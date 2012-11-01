util.AddNetworkString( "PlayerResized" )
util.AddNetworkString( "PlayerDeath" )

// -------------------------------------
// Settings and VGUI stuff
// -------------------------------------
function EnvBigWorld.SetupSettings()
	if(!sql.TableExists("environmentsbigworld")) then
		sql.Query("CREATE TABLE IF NOT EXISTS environmentsbigworld(allow INTEGER, scale INTEGER NOT NULL)")
		sql.Query("INSERT INTO environmentsbigworld(allow, scale) VALUES(0, 1)")
	end

	return sql.QueryRow("SELECT * FROM environmentsbigworld")
end

EnvBigWorld.Config = EnvBigWorld.SetupSettings()

function EnvBigWorld.EscapeNotify(Text)
	local Text = string.Replace(Text, ")", "")
	Text = string.Replace(Text, "(", "")
	Text = string.Replace(Text, "'", "")
	Text = string.Replace(Text, '"', "")
	Text = string.Replace(Text, [[\]], "")
	return Text
end

function EnvBigWorld.Notify( ply, Text )
	ply:SendLua("GAMEMODE:AddNotify(\""..EnvBigWorld.EscapeNotify(Text).."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
	ply:PrintMessage(HUD_PRINTCONSOLE, Text)
end

function EnvBigWorld.AdminReloadPlayer(ply)
	if(!ply or !ply:IsValid()) then
		return
	end
	for k,v in pairs(EnvBigWorld.Config) do
		ply:ConCommand("ebw_"..k.." "..v.."\n")
		if( k == "scale" ) then
			EnvBigWorld.fScale = tonumber(v)
		elseif( k == "allow" ) then
			EnvBigWorld.bAllow = tonumber(v)
		end
	end
	
	EnvBigWorld.PlayerResize( ply )
	ply:Respawn()
end

function EnvBigWorld.AdminReload()
	if(ply) then
		EnvBigWorld.AdminReloadPlayer(ply)
	else
		for k,v in pairs(player.GetAll()) do
			EnvBigWorld.AdminReloadPlayer(v)
		end
	end
end

function EnvBigWorld.ApplySettings( ply, cmd, args )
	if !ply then
		MsgN("This command can only be run in-game!")
	end
	if(!ply:IsAdmin()) then
		return
	end
	
	local allow = tonumber(ply:GetInfo("ebw_allow") or 0)
	local scale = tonumber(ply:GetInfo("ebw_scale") or 1)
	
	sql.Query("UPDATE environmentsbigworld SET allow = "..allow..", scale = "..scale)
	
	EnvBigWorld.Config = sql.QueryRow("SELECT * FROM environmentsbigworld")
	
	timer.Simple( 2, EnvBigWorld.AdminReload )
	
	EnvBigWorld.Notify(ply, "Big World settings have been updated")
end
concommand.Add("ebw_apply", EnvBigWorld.ApplySettings)

// -------------------------------------
// Shrinker Blocker
// -------------------------------------
function EnvBigWorld.BlockShrinker( ply, tr, toolmode )
	if( EnvBigWorld.fScale == 1 ) then return end
	
	if( EnvBigWorld.bAllow == 0 && toolmode == "shrinker" ) then
		return false
	else
		return true
	end
end
hook.Add("CanTool", "EnvBigWorld.BlockShrinker", EnvBigWorld.BlockShrinker)

// -------------------------------------
// Resize
// -------------------------------------
function EnvBigWorld.PlayerResize( ply )
	local scale = 1 / EnvBigWorld.fScale

	ply:SetModelScale( scale, 0 )
	ply:SetStepSize( 18 * scale )
	ply:SetHull( Vector( -16, -16, 0 ) * scale, Vector( 16, 16, 72 ) * scale )
	ply:SetHullDuck( Vector( -16, -16, 0 ) * scale, Vector( 16, 16, 36 ) * scale )
	ply:SetViewOffset( Vector( 0, 0, 64 ) * scale )
	ply:SetViewOffsetDucked( Vector( 0, 0, 28 ) * scale )
	//ply:SetJumpPower( 200 * scale )
	//ply:SetGravity( scale )
	ply:SetWalkSpeed( 200 * scale )
	ply:SetRunSpeed( 320 * scale )
	
	net.Start( "PlayerResized" )
		net.WriteFloat( scale );
		net.WriteEntity( ply )
	net.Broadcast()
	
	game.ConsoleCommand("sv_noclipspeed " .. 5*scale .. "\n")
	game.ConsoleCommand("sv_noclipaccelerate " .. 5*scale .. "\n")
	
	ply:Freeze( false )
end

function EnvBigWorld.PlayerHullFix( ply )
	local scale = 1 / EnvBigWorld.fScale
	
	if( ply.bFirstSpawn && scale == 1 ) then
	timer.Simple( 0.5, 	 function() EnvBigWorld.PlayerHullFix( ply )
									ply.bFirstSpawn = false
									return
								end )
	end
	
	EnvBigWorld.PlayerResize( ply )
	ply:Respawn()
end

function EnvBigWorld.PlayerDeath( ply )
	if( EnvBigWorld.fScale == 1 ) then return end
	local scale = EnvBigWorld.fScale

	if( IsValid( ply:GetRagdollEntity() ) ) then		
		net.Start( "PlayerDeath" )
			net.WriteEntity( ply )
			net.WriteFloat( scale )
		net.Broadcast()
	
		ply:GetRagdollEntity():Remove()
	end
end
hook.Add("PlayerDeath", "EnvBigWorld.PlayerDeath", EnvBigWorld.PlayerDeath)

function EnvBigWorld.OnEntityCreated( xEntity )
	if( EnvBigWorld.fScale == 1 ) then return end
	if( !IsValid( xEntity ) || !EnvBigWorld.fScale || !ShrinkLib  ) then return end
	if( ShrinkLib.aBlackListEnts[ xEntity:GetClass() ] ) then
		xEntity:Remove()
		return
	end

	local aWhiteList = { ["prop_physics"] = true, ["sent_anim"] = true }
	if( aWhiteList[ xEntity:GetClass() ] ) then
		if( xEntity:GetModel() && xEntity:GetPhysicsObject():IsValid() ) then
			local fScale = 1 /  EnvBigWorld.fScale
			ShrinkLib.Shrink( xEntity, fScale )
		else
			timer.Simple( 0.05, function()
									if( xEntity:GetModel() && xEntity:GetPhysicsObject():IsValid() ) then
											local fScale = 1 /  EnvBigWorld.fScale
											ShrinkLib.Shrink( xEntity, fScale )
									end
								end )
		end
	end
end
--hook.Add("OnEntityCreated", "EnvBigWorld.OnEntityCreated", EnvBigWorld.OnEntityCreated)

// -------------------------------------
// Shared Hooks
// -------------------------------------

function EnvBigWorld.PlayerSpawn( ply )
	if( EnvBigWorld.fScale == 1 ) then return end
	ply:Freeze( true )
	timer.Simple( 1.0, function() EnvBigWorld.PlayerHullFix( ply ) end )
	if( IsValid( ply.xOldRagdoll ) ) then ply.xOldRagdoll:Remove() end
end
hook.Add("PlayerSpawn", "EnvBigWorld.PlayerSpawn", EnvBigWorld.PlayerSpawn)

function EnvBigWorld.PlayerInitialSpawn( ply )
	if( EnvBigWorld.fScale == 1 ) then return end
	EnvBigWorld.AdminReload( ply )
	ply:Freeze( true )
	ply.bFirstSpawn = true
	timer.Simple( 1.5, function() EnvBigWorld.PlayerHullFix( ply ) end )
end
hook.Add("PlayerInitialSpawn", "EnvBigWorld.PlayerHullFix", EnvBigWorld.PlayerInitialSpawn)
