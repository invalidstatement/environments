------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

//prototype events system
local events = {}
events["asteroidstorm"] = function()
	local planet = table.Random(environments)
	if planet.spawn == "1" then
		planet = table.Random(environments)
		if planet.spawn == "0" then
			local roids = ents.Create("event_asteroid_storm")
			roids:SetPos(planet.position + Vector(0, 0, planet.radius + 2000))
			roids:Spawn()
			roids:Start(planet.radius)
		end
	else
		local roids = ents.Create("event_asteroid_storm")
		roids:SetPos(planet.position + Vector(0, 0, planet.radius + 2000))
		roids:Spawn()
		roids:Start(planet.radius)
	end
end

local function FireEvent(ply,cmd,args)
	if not ply:IsAdmin() then return end
	events[args[1]]()
end
concommand.Add("env_fire_event", FireEvent)

local function EventChecker()
	
	if math.random(1,5) == 3 then
		print("Event Running")
		//call the function to run the event
		table.Random(events)()
	end
end
timer.Create("EnvEvents", 10, 1, EventChecker)

local function Cleanup()
	for k,v in pairs(ents.FindByClass("event_asteroid")) do
		v:Remove()
	end
end
timer.Create("EnvEventsClean", 30, 1, Cleanup)