------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local VGUI = {}

function VGUI:Init()

end

function VGUI:PerformLayout()
	self:SetPos(300,300)
	self:SetSize( 400, 300 )
end

function VGUI:ApplySchemeSettings()

end

function VGUI:Paint()
	//outer frame
	draw.RoundedBox(16,0,0,self:GetWide(),self:GetTall(), Color(60,60,60,255))
	
	//inner frame
	draw.RoundedBox(16,6,6,self:GetWide()-12,self:GetTall()-12,Color(220,220,220,255))
	return true
end
vgui.Register("WristComputer", VGUI, "Panel")

--vgui.Create("WristComputer")
