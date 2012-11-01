------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local function DrawPlayer( pl )
	return false
end
hook.Add( "ShouldDrawLocalPlayer", "PlayerSetDraw", DrawPlayer)

//Player bones are wierd, they are based on thier scale times their parent's scale so 0.5 the child x0.5 for the parent
//the child would be scaled 0.25
/*function MakeSuitReady()
	for k,v in pairs(player.GetAll()) do
		function v:BuildBonePositions( NumBones, NumPhysBones )
			local realboneid = self:LookupBone("ValveBiped.Bip01_Head1")
			local pos, angles = self:GetBonePosition(realboneid)
			for i=0, NumBones do
				BoneScale( self, i )
			end
			local matBone = self:GetBoneMatrix( realboneid )
			matBone:Scale( Vector( 12, 12, 12 ) )
			self:SetBoneMatrix( realboneid, matBone )
			self:SetBonePosition(realboneid, pos, angles)
		end
	end
end
timer.Create("suitsstuff", 10, 0, MakeSuitReady)

function BoneScale( self, realboneid )
	if self:GetBoneName(realboneid) == "ValveBiped.Bip01_Head1" then return end
	local matBone = self:GetBoneMatrix( realboneid )
	if matBone then
		matBone:Scale( Vector( 0.75, 0.75, 0.75 ) )
		self:SetBoneMatrix( realboneid, matBone )
	end
end*/

// ---------------------------------------------------
// Gravity Hull Designator Support
// ---------------------------------------------------

local aPlayersInGHD = {}
local function EnvGHDRenderSuit()
	for i, xPlayer in pairs( aPlayersInGHD ) do
		local xData = GravHull.SHIPCONTENTS[ xPlayer ]
		if !xData then continue end
		local vLocalPosition, vLocalAngle = WorldToLocal( EyePos(), RenderAngles(), xData.S:GetPos(), xData.S:GetAngles() )
		cam.Start3D( LocalToWorld( vLocalPosition, vLocalAngle, xData.G.RealPos or xData.G:GetRealPos(), xData.G.RealAng or xData.G:GetRealAngles() ) )
			if( IsValid( xPlayer.m_hSuit ) ) then	
				xPlayer.m_hSuit:SetupBones()
				xPlayer.m_hSuit:DrawModel()
			end
			
			if( IsValid( xPlayer.m_hHelmet ) ) then
				xPlayer.m_hHelmet:SetupBones()
				xPlayer.m_hHelmet:DrawModel()
			end
		cam.End3D()
	end
end

local nPlayersInGHD = 0
local bHookActive = false

local function CleanupPlayersInGHDList()
	for i, xPlayer in pairs( aPlayersInGHD ) do
		local bValid = false
		for i, xConnectedPlayer in pairs( player.GetAll() ) do
			if( xPlayer == xConnectedPlayer ) then bValid = true end
		end
		
		if( !bValid ) then
			for i, xElement in pairs( aPlayersInGHD ) do
				if( xElement == xPlayer ) then
					table.remove( aPlayersInGHD, i )
				end
			end
	
			nPlayersInGHD = nPlayersInGHD - 1
			if( nPlayersInGHD == 0 && bHookActive ) then
				aPlayersInGHD = {}
				
				hook.Remove( "PostDrawOpaqueRenderables", "EnvGHDRenderSuit" )
				bHookActive = false
			end
		end
	end
end

local function EnvGHDPlayerEnteredShip( len )
	local xPlayer = net.ReadEntity()
	if( IsValid( xPlayer ) && xPlayer:IsPlayer() ) then
		xPlayer.m_hSuit = net.ReadEntity()
		xPlayer.m_hHelmet = net.ReadEntity()
		table.insert( aPlayersInGHD, xPlayer )
		
		nPlayersInGHD = nPlayersInGHD + 1
		if( nPlayersInGHD == 1 && !bHookActive ) then
			hook.Add( "PostDrawOpaqueRenderables", "EnvGHDRenderSuit", EnvGHDRenderSuit )
			bHookActive = true
		end
	end
	
	CleanupPlayersInGHDList()
end
net.Receive("EGHDPEnS", EnvGHDPlayerEnteredShip)

local function EnvGHDPlayerExitedShip( len )
	local xPlayer = net.ReadEntity()
	if( IsValid( xPlayer ) && xPlayer:IsPlayer() ) then
		for i, xElement in pairs( aPlayersInGHD ) do
			if( xElement == xPlayer ) then
				table.remove( aPlayersInGHD, i )
			end
		end
		
		nPlayersInGHD = nPlayersInGHD - 1
		if( nPlayersInGHD == 0 && bHookActive ) then
			aPlayersInGHD = {}
			
			hook.Remove( "PostDrawOpaqueRenderables", "EnvGHDRenderSuit" )
			bHookActive = false
		end
		
		CleanupPlayersInGHDList()
	end
end
net.Receive("EGHDPExS", EnvGHDPlayerExitedShip)