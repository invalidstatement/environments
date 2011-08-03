
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.IsLS = true

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetNetworkedInt( "OOO", 0 )
	self.Active = 0
end

function ENT:SetActive( value, caller )
	if ((not(value == nil) and value != 0) or (value == nil)) and self.Active == 0 then
		if self.TurnOn then self:TurnOn( nil, caller ) end
	elseif ((not(value == nil) and value == 0) or (value == nil)) and self.Active == 1 then
		if self.TurnOff then self:TurnOff( nil, caller ) end
	end
end

function ENT:SetOOO(value)
	self:SetNetworkedInt( "OOO", value )
end

AccessorFunc( ENT, "LSMULTIPLIER", "Multiplier", FORCE_NUMBER )
function ENT:GetMultiplier()
	return self.LSMULTIPLIER or 1
end

function ENT:Repair()
	self:SetHealth( self:GetMaxHealth())
	self:SetColor(255,255,255,255)
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		self:SetActive( nil, caller )
	end
end

function ENT:OnTakeDamage(DmgInfo)//should make the damage go to the shield if the shield is installed(CDS)
	if self.Shield then
		self.Shield:ShieldDamage(DmgInfo:GetDamage())
		CDS_ShieldImpact(self:GetPos())
		return
	end
	Environments.DamageLS(self, DmgInfo:GetDamage())
end

function ENT:OnRemove()
	if self.node then
		self.node:Unlink(self)
	end
	if WireLib then WireLib.Remove(self) end
end

function ENT:ConsumeResource( resource, amount)
	if self.node then
		return self.node:ConsumeResource(resource, amount)
	end
end

function ENT:SupplyResource(resource, amount)
	if self.node then
		return self.node:GenerateResource(resource, amount)
	end
end

function ENT:Link(ent)
	if self.node then
		self.node:Unlink(self)
	end
	if ent and ent:IsValid() then
		self.node = ent
		umsg.Start("Env_SetNodeOnEnt")
			umsg.Entity(self)
			umsg.Entity(ent)
		umsg.End()
		--self:SetNWEntity("node", ent)
	end
end

function ENT:Unlink()
	if self.node then
		self.node:Unlink(self)
		self.node = nil
		umsg.Start("Env_SetNodeOnEnt")
			umsg.Entity(self)
			umsg.Entity(NullEntity())
		umsg.End()
	end
end

function ENT:GetResourceAmount(resource)
	if self.node then
		if self.node.resources[resource] then
			return self.node.resources[resource].value
		else
			return 0
		end
	else
		return 0
	end
end

function ENT:GetUnitCapacity(resource)
	return self.maxresources[resource]
end

function ENT:GetNetworkCapacity(resource)
	if self.node then
		return self.node.maxresources[resource]
	end
end

function ENT:OnRestore()
	if WireLib then WireLib.Restored(self) end
end

function ENT:PreEntityCopy()
	Environments.BuildDupeInfo(self)
	if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	Environments.ApplyDupeInfo(Ent, CreatedEntities)
	if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
