//Creates Tools
AddCSLuaFile("autorun/autorun.lua")
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

local scripted_ents = scripted_ents
local table = table
local util = util
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

if not Environments then
	Environments = {}
end

local Environments = Environments

//Stargate Overrides --Plz Work
local loaded = false
local o = scripted_ents.Register
scripted_ents.Register = function(...)
	if not loaded then
		loaded = true
		if StarGate then
			StarGate.LifeSupportAndWire = function(ENT) 
				ENT.WireDebugName = ENT.WireDebugName or "No Name";
				ENT.HasWire = StarGate.HasWire;
				ENT.HasResourceDistribution = true --StarGate.HasResourceDistribution;
				ENT.HasRD = true --StarGate.HasResourceDistribution; -- Quick reference
				
				-- General handlers
				ENT.OnRemove = function(self)
					if self.node then
						self.node:Unlink(self)
					end
					if(WireAddon and (self.Outputs or self.Inputs)) then
						Wire_Remove(self);
					end
				end
				ENT.OnRestore = function(self)
					if WireAddon then
						Wire_Restored(self)
					end
				end

				-- Wire Handlers
				ENT.CreateWireOutputs = function(self,...)
					if(WireAddon) then
						local data = {};
						local types = {};
						for k,v in pairs({...}) do
							if(type(v) == "table") then
								types[k] = v.Type;
								data[k] = v.Name;
							else
								data[k] = v;
							end
						end
						--self.Outputs = Wire_CreateOutputs(self.Entity,{...}); -- Old way, kept if I need to revert
						self.Outputs = WireLib.CreateSpecialOutputs(self,data,types);
					end
				end
				ENT.CreateWireInputs = function(self,...)
					if(WireAddon) then
						local data = {};
						local types = {};
						for k,v in pairs({...}) do
							if(type(v) == "table") then
								types[k] = v.Type;
								data[k] = v.Name;
							else
								data[k] = v;
							end
						end
						--self.Inputs = Wire_CreateInputs(self.Entity,{...}); -- Old way, kept if I need to revert
						self.Inputs = WireLib.CreateSpecialInputs(self,data,types);
					end
				end
				ENT.SetWire = function(self,key,value)
					if(WireAddon) then
						-- Special interaction to modify datatypes
						if(self.Outputs and self.Outputs[key]) then
							local datatype = self.Outputs[key].Type;
							if(datatype == "NORMAL") then
								-- Supports bools and converts them to numbers
								if(value == true) then
									value = 1;
								elseif(value == false) then
									value = 0;
								end
								-- If still not a number, make it a num now!
								value = tonumber(value);
							elseif(datatype == "STRING") then
								value = tostring(value);
							end
						end
						if(value ~= nil) then
							WireLib.TriggerOutput(self,key,value);
							if(self.WireOutput) then
								self:WireOutput(key,value);
							end
						end
					end
				end
				ENT.GetWire = function(self,key,default)
					if(WireAddon) then
						if(self.Inputs and self.Inputs[key] and self.Inputs[key].Value) then
							return self.Inputs[key].Value or default or WireLib.DT[self.Inputs[key].Type].Zero;
						end
					end
					return default or 0; -- Error. Either wire is not installed or the input is not SET. Return the default value instead
				end
				
				-- RD Handling
				ENT.AddResource = function(self, resource, maximum, default)
					if not self.maxresources then self.maxresources = {} end
					if not self.resources then self.resources = {} end
					self.maxresources[resource] = maximum
					self.resources[resource] = default
				end
				ENT.GetResource = function(self, resource)
					if self.node then
						if self.node.resources[resource] then
							return self.node.resources[resource].value
						else
							return 0
						end
					else
						if self.resources then
							return self.resources[resource] or 0
						end
						return 0
					end
				end
				ENT.ConsumeResource = function(self, resource, amount)
					if self.node then
						return self.node:ConsumeResource(resource, amount)
					end
				end
				ENT.Link = function(self,ent)
					if self.node then
						self.node:Unlink(self)
					end
					if ent and ent:IsValid() then
						self.node = ent
						
						if delay then
							timer.Simple(0.1, function(self, ent)
								umsg.Start("Env_SetNodeOnEnt")
									umsg.Entity(self)
									umsg.Entity(ent)
								umsg.End()
							end, self, ent)
						else
							umsg.Start("Env_SetNodeOnEnt")
								umsg.Entity(self)
								umsg.Entity(ent)
							umsg.End()
						end
						--self:SetNWEntity("node", ent)
					end
				end
				ENT.Unlink = function(self)
					if self.node then
						self.node:Unlink(self)
						self.node = nil
						umsg.Start("Env_SetNodeOnEnt")
							umsg.Entity(self)
							umsg.Entity(NullEntity())
						umsg.End()
					end
				end
				ENT.SupplyResource = function(self,resource, amount)
					if self.node then
						return self.node:GenerateResource(resource, amount)
					else
						if self.resources then
							self.resources[resource] = amount
						end
					end
				end
				ENT.GetUnitCapacity = function(self,resource)
					return self.maxresources[resource]
				end
				ENT.GetNetworkCapacity = function(self,resource)
					if self.node then
						return self.node.maxresources[resource]
					else
						if self.maxresources then
							return self.maxresources[resource]
						end
					end
					return 0
				end
				
				-- For LifeSupport and Resource Distribution and Wire - Makes all connections savable with Duplicator
				ENT.PreEntityCopy = function(self)
					Environments.BuildDupeInfo( self )
					if(WireAddon) then
						local data = WireLib.BuildDupeInfo(self)
						if(data) then
							duplicator.StoreEntityModifier(self,"WireDupeInfo",data);
						end
					end
				end
				ENT.PostEntityPaste = function(self,Player,Ent,CreatedEntities)
					Environments.ApplyDupeInfo( self, CreatedEntities )
					if(WireAddon) then
						if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
							WireLib.ApplyDupeInfo(Player,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end);
						end
					end
				end
			end 
		end
	end
	o(...)
end

if SERVER then
	local function CheckRD() --make not call for update all the time
		for k,ply in pairs(player.GetAll()) do
			local ent = ply:GetEyeTrace().Entity
			if ent and ent:IsValid() then
				if ent.node and ent.node:IsValid() then --its a RD entity, send the message!
					--list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
					local dat = list.Get("LSEntOverlayText")[ent:GetClass()] --get the resources
					--this is tricky, how do I avoid updating everything?
					if dat then
						ent.node:DoUpdate(dat.resnames, dat.genresnames, ply)
					else --no data? SG? CAP?
					
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
	duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities ) --add duping for cables
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		local DupeInfo = ent.EntityMods.EnvDupeInfo
		if ent.IsNode then
			/*if DupeInfo.resources then
				ent.maxresources = DupeInfo.resources
				ent:Initialize()
			end
			ent.EntityMods.EnvDupeInfo = nil */
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
		--Environments.Create_Beam(ent, pos, forward, mat) --make work
		ent.EntityMods.EnvDupeInfo = nil
	end
end

local models = {}
function Environments.GetScreenInfo(model)
	local info = {}
	for k,v in pairs(models) do
		if k == model then
			return v
		end
	end
end

function Environments.RegisterModelScreenData(model, offset, angle, height, width)
	models[model] = {}
	models[model].Offset = offset
	models[model].Angle = angle
	models[model].X = width
	models[model].Y = height
end

function Environments.Create_Beam(ent, localpos, forward, mat)
	ent:SetNWVector("CableForward", forward)
	ent:SetNWVector("CablePos", localpos)
	ent:SetNWString("CableMat",  mat)
end

Environments.RegisterModelScreenData("models/punisher239/punisher239_reactor_small.mdl", Vector(-110,0,50), Angle(0,30,270), 0, 0)

if CLIENT then
	local resolution = 0.1
	local startpos, endpos, endpos2, cyl
	function Environments.DrawCable(ent, p1, p1f, p2, p2f)
		ent.mesh = NewMesh()
		local tab = {}
		for mu = 0, 1 - resolution, resolution do
			startpos =  Vector( ( p2.x - p1.x ) * mu + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu ) )
			endpos = Vector( ( p2.x - p1.x ) * ( mu + resolution ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu + resolution ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu + resolution ) )
			
			if ( mu + resolution >= 1 ) then
				endpos2 = p2 - p1f * 100
			else
				endpos2 = Vector( ( p2.x - p1.x ) * ( mu + resolution*2 ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu + resolution*2 ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu + resolution*2 ) )
			end
			
			cyl = GenerateCylinder( startpos, endpos - startpos, endpos, endpos2 - endpos, 1.3 )
			for k,v in pairs(cyl) do
				table.insert(tab, v)
			end
		end
		ent.mesh:BuildFromTriangles(tab)
	end
	
	local ang
	function getStartPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end

	local ang
	function getEndPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end
	
	local function MeshQuad( v1, v2, v3, v4, t ) --s = 0
		return
		{        
			Vertex( v1, 0, 0 ),
			Vertex( v2, (v1-v2):Length() * t, 0 ),
			Vertex( v4, 0, (v1-v4):Length() * t ),
			Vertex( v2, (v1-v2):Length() * t, 0 ),
			Vertex( v3, (v3-v4):Length() * t, (v2-v3):Length() * t),
			Vertex( v4, 0, (v1-v4):Length() * t ),
		}    
	end
	
	local angle, ang
	function GenerateCylinder( p1, d1, p2, d2, radius, segments )
		segments = segments or 10
		angle = 360 / segments
		d1:Normalize()
		d2:Normalize()
		local tab = {}	
		for i = 0, segments - 1 do
			ang = i * angle
			--local inside = MeshQuad(getStartPosition( p1, d1, ang, radius ),getStartPosition( p1, d1, ang + angle, radius ),getEndPosition( p2, d2, ang + angle, radius ),getEndPosition( p2, d2, ang, radius ), 1)
			-- Outside
			local outside = MeshQuad(getEndPosition( p2, d2, ang, radius ),getEndPosition( p2, d2, ang + angle, radius ),getStartPosition( p1, d1, ang + angle, radius ),getStartPosition( p1, d1, ang, radius ), 0.1)--i*0.1, (i + 1)*0.1)

			--for k,v in pairs(inside) do
			--	table.insert(tab, v)
		--	end
			for k,v in pairs(outside) do
				table.insert(tab, v)
			end
		end
		return tab
	end
	
	local m0, m1, mu2, mu3
	local a0, a1, a2, a3
	function hermiteInterpolate( y1, y2, y3, y4, tension, bias, mu )	
		mu2 = mu * mu --mu^2
		mu3 = mu2 * mu --mu^3
		m0 = ( y2 - y1 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y3 - y2 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		m1 = ( y3 - y2 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y4 - y3 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		a0 = 2 * mu3 - 3 * mu2 + 1
		a1 = mu3 - 2 * mu2 + mu
		a2 = mu3 - mu2
		a3 = -2 * mu3 + 3 * mu2
		
		return a0 * y2 + a1 * m0 + a2 * m1 + a3 * y3
	end
else
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
					umsg.Entity(ent)
					umsg.String(name)
					umsg.Long(amount)
				umsg.End()
			end
		end
		for k,v in pairs(ents.GetAll()) do
			if v and v.node and v.node:IsValid() then
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Entity(v)
					umsg.Entity(v.node)
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

Environments.Resources = {} --string to short
Environments.Resources2 = {} --short to string
function Environments.RegisterResource(name)
	Environments.Resources[name] = table.Count(Environments.Resources) + 1
	Environments.Resources2[table.Count(Environments.Resources)] = name
end	

//Adding Main Resources For Optimization
Environments.RegisterResource("oxygen")
Environments.RegisterResource("water")
Environments.RegisterResource("energy")
Environments.RegisterResource("nitrogen")
Environments.RegisterResource("hydrogen")
Environments.RegisterResource("steam")
Environments.RegisterResource("carbon dioxide")

print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")