//Creates Tools
AddCSLuaFile("autorun/autorun.lua")
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

local whatever
if not Environments then
	Environments = {}
end

function Environments.BuildDupeInfo( ent )
	if ent.IsNode then
		local nettable = ent.connected
		local info = {}
		info.resources = table.Copy(ent.maxresources)
		local entids = {}
		if table.Count(ent.connected) > 0 then
			for k, v in pairs(ent.connected) do
				table.insert(entids, v:EntIndex())
			end
		end
		info.entities = entids
		info.cons = cons
		if info.entities then
			duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
		end
	elseif ent:GetClass() == "env_pump" then
		local info = {}
		info.pump = ent.pump_active
		info.rate = ent.pump_rate
		info.hoselength = ent.hose_length
		duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
	end
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		local DupeInfo = ent.EntityMods.EnvDupeInfo
		if ent.IsNode then
			if DupeInfo.resources then
				ent.maxresources = DupeInfo.resources
				ent:Initialize()
			end
			if DupeInfo.entities and table.Count(DupeInfo.entities) > 0 then
				for _,ID in pairs(DupeInfo.entities) do
					local ent2 = CreatedEntities[ID]
					if ent2 and ent2:IsValid() then
						ent:Link(ent2)
						ent2:Link(ent)
					end
				end
			end
			ent.EntityMods.EnvDupeInfo = nil //trash this info, we'll never need it again
		elseif ent:GetClass() == "env_pump" then
			ent:Setup( DupeInfo.pump, DupeInfo.rate, DupeInfo.hoselength )
			ent.EntityMods.EnvDupeInfo = nil
		end
	end
end

local models = {}
function Environments.GetScreenInfo(model)
	local info = {}
	for k,v in pairs(models) do
		if k == model then
			return v
		end
	end
end

function Environments.RegisterModelScreenData(model, offset, angle, height, width)
	models[model] = {}
	models[model].Offset = offset
	models[model].Angle = angle
	models[model].X = width
	models[model].Y = height
end

function Environments.Create_Beam(ent, localpos, forward, mat)
	ent:SetNWVector("CableForward", forward)
	ent:SetNWVector("CablePos", localpos)
	ent:SetNWString("CableMat",  mat)
end

Environments.RegisterModelScreenData("models/punisher239/punisher239_reactor_small.mdl", Vector(-110,0,50), Angle(0,30,270), 0, 0)

if CLIENT then
	local resolution = 0.1
	local startpos, endpos, endpos2, cyl
	function Environments.DrawCable(ent, p1, p1f, p2, p2f)--FIX THIS!!! the cable is FLAT!
		ent.mesh = NewMesh()
		local tab = {}
		for mu = 0, 1 - resolution, resolution do
			startpos =  Vector( ( p2.x - p1.x ) * mu + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu ) )
			endpos = Vector( ( p2.x - p1.x ) * ( mu + resolution ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu + resolution ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu + resolution ) )
			
			if ( mu + resolution >= 1 ) then
				endpos2 = p2 - p1f * 100
			else
				endpos2 = Vector( ( p2.x - p1.x ) * ( mu + resolution*2 ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0, 0, mu + resolution*2 ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0, 0, mu + resolution*2 ) )
			end
			
			cyl = GenerateCylinder( startpos, endpos - startpos, endpos, endpos2 - endpos, 1.3 )
			for k,v in pairs(cyl) do
				table.insert(tab, v)
			end
		end
		ent.mesh:BuildFromTriangles(tab)
	end
	
	local ang
	function getStartPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end

	local ang
	function getEndPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end
	
	local angle, ang
	function GenerateCylinder( p1, d1, p2, d2, radius, segments )
		segments = segments or 10
		angle = 360 / segments
		local tab = {}	
		for i = 0, segments - 1 do
			ang = i * angle
			--local inside = MeshQuad(getStartPosition( p1, d1, ang, radius ),getStartPosition( p1, d1, ang + angle, radius ),getEndPosition( p2, d2, ang + angle, radius ),getEndPosition( p2, d2, ang, radius ), 1)
			-- Outside
			local outside = MeshQuad(getEndPosition( p2, d2, ang, radius ),getEndPosition( p2, d2, ang + angle, radius ),getStartPosition( p1, d1, ang + angle, radius ),getStartPosition( p1, d1, ang, radius ), 1)

			--for k,v in pairs(inside) do
			--	table.insert(tab, v)
		--	end
			for k,v in pairs(outside) do
				table.insert(tab, v)
			end
		end
		return tab
	end
	
	local m0, m1, mu2, mu3
	local a0, a1, a2, a3
	function hermiteInterpolate( y1, y2, y3, y4, tension, bias, mu )	
		mu2 = mu * mu
		mu3 = mu2 * mu
		m0 = ( y2 - y1 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y3 - y2 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		m1 = ( y3 - y2 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y4 - y3 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		a0 = 2 * mu3 - 3 * mu2 + 1
		a1 = mu3 - 2 * mu2 + mu
		a2 = mu3 - mu2
		a3 = -2 * mu3 + 3 * mu2
		
		return a0 * y2 + a1 * m0 + a2 * m1 + a3 * y3
	end
end

print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")