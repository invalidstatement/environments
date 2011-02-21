------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local Space = Space

PlayerGravity = true

CompatibleEntities = {"func_precipitation", "env_smokestack", "func_dustcloud"}

include("shared.lua")
include("core/base.lua")
	
function ENT:Initialize()
	self.Entity:SetModel( "models/combine_helicopter/helicopter_bomb01" ) --setup stuff
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:PhysicsInitSphere(1)
	self:SetCollisionBounds(Vector(-1,-1,-1),Vector(1,1,1))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:DrawShadow(false)
	
	self.gravity = 0
	self.Debugging = false
	
	local phys = self.Entity:GetPhysicsObject() --reset physics
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	self:SetColor(255,255,255,0) --Make invis
	
	//Important Tables
	self.Entities = {}
end

function ENT:StartTouch(ent)
	if not ent:GetPhysicsObject():IsValid() then return end
	if ent:IsWorld() then return end
	
	if ent:GetClass() == "func_door" then return end
	
	if not self.Enabled then 
		if self.Debugging then Msg("Entity ", ent, " tried to enter but ", self.name, " wasn't on.\n") end
		
		return
	elseif self.Debugging then 
		Msg("Entity ", ent, " has started touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = ent
end

function ENT:EndTouch(ent)
	if ent:IsWorld() then return end
	
	if self.Debugging then
		Msg("Entity ", ent, " has stopped touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = nil

	if not ent:GetPhysicsObject():IsValid() then return end

	if ent.environment == self then
		if( ent:IsPlayer() ) then
			ent:SetGravity( 0.00001 )
			if not ent:IsAdmin() then
				ent:SetMoveType( MOVETYPE_WALK )
			end
			
			ent:SetNWBool( "inspace", true )
		else
			ent:GetPhysicsObject():EnableDrag( false )
			ent:GetPhysicsObject():EnableGravity( false )
		end
		ent.environment = Space()
		if self.Debugging then Msg("...and has decided to get spaced.\n") end
	else
		--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
	end
end

function ENT:Check()
	--local start = SysTime()
	local radius = self.radius
	for k,ent in pairs(self.Entities) do
		if ent:GetPhysicsObject():IsValid() then
			if ent:GetPos():Distance(self:GetPos()) <= radius then
				//Set Planet
				ent:SetGravity( self.gravity )
				ent:GetPhysicsObject():EnableDrag( true )
				ent:GetPhysicsObject():EnableGravity( true )
				ent.environment = self
				if( ent:IsPlayer() ) then
					ent:SetNWBool( "inspace", false )
				end
			else --space
				//Set Space
				if ent.environment == self then
					if( ent:IsPlayer() ) then
						ent:SetGravity( 0.00001 )
						if not ent:IsAdmin() then
							ent:SetMoveType( MOVETYPE_WALK )
						end

						ent:SetNWBool( "inspace", true )
					else
						ent:GetPhysicsObject():EnableDrag( false )
						ent:GetPhysicsObject():EnableGravity( false )
					end
					ent.environment = Space()
					if self.Debugging then Msg("...and has decided to get spaced.\n") end
				else
					--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
				end
			end
		end
	end
	--print(self.name, SysTime()-start, table.Count(self.Entities))
end

function ENT:Think()
	if not self:GetPos() == self.position then
		self:SetPos(self.position)
	end
	
	if self.Entities then
		self:Check()
	
		if self.unstable == "true" then
			local rand = math.random(1,50)
			if rand == 5 then
				util.ScreenShake(self:GetPos(), 14, 255, 6, self.radius)
				--self.Shaker:Fire("StartShake")
			end
		end
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Configure(rad, gravity, name, env)
	self:PhysicsInitSphere(rad)
	self:SetCollisionBounds(Vector(-rad,-rad,-rad),Vector(rad,rad,rad))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:SetMoveType( MOVETYPE_NONE )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	for k,v in pairs(env) do
		self[k] = v
	end
	
	self.radius = rad
	self.Enabled = true
	self.gravity = gravity
	
	if Init_Debugging_Override or self.Debugging then
		Msg("Initialized a new entity env: ", self, "\n")
		Msg("ID is: ", self.name, "\n")
		Msg("Dumping stats:\n")
		Msg("------------ START DUMP ------------\n")
		PrintTable(self.air)
		Msg("------------- END DUMP -------------\n\n")
	end
	
	//Fill World Entity Table
	for k,ent in pairs(ents.FindInSphere(self:GetPos(), self.radius)) do
		if table.HasValue(CompatibleEntities, ent:GetClass()) then
			RegisterWorldSFXEntity(ent, self)
		end
	end
	
	//Create the earthquaker if need be :)
	/*if self.unstable == "true" then
		self.Shaker = ents.Create("env_shake")
		self.Shaker:Spawn()
		self.Shaker:SetPos(self:GetPos())
		self.Shaker:SetKeyValue("radius", self.radius)
		self.Shaker:SetKeyValue("duration", 6)
		self.Shaker:Fire("Amplitude", 14)
		self.Shaker:Fire("Frequency", 255)
	end*/
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

