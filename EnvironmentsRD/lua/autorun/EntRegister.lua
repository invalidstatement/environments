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
--Environments.MakeData[class].resources = resources and multipliers for each
--Environments.MakeData[class].basevolume = basevolume for determining mult
local default = {}
default.basevolume = 4096
default.basehealth = 200
default.basemass = 200
function Environments.MakeFunc(ent)
	local data = ""
	if !Environments.MakeData[ent:GetClass()] then
		ErrorNoHalt("MakeFunc ERROR: No MakeData found for "..ent:GetClass().."! Defaulting!\n") 
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

function Environments.RegisterTool(name, filename, category, description, cleanupgroup)
	local TOOL = ToolObj:Create()
	
	TOOL.Mode = filename
	TOOL.Name = name
	TOOL.Tab = "Environments"
	
	TOOL.Category = category
	TOOL.AddToMenu = true
	TOOL.Description = description
	TOOL.Command = nil
	TOOL.ConfigName = ""
	
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
		Limit=20, -- Limits?
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
			if class then
				CreateConVar("sbox_max"..self.CleanupGroup,self.Entity.Limit)
			end
		end
	end

	function TOOL:GetDeviceModel()
		local mdl = ""
		local type = self:GetClientInfo("type")
		local sub_type = self:GetClientInfo("sub_type")
		if Environments.Tooldata[self.Name][type] then
			if Environments.Tooldata[self.Name][type][sub_type] then
				mdl = Environments.Tooldata[self.Name][type][sub_type].model
			end
		end
		if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl" end
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
			
			--ccccccccccccccccccccccccPrintTable(info)
			if info.extra then
				--print("info.extra exists!")
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
			local model = self.Model or self:GetDeviceModel()
			if !self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model then
				local trace = self:GetOwner():GetEyeTrace()
				self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() + self.Entity.Angle )
			end
			self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
		end
	end
	

	TOOL.Models = models
	local Models = TOOL.Models --fixes stuph		

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
			
		local cur_type		= GetConVarString(ccv_type)
		local cur_sub_type	= GetConVarString(ccv_sub_type)
		
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
					--print("Selected "..self.devname)
					self.tool.Model = self.model
					RunConsoleCommand( ccv_type, self.devtype )
					RunConsoleCommand( ccv_sub_type, self.devname )
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

//Generator Tool
Environments.RegisterDevice("Generators", "Fusion Generator", "Huge Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_huge.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_large.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Medium Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_medium.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_small.mdl")

Environments.RegisterDevice("Generators", "Solar Panel", "Large Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Huge Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl")

Environments.RegisterDevice("Generators", "Water Pump", "Large Water Pump", "generator_water", "models/chipstiks_ls3_models/LargeH2OPump/largeh2opump.mdl")
Environments.RegisterDevice("Generators", "Water Pump", "Small Water Pump", "generator_water", "models/props_phx/life_support/gen_water.mdl")

Environments.RegisterDevice("Generators", "Oxygen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", nil, "oxygen")
Environments.RegisterDevice("Generators", "Oxygen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "oxygen")

Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", nil, "nitrogen")
Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "nitrogen")

Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", nil, "hydrogen")
Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "hydrogen")

Environments.RegisterDevice("Generators", "CO2 Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", nil, "carbon dioxide")
Environments.RegisterDevice("Generators", "CO2 Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "carbon dioxide")

Environments.RegisterDevice("Generators", "Water Splitter", "Water Splitter", "generator_water_to_air", "models/ce_ls3additional/water_air_extractor/water_air_extractor.mdl")

Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell", "Small Fuel Cell", "generator_hydrogen_fuel_cell", "models/Slyfo/electrolysis_gen.mdl")

//Storage Tool
Environments.RegisterDevice("Storages", "Water Storage", "Large Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_large.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Medium Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_medium.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Small Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_small.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Tiny Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_tiny.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Massive Water Tank", "env_water_storage", "models/props/de_nuke/storagetank.mdl")

Environments.RegisterDevice("Storages", "Energy Storage", "Large Battery", "env_energy_storage", "models/props_phx/life_support/battery_large.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Battery", "env_energy_storage", "models/props_phx/life_support/battery_medium.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Battery", "env_energy_storage", "models/props_phx/life_support/battery_small.mdl")

Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Storage", "env_oxygen_storage", "models/props_wasteland/coolingtank02.mdl")

Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Storage", "env_nitrogen_storage", "models/props_wasteland/coolingtank02.mdl")

Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Storage", "env_hydrogen_storage", "models/props_wasteland/coolingtank02.mdl")

Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Storage", "env_co2_storage", "models/props_wasteland/coolingtank02.mdl")


//Life Support Tool
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Suit Dispenser", "suit_dispenser", "models/props_combine/combine_emitter01.mdl")
Environments.RegisterDevice("Life Support", "LS Core", "LS Core", "env_lscore", "models/SBEP_community/d12airscrubber.mdl")
Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/props_combine/combine_mine01.mdl")

hook.Add("AddTools", "environments tool hax", function()
	Environments.RegisterTool("Steam Storages", "Steam_Storage", "Storages", "asdajldkjad", "env_steam_storage", {["models/chipstiks_ls3_models/LargeSteamTank/largesteamtank.mdl"] = {}}, "storage")
	Environments.RegisterTool("Water Tanks", "Water_Takns", "Storages", "asdajldkjad", "env_water_storage", {
		["models/ce_ls3additional/resource_tanks/resource_tank_large.mdl"] = {},
		["models/ce_ls3additional/resource_tanks/resource_tank_medium.mdl"] = {},
		["models/ce_ls3additional/resource_tanks/resource_tank_small.mdl"] = {},
		["models/ce_ls3additional/resource_tanks/resource_tank_tiny.mdl"] = {}, 
		["models/props/de_port/tankoil01.mdl"] = {},
		["models/props/de_nuke/storagetank.mdl"] = {},
		["models/props_wasteland/coolingtank02.mdl"] = {},
		["models/props_c17/oildrum001.mdl"] = {} 
	}, "storage")
	
	//Real Tools
	Environments.RegisterTool("Generators", "Energy_Gens", "Tools", "Used to spawn various LS devices", "generator")
	Environments.RegisterTool("Storages", "Storage_Tanks", "Tools", "Used to spawn various resource storages", "storage")
	Environments.RegisterTool("Life Support", "Life_Support", "Tools", "Used to spawn various devices designed to keep you alive in space.", "life support")
	
	Environments.RegisterTool("Water Heaters", "Water_Heater", "Generators", "asdajldkjad", "env_water_heater", {["models/ce_ls3additional/water_heater/water_heater.mdl"] = {}}, "generator")
end)

Environments.RegisterLSStorage("Steam Storage", "env_steam_storage", {[3600] = "steam"}, 4084, 400, 300)
Environments.RegisterLSStorage("Water Storage", "env_water_storage", {[3600] = "water"}, 4084, 400, 500)
Environments.RegisterLSStorage("Energy Storage", "env_energy_storage", {[3600] = "energy"}, 6021, 200, 5)
Environments.RegisterLSStorage("Oxygen Storage", "env_oxygen_storage", {[4600] = "oxygen"}, 4084, 100, 10)
Environments.RegisterLSStorage("Hydrogen Storage", "env_hydrogen_storage", {[4600] = "hydrogen"}, 4084, 100, 10)
Environments.RegisterLSStorage("Nitrogen Storage", "env_nitrogen_storage", {[4600] = "nitrogen"}, 4084, 100, 10)
Environments.RegisterLSStorage("CO2 Storage", "env_co2_storage", {[4600] = "co2"}, 4084, 100, 10)

Environments.RegisterLSEntity("Water Heater","env_water_heater",{"water","energy"},{"steam"},function(self) local mult = self:GetMultiplier() local amt = self:ConsumeResource("water", 200) amt = self:ConsumeResource("energy",amt*1.5)  self:SupplyResource("steam", amt) end, 70000, 300, 300)

