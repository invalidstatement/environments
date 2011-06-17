include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local ResourceUnits = {}
ResourceUnits["energy"] = " Joules"
ResourceUnits["water"] = " L"
ResourceUnits["oxygen"] = " L"
ResourceUnits["hydrogen"] = " L"
ResourceUnits["nitrogen"] = " L"
ResourceUnits["carbon dioxide"] = " L"

local ResourceNames = {}
ResourceNames["energy"] = "Energy"
ResourceNames["water"] = "Water"
ResourceNames["oxygen"] = "Oxygen"
ResourceNames["hydrogen"] = "Hydrogen"
ResourceNames["nitrogen"] = "Nitrogen"
ResourceNames["carbon dioxide"] = "CO2"

surface.CreateFont( "arial", 60, 600, true, false, "ConflictText" )
surface.CreateFont( "arial", 40, 600, true, false, "Flavour" )

function ENT:Draw( bDontDrawModel )
	self:DoNormalDraw()

	if (Wire_Render) then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent( bDontDrawModel )
	if ( bDontDrawModel ) then return end
	self:Draw()
end

function ENT:DoNormalDraw( bDontDrawModel )
	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
		--overlaysettings
		local node = self
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()]
		local HasOOO = OverlaySettings.HasOOO
		local num = OverlaySettings.num or 0
		local strings = OverlaySettings.strings
		local resnames = OverlaySettings.resnames
		--End overlaysettings
		local trace = LocalPlayer():GetEyeTrace()
		if ( !bDontDrawModel ) then self:DrawModel() end
		local nettable = {} --CAF.GetAddon("Resource Distribution").GetEntityTable(self)
		--if table.Count(nettable) <= 0 then return end
		local playername = self:GetPlayerName()
		if playername == "" then
			playername = "World"
		end
		-- 0 = no overlay!
		-- 1 = default overlaytext
		-- 2 = new overlaytext

		if not mode or mode != 2 then
			local OverlayText = ""
				OverlayText = OverlayText ..self.PrintName.."\n"
			if not node:IsValid() then
				OverlayText = OverlayText .. "Not connected to a network\n"
			else
				OverlayText = OverlayText .. "Network " .. tostring(node:EntIndex()) .."\n"
			end
			OverlayText = OverlayText.."\n"
			local resources = self.resources
			if num == -1 then
				if ( table.Count(resources) > 0 ) then
					for k, v in pairs(resources) do
						if node then
							OverlayText = OverlayText ..ResourceNames[k]..": ".. node:GetNWInt(k, 0) .."/".. 0 .."\n" .. ResourceUnits[k]
						else
							OverlayText = OverlayText ..ResourceNames[k]..": ".. 0 .."/".. 0 .."\n"
						end
					end
				else
					OverlayText = OverlayText .. "No Resources Connected\n"
				end
			else
				if resnames and table.Count(resnames) > 0 then
					for _, k in pairs(resnames) do
						if node then
							OverlayText = OverlayText ..ResourceNames[k]..": ".. node:GetNWInt(k, 0) .."/".. node:GetNWInt("max"..k, 0) .. ResourceUnits[k] .."\n"
						else
							OverlayText = OverlayText ..ResourceNames[k]..": ".. 0 .."/".. self.maxresources[k] .."\n"
						end
					end
				end
			end
			OverlayText = OverlayText .. "(" .. playername ..")"
			AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self  )
		end
	else
		if ( !bDontDrawModel ) then self:DrawModel() end
	end
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end
