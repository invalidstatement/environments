include("weapons/gmod_tool/environments_tool_base.lua")
AddCSLuaFile("weapons/gmod_tool/stools/fission_gen.lua")

TOOL.Category = "Generators"
TOOL.Name = "Fission Reactor"
TOOL.Description = "Used to spawn fission reactors"

TOOL.Models = { 	["models/Punisher239/punisher239_reactor_small.mdl"] = {},
					["models/Punisher239/punisher239_reactor_big.mdl"] = {} }
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "generator_fission";
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
	local base_volume = 4084 //Change to the actual base volume later on
	local phys = ent:GetPhysicsObject()
	local volume = -1
		
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		volume = math.Round(vol)
	end
		
	base_volume = 339933 * 3 --3399325  
	if volume != -1 then
		volume_mul = volume/base_volume
	end
	
	ent.maxresources = {}
	ent.maxresources["steam"] = math.Round(volume_mul*450)
	ent.maxresources["water"] = math.Round(volume_mul*100)
	
		
	ent:SetMultiplier(volume_mul)
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