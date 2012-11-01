--[[
	Resources API
		Last Update: April 2012

		file: resources_api.lua
		
	Use this in your Life Support devices. Using these function names will
	insure they are compatibile with other systems that use this API.

	This will be called as a shared file as it contains both SERVER and
	CLIENT functions.

	Client Side Functions:
		ent:ResourcesDraw()

	Server Side Functions:
		ent:ResourcesConsume( resourcename, amount )
		ent:ResourcesSupply( resourcename, amount )
		ent:ResourcesGetCapacity( resourcename )
		ent:ResourcesSetDeviceCapacity( resourcename, amount )
		ent:ResourcesGetAmount( resourcename )
		ent:ResourcesGetDeviceAmount( resourcename )
		ent:ResourcesGetDeviceCapacity( resourcename )
		ent:ResourcesLink( entity )
		ent:ResourcesUnLink( entity )
		ent:ResourcesCanLink( entity )
]]
print("RESOURCES API INSTALLED")

RESOURCES = {}
RESOURCES.Version = 1 --only changes when something major gets changed

--register the device clientside
function RESOURCES:Setup( ent )
	--[[
		your shared code here
	]]
	
	--client functions
	if CLIENT then
		--[[
			your client side code here
		]]
		
		//load network data/setup variables
		local tab = Environments.GetEntTable(ent:EntIndex())
		ent.maxresources = tab.maxresources
		ent.resources = tab.resources
		ent.node = Entity(tab.network) or NULL
		
		--Used do draw any connections, "beams", info huds, etc for the devices.
		--this would be placed within the ENT:Draw() function
		function ent:ResourcesDraw( ent )
			-- your code here
		end

	--server functions
	elseif SERVER then
		--[[
			your server side code here
		]]
		
		//setup variables
		ent.node = nil
		ent.resources = {}
		ent.maxresources = {}
		
		--Can be negitive or positive (for consume and generate)
		-- supply: resource name or resource table
		-- returns: amount not consumed
		function ent:ResourcesConsume( res, amount )
			if type(res) == "table" then
				local consume = {}
				for n, v in pairs( res ) do
					consume[n] = self:ResourcesConsume( n,v )
				end
				return consume
			end

			if self.node then
				return self.node:ConsumeResource(res, amount)
			end
			
			return 0 --0 = success. Anything larger and it couldnt consume the amount
		end

		--Supplies the resource to the connected network
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSupply( res, amount )
			if type(res) == "table" then
				local supply = {}
				for n, v in pairs( res ) do
					supply[n] = self:ResourcesGenerate( n,v )
				end
				return supply
			end

			if self.node then
				return self.node:GenerateResource(res, amount)
			end
			
			return 0 --0 = success. Anything larger and it couldnt supply the amount (insufficient storage)
		end

		--Gets the devices networks total storage for the resource
		-- supply: resource name
		-- returns: number
		-- note: If passed in nothing (nil), return the capity for each resource
		function ent:ResourcesGetCapacity( res )
			if (res) then
				if self.node then
					return self.node.maxresources[res] or 0
				end
				
				return 0
			else
				return self.node.maxresources --table of resources
			end
		end

		--Sets the device max storage capacity
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSetDeviceCapacity( res, amount )
			if type(res) == "table" then
				for n, v in pairs( res ) do self:ResourcesSetDeviceCapacity( n,v ) end
			return end

			//needs work/testing
			if not self.maxresources then self.maxresources = {} end
			self.maxresources[name] = amt
		end

		--  Gets the devices stored amount of resource from the connected network
		--  supply: resource name
		--  returns: number
		function ent:ResourcesGetAmount( res )
			if (res) then
				if self.node then
					if self.node.resources[resource] then
						return self.node.resources[res].value
					else
						return 0
					end
				end
				return self.resources[res] or 0
			else
				if self.node then
					local t = {}
					for k,v in pairs(self.node.resources) do
						t[k] = v.value
					end
					return t
				end
				return self.resources --table of resources
			end
		end

		--how much this devive is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceAmount( res )
			if (res) then
				return self.resources[res] or 0
			else
				return self.resources --table of resources
			end
		end

		--how much this devives network is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceCapacity( res )
			if (res) then
				return self.maxresources[res] or 0
			else
				return self.maxresources --table of max resources
			end
		end

		--link to another device/network
		-- supply: entity
		-- returns:
		function ent:ResourcesLink( entity )
			if self.node then
				self:Unlink()
			end
			if entity and entity:IsValid() then
				self.node = entity
				
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Short(self:EntIndex())
					umsg.Short(entity:EntIndex())
				umsg.End()
			end
		end

		--removes all link from a network
		-- supply: entity or table of entities (all optional)
		-- returns:
		-- note: if an entity is passed in then unlink with that entity, otherwise unlink all
		function ent:ResourcesUnLink( entity )
			if type(entity) == "table" then
				for _, v in pairs( res ) do self:ResourcesUnLink( v ) end
			return end

			if (!entity) then --unlink all
				if self.node then
					self.resources = {}
					if self.maxresources then
						for k,v in pairs(self.maxresources) do
							--print("Resource: "..k, "Amount: "..v)
							local amt = self:GetResourceAmount(k)
							if amt > v then
								amt = v
							end
							if self.node.resources[k] then
								self.node.resources[k].value = self.node.resources[k].value - amt
							end
							--print("Recovered: "..amt)
							self.resources[k] = amt
							--self:UpdateStorage(k)
						end
					end
					self.node.updated = true
					self.node:Unlink(self)
					self.node = nil
					self.client_updated = false

					umsg.Start("Env_SetNodeOnEnt")
						umsg.Short(self:EntIndex())
						umsg.Short(0)
					umsg.End()
				end
			else
				--your code here, unlink with entity
			end
		end

		--determains if two devices can be linked
		-- supply: entity or table of entities
		-- returns: boolean (if entity passed in), or table (if table of entities passed in)
		function ent:ResourcesCanLink( entity )
			if type(ent) == "table" then
				local links = {}
				for _, v in pairs( ent ) do
					links[ent] = self:ResourcesCanLink( v )
				end
				return links
			end

			--your code here
			return false
		end
		
		--Returns a list of connected entities
		function ent:ResourcesGetConnected()
			return {} --returns a table of all connected entities
		end

		--This function is called to save any resource info so it can be saved using the duplicator
		--this goes into ENT:PreEntityCopy
		function ent:ResourcesBuildDupeInfo()
			--your code here
		end

		--This function is called to store any resource info after a dup
		--this goes into ENT:PostEntityPaste
		function ent:ResourcesApplyDupeInfo( ply, ent, CreatedEntities )
			--your code here
		end
	end
end

local meta = FindMetaTable( "Entity" )

--sets up the functions to be used on the "Life Support" devices
-- supply: entity
function meta:InitResources( )
	RESOURCES:Setup( self )
end