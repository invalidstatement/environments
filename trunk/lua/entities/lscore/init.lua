------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "common/warning.wav" )

include("shared.lua")
AddCSLuaFile("shared.lua")
	
function ENT:SpawnFunction(ply, tr) -- Spawn function needed to make it appear on the spawn menu
	local ent = ents.Create("lscore") -- Create the entity
	ent:SetPos(tr.HitPos + Vector(0, 0, 50) ) -- Set it to spawn 50 units over the spot you aim at when spawning it
	ent:Spawn() -- Spawn it
 
	return ent -- You need to return the entity to make it work
end
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetModel( "models/SBEP_community/d12airscrubber.mdl" ) --setup stuff
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.gravity = 1
	self.Debugging = false
	self.Active = 0
	self.env = {}
	
	self.energy = 0
	self.coolant = 0
	self.coolant2 = 0
	
	self.mino2 = 10.5

	self.air = {}
	self.air.o2per = 0
	self.air.o2 = 0
	
	local phys = self.Entity:GetPhysicsObject() --reset physics
	if (phys:IsValid()) then
		phys:Wake()
	end
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(self)
	self.Entities = {}
	
	self:AddResource("energy", 0)
	self:AddResource("water", 0)
	self:AddResource("nitrogen", 0)
	self:AddResource("oxygen", 0)
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Gravity", "Max O2 level" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Oxygen-Level", "Temperature", "Gravity" })
	else
		self.Inputs = {{Name="On"},{Name="Gravity"},{Name="Max O2 level"}}
	end
	
	self:NextThink(CurTime() + 1)
end

function ENT:Check()
	local size = 0
	local constrainedents = constraint.GetAllConstrainedEntities( self )
	for k,ent in pairs(constrainedents) do
		local vec = ent:OBBMaxs() - ent:OBBMins()
		local volume = (vec.x * vec.y * vec.z)
		size = size + volume
		
		ent.env = self
	end
	self.env.size = math.Round(size/100000)
	self.maxair = self.env.size*100
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:EmitSound( "apc_engine_start" )
		self:Check()
		self.Active = 1
		--self.gravity = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "apc_engine_start" )
		self:EmitSound( "apc_engine_stop" )
		self.Active = 0
		--self.gravity = 0.00001
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:SetActive( value )
	if not (value == nil) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:Breathe()
	if self.air.o2 >= 5 then
		self.air.o2 = self.air.o2 - self:ConsumeResource("oxygen", 5)
		self.air.o2per = (self.air.o2/self.maxair)*100
	else
		self.air.o2 = 0
		self.air.o2per = 0
	end
end

function ENT:OnRemove()
	local constrainedents = constraint.GetAllConstrainedEntities( self.Entity )
	local size = 0
	for k,ent in pairs(constrainedents) do
		ent.env = nil
	end
	self.BaseClass.OnRemove(self)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Gravity") then
		local gravity = value
		if value <= 0 then
			gravity = 0
		end
		self.gravity = gravity
	elseif (iname == "Max O2 level") then
		--local level = 100
		--level = math.Clamp(math.Round(value), 0, 100)
		--self.mino2 = level
	end
end


local mintemp = 284
local maxtemp = 305
local mino2 = 11
local maxsize = 512
function ENT:Regulate()
	local temperature = self.environment.temperature 
	local pressure = self.environment.pressure
	--Msg("Temperature: "..tostring(temperature)..", pressure: " ..tostring(pressure).."\n")
	
	local energy = self:GetResourceAmount("energy")
	if energy == 0 then
		self:TurnOff()
		if self.temperature == nil then
			self.temperature = temperature
		end
		return
	else
		if self.temperature == nil then
			self.temperature = temperature
		end
		if temperature < self.temperature then
			local dif = self.temperature - temperature
			dif = math.ceil(dif / 100) //Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
			self.temperature = self.temperature - dif
		elseif temperature > self.temperature then
			local dif = temperature - self.temperature
			dif = math.ceil(dif / 100)
			self.temperature = self.temperature + dif
		end
		
		if self.temperature > maxtemp then
			local mult = math.ceil(self.env.size/maxsize)
			local mult2 = math.ceil(maxsize/1024)
			
			if self.temperature - 60 > maxtemp then --is it above the comfortable range?
				--print("Cooling Down")
				self.coolant = self:GetResourceAmount("water")
				self.coolant2 = self:GetResourceAmount("nitrogen")
				--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
				if self.coolant2 > mult * 12 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 20
					self:ConsumeResource("nitrogen", mult * 12 * mult2)
				elseif self.coolant > mult * 60 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 20
					self:ConsumeResource("water", mult * 60 * mult2)
				else
					--Msg("Not enough coolant\n")
					if self.coolant2 > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant2/mult * 12 * mult2)*60)
						self.coolant = 0
					elseif self.coolant > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant/mult * 60 * mult2)*60)
						self.coolant = 0
					end
				end
			elseif self.temperature - 30 > maxtemp then --is it above the comfortable range?
				--print("Cooling Down")
				self.coolant = self:GetResourceAmount("water")
				self.coolant2 = self:GetResourceAmount("nitrogen")
				--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
				if self.coolant2 > math.ceil(self.env.size / maxsize) * 6 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 10
					self:ConsumeResource("nitrogen", mult * 6 * mult2)
				elseif self.coolant > mult * 30 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 10
					self:ConsumeResource("water", mult * 30 * mult2)
				else
					--Msg("Not enough coolant\n")
					if self.coolant2 > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant2/mult * 6 * mult2))
						self.coolant = 0
					elseif self.coolant > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant/mult * 30 * mult2))
						self.coolant = 0
					end
				end
			else--if self.temperature - 15 > maxtemp then --is it above the comfortable range?
				--print("Cooling Down")
				self.coolant = self:GetResourceAmount("water")
				self.coolant2 = self:GetResourceAmount("nitrogen")
				--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
				if self.coolant2 > mult * 3 * mult2 then
					--Msg("Enough Coolant\n")
					self.env.temperature = self.env.temperature - 5
					self:ConsumeResource("nitrogen", mult * 3 * mult2)
				elseif self.coolant > mult * 15 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 5
					self:ConsumeResource("water", mult * 15 * mult2)
				else
					--Msg("Not enough coolant\n")
					if self.coolant2 > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant2/mult * 3 * mult2))
						self.coolant = 0
					elseif self.coolant > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant/mult * 15 * mult2))
						self.coolant = 0
					end
				end
			/*else
				--print("Cooling Down")
				self.coolant = self:GetResourceAmount("water")
				self.coolant2 = self:GetResourceAmount("nitrogen")
				
				--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
				if self.coolant2 > (math.ceil(self.env.size / maxsize) * 12 * mult2) then
					--Msg("Enough Coolant\n")
					self.env.temperature = self.env.temperature - 1
					self:ConsumeResource("nitrogen", mult * 12 * mult2)
				elseif self.coolant > mult * 60 * mult2 then
					--Msg("Enough Coolant\n")
					self.temperature = self.temperature - 1
					self:ConsumeResource("water", mult * 60 * mult2)
				else
					--Msg("Not enough coolant\n")
					if self.coolant2 > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant2/mult * 12 * mult2))
						self.coolant = 0
					elseif self.coolant > 0 then
						self.temperature = self.temperature - math.ceil((self.coolant/mult * 60 * mult2))
						self.coolant = 0
					end
				end*/
			end
		end
		
		if self.temperature < mintemp then
			local mult = math.ceil(self.env.size/maxsize)
			local mult2 = math.ceil(maxsize/1024)
			
			self.energy = self:GetResourceAmount("energy")
			if self.temperature + 60 < mintemp then --is it below the comfortable range?
				--print("Heating Up 60")
				if self.energy > (mult * 60 * mult2) then
					--Msg("Enough energy\n")
					self.temperature = self.temperature + 20
					self:ConsumeResource("energy", mult * 60 * mult2)
				else
					--Msg("Not Enough energy\n")
					self:ConsumeResource("energy", self.energy)
					self.temperature = self.temperature + math.ceil((self.energy/mult * 60 * mult2))
					self.energy = 0
				end
			elseif self.temperature + 30 < mintemp then --is it below the comfortable range?
				--print("Heating Up 30")
				if self.energy > (mult * 30 * mult2) then
					--Msg("Enough energy\n")
					self.temperature = self.temperature + 10
					self:ConsumeResource("energy", mult * 30 * mult2)
				else
					--Msg("Not Enough energy\n")
					self:ConsumeResource("energy", self.energy)
					self.temperature = self.temperature + math.ceil((self.energy/mult * 30 * mult2))
					self.energy = 0
				end
			else--if self.temperature + 15 < mintemp then --is it below the comfortable range?
				--print("Heating Up 15")
				if self.energy > (mult * 15 * mult2) then
					--Msg("Enough energy\n")
					self.temperature = self.temperature + 5
					self:ConsumeResource("energy", mult * 15 * mult2)
				else
					--Msg("Not Enough energy\n")
					self:ConsumeResource("energy", self.energy)
					self.temperature = self.temperature + math.ceil((self.energy/mult * 15 * mult2))
					self.energy = 0
				end
			/*else
				print("Heating Up")
				local mult = 0.125
				if self.energy > (math.ceil(self.env.size / maxsize) * 7.5 * math.ceil(maxsize/1024)) then
					Msg("Enough energy\n")
					self.temperature = self.temperature + 1
					self:ConsumeResource("energy", math.ceil(self.env.size / maxsize) * 7.5 * math.ceil(maxsize/1024))
				else
					Msg("Not Enough energy\n")
					self:ConsumeResource("energy", self.energy)
					self.energy = 0
				end*/
			end
		end
		
		if self.air.o2per <= self.mino2 then
			local needed = ((mino2 - self.air.o2per)*self.maxair)/100
			if needed > 1000 then
				needed = 1000
			end
			self.air.o2 = self.air.o2 + self:ConsumeResource("oxygen", needed)
			self.air.o2per = (self.air.o2/self.maxair)*100
		end
		if not (WireAddon == nil) then
			Wire_TriggerOutput(self.Entity, "Oxygen-Level", tonumber(self.air.o2per))
			Wire_TriggerOutput(self.Entity, "Temperature", tonumber(self.temperature))
			Wire_TriggerOutput(self.Entity, "Gravity", tonumber(self.gravity))
		end
	end
end

function ENT:Affect()
	if not self.environment then return end
	local temperature = self.environment.temperature
	if self.temperature == nil then
		self.temperature = temperature
	end
	if temperature < self.temperature then
		local dif = self.temperature - temperature
		dif = math.ceil(dif / 100) //Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
		self.temperature = self.temperature - dif
	elseif temperature > self.temperature then
		local dif = temperature - self.temperature
		dif = math.ceil(dif / 100)
		self.temperature = self.temperature + dif
	end
	--Msg("Temperature: "..tostring(temperature).."\n")
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.Entities == {} or nil then return end
	if self.Active == 1 then
		self:Check()
		self:Regulate()
		--print("Energy:"..self.energy.." Coolant:"..self.coolant.." Temp:"..self.env.temperature)
	else
		self:Affect()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.Entity:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()

end