------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local planets = {} --Planetary Data Table :D updated from server usermessages
local stars = {} --Star data table updated from server usmg
local blooms = {}
local colors = {}

//This is the planet the client is currently on, used for effects and such
planet = nil

Environments.suit = {}
Environments.suit.air = 0
Environments.suit.coolant = 0
Environments.suit.energy = 0
Environments.suit.o2per = 0

//Load it depending on the server setup
if CAF and CAF.GetAddon("Spacebuild") then --sb installed
	print("Spacebuild is active on the server")
else --No sb installed
	LoadHud()
	hook.Add("PlayerNoClip", "EnvPredict", NoclipPredict)
end

function NoclipPredict(ply)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
	if ply:IsAdmin() then return true end
	
	if ply:GetNWBool("inspace") then
		return false
	end
	return true
end


local function EnvironmentCheck() --Whoah! What planet I am on?!
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	--if planets[1] == nil then return end
	for k, p in pairs( planets ) do
		if ply:GetPos():Distance(p.position) <= p.radius then
			//Record the name of the planet
			planet = p
			return
		end
	end
	planet = nil --space
end
timer.Create("EnvironmentCheck", 1, 0, EnvironmentCheck )

local function RenderEffects()
	if !LocalPlayer():Alive() then return end
	if not planet then return end
	if not Environments.EffectsCvar:GetBool() then return end

	local blom = blooms[planet.bloomid]
	local color = colors[planet.colorid]
	
	if color then
		local cmod = { }
		cmod["$pp_colour_addr"] = color.addcol.x
		cmod["$pp_colour_addg"] = color.addcol.y
		cmod["$pp_colour_addb"] = color.addcol.z
		cmod["$pp_colour_brightness"] = color.brightness
		cmod["$pp_colour_contrast"] = color.contrast
		cmod["$pp_colour_colour"] = color.color
		cmod["$pp_colour_mulr"] = color.mulcol.x
		cmod["$pp_colour_mulg"] = color.mulcol.y
		cmod["$pp_colour_mulb"] = color.mulcol.z
		DrawColorModify( cmod )
	end
	
	if blom then
		DrawBloom( blom.darken, blom.multiply, blom.x, blom.y, blom.passes, blom.colormul, blom.color.x, blom.color.y, blom.color.z );
	end
end
hook.Add("RenderScreenspaceEffects","EnvironmentsRenderPlanetEffects", RenderEffects) 

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
	Environments.suit = hash
	Environments.suit.temperature = msg:ReadFloat()
	Environments.suit.o2per = msg:ReadFloat()
	Environments.suit.temp = msg:ReadFloat()
	NeedUpdate = true
end
usermessage.Hook( "LSUpdate", LSUpdate )

//Spacebuild Compatibility :D
local function LS_umsg_hook1( um )
	Environments.suit.o2per = um:ReadFloat()
	Environments.suit.air = um:ReadShort()
	Environments.suit.temperature = um:ReadShort()
	Environments.suit.coolant = um:ReadShort()
	Environments.suit.energy = um:ReadShort()
end
--usermessage.Hook("LS_umsg1", LS_umsg_hook1) 

local function PlanetUmsg( msg )
	local ent = msg:ReadShort()
	local hash  = {}
	hash.ent = ents.GetByIndex(ent)
	hash.position = msg:ReadVector()
	hash.radius = msg:ReadShort()
	hash.name = msg:ReadString()
	hash.colorid = msg:ReadString()
	hash.bloomid = msg:ReadString()
	
	planets[ent] = hash
	--print("Recieved Planet: ".. hash.colorid)
end
usermessage.Hook( "AddPlanet", PlanetUmsg )

local function PlanetColor(msg)
	local hash = {}
	hash.addcol = msg:ReadVector()
		
	hash.mulcol = msg:ReadVector()
		
	hash.brightness = msg:ReadFloat()
	hash.contrast = msg:ReadFloat()
	hash.color = msg:ReadFloat()
	hash.ID = msg:ReadString()
	colors[hash.ID] = hash
	--print("Recieved Color: ".. hash.ID)
end
usermessage.Hook("PlanetColor", PlanetColor)

local function PlanetBloom(msg)
	local hash = {}
	
	hash.color = msg:ReadVector()

	hash.x = msg:ReadFloat()
	hash.y = msg:ReadFloat()
		
	hash.passes = msg:ReadFloat()
	hash.darken = msg:ReadFloat()
	hash.multiply = msg:ReadFloat()
	hash.colormul = msg:ReadFloat()
	hash.ID = msg:ReadString()
	blooms[hash.ID] = hash
	--print("Recieved Bloom: ".. hash.ID)
end
usermessage.Hook("PlanetBloom", PlanetBloom)

local function ZeroGravRagdoll( msg )
	local ply = msg:ReadEntity();
	timer.Create("ZGR", 0.1, 1, ZGR, ply)
end
usermessage.Hook( "ZGRagdoll", ZeroGravRagdoll );

function ZGR(ply)
	local ent = ply:GetRagdollEntity();
	
	if( ent and ent:IsValid() ) then
		for i = 0, ent:GetPhysicsObjectCount() do	
			local phys = ent:GetPhysicsObjectNum( i );
			if( phys and phys:IsValid() ) then
				phys:EnableGravity( false )
			end
		end
	end
end

local function OnEntityCreated( e )
	if( e == LocalPlayer() ) then
		timer.Simple( 0, function()
			RunConsoleCommand( "ragdoll_sleepaftertime", "9999.9" )
		end )
	end
end
hook.Add("OnEntityCreated", "Ragdoll checker", OnEntityCreated)

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
--usermessage.Hook( "AddStar", StarUmsg )

