//Creates Tools
AddCSLuaFile("autorun/autorun.lua")
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

if not Environments then
	Environments = {}
end

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
				ENT.HasResourceDistribution = StarGate.HasResourceDistribution;
				ENT.HasRD = StarGate.HasResourceDistribution; -- Quick reference
				
				-- General handlers
				ENT.OnRemove = function(self)
					if self.node then
						self.node:Unlink() --fails
						local node = self.node --backup unlink :D
						node.connected[self:EntIndex()] = nil
						if not self.maxresources then return end
						for name,max in pairs(self.maxresources) do
							local curmax = node.maxresources[name]
							if curmax then
								node.maxresources[name] = curmax - max
							end
							node:SetNWInt("max"..name, node.maxresources[name])
						end
					end
					if(WireAddon and (self.Outputs or self.Inputs)) then
						Wire_Remove(self.Entity);
					end
				end
				ENT.OnRestore = function(self)
					if(WireAddon) then
						Wire_Restored(self.Entity)
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
						self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,data,types);
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
						self.Inputs = WireLib.CreateSpecialInputs(self.Entity,data,types);
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
							WireLib.TriggerOutput(self.Entity,key,value);
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
						--print("self.resources")
							return self.resources[resource] or 0
						end
						--print("returning 0")
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
						self:SetNWEntity("node", ent)
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
					--if(RD_BuildDupeInfo) then RD_BuildDupeInfo(self.Entity) end;
					if(WireAddon) then
						local data = WireLib.BuildDupeInfo(self.Entity);
						if(data) then
							duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",data);
						end
					end
				end
				ENT.PostEntityPaste = function(self,Player,Ent,CreatedEntities)
					--if(RD_ApplyDupeInfo) then RD_ApplyDupeInfo(Ent,CreatedEntities) end;
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

timer.Simple(0,function() --Stargate fix?
	StarGate.LifeSupportAndWire = function(ent) 
		print("hello") 
	end 
end)

function Environments.BuildDupeInfo( ent )
	if ent.IsNode then
		local nettable = ent.connected
		local info = {}
		info.resources = table.Copy(ent.maxresources)
		local entids = {}
		if table.Count(ent.connected) > 0 then
			for k, v in pairs(ent.connected) do
				table.insert(entids, v:EntIndex())
			end
		end
		info.entities = entids
		info.cons = cons
		if info.entities then
			duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
		end
	elseif ent:GetClass() == "env_pump" then
		local info = {}
		info.pump = ent.pump_active
		info.rate = ent.pump_rate
		info.hoselength = ent.hose_length
		duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
	end
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		local DupeInfo = ent.EntityMods.EnvDupeInfo
		if ent.IsNode then
			if DupeInfo.resources then
				ent.maxresources = DupeInfo.resources
				ent:Initialize()
			end
			if DupeInfo.entities and table.Count(DupeInfo.entities) > 0 then
				for _,ID in pairs(DupeInfo.entities) do
					local ent2 = CreatedEntities[ID]
					if ent2 and ent2:IsValid() then
						ent:Link(ent2)
						ent2:Link(ent)
					end
				end
			end
			ent.EntityMods.EnvDupeInfo = nil //trash this info, we'll never need it again
		elseif ent:GetClass() == "env_pump" then
			ent:Setup( DupeInfo.pump, DupeInfo.rate, DupeInfo.hoselength )
			ent.EntityMods.EnvDupeInfo = nil
		end
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
	function Environments.DrawCable(ent, p1, p1f, p2, p2f)--FIX THIS!!! the cable is FLAT!
		ent.mesh = NewMesh()
		local tab = {}
		for mu = 0, 1 - resolution, resolution do
			startpos =  Vector( ( p2.x - p1.x ) * mu + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu ) )
			endpos = Vector( ( p2.x - p1.x ) * ( mu + resolution ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu + resolution ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu + resolution ) )
			
			if ( mu + resolution >= 1 ) then
				endpos2 = p2 - p1f * 100
			else
				endpos2 = Vector( ( p2.x - p1.x ) * ( mu + resolution*2 ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu + resolution*2 ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu + resolution*2 ) )
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
	
	local angle, ang
	function GenerateCylinder( p1, d1, p2, d2, radius, segments )
		segments = segments or 10
		angle = 360 / segments
		local tab = {}	
		for i = 0, segments - 1 do
			ang = i * angle
			--local inside = MeshQuad(getStartPosition( p1, d1, ang, radius ),getStartPosition( p1, d1, ang + angle, radius ),getEndPosition( p2, d2, ang + angle, radius ),getEndPosition( p2, d2, ang, radius ), 1)
			-- Outside
			local outside = MeshQuad(getEndPosition( p2, d2, ang, radius ),getEndPosition( p2, d2, ang + angle, radius ),getStartPosition( p1, d1, ang + angle, radius ),getStartPosition( p1, d1, ang, radius ), 1)

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
		mu2 = mu * mu
		mu3 = mu2 * mu
		m0 = ( y2 - y1 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y3 - y2 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		m1 = ( y3 - y2 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y4 - y3 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		a0 = 2 * mu3 - 3 * mu2 + 1
		a1 = mu3 - 2 * mu2 + mu
		a2 = mu3 - mu2
		a3 = -2 * mu3 + 3 * mu2
		
		return a0 * y2 + a1 * m0 + a2 * m1 + a3 * y3
	end
end

print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")