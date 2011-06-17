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
