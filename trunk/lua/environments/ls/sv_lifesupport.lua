------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
--BUGS
--1. ply.suit.air , coolant, energy, ect is all used by LS too, try and fix the variable clash

////////////////////////////////////////////////////
//  LS So Far.....                                //
////////////////////////////////////////////////////
// ply.suit table...                              //
//    air and maxair -- self explanitory          //
//    coolant and maxcoolant -- self explanitory  //
//    energy and maxenergy -- self explanitory    //
////////////////////////////////////////////////////
// LS Equipment Types....                         //
//    airtank: Stores the suit's air              //
//    battery: Stores the suit's energy           //
//    coolanttank: Stores the suit's coolant      //
////////////////////////////////////////////////////
// Meta Functions....                             //
////////////////////////////////////////////////////
// player:ResetSuit()                             //
//    sets the player's suit to normal values     //
// player:FillSuit(air, energy, coolant)          //
//    fills the players suit with the amounts of  //
//    resources inputed                           //
// player:SetupLSGear(type, args...)              //
//    sets up the players LS equipment values     //
////////////////////////////////////////////////////

function SRP.InitLS()
	timer.Create("LSCheck", 1, 0, LSCheck) --rename function later
	print("//   LifeSupport Checker Started   //")
end

function SRP.CreateLS(ply)--When a player joins
	ply.suit = {}
	ply.suit.params = {}
	local hash = {}
	hash.air = 200 --100
	hash.energy = 200 --100
	hash.coolant = 200 --100
	hash.temperature = 288
	ply.suit = hash
end

/*function Space()
	local hash = {}
	hash.air = {}
	hash.oxygen = 0
	hash.carbondioxide = 0
	hash.pressure = 0
	hash.temperature = 2.75
	hash.air.o2per = 0
	
	return hash
end*/

//basic working LS

//vars
//ply.suit.temp = suit temperature
//Does the environmental check for each player
/*function LSCheck()
	for _, ply in pairs(player.GetAll()) do
		if not ply:Alive() or not ply:IsValid() then return end
		local airused = true
		local env = ply.environment
		local suit = ply.suit
		local temperature = env.temperature
		if ply:GetNWBool("inspace") == true then
			env = Space()
		else
			temperature = SunCheck(ply)
		end
		if ply.suit.worn then
			if env == nil or env == {} then --is the env already prechecked to be ok or is it nil?
				print("ERROR: Player "..ply:Nick().."'s Environment Is Set To Nil!")
				return false
			else
				//Do air check
				if env.air.o2per < 10 or ply:WaterLevel() > 2 then
					if suit.air > 0 then
						suit.air = suit.air - 10
					else
						airused = false
					end
				end
				//Do temperature check
				if temperature >= 300 then
					local amt = math.ceil((temperature - 300)/16)
					if temperature >= 1000 then
						ply:TakeDamage(50)
					end
					if amt < 5 then
						amt = 5
					end
					if suit.coolant > 0 then
						suit.coolant = suit.coolant - amt
					else
						airused = false
					end
				elseif temperature <= 280 then
					local amt = math.ceil((280 - temperature)/16)
					if amt < 5 then
						amt = 5
					end
					if suit.energy > 0 then
						suit.energy = suit.energy - amt
					else
						airused = false
					end
				end
				if airused then--player is all fine and dandy
					
				else --ply cant survive
					ply:TakeDamage(10)
				end
				UpdateLS(ply, temperature)
			end
		else//player is not wearing suit
			//you cant survive in a vacuum :P
			--if ply:GetNWBool("inspace") == true then
				--ply:TakeDamage(20)
			--end
			//do stuff differently :D
		end
	end
end*/

//prototype suit environment ls
local efficiency = 0.02 --the insulating efficiency of the suit, how fast the suit gains or loses temperature
function LSCheck()
	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() and ply:IsValid() then return end
		local env = ply.environment
		local suit = ply.suit
		local temperature = env.temperature
		local airused = true
		
		if ply:GetNWBool("inspace") == true then
			env = Space()
		else
			temperature = SunCheck(ply)
		end
		
		//Temperature Stuff
		//Conduction
		local tempchange = 0
		if suit.temperature > env.temperature then
			tempchange = (suit.temperature - env.temperature) * efficiency
			suit.temperature = suit.temperature - tempchange
		elseif suit.temperature < env.temperature then
			tempchange = (env.temperature - suit.temperature) * efficiency
			suit.temperature = suit.temperature + tempchange
		end
		
		//Resource Usage
		if suit.temperature > 310 then --is it above the comfortable range?
			local needed = math.abs(tempchange)*5
			if needed < 5 then
				needed = 5
			end
			
			if suit.energy >= needed then
				suit.coolant = suit.coolant - needed
				suit.temperature = suit.temperature - tempchange
				if suit.temperature + tempchange > 310 then
					suit.temperature = 310
				elseif suit.temperature - tempchange < 284 then
					suit.temperature = 284
				end
			elseif suit.coolant > 0 then
				local per = suit.coolant/needed
				suit.coolant = 0
				suit.temperature = suit.temperature - (tempchange * per)
			end
		elseif suit.temperature < 284 then --is it below the comfortable range?
			local needed = math.abs(tempchange)*5
			if needed < 5 then
				needed = 5
			end
			
			if suit.energy >= needed then
				suit.energy = suit.energy - needed
				suit.temperature = suit.temperature + tempchange
				if suit.temperature + tempchange > 310 then
					suit.temperature = 310
				elseif suit.temperature - tempchange < 284 then
					suit.temperature = 284
				end
			elseif suit.energy > 0 then
				local per = suit.energy/needed
				suit.energy = 0
				suit.temperature = suit.temperature + (tempchange * per)
			end
		end
		
		//check if damage needs to be done
		if suit.temperature > 320 then
			airused = false
		elseif suit.temperature < 250 then
			airused = false
		end
		
		//Air Stuff
		if env.air.o2per < 10 or ply:WaterLevel() > 2 then
			if suit.air > 0 then
				suit.air = suit.air - 5
			else
				airused = false
			end
		end
		
		//Damage Stuff
		if airused then--player is all fine and dandy
	
		else --ply cant survive
			ply:TakeDamage(10)
		end
		UpdateLS(ply, temperature)
	end
end

function SunCheck(ent)
	local lit = false
	if table.Count(stars) > 0 then
		for k,v in pairs(stars) do
			local trace = {}
			trace.start = ent:GetPos()
			trace.filter = ent
			trace.endpos = v.position
			local tr = util.TraceLine( trace )
			if (tr.Hit) then
				local distance = tr.HitPos:Distance(v.position)
				if distance <= v.radius then
					lit = true
				else
					lit = false
				end
			else
				lit = true
			end
		end
	else --No stars on map
		local trace = {}
		trace.start = ent:GetPos()
		trace.filter = ent
		trace.endpos = ent:GetPos() + Vector(0,0,2000)
		local tr = util.TraceLine( trace )
		lit = not tr.Hit
	end
	if lit then
		if ent.environment.temperature2 then
			return ent.environment.suntemperature + (( ent.environment.suntemperature * ((ent.environment.firstenvironment.air.co2per - ent.environment.air.co2per)/100))/2)
		end
	end
	if not ent.environment.temperature then
		return 0
	end
	return ent.environment.temperature + (( ent.environment.temperature * ((ent.environment.firstenvironment.air.co2per - ent.environment.air.co2per)/100))/2)
end

--------------------------------------------------------
--              Life Support Meta Tables              --
--------------------------------------------------------
local meta = FindMetaTable("Player")

function meta:ResetSuit() --Resets a player's suit
	local hash = self.suit
	hash.air = 2000 --200
	hash.energy = 2000 --200
	hash.coolant = 2000 --200
	hash.temperature = 288
	hash.worn = true
	self.suit = hash
end

function meta:FillSuit(air, energy, coolant)
	self.suit.air = self.suit.air + air
	self.suit.energy = self.suit.energy + energy
	self.suit.coolant = self.suit.coolant + coolant
end


--------------------------------------------------------
--              Life Support Concommands              --
--------------------------------------------------------
local function RefillLS(ply, cmd, args)
	ply:ResetSuit()
end
concommand.Add("Refill", RefillLS)

local function ToggleSuit(ply, cmd, args)
	if ply.suit.worn then
		ply.suit.worn = false
		ply:SetModel(ply.model)
	else
		ply.suit.worn = true
		ply.model = ply:GetModel()
		ply:SetModel("models/SBEP Player Models/orangehevsuit.mdl")
	end
end
concommand.Add("ToggleSuit", ToggleSuit)


--------------------------------------------------------
--              Life Support Usermessages             --
--------------------------------------------------------
function UpdateLS(ply, temp)
	umsg.Start("LSUpdate", ply)
		umsg.Short(ply.suit.air)
		umsg.Short(ply.suit.coolant)
		umsg.Short(ply.suit.energy)
		umsg.Short(temp)
		umsg.Short(ply.environment.air.o2per)
		umsg.Short(ply.suit.temperature)
	umsg.End()
end

--------------------------------------------------------
--                  Life Support Hooks                --
--------------------------------------------------------
function Spawn(ply)
	SRP.CreateLS(ply)
end
hook.Add("PlayerInitialSpawn","CreateLS", Spawn)

local function lsspawn(ply)
	timer.Create("ResetSuit"..ply:Nick(), 1, 1, function() ply:ResetSuit() end)
	--ply:SetModel("models/SBEP Player Models/orangehevsuit.mdl")
end
hook.Add("PlayerSpawn", "SpawnLS", lsspawn)
