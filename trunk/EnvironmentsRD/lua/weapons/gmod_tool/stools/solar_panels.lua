include("weapons/gmod_tool/environments_tool_base.lua")

TOOL.Category = "Generators"
TOOL.Name = "Solar Panels"
TOOL.Description = "Used to spawn solar panels"

TOOL.Models = { 	["models/ce_ls3additional/solar_generator/solar_generator_giant.mdl"] = {},
					["models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl"] = {} }
					
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "generator_solar";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 20
local name = TOOL.Mode

TOOL.CleanupGroup = "generator" --sets what this things count adds from
TOOL.Language["Undone"] = "Generator Removed";
TOOL.Language["Cleanup"] = "Generators";
TOOL.Language["Cleaned"] = "Removed all generators";
TOOL.Language["SBoxLimit"] = "Hit the generator limit";

function TOOL:GetMults(ent)
	local volume_mul = 1 //Change to be 0 by default later on
	local base_volume = 1982 //Change to the actual base volume later on
	local phys = ent:GetPhysicsObject()
	local volume = -1
		
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		volume = math.Round(vol)
	end
		
	if volume != -1 then
		volume_mul = volume/base_volume
	end
		
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