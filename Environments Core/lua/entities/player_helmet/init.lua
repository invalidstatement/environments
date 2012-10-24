
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
	if self:GetParent():IsPlayer() then --makes sure the helmet stays on when parenting to the death ragdoll.
		local modelname = player_manager.TranslatePlayerModel( self.m_iszModelName )
		util.PrecacheModel( modelname )
		self:SetModel( modelname )
	end

	self:AddEffects( bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES) )
end



