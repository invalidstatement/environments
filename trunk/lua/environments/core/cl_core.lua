------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
planets = {} --Planetary Data Table :D updated from server usermessages
stars = {} --Star data table updated from server usmg

SRP = {}

//This is the planet the client is currently on, used for effects and such
planet = 0

SRP.suit = {}
SRP.suit.air = 0
SRP.suit.coolant = 0
SRP.suit.energy = 0
SRP.suit.o2per = 0

//Create the VGUI
topbar = vgui.Create( "LS Debug Bar" )
topbar:SetVisible( true )
LoadHud()

//Load it depending on the server setup
if CAF and CAF.GetAddon("Spacebuild") then --sb installed
	print("Spacebuild is active on the server")
		
else --No sb installed
	--Attempt to load the planets table from the file from the server.
	local data = file.Read("environments/"..game.GetMap()..".txt")
	if data then
		planets = table.DeSanitise(util.KeyValuesToTable(data))
	end
end

local function EnvironmentCheck() --Whoah! What planet I am on?!
	local location -- this goes with the if statement
	local ply = LocalPlayer()
	if not (ply and ply:IsValid() and ply:Alive()) then return end
	local plypos = ply:LocalToWorld( Vector(0,0,0) )
	--if planets[1] == nil then return end
	for k, p in pairs( planets ) do
		if plypos:Distance(planets[k].position) < p.radius then
			//Record the name of the planet
			planet = p.name
			
			return
		end
	end
	planet = "space"
end
--timer.Create("EnvironmentCheck", 1, 0, EnvironmentCheck )

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

local function LSUpdate(msg) --recieves life support update packet
	local hash = {}
	hash.air = msg:ReadShort() --Get air left in suit
	hash.coolant = msg:ReadShort() --Get coolant left in suit
	hash.energy = msg:ReadShort() --Get energy left in suit
	SRP.suit = hash
	SRP.suit.temperature = msg:ReadShort() --Get energy left in suit
	SRP.suit.o2per = msg:ReadFloat()
	SRP.suit.temp = msg:ReadShort()
end
usermessage.Hook( "LSUpdate", LSUpdate )

//Borrowed from SB, gotta have reverse compatibility
local function PlanetUmsg( msg )
	local ent = msg:ReadShort()
	local hash  = {}
	hash.ent = ents.GetByIndex(ent)
	hash.name = msg:ReadString()
	hash.position = msg:ReadVector()
	hash.radius = msg:ReadFloat()
	if msg:ReadBool() then
		hash.color = true
		hash.AddColor_r = msg:ReadShort()
		hash.AddColor_g = msg:ReadShort()
		hash.AddColor_b = msg:ReadShort()
		hash.MulColor_r = msg:ReadShort()		
		hash.MulColor_g = msg:ReadShort()
		hash.MulColor_b = msg:ReadShort()
		hash.Brightness = msg:ReadFloat()
		hash.Contrast = msg:ReadFloat()
		hash.CColor = msg:ReadFloat()
	else
		hash.color = false
	end
	if msg:ReadBool() then
		hash.bloom = true
		hash.Col_r = msg:ReadShort()
		hash.Col_g = msg:ReadShort()
		hash.Col_b = msg:ReadShort()
		hash.SizeX = msg:ReadFloat()
		hash.SizeY = msg:ReadFloat()
		hash.Passes = msg:ReadFloat()
		hash.Darken = msg:ReadFloat()
		hash.Multiply = msg:ReadFloat()
		hash.BColor = msg:ReadFloat()
	else
		hash.bloom = false
	end
	planets[ent] = hash
end
usermessage.Hook( "AddPlanet", PlanetUmsg )
	
local function StarUmsg( msg )
	local ent = msg:ReadShort()
	local tmpname = msg:ReadString()
	local position = msg:ReadVector()
	local radius = msg:ReadFloat()
	stars[ ent] = {
		Ent = ents.GetByIndex(ent),
		name = tmpname,
		Position = position,
		Radius = radius, // * 2
		BeamRadius = radius * 1.5, //*3
	}
end
usermessage.Hook( "AddStar", StarUmsg )

