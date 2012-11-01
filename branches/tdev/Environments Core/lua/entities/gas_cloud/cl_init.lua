include('shared.lua')

function ENT:Draw()            
	self:DrawModel()
end  

function ENT:Initialize()
	local ed = EffectData()
	ed:SetEntity(self)
	util.Effect("gas_cloud", ed)
end

