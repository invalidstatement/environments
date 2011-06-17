AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:Remove()
end

function ENT:IsActive()	

end

function ENT:SetStartSound(sound)

end

function ENT:SetStopSound(sound)

end

function ENT:SetAlarmSound(sound)

end

function ENT:SetDefault()

end

function ENT:SetRange(amount)

end

function ENT:GetRange()

end

function ENT:SetTempGiven(amount)

end

function ENT:CoolDown(temp)

end

function ENT:GetLSClass()

end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:TriggerInput(iname, value)

end

function ENT:Think()

end

function ENT:ConsumeBaseResources()

end

function ENT:CheckResources()

end

--Still need to check
--check
function ENT:Damage()

end

--check
function ENT:Repair()

end

--check 
function ENT:Destruct()

end

--check
function ENT:OnRemove()

end
