
//
// The server only runs this file so it can send it to the client
//
player_manager.AddValidModel( "SBEPRedHEV", "models/SBEP Player Models/redhevsuit.mdl" ) 
player_manager.AddValidModel( "SBEPBlueHEV", "models/SBEP Player Models/bluehevsuit.mdl" )
player_manager.AddValidModel( "SBEPOrangeHEV", "models/SBEP Player Models/orangehevsuit.mdl" )
if ( SERVER ) then AddCSLuaFile( "clothing_menu.lua" ) return end
CreateClientConVar( "cl_playerclothing", "none"	, true, true )
//
// The PlayerOptionsClothing defines which models will
// appear on the player clothing menu. It doesn't define
// which models are valid. Just which choices will appear.
//
// Look at player_manager to see how to define which models
// are valid.
//
//

local function OnChangeModel( name, oldvalue, newvalue )
	RunConsoleCommand( "cl_playerclothing", GetConVar( "cl_playerclothing" ):GetDefault() )
end
cvars.AddChangeCallback( "cl_playermodel", OnChangeModel )

local function DrawPlayer( pl )
	return false
end
hook.Add( "ShouldDrawLocalPlayer", "PlayerSetDraw", DrawPlayer)

