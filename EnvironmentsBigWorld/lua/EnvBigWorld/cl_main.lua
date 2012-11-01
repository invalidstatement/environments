// -------------------------------------
// Settings and VGUI stuff
// -------------------------------------
EnvBigWorld.AdminCPanel = nil

CreateClientConVar("ebw_allow", 0, false, true)
CreateClientConVar("ebw_scale", 1, false, true)

function EnvBigWorld.AdminPanel(Panel)
	Panel:ClearControls()
	
	if(!LocalPlayer():IsAdmin()) then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	
	if(!EnvBigWorld.AdminCPanel) then
		EnvBigWorld.AdminCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "Big World for Environments\n by Tingle and Matthew"})
	
	Panel:AddControl("CheckBox", {Label = "Allow Shrinker STool", Command = "ebw_allow"})
	Panel:AddControl("Slider", {Label = "World Scale", Command = "ebw_scale", Type = "Integer", Min = "1", Max = "5"})
	Panel:AddControl("Button", {Text = "Apply and Save Settings", Command = "ebw_apply"})
end

function EnvBigWorld.SpawnMenuOpen()
	if(EnvBigWorld.AdminCPanel) then
		EnvBigWorld.AdminPanel(EnvBigWorld.AdminCPanel)
	end
end
hook.Add("SpawnMenuOpen", "EnvBigWorld.SpawnMenuOpen", EnvBigWorld.SpawnMenuOpen)

function EnvBigWorld.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Environments", "Config", "Big World", "#Big World", "", "", EnvBigWorld.AdminPanel)
end
hook.Add("PopulateToolMenu", "EnvBigWorld.PopulateToolMenu", EnvBigWorld.PopulateToolMenu)

// -------------------------------------
// Resize
// -------------------------------------
function EnvBigWorld.ClPlayerResize( len )
	local nScale = net.ReadFloat()
	local xPlayer = net.ReadEntity()
	if( IsValid( xPlayer ) ) then
		xPlayer:SetModelScale( nScale, 0 )
		xPlayer:SetHull( Vector( -16, -16, 0 ) * nScale, Vector( 16, 16, 72 ) * nScale )
		xPlayer:SetHullDuck( Vector( -16, -16, 0 ) * nScale, Vector( 16, 16, 36 ) * nScale )
	end
end
net.Receive("PlayerResized", EnvBigWorld.ClPlayerResize)

function EnvBigWorld.UpdateAnimation( ply, vel, max )
	local scale = 1 / tonumber( ply:GetInfo("ebw_scale") )
	
	ply.scale_cycle = tonumber(tostring(ply.scale_cycle)) and ply.scale_cycle or 0
	ply.scale_cycle =  (ply.scale_cycle or 0 ) + (vel:Length() * FrameTime() * (1/scale * 0.01) )
	ply:SetCycle( ply.scale_cycle )

	if( ply:GetVelocity():Length() > (100 * scale) ) then
		local sCurrentSequence = ply:GetSequenceName( ply:GetSequence() )
		sCurrentSequence = string.gsub( sCurrentSequence, "walk", "run" )
		ply:SetSequence( ply:LookupSequence( sCurrentSequence ) )
	end
end
hook.Add("UpdateAnimation", "EnvBigWorld.UpdateAnimation", EnvBigWorld.UpdateAnimation )

function EnvBigWorld.PlayerFootstep( ply, pos, foot, sound, volume, rf )
	local scale = 1 / tonumber( ply:GetInfo("ebw_scale") )
	if scale < 0.2 then
		ply:EmitSound("npc/fast_zombie/foot2.wav", 40, math.random(170, 200))
		return true
	else
		ply:EmitSound(sound, 60, math.Clamp((1/scale)*255, 0,255))
	end
end
hook.Add("PlayerFootstep", "EnvBigWorld.PlayerFootstep", EnvBigWorld.PlayerFootstep )

function EnvBigWorld.PlayerStepSoundTime(ply, iType, bWalking )
	local scale = 1 / tonumber( ply:GetInfo("ebw_scale") )
	local fStepTime = 350
	local fMaxSpeed = ply:GetMaxSpeed()

	if ( iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT ) then
		if ( fMaxSpeed <= 100 ) then
			fStepTime = 400
		elseif ( fMaxSpeed <= 300 ) then
			fStepTime = 350
		else
			fStepTime = 250
		end

	elseif ( iType == STEPSOUNDTIME_ON_LADDER ) then

		fStepTime = 450

	elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then

		fStepTime = 600

	end

	if ( ply:Crouching() ) then
		fStepTime = fStepTime + 50
	end

	return fStepTime * scale
end
hook.Add("PlayerStepSoundTime", "EnvBigWorld.PlayerStepSoundTime", EnvBigWorld.PlayerStepSoundTime )

function EnvBigWorld.ClPlayerDeath( len )
	local xPlayer = net.ReadEntity()
	local fScale = net.ReadFloat()
	local effectdata = EffectData()

	local aBoneList = {	"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_L_Thigh" }
	for i, sBone in pairs(aBoneList) do	
		local vPoint = xPlayer:GetBonePosition( xPlayer:LookupBone(sBone) )
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 20 * fScale )
		util.Effect( "inflator_magic", effectdata )
	end
end
net.Receive("PlayerDeath", EnvBigWorld.ClPlayerDeath)