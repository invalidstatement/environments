
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Environment"
ENT.Author = "CmdrMatthew"

if CLIENT then
	function ENT:Draw()
		//local radius = self:GetRadius() * 10
		if not Environments.EffectsCvar:GetBool() then return end
		
		local radius = 3000
		local pos = self:GetPos()
		local BeamRadius = radius * 6
     
		-- calculate brightness.
		local dot = math.Clamp( EyeAngles():Forward():DotProduct( ( pos - EyePos() ):Normalize() ), 0, 1 )
		local dist = ( pos - EyePos() ):Length()
     
		-- draw sunbeams.
		local sunpos = EyePos() + ( pos - EyePos() ):Normalize() * ( dist * 0.5 )
		local scrpos = sunpos:ToScreen()
			 
		if( dist <= BeamRadius && dot > 0 ) then
			local frac = ( 1 - ( dist / BeamRadius )) * dot
     
			-- draw sun.
			DrawSunbeams(0.25, frac, 0.055, scrpos.x / ScrW(), scrpos.y / ScrH())//change 3rd arg to 0.055
        end
    end
end
