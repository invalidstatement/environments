AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local rockmodels = {
	"models/props_canal/rock_riverbed02c.mdl",
	"models//props_debris/concrete_spawnchunk001a.mdl",
	"models//props_debris/concrete_spawnchunk001b.mdl",
	"models//props_debris/concrete_spawnchunk001c.mdl",
	"models//props_debris/concrete_spawnchunk001d.mdl",
	"models//props_debris/concrete_spawnchunk001e.mdl",
	"models//props_debris/concrete_spawnchunk001f.mdl",
	"models//props_debris/concrete_spawnchunk001g.mdl",
	"models//props_debris/concrete_spawnchunk001h.mdl",
	"models//props_debris/concrete_spawnchunk001i.mdl",
	"models//props_debris/concrete_spawnchunk001j.mdl",
	"models//props_debris/concrete_spawnchunk001k.mdl",
	"models/props_wasteland/rockcliff01g.mdl",
	"models/props_wasteland/rockgranite01c.mdl",
	"models/props_wasteland/rockgranite04b.mdl",
	"models/props_wasteland/rockcliff01c.mdl",
	"models/props_wasteland/rockcliff01j.mdl",
	"models/props_wasteland/rockgranite02a.mdl",
	"models/props_wasteland/rockcliff01e.mdl",
	"models/props_wasteland/rockgranite01a.mdl",
	"models/props_wasteland/rockgranite03c.mdl",
	"models/props_wasteland/rockcliff01b.mdl",
	"models/props_wasteland/rockcliff01f.mdl",
	"models/props_wasteland/rockgranite01b.mdl",
	"models/props_wasteland/rockcliff01g.mdl",
	}

function ENT:Initialize()
	self.Entity:SetModel(rockmodels[math.random(1,table.Count(rockmodels))])
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(2500)
	end
	self.firstthink = true
end

function ENT:PhysicsCollide(ent)
	if not self.Burn then return end
	local expl = ents.Create("env_explosion")
	expl:SetPos(self.Entity:GetPos())
	expl:SetParent(self.Entity)
	expl:SetOwner(self.Entity:GetOwner())
	expl:SetKeyValue("iMagnitude","400");
	expl:SetKeyValue("iRadiusOverride", 250)
	expl:Spawn()
	expl:Activate()
	expl:Fire("explode", "", 0)	
	expl:Fire("kill", "", .5)
	for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),100)) do
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

function ENT:Think()
	if not self.firstthink then
		if self.Burn ~= true then
			self.Burn = true
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