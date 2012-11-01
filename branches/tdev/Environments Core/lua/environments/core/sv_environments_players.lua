------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

--localize
local math = math
local player = player
local util = util
local umsg = umsg
local table = table
local timer = timer
local pcall = pcall
local pairs = pairs

//Custom Locals
local Space = Space
local Environments = Environments

local efficiency = 0.02 --the insulating efficiency of the suit, how fast the suit gains or loses temperature
function Environments.LSCheck() --this has to be the worst function ever
	if CAF then
		local RD = CAF.GetAddon("Resource Distribution") --I dont want to depend on this being there :(
	else
		local RD = nil
	end
	for k, ply in pairs(player.GetAll()) do
		local status, error = pcall(function() --starts the error checker
		if not ply:Alive() or not ply:IsValid() then return end --not if dead
		
		if ply:GetNWBool("inspace") == true then --make sure space is correct
			ply.environment = Space()	--why am I doing this? perhaps get rid of NWBool?
		end
		if ply.GetScriptedVehicle and ply:GetScriptedVehicle() and ply:GetScriptedVehicle():IsValid() then --if in vehicle
			ply.environment = ply:GetScriptedVehicle().environment
		elseif ply:GetVehicle() and ply:GetVehicle():IsValid() then
			ply.environment = ply:GetVehicle().environment
		end
		
		if ply.GHDed then
			Environments.BackupCheck(ply) --ghd crap
		end
		
		Environments.PlayerCheck(ply) --check LS Cores, and grav plating
		
		local env = ply.environment
		
		if not env then return end
		
		local suit = ply.suit
		local airused = true
		local temperature = env.temperature
		
		if ply:GetNWBool("inspace") == false then
			temperature = Environments.SunCheck(ply) --check for suntemp
		end
		
		if not env.pressure then --double check
			env.pressure = 1
		end
		
		local realo2 = env.air.o2per*env.pressure --relative o2 percent
		if ply.suit.worn and ply.suit.helmet then
			local pod = ply:GetParent()
			//Temperature Stuff
			//Conduction
			local tempchange = 0
			if temperature < 1500 then
				if suit.temperature > temperature then
					tempchange = (suit.temperature - temperature) * efficiency
					suit.temperature = suit.temperature - tempchange
				elseif suit.temperature < temperature then
					tempchange = (temperature - suit.temperature) * efficiency
					suit.temperature = suit.temperature + tempchange
				end
			else
				ply:TakeDamage(100)
			end
			
			//Resource Usage
			if suit.temperature > 310 then --is it above the comfortable range?
				local needed = tempchange*5
				
				if needed < 5 then
					needed = 5
				elseif needed > 20 then
					needed = 20
				end	
				
				if pod and pod:IsValid() and RD and RD.GetResourceAmount(pod, "water") >= needed then
					RD.ConsumeResource(pod, "water", needed)
					suit.temperature = suit.temperature - tempchange
					if suit.temperature + tempchange > 310 then
						suit.temperature = 310
					elseif suit.temperature - tempchange < 284 then
						suit.temperature = 284
					end
				elseif pod and pod:IsValid() and pod.Link and pod.node and pod:GetResourceAmount("water") >= needed then
					pod:ConsumeResource("water", needed)
					suit.temperature = suit.temperature - tempchange
					if suit.temperature + tempchange > 310 then
						suit.temperature = 310
					elseif suit.temperature - tempchange < 284 then
						suit.temperature = 284
					end
				else
					if suit.coolant >= needed then
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
				end
			elseif suit.temperature < 284 then --is it below the comfortable range?
				local needed = tempchange*5
				if needed < 5 then
					needed = 5
				elseif needed > 20 then
					needed = 20
				end
			
				if pod and pod:IsValid() and RD and RD.GetResourceAmount(pod, "energy") >= needed then
					RD.ConsumeResource(pod, "energy", needed)
					suit.temperature = suit.temperature + tempchange
					if suit.temperature + tempchange > 310 then
						suit.temperature = 310
					elseif suit.temperature - tempchange < 284 then
						suit.temperature = 284
					end
				elseif pod and pod:IsValid() and pod.Link and pod.node and pod:GetResourceAmount("energy") >= needed then
					pod:ConsumeResource("energy", needed)
					suit.temperature = suit.temperature + tempchange
					if suit.temperature + tempchange > 310 then
						suit.temperature = 310
					elseif suit.temperature - tempchange < 284 then
						suit.temperature = 284
					end
				else
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
			end
			
			//check if damage needs to be done
			if suit.temperature > 320 then
				airused = false
			elseif suit.temperature < 250 then
				airused = false
			end

			//Air Stuff
			if realo2 < 10 or ply:WaterLevel() > 2 then
				if pod and pod:IsValid() and RD and RD.GetResourceAmount(pod, "oxygen") >= 5 then
					RD.ConsumeResource(pod, "oxygen", 5)
				elseif pod and pod:IsValid() and pod.Link and pod.node and pod:GetResourceAmount("oxygen") >= 5 then
					pod:ConsumeResource("oxygen", 5)
				else
					if suit.air >= 5 then
						suit.air = suit.air - 5
					elseif suit.air > 0 then
						suit.air = 0
					else
						airused = false
					end
				end
			end
			
			//Damage Stuff
			if airused then--player is all fine and dandy
		
			else --ply cant survive
				ply:TakeDamage(10)
				ply.suit.recover = ply.suit.recover + 10
			end
			
			//Recovery
			if ply.suit.temperature >= 284 and ply.suit.temperature <= 310 and airused and ply.suit.recover > 0 then
				if ((ply:Health() + 5 )>= 100) then
					ply:SetHealth(100)
					ply.suit.recover = 0
				else
					ply:SetHealth(ply:Health() + 5)
					ply.suit.recover = ply.suit.recover - 5
				end
			end
		else --player is not wearing their suit or helmet
			local tempchange = 0 

			if temperature < 1500 then
				if suit.temperature > temperature then
					tempchange = (suit.temperature - temperature) * 0.05
					suit.temperature = suit.temperature - tempchange
				elseif suit.temperature < temperature then
					tempchange = (temperature - suit.temperature) * 0.05
					suit.temperature = suit.temperature + tempchange
				end
			else
				ply:TakeDamage(100)
			end
			
			if temperature > 320 then
				--do burn damage
				if temperature > 400 then
					ply:TakeDamage(10)
					ply.suit.recover = ply.suit.recover + 10
				else
					ply:TakeDamage(5)
					ply.suit.recover = ply.suit.recover + 5
				end
			elseif temperature < 250 then
				--do cold damage
				ply:TakeDamage(5)
				ply.suit.recover = ply.suit.recover + 5
			end
			
			if realo2 < 10 or ply:WaterLevel() > 2 then
				airused = false
			end
			
			//Damage Stuff
			if airused then--player is all fine and dandy
		
			else --ply cant survive add breath here later
				ply:TakeDamage(5)
				ply.suit.recover = ply.suit.recover + 5
			end
			
			//Recovery
			if temperature >= 284 and temperature <= 310 and airused and ply.suit.recover > 0 then
				if ((ply:Health() + 5 )>= 100) then
					ply:SetHealth(100)
					ply.suit.recover = 0
				else
					ply:SetHealth(ply:Health() + 5)
					ply.suit.recover = ply.suit.recover - 5
				end
			end
		end
		
		Environments.UpdateLS(ply, temperature) end) --ends the error checker
		
		if error then
			--Environments.Log("Player Think Error: "..error) --lets not do that anymore.
			MsgAll("Environments Player Think Error: "..error.."\n")
		end
	end
end

function Environments.SunCheck(ent)
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
		if ent.environment.sunburn then
			if ent:Health() > 0 then
				ent:TakeDamage( 5, 0 )
				ent:EmitSound( "HL2Player.BurnPain" )
			end
		end
		
		if ent.environment.suntemperature then
			return ent.environment.suntemperature + ((ent.environment.suntemperature * (((ent.environment.air.co2/ent.environment.air.max)*100 - ent.environment.originalco2per)/100))/2)
		end
	end
	if not ent.environment.temperature then
		return 0
	end
	if ent.environment.originalco2per and ent.environment.air.co2 then
		return ent.environment.temperature + ((ent.environment.temperature * (((ent.environment.air.co2/ent.environment.air.max)*100 - ent.environment.originalco2per)/100))/2)
	else 
		return ent.environment.temperature
	end
end

function Environments.PlayerCheck(ent) --fix with parenting >:(
	--if not ent:GetNWBool("inspace") then return end
	local phys = ent:GetPhysicsObject()
	local veh = ent:GetVehicle()
	
	if ent:GetNWBool("inspace") then
		if !ent:IsAdmin() then
			ent:SetMoveType( MOVETYPE_WALK )
		end
	end
	
	local trace = {}
	local pos = ent:GetPos()
	trace.start = pos
	trace.endpos = pos - Vector(0,0,512)
	trace.filter = { ent, veh }
	
	local tr = util.TraceLine( trace )
	
	if tr.Hit and tr.Entity:IsValid() then
		trace = {}
		trace.start = pos
		trace.endpos = pos + Vector(0,0,512)
		trace.filter = { ent, veh }
	
		local tr2 = util.TraceLine( trace )

		if tr2.Entity.env and tr.Entity.env and tr.Entity.env.IsValid and tr.Entity.env:IsValid() then
			if tr.Entity.env.Active == 1 then
				ent.environment = tr.Entity.env
				tr.Entity.env:Breathe()
				ent.gravity = 1
				ent:SetGravity(tr.Entity.env.gravity)
				if phys:IsValid() then
					phys:EnableGravity( true )
					phys:EnableDrag( true )
				end
				
				return
			elseif tr.Entity.env.air.o2per > 0 then
				ent.environment = tr.Entity.env
				ent:SetGravity(0.00001)
				tr.Entity.env:Breathe()
				ent.gravity = 1
				if phys:IsValid() then
					phys:EnableGravity( false )
					phys:EnableDrag( true )
				end
				return
			end
		elseif (tr.Entity.grav_plate and tr.Entity.grav_plate == 1) then
			ent:SetGravity(1)
			ent.gravity = 1
			if phys:IsValid() then
				phys:EnableGravity( true )
				phys:EnableDrag( true )
			end
			return
		end
	end
	if ent.gravity and ent.gravity == 0 then 
		return 
	end
	if ent:GetNWBool("inspace") then
		if !ent.GHDed then
			phys:EnableGravity( false )
			phys:EnableDrag( false )
			ent:SetGravity(0.00001)
			ent.gravity = 0
			ent.environment = Space()
		end
	end
end


--------------------------------------------------------
--              Life Support Meta Tables              --
--------------------------------------------------------
local meta = FindMetaTable("Player")

function meta:ResetSuit() --Resets a player's suit
	local hash = self.suit or {}
	hash.air = 200 --200
	hash.energy = 200 --200
	hash.coolant = 200 --200
	hash.temperature = 288
	hash.worn = true
	hash.helmet = true
	hash.recover = 0
	self.suit = hash
	--self:SetHealth(self:GetHealth())
end

function meta:FillSuit(air, energy, coolant)
	self.suit.air = self.suit.air + air
	self.suit.energy = self.suit.energy + energy
	self.suit.coolant = self.suit.coolant + coolant
end

--------------------------------------------------------
--              Life Support Concommands              --
--------------------------------------------------------
local function ToggleSuit(ply, cmd, args)
	if ply.suit.worn then
		ply:TakeOffSuit()
		ply:TakeOffHelmet()
		ply.suit.worn = false
		ply.suit.helmet = false
	else
		ply:PutOnSuit()
		ply:PutOnHelmet()
		ply.suit.worn = true
		ply.suit.helmet = true
	end
end
concommand.Add("ToggleSuit", ToggleSuit)

local function ToggleHelmet(ply, cmd, args)
	if ply.suit.worn == false then return end
	if ply.suit.helmet then
		ply:TakeOffHelmet()
		ply.suit.helmet = false
	else
		ply:PutOnHelmet()
		ply.suit.helmet = true
	end
end
concommand.Add("ToggleHelmet", ToggleHelmet)

--------------------------------------------------------
--              Life Support Usermessages             --
--------------------------------------------------------
function Environments.UpdateLS(ply, temp)
	umsg.Start("LSUpdate", ply)
		umsg.Short(ply.suit.air)
		umsg.Short(ply.suit.coolant)
		umsg.Short(ply.suit.energy)
		umsg.Float(temp)
		umsg.Float(ply.environment.air.o2per)
		umsg.Float(ply.suit.temperature)
	umsg.End()
end

--------------------------------------------------------
--                  Life Support Hooks                --
--------------------------------------------------------
function Environments.Hooks.LSInitSpawn(ply)
	ply.suit = {}
	ply.suit.params = {}
	local hash = {}
	hash.air = 200 --100
	hash.energy = 200 --100
	hash.coolant = 200 --100
	hash.temperature = 288
	hash.recover = 0
	ply.suit = hash
	
	umsg.Start("Environments", ply)
		umsg.Short(Environments.Version)
	umsg.End()
end

function Environments.Hooks.PlayerDeath( ply, inf, killer )
	if ply.environment then
		if ply.environment.name == "space" then
			umsg.Start( "ZGRagdoll" )
				umsg.Entity( ply )
			umsg.End()
		end
	end
end

function Environments.Hooks.LSInitSpawnDry(ply) --for when its not a space map
	ply.suit = {}
	ply.suit.params = {}
	local hash = {}
	hash.air = 200 --100
	hash.energy = 200 --100
	hash.coolant = 200 --100
	hash.temperature = 288
	hash.recover = 0
	ply.suit = hash
	
	ply.environment = {}
	ply.environment.temperature = 288
	ply.environment.air = {}
	ply.environment.air.o2per = 20
	ply.environment.pressure = 1
	
	//INIT THEM!
	umsg.Start("Environments", ply)
		umsg.Short(Environments.Version)
	umsg.End()
end

function Environments.Hooks.LSSpawn(ply)
	if not ply.msged then
		ply:ChatPrint("This server is running Environments, please report any bugs to CmdrMatthew")
		ply.msged = true
	end
	local temp = function() ply:ResetSuit() end
	timer.Simple(1, temp)
end

function Environments.Hooks.HelmetSwitch( ply )
	local status, error = pcall(function() 
	if !ply.m_hSuit or !ply.m_hSuit.GetParent or !ply.m_hSuit:GetParent().GetInfo then return end
	if Environments.UseSuit then
		if ply.suit.helmet then
			--ply:TakeOffSuit()
			ply:TakeOffHelmet()
			--ply.suit.worn = false
			ply.suit.helmet = false
			ply:ChatPrint("You took off your helmet.")
		else
			--ply:PutOnSuit()
			ply:PutOnHelmet()
			--ply.suit.worn = true
			ply.suit.helmet = true
			ply:ChatPrint("You put on your helmet.")
		end
	else
		if ply.suit.helmet then
			ply:SetNWBool("helmet", false)
			ply.suit.helmet = false
			ply:ChatPrint("You took off your helmet.")
		else
			ply:SetNWBool("helmet", true)
			ply.suit.helmet = true
			ply:ChatPrint("You put on your helmet.")
		end
	end end)
	if error then
		Environments.Log("Helmet Error: "..error)
	end
end

function Environments.BackupCheck(ent)
	for k,v in pairs(environments) do
		local distance = v:GetPos():Distance(ent:GetPos())
		if distance <= v.radius then
			if v.gravity == 0 then
				ent:SetGravity(0.000001)
			else
				ent:SetGravity(v.gravity)
			end
			
			ent.environment = v
			return
		end
	end
	ent.environment = Space()
end

local function EnterShip(ent,ship,ghost,oldpos,oldang)
	if ent:IsPlayer() then
		ent.GHDed = true
	end
end
hook.Add("EnterShip", "EnvironmentsGHDFix", EnterShip)

local function ExitShip(ent,ship,ghost,oldpos,oldang)
	if ent:IsPlayer() then
		ent.GHDed = false
	end
end
hook.Add("ExitShip", "EnvironmentsGHDFix", ExitShip)