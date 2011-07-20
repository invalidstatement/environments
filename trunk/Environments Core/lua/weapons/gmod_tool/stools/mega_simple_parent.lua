
TOOL.Category = 'Constraints'
TOOL.Name = '#Mega Parent'
TOOL.Command = nil
TOOL.ConfigName = ''

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then
	language.Add( "Tool_mega_simple_parent_name", "Mega Parent" )
	language.Add( "Tool_mega_simple_parent_desc", "Parent Props Together to Reduce Lag." )
	language.Add( "Tool_mega_simple_parent_0", "Left Click to Select all Constrained Props. Right Click to Parent all Selected Props." )
end

function TOOL:LeftClick( trace )
	if trace.Entity then
		if !trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld or trace.Entity:IsNPC() then
			return false
		end
	end
	if CLIENT then return true end
	local cons = constraint.GetAllConstrainedEntities(trace.Entity)
	if cons then
		for k,v in pairs(cons) do
			v:SetColor(100,100,255,150)
		end
	end
	trace.Entity:SetColor(100,255,100,150)
	self.selected = trace.Entity
	--self:Parent(trace.Entity)
	self:GetOwner():SendLua( "GAMEMODE:AddNotify('Parent Selected.', NOTIFY_GENERIC, 7);" )
	return true
end

function TOOL:Parent(ent)
	local Ents = constraint.GetAllConstrainedEntities(ent)
	if Ents then
		for k,v in pairs(Ents) do
			if v and v:IsValid() and v != ent then
				v:GetPhysicsObject():EnableMotion( false ) 
				self:GetOwner():AddFrozenPhysicsObject( v, v:GetPhysicsObject() )
				constraint.RemoveAll(v)
				v:SetParent(ent)
				constraint.Weld(ent, v, 0, 0, 0)
				v:SetSolid(SOLID_VPHYSICS)
				v:SetColor(255,255,255,255)
			end
		end
	end
	ent:SetColor(255,255,255,255)
	self:GetOwner():SendLua( "GAMEMODE:AddNotify('Parenting Completed.', NOTIFY_GENERIC, 7);" )
end

function TOOL:RightClick( trace )
	if CLIENT then return true end
	if self.selected and self.selected:IsValid() then
		self:Parent(self.selected)
	end
	return true
end

function TOOL.BuildCPanel( CPanel )
	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_mega_simple_parent_name", Description	= "#Tool_mega_simple_parent_desc" }  )
end
