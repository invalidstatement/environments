------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------

SRP = {}
UseEnvironments = true
UseSimpleSpace = false
PlayerGravity = true

//
environments = {}
stars = {}

--Remove and put in seperate file later
default = {}
default.atmosphere = {}
default.atmosphere.oxygen = 30
default.atmosphere.carbondioxide = 5
default.atmosphere.methane = 1
default.atmosphere.nitrogen = 40
default.atmosphere.hydrogen = 22
default.atmosphere.helium = 1
default.atmosphere.ammonia = 1

function Space()
	local hash = {}
	hash.air = {}
	hash.oxygen = 0
	hash.carbondioxide = 0
	hash.pressure = 0
	hash.temperature = 60
	hash.air.o2per = 0
	
	return hash
end

local function NoClip( ply, on )
	// Don't allow if player is in vehicle
	if ( ply:InVehicle() ) then return false end
	// Always allow in single player
	if ( SinglePlayer() ) then return true end
	// Check based on the player's environment
	if ply:GetNWBool("inspace") and server_settings.Bool("srp_noclip") then
		if not (ply:IsAdmin() or ply:IsSuperAdmin()) and server_settings.Bool("srp_adminspacenoclip" ) then
			if not ply:IsSuperAdmin() and server_settings.Bool("srp_superadminspacenoclip") then
				if server_settings.Bool( "srp_planetnocliponly") then
					return false
				end
			end
		end
	end
	return true
end
hook.Add("PlayerNoClip","EnvNoClip", NoClip)

local function LoadEnvironments()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	--Get All Planets Loaded
	RegisterEnvironments() 
	print("// Registering Sun..               //")
	--Register all things related to the sun
	RegisterSun()
	print("// Starting Periodicals..          //")
	--Start all things running on timers
	timer.Create("GravityCheck", 1, 0, CheckGravity )
	print("//   Environment Checker Started   //")
	if UseLS then
		--Start Life Support like Functions
		SRP.InitLS()
		--timer.Create("RadiationCheck", 0.5, 0, RadiationCheck)
		--print("//   Radiation Checker Started     //")
	end
	print("/////////////////////////////////////")
	print("//       Environments Loaded       //")
	print("/////////////////////////////////////")
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function RegisterEnvironments()
	local hash = {}
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
						planet.atmosphere = default.atmosphere
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						
						i=i+1
						planet.name = i

						table.insert(hash, planet)
						print("//	  New Spacebuild Cube Planet Added")
					elseif value == "planet" then
						planet.typeof = "sphere"
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

						i=i+1
						planet.name = i
		
						table.insert(hash, planet)
						print("//	  New Spacebuild 2 Planet Added")
					elseif value == "planet2" then
						planet.typeof = "sphere"
						
						--Defaults
						planet.atmosphere = {}
						planet.atmosphere = table.Copy(default.atmosphere)
						planet.unstable = "false"
						planet.temperature = 288
						planet.pressure = 1
						
						for k2,v2 in pairs(values) do
							if (k2 == "Case02") then planet.radius = tonumber(v2) --Get Radius
							elseif (k2 == "Case03") then planet.gravity = tonumber(v2) --Get Gravity
							elseif (k2 == "Case04") then planet.tmosphere = tonumber(v2) --What does this mean?
							elseif (k2 == "Case05") then planet.pressure = tonumber(v2)
							elseif (k2 == "Case06") then planet.temperature = tonumber(v2)
							elseif (k2 == "Case09") then planet.atmosphere.oxygen = tonumber(v2)
							elseif (k2 == "Case10") then planet.atmosphere.carbondioxide = tonumber(v2)
							elseif (k2 == "Case11") then planet.atmosphere.nitrogen = tonumber(v2)
							elseif (k2 == "Case12") then planet.atmosphere.hydrogen = tonumber(v2)
							elseif (k2 == "Case13") then planet.name = tostring(v2) end --Get Name
						end
						
						planet.position = ent:GetPos()
						
						i=i+1
						table.insert(hash, planet)
						print("//	  New Spacebuild 3 Planet Added")
					elseif value == "insert cool name here" then
						table.insert(hash, planet)
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
						
						planet.temperature = 10000
						planet.solaractivity = "med"
						planet.baseradiation = "1000"

						i=i+1
						table.insert(stars, planet)
						print("//	  New Spacebuild 3 Star Added")
					elseif value == "insert cool star name here" then
						table.insert(stars, planet)
					end
				end 
			end
		end
		planets = hash
		file.Write( "environments/" .. map .. "_stars.txt", util.TableToKeyValues( table.Sanitise(stars) ) )
		file.Write( "environments/" .. map .. ".txt", util.TableToKeyValues( table.Sanitise(hash) ) )
	end
	local numberofplanets = table.Count( planets ) or 0
	if numberofplanets > 0 then
		UseEnvironments = true
	end
	
	for k,v in pairs(planets) do
		CreateEnvironment(v)
	end
	
	--Add the file for the client to download so they can access its info
	resource.AddFile("environments/" .. map .. ".txt")
end

function RegisterSun()
	if table.Count(stars) > 0 then
		--set as core radiation source, and sun angle(needed for solar planels) and other sun effects
		--local suneffect ents.Create("sun_effects")
		--suneffect:SetPos(stars[1].position)
		--suneffect:Configure(stars[1].radius, stars[1].intensity)
		print("//   Sun Registered                //")
	else
		print("//   No Stars Found                //")
	end
end

local someents = {}
function CheckSpaceEnts()
	for _, e in pairs( ents.GetAll() ) do
		if( e:GetPhysicsObject():IsValid() and !e:IsWorld() and !e:IsWeapon() and e:GetTable() != nil and UseEnvironments ) then
			if( !e:GetTable().sgravity ) then
				if( e:IsPlayer() ) then
					if( PlayerGravity ) then
						e:SetGravity( 0.000000001 )
					end
					/*if( CanNoclipInSpace ) then
						if( AdminOnlyNoclip and !e:IsAdmin() ) then
							e:SetMoveType( MOVETYPE_WALK )
						end
					else
						e:SetMoveType( MOVETYPE_WALK )
					end*/
					e:SetNWBool( "inspace", true )
					e.environment = Space()
				else
					e:GetPhysicsObject():EnableDrag( false )
					e:GetPhysicsObject():EnableGravity( false )
				end
			end
			e:GetTable().sgravity = false
		end
	end
end

function CheckGravity()
	if UseEnvironments then
		for _, p in pairs( environments ) do
			if p.typeof == "sphere" then
				someents = ents.FindInSphere( p.position , p.radius )
			end
			if p.typeof == "cube" then
				someents = ents.FindInBox( Vector( p.radius, p.radius, p.radius ) - p.position, p.position + Vector( p.radius, p.radius, p.radius ) )
			end
			for _, e in pairs( someents ) do
				if( e:GetPhysicsObject():IsValid() and !e:IsWorld() and !e:IsWeapon() ) then
					e:SetGravity( p.gravity )
					e:GetPhysicsObject():EnableDrag( true )
					e:GetPhysicsObject():EnableGravity( true )
					e:GetTable().sgravity = true
					if( e:IsPlayer() ) then
						e:SetNWBool( "inspace", false )
						e.environment = p
					end
				end
			end
		end
		CheckSpaceEnts()
	end
end

local function PrintPlanets()
	local ent = ents.FindByClass( "logic_case" )
	for k,v in pairs(ent) do
		local values = v:GetKeyValues()
		PrintTable(values)
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

