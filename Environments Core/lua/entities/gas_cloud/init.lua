AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/Items/BoxSRounds.mdl")
	//self.Entity:PhysicsInit(SOLID_VPHYSICS)
	//self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	//self.Entity:SetSolid(SOLID_VPHYSICS)
	//local phys = self.Entity:GetPhysicsObject()
	//if (phys:IsValid()) then
		//phys:EnableGravity(false)
		//phys:SetMass(50000)
	//end
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	
	self:SetColor(Color(255,255,255,0))
	
	self:SetAmount(1)
	self.ResourceName = ""
end

function ENT:SetResource(res)
	self.ResourceName = res
end

function ENT:SetAmount(x)
	self.ResourceAmount = x
	self:SetNWInt("resourceamt", x)
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() < 1 then
		self:EmitSound("Weapon_Mortar.Impact")
		self:Remove()
	end
end

function ENT:Suck(amt)//dont forget to add effects
	if amt > self.ResourceAmount then
		amt = self.ResourceAmount
	end
	
	self:SetResource(self.ResourceAmount - amt)
	return amt
end

function ENT:Think()
	if self.ResourceAmount < 1 then
		self:Remove()
	end
	self:NextThink(CurTime()+1)
	return true
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