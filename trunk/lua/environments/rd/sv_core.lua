------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------
local RD = {}

local devices = {}

function RD.ClientUpdate(ent)
	
end

function RD.AddResource(ent, resource, max, default)
	if not devices[ent:EntIndex()] then
		devices[ent:EntIndex()] = {}
end

function RD.SupplyResource(ent, resource, amt)

end