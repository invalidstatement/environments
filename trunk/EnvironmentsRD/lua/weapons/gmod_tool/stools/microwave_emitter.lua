include("weapons/gmod_tool/environments_tool_base.lua")

TOOL.Category = "Generators"
TOOL.Name = "Microwave Emitter"
TOOL.Description = "Used to spawn microwave emitters"

TOOL.Models = { 	["models/props_phx/life_support/crylaser_small.mdl"] = {} }
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "generator_microwave";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 6
local name = TOOL.Mode

TOOL.CleanupGroup = "generator" --sets what this things count adds from
TOOL.Language["Undone"] = "Generator Removed";
TOOL.Language["Cleanup"] = "Generators";
TOOL.Language["Cleaned"] = "Removed all generators";
TOOL.Language["SBoxLimit"] = "Hit the generator limit";

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