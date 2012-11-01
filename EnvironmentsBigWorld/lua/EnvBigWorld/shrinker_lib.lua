ShrinkLib = {}

ShrinkLib.aBlackListEnts = { ["prop_vehicle_jeep"] = true, ["prop_vehicle_jeep_old"] = true, ["prop_vehicle_airboat"] = true, ["prop_ragdoll"] = true }
ShrinkLib.aMotionControlledEnts = { ["gmod_hoverball"] = true, ["gmod_thuster"] = true, ["gmod_masslessthruster"] = true }

local aBlackListEnts = ShrinkLib.aBlackListEnts
local aMotionControlledEnts = ShrinkLib.aMotionControlledEnts
if( SERVER ) then
	util.AddNetworkString( "EntPhysUpdate" )
	
	function ShrinkLib.Shrink( xEntity, fScale )
		if( true ) then return end // waiting on GetConvexMesh( nIndex ) hell no to the current concav GetMesh() ....
		if( !(xEntity:IsValid() && xEntity:GetPhysicsObject():IsValid()) || aBlackListEnts[aBlackListEnts] ) then return end
		
		xEntity:SetModelScale( fScale, 0 )
		
		local xPhysObj = xEntity:GetPhysicsObject()
		local xMesh = xEntity:GetPhysicsObject():GetMesh()
		
		local aMultiConvex = {}
		local aTempConvex = {}
		local nCount = 0
		
		for k,v in pairs( xMesh ) do
			v.pos = v.pos * fScale
			
			if( nCount < 32 ) then
				table.insert( aTempConvex, v )
				nCount = nCount +1
			else
				table.insert( aMultiConvex, aTempConvex )
				aTempConvex = {}
				nCount = 0
			end
			
			if( nCount == 32 && !aMultiConvex[0] ) then
				table.insert( aMultiConvex, aTempConvex )
				aTempConvex = {}
				nCount = 0
			end			
		end
		
		xEntity:PhysicsInitMultiConvex( aMultiConvex )
		xEntity:EnableCustomCollisions()
		
		if( aMotionControlledEnts[ xEntity:GetClass()] ) then
			xEntity:StartMotionController()
		end
		
		net.Start( "EntPhysUpdate" )
			net.WriteFloat( fScale );
			net.WriteEntity( xEntity )
		net.Broadcast()
	end
end

if( CLIENT ) then
	function ShrinkLib.EntPhysUpdate( len )
	end
	net.Receive("EntPhysUpdate", ShrinkLib.EntPhysUpdate)
end