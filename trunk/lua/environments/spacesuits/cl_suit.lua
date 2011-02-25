------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local function DrawPlayer( pl )
	return false
end
hook.Add( "ShouldDrawLocalPlayer", "PlayerSetDraw", DrawPlayer)

