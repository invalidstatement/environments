------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local DEBUGBAR = {}

function DEBUGBAR:Init()
	self:SetMouseInputEnabled(false)
end

function DEBUGBAR:PerformLayout()
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), 24 )
end

function DEBUGBAR:ApplySchemeSettings()
end

function DEBUGBAR:Paint()
	/*local air = SRP.suit.air
	local coolant = SRP.suit.coolant
	local energy = SRP.suit.energy
	local temperature = SRP.suit.temperature
	local o2 = SRP.suit.o2per
	
	local length     = -35 --should make 5 w/ spacer
	local spacer     = 40
	
	surface.SetFont( "Default" )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	draw.RoundedBox(0, 0, 0, ScrW(), 24, Color(0, 0, 0, 150))
	draw.RoundedBox(0, 0, 24, ScrW(), 2, Color(255, 255, 255, 255))

	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Air: " ..tostring(air) )
		local x, y = surface.GetTextSize( "Air: " ..tostring(air) )
		length = length + x + spacer
	
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Coolant: " ..coolant )
		local x, y = surface.GetTextSize( "Coolant: " ..tostring(coolant) )
		length = length + x + spacer
	
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Energy: " .. tostring(energy) )
		local x, y = surface.GetTextSize( "Energy: " .. tostring(energy) )
		length = length + x + spacer
		
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Suit Temp: " .. tostring(SRP.suit.temp) )
		local x, y = surface.GetTextSize( "Suit Temp: " .. tostring(SRP.suit.temp) )
		length = length + x + spacer
		
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Planet: " .. tostring(planet) )
		local x, y = surface.GetTextSize( "Planet: " .. tostring(planet) )
		length = length + x + spacer

	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Temperature: " .. tostring(temperature) )
		local x, y = surface.GetTextSize( "Temperature: " .. tostring(temperature) )
		length = length + x + spacer
		
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "O2 Percent: " .. tostring(o2) )
		local x, y = surface.GetTextSize( "O2 Percent: " .. tostring(o2) )
		length = length + x + spacer*/
end

vgui.Register("LS Debug Bar", DEBUGBAR, "Panel")
