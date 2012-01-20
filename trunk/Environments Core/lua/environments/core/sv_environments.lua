------------------------------------------
//   Environments  //
//   CmdrMatthew   //
------------------------------------------

--localize
--loser xD http://steamcommunity.com/id/AlauraLoveless/
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
local type = type
local pairs = pairs
local Angle = Angle
local Vector = Vector
local SysTime = SysTime

//Custom Locals
local Environments = Environments

UseEnvironments = false

local EnvironmentDebugCount = 0 --used to check if a planet is missing

local AllowNoClip = CreateConVar( "env_noclip", "0", FCVAR_NOTIFY )

//Table of all Environments
environments = {}
stars = {}

//Planet Default Atmospheres
default = {}
default.atmosphere = {}
default.atmosphere.o2 = 30
default.atmosphere.co2 = 5
default.atmosphere.ch4 = 0
default.atmosphere.n = 50
default.atmosphere.h = 15
default.atmosphere.ar = 0

//add a new Environments "Lite" mode that only checks players and stuff in a method similar to SB3, should be able to be turned on and off at will
//USE THIS TO MAKE SURE THE PLAYER'S EVN IS A VALID ONE
local meta = {} 
local function NewEnvironment(ent) --new metatable based environments, should have fewer problems than entities alone
	local tab = {}
	
	
	setmetatable(tab, meta)
end

function Environments.ShutDown() --wip, add a new system for hook creation, a table filled with the hooks that gets created at startup, or destroyed at shutdown
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
	
	//Remove Hooks
	hook.Remove("PlayerNoClip","EnvNoClip")
	hook.Remove("PlayerInitialSpawn","CreateLS")
	hook.Remove("PlayerInitialSpawn","CreateEnvironemtns")
	hook.Remove("PlayerSpawn", "SpawnLS")
	--hook.Remove("ShowTeam", "HelmetToggle") probably dont need to remove
	hook.Remove("PlayerDeath", "ZgRagdoll")
end

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
			if self:IsWeapon() then return end
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
		timer.Create("EnvSpecial", 10, 0, Environments.SpecialEvents)
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
			} )
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
			} )
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
			v.total = v.air.total
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
		EnvironmentDebugCount = table.Count(environments)
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
	Stars = {}
	for k,v in pairs(rawstars) do
		local star = Environments.ParseStar(v)
		Environments.CreateStar(star)
		table.insert(stars, star)
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
			planet.atmosphere.o2 = tonumber(tab.Case09)
			planet.atmosphere.co2 = tonumber(tab.Case10)
			planet.atmosphere.n = tonumber(tab.Case11)
			planet.atmosphere.h = tonumber(tab.Case12)
			planet.name = tostring(tab.Case13) --Get Name
			planet.colorid = tostring(tab.Case15)
			planet.bloomid = tostring(tab.Case16)
			
			planet.originalco2per = planet.atmosphere.co2
			
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
		else --not a normal ent

		end
	end
	planets.version = Environments.FileVersion
	//Environments.PlanetSaveData = {}
	//Environments.PlanetSaveData = planets
	
	return planets, stars
end

function Environments.SaveMap() --plz work :)
	local map = game.GetMap()
	local planets = {}
	for k,v in pairs(environments) do
		if !v:IsValid() then continue end
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
			--planet.atmosphere = table.Copy(v.air) --need to get only percentage values
			planet.atmosphere.o2 = v.air.o2per
			planet.atmosphere.co2 = v.air.co2per
			planet.atmosphere.h = v.air.hper
			planet.atmosphere.n = v.air.nper
			planet.atmosphere.ar = v.air.arper
			planet.atmosphere.ch4 = v.air.ch4per
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
space.radius = 0

function space:UpdateGravity(ent)
	ent:SetGravity( 0 )
	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableDrag( false )
		phys:EnableGravity( false )
	end
	if( ent:IsPlayer() ) then
		ent:SetNWBool( "inspace", false )
	end
end

function space.UpdatePressure()

end

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
			print("//   Star Registered               //")
		else
			local suns = ents.FindByClass("env_sun")
			for k,ent in pairs(suns) do
				if ent:IsValid() then
					local values = ent:GetKeyValues()
					if values.target and string.len(values.target) > 0 then
						local targets = ents.FindByName( "sun_target" )
						for _, target in pairs( targets ) do
							SunAngle = (target:GetPos() - ent:GetPos()):Normalize()
							print("target found: ".. tostring(target))
							break //Sunangle set, all that was needed
						end
					end
					
					if !SunAngle then //Sun angle still not set, but sun found
						local ang = ent:GetAngles()
						ang.p = ang.p - 180
						ang.y = ang.y - 180
						--get within acceptable angle values no matter what...
						ang.p = math.NormalizeAngle( ang.p )
						ang.y = math.NormalizeAngle( ang.y )
						ang.r = math.NormalizeAngle( ang.r )
						SunAngle = ang:Forward()
					end
					break
                end
			end
			
			if SunAngle then
				print("//   Registered Env_Sun Entity     //")
			else
				print("//   No Stars Found, Defaulting    //")
				TrueSun = {}
				TrueSun[1] = Vector(0,0,10000)
			end
		end
	end)

	if error then
		print("Star Register Error: "..error)
		print("//   No Stars Found, Defaulting      //")
		TrueSun = {}
		TrueSun[1] = Vector(0,0,0)
	end
end

function Environments.GetSunFraction(entpos, up)//wip
	local trace = {}
	local lit = false
	local SunAngle2 = SunAngle or Vector(0, 0 ,1)
	local SunAngle = nil
	if TrueSun and table.Count(TrueSun) > 0 then
		local output = 0
		for k,SUN_POS in pairs(TrueSun) do
				--[[SunAngle = (entpos - v)
				SunAngle:Normalize()
				local startpos = (entpos - (SunAngle * 4096))
				trace.start = startpos
				trace.endpos = entpos //+ Vector(0,0,30)
				local tr = util.TraceLine( trace )
				if (tr.Hit) then
					if (tr.Entity == self) then
						self:TurnOn()
						self:Extract_Energy()
						return
					end
				else
					self:TurnOn()
					self:Extract_Energy()
					return
				end]]
			trace = util.QuickTrace(SUN_POS, entpos-SUN_POS, nil)
			if trace.Hit then 
				if trace.Entity == self then
					local v = (up or Vector(0,0,1)) + trace.HitNormal
					local n = v.x*v.y*v.z
					print("truesun hit")
					if n > 0 then
						output = output + n
						--solar panel produces energy
					end
				else
					local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
					output = output + n
					print("not hit self truesun")
					--solar panel is being blocked
				end
			end
			if output >= 1 then
				break
			end
		end
		if output > 1 then 
			output = 1
		end
		if output > 0 then
			return output
		end
	end
	local SUN_POS = (entpos - (SunAngle2 * 4096))
		--[[trace.start = startpos
		trace.endpos = entpos //+ Vector(0,0,30)
		local tr = util.TraceLine( trace )
		if (tr.Hit) then
			if (tr.Entity == self) then
				self:TurnOn()
				self:Extract_Energy(1)
				return
			end
		else
			self:TurnOn()
			self:Extract_Energy()
			return
		end]]
	trace = util.QuickTrace(SUN_POS, entpos-SUN_POS, nil)
	if trace.Hit then 
		if trace.Entity == self then
			local v = (up or Vector(0,0,1)) + trace.HitNormal
			local n = v.x*v.y*v.z
			print("sunpos hit")
			if n > 0 then
				return n
			end
		else
			local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
			if n > 0 then
				print("not hit sunpos")
				return n
			end
			--solar panel is being blocked
		end
	end
end

local function yay(ply, cmd, args)//temporary
	print(Environments.GetSunFraction(ply:GetPos(), ply:GetUp()))
end
concommand.Add("env_suncheck", yay)

function Environments.Hooks.NoClip( ply, on )
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
	if planet or !Environments.SFX[ent:EntIndex()] then//dont overwrite other values unless there is a planet found for the entity
		Environments.SFX[ent:EntIndex()] = {}
		Environments.SFX[ent:EntIndex()].entity = ent
		Environments.SFX[ent:EntIndex()].planet = planet
	end
end

local CompatibleEntities = {"func_precipitation", "env_smokestack", "func_dustcloud", "func_smokevolume"}
local function FindSFXEntities()
	for k, v in pairs(ents.GetAll()) do
		if table.HasValue(CompatibleEntities, v:GetClass()) then
			RegisterWorldSFXEntity(v, nil)
		end
	end
end
hook.Add("InitPostEntity", "findSFX", FindSFXEntities)

local function SFXManager()
	if not Environments.SFX then return end
	for k,v in pairs(Environments.SFX) do
		local ent = v.entity
		local class = string.lower(ent:GetClass())
		if class == "func_precipitation" then

		elseif class == "func_dustcloud" then
			--ent:Fire("TurnOff")
		elseif class == "env_smokestack" then
			--ent:SetKeyValue("BaseSpread", 300)
			--ent:SetKeyValue("rendercolor", "0 0 0")
			--ent:Fire("JetLength", 1000)
			--ent:Fire("Rate", 400)
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

function Environments.FindEnvironmentOnPos(pos)
	for k,v in pairs(environments) do
		if pos:Distance(v:GetPos()) <= v.radius then
			return v
		end
	end
	return nil
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
	ply:ChatPrint("Environments Has Been Reloaded From Map!")
end
concommand.Add("env_server_full_reload", ComReload)

local function SendPlanetData(ply, cmd, args)
	if ply:IsAdmin() then
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
end
concommand.Add("request_planet_data", SendPlanetData)

local function PrintData(ply, cmd, args)
	local self = ply.environment
	if !self then return end
	Msg("ID is: ", self.name, "\n")
	Msg("Dumping stats:\n")
	Msg("------------ START DUMP ------------\n")
	PrintTable(self.OldData)
	Msg("------------- END DUMP -------------\n\n")
end
concommand.Add("print_planet", PrintData)

local function PlanetCheck()
	local original = EnvironmentDebugCount
	local num = 0
	for k,v in pairs(environments) do
		if v:IsValid() then
			num = num + 1
		end
	end
	if num < original then --planet missing
		MsgAll("Environments: Planet Discrepancy Detected, Reloading!")
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
	end
end
timer.Create("ThinkCheckPlanetIssues", 1, 0, PlanetCheck)


