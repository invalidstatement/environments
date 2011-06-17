include("weapons/gmod_tool/environments_tool_base.lua")
AddCSLuaFile("weapons/gmod_tool/stools/energy_cells.lua")

TOOL.Category = "Storages"
TOOL.Name = "Water Tanks"
TOOL.Description = "Used to spawn water tanks."

TOOL.Models = { 	["models/props/de_port/tankoil01.mdl"] = {},
					["models/props/de_nuke/storagetank.mdl"] = {},
					["models/props_wasteland/coolingtank02.mdl"] = {},
					["models/props_c17/oildrum001.mdl"] = {},
					["models/ce_ls3additional/resource_tanks/resource_tank_large.mdl"] = {},
					["models/ce_ls3additional/resource_tanks/resource_tank_medium.mdl"] = {} }

local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "env_storage_water";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 20
local name = TOOL.Mode

TOOL.CleanupGroup = "storage" --sets what this things count adds from
TOOL.Language["Undone"] = "Undone Storage Device";
TOOL.Language["Cleanup"] = "Storages";
TOOL.Language["Cleaned"] = "Removed all storage devices";
TOOL.Language["SBoxLimit"] = "Hit the storage limit";

function TOOL:GetMults(ent)
	local volume_mul = 1 //Change to be 0 by default later on
	local base_volume = 4084 //Change to the actual base volume later on
	local phys = ent:GetPhysicsObject()
	local volume = -1
		
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		volume = math.Round(vol)
	end
		
	if volume >= 100000000 then
		volume = volume/10
	end
		
	ent.maxresources = {}
	ent:AddResource("water", math.Round(volume/10))
		
	ent:SetMultiplier(volume_mul)
end
	
function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:ClearControls()
	CPanel:AddHeader()
	CPanel:AddDefaultControls()
	CPanel:AddControl("Header", { Text = "#Tool_"..name.."_name", Description = "#Tool_"..name.."_desc" })
	
	CPanel:AddControl( "PropSelect", {
		Label = "#Models",
		ConVar = name.."_model",
		Category = "Storages",
		Models = Models
	})
	CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
	CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
	CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
end
	
TOOL:Register()