

//TODO:
//1. (WIP) Add syncing to joining clients
//2. (DONE) Finish restoring
//3. Add more contraint compatibility
//4. Add option to freeze it when shrinking/restoring
//5. Nocollide constrained shrunken props
TOOL.Category = 'Tools'
TOOL.Name = '#Prop Shrinker'
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Environments"

TOOL.ClientConVar[ "scale" ] = 0.25
TOOL.ClientConVar[ "parent" ] = 0
TOOL.ClientConVar[ "freeze" ] = 1

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then
	language.Add( "Tool_prop_shrinker_name", "Prop Shrinker" )
	language.Add( "Tool_prop_shrinker_desc", "Enables walking on a prop even in low-to-zero gravity." )
	language.Add( "Tool_prop_shrinker_0", "Left Click to Shrink All Constrained Props.  Right Click To Restore to Normal Size." )
end

local function SaveShrink( Player, Entity, Data )
	if not SERVER then return end
	if Data.GravPlating and Data.GravPlating == 1 then
		Entity.grav_plate = 1
		if ( SERVER ) then
			Entity.EntityMods = Entity.EntityMods or {}
			Entity.EntityMods.GravPlating = Data
		end
	else
		Entity.grav_plate = nil
		if ( SERVER ) then
			if Entity.EntityMods then Entity.EntityMods.GravPlating = nil end
		end	
	end
	duplicator.StoreEntityModifier( Entity, "gravplating", Data )
end
duplicator.RegisterEntityModifier( "gravplating", SaveShrink )

function TOOL:LeftClick( trace )
	if trace.Entity then
		if !trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld or trace.Entity:IsNPC() or trace.Entity.Shrunken then
			return false
		end
	end
	if CLIENT then return true end
	if self:GetOwner():IsAdmin() then
		local scale = tonumber(self:GetClientInfo("scale")) or 0
		if scale < 0.01 then //keep it in safe bounds
			scale = 0.01
		elseif scale > 2 then
			scale = 2
		end
		
		local parent = tobool(self:GetClientInfo("parent")) or false
		local freeze = tobool(self:GetClientInfo("freeze")) or false
		
		Shrink.DoShrink(trace.Entity, scale, parent, freeze, self:GetOwner())
		
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('Props have been shrunken.', NOTIFY_GENERIC, 7);" )
	else
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('You must be admin to use this.', NOTIFY_GENERIC, 7);" )
	end
	return true
end

function TOOL:RightClick( trace )//not finished
	if trace.Entity then
		if !trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld or trace.Entity:IsNPC() or !trace.Entity.Shrunken then
			return false
		end
	end
	if CLIENT then return true end
	if self:GetOwner():IsAdmin() then
		Shrink.DoRestore(trace.Entity)
		
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('Props have been restored.', NOTIFY_GENERIC, 7);" )
	else
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('You must be admin to use this.', NOTIFY_GENERIC, 7);" )
	end
	return true
end

function TOOL.BuildCPanel( CPanel)
	local cp = CPanel
	cp:AddControl("Header",{Text = "#Tool_prop_shrinker_name", Description = "#Tool_prop_shrinker_desc"})
	
	cp:AddControl("Slider",{Label = "Scale", Description = "The scale to shrink the props to.", Type = "Float", Min = 0.01, Max = 2, Command = "prop_shrinker_scale"})
	cp:AddControl("Checkbox",{Label = "Parent?", Description = "Attach the props together with parenting? Makes them far more stable, but only the parent will collide.", Command = "prop_shrinker_parent"})
	cp:AddControl("Checkbox",{Label = "Freeze?", Description = "Keep the shrunken props from moving, highly recommended with stationary structures.", Command = "prop_shrinker_freeze"})
	//cp:AddControl("Slider",{Label = "Player Gravity Percentage", Description = "The percentage of normal gravity to apply to players inside. *DOES NOT WORK WITH PROPS YET*", Type = "Integer", Min = 0, Max = 500, Command = "localphysics_gravity"})
	//cp:AddControl("Button",{Label = "Help", Description = "Help, obviously", Command = "ghd_help"})
	//cp:AddControl("Button",{Label = "Fix Camera", Description = "If you're teleporting to the sky when you enter a ship, click this until it works.", Command = "ghd_fixcamera"})
end


Shrink = {}
local s = Shrink

local ShrinkedEnts = {}

local badstuff = {}
local a = badstuff//this stuff crashes if you try to shrink it
a["prop_vehicle_jeep"] = true
a["prop_vehicle_jeep_old"] = true
a["prop_vehicle_airboat"] = true
a["prop_ragdoll"] = true
function s.DoShrink(ent, scale, parent, freeze, ply)
	local es = constraint.GetAllConstrainedEntities(ent)
	
	//clear constraints
	for k,v in pairs(es) do
		v.tempcons = constraint.GetTable(v)
	end
	
	for k,v in pairs(es) do
		constraint.RemoveAll(v)
		v.Shrunken = scale //dont let people shrink stuff more than once, its very glitchy
	end
	
	if !badstuff[ent:GetClass()] then
		//actually shrink
		for k,v in pairs(es) do
			s.Shrink(v, ent, scale or 0.25)
		end
		
		//redo constraints
		for k,v in pairs(es) do
			local cons = v.tempcons
			v.tempcons = nil
			
			if parent then
				v:SetParent(ent)
				v:SetSolid(SOLID_BBOX)
			end
		
			if cons then
				for k,v in pairs(cons) do
					if v.Type == "Weld" then
						v.Ent1:GetTable().Constraints = nil//hopefully this wont be needed anymore
						//v.Ent2:GetTable().Constraints = nil
						//print(constraint.CanConstrain(v.Ent1, v.Bone1))
						//print(constraint.Find(v.Ent1, v.Ent2, "Weld", 0,0))
						local weld = constraint.Weld(v.Ent1, v.Ent2, v.Bone1 or 0, v.Bone2 or 0, v.forcelimit, true)
					elseif v.Type == "Axis" then//doesnt work right
						//v.Ent1:GetTable().Constraints = nil
						
						//local axis = constraint.Axis(v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.forcelimit, v.torquelimit, v.friction, true, v.LocalAxis)
					end
				end
			end
			
			if freeze then
				v:GetPhysicsObject():EnableMotion( false ) 
				if ply then
					ply:AddFrozenPhysicsObject( v, v:GetPhysicsObject() )
				end
			end
			
			ShrinkedEnts[v:EntIndex()] = scale
		end
	end
end

function s.DoRestore(ent, freeze)
	local es = constraint.GetAllConstrainedEntities(ent)
	
	for k,v in pairs(es) do
		local cons = constraint.GetTable(v)
		constraint.RemoveAll(v)

		if !badstuff[ent:GetClass()] then
			s.Restore(v, ent)
		
			if cons then
				for k,v in pairs(cons) do
					if v.Type == "Weld" then
						v.Ent1:GetTable().Constraints = nil
						//v.Ent2:GetTable().Constraints = nil
						//print(constraint.CanConstrain(v.Ent1, v.Bone1))
						//print(constraint.Find(v.Ent1, v.Ent2, "Weld", 0,0))
						local weld = constraint.Weld(v.Ent1, v.Ent2, v.Bone1 or 0, v.Bone2 or 0, v.forcelimit, true)
					elseif v.Type == "Axis" then//doesnt work right
						//v.Ent1:GetTable().Constraints = nil
						
						//local axis = constraint.Axis(v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.forcelimit, v.torquelimit, v.friction, true, v.LocalAxis)
					end
				end
			end
			
			if freeze then
				v:GetPhysicsObject():EnableMotion( false ) 
				if ply then
					ply:AddFrozenPhysicsObject( v, v:GetPhysicsObject() )
				end
			end
			
			ShrinkedEnts[v:EntIndex()] = nil//its fine now
		end
		v.Shrunken = false //they can now mess with it again, it has been restored
	end
end


local function Sync(ply)
	for k,v in pairs(ShrinkedEnts) do
		local ent = Entity(k)
		if ent and ent:IsValid() then
			umsg.Start("addhullent", ply)
				umsg.Short(k)
				umsg.Short(0)
				umsg.Float(v)
			umsg.End()
		else
			ShrinkedEnts[k] = nil--its invalid, this would just slow everything down to send it to the clients
		end
	end
end
hook.Add("PlayerInitialSpawn", "SyncShrink", Sync)

if CLIENT then
	local shrinked = {}
	
	local function shrinkcheck()//this isnt working
		for k,v in pairs(shrinked) do
			local ent = Entity(k)
			if ent and ent:IsValid() then
				//print("scaled "..tostring(ent).." "..tostring(v))
				ent:SetModelScale(Vector(v, v, v))
				ent.DrawEntityOutline = function() end
				
				shrinked[k] = nil//dont loop through us again, we are finished
			end
		end
	end
	timer.Create("ShrinkCheck", 1, 0, shrinkcheck)//possibly increase interval
	
	local function addhullent(msg)
		local entID = msg:ReadShort()
		local hullID = msg:ReadShort()
		local scale = msg:ReadFloat()
		
		local ent = Entity(entID)
		if ent and ent:IsValid() then
			ent:SetModelScale(Vector(scale,scale,scale))
			//print(ent:OBBMins(), ent:OBBMaxs())
			//ent:SetCollisionBounds(ent:OBBMins()*scale, ent:OBBMaxs()*scale)
			ent.DrawEntityOutline = function() end//fixes it breaking the clientside scale
		else
			shrinked[entID] = scale//this isnt working
		end
	end
	usermessage.Hook("addhullent", addhullent)
end

local MCents = {}//this stuff needs the motion controller started after shrinking
local b = MCents
b["gmod_hoverball"] = true
b["gmod_thuster"] = true
b["gmod_masslessthruster"] = true
function s.Shrink(ent, mainent, scale)
	local angles = ent:GetAngles()
	local pos = mainent:WorldToLocal(ent:GetPos())*scale
	ent:SetPos(mainent:LocalToWorld(pos))
	//e:SetModel(ent:GetModel())
	//print(ent:OBBMins(), ent:OBBMaxs())
	local min = ent:OBBMins()*scale
	local max = ent:OBBMaxs()*scale
	ent:SetCollisionBounds(min, max)
	//e:SetSolid(SOLID_VPHYSICS)
	//e:SetMoveType(MOVETYPE_VPHYSICS)
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:PhysicsInitSphere(10)
	ent:PhysicsInitBox(min, max)
	//ent:SetMoveType(MOVETYPE_VPHYSICS)
	//e:GetPhysicsObject():Wake()
	//e:GetPhysicsObject():EnableMotion(false)
	if MCents[ent:GetClass()] then
	    ent:StartMotionController()
	else
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
		    phys:SetMass((phys:GetMass() or 1)*(scale^2))
		end
	end
	ent:SetAngles(angles)
	
	//send to client
	umsg.Start("addhullent")
		umsg.Short(ent:EntIndex())
		umsg.Short(mainent:EntIndex())//hull ent
		umsg.Float(scale or 0.25)
	umsg.End()
end

function s.Restore(ent, mainent)//physics remain glitchy, reasons unknown
	local scale = 1/(ent.Shrunken or 1)
	local angles = ent:GetAngles()
	local pos = mainent:WorldToLocal(ent:GetPos())*scale//plz dont error
	
	local min = ent:OBBMins()*scale
	local max = ent:OBBMaxs()*scale
	ent:SetCollisionBounds(min, max)
	
	ent:SetPos(mainent:LocalToWorld(pos))
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetMoveType(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	
	//todo reset mass
	if MCents[ent:GetClass()] then
	    ent:StartMotionController()
	else
		//local phys = ent:GetPhysicsObject()
		//if phys and phys:IsValid() then
		    //phys:SetMass((phys:GetMass() or 1)*(scale^2))
		//end
	end
	
	ent:SetAngles(angles)
	
	umsg.Start("addhullent")
		umsg.Short(ent:EntIndex())
		umsg.Short(mainent:EntIndex())//hull ent
		umsg.Float(1)
	umsg.End()
end