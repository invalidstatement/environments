
TOOL.Category = "Storages"
TOOL.Name = "Gas Storages"
TOOL.ClientConVar[ "model" ] = "models/props_wasteland/coolingtank02.mdl"
TOOL.ClientConVar[ "Weld" ] = 1
TOOL.ClientConVar[ "NoCollide" ] = 0
TOOL.ClientConVar[ "Type" ] = "Oxygen"
TOOL.ClientConVar[ "Freeze" ] = 1
TOOL.Tab = "Environments"

local EntityName = "env_storage"
local toolname = "gas_storages"

cleanup.Register("storage")

local GenModels = { ["models/props/de_port/tankoil01.mdl"] = {},
						["models/props/de_nuke/storagetank.mdl"] = {},
						["models/props_wasteland/coolingtank02.mdl"] = {},
						["models/props_c17/oildrum001.mdl"] = {} }


-- This needs to be shared...
function TOOL:GetGenModel()
	local mdl = self:GetClientInfo("model")
	if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/props_wasteland/coolingtank02.mdl" end
	return mdl
end
						
if (SERVER) then
	CreateConVar("sbox_maxstorage", 10)
	
	function TOOL:CreateDevice(ply, trace, Model)
		if (!ply:CheckLimit("storage")) then return end
		if self:GetClientInfo("type") == "carbon dioxide" then
			name = EntityName.."_co2"
		else
			name = EntityName.."_"..self:GetClientInfo("type")
		end
		local ent = ents.Create(name)
		if (!ent:IsValid()) then return end
		
		-- Pos/Model/Angle
		ent:SetModel( Model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )

		local volume_mul = 1
		local base_volume = 4084
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() and phys.GetVolume then
			local vol = phys:GetVolume()
			vol = math.Round(vol)
			volume_mul = vol/base_volume
		end
		
		ent:SetPlayer(ply)
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():Wake()
		
		ent:AddResource(string.lower(self:GetClientInfo("Type")), math.Round(volume_mul * 4600))
		
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		
		-- Get the model
		local model = self:GetGenModel()
		if (!model) then return end

		-- If the trace hit an entity
		local traceent = trace.Entity
		local ent = self:CreateDevice( ply, trace, model )
		if (!ent or !ent:IsValid()) then return end
		local phys = ent:GetPhysicsObject()
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			if self:GetClientInfo("Weld") == "1" then
				local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			end
			if self:GetClientInfo("NoCollide") == "1" then
				local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
			end
		end
		if self:GetClientInfo("Freeze") == "1" then
			phys:EnableMotion( false ) 
			ply:AddFrozenPhysicsObject( ent, phys )
		end
				
		ply:AddCount( "storage", ent)
		ply:AddCleanup( "storage", ent )

		undo.Create( "storage" )
			undo.AddEntity( ent )
			if weld then
				undo.AddEntity( weld )
			end
			if nocollide then
				undo.AddEntity( nocollide )
			end
			undo.SetPlayer( ply )
		undo.Finish()
			
		return true
	end
	
	function TOOL:RightClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		
		-- Get the model
		local model = self:GetDeviceModel()
		if (!model) then return end

		-- If the trace hit an entity
		local traceent = trace.Entity
		if (traceent and traceent:IsValid() and traceent.Repair) then
			traceent:Repair()
		end
	end
else
	language.Add( "Tool_gas_storages_name", "Gas Storages" )
	language.Add( "Tool_gas_storages_desc", "Used to gas storages." )
	language.Add( "Tool_gas_storages_0", "Primary: Spawn an gas storage" )
	language.Add( "undone_storage", "Undone Storage Device" )
	language.Add( "Cleanup_storage", "Storage Devices" )
	language.Add( "Cleaned_storage", "Cleaned up all Storage Devices" )
	language.Add( "SBoxLimit_storage", "You've reached the Storage Device limit!" )
	
	local options = {}
	options["Oxygen"] = {gas_storages_Type = "oxygen"}
	options["Carbon-Dioxide"] = {gas_storages_Type = "carbon dioxide"}
	options["Hydrogen"] = {gas_storages_Type = "hydrogen"}
	options["Nitrogen"] = {gas_storages_Type = "nitrogen"}
	
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:ClearControls()
		CPanel:AddHeader()
		CPanel:AddDefaultControls()
		CPanel:AddControl("Header", { Text = "#Tool_gas_storages_name", Description = "#Tool_gas_storages_desc" })
		
		CPanel:AddControl("ComboBox", {
			Label = "#Presets",
			MenuButton = "1",
			Folder = "Storages",

			Options = {
				Default = {
					gas_storages_model = "models/combatmodels/tank_gun.mdl",
				}
			},

			CVars = {
				[0] = "gas_storages_model",
			}
		})
		
		CPanel:AddControl( "PropSelect", {
			Label = "#Models",
			ConVar = "gas_storages_model",
			Category = "Storages",
			Models = GenModels
		})
		CPanel:AddControl("ComboBox", { Label = "Gas", MenuButton = 0, Options = options})
		CPanel:AddControl("CheckBox", { Label = "Weld", Command = "gas_storages_Weld" })
		CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = "gas_storages_NoCollide" })
		CPanel:AddControl("CheckBox", { Label = "Freeze", Command = toolname.."_Freeze" })
	end

	function TOOL:UpdateGhostCannon( ent, player )
		if (!ent or !ent:IsValid()) then return end
		local trace = player:GetEyeTrace()
		
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		
		ent:SetNoDraw( false )
	end
	
	function TOOL:Think()
		local model = self:GetGenModel()
		if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model) then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() + Angle(90,0,0) )
		end
		self:UpdateGhostCannon( self.GhostEntity, self:GetOwner() )
	end
end