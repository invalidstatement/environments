include('shared.lua')

function ENT:Draw()
	if self:GetOOO() > 0 then
		local trace = {}
		trace.start = self:GetPos()+Vector(25,0,0)	
		trace.endpos = self:GetPos()+(self:GetForward()*512)
		trace.filter = self
		local tr = util.TraceLine( trace )
		
		render.DrawBeam( self:GetPos()+Vector(5,0,1), tr.HitPos or trace.endpos, 3, 0, 1, Color(255,155,155,255) )
	end
	self:DrawModel()
end
