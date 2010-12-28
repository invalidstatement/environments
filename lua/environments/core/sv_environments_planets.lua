------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------

local mt = {} -- The metatable
local methods = {} -- Methods for our objects
mt.__index = methods -- Redirect all key "requests" to the methods table

function CreateEnvironment(planet)
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
	local name = planet.name
	local radius = planet.radius
	
	local self = {}
	self.radius = radius
	self.position = planet.position
	self.typeof = planet.typeof
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
	end
	if name then
		self.name = name
	end
	self.air.max = math.Round(100 * 5 * (GetVolume(radius)/1000) * self.atmosphere)
	
	//Add it to the table
	setmetatable(self, mt)
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
	if type(air1) != "string" or type(air2) != "string" or type(value) != "number" then return 0 end
	
	if server_settings.Bool( "SB_StaticEnvironment" ) then
		return value
		//Don't do anything else anymore
	end
	
	if air1 == "" then
		self.atmosphere[air2] = self.atmosphere[air2] + value
	else
		self.atmosphere[air1] = self.atmosphere[air1] - value
		self.atmosphere[air2] = self.atmosphere[air2] + value
	end
	
	PrintTable(self.atmosphere)
end