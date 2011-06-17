include("weapons/gmod_tool/environments_tool_base.lua")

TOOL.Category = "Life Support"
TOOL.Name = "Suit Dispenser"
TOOL.Description = "Used to spawn microwave recievers"

TOOL.Models = { 	["models/props_combine/combine_emitter01.mdl"] = {} }
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "suit_dispenser";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 10
local name = TOOL.Mode

TOOL.CleanupGroup = "lifesupport" --sets what this things count adds from
TOOL.Language["Undone"] = "Life Support Device Removed";
TOOL.Language["Cleanup"] = "Life Support";
TOOL.Language["Cleaned"] = "Removed all life support";
TOOL.Language["SBoxLimit"] = "Hit the life support limit";

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