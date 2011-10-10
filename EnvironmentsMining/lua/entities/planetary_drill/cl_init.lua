include('shared.lua')

function ENT:Draw(a)
	self.BaseClass.Draw(self, a)
	--self:DrawModel()
	if self:GetOOO() == 1 then
		local ang = self.Drill:GetAngles()
		ang:RotateAroundAxis(self.Drill:GetUp(), FrameTime()*50)
		self.Drill:SetAngles(ang)
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.Drill = ClientsideModel("models/Slyfo/rover_drillshaft.mdl", RENDERGROUP_OPAQUE)
	self.Drill:SetModel("models/Slyfo/rover_drillshaft.mdl")
	self.Drill:SetPos(self:LocalToWorld(Vector(0,0,150)))
	self.Drill:SetParent(self)
	
	self.Drillbit = ClientsideModel("models/Slyfo/rover_drillbit.mdl", RENDERGROUP_OPAQUE)
	self.Drillbit:SetModel("models/Slyfo/rover_drillbit.mdl")
	self.Drillbit:SetPos(self:LocalToWorld(Vector(0,0,25)))
	self.Drillbit:SetParent(self.Drill)
	
	self.BitPosition = 0
end	

function ENT:OnRemove()
	self.Drill:Remove()
	self.Drillbit:Remove()
end

function ENT:Think()
	local mult = FrameTime()*10
	if self:GetOOO() == 1 then
		if self.BitPosition <= 150 then
			self.BitPosition = self.BitPosition + mult
			self.Drill:SetPos(self:LocalToWorld(Vector(0,0,150 - self.BitPosition)))
		end
	else
		if self.BitPosition > 0 then
			self.BitPosition = self.BitPosition - mult
			self.Drill:SetPos(self:LocalToWorld(Vector(0,0,150 - self.BitPosition)))
		end
	end
end

language.Add("other_dispenser", "Dispenser")