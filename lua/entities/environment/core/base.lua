local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3
local SB_AIR_CH4 = 4
local SB_AIR_AR = 5

///////////////////////////////////////////////
//       Meta Table Stuff For Planets        //
///////////////////////////////////////////////

function GetVolume(radius)
	return (4/3) * math.pi * radius * radius
end

function ENT:Convert(air1, air2, value)
	print(air1,air2,value)
	--if not air1 or not air2 or not value then return 0 end
	--if type(air1) != "number" or type(air2) != "number" or type(value) != "number" then return 0 end 
	air1 = math.Round(air1)
	air2 = math.Round(air2)
	value = math.Round(value)
	if air1 < -1 or air1 > 5 then return 0 end
	if air2 < -1 or air2 > 5 then return 0 end
	if air1 == air2 then return 0 end
	if value < 1 then return 0 end
	/*if server_settings.Bool( "SB_StaticEnvironment" ) then
		return value;
		//Don't do anything else anymore
	end*/
	if air1 == -1 then
		print("empty")
		if self.air.empty < value then
			value = self.air.empty
		end
		self.air.empty = self.air.empty - value
		if air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		end
	elseif air1 == SB_AIR_O2 then
		print("o2")
		if self.air.o2 < value then
			value = self.air.o2
		end
		self.air.o2 = self.air.o2 - value
		if air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_CO2 then
		print("co2")
		if self.air.co2 < value then
			value = self.air.co2
		end
		self.air.co2 = self.air.co2 - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_N then
		print("n")
		if self.air.n < value then
			value = self.air.n
		end
		self.air.n = self.air.n - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_CH4 then
		print("Ch4")
		if self.air.ch4 < value then
			value = self.air.ch4
		end
		self.air.ch4 = self.air.ch4 - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_AR then
		print("AR")
		if self.air.ar < value then
			value = self.air.ar
		end
		self.air.ar = self.air.ar - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	else
		print("else")
		if self.air.h < value then
			value = self.air.h
		end
		self.air.h = self.air.h - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	end
	for k,v in pairs(self.air) do
		if k == "o2per" or k == "co2per" or k == "emptyper" or k == "nper" or k == "hper" or k == "max" or k =="ch4per" or k=="arper" then
		else
			self.air[k.."per"] = self:GetResourcePercentage(k)
		end
	end
	self.pressure = self.atmosphere * self.gravity * (1 - (self.air.emptyper/100))
	/*if air1 or air2 == 1 then
		--self.temperature = self.temperature + (( self.temperature * ((self.air.co2per - self.original.air.co2per)/100))/2)
		--self.suntemperature = self.suntemperature + (( self.suntemperature * ((self.air.co2per - self.original.air.co2per)/100))/2)
	end
	if air1 or air2 == 4 then
		--self.temperature = self.temperature + (( self.temperature * ((self.air.ch4per - self.original.air.ch4per)/100))/2)
	end*/
	--self:GetBreathable()
	print(value)
	return value
end

/*function ENT:GetBreathable()
	if self.air.arper >= 5 then
		self.breathable = false
		return false
	end
	self.breathable = true
	return true
end*/

function ENT:GetResourcePercentage(res)
	--if not res or type(res) == "number" then return 0 end
	if self.air.max == 0 then
		return 0
	end
	--local ignore = {"o2per", "co2per", "nper", "hper", "emptyper", "max", "nhper"}
	--if table.HasValue(ignore, res) then return 0 end
	return ((self.air[res] / self.air.max) * 100)
end

//Basic LS3 Compatibility
function ENT:IsOnPlanet()
	return self
end

function ENT:GetAtmosphere()
	return self.atmosphere
end

function ENT:GetSize()
	return self.radius
end

function ENT:IsSpace()
	return false
end

function ENT:IsStar()
	return false
end

function ENT:IsEnvironment()
	return true
end

function ENT:IsPlanet()
	return true
end

function ENT:GetGravity()
	return self.gravity
end

function ENT:GetO2Percentage()
	return self.air.o2per
end

function ENT:GetCO2Percentage()
	return self.air.co2per
end

function ENT:GetNPercentage()
	return self.air.nper
end

function ENT:GetHPercentage()
	return self.air.hper
end

function ENT:GetEmptyAirPercentage()
	return self.air.emptyper
end

function ENT:GetPressure()
	return self.pressure
end

function ENT:GetTemperature()
	return self.temperature + ((self.temperature * ((self.air.co2per - self.original.air.co2per)/100))/2)
end

function ENT:GetGravity()
	return self.gravity
end

function ENT:GetEnvironmentName()
	return self.name
end
