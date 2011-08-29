//Creates Tools
AddCSLuaFile("autorun/EntRegister.lua")
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

local list = list
local scripted_ents = scripted_ents
local table = table
local math = math
local cleanup = cleanup
local language = language
local util = util
local constraint = constraint
local pairs = pairs

if not Environments then
	Environments = {}
end

local Environments = Environments --yay speed boost!

Environments.MakeData = {}

local default = {}
default.basevolume = 4096
default.basehealth = 200
default.basemass = 200
function Environments.MakeFunc(ent)
	local data = ""
	if !Environments.MakeData[ent:GetClass()] then
		ErrorNoHalt("MakeFunc WARNING: No MakeData found for "..ent:GetClass().."! Defaulting!\n") 
		data = default
	else
		data = Environments.MakeData[ent:GetClass()]
	end
	
	local base_volume = data.basevolume
	local volume_mul = 1 //Change to be 0 by default later on
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	
	if data.resources then
		for k,v in pairs(data.resources) do
			ent:AddResource(v, k*volume_mul)
		end
	end
	
	ent:SetMaxHealth(data.basehealth*volume_mul)
	ent:SetHealth(data.basehealth*volume_mul)
	
	ent:GetPhysicsObject():SetMass(data.basemass*volume_mul)
end

/*GENERATOR_1_TO_1 = 1
GENERATOR_2_TO_1 = 2
GENERATOR_1_TO_2 = 3
function GetGenerateFunc(type, res1, res2, res3)
	if type == 1 then
		CompileString([[func = function(self)
			local mult = self:GetMultiplier() 
			local amt = self:ConsumeResource(]]..res1..[[, 200) 
			amt = self:ConsumeResource(]]..res2..[[,amt*1.5)  
			self:SupplyResource(]]..res3..[[, amt)
		end]], "asdadjlkj")()
	elseif type == 2 then
		func = function(self)
		
		end
	end
	return func
end*/

function Environments.RegisterEnt(class, basevolume, basehealth, basemass)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	--Environments.MakeData[class].resources = table.Copy(res)
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
end

Environments.RegisterEnt("generator_fusion", 339933 * 3, 1000, 1000)
Environments.RegisterEnt("generator_solar", 1982, 50, 10)
Environments.RegisterEnt("generator_water", 18619, 200, 60)
Environments.RegisterEnt("env_air_compressor", 284267, 600, 200)
Environments.RegisterEnt("generator_water_to_air", 49738, 350, 120)
Environments.RegisterEnt("generator_hydrogen_fuel_cell", 27929, 200, 60)

function Environments.RegisterLSEntity(name,class,In,Out,generatefunc,basevolume,basehealth,basemass) --simple quick entity creation
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = name
	
	list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
	
	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.Active = 0
			if WireAddon then
				self.WireDebugName = self.PrintName
				self.Outputs = Wire_CreateOutputs(self, { "Out" })
			end
		end
		
		function ENT:TurnOn()
			if self.Active == 0 then
				self.Active = 1
				self:SetOOO(1)
			end
		end

		function ENT:TurnOff()
			if self.Active == 1 then
				self.Active = 0
				self:SetOOO(0)
				if WireAddon then Wire_TriggerOutput(self, "Out", 0) end
			end
		end

		function ENT:SetActive(value)
			if not (value == nil) then
				if (value != 0 and self.Active == 0 ) then
					self:TurnOn()
				elseif (value == 0 and self.Active == 1 ) then
					self:TurnOff()
				end
			else
				if ( self.Active == 0 ) then
					self:TurnOn()
				else
					self:TurnOff()
				end
			end
		end
		
		ENT.Generate = generatefunc

		function ENT:Think()
			if self.Active == 1 then
				self:Generate()
			end
			
			self:NextThink(CurTime() + 1)
			return true
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, class, true)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
	print("Entity Registered "..class)
end

function Environments.RegisterLSStorage(name, class, res, basevolume, basehealth, basemass)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_storage"
	ENT.PrintName = name
	
	list.Set( "LSEntOverlayText", class, {HasOOO = false, resnames = res} )
	
	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.damaged = 0
			if WireAddon then
				self.WireDebugName = self.PrintName
				self.Outputs = Wire_CreateOutputs(self.Entity, { "Out" })
			end
		end
		
		function ENT:AddResource(name,amt)--adds to storage
			if not self.maxresources then self.maxresources = {} end
			self.maxresources[name] = (self.maxresources[name] or 0) + amt
		end

		function ENT:Damage()
			if (self.damaged == 0) then self.damaged = 1 end
		end
	else
	
	end
	
	scripted_ents.Register(ENT, class, true)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	Environments.MakeData[class].resources = table.Copy(res)
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
	print("Storage Registered "..class)
end

function Environments.RegisterTool(name, filename, category, description, cleanupgroup, limit)
	local TOOL = ToolObj:Create()
	
	TOOL.Mode = filename
	TOOL.Name = name
	TOOL.Tab = "Environments"
	
	TOOL.Category = category
	TOOL.AddToMenu = true
	TOOL.Description = description
	TOOL.Command = nil
	TOOL.ConfigName = ""
	
	TOOL.ClientConVar[ "model" ] = " "
	TOOL.ClientConVar[ "type" ] = " "
	TOOL.ClientConVar[ "sub_type" ] = " "
	TOOL.ClientConVar[ "Weld" ] = 1
	TOOL.ClientConVar[ "NoCollide" ] = 0
	TOOL.ClientConVar[ "Freeze" ] = 1
	
	TOOL.CleanupGroup = cleanupgroup

	TOOL.Entity = {
		Angle=Angle(90,0,0), -- Angle offset?
		Keys={}, -- These keys will be saved by the duplicator on a copy, NOT!
		Class=class, -- Default SENT to spawn
		Limit=limit or 20, -- Limits?
	};

	TOOL.Topic = {}
	TOOL.Language = {}

	function TOOL:Register()
		-- Register language clientside
		if self.Language["Cleanup"] then
			cleanup.Register(self.CleanupGroup)
		end
		if CLIENT then
			//Yay, simplified titles
			language.Add( "Tool_"..self.Mode.."_name", self.Name )
			language.Add( "Tool_"..self.Mode.."_desc", self.Description )
			language.Add( "Tool_"..self.Mode.."_0", "Primary: Spawn a Device. Reload: Repair a Device." )
			
			for k,v in pairs(self.Language) do
				language.Add(k.."_"..self.CleanupGroup,v)
			end
		else
			CreateConVar("sbox_max"..self.CleanupGroup,self.Entity.Limit)
		end
	end

	function TOOL:GetDeviceModel()
		local mdl = self:GetClientInfo("model")

		--/*do I really need this?*/ if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl" end
		return mdl
	end
	
	function TOOL:GetDeviceClass()
		if Environments.Tooldata[self.Name][self:GetClientInfo("type")] then
			if Environments.Tooldata[self.Name][self:GetClientInfo("type")][self:GetClientInfo("sub_type")] then
				return Environments.Tooldata[self.Name][self:GetClientInfo("type")][self:GetClientInfo("sub_type")].class
			end
		end
	end
	
	function TOOL:GetDeviceInfo()
		return Environments.Tooldata[self.Name][self:GetClientInfo("type")][self:GetClientInfo("sub_type")]
	end

	if SERVER then
		function TOOL:CreateDevice(ply, trace, Model, class)
			if !ply:CheckLimit(self.CleanupGroup) then return end
			if !class then return end
			local ent = ents.Create(class)
			if !ent:IsValid() then return end
			
			local info = self:GetDeviceInfo()
			
			-- Pos/Model/Angle
			ent:SetModel( Model )
			ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
			ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )

			ent:SetPlayer(ply)
			ent:Spawn()
			ent:Activate()
			ent:GetPhysicsObject():Wake()
			
			if info.skin then
				ent:SetSkin(info.skin)
			end
			
			if info.extra then
				ent.env_extra = info.extra
			end
			
			print("Ent Created: Volume: "..ent:GetPhysicsObject():GetVolume())
			
			Environments.MakeFunc(ent)
			
			return ent
		end

		function TOOL:LeftClick( trace )
			if !trace then return end
			local traceent = trace.Entity
			local ply = self:GetOwner()
				
			-- Get the model
			local model = self:GetDeviceModel()
			if !model then return end
		
			//create it
			local ent = self:CreateDevice( ply, trace, model, self:GetDeviceClass() )
			if !ent or !ent:IsValid() then return end
			
			//effect :D
			if DoPropSpawnedEffect then
				DoPropSpawnedEffect(ent)
			end
			
			//constraints
			local weld = nil
			local nocollide = nil
			local phys = ent:GetPhysicsObject()
			if (!traceent:IsWorld() and !traceent:IsPlayer()) then
				if self:GetClientInfo("Weld") == "1" then
					weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
				end
				if self:GetClientInfo("NoCollide") == "1" then
					nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
				end
			end
			if self:GetClientInfo("Freeze") == "1" then
				phys:EnableMotion( false ) 
				ply:AddFrozenPhysicsObject( ent, phys )
			end
			
			//Counts and undos
			ply:AddCount( self.CleanupGroup, ent)
			ply:AddCleanup( self.CleanupGroup, ent )

			self:AddUndo(ply, ent, weld, nocollide)

			return true
		end
		
		function TOOL:RightClick( trace )
			return
		end
		
		function TOOL:Reload(trace)
			if trace.Entity and trace.Entity:IsValid() then
				if trace.Entity.Repair then
					trace.Entity:Repair()
					self:GetOwner():ChatPrint("Device Repaired!")
					return true
				end
			end
		end
		
		//Cleanups and stuff
		function TOOL:AddUndo(p,...)
			undo.Create(self.CleanupGroup)
			for k,v in pairs({...}) do
				if(k ~= "n") then
					undo.AddEntity(v)
				end
			end
			undo.SetPlayer(p)
			undo.Finish()
		end
	end

	if SinglePlayer() and SERVER or !SinglePlayer() and CLIENT then
		// Ghosts, scary
		function TOOL:UpdateGhostEntity( ent, player )
			if !ent or !ent:IsValid() then return end
			local trace = player:GetEyeTrace()
			
			if trace.HitNonWorld then
				if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
					ent:SetNoDraw( true )
					return
				end
			end
				
			ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )
			ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
				
			ent:SetNoDraw( false )
		end
			
		function TOOL:Think()
			local model = ""
			model = self:GetDeviceModel()
			if !self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model then
				local trace = self:GetOwner():GetEyeTrace()
				self:MakeGhostEntity( model, trace.HitPos, trace.HitNormal:Angle() + self.Entity.Angle )
			end
			self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
		end
		
		function TOOL:MakeGhostEntity( model, pos, angle )
			util.PrecacheModel( model )
			
			// Release the old ghost entity
			self:ReleaseGhostEntity()
			
			// Don't allow ragdolls/effects to be ghosts
			if !model or model == " " or model == "" then return end
			
			self.GhostEntity = ents.Create( "prop_physics" )
			
			// If there's too many entities we might not spawn..
			if !self.GhostEntity:IsValid() then
				self.GhostEntity = nil
				return
			end
			
			self.GhostEntity:SetModel( model )
			self.GhostEntity:SetPos( pos )
			self.GhostEntity:SetAngles( angle )
			self.GhostEntity:Spawn()
			
			self.GhostEntity:SetSolid( SOLID_VPHYSICS )
			self.GhostEntity:SetMoveType( MOVETYPE_NONE )
			self.GhostEntity:SetNotSolid( true )
			self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.GhostEntity:SetColor( 255, 255, 255, 150 )
		end
	end
	
	local name = TOOL.Mode

	TOOL.Language["Undone"] = "Generator Removed";
	TOOL.Language["Cleanup"] = "Generators";
	TOOL.Language["Cleaned"] = "Removed all generators";
	TOOL.Language["SBoxLimit"] = "Hit the generator limit";
	
	local self = TOOL
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:ClearControls()
		CPanel:AddHeader()
		CPanel:AddDefaultControls()
		CPanel:AddControl("Header", { Text = "#Tool_"..name.."_name", Description = "#Tool_"..name.."_desc" })
		
		local list = vgui.Create( "DPanelList" )
		list:SetTall( 400 )
		list:SetPadding( 1 )
		list:SetSpacing( 1 )
		list:EnableVerticalScrollbar(true)
		
		local ccv_type		= self.Mode.."_type"
		local ccv_sub_type	= self.Mode.."_sub_type"
		local ccv_model 	= self.Mode.."_model"
			
		local cur_type		= GetConVarString(ccv_type)
		local cur_sub_type	= GetConVarString(ccv_sub_type)
		local cur_model	 	= GetConVarString(ccv_model)
		
		for cat,tab in pairs(Environments.Tooldata[self.Name]) do
			local c = vgui.Create("DCollapsibleCategory")
			c:SetLabel(cat)
			c:SetExpanded(false)
			
			local CategoryList = vgui.Create( "DPanelList" )
			CategoryList:SetAutoSize( true )
			CategoryList:SetSpacing( 6 )
			CategoryList:SetPadding( 3 )
			CategoryList:EnableHorizontal( true )
			CategoryList:EnableVerticalScrollbar( true )
			
			for k,v in pairs(tab) do
				local icon = vgui.Create("SpawnIcon")
				
				util.PrecacheModel(v.model)
				icon:SetModel(v.model)
				icon.tool = self
				icon.model = v.model
				icon.class = v.class
				icon.skin = v.skin
				icon.devname = k
				icon.devtype = cat
				icon:SetTooltip(k)
				icon.DoClick = function(self)
					self.tool.Model = self.model
					RunConsoleCommand( ccv_type, self.devtype )
					RunConsoleCommand( ccv_sub_type, self.devname )
					RunConsoleCommand( ccv_model, self.model )
				end
				
				CategoryList:AddItem(icon)
			end
			
			c:SetContents(CategoryList)
			list:AddItem(c)
		end
		CPanel:AddPanel(list)

		CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
		CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
		CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
	end
		
	TOOL:Register()

	TOOL:CreateConVars()
	SWEP.Tool[ name ] = TOOL --inject into stool
end

Environments.Tooldata = {}
function Environments.RegisterDevice(toolname, genname, devname, class, model, skin, extra)
	if !Environments.Tooldata[toolname] then
		Environments.Tooldata[toolname] = {}
	end
	local dat = Environments.Tooldata[toolname]
	
	if !dat[genname] then
		dat[genname] = {}
	end
	dat[genname][devname] = {}
	dat[genname][devname].model = model
	dat[genname][devname].class = class
	dat[genname][devname].skin = skin
	dat[genname][devname].extra = extra
end

hook.Add("AddTools", "environments tool hax", function()
	Environments.RegisterTool("Generators", "Energy_Gens", "Life Support", "Used to spawn various LS devices", "generator", 30)
	Environments.RegisterTool("Storages", "Storage_Tanks", "Life Support", "Used to spawn various resource storages", "storage", 20)
	Environments.RegisterTool("Life Support", "Life_Support", "Life Support", "Used to spawn various devices designed to keep you alive in space.", "lifesupport", 15)
end)

//Load devices and stuff from addons
local Files = file.FindInLua( "environments/lifesupport/*.lua" )
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "environments/lifesupport/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "environments/lifesupport/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	else
		Msg("Loaded: Successfully\n")
	end
end
