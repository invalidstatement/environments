
include('shared.lua')

function ENT:Initialize()
	self.BuildBonePositions = self.BuildBonePositions
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	self:DrawModel()
	self:DrawShadow( false )
end

/*------------------------------------------------------------
	Does the actual bone scaling work. This function is made
	to work with copied bones too (realboneid).
------------------------------------------------------------*/
local function BoneScale( self, realboneid )
	local matBone = self:GetBoneMatrix( realboneid )
	matBone:Scale( Vector( 0, 0, 0 ) )
	self:SetBoneMatrix( realboneid, matBone )
end

/*---------------------------------------------------------
   Name: BuildBonePositions
   Desc:
---------------------------------------------------------*/
function ENT:BuildBonePositions( NumBones, NumPhysBones )
	local realboneid = self:LookupBone( "ValveBiped.Bip01_Head1" )
	BoneScale( self, realboneid )
end

