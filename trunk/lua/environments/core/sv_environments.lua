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
local ents = ents
local string = string
local os = os
local tonumber = tonumber
local pcall = pcall
local print = print
local pairs = pairs
local SysTime = SysTime

SRP = {} --Backup Compatability from when this was gonna be a gamemode
UseEnvironments = false

local AllowNoClip = CreateConVar( "env_allow_noclip", "1", FCVAR_NOTIFY )

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
end)

local function LoadEnvironments()
	local start = SysTime()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	local status, error = pcall(function() --log errors
	--Get All Planets Loaded
	Environments.RegisterEnvironments() 
	if UseEnvironments then --It is a spacebuild map
		//Add Hooks
		hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
		hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawn)
		hook.Add("PlayerInitialSpawn","CreateEnvironemtns", Environments.SendInfo)
		hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
		hook.Add("ShowTeam", "HelmetToggle", Environments.Hooks.HelmetSwitch)
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
			end
			self.environment = Space()
		end
			
		print("// Registering Sun..               //")
		local status, error = pcall(Environments.RegisterSun)
		if error then
			print("//   No Sun Found, Defaulting      //")
			TrueSun = {}
			TrueSun[1] = Vector(0,0,0)
		end
			
		print("// Starting Periodicals..          //")
		timer.Create("EnvEvents", 10, 1, Environments.EventChecker)
		print("//   Event System Started          //")
		timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		print("//   LifeSupport Checker Started   //")
	else --Not a spacebuild map
		print("//   This is not a valid space map //")
		print("//   Doing Partial Startup         //")
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
	end end)--ends the error checker
	
	if not error then
		print("/////////////////////////////////////")
		print("//       Environments Loaded       //")
		print("/////////////////////////////////////")
		Environments.Log("Successful Startup")
	else
		print("/////////////////////////////////////")
		print("//    Environments Load Failed     //")
		print("/////////////////////////////////////")
		print(error)
		Environments.Log("Startup Error: "..error)
	end
	if Environments.Debug then
		print("Environments Server Startup Time: "..(SysTime() - start))
	end
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function Environments.RegisterEnvironments()
	local planets = {}
	local i = 0
	local map = game.GetMap()
	
	if file.Exists( "environments/" .. map ..".txt" ) then
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
		print("//   Attempting to Load From File  //")
		local contents = file.Read( "environments/" .. map .. ".txt" )
		local starscontents = file.Read( "environments/" .. map .. "_stars.txt")
		if contents then
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
				end
			end)
			if error then --Read Error
				print("//    A File Read Error Has Occured//")
				file.Delete("environments/"..map..".txt")
				file.Delete("environments/"..map.."_stars.txt")
				Environments.RegisterEnvironments()
			end
		else --Empty File
			print("//    The File Has No Content       //")
			file.Delete("environments/"..map..".txt")
			file.Delete("environments/"..map.."_stars.txt")
			Environments.RegisterEnvironments()
		end
	else
		print("//   Loading From Map              //")
		Environments.MapEntities = {}
		Environments.MapEntities.Color = {}
		Environments.MapEntities.Bloom = {}
		local entities = ents.FindByClass( "logic_case" )
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

			for key, value in pairs(values) do
				if key == "Case01" then
					local planet = {}
					planet.position = {}
					if value == "cube" then --need to fix in the future
						planet.typeof = "cube"
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) end--Get Gravity
						end
						
						planet.position = ent:GetPos()
						
						--Add Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						planet.noclip = 0
						planet.spawn = 0
						
						i=i+1
						planet.name = i

						table.insert(planets, planet)
						print("//     Spacebuild Cube Added       //")
					elseif value == "planet" then
						planet.typeof = "sphere"
						
						--Add Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						planet.noclip = 0
						planet.spawn = 0
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) --Get Gravity
							elseif (k2 == "Case04") then planet.atm = tonumber(v2)
							elseif (k2 == "Case05") then planet.temperature = tonumber(v2)
							elseif (k2 == "Case06") then planet.suntemperature = tonumber(v2)
							elseif (k2 == "Case07") then planet.colorid = tostring(v2)
							elseif (k2 == "Case08") then planet.bloomid = tostring(v2)
							elseif (k2 == "Case16") then planet.flags = tonumber(v2) end
						end
						planet.position = ent:GetPos()
						
						if planet.atm == 0 then
							planet.atm = 1
						end
						i=i+1
						planet.name = i
						
						local planet = Environments.CreateSB2Environment(planet)
						table.insert(planets, planet)
						print("//     Spacebuild 2 Planet Added   //")
					elseif value == "planet2" then
						planet.typeof = "sphere"
						
						--Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						planet.noclip = 0
						planet.spawn = 0
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) --Get Gravity
							elseif (k2 == "Case04") then planet.atm = tonumber(v2) --What does this mean?
							elseif (k2 == "Case05") then planet.pressure = tonumber(v2)
							elseif (k2 == "Case06") then planet.temperature = tonumber(v2)
							elseif (k2 == "Case07") then planet.suntemperature = tonumber(v2)
							elseif (k2 == "Case09") then planet.atmosphere.oxygen = tonumber(v2)
							elseif (k2 == "Case10") then planet.atmosphere.carbondioxide = tonumber(v2)
							elseif (k2 == "Case11") then planet.atmosphere.nitrogen = tonumber(v2)
							elseif (k2 == "Case12") then planet.atmosphere.hydrogen = tonumber(v2)
							elseif (k2 == "Case13") then planet.name = tostring(v2) --Get Name
							elseif (k2 == "Case15") then planet.colorid = tostring(v2)
							elseif (k2 == "Case16") then planet.bloomid = tostring(v2) end
						end
						
						if planet.atm == 0 then
							planet.atm = 1
						end
						
						planet.position = ent:GetPos()
						
						i=i+1
						table.insert(planets, planet)
						print("//     Spacebuild 3 Planet Added   //")
					elseif value == "star" then
						planet.typeof = "sphere"
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) end --Get Gravity
						end
						
						planet.position = ent:GetPos()
						
						planet.temperature = 10000
						planet.solaractivity = "med"
						planet.baseradiation = "1000"
						
						i=i+1	
						table.insert(stars, planet)
						print("//     Spacebuild 2 Star Added     //")
					elseif value == "star2" then
						planet.typeof = "sphere"
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) --Get Gravity
							elseif (k2 == "Case06") then planet.name = tostring(v2) end
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
			end
		end
		planets.version = Environments.FileVersion
		file.Write( "environments/" .. map .. "_stars.txt", util.TableToKeyValues( table.Sanitise(stars) ) )
		file.Write( "environments/" .. map .. ".txt", util.TableToKeyValues( table.Sanitise(planets) ) )
	end
	planets.version = nil
	
	for k,v in pairs(planets) do
		Environments.CreateEnvironment(v)
	end
	for k,v in pairs(stars) do
		Environments.CreateStarEnv(v)
	end
	
	local numberofplanets = table.Count( environments ) or 0
	if numberofplanets > 0 then
		UseEnvironments = true
	end
	
	--Add the file for the client to download so they can access its info
	--resource.AddFile("environments/" .. map .. ".txt")
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
end

function Environments.Hooks.NoClip( ply, on )
	--if ply:GetMoveType() == MOVETYPE_FLY then ply:SetMoveType(MOVETYPE_WALK) return false end --allow them to get out of jetpack
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
		
		if ply.environment.air.o2per >= 9.5 /*and ply.environment.temperature > 270 and ply.environment.temperature <= 310*/ then --if can breathe
			return true
		else
			return false
		end
	--end
end

function Environments.Log(text)
	local old = file.Read("env_log.txt")
	if old then
		file.Write("env_log.txt", old .. "\n" .. tostring(os.date("%m/%d/%y")).." - "..tostring(os.date("%H:%M:%S")) .. "; " .. text)
	else
		file.Write("env_log.txt", tostring(os.date("%m/%d/%y")).." - "..tostring(os.date("%H:%M:%S")) .. "; " .. text)
	end
end

local function Logging( ply )
	logrecs1 = {}
	--logrecs2 = {}
	for logrecs in (file.Read("env_log.txt") or ""):gmatch("[^\n\r]+") do
		table.insert(logrecs1,logrecs)
	end
	/*for logrecs in (file.Read("env_log.txt") or ""):gmatch("[^\n\r]+") do
		table.insert(logrecs2,logrecs)
	end*/
	datastream.StreamToClients(ply,"sendEnvLogs",{logrecs1})
end
concommand.Add("env_get_logs", Logging)

local SFX = {}
function RegisterWorldSFXEntity(ent, planet)
	SFX[ent:EntIndex()] = ent
	SFX[ent:EntIndex()].planet = planet
end

local function SFXManager()
	if not SFX then return end
	for k,v in pairs(SFX) do
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

function Environments.SendInfo(ply)
	for _, v in pairs( environments ) do
		umsg.Start( "AddPlanet", ply );
			umsg.Short( v:EntIndex() )
			umsg.Vector( v:GetPos() );
			umsg.Short( v.radius );
			if v.colorid then
				umsg.String( v.colorid );
			end
			if v.bloomid then
				umsg.String( v.bloomid );
			end
		umsg.End();
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
end

local function Reload(ply,cmd,args)
	if not ply:IsAdmin() then return end
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Delete()
			v = nil
		else
			v = nil
		end
	end
	Environments.RegisterEnvironments()
	Environments.Log("Planets Reloaded")
	ply:ChatPrint("Environments Has Been Reset!")
end
concommand.Add("env_server_reload", Reload)
