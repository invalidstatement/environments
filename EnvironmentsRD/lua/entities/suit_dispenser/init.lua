AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if WireAddon then
		self.WireDebugName = self.PrintName
	end
	self.resources = {}
	self.resources["energy"] = 0
	self.resources["water"] = 0
	self.resources["air"] = 0
	
	self.maxresources = {}
	self.maxresources["energy"] = 0
	self.maxresources["water"] = 0
	self.maxresources["air"] = 0
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		self:SetActive( nil, caller )
	end
end
	
function ENT:Repair()
	self.BaseClass.Repair(self)
	self.damaged = 0
end

local function quiet_steam(ent)
	ent:StopSound( "ambient.steam01" )
end

local MaxAmount = 4000
local Multiplier = 1.5
local Divider = 1/Multiplier

function ENT:SetActive( value, caller )
	if not self.node then return end
	self.air = self:GetResourceAmount("oxygen")
	self.energy = self:GetResourceAmount("energy")
	self.coolant = self:GetResourceAmount("water")
	self.coolant2 = self:GetResourceAmount("nitrogen")

	local air_needed = math.ceil((MaxAmount - caller.suit.air) * Divider)
	if ( air_needed < self.air ) then
		self:ConsumeResource("oxygen", air_needed)
		caller.suit.air = MaxAmount
	elseif (self.air > 0) then
		caller.suit.air = caller.suit.air + math.floor(self.air * Multiplier)
		self:ConsumeResource("oxygen", self.air)
	end
	
	local energy_needed = math.ceil((MaxAmount - caller.suit.energy) * Divider)
	if ( energy_needed < self.energy ) then
		self:ConsumeResource("energy", energy_needed)
		caller.suit.energy = MaxAmount
	elseif (self.energy > 0) then
		caller.suit.energy = caller.suit.energy +  math.floor(self.energy * Multiplier)
		self:ConsumeResource("energy", self.energy)
	end
	
	local nitrogen_needed = math.ceil(((MaxAmount - caller.suit.coolant) * Divider)/2)
	if ( nitrogen_needed < self.coolant2 ) then
		self:ConsumeResource("nitrogen", nitrogen_needed)
		caller.suit.coolant = MaxAmount
	elseif (self.coolant2 > 0) then
		caller.suit.coolant = caller.suit.coolant + math.floor(self.coolant2 * 2 * Multiplier)
		self:ConsumeResource("nitrogen", self.coolant2)
	end
	
	local coolant_needed = math.ceil((MaxAmount - caller.suit.coolant) * Divider)
	if ( coolant_needed < self.coolant ) then
		self:ConsumeResource("water", coolant_needed)
		caller.suit.coolant = MaxAmount
	elseif (self.coolant > 0) then
		caller.suit.coolant = caller.suit.coolant + math.floor(self.coolant * Multiplier)
		self:ConsumeResource("water", self.coolant)
	end
	
	caller.Entity:EmitSound( "ambient.steam01" )
	local temp = function() quiet_steam(caller.Entity) end
	timer.Simple(3, temp) 
end

