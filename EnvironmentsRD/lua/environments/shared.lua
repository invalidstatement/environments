
local scripted_ents = scripted_ents
local table = table
local util = util
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

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
				ENT.HasResourceDistribution = true
				ENT.HasRD = true
				
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
									umsg.Short(self:EntIndex())
									umsg.Short(ent:EntIndex())
								umsg.End()
							end, self, ent)
						else
							umsg.Start("Env_SetNodeOnEnt")
								umsg.Short(self:EntIndex())
								umsg.Short(ent:EntIndex())
							umsg.End()
						end
					end
				end
				ENT.Unlink = function(self)
					if self.node then
						self.node:Unlink(self)
						self.node = nil
						umsg.Start("Env_SetNodeOnEnt")
							umsg.Short(self:EntIndex())
							umsg.Short(0)
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