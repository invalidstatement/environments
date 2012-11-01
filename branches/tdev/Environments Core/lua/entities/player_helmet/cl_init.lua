
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

function ENT:DrawTranslucent()
	self:Draw()
end

/*------------------------------------------------------------
	Does the actual bone scaling work. This function is made
	to work with copied bones too (realboneid).
------------------------------------------------------------*/
local function BoneScale( self, realboneid )
	if self:GetBoneName(realboneid) == "ValveBiped.Bip01_Head1" then return end
	local matBone = self:GetBoneMatrix( realboneid )
	if matBone then
		print("found bone")
		matBone:Scale( Vector( 0, 0, 0 ) )
		self:SetBoneMatrix( realboneid, matBone )
	end
end

/*---------------------------------------------------------
   Name: BuildBonePositions
   Desc:
---------------------------------------------------------*/
function ENT:BuildBonePositions( NumBones, NumPhysBones )
	print("hi")
	for i=0, NumBones do
		BoneScale( self, i )
	end
end

