------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local meta = FindMetaTable("Player")
function meta:PutOnSuit()
	if table.HasValue(nofingers, self.m_hSuit:GetParent():GetInfo( "cl_playermodel" )) then
		self.m_hSuit:SetModel("models/player/barney.mdl")
	else
		self.m_hSuit:SetModel("models/player/combine_super_soldier.mdl")
	end
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
		self.m_hHelmet:SetModel("models/player/combine_super_soldier.mdl")
		self:SetNWBool("helmet", true)
		self.m_hHelmet:SetColor(self.ClothingColor.r,self.ClothingColor.g,self.ClothingColor.b,255,255)
	end
end

function meta:TakeOffHelmet()
	if self.m_hHelmet:GetParent().GetInfo then
		self:SetNWBool("helmet", false)
		self.m_hHelmet:SetModel(player_manager.TranslatePlayerModel(self.m_hHelmet:GetParent():GetInfo( "cl_playermodel" )))
		self.m_hHelmet:SetColor(255,255,255,255)
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function Environments.Hooks.SuitPlayerDeath( Victim, Inflictor, Attacker )
	if ( ValidEntity( Victim.m_hSuit ) ) then
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
function Environments.Hooks.SuitPlayerSpawn( pl )
	// Set player clothing
	PlayerSetClothing(pl)
end

nofingers = {"barney", "mossman", "alyx", "breen", "gman", "kleiner"}
function PlayerSetClothing( pl )
	RemovePlayerClothing( pl )
	pl.ClothingColor = {}
	pl.ClothingColor.r = tonumber(pl:GetInfoNum("env_suit_color_r",255))
	pl.ClothingColor.b = tonumber(pl:GetInfoNum("env_suit_color_b",255))
	pl.ClothingColor.g = tonumber(pl:GetInfoNum("env_suit_color_g",255))
	--PrintTable(pl.ClothingColor)
	--print(pl:GetInfoNum("env_suit_color_r",255),pl:GetInfoNum("env_suit_color_b",255),pl:GetInfoNum("env_suit_color_g",255))
	pl:SetNWBool("helmet", true)
	pl.m_hHelmet = ents.Create( "player_helmet" )
	pl.m_hHelmet:SetParent( pl )
	pl.m_hHelmet:SetPos( pl:GetPos() )
	pl.m_hHelmet:SetAngles( pl:GetAngles() )
	pl.m_hHelmet:Spawn()
	pl.m_hHelmet:SetModel("models/player/combine_super_soldier.mdl")
	pl.m_hHelmet:SetColor(pl.ClothingColor.r,pl.ClothingColor.g,pl.ClothingColor.b,255)
	
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
	pl.m_hSuit:SetColor(pl.ClothingColor.r,pl.ClothingColor.g,pl.ClothingColor.b,255)
end

