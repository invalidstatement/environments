------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------
--[[
nettable[netid] = {}
	nettable[netid].resources = {}
	nettable[netid].resources[resource] = {}
	nettable[netid].resources[resource] .value = value
	nettable[netid].resources[resource] .maxvalue = value
	nettable[netid].resources[resource].haschanged = true/false
	nettable[netid].entities = {}
	nettable[netid].haschanged = true/false
	nettable[netid].clear = true/false
	nettable[netid].new = true/false

]]
local RD = {}

local devices = {}

function RD.ClientUpdate(ent)
	
end

local function SendResourceData(net, res, max, value)
	umsg.Start("RDupdate")
		umsg.String(res)
		umsg.Long(value)
		umsg.Long(max)
	end
end

local function UpdateNetworksAndEntities()
	if ent_table then
		for k,v in pairs(ent_table) do
			
		end
	end
	//nets
	if nettable then
		for k,v in pairs(nettable) do
			if v.clear then
			
			elseif v.new then
			
			elseif v.haschanged then
				for k,r in pairs(v.resources) do
					if r.haschanged then
						SendResourceData(net, res, max, value)
						r.haschanged = false
					end
				end
			end
		end
	end
end


function RD.AddResource(ent, resource, max, default)
	if not devices[ent:EntIndex()] then
		devices[ent:EntIndex()] = {}
	end
end

function RD.SupplyResource(ent, resource, amt)

end