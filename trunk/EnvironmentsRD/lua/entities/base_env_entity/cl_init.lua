include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

--ENT.ScreenAngles = Angle(0,0,0)
--ENT.ScreenAngles.r = 270
--ENT.ScreenAngles.y = 30
/*] dev_setentvar ScreenAngles.Y 0
] dev_setentvar ScreenAngles.R 45 
] dev_setentvar ScreenAngles.P 270*/

--ENT.ScreenPos = Vector(-110,0,50)

local OOO = {}
OOO[0] = "Off"
OOO[1] = "On"
OOO[2] = "Overdrive"

local ResourceUnits = {}
ResourceUnits["energy"] = " Kj"
ResourceUnits["water"] = " L"
ResourceUnits["oxygen"] = " L"
ResourceUnits["hydrogen"] = " L"
ResourceUnits["nitrogen"] = " L"
ResourceUnits["carbon dioxide"] = " L"
ResourceUnits["steam"] = " L"

local ResourceNames = {}
ResourceNames["energy"] = "Energy"
ResourceNames["water"] = "Water"
ResourceNames["oxygen"] = "Oxygen"
ResourceNames["hydrogen"] = "Hydrogen"
ResourceNames["nitrogen"] = "Nitrogen"
ResourceNames["carbon dioxide"] = "CO2"
ResourceNames["steam"] = "Steam"
 
function ENT:Initialize()
	local info = nil
	if Environments.GetScreenInfo then
		info = Environments.GetScreenInfo(self:GetModel())
	end
	if info then
		self.ScreenMode = true
		self.ScreenAngles = info.Angle
		self.ScreenPos = info.Offset
	end
end

function ENT:Draw( bDontDrawModel )
	self:DoNormalDraw()
	
	local node = self:GetNWEntity("node")
	if node and node:IsValid() and self:GetNWVector("CablePos") != Vector(0,0,0) then
		if self:GetPos() != self.LastPos or node:GetPos() != node.LastPos then
			Environments.DrawCable(self, self:LocalToWorld(self:GetNWVector("CablePos", Vector(0,0,0))), self:LocalToWorld(self:GetNWVector("CableForward", Vector(0,1,0))):Normalize(), node:GetPos(), node:GetAngles():Forward())
			node.LastPos = node:GetPos()
			self.LastPos = self:GetPos()
		end
		
		if self.mesh then
			if !self.Material or self.Material:GetName() != self:GetNWString("CableMat", "models/wireframe") then self.Material = Material( self:GetNWString("CableMat", "models/wireframe") ) end
			render.SetMaterial( self.Material )
			self.mesh:Draw()
		end
	end

	if (Wire_Render) then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent( bDontDrawModel )
	if ( bDontDrawModel ) then return end
	self:Draw()
end

function ENT:GetOOO()
	return self:GetNetworkedInt("OOO") or 0
end

function ENT:DoNormalDraw( bDontDrawModel )
	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
		--overlaysettings
		local node = self:GetNWEntity("node")
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
		local HasOOO = OverlaySettings.HasOOO
		local num = OverlaySettings.num or 0
		local resnames = OverlaySettings.resnames
		local genresnames = OverlaySettings.genresnames
		--End overlaysettings
		
		if ( !bDontDrawModel ) then self:DrawModel() end
		
		local playername = self:GetPlayerName()
		if playername == "" then
			playername = "World"
		end
		-- 0 = no overlay!
		-- 1 = default overlaytext
		-- 2 = new overlaytext
		if not self.ScreenMode then
			local OverlayText = ""
				OverlayText = OverlayText ..self.PrintName.."\n"
			if not node:IsValid() then
				OverlayText = OverlayText .. "Not connected to a network\n"
			else
				OverlayText = OverlayText .. "Network " .. tostring(node:EntIndex()) .."\n"
			end
			if HasOOO then
				local runmode = "UnKnown"
				if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
					runmode = OOO[self:GetOOO()]
				end
				OverlayText = OverlayText .. "Mode: " .. runmode .."\n"
			end
			OverlayText = OverlayText.."\n"
			local resources = self.resources
			if num == -1 then
				if ( table.Count(resources) > 0 ) then
					for k, v in pairs(resources) do
						if node then
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. node:GetNWInt(k, 0) .."/".. 0 .."\n" .. (ResourceUnits[k] or "")
						else
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. 0 .."/".. 0 .."\n"
						end
					end
				else
					OverlayText = OverlayText .. "No Resources Connected\n"
				end
			else
				if resnames and table.Count(resnames) > 0 then
					for _, k in pairs(resnames) do
						if node then
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. node:GetNWInt(k, 0) .."/".. node:GetNWInt("max"..k, 0) .. (ResourceUnits[k] or "") .."\n"
						else
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. 0 .."/".. self.maxresources[k] .."\n"
						end
					end
				end
				if genresnames and table.Count(genresnames) > 0 then
					OverlayText = OverlayText.."\nGenerates:\n"
					for _, k in pairs(genresnames) do
						if node then
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. node:GetNWInt(k, 0) .."/".. node:GetNWInt("max"..k, 0).. (ResourceUnits[k] or "") .."\n"
						else
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. 0 .."/".. 0 .."\n"
						end
					end
				end
			end
			OverlayText = OverlayText .. "(" .. playername ..")"
			AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self  )
		else
			local rot = Vector(0,0,90)
			local TempY = 0
			local maxvector = self:OBBMaxs()
			local getpos = self:GetPos()
			
			//SetPosition
			local pos = getpos + (self:GetRight() * self.ScreenPos.y) //y-axis
			pos = pos + (self:GetUp() * self.ScreenPos.z) //z-axis
			pos = pos + (self:GetForward() * self.ScreenPos.x) //x-axis
			
			//Set Angles
			local angle = self:GetAngles()
			angle:RotateAroundAxis(self:GetRight(),self.ScreenAngles.p)
			angle:RotateAroundAxis(self:GetForward(),self.ScreenAngles.y)
			angle:RotateAroundAxis(self:GetUp(),self.ScreenAngles.r)

			local textStartPos = -625 --used for centering
			local stringUsage = ""
			cam.Start3D2D(pos,angle,0.03)
				local status, error = pcall(function()
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect( textStartPos, 0, 1250, 500 )

				surface.SetDrawColor(155,155,155,255)
				surface.DrawRect( textStartPos, 0, -5, 500 )
				surface.DrawRect( textStartPos, 0, 1250, -5 )
				surface.DrawRect( textStartPos, 500, 1250, -5 )
				surface.DrawRect( textStartPos+1250, 0, 5, 500 )
				
				--local x, y = GetMousePos(LocalPlayer():GetEyeTrace().HitPos, pos, 0.03, angle) --test cursor
				--surface.DrawRect( x, y, 50,50)
				
				TempY = TempY + 10
				surface.SetFont("ConflictText")
				surface.SetTextColor(255,255,255,255)
				surface.SetTextPos(textStartPos+15,TempY)
				surface.DrawText(self.PrintName)
				TempY = TempY + 70
				
				if HasOOO then
					local runmode = "UnKnown"
					if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
						runmode = OOO[self:GetOOO()]
					end
					surface.SetFont("Flavour")
					surface.SetTextColor(155,155,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Mode: "..runmode)
					TempY = TempY + 50
				end
				
				if #genresnames == 0 and #resnames == 0 then
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("No resources connected")
					TempY = TempY + 70
				else
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Resources: ")
					TempY = TempY + 50
				end
			
				if ( table.Count(resnames) > 0 ) then		
					for k, v in pairs(resnames) do
						stringUsage = stringUsage.."["..ResourceNames[v]..": "..node:GetNWInt(v, 0) .."/".. node:GetNWInt("max"..v, 0).."] "
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end
				if ( table.Count(genresnames) > 0 ) then
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Generates: ")
					TempY = TempY + 50
					for k, v in pairs(genresnames) do
						stringUsage = stringUsage.."["..ResourceNames[v]..": "..node:GetNWInt(v, 0) .."/".. node:GetNWInt("max"..v, 0).."] "
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end end)
				if error then print(error) end
			cam.End3D2D()
		end
	else
		if ( !bDontDrawModel ) then self:DrawModel() end
	end
end

function GetMousePos(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end
