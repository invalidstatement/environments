
local scripted_ents = scripted_ents
local table = table
local util = util
local player = player
local umsg = umsg
local list = list
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

if SERVER then
	local function CheckRD() --make not call for update all the time
		for k,ply in pairs(player.GetAll()) do
			local ent = ply:GetEyeTrace().Entity
			if ent and ent:IsValid() then
				if ent.node and ent.node:IsValid() then --its a RD entity, send the message!
					--list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
					local dat = list.Get("LSEntOverlayText")[ent:GetClass()] --get the resources
					if dat then
						ent.node:DoUpdate(dat.resnames, dat.genresnames, ply)
					else --no list data? SG? CAP?
					
					end
				elseif ent.maxresources and !ent.IsNode then
					if !ent.client_updated then
						for res,amt in pairs(ent.maxresources) do
							umsg.Start("EnvStorageUpdate")
								umsg.Entity(ent)
								umsg.String(res)
								if ent.resources then
									umsg.Long(ent.resources[res] or 0)
								else
									umsg.Long(0)
								end
								umsg.Long(amt)
							umsg.End()
						end
						ent.client_updated = true
					end
				end
			end
		end
	end
	timer.Create("RDChecker", 0.5, 0, CheckRD) --adjust rate perhaps?
end

function Environments.BuildDupeInfo( ent ) --need to add duping for cables
	local info = {}
	if ent.IsNode then
		--local nettable = ent.connected
		--local info = {}
		--info.resources = table.Copy(ent.maxresources)

		--duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
		return
	elseif ent:GetClass() == "env_pump" then
		local info = {}
		info.pump = ent.pump_active
		info.rate = ent.pump_rate
		info.hoselength = ent.hose_length
	end
	
	if ent.node then
		info.Node = ent.node:EntIndex()
	end
	
	local forw = ent:GetNWVector("CableForward", nil)
	local pos = ent:GetNWVector("CablePos", nil)
	local mat = ent:GetNWString("CableMat", nil)
	
	info.LinkMat = mat
	info.LinkPos = pos 
	info.LinkForw = forw
	
	duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities ) --add duping for cables
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		local DupeInfo = ent.EntityMods.EnvDupeInfo
		if ent.IsNode then
			return
		elseif ent:GetClass() == "env_pump" then
			ent:Setup( DupeInfo.pump, DupeInfo.rate, DupeInfo.hoselength )
		end
		Environments.MakeFunc(ent) --yay
		
		if DupeInfo.Node then
			local node = CreatedEntities[DupeInfo.Node]
			ent:Link(node, true)
			node:Link(ent, true)
		end
		
		local mat = DupeInfo.LinkMat
		local pos = DupeInfo.LinkPos
		local forward = DupeInfo.LinkForw
		if mat and pos and forward then
			Environments.Create_Beam(ent, pos, forward, mat) --make work
		end
		ent.EntityMods.EnvDupeInfo = nil
	end
end

function Environments.Create_Beam(ent, localpos, forward, mat)
	ent:SetNWVector("CableForward", forward)
	ent:SetNWVector("CablePos", localpos)
	ent:SetNWString("CableMat",  mat)
end

if SERVER then
	function Environments.RDPlayerUpdate(ply)--CRAPPY!!! FIX!
		for k,ent in pairs(ents.FindByClass("resource_node_env")) do
			for name,tab in pairs(ent.resources) do
				umsg.Start("Env_UpdateResAmt")
					umsg.Entity(ent)
					name = Environments.Resources[name] or name
					umsg.String(name)
					umsg.Long(tab.value)
				umsg.End()
			end
			for name,amount in pairs(ent.maxresources) do
				umsg.Start("Env_UpdateMaxRes")
					umsg.Short(ent:EntIndex())
					umsg.String(name)
					umsg.Long(amount)
				umsg.End()
			end
		end
		for k,v in pairs(ents.GetAll()) do
			if v and v.node and v.node:IsValid() then
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Short(v:EntIndex())
					umsg.Short(v.node:EntIndex())
				umsg.End()
			end
		end
	end
	hook.Add("PlayerInitialSpawn", "EnvRDPlayerUpdate", Environments.RDPlayerUpdate)
	
	function Environments.DamageLS(ent, dam) 
		if !ent or !ent:IsValid() or !dam then return end
		if ent:GetMaxHealth() == 0 then return end
		dam = math.floor(dam / 2)
		if (ent:Health() > 0) then
			local HP = ent:Health() - dam
			ent:SetHealth( HP )
			if ent:Health() <= (ent:GetMaxHealth() / 2) then
				if ent.Damage then
					ent:Damage()
				end
			end
			
			if ent:Health() <= 0 then
				ent:SetColor(50, 50, 50, 255)
				if ent.Destruct then
					ent:Destruct()
				else
					Environments.LSDestruct( ent, true )
				end
				return
			end
			
			local health = ent:Health()
			local max = ent:GetMaxHealth()
			if health <= max/7 then
				ent:SetColor(75,75,75,255)
			elseif health <= max/6 then
				ent:SetColor(100,100,100,255)
			elseif health <= max/5 then
				ent:SetColor(125,125,125,255)
			elseif health <= max/4 then
				ent:SetColor(150,150,150,255)
			elseif health <= max/3 then
				ent:SetColor(175,175,175,255)
			elseif health <= max/2 then
				ent:SetColor(200,200,200,255)
			end
		end
	end
	
	function Environments.ZapMe(pos, magnitude)
		if not (pos and magnitude) then return end
		zap = ents.Create("point_tesla")
		zap:SetKeyValue("targetname", "teslab")
		zap:SetKeyValue("m_SoundName" ,"DoSpark")
		zap:SetKeyValue("texture" ,"sprites/physbeam.spr")
		zap:SetKeyValue("m_Color" ,"200 200 255")
		zap:SetKeyValue("m_flRadius" ,tostring(magnitude*80))
		zap:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)+4))
		zap:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)+12))
		zap:SetKeyValue("thick_min", tostring(magnitude))
		zap:SetKeyValue("thick_max", tostring(magnitude*8))
		zap:SetKeyValue("lifetime_min" ,"0.1")
		zap:SetKeyValue("lifetime_max", "0.2")
		zap:SetKeyValue("interval_min", "0.05")
		zap:SetKeyValue("interval_max" ,"0.08")
		zap:SetPos(pos)
		zap:Spawn()
		zap:Fire("DoSpark","",0)
		zap:Fire("kill","", 1)
	end
	
	function Environments.LSDestruct( ent, Simple )
		if Simple then
			Explode2( ent )
		else
			timer.Simple(1, Explode1, ent)
			timer.Simple(1.2, Explode1, ent)
			timer.Simple(2, Explode1, ent)
			timer.Simple(2, Explode2, ent)
		end
	end
	
	function Explode1( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
				Effect:SetScale(1)
				Effect:SetMagnitude(25)
			util.Effect("Explosion", Effect, true, true)
		end
	end

	function Explode2( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos())
				Effect:SetScale(3)
				Effect:SetMagnitude(100)
			util.Effect("Explosion", Effect, true, true)
			ent:Remove()
		end
	end
end
