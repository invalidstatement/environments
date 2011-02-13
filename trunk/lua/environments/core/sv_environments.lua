------------------------------------------
//   Environments  //
//   CmdrMatthew   //
------------------------------------------

SRP = {}
UseEnvironments = false
PlayerGravity = true


environments = {}
stars = {}

--Remove and put in seperate file later
default = {}
default.atmosphere = {}
default.atmosphere.oxygen = 30
default.atmosphere.carbondioxide = 5
default.atmosphere.methane = 0
default.atmosphere.nitrogen = 40
default.atmosphere.hydrogen = 22
default.atmosphere.argon = 0
--default.atmosphere.helium = 1
--default.atmosphere.ammonia = 1

//LS3 Compatability
/*if not CAF then
	CAF = {}
	print("Caf not loaded yet")
end*/
timer.Create("registerCAFOverwrites", 5, 1, function()
	local old = CAF.GetAddon
	local SB = {}
	function CAF.GetAddon(name)
		if name == "Spacebuild" then
			return SB
		elseif name == "Life Support" then
			return LS
		end
		return old(name)
	end
	function SB.GetStatus()
		return true
	end

	local LS = {}
	function LS.GetStatus()
		return true
	end
end)
//End LS3

local function LoadEnvironments()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	--Get All Planets Loaded
	RegisterEnvironments() 
	if UseEnvironments then --It is a spacebuild map
		hook.Add("PlayerNoClip","EnvNoClip", NoClip)
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
		--Register all things related to the sun
		local status, error = pcall(RegisterSun)
		if error then
			print("//   Registering Sun Failed :(     //")
			print("ERROR: "..error)
			TrueSun = {}
			TrueSun[1] = Vector(0,0,0)
		end
		print("// Starting Periodicals..          //")
		--Start all things running on timers
		timer.Create("LSCheck", 1, 0, LSCheck) --rename function later
		print("//   LifeSupport Checker Started   //")
	else --Not a spacebuild map
		print("//   This is not a valid SB map    //")
	end
	print("/////////////////////////////////////")
	print("//       Environments Loaded       //")
	print("/////////////////////////////////////")
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function RegisterEnvironments()
	local planets = {}
	local i = 0
	local map = game.GetMap()
	print("//   Attempting to Load From File  //")
	
	if file.Exists( "environments/" .. map ..".txt" ) then
		local contents = file.Read( "environments/" .. map .. ".txt" )
		local starscontents = file.Read( "environments/" .. map .. "_stars.txt")
		if contents then
			planets = table.DeSanitise(util.KeyValuesToTable(contents))
			stars = table.DeSanitise(util.KeyValuesToTable(starscontents))
			print("//     " .. table.Count(planets) .. " Planets Loaded From File  //")
			print("//     " .. table.Count(stars) .. " Stars Loaded From File    //")
		else
			print("//    ERROR: File has no content        //")
		end
	else 
		print("//	Warning: No File Found, Creating From Defaults")
		local entities = ents.FindByClass( "logic_case" )
		for k,ent in pairs(entities) do
			local values = ent:GetKeyValues()
			for key, value in pairs(values) do
				if key == "Case01" then
					local planet = {}
					planet.position = {}
					if value == "cube" then
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
						
						i=i+1
						planet.name = i

						table.insert(planets, planet)
						print("//	  New Spacebuild Cube Planet Added")
					elseif value == "planet" then
						planet.typeof = "sphere"
						
						--Add Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						planet.noclip = 0
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) --Get Gravity
							elseif (k2 == "Case04") then planet.atm = tonumber(v2)
							elseif (k2 == "Case05") then planet.temperature = tonumber(v2)
							elseif (k2 == "Case06") then planet.suntemperature = tonumber(v2)
							elseif (k2 == "Case16") then planet.flags = tonumber(v2) end
						end
						
						planet.position = ent:GetPos()
						
						i=i+1
						planet.name = i
						
						local planet = CreateSB2Environment(planet)
						table.insert(planets, planet)
						print("//	  Spacebuild 2 Planet Added //")
					elseif value == "planet2" then
						planet.typeof = "sphere"
						
						--Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						planet.noclip = 0
						
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
						
						planet.position = ent:GetPos()
						
						i=i+1
						table.insert(planets, planet)
						print("//	  Spacebuild 3 Planet Added //")
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
						print("//	  New Spacebuild 2 Star Added")
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
						print("//	  New Spacebuild 3 Star Added")
					end
				end 
			end
		end
		file.Write( "environments/" .. map .. "_stars.txt", util.TableToKeyValues( table.Sanitise(stars) ) )
		file.Write( "environments/" .. map .. ".txt", util.TableToKeyValues( table.Sanitise(planets) ) )
	end
	
	for k,v in pairs(planets) do
		CreateEnvironment(v)
	end
	for k,v in pairs(stars) do
		CreateStarEnv(v)
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

function RegisterSun()
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

local function NoClip( ply, on )
	// Don't allow if player is in vehicle
	--if ( ply:InVehicle() ) then return false end
	// Always allow in single player
	--if ( SinglePlayer() ) then return true end
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
			v:SetKeyValue("BaseSpread", 300)
			v:SetKeyValue("rendercolor", "0 0 0")
			v:Fire("JetLength", 1000)
			v:Fire("Rate", 400)
		end
	end
end
timer.Create("SFXCHECKER", 10, 0, SFXManager)


local function PrintPlanets()
	local ent = ents.FindByClass( "logic_case" )
	for k,v in pairs(ent) do
		local values = v:GetKeyValues()
		PrintTable(values)
		print("/n")
	end
end
concommand.Add("srp_print", PrintPlanets)

--------------------------------------------------------
--              Environments Usermessages             --
--------------------------------------------------------
function SendPlanet(index, ply)
	umsg.Start("AddPlanet", ply)
		umsg.Short( index ) --env number
		local position = Vector(planets[index].position.x, planets[index].position.y, planets[index].position.z)
		umsg.Vector( position ) --env position
		umsg.Float( planets[index].radius ) --env radius
		umsg.String( planets[index].name ) --env name
	umsg.End()
	--print("umsg: Index:" .. tostring(index) .. " position: (" .. tostring(position) .. ") radius: " .. tostring(planets[index].radius) .. " name: " .. tostring(planets[index].name))
end

function SendStar(index, ply)
	umsg.Start("AddStar", ply)
		umsg.Short( index ) --env number
		umsg.Vector( stars[index].position ) --env position
		umsg.Float( stars[index].radius ) --env radius
		--umsg.String( planets[index].name ) --env name
	umsg.End()
	--print("umsg: Index:" .. tostring(index) .. " position: (" .. tostring(position) .. ") radius: " .. tostring(planets[index].radius) .. " name: " .. tostring(planets[index].name))
end

