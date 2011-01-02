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
	ply.suit = hash
end

function Space()
	local hash = {}
	hash.air = {}
	hash.oxygen = 0
	hash.carbondioxide = 0
	hash.pressure = 0
	hash.temperature = 2.75
	hash.air.o2per = 0
	
	return hash
end

//Does the environmental check for each player
function LSCheck()
	for _, ply in pairs(player.GetAll()) do
		if not ply:Alive() or not ply:IsValid() then return end
		local airused = true
		local env = ply.environment
		local suit = ply.suit
		if ply:GetNWBool("inspace") == true then
			env = Space()
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
				if env.temperature >= 300 then
					if env.temperature >= 1000 then
						ply:TakeDamage(50)
					end
					
					if suit.coolant > 0 then
						suit.coolant = suit.coolant - 10
					else
						airused = false
					end
				elseif env.temperature <= 268 then
					if suit.energy > 0 then
						suit.energy = suit.energy - 10
					else
						airused = false
					end
				end
				if airused then--player is all fine and dandy
					
				else --ply cant survive
					ply:TakeDamage(10)
				end
				UpdateLS(ply)
			end
		else//player is not wearing suit
			//you cant survive in a vacuum :P
			--if ply:GetNWBool("inspace") == true then
				--ply:TakeDamage(20)
			--end
			//do stuff differently :D
		end
	end
end


--------------------------------------------------------
--              Life Support Meta Tables              --
--------------------------------------------------------
local meta = FindMetaTable("Player")

function meta:ResetSuit() --Resets a player's suit
	local hash = self.suit
	hash.air = 200 --100
	hash.energy = 200 --100
	hash.coolant = 200 --100
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
function UpdateLS(ply)
	local u = ply:UniqueID()
	umsg.Start("LSUpdate", ply)
		umsg.Short(ply.suit.air)
		umsg.Short(ply.suit.coolant)
		umsg.Short(ply.suit.energy)
		umsg.Short(ply.environment.temperature)
		umsg.Short(ply.environment.air.o2per)
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
	ply:ResetSuit()
	--ply:SetModel("models/SBEP Player Models/orangehevsuit.mdl")
end
hook.Add("PlayerSpawn", "SpawnLS", lsspawn)
