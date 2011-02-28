------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local mapdata = {} --stores map info

//prototype events system
local events = {}
events["asteroidstorm"] = function(planet)
	local roids = ents.Create("event_asteroid_storm")
	roids:SetPos(planet.position + Vector(0, 0, planet.radius + 2000))
	roids:Spawn()
	roids:Start(planet.radius)
end
events["meteor"] = function(planet)
	local roid = ents.Create("event_meteor")
	roid:SetPos(GetBestPath(roid, planet))
	roid:Spawn()
	roid:Start(planet)
end

local function FireEvent(ply,cmd,args)
	if not ply:IsAdmin() then return end
	if ply.environment.name != "space" then
		events[args[1]](ply.environment)
	else
		ply:ChatPrint("You can't call in a "..args[1].." in space!")
	end
end
concommand.Add("env_fire_event", FireEvent)

local function EventChecker()
	if math.random(1,5) == 3 then
		print("Event Running")
		//call the function to run the event
		local planet = table.Random(environments)
		if not planet.spawn == "1" then
			table.Random(events)(planet)
		else
			planet = table.Random(environments)
			if not planet.spawn == "1" then
				table.Random(events)(planet)
			end
		end	
	end
end
timer.Create("EnvEvents", 10, 1, EventChecker)

function GetBestPath(ent, planet) --try for the best, most spectacular asteroid path
	--for now, lets just go with the top of the map
	local pos = Vector(0, 0, 32000)
	
	local tracedata = {}
	tracedata.start = planet.position
	tracedata.endpos = pos
	tracedata.filter = ent
	tracedata.mins = ent:OBBMins()
	tracedata.maxs = ent:OBBMaxs()
	tracedata.mask = MASK_NPCWORLDSTATIC
	 
	local trace = util.TraceHull( tracedata )
	if trace.HitWorld then
		if not trace.HitSky then
			return planet.position + Vector(0, 2000, planet.radius + 2000)
		else
			return trace.HitPos
		end
	else
		return trace.HitPos
	end
end

local function Cleanup()
	for k,v in pairs(ents.FindByClass("event_asteroid")) do
		v:Remove()
	end
end
timer.Create("EnvEventsClean", 30, 1, Cleanup)

local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "event_meteor" or Ent:GetClass() == "event_asteroid" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "NOPHYSGUNNINGMETEORS!", physgunPickup )