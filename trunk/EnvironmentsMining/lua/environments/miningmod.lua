------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

MiningMod = {}
local MM = MiningMod
MM.Oil = false
MM.Asteroids = true

MM.Spawned = {}
MM.Spawned.Roids = {}

local roidmodels = {}
roidmodels[1] = "models/ce_ls3additional/asteroids/asteroid_200.mdl"
roidmodels[2] = "models/props_foliage/rock_forest03.mdl"
roidmodels[3] = "models/props_wasteland/rockgranite01c.mdl"

local function RoidRespawn(ent)
	MM.Spawned.Roids[ent] = nil
	local pos = ent:GetPos()
	local res = ent.Resource
	local model = ent:GetModel()
	timer.Simple(20, function()
		local ent = ents.Create("prop_physics")

		ent:SetModel(model)
		ent:SetPos(pos)
		ent:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
		ent:Spawn()
		
		ent:CallOnRemove("RespawnRoid", RoidRespawn)
	
		local phys = ent:GetPhysicsObject() --freeze
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
		MM.Spawned.Roids[ent] = 1
	end)
end

local function Init()
	print("hey")
	MM.SpawnStuff()
end
hook.Add("InitPostEntity", "MMSpawnRoids", Init)

function MM.MakeRoid(pos)
	ent:SetModel(table.Random(roidmodels))
	ent:SetPos(pos)
	ent:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
	ent:Spawn()
	
	local phys = ent:GetPhysicsObject() --freeze
	if phys and phys:IsValid() then
		phys:EnableMotion(false)
	end	
	
	MM.Spawned.Roids[ent] = 1
end

function MM.SpawnStuff()
	if MM.Asteroids then
		for i = 1, 20 do --spawn roids in orbit of planets
			local ent = ents.Create("prop_physics")
			local env = table.Random(environments)
			local pos = math.RandomCirclePoint(env:GetPos(), env.radius + math.Rand(300,1500), math.Rand(-180, 180))
			ent:SetModel(table.Random(roidmodels))
			ent:SetPos(pos)
			ent:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
			ent:Spawn()
			
			ent.OreAmount = 2000
			
			local phys = ent:GetPhysicsObject() --freeze
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end	
			
			MM.Spawned.Roids[ent] = 1
		end
		print("spawning rocks")
		for i = 1, 20 do --random ones
			local notfinished = true
			local rep = 0
			while notfinished do
				rep = rep + 1
				local a = VectorRand()*16384
				if util.IsInWorld(a) then --add check to make sure they arent in something
					if !Environments.FindEnvironmentOnPos(a) then
						local ent = ents.Create("prop_physics")

						ent:SetModel(table.Random(roidmodels))
						ent:SetPos(a)
						ent:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
						ent:Spawn()
						
						ent.OreAmount = 2000
						
						ent:CallOnRemove("RespawnRoid", RoidRespawn)
						
						local phys = ent:GetPhysicsObject() --freeze
						if phys and phys:IsValid() then
							phys:EnableMotion(false)
						end
						MM.Spawned.Roids[ent] = 1
						notfinished = false
					end
				end
				if rep > 15 then
					notfinished = false
					print("find pos failed, continuing")
				end
			end
		end
	end
	if MM.Oil then
		for k,v in pairs(environments) do
			if v:IsPlanet() then
				local rad = v.radius
				local pos = v:GetPos()
				
				--need to figure out how to get positions underground....
				--then make a few random boxes of oil underground
				--this will be checked by a drill/GPR, to see if anything is down there
			end
		end
	end
end

function Environments.FindEnvironmentOnPos(pos)
	for k,v in pairs(environments) do
		if pos:Distance(v:GetPos()) <= v.radius then
			return v
		end
	end
	return nil
end

function math.RandomCirclePoint(vec, rad, p)
	local cur = Vector(rad, 0, 0)

	cur:Rotate(Angle(p or 0,math.random(0,360),0))

	return cur + vec --offset to change the origin to the supplied vector
end


-- wrex.. Added functions to make it where clients couldn't touch the asteroids


	-- physgun and gravity gun blocking code
function ToolPickup(ply,ent) 
	for k,v in pairs(roidmodels) do
		if(!ent:IsValid()) then 
		return end		
		if (ent:GetModel() == v ) then
		return false end 
	end	
end
	
hook.Add("PhysgunPickup", "PhysgunPickup", ToolPickup)
hook.Add("GravGunPunt", "GravGunPunt", ToolPickup)
hook.Add("GravGunPickupAllowed", "GravGunPickupAllowed", ToolPickup)
 

-- tool gun blocking code
function CanTool(ply, tr, toolgun)
	for k,v in pairs(roidmodels) do
	
		if(tr.HitWorld) then return end
		ent = tr.Entity
		if(!ent:IsValid()) then return end
		if(ent:GetModel() == v )then
		return false
		end
		
	 end
	 
 end
 hook.Add("CanTool", "AsteriodCanTool", CanTool)
 

