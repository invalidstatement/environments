------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
//IDEA!!!!!!!
//Load the text file from the server to get planet info instead of usmgs :D
planets = {} --Planetary Data Table :D updated from server usermessages
stars = {} --Star data table updated from server usmg

SRP = {}
SRP.environment = {}

//This is the planet the client is currently on, used for effects and such
planet = 0

--Attempt to load the planets table from the file from the server.
planets = util.KeyValuesToTable("environments/" .. game.GetMap() .. ".txt")
if planets == nil or {} then
	print("ERROR, planets file not downloaded")
else
	PrintTable(planets) --Did it work?
end

local function EnvironmentCheck() --Whoah! What planet I am on?!
	local location -- this goes with the if statement
	local ply = LocalPlayer()
	if not (ply and ply:IsValid() and ply:Alive()) then return end
	local plypos = ply:LocalToWorld( Vector(0,0,0) )
	--if planets[1] == nil then return end
	for k, p in pairs( planets ) do
		local ppos = Vector(planets[k].position.x, planets[k].position.y, planets[k].position.z)
		if plypos:Distance(ppos) < p.radius then
			location = p.name --this goes with the if statement
			
			//Record the name of the planet
			planet = p.name
			
			//Put planet values in the environment table
			SRP.environment = p.atmosphere
			SRP.environment.pressure = p.pressure
			SRP.environment.temperature = p.temperature
			
			return
		end
	end
	if location == nil then --Do I need this If statement?
		planet = "space"
		SRP.environment = Space()
	end
end
--timer.Create("EnvironmentCheck", 0.5, 0, EnvironmentCheck )

function Space()
	local hash = {}
	hash.oxygen = 0
	hash.carbondioxide = 0
	hash.pressure = 0
	hash.temperature = 60
	
	return hash
end
--------------------------------------------------------
--              Environments Usermessages             --
--------------------------------------------------------

//OLD FUNCTION, MAY NEED REMOVAL IF REPLACED BY .TXT FILE
local function AddPlanet(msg) --adds the planets to the table
	local planet = {}
	planet.position = {}
	
	planet.index = msg:ReadShort() --get planet index
	local position = msg:ReadVector() --get planet position
	planet.radius = msg:ReadFloat() --get planet radius
	planet.name = msg:ReadString() --get planet name
	
	planet.position.x = position.x
	planet.position.y = position.y
	planet.position.z = position.z
	
	print("msg recieved, planet added")
	print(util.TableToKeyValues(planet))
	table.insert(planets, planet)
end
usermessage.Hook( "AddPlanet", AddPlanet )

local function RecieveStar(msg) --recieves the sun position
	local star = {}
	star.position = {}
	
	star.index = msg:ReadShort() --get star index
	local position = msg:ReadVector() --get star position
	star.radius = msg:ReadFloat() --get star radius
	--star.name = msg:ReadString() --get star name
	
	star.position.x = position.x
	star.position.y = position.y
	star.position.z = position.z
	
	print("Star Added")
	print(util.TableToKeyValues(star))
	table.insert(stars, star)
end
usermessage.Hook( "AddStar", RecieveStar )
