include("weapons/gmod_tool/environments_tool_base.lua")
AddCSLuaFile("weapons/gmod_tool/stools/air_compressors.lua")

TOOL.Category = "Generators"
TOOL.Name = "Air Compressors"
TOOL.Description = "Used to spawn air compressors"

TOOL.ClientConVar[ "Type" ] = "Oxygen"

TOOL.Models = {     ["models/props_vehicles/generatortrailer01.mdl"] = {},
					["models/props_outland/generator_static01a.mdl"] = {} }
					
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "air_compressor";
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
	local base_volume = 4084
	base_volume = 188530
		
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	
	ent.caf = {}
	ent.caf.custom = {}
	ent.caf.custom.resource = string.lower(self:GetClientInfo("Type"))
	
	ent:SetMultiplier(volume_mul)
end
	
local options = {}
options["Oxygen"] = {air_compressors_Type = "oxygen"}
options["Carbon-dioxide"] = {air_compressors_Type = "carbon dioxide"}
options["Hydrogen"] = {air_compressors_Type = "hydrogen"}
options["Nitrogen"] = {air_compressors_Type = "nitrogen"}
	
function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:ClearControls()
	CPanel:AddHeader()
	CPanel:AddDefaultControls()
	CPanel:AddControl("Header", { Text = "#Tool_water_tanks_name", Description = "#Tool_water_tanks_desc" })
		
	CPanel:AddControl( "PropSelect", {
		Label = "#Models",
		ConVar = name.."_model",
		Category = "Storages",
		Models = Models
	})
	
	CPanel:AddControl("ComboBox", { Label = "Gas", MenuButton = 0, Options = options})
	CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
	CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
	CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
end
	
TOOL:Register()