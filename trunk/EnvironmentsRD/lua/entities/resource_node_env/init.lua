
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
			umsg.Start("Env_UpdateMaxRes")
				umsg.Entity(self)
				umsg.String(name)
				umsg.Long(self.maxresources[name])
			umsg.End()
			--self:SetNWInt("max"..name, self.maxresources[name])
		end
	end
	if ent.resources then
		for name,amt in pairs(ent.resources) do
			local curmax = self.maxresources[name]
			if self.resources[name] then
				local cur = self.resources[name].value
				if cur and (cur + amt) <= curmax then
					self.resources[name].value = cur + amt
				elseif cur then
					self.resources[name].value = curmax
				end
			else
				self.resources[name] = {}
				self.resources[name].value = amt
			end
			self.resources[name].haschanged = true
			self.updated = true
		end
	end
end

function ENT:Unlink(ent)
	if ent then
		print("Check Passed!")
		self.connected[ent:EntIndex()] = nil
		if ent.maxresources then
			for name,max in pairs(ent.maxresources) do
				local curmax = self.maxresources[name]
				if curmax then
					self.maxresources[name] = curmax - max
				end
				umsg.Start("Env_UpdateMaxRes")
					umsg.Entity(self)
					umsg.String(name)
					umsg.Long(self.maxresources[name])
				umsg.End()
				--self:SetNWInt("max"..name, self.maxresources[name])
			end
		end
	end
end

function ENT:Repair()
	self:SetHealth( self:GetMaxHealth( ))
end

function ENT:LinkCheck()
	local curpos = self:GetPos()
	for k,v in pairs(self.connected) do
		if !v or !v:IsValid() then
			self.connected[k] = nil
			continue
		end
		if v:GetPos():Distance(curpos) > 2048 then
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
		for name,v in pairs(self.resources) do
			if v.haschanged then
				umsg.Start("Env_UpdateResAmt") --temporary prototype system
					umsg.Entity(self)
					umsg.String(name)
					umsg.Long(v.value)
				umsg.End()
				v.haschanged = false
			end
			
			--self:SetNWInt(name, value) --get rid of soon
		end
		self.updated = false
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:GenerateResource(name, amt)
	amt = math.Round(amt) -- :(
	
	local max = self.maxresources[name]
	if not max then return 0 end
	if self.resources[name] then
		local res = self.resources[name].value
		if res + amt < max then
			self.resources[name].value = self.resources[name].value + amt
			self.resources[name].haschanged = true
			self.updated = true
			return amt
		else
			self.resources[name].value = max
			self.resources[name].haschanged = true
			self.updated = true
			return max - res
		end
	else
		self.resources[name] = {}
		self.resources[name].value = amt
		self.resources[name].haschanged = true
		self.updated = true
		return amt
	end
	return amt
end

function ENT:ConsumeResource(name, amt)
	amt = math.Round(amt) -- :(
	if self.resources[name] then
		local res = self.resources[name].value
		if res >= amt then
			self.resources[name].value = res - amt
			self.updated = true
			self.resources[name].haschanged = true
			return amt
		elseif not res == 0 then
			--amt = res
			res = 0
			self.resources[name].haschanged = true
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
		return self.resources[resource].value
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