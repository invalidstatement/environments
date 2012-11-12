AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.Active = 0
	
	self:SetModel("models/Slyfo/data_probe_launcher.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
	end 
	

end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.Entity:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

local function quiet_steam(ent)
	ent:StopSound( "ambient.steam01" )
end

function ENT:TurnOn()
	if (self.Active == 0) then
		if (self.Mute == 0) then
			self:EmitSound( "Airboat_engine_idle" )
		end
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(1)
	elseif ( self.overdrive == 0 ) then
		self:TurnOnOverdrive()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		if (self.Mute == 0) then
			self:StopSound( "Airboat_engine_idle" )
			self:EmitSound( "Airboat_engine_stop" )
			self:StopSound( "apc_engine_start" )
		end
		self.Active = 0
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:FindOil(trace)
	if trace.HitWorld then
		return true
	end
 
	return false --for now
end

function ENT:Extract()
	local trace = {}
	trace.start = self:GetPos()+Vector(25,0,0)	
	trace.endpos = self:GetPos()+(self:GetForward()*512)
	trace.filter = self
	local tr = util.TraceLine( trace )


	if self:GetResourceAmount("energy") > 100 then
		self:ConsumeResource("energy", 100)
		if self:FindOil(trace) then
			self:SupplyResource("Crude Oil", math.random(50,60))
		end
	else
		self:TurnOff()
	end
	
	//local effectdata = EffectData()
	//effectdata:SetEntity( self )
	//effectdata:SetOrigin( self:GetPos()+Vector(5,0,1))
	//effectdata:SetStart( tr.HitPos )
	//effectdata:SetNormal( self:GetPos()+(self:GetUp()*512) )
	//util.Effect( "laser_beam", effectdata)
end

function ENT:Think()
	if self.Active == 1 then
		self:Extract()
	end

	self:NextThink(CurTime() + 1)
	return true
end

