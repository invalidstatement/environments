------------------------------------------
//   Environments  //
//   CmdrMatthew   //
------------------------------------------
SRP = {} --Backup Compatability from when this was gonna be a gamemode
UseEnvironments = false

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
//End LS3

local function LoadEnvironments()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	--Get All Planets Loaded
	Environments.RegisterEnvironments() 
	if UseEnvironments then --It is a spacebuild map
		//Add Hooks
		hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
		hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawn)
		hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
		hook.Add("ShowTeam", "HelmetToggle", Environments.Hooks.HelmetSwitch)
		hook.Add("PlayerInitialSpawn", "PlayerSetSuit", Environments.Hooks.SuitInitialSpawn)
		hook.Add("PlayerDeath", "PlayerRemoveSuit", Environments.Hooks.SuitPlayerDeath)
		hook.Add("PlayerSpawn", "PlayerSetSuit", Environments.Hooks.SuitPlayerSpawn)
		
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
		timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		print("//   LifeSupport Checker Started   //")
	else --Not a spacebuild map
		print("//   This is not a valid space map //")
	end
	print("/////////////////////////////////////")
	print("//       Environments Loaded       //")
	print("/////////////////////////////////////")
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function Environments.RegisterEnvironments()
	local planets = {}
	local i = 0
	local map = game.GetMap()
	
	if file.Exists( "environments/" .. map ..".txt" ) then
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
		local entities = ents.FindByClass( "logic_case" )
		for k,ent in pairs(entities) do
			local values = ent:GetKeyValues()
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
							elseif (k2 == "Case13") then planet.name = tostring(v2) end --Get Name
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
	resource.AddFile("environments/" .. map .. ".txt")
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
	// Check based on the player's environment
	if not ply.environment then return false end
	if ply.environment.noclip == "1" or ply.environment.noclip == 1 then
		return true
	else
		if not ply:IsAdmin() then
			return false
		end
	end
end

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
	Environments.RegisterEnvironments()
	ply:ChatPrint("Environments Has Been Reset!")
end
concommand.Add("env_server_reload", Reload)
