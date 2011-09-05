------------------------------------------
//   Environments  //
//   CmdrMatthew   //
------------------------------------------

--localize
local math = math
local hook = hook
local game = game
local util = util
local file = file
local table = table
local timer = timer
local umsg = umsg
local ents = ents
local string = string
local os = os
local tonumber = tonumber
local pcall = pcall
local print = print
local pairs = pairs
local SysTime = SysTime

//Custom Locals
local Environments = Environments

UseEnvironments = false

local AllowNoClip = CreateConVar( "env_noclip", "0", FCVAR_NOTIFY )

//Table of all Environments
environments = {}
stars = {}

//Planet Default Atmospheres
default = {}
default.atmosphere = {}
default.atmosphere.oxygen = 30
default.atmosphere.carbondioxide = 5
default.atmosphere.methane = 0
default.atmosphere.nitrogen = 40
default.atmosphere.hydrogen = 22
default.atmosphere.argon = 0

//Overwrite CAF to fix issues with tools
timer.Create("registerCAFOverwrites", 5, 1, function()
	if CAF then
		local old = CAF.GetAddon
		local SB = {}
			
		function SB.GetStatus()
			return true
		end

		function LS.GetStatus()
			return true
		end
			
		function CAF.GetAddon(name)
			if name == "Spacebuild" then
				return SB
			elseif name == "Life Support" then
				return LS
			end
			return old(name)
		end
	end
end)

local function LoadEnvironments()
	local start = SysTime()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	local status, error = pcall(function() --log errors
	--Get All Planets Loaded
	if INFMAP then print("INFINITE MAP SYSTEM DETECTED!") --detect our map/system
		print("LOADING ENVIRONMENTS AS SUCH") 
	end
	Environments.RegisterEnvironments() 
	if UseEnvironments then --It is a spacebuild map
		//Add Hooks
		hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
		hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawn)
		hook.Add("PlayerInitialSpawn","CreateEnvironemtns", Environments.SendInfo)
		hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
		hook.Add("ShowTeam", "HelmetToggle", Environments.Hooks.HelmetSwitch)
		hook.Add("PlayerDeath", "ZgRagdoll", Environments.Hooks.PlayerDeath)
		if Environments.UseSuit then
			hook.Add("PlayerInitialSpawn", "PlayerSetSuit", Environments.Hooks.SuitInitialSpawn)
			hook.Add("PlayerDeath", "PlayerRemoveSuit", Environments.Hooks.SuitPlayerDeath)
			hook.Add("PlayerSpawn", "PlayerSetSuit", Environments.Hooks.SuitPlayerSpawn)
		end
			
		//Fixes spawning ents in space
		local meta = FindMetaTable("Entity")
		local olds = meta.Spawn
		function meta:Spawn()
			olds(self)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableDrag(false)
				phys:EnableGravity(false)
				phys:Wake()
			end
			self.environment = Space()
		end
		
		//Fixes cleanup breaking everything :D
		local o = game.CleanUpMap
		function game.CleanUpMap(b, filters)
			if filters then
				table.insert(filters, "environment")
				table.insert(filters, "star")
			else
				filters = {"environment", "star"}
			end
			o(b, filters)
		end
			
		print("// Registering Sun..               //")
		Environments.RegisterSun()
			
		print("// Starting Periodicals..          //")
		timer.Create("EnvEvents", 30, 0, Environments.EventChecker)
		print("//   Event System Started          //")
		timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		print("//   LifeSupport Checker Started   //")
	else --Not a spacebuild map
		print("//   This is not a valid space map //")
		if GAMEMODE.IsSandboxDerived and Environments.ForceLoad then
			print("//     Doing Partial Startup       //")
			--hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
			hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawnDry)
			--hook.Add("PlayerInitialSpawn","CreateEnvironemtns", Environments.SendInfo)
			hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
			hook.Add("ShowTeam", "HelmetToggle", Environments.Hooks.HelmetSwitch)
			if Environments.UseSuit then
				hook.Add("PlayerInitialSpawn", "PlayerSetSuit", Environments.Hooks.SuitInitialSpawn)
				hook.Add("PlayerDeath", "PlayerRemoveSuit", Environments.Hooks.SuitPlayerDeath)
				hook.Add("PlayerSpawn", "PlayerSetSuit", Environments.Hooks.SuitPlayerSpawn)
			end
			timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		else
			print("//     Startup Aborted             //")
		end
	end end)--ends the error checker
	
	if not error then
		print("/////////////////////////////////////")
		print("//       Environments Loaded       //")
		print("/////////////////////////////////////")
	else
		print("/////////////////////////////////////")
		print("//    Environments Load Failed     //")
		print("/////////////////////////////////////")
		print("ERROR: "..error)
		Environments.Log("Startup Error: "..error)
	end
	if Environments.Debug then
		print("Environments Server Startup Time: "..(SysTime() - start))
	end
	
	local servertags = nil
	local function AddServerTag(tag)
		if not servertags then
			servertags = GetConVarString("sv_tags")
		end
		if servertags == nil then
			RunConsoleCommand("sv_tags", tag)
		elseif not string.find(servertags, tag) then
			servertags = servertags .. ","..tag
			RunConsoleCommand("sv_tags", servertags)
		end
	end
	
	AddServerTag("SB")
	AddServerTag("Environments")
	AddServerTag("Space")
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function Environments.GetMapEntities() --use this rather than whats in Environments.LoadFromMap()
	local entities = ents.FindByClass( "logic_case" )
	Environments.MapEntities = {}
	Environments.MapEntities.Color = {}
	Environments.MapEntities.Bloom = {}
	for k,ent in pairs(entities) do
		local values = ent:GetKeyValues()
		local tab = ent:GetKeyValues()
		if( tab.Case01 == "planet_color" ) then
			table.insert( Environments.MapEntities.Color, {
				addcol = Vector( tab.Case02 ),
				mulcol = Vector( tab.Case03 ),
				brightness = tonumber( tab.Case04 ),
				contrast = tonumber( tab.Case05 ),
				color = tonumber( tab.Case06 ),
				id = tab.Case16
			} );
		elseif( tab.Case01 == "planet_bloom" ) then
			table.insert(  Environments.MapEntities.Bloom, {
				color = Vector( tab.Case02 ),
				x = tonumber( string.Explode( " ", tab.Case03 )[1] ),
				y = tonumber( string.Explode( " ", tab.Case03 )[2] ),
				passes = tonumber( tab.Case04 ),
				darken = tonumber( tab.Case05 ),
				multiply = tonumber( tab.Case06 ),
				colormul = tonumber( tab.Case07 ),
				id = tab.Case16
			} );
		end
	end
end

function Environments.RegisterEnvironments()
	local planets = {}
	local i = 0
	local map = game.GetMap()
	
	if file.Exists( "environments/" .. map ..".txt" ) then
		Environments.GetMapEntities()
		print("//   Attempting to Load From File  //")
		local contents = file.Read( "environments/" .. map .. ".txt" )
		local starscontents = file.Read( "environments/" .. map .. "_stars.txt")
		if contents and starscontents then
			local status, error = pcall(function()
				planets = table.DeSanitise(util.KeyValuesToTable(contents))
				stars = table.DeSanitise(util.KeyValuesToTable(starscontents))
				if planets.version == Environments.FileVersion then
					print("//     " .. table.Count(planets) - 1 .. " Planets Loaded From File  //")
					print("//     " .. table.Count(stars) .. " Stars Loaded From File    //")
				else --Incorrect File Version
					print("//    Files Are Of An Old Version  //")
					file.Delete("environments/"..map..".txt")
					file.Delete("environments/"..map.."_stars.txt")
					Environments.RegisterEnvironments()
					return
				end
			end)
			if error then --Read Error
				print("//    A File Read Error Has Occured//")
				file.Delete("environments/"..map..".txt")
				file.Delete("environments/"..map.."_stars.txt")
				Environments.RegisterEnvironments()
				return
			end
		else --Empty File
			print("//    The File Has No Content       //")
			file.Delete("environments/"..map..".txt")
			file.Delete("environments/"..map.."_stars.txt")
			Environments.RegisterEnvironments()
			return
		end
		planets.version = nil
		for k,v in pairs(planets) do --clean this up, the parsing only does atmosphere
			v.air = Environments.ParseSaveData(v).air --get air data from atmosphere data
			v.atmosphere = v.atm
			Environments.CreatePlanet(v)
		end  
		for k,v in pairs(stars) do
			local star = Environments.ParseStar(v)
			Environments.CreateStar(star)
		end
	else --load it from the map
		local rawdata, rawstars = Environments.CreateEnvironmentsFromMap()

		file.Write( "environments/" .. map .. "_stars.txt", util.TableToKeyValues( table.Sanitise(rawstars) ) )
	end
	if table.Count(environments) > 0 then
		UseEnvironments = true
	end
	Environments.SaveMap()
end

function Environments.CreateEnvironmentsFromMap()
	local rawdata, rawstars = Environments.LoadFromMap()
	rawdata.version = nil
	for k,v in pairs(rawdata) do
		local planet = Environments.ParsePlanet(v)
		Environments.CreatePlanet(planet)
	end
	for k,v in pairs(rawstars) do
		local star = Environments.ParseStar(v)
		Environments.CreateStar(star)
	end
	return rawdata, rawstars
end

function Environments.LoadFromMap()
	local i = 0
	local planets, stars = {}, {}
	print("//   Loading From Map              //")
	Environments.GetMapEntities()
	local entities = ents.FindByClass( "logic_case" )
	for k,ent in pairs(entities) do
		local values = ent:GetKeyValues()
		local tab = ent:GetKeyValues()
			
		local Type = tab.Case01
		local planet = {}
		planet.position = {}
		
		if Type == "env_rectangle" then
			planet.typeof = "cube"

			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			//END KEYS
	
			planet.position = ent:GetPos()
			
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
	
			i=i+1
			planet.name = i

			table.insert(planets, planet)
			print("//     Spacebuild Cube Added       //")
		elseif Type == "cube" then --need to fix in the future
			planet.typeof = "cube"
			
			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			//END KEYS
	
			planet.position = ent:GetPos()
			
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			
			i=i+1
			planet.name = i

			table.insert(planets, planet)
			print("//     Spacebuild Cube Added       //")
		elseif Type == "planet" then
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			planet.typeof = "SB2"
			
			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.atm = tonumber(tab.Case04)
			planet.temperature = tonumber(tab.Case05)
			planet.suntemperature = tonumber(tab.Case06)
			planet.colorid = tostring(tab.Case07)
			planet.bloomid = tostring(tab.Case08)
			planet.flags = tonumber(tab.Case16)
			//END KEY

			planet.position = ent:GetPos()
						
			if planet.atm == 0 then
				planet.atm = 1
			end
			i=i+1
			planet.name = i
			
			local planet = Environments.ParseSB2Environment(planet)
			table.insert(planets, planet)
			print("//     Spacebuild 2 Planet Added   //")
		elseif Type == "planet2" then
			--Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			
			planet.typeof = "SB3"
			
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.atm = tonumber(tab.Case04) --What does this mean?
			planet.pressure = tonumber(tab.Case05)
			planet.temperature = tonumber(tab.Case06)
			planet.suntemperature = tonumber(tab.Case07)
			planet.flags = tonumber(tab.Case08) --can be 0, 1, 2
			planet.atmosphere.oxygen = tonumber(tab.Case09)
			planet.atmosphere.carbondioxide = tonumber(tab.Case10)
			planet.atmosphere.nitrogen = tonumber(tab.Case11)
			planet.atmosphere.hydrogen = tonumber(tab.Case12)
			planet.name = tostring(tab.Case13) --Get Name
			planet.colorid = tostring(tab.Case15)
			planet.bloomid = tostring(tab.Case16)
				
			planet.originalco2per = planet.atmosphere.carbondioxide
				
			if planet.atm == 0 then
				planet.atm = 1
			end
						
			planet.position = ent:GetPos()
						
			i=i+1
			table.insert(planets, planet)
			print("//     Spacebuild 3 Planet Added   //")
		elseif Type == "star" then
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
						
			planet.position = ent:GetPos()
						
			planet.temperature = 10000
			planet.solaractivity = "med"
			planet.baseradiation = "1000"
						
			i=i+1	
			table.insert(stars, planet)
			print("//     Spacebuild 2 Star Added     //")
		elseif Type == "star2" then				
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.name = tostring(tab.Case06)
				
			if not planet.name then
				planet.name = "Star"
			end
				
			planet.position = ent:GetPos()
						
			planet.temperature = 5000
			planet.solaractivity = "med"
			planet.baseradiation = "1000"

			i=i+1
			table.insert(stars, planet)
			print("//     Spacebuild 3 Star Added     //")
		end
	end
	planets.version = Environments.FileVersion
	Environments.PlanetSaveData = {}
	Environments.PlanetSaveData = planets
	
	return planets, stars
end

function Environments.SaveMap() --plz work :)
	local map = game.GetMap()
	local planets = {}
	for k,v in pairs(environments) do
		if not v:IsStar() then
			local planet = {}
			--print("Gravity: "..v.gravity)
			planet.gravity = v.gravity
			--print("Pressure: "..v.pressure)
			planet.pressure = v.pressure
			planet.typeof = v.typeof
			planet.radius = v.radius
			planet.name = v.name 
			planet.temperature = v.temperature
			planet.atm = v.atmosphere
			planet.suntemperature = v.suntemperature
			planet.atmosphere = {}
			--planet.atmosphere = table.Copy(v.air)
			planet.atmosphere.oxygen = v.air.o2per
			planet.atmosphere.carbondioxide = v.air.co2per
			planet.atmosphere.hydrogen = v.air.hper
			planet.atmosphere.nitrogen = v.air.nper
			planet.atmosphere.argon = v.air.arper
			planet.atmosphere.methane = v.air.ch4per
			planet.bloomid = v.bloomid
			planet.colorid = v.colorid
			planet.unstable = v.unstable
			planet.sunburn = v.sunburn
			planet.position = v.position
			planet.originalco2per = v.originalco2per
			planet.atmosphere.total = v.air.total
			table.insert(planets, planet)
		end
	end
	planets.version = Environments.FileVersion
	--print("Environments: Map Saved "..CurTime())
	file.Write( "environments/" .. map .. ".txt", util.TableToKeyValues( table.Sanitise(planets) ) )
end
timer.Create("MapSavesEnv", 120, 0, Environments.SaveMap)

function table.Sanitise(tab)
	for k,v in pairs(tab) do
		local t = type(v)
		if t == "boolean" then
			tab[k] = {}
			tab[k].__type = "bool"
			tab[k]["1"] = tostring(v)
		elseif t == "table" then
			tab[k] = table.Sanitise(v)
		elseif t == "Vector" then
			tab[k] = {}
			tab[k].__type = "vector"
			tab[k].x = v.x
			tab[k].y = v.y
			tab[k].z = v.z
		elseif t == "Angle" then
			tab[k] = {}
			tab[k].__type = "angle"
			tab[k].p = v.p
			tab[k].y = v.y
			tab[k].r = v.r
		end
	end
	return tab
end

function table.DeSanitise(tab)
	for k,v in pairs(tab) do
		local t = type(v)

		if t == "table" then
			if v.__type then
				if v.__type == "bool" then
					if v["1"] == "true" then
						tab[k] = true
					else
						tab[k] = false
					end
				elseif v.__type == "vector" then
					tab[k] = Vector(v.x, v.y, v.z)
				elseif v.__type == "angle" then
					tab[k] = Angle(a.p, a.y, a.r)
				end
			else
				tab[k] = table.DeSanitise(v)
			end
		end
	end
	return tab
end
//Space Definition
local space = {}
space.air = {}
space.oxygen = 0
space.carbondioxide = 0
space.pressure = 0
space.temperature = 3
space.air.o2per = 0
space.noclip = 0
space.name = "space"
space.originalco2per = 0
space.gravity = 0

function space.IsOnPlanet()
	return false
end
	
function space.GetAtmosphere()
	return 0
end
	
function space.IsPlanet()
	return false
end
	
function space.IsSpace()
	return true
end
	
function space.IsStar()
	return false
end

function space.GetEnvironmentName()
	return "Space"
end

function space.GetGravity()
	return 0
end

function space.GetO2Percentage()
	return 0
end

function space.GetCO2Percentage()
	return 0
end

function space.GetNPercentage()
	return 0
end

function space.GetHPercentage()
	return 0
end

function space.GetEmptyAirPercentage()
	return 100
end

function space.GetPressure()
	return 0
end

function space.GetTemperature()
	return 3
end

function space.Convert()
	return 0
end

function Space()
	return space
end
//End Space Definition

function Environments.RegisterSun()
	local status, error = pcall(function()
		TrueSun = {}
		if table.Count(stars) > 0 then
			--set as core radiation source, and sun angle(needed for solar planels) and other sun effects
			TrueSun[1] = table.Random(stars).position
			print("//   Sun Registered                //")
		else
			TrueSun[1] = ents.FindByClass("env_sun")[1]:GetPos()
			print("//   No Stars Found                //")
			print("//   Registered Env_Sun            //")
		end
	end)

	if error then
		print("//   No Sun Found, Defaulting      //")
		TrueSun = {}
		TrueSun[1] = Vector(0,0,0)
	end
end

function Environments.Hooks.NoClip( ply, on )
	/*--if ply:GetMoveType() == MOVETYPE_FLY then ply:SetMoveType(MOVETYPE_WALK) return false end --allow them to get out of jetpack
	// Always allow them to get out of noclip
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
	// Always allow admins
	if ply:IsAdmin() then return true end
	
	--if ply:GetNWBool("inspace", true) and ply.environment.gravity == 0 then --jetpack in space :D
		--ply:SetMoveType(MOVETYPE_FLY)
		
		--return false
	--else
		// Allow others based on environment (if they can breathe or not)
		if not ply.environment then return false end --double check	
		--if ply:GetNWBool("inspace", false) then return end --not in space you don't
		--if AllowNoClip:GetBool() then return true end --check if user wants to block noclip
		
		if ply.environment.air.o2per >= 9.5 and ply.environment.temperature > 270 and ply.environment.temperature <= 310 then --if can breathe
			return true
		else
			return false
		end
	--end*/
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if ply:IsAdmin() then return true end
	
    if GetConVarNumber("env_noclip") != 1 then
		if not ply.environment then return false end --double check     
		
		if ply.environment.IsSpace and ply.environment:IsSpace() then return false end --not in space you don't
	end
	
    return true            
end

function Environments.Log(text)
	local old = file.Read("env_log.txt")
	if old then
		file.Append("env_log.txt", "\n" .. tostring(os.date("%m/%d/%y")).." - "..tostring(os.date("%H:%M:%S")) .. "; " .. text)
	else
		file.Write("env_log.txt", tostring(os.date("%m/%d/%y")).." - "..tostring(os.date("%H:%M:%S")) .. "; " .. text)
	end
end

local function Logging( ply )
	logrecs1 = {}

	for logrecs in (file.Read("env_log.txt") or ""):gmatch("[^\n\r]+") do
		table.insert(logrecs1,logrecs)
	end

	datastream.StreamToClients(ply,"sendEnvLogs",{logrecs1})
end
--concommand.Add("env_get_logs", Logging)

Environments.SFX = {}
function RegisterWorldSFXEntity(ent, planet)
	Environments.SFX[ent:EntIndex()] = ent
	Environments.SFX[ent:EntIndex()].planet = planet
end

local function SFXManager()
	if not Environments.SFX then return end
	for k,v in pairs(Environments.SFX) do
		local class = string.lower(v:GetClass())
		if class == "func_precipitation" then

		elseif class == "func_dustcloud" then
			--v:Fire("TurnOff")
		elseif class == "env_smokestack" then
			--v:SetKeyValue("BaseSpread", 300)
			--v:SetKeyValue("rendercolor", "0 0 0")
			--v:Fire("JetLength", 1000)
			--v:Fire("Rate", 400)
		end
	end
end
--timer.Create("SFXCHECKER", 10, 0, SFXManager)

local function bool(b)
	if b == "true" then 
		return true
	end
	if b == "false" then 
		return false
	end
end

function Environments.AdminCommand(ply, cmd, args)
	if !ply:IsAdmin() then return end
	local cmd = args[1]
	local value = args[2]
	
	print("Admin Command Recieved From "..ply:Nick().." Command: "..cmd..", Value: "..value)
	if cmd == "noclip" then --noclip blocking
		RunConsoleCommand("env_noclip", value)
	elseif cmd == "planetconfig" then --planet editing
		local k = value
		local v = args[3]
		if tonumber(v) then 
			v = tonumber(v) 
		elseif v == "true" or v == "false" then
			v = bool(v)
		end
		if ply.environment and ply.environment != Space() then
			print("Planet Var: '"..k.."', Set to: '"..tostring(v).."', Type: "..type(v))
			ply.environment[k] = v
		end
	end
end
concommand.Add("environments_admin", Environments.AdminCommand)

function Environments.SendInfo(ply)
	timer.Simple(1, function()
	for _, v in pairs( environments ) do
		umsg.Start( "AddPlanet", ply )
			umsg.Short( v:EntIndex() )
			umsg.Vector( v:GetPos() )
			umsg.Short( v.radius )
			umsg.String( v.name or "" )
			if v.colorid then
				umsg.String( v.colorid )
			end
			if v.bloomid then
				umsg.String( v.bloomid )
			end
		umsg.End()
	end

	for _, v in pairs( Environments.MapEntities.Color ) do
		umsg.Start( "PlanetColor", ply )
			umsg.Vector( v.addcol )
			umsg.Vector( v.mulcol )
			umsg.Float( v.brightness )
			umsg.Float( v.contrast )
			umsg.Float( v.color )
			umsg.String( v.id )
		umsg.End()
	end
	
	for _, v in pairs( Environments.MapEntities.Bloom ) do
		umsg.Start( "PlanetBloom", ply )
			umsg.Vector( v.color )
			umsg.Float( v.x )
			umsg.Float( v.y )
			umsg.Float( v.passes )
			umsg.Float( v.darken )
			umsg.Float( v.multiply )
			umsg.Float( v.colormul )
			umsg.String( v.id )
		umsg.End()
	end 
	end, ply)
end

function Environments.OnEnvironment(pos)
	for k,v in pairs(environments) do
		local distance = pos:Distance(ent:GetPos())
		if distance <= v.radius then
			return true
		end
	end
	return false
end

local function Reload(ply,cmd,args)
	if not ply:IsAdmin() then return end
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Remove()
			v = nil
		else
			v = nil
		end
	end
	environments = {}
	Environments.RegisterEnvironments()
	Environments.Log("Planets Reloaded")
	ply:ChatPrint("Environments Has Been Reset!")
end
concommand.Add("env_server_reload", Reload)

local function ComReload(ply,cmd,args)
	if not ply:IsAdmin() then return end
	
	local map = game.GetMap()
	file.Delete("environments/"..map..".txt")
	file.Delete("environments/"..map.."_stars.txt")
	
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Remove()
			v = nil
		else
			v = nil
		end
	end
	environments = {}
	Environments.RegisterEnvironments()
	Environments.Log("Planets Reloaded From Map")
	ply:ChatPrint("Environments Has Been Reloaded From Map!")
end
concommand.Add("env_server_full_reload", ComReload)

local function SendPlanetData(ply, cmd, args)
	local env = ply.environment
	--if string.lower(type(ply.environment)) == "entity" then
		umsg.Start("env_planet_data", ply)
			umsg.String(env.name)
			umsg.Float(env.gravity)
			umsg.Bool(env.unstable)
			umsg.Bool(env.sunburn)
			umsg.Float(env.temperature)
			umsg.Float(env.suntemperature or 0)
		umsg.End()
	--end
end
concommand.Add("request_planet_data", SendPlanetData)
