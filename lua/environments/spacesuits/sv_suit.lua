
local GM = {}

local meta = FindMetaTable("Player")
function meta:PutOnSuit()
	if table.HasValue(nofingers, self.m_hClothing:GetParent():GetInfo( "cl_playermodel" )) then
		self.m_hClothing:SetModel("models/player/barney.mdl")
	else
		self.m_hClothing:SetModel("models/player/combine_super_soldier.mdl")
	end
end

function meta:TakeOffSuit()
	self.m_hClothing:SetModel(player_manager.TranslatePlayerModel(self.m_hClothing:GetParent():GetInfo( "cl_playermodel" )))
end

function meta:PutOnHelmet()
	if table.HasValue(nofingers, self.m_hClothing:GetParent():GetInfo( "cl_playermodel" )) then
		self.m_hModel:SetModel("models/player/barney.mdl")
	else
		self.m_hModel:SetModel("models/player/combine_super_soldier.mdl")
	end
end

function meta:TakeOffHelmet()
	self.m_hModel:SetModel(player_manager.TranslatePlayerModel(self.m_hClothing:GetParent():GetInfo( "cl_playermodel" )))
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
local function PlayerDeath( Victim, Inflictor, Attacker )
	if ( ValidEntity( Victim.m_hClothing ) ) then
		Victim.m_hModel:SetParent( Victim:GetRagdollEntity() )
		Victim.m_hModel:Initialize()
		Victim.m_hClothing:SetParent( Victim:GetRagdollEntity() )
		Victim.m_hClothing:Initialize()
	end
end
hook.Add( "PlayerDeath", "PlayerRemoveClothing", PlayerDeath )

local function RemovePlayerClothing( ply )
	if ( ply.m_hClothing && ply.m_hClothing:IsValid() ) then

		ply.m_hModel:Remove()
		ply.m_hModel = nil
		ply.m_hClothing:Remove()
		ply.m_hClothing = nil

	end
	ply:SetMaterial( "" )
	ply:SetColor(Color(255,255,255,0))
	ply:SetRenderMode( RENDERMODE_NONE )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
local function PlayerInitialSpawn( pl )
	// Delay set player clothing
	timer.Simple( 0.1, function()
		hook.Call( "PlayerSetClothing", GM, pl )
	end)
end
hook.Add( "PlayerInitialSpawn", "PlayerSetClothing", PlayerInitialSpawn )

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
local function PlayerSpawn( pl )
	// Set player clothing
	hook.Call( "PlayerSetClothing", GM, pl )
end
hook.Add( "PlayerSpawn", "PlayerSetClothing", PlayerSpawn )

/*---------------------------------------------------------
   Name: gamemode:PlayerSetClothing( )
   Desc: Set the player's clothing
---------------------------------------------------------*/
nofingers = {"barney", "mossman", "alyx", "breen", "gman", "kleiner"}
function GM:PlayerSetClothing( pl )

	RemovePlayerClothing( pl )
	pl.m_hModel = ents.Create( "player_model" )
	pl.m_hModel:SetParent( pl )
	pl.m_hModel:SetPos( pl:GetPos() )
	pl.m_hModel:SetAngles( pl:GetAngles() )
	pl.m_hModel:Spawn()
	pl.m_hClothing = ents.Create( "player_clothing" )
	pl.m_hClothing:SetParent( pl )
	if table.HasValue(nofingers, pl.m_hClothing:GetParent():GetInfo( "cl_playermodel" )) then
		pl.m_hClothing:SetModel("models/player/barney.mdl")
	else
		pl.m_hClothing:SetModel("models/player/combine_super_soldier.mdl")
	end
	pl.m_hClothing:SetPos( pl:GetPos() )
	pl.m_hClothing:SetAngles( pl:GetAngles() )
	pl.m_hClothing:Spawn()

end
