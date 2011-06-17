
TOOL.Category = "Life Support"
TOOL.Name = "Life Support Core"
TOOL.ClientConVar[ "model" ] = "models/SBEP_community/d12airscrubber.mdl"
TOOL.ClientConVar[ "Weld" ] = 1
TOOL.ClientConVar[ "NoCollide" ] = 0
TOOL.ClientConVar[ "Freeze" ] = 1
TOOL.Tab = "Environments"

local EntityName = "env_lscore"
local toolname = "ls_devices"

cleanup.Register("generators")

local PewPewModels = { 	["models/SBEP_community/d12airscrubber.mdl"] = {} }


-- This needs to be shared...
function TOOL:GetDeviceModel()
	local mdl = self:GetClientInfo("model")
	if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/SBEP_community/d12airscrubber.mdl" end
	return mdl
end
						
if (SERVER) then
	CreateConVar("sbox_maxgenerator", 12)

	function TOOL:CreateDevice(ply, trace, Model)
		if (!ply:CheckLimit("generator")) then return end
		local ent = ents.Create( EntityName )
		if (!ent:IsValid()) then return end
		
		-- Pos/Model/Angle
		ent:SetModel( Model )
		ent:SetPos( trace.HitPos ) --- trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() )
		
		ent:SetPlayer(ply)
		ent:Spawn()
		ent:Activate()
		
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		local traceent = trace.Entity
		
		-- Get the model
		local model = self:GetDeviceModel()
		if (!model) then return end

		-- else create a new one
			
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
				
		ply:AddCount( "generator", ent)
		ply:AddCleanup( "generator", ent )

		undo.Create( "generator" )
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
	language.Add( "Tool_"..toolname.."_name", "Life Support" )
	language.Add( "Tool_"..toolname.."_desc", "Used to spawn life support." )
	language.Add( "Tool_"..toolname.."_0", "Primary: Spawn a life support device" )
	language.Add( "undone_generator", "Undone Generators" )
	language.Add( "Cleanup_generator", "Generators" )
	language.Add( "Cleaned_generator", "Cleaned up all Generators" )
	language.Add( "SBoxLimit_generator", "You've reached the generator limit!" )
	
	
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:ClearControls()
		CPanel:AddHeader()
		CPanel:AddDefaultControls()
		CPanel:AddControl("Header", { Text = "#Tool_ls_devices_name", Description = "#Tool_ls_devices_desc" })
		
		CPanel:AddControl("ComboBox", {
			Label = "#Presets",
			MenuButton = "1",
			Folder = "Storages",

			Options = {
				Default = {
					ls_devices_model = "models/SBEP_community/d12airscrubber.mdl",
				}
			},

			CVars = {
				[0] = "ls_device_model",
			}
		})
		
		-- (Thanks to Grocel for making this selectable icon thingy)
		CPanel:AddControl( "PropSelect", {
			Label = "#Models (Or click Reload to select a model)",
			ConVar = toolname.."_model",
			Category = "Storages",
			Models = PewPewModels
		})
		CPanel:AddControl("CheckBox", { Label = "Weld", Command = toolname.."_Weld" })
		CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = toolname.."_NoCollide" })
		CPanel:AddControl("CheckBox", { Label = "Freeze", Command = toolname.."_Freeze" })
	end

	-- Ghost functions (Thanks to Grocel for making the base. I changed it a bit)
	function TOOL:UpdateGhostDevice( ent, player )
		if (!ent or !ent:IsValid()) then return end
		local trace = player:GetEyeTrace()
		
		ent:SetAngles( trace.HitNormal:Angle() )
		ent:SetPos( trace.HitPos ) --- trace.HitNormal * ent:OBBMins().z )
		
		ent:SetNoDraw( false )
	end
	
	function TOOL:Think()
		local model = self:GetDeviceModel()
		if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model) then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() )
		end
		self:UpdateGhostDevice( self.GhostEntity, self:GetOwner() )
	end
end