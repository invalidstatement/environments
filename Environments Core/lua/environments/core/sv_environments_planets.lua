------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

--localize
local math = math
local table = table
local ents = ents
local pairs = pairs
local tonumber = tonumber
local type = type

//Custom Locals
local Environments = Environments
local Space = Space

local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3
local SB_AIR_CH4 = 4
local SB_AIR_AR = 5


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

local function GetFlags(flags)
	if not flags or type(flags) != "number" then return end
	local habitat = Extract_Bit(1, flags)
	local unstable = Extract_Bit(2, flags)
	local sunburn = Extract_Bit(3, flags) 
	--print(habitat, unstable, sunburn)
	return habitat, unstable, sunburn
end

local function GetSB3Flags(flags)
	if not flags or type(flags) != "number" then return end
	local unstable = Extract_Bit(1, flags)
	local sunburn = Extract_Bit(2, flags) 
	return unstable, sunburn
end

local function GetVolume(radius)
	return (4/3) * math.pi * radius * radius
end

function Environments.ParseSaveData(planet)
	local compounds = {}
	--compounds = table.Copy(planet.atmosphere)
	compounds["o2"] = planet.atmosphere.oxygen
	compounds["co2"] = planet.atmosphere.carbondioxide
	compounds["h"] = planet.atmosphere.hydrogen
	compounds["n"] = planet.atmosphere.nitrogen
	compounds["ch4"] = planet.atmosphere.methane
	compounds["ar"] = planet.atmosphere.argon
	
	local gravity = planet.gravity
	local o2 = tonumber(planet.atmosphere.oxygen)
	local co2 = tonumber(planet.atmosphere.carbondioxide)
	local n = tonumber(planet.atmosphere.nitrogen)
	local h = tonumber(planet.atmosphere.hydrogen)
	local ch4 = tonumber(planet.atmosphere.methane)
	local ar = planet.atmosphere.argon
	local temperature = planet.temperature
	local suntemperature = planet.suntemperature
	local atmosphere = planet.atm
	local radius = planet.radius
	local volume = GetVolume(radius)
	
	local self = {}
	self.atmosphere = planet.atm
	self.air = {}
	
	self.air.max = math.Round(100 * 5 * (volume/1000) * self.atmosphere)
	self.air.total = planet.atmosphere.total
	
	for k,v in pairs(compounds) do
		if v and type(v) == "number" and v > 0 then
			if v < 0 then v = 0 end
			if v > 100 then v = 100 end
			self.air[k.."per"] = v
			self.air[k] = math.Round((v/100)*self.air.total)
		else
			v = 0
			self.air[k.."per"] = v
			self.air[k] = v
		end
	end
	
	if o2 + co2 + n + h + ch4 + ar < 1 then
		--local tmp = 100 - (o2 + co2 + n + h + ch4 + ar)
		self.air.total = 0
		self.air.empty = 0
		self.air.emptyper = 0
	elseif o2 + co2 + n + h + ch4 + ar > 100 then
		local tmp = (o2 + co2 + n + h + ch4 + ar) - 100
		if co2 > tmp then
			self.air.co2 = math.Round((co2 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.co2per = co2 + tmp
		elseif n > tmp then
			self.air.n = math.Round((n - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.nper = n + tmp
		elseif h > tmp then
			self.air.h = math.Round((h - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.hper = h + tmp
		elseif o2 > tmp then
			self.air.o2 = math.Round((o2 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.o2per = o2 - tmp
		elseif ar > tmp then
			self.air.ar = math.Round((ar - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.arper = ar - tmp
		elseif ch4 > tmp then
			self.air.ch4 = math.Round((ch4 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.ch4per = ch4 - tmp
		end
		self.air.empty = 0
		self.air.emptyper = 0
	else
		self.air.empty = 0
		self.air.emptyper = 0
	end
	
	self.originalco2per = self.air.co2per
	return self
end

//Actually creates it
function Environments.CreatePlanet(d)
	local planet = ents.Create("Environment")
	planet:Spawn()
	planet:SetPos(d.position)
	--planet.environment = self
	planet:Configure(d.radius, d.gravity, d.name, d)
	
	//stop it from getting removed
	planet.Delete = planet.Remove
	planet.Remove = function() 
		Environments.Log("Something Attempted to Remove Planet "..d.name)
	end
	
	table.insert(environments, planet)
end

//parses the data from the map loading
function Environments.ParsePlanet(planet)
	local compounds = {}
	compounds["o2"] = planet.atmosphere.oxygen
	compounds["co2"] = planet.atmosphere.carbondioxide
	compounds["h"] = planet.atmosphere.hydrogen
	compounds["n"] = planet.atmosphere.nitrogen
	compounds["ch4"] = planet.atmosphere.methane
	compounds["ar"] = planet.atmosphere.argon
	
	local gravity = planet.gravity
	local o2 = planet.atmosphere.oxygen
	local co2 = planet.atmosphere.carbondioxide
	local n = planet.atmosphere.nitrogen
	local h = planet.atmosphere.hydrogen
	local ch4 = planet.atmosphere.methane
	local ar = planet.atmosphere.argon
	local temperature = planet.temperature
	local suntemperature = planet.suntemperature
	local atmosphere = planet.atm
	local radius = planet.radius
	local volume = GetVolume(radius)
	local unstable =  planet.unstable
	local sunburn = planet.sunburn
	
	if planet.flags then
		unstable, sunburn = GetSB3Flags(planet.flags)
	end
	
	local self = {}
	self.radius = radius
	self.position = planet.position
	self.typeof = planet.typeof

	self.noclip = planet.noclip
	self.unstable = unstable
	self.sunburn = sunburn
	self.bloomid = planet.bloomid
	self.colorid = planet.colorid
	
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
		if temperature < 35 then
			temperature = 35
		end
		self.temperature = temperature
	end
	//set suntemperature if given
	if suntemperature and type(suntemperature) == "number" then
		if suntemperature < 35 then
			suntemperature = 35
		end
		self.suntemperature = suntemperature
	end
	
	
	self.air = {}
	self.air.max = math.Round(100 * 5 * (volume/1000) * self.atmosphere)
	self.air.total = self.air.max
	for k,v in pairs(compounds) do
		if v and type(v) == "number" and v > 0 then
			if v < 0 then v = 0 end
			if v > 100 then v = 100 end
			self.air[k.."per"] = v
			self.air[k] = math.Round((v/100)*self.air.total)
		else
			v = 0
			self.air[k.."per"] = v
			self.air[k] = v
		end
	end
	
	if o2 + co2 + n + h + ch4 + ar < 1 then
		//This is perfectly ok, it just means something isnt perfect
		--local tmp = 100 - (o2 + co2 + n + h + ch4 + ar)
		self.air.total = 0
		self.air.empty = 0
		self.air.emptyper = 0
	elseif o2 + co2 + n + h + ch4 + ar > 100 then
		local tmp = (o2 + co2 + n + h + ch4 + ar) - 100
		if co2 > tmp then
			self.air.co2 = math.Round((co2 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.co2per = co2 + tmp
		elseif n > tmp then
			self.air.n = math.Round((n - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.nper = n + tmp
		elseif h > tmp then
			self.air.h = math.Round((h - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.hper = h + tmp
		elseif o2 > tmp then
			self.air.o2 = math.Round((o2 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.o2per = o2 - tmp
		elseif ar > tmp then
			self.air.ar = math.Round((ar - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.arper = ar - tmp
		elseif ch4 > tmp then
			self.air.ch4 = math.Round((ch4 - tmp) * 5 * (volume/1000) * self.atmosphere)
			self.air.ch4per = ch4 - tmp
		end
		self.air.empty = 0
		self.air.emptyper = 0
	elseif o2 + co2 + n + h + ch4 + ar < 100 then
		local total = o2 + co2 + n + h + ch4 + ar
		local needed = 100 - total
		self.air.nper = n + needed
		self.air.n = math.Round((self.air.nper/100)*self.air.total)
	else
		self.air.empty = 0
		self.air.emptyper = 0
	end
	if planet.name then
		self.name = planet.name
	end

	--self.pressure = self.atmosphere * self.gravity * (1 - (self.air.emptyper/100))
	self.originalco2per = self.air.co2per
	
	return self
end

//Borrowed from SB3
function Environments.ParseSB2Environment(planet)
	local habitat, unstable, sunburn = GetFlags(planet.flags)
	planet.flags = nil
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
	planet.sunburn = sunburn
	return planet
end
//End Borrowed code

function Environments.ParseStar(planet)
	local self = {}
	self.radius = planet.radius
	self.position = planet.position
	self.typeof = planet.typeof
	self.name = planet.name
	self.temperature = planet.temperature
	self.isstar = true
	self.gravity = 0 --planet.gravity
	self.air = {}
	self.air.o2per = 0
	return self
end

function Environments.CreateStar(planet)
	local star = ents.Create("Star")
	star:Spawn()
	star:SetPos(planet.position)
	star:Configure(planet.radius, planet.gravity, planet.name, planet)
	
	table.insert(environments, star)
end
