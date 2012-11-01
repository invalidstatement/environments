------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local meta = FindMetaTable("Player")
function meta:PutOnSuit()
	//if table.HasValue(nofingers, self.m_hSuit:GetParent():GetInfo( "cl_playermodel" )) then
		//self.m_hSuit:SetModel("models/player/barney.mdl")
	//else
		self.m_hSuit:SetModel(self.SuitModel)
	//end
	self:SetNWBool("helmet", true)
end

function meta:TakeOffSuit()
	if self.m_hHelmet:GetParent().GetInfo then
		self:SetNWBool("helmet", false)
		self.m_hSuit:SetModel(player_manager.TranslatePlayerModel(self.m_hSuit:GetParent():GetInfo( "cl_playermodel" )))
	end
end

function meta:PutOnHelmet()
	if self.m_hHelmet:GetParent().GetInfo then
		self.m_hHelmet:SetModel(self.SuitModel)
		self:SetNWBool("helmet", true)
		self.m_hHelmet:SetColor(Color(self.ClothingColor.r,self.ClothingColor.g,self.ClothingColor.b,255,255))
		
		self.m_hSuit:ManipulateBoneScale( self.m_hSuit:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1) )
	end
end

function meta:TakeOffHelmet()
	if self.m_hHelmet:GetParent().GetInfo then
		self:SetNWBool("helmet", false)
		self.m_hHelmet:SetModel(player_manager.TranslatePlayerModel(self.m_hHelmet:GetParent():GetInfo( "cl_playermodel" )))
		self.m_hHelmet:SetColor(Color(255,255,255,255))
		
		for i=0, self.m_hHelmet:GetBoneCount() do
			if( self.m_hHelmet:GetBoneName( i ) == "ValveBiped.Bip01_Head1" ) then continue end
			if( self.m_hHelmet:GetBoneName( i ) == "ValveBiped.Bip01_Neck1" ) then continue end
			
			self.m_hHelmet:ManipulateBoneScale( i, Vector(0,0,0) )
		end
		
		self.m_hSuit:ManipulateBoneScale( self.m_hSuit:LookupBone("ValveBiped.Bip01_Head1"), Vector(0,0,0) )
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function Environments.Hooks.SuitPlayerDeath( Victim, Inflictor, Attacker )
	if ( IsValid( Victim.m_hSuit ) ) then
		Victim.m_hHelmet:SetParent( Victim:GetRagdollEntity() )
		Victim.m_hHelmet:Initialize()
		Victim.m_hSuit:SetParent( Victim:GetRagdollEntity() )
		Victim.m_hSuit:Initialize()
	end
end

local function RemovePlayerClothing( ply )
	if ( ply.m_hSuit && ply.m_hSuit:IsValid() ) then
		ply.m_hHelmet:Remove()
		ply.m_hHelmet = nil
		ply.m_hSuit:Remove()
		ply.m_hSuit = nil
	end
	ply:SetRenderMode(RENDERMODE_NONE)
end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
function Environments.Hooks.SuitInitialSpawn( pl )
	// Delay set player clothing
	timer.Simple( 0.1, function()
		hook.Call( "PlayerSetClothing", GM, pl )
	end)
	pl:SetNWBool("helmet", true)
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
nofingers = {"barney", "mossman", "alyx", "breen", "gman", "kleiner"}
function Environments.Hooks.SuitPlayerSpawn( pl )
	RemovePlayerClothing( pl )
	//just in case
	pl.ClothingColor = {}
	pl.ClothingColor.r = tonumber(pl:GetInfoNum("env_suit_color_r",255))
	pl.ClothingColor.b = tonumber(pl:GetInfoNum("env_suit_color_b",255))
	pl.ClothingColor.g = tonumber(pl:GetInfoNum("env_suit_color_g",255))

	pl:SetNWBool("helmet", true)
	pl.m_hHelmet = ents.Create( "player_helmet" )
	pl.m_hHelmet:SetParent( pl )
	pl.m_hHelmet:SetPos( pl:GetPos() )
	pl.m_hHelmet:SetAngles( pl:GetAngles() )
	pl.m_hHelmet:Spawn()
	pl.m_hHelmet:SetModel("models/player/combine_super_soldier.mdl")
	
	pl.m_hSuit = ents.Create( "player_suit" )
	pl.m_hSuit:SetParent( pl )
	if table.HasValue(nofingers, pl.m_hSuit:GetParent():GetInfo( "cl_playermodel" )) then
		pl.m_hSuit:SetModel("models/player/barney.mdl")
	else
		pl.m_hSuit:SetModel("models/player/combine_super_soldier.mdl")
	end
	pl.m_hSuit:SetPos( pl:GetPos() )
	pl.m_hSuit:SetAngles( pl:GetAngles() )
	pl.m_hSuit:Spawn()
	
	//set the colors after player info is recieved
	timer.Simple(0.5, function() 
		pl.ClothingColor = {}
		pl.ClothingColor.r = tonumber(pl:GetInfoNum("env_suit_color_r",255))
		pl.ClothingColor.b = tonumber(pl:GetInfoNum("env_suit_color_b",255))
		pl.ClothingColor.g = tonumber(pl:GetInfoNum("env_suit_color_g",255))
		pl.m_hSuit:SetColor(Color(pl.ClothingColor.r,pl.ClothingColor.g,pl.ClothingColor.b,255))
		pl.m_hHelmet:SetColor(Color(pl.ClothingColor.r,pl.ClothingColor.g,pl.ClothingColor.b,255))
		
		pl.SuitModel = pl:GetInfo("env_suit_model") --or "models/player/combine_super_soldier.mdl"
		
		pl.m_hHelmet:SetModel(pl.SuitModel)
		pl.m_hSuit:SetModel(pl.SuitModel)
	end)
end

/////////////////////////////////////////////////////////
//  This is the prototype Player MMU System WIP Code   //
/////////////////////////////////////////////////////////
function meta:ToggleMMU(override)
	self.MMV = !self.MMV
	self.Active = !self.Active
	if override then
		self.MMV = override
		self.Active = override
	end

	if self.Active == true then
		self:SetupMMU()
	else
		self:RemoveMMU()
	end
end

local offset = Vector(0,0,25)
function meta:SetupMMU()
	self.Fuel = self.MaxFuel
	self.CanBurstAgain = false
	self.LastTime = CurTime()
	
	timer.Simple(1,function()
		local model = "models/Slyfo_2/mmu_mk_1.mdl"
		local attachment = self:LookupAttachment("chest")
		local tab = self:GetAttachment(attachment)
		self.Unit = ents.Create("prop_physics")
		self.Unit:SetModel(model)
		self.Unit:SetPos(tab.Pos)
		self.Unit:SetAngles(tab.Ang)
		self.Unit:SetParent(self)
		self.Unit:Fire("SetParentAttachmentMaintainOffset", "chest", 0.01)
		self:PrintMessage(HUD_PRINTTALK,"Your MMU is now active!")
		hook.Add("Think",self:SteamID().."MMUThink",function() self:MMUThink() end)
	end)
end

function meta:RemoveMMU()
	self.Fuel = self.MaxFuel
	self.CanBurstAgain = false
	self.LastTime = CurTime()
	
	self.Unit:Remove()
	self:PrintMessage(HUD_PRINTTALK,"Your MMU is now inactive!")
	hook.Remove("Think",self:SteamID().."MMUThink")
end

local SwepThrustSound = "npc/env_headcrabcanister/hiss.wav"
local SwepThrustSoundObj = Sound(SwepThrustSound)
local ThrustForce = 150
local self = {}
function meta:MMUThink()
	local SwepThrustSoundObj = "npc/env_headcrabcanister/hiss.wav"
	if not self:Alive() then 
		self:ToggleMMU(false) 
		if self.SoundFileThing then self.SoundFileThing:Stop() end
		return 
	end
	
	if (self.LastTime + 2.5) <= CurTime() then 
		self.LastTime = CurTime() 
		self.CanBurstAgain = true 
	end
	
	if self.CanBurstAgain != true then return end
	if not self.MMV then self.MMV = false end
	if self.MMV == true then
		if self:KeyDown(IN_FORWARD) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAimVector()*ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_BACK) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAimVector()*-ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_MOVELEFT) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAngles():Right()*-ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_MOVERIGHT) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAngles():Right()*ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_JUMP) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAngles():Up()*ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_DUCK) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:SetLocalVelocity((self:GetAngles():Up()*-ThrustForce))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		elseif self:KeyDown(IN_WALK) then
			if self.SoundFileThing then self.SoundFileThing:Stop() end
			self:PrintMessage(HUD_PRINTTALK,"MMU Halting Movement...")
			self:SetLocalVelocity(Vector(0,0,0))
			self.CanBurstAgain = false
			self.SoundFileThing = CreateSound(self,SwepThrustSoundObj)
			self.SoundFileThing:Play()
			--self.Fuel = math.Clamp(self.Fuel-FuelConsumption,0,self.MaxFuel)
		end
		timer.Simple(0.2,function() if self.SoundFileThing then self.SoundFileThing:Stop() end end)
	end
	--self:SetNWInt("Fuel",self.Fuel)
end

// ---------------------------------------------------
// Gravity Hull Designator Support
// ---------------------------------------------------

util.AddNetworkString( "EGHDPEnS" )
util.AddNetworkString( "EGHDPExS" )

local function EnvGHDEnterShipSupport( xEntity, e, g, oldpos, oldang )
	if( xEntity:IsPlayer() && IsValid( xEntity.m_hSuit ) && IsValid( xEntity.m_hHelmet ) ) then
		net.Start( "EGHDPEnS" )
			net.WriteEntity( xEntity )
			net.WriteEntity( xEntity.m_hSuit )
			net.WriteEntity( xEntity.m_hHelmet )
		net.Broadcast()
	end	
end
hook.Add( "EnterShip", "EnvGHDEnterShipSupport", EnvGHDEnterShipSupport )

local function EnvGHDExitShipSupport( xEntity, e, g, oldpos, oldang )
	if( xEntity:IsPlayer() ) then
		net.Start( "EGHDPExS" )
			net.WriteEntity( xEntity )
		net.Broadcast()
	end	
end
hook.Add( "ExitShip", "EnvGHDExitShipSupport", EnvGHDExitShipSupport )