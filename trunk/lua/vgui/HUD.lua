
surface.CreateFont( "digital-7", 36, 2, true, false, "lcd2" )
function LoadHud()
	function Draw()
		local max = 4000
		local speed = SRP.suit.energy
		local per = speed/max
		local a = Vector(ScrW()*.5,ScrH(),0)
		local s = math.ceil(ScrW()/12/8)*8
		s = s
	
		draw.NoTexture()
		surface.SetDrawColor(100,100,100,255)
		surface.DrawRect(a.x-58,a.y-43,166,43)
		surface.SetDrawColor(220,220,220,255)
		surface.DrawRect(a.x-55,a.y-40,160,40)
			
		
		surface.SetDrawColor(0,0,0,128)
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
	
		local alpha = 255
		for i = 0,11/*math.min((speed/max)*(s/6-1),s/6-1)*/ do
			/*if i < s/48 then
				surface.SetDrawColor(0,0,255,alpha)
			elseif i < s / 10 then
				surface.SetDrawColor(0,255,0,alpha)
			elseif i < s / 7 then
				surface.SetDrawColor(255,255,0,alpha)
			else
				surface.SetDrawColor(255,0,0,alpha)
			end*/
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
			*/
		
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
		end
		local speedstr = tostring(math.Round(SRP.suit.air*100)/max)
		if not string.find(speedstr,"%.") then
			speedstr = speedstr .. ".0"
		end
		draw.DrawText(speedstr,"lcd2",a.x+s*.5+55,a.y-33,color_black,2)
	end
	hook.Add("HUDPaint", "LsDisplay", Draw)
end
LoadHud()


local function LS_umsg_hook1( um )
	SRP.suit.o2 = um:ReadFloat()
	SRP.suit.air = um:ReadShort()
	SRP.suit.temperature = um:ReadShort()
	SRP.suit.coolant = um:ReadShort()
	SRP.suit.energy = um:ReadShort()
end
usermessage.Hook("LS_umsg1", LS_umsg_hook1) 


