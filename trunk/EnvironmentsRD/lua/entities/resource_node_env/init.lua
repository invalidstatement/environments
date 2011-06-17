
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.NoSpaceAfterEndTouch = true

function ENT:SpawnFunction(ply, tr) -- Spawn function needed to make it appear on the spawn menu
	local ent = ents.Create("resource_node_env") -- Create the entity
	ent:SetPos(tr.HitPos + Vector(0, 0, 50) ) -- Set it to spawn 50 units over the spot you aim at when spawning it
	ent:Spawn() -- Spawn it
 
	return ent -- You need to return the entity to make it work
end

function ENT:Initialize()
	//self.BaseClass.Initialize(self) --use this in all ents
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	--self:SetNetworkedInt( "overlaymode", 2 )
	
	self.nextcheck = CurTime() + 5
	
	//rd table
	self.resources = {}
	self.connected = {}
	self.maxresources = {}
	/*if self.maxresources then
		for name,max in pairs(self.maxresources) do
			self.maxresources[name] = max
			self:SetNWInt("max"..name, self.maxresources[name])
		end
	end*/
	
	self.vent = false
	
	self:Think()
end

function ENT:TriggerInput(iname, value)
	
end

function ENT:Link(ent)
	if ent == self then return end
	
	self.connected[ent:EntIndex()] = ent
	if ent.maxresources then
		for name,max in pairs(ent.maxresources) do
			local curmax = self.maxresources[name]
			if curmax then
				self.maxresources[name] = curmax + max
			else
				self.maxresources[name] = max
			end
			self:SetNWInt("max"..name, self.maxresources[name])
		end
	end
	if ent.resources then
		for name,amt in pairs(ent.resources) do
			local curmax = self.maxresources[name]
			local cur = self.resources[name]
			if cur and (cur + amt) <= curmax then
				self.resources[name] = cur + amt
			elseif cur then
				self.resources[name] = curmax
			else
				self.resources[name] = amt
			end
			self.updated = true
		end
	end
end

function ENT:Unlink(ent)
	if ent and ent:IsValid() then
		self.connected[ent:EntIndex()] = nil
		if not ent.maxresources then return end
		for name,max in pairs(ent.maxresources) do
			local curmax = self.maxresources[name]
			if curmax then
				self.maxresources[name] = curmax - max
			end
			self:SetNWInt("max"..name, self.maxresources[name])
		end
	end
end

function ENT:Repair()
	self:SetHealth( self:GetMaxHealth( ))
end

function ENT:Leak()
	if self.environment then
		if self.vent == "oxygen" then
			local air = self:GetResourceAmount("oxygen")
			local mul = air/self.maxresources["oxygen"]
			local am = math.Round(mul * 1000);
			if (air >= am) then
				self:ConsumeResource("oxygen", am)
				self.environment:Convert(-1, 0, am)
			else
				self:ConsumeResource("oxygen", air)
				self.environment:Convert(-1, 0, air)
			end
		elseif self.vent == "nitrogen" then
			local air = self:GetResourceAmount("nitrogen")
			local mul = air/self.maxresources["nitrogen"]
			local am = math.Round(mul * 1000);
			if (air >= am) then
				self:ConsumeResource("nitrogen", am)
				self.environment:Convert(-1, 2, am)
			else
				self:ConsumeResource("nitrogen", air)
				self.environment:Convert(-1, 2, air)
			end
		elseif self.vent == "hydrogen" then
			local air = self:GetResourceAmount("hydrogen")
			local mul = air/self.maxresources["hydrogen"]
			local am = math.Round(mul * 1000);
			if (air >= am) then
				self:ConsumeResource("hydrogen", am)
				self.environment:Convert(-1, 3, am)
			else
				self:ConsumeResource("hydrogen", air)
				self.environment:Convert(-1, 3, air)
			end
		end
		self.updated = true
	end
end

function ENT:LinkCheck()
	local curpos = self:GetPos()
	for k,v in pairs(self.connected) do
		if !v or !v:IsValid() then
			self.connected[k] = nil
			continue
		end
		if v:GetPos():Distance(curpos) > 2054 then
			v:Unlink()
			self:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
			v:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
		end
	end
end

function ENT:Think()
	if self.nextcheck < CurTime() then
		self:LinkCheck()
		self.nextcheck = CurTime() + 5
	end
	if self.updated then
		for name,value in pairs(self.resources) do
			self:SetNWInt(name, value)
		end
		self.updated = false
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:GenerateResource(name, amt)
	local res = self.resources[name]
	local max = self.maxresources[name]
	if not max then return 0 end
	if res then
		if res + amt < max then
			self.resources[name] = self.resources[name] + amt
			self.updated = true
			return amt
		else
			self.resources[name] = max
			self.updated = true
			return max - res
		end
	else
		self.resources[name] = amt
		self.updated = true
		return amt
	end
	return amt
end

function ENT:ConsumeResource(name, amt)
	if self.resources[name] then
		local res = self.resources[name]
		if res >= amt then
			self.resources[name] = res - amt
			self.updated = true
			return amt
		elseif not res == 0 then
			amt = res
			res = 0
			self.updated = true
			return res
		else
			return 0
		end
	else
		return 0
	end
end

function ENT:OnTakeDamage(DmgInfo)//should make the damage go to the shield if the shield is installed(CDS)
	if self.Shield then
		self.Shield:ShieldDamage(DmgInfo:GetDamage())
		CDS_ShieldImpact(self:GetPos())
		return
	end
end

function ENT:OnRemove()	
	if self.connected then
		for k,v in pairs(self.connected) do
			if v and v:IsValid() then
				v:Unlink()
			end
		end
	end
	if not (WireAddon == nil) then Wire_Remove(self) end
end

function ENT:GetResourceAmount(resource)
	if self.resources[resource] then
		return self.resources[resource]
	else
		return 0
	end
end

function ENT:OnRestore()
	//self.BaseClass.OnRestore(self) --use this if you have to use OnRestore
	if not (WireAddon == nil) then Wire_Restored(self) end
end

function ENT:PreEntityCopy()
	//self.BaseClass.PreEntityCopy(self) --use this if you have to use PreEntityCopy
	Environments.BuildDupeInfo(self)
	if not (WireAddon == nil) then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	//self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities ) --use this if you have to use PostEntityPaste
	Environments.ApplyDupeInfo(Ent, CreatedEntities)
	if not (WireAddon == nil) and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
