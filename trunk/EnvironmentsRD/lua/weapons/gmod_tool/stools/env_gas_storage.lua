include("weapons/gmod_tool/environments_tool_base.lua")
AddCSLuaFile("weapons/gmod_tool/stools/gas_storage.lua")

TOOL.Category = "Storages"
TOOL.Name = "Gas Storage Cache"
TOOL.Description = "Used to spawn gas storages"

TOOL.Models = { ["models/Slyfo/t-eng.mdl"] = {} }
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "env_storage_gas";
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

	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	
	ent.maxresources = {}
	ent:AddResource("oxygen", math.Round(volume_mul*4000))
	ent:AddResource("hydrogen", math.Round(volume_mul*4000))
	ent:AddResource("nitrogen", math.Round(volume_mul*4000))
	ent:AddResource("carbon dioxide", math.Round(volume_mul*4000))
		
	ent:SetMultiplier(volume_mul)
	
	return volume_mul
end
	
function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:ClearControls()

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