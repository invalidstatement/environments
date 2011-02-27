AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:SetModel("models/props_wasteland/rockgranite04c.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(false)
		phys:SetMass(50000)
	end
	self:SetColor(150,150,150,255)
	self.firstthink = true
end

function ENT:PhysicsCollide(ent)
	if not self.Burn then return end
	local expl = ents.Create("env_explosion")
	expl:SetPos(self.Entity:GetPos())
	expl:SetParent(self.Entity)
	expl:SetOwner(self.Entity:GetOwner())
	expl:SetKeyValue("iMagnitude","1000");
	expl:SetKeyValue("iRadiusOverride", 2000)
	expl:Spawn()
	expl:Activate()
	util.ScreenShake(self:GetPos(), 14, 255, 6, 5000)
	expl:Fire("explode", "", 0)	
	expl:Fire("kill", "", .5)
	for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),500)) do
		if v:IsValid() then
			constraint.RemoveAll(v)
		end
	end
	local tr = util.QuickTrace(self.Entity:GetPos(), self.Entity:GetPos()+(self.Entity:GetVelocity()*100), self.Entity)
	if tr.Entity then
		if tr.Entity:IsValid() then
			constraint.RemoveAll(tr.Entity)
		end
	end
	self.Entity:Remove()
end

function ENT:Start(planet)
	self.target = planet.position
	self:GetPhysicsObject():SetVelocity( (self.target - self:GetPos() ):Normalize() * 700 ) 
end

function ENT:Think()
	if not self.firstthink then
		if self.Burn ~= true then
			self.Burn = true
			self:Ignite(20,100)
			self.flame = ents.Create("env_fire_trail")
			self.flame:SetAngles(self.Entity:GetAngles())
			self.flame:SetPos(self.Entity:GetPos())
			self.flame:SetParent(self.Entity)
			self.flame:Spawn()
			self.flame:Activate()
		end
	else
		self.firstthink = false
	end
	self.Entity:NextThink(CurTime()+1)
	return true
end