------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local util = util
local ents = ents
local table = table
local os = os
local math = math
local GetWorldEntity = GetWorldEntity
local Vector = Vector
local print = print
local MsgAll = MsgAll
local pcall = pcall
local pairs = pairs

function table.Random(t) --darn you garry
	local rk = math.random(1,table.Count(t))
	local i = 1
	for k,v in pairs(t) do
		if i == rk then return v, k end
		i = i + 1
	end
end

//prototype events system
local events = {}
events["meteorstorm"] = function(planet)
	local roids = ents.Create("event_asteroid_storm")
	roids:SetPos(planet.position + Vector(0, 0, planet.radius + 2000))
	roids:Spawn()
	roids:Start(planet.radius)
	return "Meteor Storm"
end
events["meteor"] = function(planet)
	local roid = ents.Create("event_meteor")
	roid:SetPos(GetBestPath(roid, planet))
	roid:Spawn()
	roid:Start(planet)
	return "Meteor Strike"
end
events["earthquake"] = function(planet)
	util.ScreenShake(planet:GetPos(), 14, 255, 6, planet.radius)
	return "Earthquake"
end
/*events["micrometeorite"] = function(planet)
	local AttackVector = Vector(math.random(-9999,9999),math.random(-9999,9999),math.random(-9999,9999)):Normalize()
	
	local basepoint = ents.Create("prop_dynamic") --since we can't do IsInWorld on a vector we'll make a marker; Spawn once, use may times.
	basepoint:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	basepoint:SetPos(Vector(0,0,0))
	basepoint:Spawn()
	
	local trA = nil --localize now so we can access later
	local trB = nil
	
	--for i=1, swarms do
		local useA = false
		while true do
			while true do
				basepoint:SetPos(Vector(math.random(-65530,65530),math.random(-65530,65530),math.random(-65530,65530)))
				if basepoint:IsInWorld() then
					break
				end
			end	
			trA = util.QuickTrace(basepoint:GetPos(),basepoint:GetPos()+(AttackVector*99999999))
			trB = util.QuickTrace(basepoint:GetPos(),basepoint:GetPos()+(AttackVector*-99999999))
			if trA.HitSky or trB.HitSky then
				if trA.HitSky then
					useA = true
				end
				break
			end
		end
		local bullet = {}
		bullet.Num 			= math.random(5,10)
		if not useA then
			bullet.Src		= trA.HitPos
		else
			bullet.Src		= trB.HitPos
		end
		bullet.Dir 			= AttackVector
		bullet.Spread 		= Vector(0.5,0.5,0.5)
		bullet.Tracer		= 1
		bullet.TracerName 	= "AirboatGunHeavyTracer"
		bullet.Force		= 200
		bullet.Damage		= math.random(10,50)
		bullet.Attacker 	= GetWorldEntity()
		basepoint:FireBullets(bullet)
	--end
	basepoint:Remove()
	return "Micro Meteorite Storm"
end*/
--timer.Create("storms", 10, 0, events["micrometeorite"])

local function FireEvent(ply,cmd,args)
	if not ply:IsAdmin() then return end
	if ply.environment.name != "space" then
		if events[args[1]] then
			events[args[1]](ply.environment)
			Environments.Log(ply:Nick().." Called in a "..args[1].." Event")
		else
			ply:ChatPrint("You tried to call in an invalid event!")
		end
	else
		ply:ChatPrint("You can't call in a "..args[1].." in space!")
	end
end
concommand.Add("env_fire_event", FireEvent)

function Environments.EventChecker()
	local chance = math.random(1,50)
	if chance < 35 and chance > 30 then
		//call the function to run the event
		local planet = table.Random(environments)
		local event, eventname = table.Random(events)
		if not planet.spawn == "1" then
			event(planet)
		else
			planet = table.Random(environments)
			if not planet.spawn == "1" then
				event(planet)
			end
		end	
		MsgN("A " .. (eventname or "invalid event name") .. " Started at " .. tostring(os.date("%H:%M:%S")).." on planet ".. (planet.name or "Unnamed Planet"))
	end
end

function Environments.SpecialEvents()
	local count = #(ents.FindByClass("gas_cloud") or {})
	if count < 10 then
		local notfinished = true
		local rep = 0
		while notfinished do
			rep = rep + 1
			local a = VectorRand()*16384
			if util.IsInWorld(a) then --add check to make sure they arent in something
				if !Environments.FindEnvironmentOnPos(a) then
					local cloud = ents.Create("gas_cloud")
					cloud:SetPos(a)
					cloud:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
					cloud:Spawn()
					cloud:SetResource("hydrogen")
					cloud:SetAmount(10000)
					return
				end
			end
			if rep > 15 then
				notfinished = false
				print("find pos failed, continuing")
			end
		end
	end
end

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
timer.Create("EnvEventsClean", 54, 0, Cleanup)

local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "event_meteor" or Ent:GetClass() == "event_asteroid" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "NOPHYSGUNNINGMETEORS!", physgunPickup )