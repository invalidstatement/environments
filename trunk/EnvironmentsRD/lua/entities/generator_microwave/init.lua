AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion4.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion3.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion1.wav" )
util.PrecacheSound( "ambient/explosions/exp2.wav" )
util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
util.PrecacheSound( "coast.siren_citizen" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')
-- Was 2200, increased

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0

	if WireLib then
		self.WireDebugName = self.PrintName
		self.Inputs = WireLib.CreateInputs(self, { "On" })
		self.Outputs = WireLib.CreateOutputs(self, { "On", "Output" })
	else
		self.Inputs = {{Name="On"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:EmitSound( "k_lab.ambient_powergenerators" )
		self:EmitSound( "ambient/machines/thumper_startup1.wav" )
		if WireLib then WireLib.TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:StopSound( "k_lab.ambient_powergenerators" )
		self:StopSound( "coast.siren_citizen" )
		if WireLib then 
			WireLib.TriggerOutput(self, "On", 0)
			WireLib.TriggerOutput(self, "Output", 0)
		end
		self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(255, 255, 255, 255)

	self:StopSound( "coast.siren_citizen" )
end

function ENT:OnRemove()
	self:StopSound( "k_lab.ambient_powergenerators" )
	self:StopSound( "coast.siren_citizen" )
	self.BaseClass.OnRemove(self)
end

function ENT:Transfer_Energy()
	local tr = {}
	tr.start = self:GetPos() + self:GetUp()*100
	tr.endpos = self:GetPos() + self:GetUp()*50000
	tr.Filter = self
	local trace = util.TraceLine(tr)
	if trace.Entity and trace.Entity:IsValid() then
		if trace.Entity:GetClass() == "reciever_microwave" then
			local amt = self:ConsumeResource("energy", 500)
			if amt then
				trace.Entity:SupplyResource("energy", amt*0.6)
			end
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Transfer_Energy()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

