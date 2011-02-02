
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	if ( self:GetParent() && self:GetParent():IsPlayer() ) then

		self.m_hPlayer = self:GetParent()
		self.m_hParent = self:GetParent()
		self.m_iszModelName = self:GetParent():GetInfo( "cl_playermodel" )

	elseif ( self.m_hPlayer ) then

		self.m_hParent = self:GetParent()

	end

	if (!self.m_hParent) then return end
	if (!self.m_hParent:IsValid()) then return end

	self.m_hParent:SetMaterial( "models/null" )

	// Use the player's model just for the bone positions (because we can't scale player bones)
	local modelname = player_manager.TranslatePlayerModel( self.m_iszModelName )
	util.PrecacheModel( modelname )
	self:SetModel( modelname )

	// Set engine effects
	self:AddEffects( EF_BONEMERGE | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES )
end



