//MAKE IT LIKE GAUGES WITH DRAW.ROUNDED BOX :D :D :D and digital ones too!!!
surface.CreateFont( "digital-7", 36, 2, true, false, "lcd2" )
function LoadHud()
	function Draw()
		local alpha = 255
		local max = 4000
		local speed = SRP.suit.energy
		local per = speed/max
		local a = Vector(ScrW()-110,ScrH()-8,0)
		local s = math.ceil(ScrW()/12/8)*8
		s = s
		
		draw.NoTexture()
		--surface.SetMaterial(Material("phoenix_storms/black_chrome"))
		--surface.SetDrawColor(100,100,100,alpha)
		draw.RoundedBox(16,a.x-58,a.y-92,168,100, Color(50,50,255,alpha))
		--surface.DrawTexturedRect(a.x-58,a.y-43,166,43)
		--surface.SetDrawColor(220,220,220,alpha)
		--surface.DrawTexturedRect(a.x-55,a.y-40,160,40)
		draw.RoundedBox(16,a.x-54,a.y-88,160,92,Color(220,220,220,alpha))--16 first
		draw.NoTexture()
		
		surface.SetDrawColor(0,0,0,alpha)
		/*surface.DrawPoly{
		{
			x = a.x - s*.5,
			y = a.y - s*.125,
		},
		{
			x = a.x + s*.2,
			y = a.y - s *.3,
		},
		{
			x = a.x + s*.5,
			y = a.y - s *.3,
		},
		{
			x = a.x + s*.5,
			y = a.y,
		},
		{
			x = a.x - s*.5,
			y = a.y,
		},
		}*/
	
		
		/*for i = 0,11 do
			/*if i < s/48 then
				surface.SetDrawColor(0,0,255,alpha)
			elseif i < s / 10 then
				surface.SetDrawColor(0,255,0,alpha)
			elseif i < s / 7 then
				surface.SetDrawColor(255,255,0,alpha)
			else
				surface.SetDrawColor(255,0,0,alpha)
			end
			if i/11 > per then
				surface.SetDrawColor(200,200,200,255)
			else
				surface.SetDrawColor(0,0,0,255)
			end
		
			//surface.DrawRect(a.x-s*.5+6*i+1,a.y-s,4,s)
			/*
				.3-.125
				.175
				s*.7
			
		
			local x = s*.5+6*i
			local c = 1-s
			local v = s/128
			local b = -s/32
				surface.DrawPoly{
					{
						x = a.x + c+x,
						y = a.y - x*.25+v,
					},
					{
						x = a.x + c+x+4,
						y = a.y - (x+4)*.25+v,
					},
					{
						x = a.x + c+x+4,
						y = a.y+b,
					},
					{
						x = a.x + c+x,
						y = a.y+b,
					},
				}
		end*/
		local speedstr = ""
		if SRP.suit.air/max >= .10 then
			speedstr = tostring(math.Round(SRP.suit.air*100/max))
		else
			speedstr = tostring(math.Round(SRP.suit.air*100)/max)
			if not string.find(speedstr,"%.") then
				speedstr = speedstr .. ".0"
			end
		end
		local energystr = ""
		if SRP.suit.energy/4000 >= .10 then
			speedstr = tostring(math.Round(SRP.suit.energy*100/max))
		else
			energystr = tostring(math.Round(SRP.suit.energy*100)/max)
			if not string.find(energystr,"%.") then
				energystr = energystr .. ".0"
			end
		end
		--surface.DrawOutlinedRect(a.x+s*.5+55, a.y-33, 50,40)
		draw.DrawText(speedstr,"lcd2",a.x+s*.5+55,a.y-33,color_black,2)
		draw.DrawText("Air %", nil,a.x+s*.5+55,a.y-40, color_black, 2)
		
		draw.DrawText(tostring(SRP.suit.temperature),"lcd2",a.x+s*.5+55,a.y-73,color_black,2)
		draw.DrawText("Temperature", nil,a.x+s*.5+55,a.y-80, color_black, 2)
		
		draw.DrawText(energystr,"lcd2",a.x+s*.5-30,a.y-73,color_black,2)
		draw.DrawText("Energy %", nil,a.x+s*.5-30,a.y-80, color_black, 2)
		
		draw.DrawText("Pressure", nil,a.x+s*.5-30,a.y-40, color_black, 2)
		draw.DrawText("atm", nil,a.x+s*.5-10,a.y-16, color_black, 2)
		draw.DrawText("1.00", "lcd2",a.x+s*.5-30,a.y-33, color_black, 2)
	end
	hook.Add("HUDPaint", "LsDisplay", Draw)
end
LoadHud()


local function LS_umsg_hook1( um )
	SRP.suit.o2per = um:ReadFloat()
	SRP.suit.air = um:ReadShort()
	SRP.suit.temperature = um:ReadShort()
	SRP.suit.coolant = um:ReadShort()
	SRP.suit.energy = um:ReadShort()
end
usermessage.Hook("LS_umsg1", LS_umsg_hook1) 


