AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )


include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self.Active = 0
	
	self:SetModel("models/Slyfo/drillplatform.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Mute" })
		self.Outputs = Wire_CreateOutputs(self, { "Active" })
	
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end 
	
	self.BitPosition = 0
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
	
	if (iname == "Mute") then
		if (value > 0) then
			self.Mute = 1
		else
			self.Mute = 0
		end
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
		if WireAddon then Wire_TriggerOutput(self.Entity, "Active", self.Active) end
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
		if WireAddon then Wire_TriggerOutput(self, "Active", self.Active) end
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

function ENT:FindOil()
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos()+(self:GetUp()*-100)
	tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if trace.HitWorld then
		return true
	end
 
	return false --for now
end

function ENT:Extract()

	if self:GetResourceAmount("water") < 50 then
	     Environments.DamageLS(self, math.random(2,3))
		 else
		 self:ConsumeResource("water", 36)
		end

	if self:GetResourceAmount("energy") > 100 then
		self:ConsumeResource("energy", 100)
		if self:FindOil() then
			self:SupplyResource("Crude Oil", math.random(50,60))
			self:SupplyResource("Natural Gas", math.random(70,90))
		end
	else
		self:TurnOff()
	end
end

function ENT:Think()
	if self.Active == 1 then
		self:Extract()
	end

	self:NextThink(CurTime() + 1)
	return true
end

