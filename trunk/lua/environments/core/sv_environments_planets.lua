------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------

local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3

local mt = {} -- The metatable
local methods = {} -- Methods for our objects
mt.__index = methods -- Redirect all key "requests" to the methods table

local function Extract_Bit(bit, field)
	if not bit or not field then return false end
	local retval = 0
	if ((field <= 7) and (bit <= 4)) then
		if (field >= 4) then
			field = field - 4
			if (bit == 4) then return true end
		end
		if (field >= 2) then
			field = field - 2
			if (bit == 2) then return true end
		end
		if (field >= 1) then
			field = field - 1
			if (bit == 1) then return true end
		end
	end
	return false
end

function GetFlags(flags)
	if not flags or type(flags) != "number" then return end
	local habitat = Extract_Bit(1, flags)
	local unstable = Extract_Bit(2, flags)
	local sunburn = Extract_Bit(3, flags)
	return habitat, unstable, sunburn
end

function CreateEnvironment(planet, isstar)
	local compounds = {}
	compounds["o2"] = planet.atmosphere.oxygen
	compounds["co2"] = planet.atmosphere.carbondioxide
	compounds["h"] = planet.atmosphere.hydrogen
	compounds["n"] = planet.atmosphere.nitrogen
	
	local gravity = planet.gravity
	local o2 = planet.atmosphere.oxygen
	local co2 = planet.atmosphere.carbondioxide
	local n = planet.atmosphere.nitrogen
	local h = planet.atmosphere.hydrogen
	local temperature = planet.temperature
	local atmosphere = 1
	local radius = planet.radius
	
	local self = {}
	self.radius = radius
	self.position = planet.position
	self.typeof = planet.typeof
	self.temperature2 = planet.temperature2
	if gravity and type(gravity) == "number" then
		if gravity < 0 then
			gravity = 0
		end
		self.gravity = gravity
	end
	//set atmosphere if given
	if atmosphere and type(atmosphere) == "number" then
		if atmosphere < 0 then
			atmosphere = 0
		elseif atmosphere > 1 then
			atmosphere = 1
		end
		self.atmosphere = atmosphere
	end
	//set pressure if given
	if pressure and type(pressure) == "number" and pressure >= 0 then
		self.pressure = pressure
	else 
		self.pressure = math.Round(self.atmosphere * self.gravity)
	end
	//set temperature if given
	if temperature and type(temperature) == "number" then
		self.temperature = temperature
	end
	
	self.air = {}
	for k,v in pairs(compounds) do
		if v and type(v) == "number" and v > 0 then
			if v < 0 then v = 0 end
			if v > 100 then v = 100 end
			self.air[k.."per"] = v
			self.air[k] = math.Round(v * 5 * (GetVolume(radius)/1000) * self.atmosphere)
		else
			v = 0
			self.air[k.."per"] = v
			self.air[k] = v
		end
	end
	
	if o2 + co2 + n + h < 100 then
		local tmp = 100 - (o2 + co2 + n + h)
		self.air.empty = math.Round(tmp * 5 * (GetVolume(radius)/1000) * self.atmosphere)
		self.air.emptyper = tmp
	elseif o2 + co2 + n + h > 100 then
		local tmp = (o2 + co2 + n + h) - 100
		if co2 > tmp then
			self.air.co2 = math.Round((co2 - tmp) * 5 * (GetVolume(radius)/1000) * self.atmosphere)
			self.air.co2per = co2 + tmp
		elseif n > tmp then
			self.air.n = math.Round((n - tmp) * 5 * (GetVolume(radius)/1000) * self.atmosphere)
			self.air.nper = n + tmp
		elseif h > tmp then
			self.air.h = math.Round((h - tmp) * 5 * (GetVolume(radius)/1000) * self.atmosphere)
			self.air.hper = h + tmp
		elseif o2 > tmp then
			self.air.o2 = math.Round((o2 - tmp) * 5 * (GetVolume(radius)/1000) * self.atmosphere)
			self.air.o2per = o2 - tmp
		end
		self.air.empty = 0
		self.air.emptyper = 0
	else
		self.air.empty = 0
		self.air.emptyper = 0
	end
	if planet.name then
		self.name = planet.name
	end
	self.air.max = math.Round(100 * 5 * (GetVolume(radius)/1000) * self.atmosphere)
	self.firstenvironment = table.Copy(self)
	//Add it to the table
	setmetatable(self, mt)
	table.insert(environments, self)
end

//Borrowed from SB3
function CreateSB2Environment(planet)
	local habitat, unstable, sunburn = GetFlags(planet.flags)
	local o2 = 0
	local co2 = 0
	local n = 0
	local h = 0
	local pressure = atmosphere
	//set Radius if one is given
	if planet.radius and type(radius) == "number" then
		if planet.radius < 0 then
			planet.radius = 0
		end
	end
	//set temperature2 if given
	if habitat then //Based on values for earth
		planet.atmosphere.oxygen = 21
		planet.atmosphere.carbondioxide = 0.45
		planet.atmosphere.nitrogen = 78
		planet.atmosphere.hydrogen = 0.55
	else //Based on values for Venus
		planet.atmosphere.oxygen = 0
		planet.atmosphere.carbondioxide = 96.5
		planet.atmosphere.nitrogen = 3.5
		planet.atmosphere.hydrogen = 0
	end
	CreateEnvironment(planet)
end

function CreateStarEnv(planet)
	local self = {}
	self.radius = planet.radius
	self.position = planet.position
	self.typeof = planet.typeof
	self.temperature = planet.temperature
	self.isstar = true
	self.gravity = planet.gravity
	self.air = {}
	self.air.o2per = 0
	table.insert(environments, self)
end

///////////////////////////////////////////////
//       Meta Table Stuff For Planets        //
///////////////////////////////////////////////

function GetVolume(radius)
	return (4/3) * math.pi * radius * radius
end

function methods:Convert(air1, air2, value)
	if not air1 or not air2 or not value then return 0 end
	if type(air1) != "number" or type(air2) != "number" or type(value) != "number" then return 0 end 
	air1 = math.Round(air1)
	air2 = math.Round(air2)
	value = math.Round(value)
	if air1 < -1 or air1 > 3 then return 0 end
	if air2 < -1 or air2 > 3 then return 0 end
	if air1 == air2 then return 0 end
	if value < 1 then return 0 end
	/*if server_settings.Bool( "SB_StaticEnvironment" ) then
		return value;
		//Don't do anything else anymore
	end*/
	if air1 == -1 then
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
		elseif air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		end
	elseif air1 == SB_AIR_O2 then
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
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_CO2 then
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
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_N then
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
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	else
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
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	end
	for k,v in pairs(self.air) do
		self.air[k.."per"] = self:GetResourcePercentage(k)
	end
	return value
end

function methods:GetResourcePercentage(res)
	if not res or type(res) == "number" then return 0 end
	if self.air.max == 0 then
		return 0
	end
	local ignore = {"o2per", "co2per", "nper", "hper", "emptyper", "max"}
	if table.HasValue(ignore, res) then return 0 end
	return ((self.air[res] / self.air.max) * 100)
end
