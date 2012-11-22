
local Beam = Material("particles/flamelet1")

Beam:SetInt("$spriterendermode",0)

Beam:SetInt("$illumfactor",8)
Beam:SetFloat("$alpha",0.9)



/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.Start = data:GetStart()
	self.RightAngle = data:GetNormal():Angle():Right()
	self.BeamWidth = 16
	self.TimeLeft = CurTime() + 2
	self.Alpha = 1
	self.Entity:SetRenderBounds( Vector()*-8192, Vector()*8192 )	
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	local Pos = self.Position
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		self.Fade = (timeleft / 2)
		
		return true
	else
		return false	
	end
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	local pos = self.Position
	local pos2 = self.Start
	
	if self.Fade == nil then self.Fade = 0 end
	Beam:SetFloat("$alpha",self.Fade)
	Beam:SetVector("$color",Vector(1, 1, 1))
	//render.SetMaterial(Beam)
	

	//local start1 = pos+(self.RightAngle*(self.BeamWidth*self.Fade))
	//local start2 = pos-(self.RightAngle*(self.BeamWidth*self.Fade))
	
	//local end1 = pos2+(self.RightAngle*(self.BeamWidth*self.Fade))
	//local end2 = pos2-(self.RightAngle*(self.BeamWidth*self.Fade))
	//end1 = end1 + ((self.RightAngle*(pos:Distance(pos2) / 16))*self.Fade)
	//end2 = end2 - ((self.RightAngle*(pos:Distance(pos2) / 16))*self.Fade)
		
	//render.DrawQuad(start1, end1, end2, start2)
	//render.DrawQuad(start2, end2, end1, start1)
	
	render.DrawBeam( pos, pos2, 3, 0, 1, Color(255,155,155,255) )

	
end
