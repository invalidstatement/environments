/*
Eagle Predator Heads-Up Display
Version 1.3
© Night-Eagle 2007
gmail sedhdi

Console commands:
ehud_unitqqqqq
	MPH or KM/H
*/
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


ephud = {}
ephud.maxammo = {}
ephud.shownames = true
ephud.lastang = Angle(0,0,0)
ephud.lasthealth = 0
ephud.lastflicker = 1
ephud.flicker = 1
ephud.flickerend = CurTime()
ephud.units = {
	MPH = {
			63360 / 3600,
			"MPH",
		},
	["KM/H"] = {
			39370.0787 / 3600,
			"KM/H",
		},
	}
ephud.unit = CreateClientConVar("ehud_unit","MPH",false,true)
ephud.white = surface.GetTextureID("vgui/white")

surface.CreateFont( "lcd", 12, 2, 0, 0, "lcd12" )
surface.CreateFont( "lcd", 24, 2, 0, 0, "lcd24" )
surface.CreateFont( "lcd", 36, 2, 0, 0, "lcd36" )
ephud.font12 = "lcd12"
ephud.font24 = "lcd24"
ephud.font36 = "lcd36"

ephud.usrskipright = false

function ephud.rect(x,y,w,h,orx,ory,u1,v1,u2,v2)
	local ox = orx or ScrW()*.5
	local oy = ory or ScrH()*.5
	u1 = u1 or 0
	u2 = u2 or 1
	v1 = v1 or 0
	v2 = v2 or 1
	
	//surface.SetTexture(tex)
	//surface.SetDrawColor(0,0,255,150*hf.a)
	
	local points = {
		{
			x=x,
			y=y,
			u=u1,
			v=v1,
		},
		{
			x=x+w,
			y=y,
			u=u2,
			v=v1,
		},
		{
			x=x+w,
			y=y+h,
			u=u2,
			v=v2,
		},
		{
			x=x,
			y=y+h,
			u=u1,
			v=v2,
		},
	}
	for k,v in ipairs(points) do
		v.x = (v.x-ox)
		v.y = (v.y-oy)
		
		v.x = v.x*(1+math.sin(v.y/(ScrW()))^2)
		v.y = v.y*(1+math.sin(v.x/(ScrH()))^2)
		
		v.x = v.x+ox
		v.y = v.y+oy
	end
	
	surface.DrawPoly(points)
end
function ephud.rectCreate(x,y,w,h,orx,ory,u1,v1,u2,v2)
	local ox = orx or ScrW()*.5
	local oy = ory or ScrH()*.5
	u1 = u1 or 0
	u2 = u2 or 1
	v1 = v1 or 0
	v2 = v2 or 1
	
	//surface.SetTexture(tex)
	//surface.SetDrawColor(0,0,255,150*hf.a)
	
	local points = {
		{
			x=x,
			y=y,
			u=u1,
			v=v1,
		},
		{
			x=x+w,
			y=y,
			u=u2,
			v=v1,
		},
		{
			x=x+w,
			y=y+h,
			u=u2,
			v=v2,
		},
		{
			x=x,
			y=y+h,
			u=u1,
			v=v2,
		},
	}
	for k,v in ipairs(points) do
		v.x = (v.x-ox)
		v.y = (v.y-oy)
		
		v.x = v.x*(1+math.sin(v.y/(ScrW()))^2)
		v.y = v.y*(1+math.sin(v.x/(ScrH()))^2)
		
		v.x = v.x+ox
		v.y = v.y+oy
	end
	
	return points
end

function ephud.DrawRect(x,y,w,h,uix,uiy,ow,oh)
	ix = uix - 1
	iy = uiy - 1
	ixt = ix
	iyt = iy
	local dx = w/uix
	local dy = h/uiy
	for ix = 0,ix do
		for iy = 0,iy do
			ephud.rect(x+ix*dx,y+iy*dy,dx,dy,ow,oh,ix/math.max(ixt,1),iy/math.max(iyt,1))
		end
	end
end

function ephud.CreateRect(x,y,w,h,uix,uiy,ow,oh)
	local rect = {}
	ix = uix - 1
	iy = uiy - 1
	ixt = ix
	iyt = iy
	local dx = w/uix
	local dy = h/uiy
	for ix = 0,ix do
		for iy = 0,iy do
			local tmp = ephud.rectCreate(x+ix*dx,y+iy*dy,dx,dy,ow,oh,ix/math.max(ixt,1),iy/math.max(iyt,1))
			for k,v in pairs(tmp) do
				table.insert(rect, v)
			end
		end
	end
	return rect
end

function ephud.DrawText(ox,oy,text,font,x,y,color,xalign)
	ox = ox or ScrW()*.5
	oy = oy or ScrH()*.5
	
	x = x-ox
	y = y-oy
	
	x = x*(1+math.sin(y/(ScrW()))^2)
	y = y*(1+math.sin(x/(ScrH()))^2)
	
	x = x+ox
	y = y+oy
	
	draw.DrawText(text,font,x,y,color,xalign)
end

function ephud.load()
	left = ephud.CreateRect(64,ScrH()-172,256,56,16,1,nil,ScrH()*.5+64)
	function ephud.draw()
		//Start get vars
		
		//EHUD Compat
		
		local SWEP = LocalPlayer():GetActiveWeapon()
		local val = {}
		val.crx = .5*ScrW()
		val.cry = .5*ScrH()
		if SWEP:IsValid() then
			val.clip1type = SWEP:GetPrimaryAmmoType() or ""
			val.clip1 = tonumber(SWEP:Clip1()) or 0
			val.clip1left = LocalPlayer():GetAmmoCount(val.clip1type)
			val.clip2type = SWEP:GetSecondaryAmmoType() or ""
			val.clip2 = tonumber(SWEP:Clip2()) or 0
			val.clip2left = LocalPlayer():GetAmmoCount(val.clip2type)
			
			//LEGACY, REMOVE
			if type(SWEP:GetTable().mode) == "string" and type(SWEP:GetTable().data) == "table" and type(SWEP:GetTable().data[SWEP:GetTable().mode]) == "table" then
				val.firemode = SWEP:GetTable().data[SWEP:GetTable().mode].label or ""
			else
				val.firemode = ""
			end
			
			if SWEP:GetTable().redstyle then //LEGACY, REMOVE
				val.crx = SWEP:GetTable().redcrosshair
				val.cry = val.crx.y
				val.crx = val.crx.x
			end
		else
			val.clip1 = 0
			val.clip1left = 0
			val.clip2 = 0
			val.clip2left = 0
			val.firemode = ""
		end
		if not ephud.maxammo[SWEP] then
			ephud.maxammo[SWEP] = val.clip1
		elseif val.clip1 > ephud.maxammo[SWEP] then
			ephud.maxammo[SWEP] = val.clip1
		end
		
		val.clip1max = tonumber(ephud.maxammo[SWEP]) or 1
		
		if SWEP:IsValid() then
			for k,v in pairs(SWEP:GetTable().huddata or {}) do
				val[k] = v
			end
		end
		
		//End get vars
		--'
		//Draw the HUD and get more vars
		
		//HUD flicker
		local hf = {}
		hf.ch = LocalPlayer():Health()+LocalPlayer():Armor()
		hf.lh = ephud.lasthealth
		hf.a = ephud.lastflicker
		
		if hf.ch < hf.lh then
			hf.a = math.Clamp(((hf.lh - hf.ch)/100)*(math.random(1,20)/10),0,1)
			ephud.flicker = hf.a
			if ephud.flickerend < CurTime() then
				ephud.flickerend = CurTime()+(hf.lh-hf.ch)/4
			else
				ephud.flickerend = ephud.flickerend+(hf.lh-hf.ch)/15
			end
			ephud.flickerend = math.Min(ephud.flickerend,CurTime()+2)
		elseif CurTime() < ephud.flickerend then
			hf.a = math.random(math.Max((1-ephud.flickerend+CurTime())*100,0),100)/100
		else
			hf.a = 1
		end
		
		ephud.lasthealth = hf.ch
		
		//Global
		surface.SetTexture(ephud.white)
		surface.SetDrawColor(0,0,255,150*hf.a)
		local yorigin = ScrH()*.5+64
		
		//Left
		surface.SetTexture(ephud.white)
		surface.SetDrawColor(0,0,0,200*hf.a)
		--ephud.DrawRect(64,ScrH()-172,256,56,16,1,nil,yorigin)
		surface.DrawPoly(left)
		
		local var
		local imax
		//Health
		var = math.Clamp(LocalPlayer():Health(),0,100)
		surface.SetDrawColor(255,0,0,150*hf.a)
		ephud.DrawRect(72,ScrH()-164,240*var/100,16,16,1,nil,yorigin)
		surface.SetDrawColor(255,0,0,30*hf.a)
		ephud.DrawRect(72+(240*var/100),ScrH()-164,240*(1-(var/100)),16,16,1,nil,yorigin)
		ephud.DrawText(nil,yorigin,LocalPlayer():Health(),"lcd36",72,ScrH()-172,Color(255,255,255,255*hf.a),0)
		
		//Armor
		var = math.Clamp(LocalPlayer():Armor(),0,100)
		surface.SetDrawColor(135,206,255,150*hf.a)
		ephud.DrawRect(72,ScrH()-140,240*var/100,16,16,1,nil,yorigin)
		surface.SetDrawColor(135,206,255,30*hf.a)
		ephud.DrawRect(72+(240*var/100),ScrH()-140,240*(1-(var/100)),16,16,1,nil,yorigin)
		if LocalPlayer():Armor() and LocalPlayer():Armor() > 0 then
			ephud.DrawText(nil,yorigin,LocalPlayer():Armor(),"lcd36",72,ScrH()-148,Color(255,255,255,255*hf.a),0)
		end
		
		
		//Right
		if not ephud.usrskipright then
			surface.SetTexture(ephud.white)
			surface.SetDrawColor(0,0,0,150*hf.a)
			ephud.DrawRect(ScrW()-320,ScrH()-172,256,56,16,1,nil,yorigin)
		end
		
		//Secondary Ammo
		
		ephud.usrskipright = true
		
		if val.clip2left > 0 then
			surface.SetDrawColor(255,0,0,255*hf.a)
			ephud.DrawRect(ScrW()-312+(232*(CurTime()*val.clip2left*.1%1)),ScrH()-164,8,16,3,1,nil,yorigin)
			ephud.DrawText(nil,yorigin,val.clip2left,"lcd36",ScrW()-306,ScrH()-170,Color(255,255,255,255*hf.a),0)
			ephud.usrskipright = false
		end
		
		//Offset: -6,+6
		
		//Primary Ammo
		if val.clip1 > 0 then
			surface.SetDrawColor(30,200,30,150*hf.a)
			ephud.DrawRect(ScrW()-312+(240*(1-val.clip1/val.clip1max)),ScrH()-140,240*val.clip1/val.clip1max,16,16,1,nil,yorigin)
		end
		surface.SetDrawColor(0,255,0,30*hf.a)
		ephud.DrawRect(ScrW()-312,ScrH()-140,240*(1-(val.clip1/val.clip1max)),16,16,1,nil,yorigin)
		if val.clip1 >= 0 then
			ephud.DrawText(nil,yorigin,val.clip1,"lcd36",ScrW()-74,ScrH()-146,Color(255,255,255,255*hf.a),2)
			if val.clip1 == 0 then
				surface.SetDrawColor(30,200,30,255*hf.a)
				ephud.DrawRect(ScrW()-312+(232*(CurTime()*50*.1%1)),ScrH()-140,8,16,3,1,nil,yorigin)
			end
			if val.clip1left > 0 then
				ephud.DrawText(nil,origin,val.clip1left,"lcd36",ScrW()-80,ScrH()-186,Color(255,255,255,255*hf.a),2)
			end
			ephud.usrskipright = false
		elseif val.clip1left > 0 then
			surface.SetDrawColor(30,200,30,255*hf.a)
			ephud.DrawRect(ScrW()-312+(232*(CurTime()*val.clip1left*.1%1)),ScrH()-140,8,16,3,1,nil,yorigin)
			ephud.DrawText(nil,yorigin,val.clip1left,"lcd36",ScrW()-74,ScrH()-146,Color(255,255,255,255*hf.a),2)
			ephud.usrskipright = false
		end
		if val.clip1max > 0 then
			ephud.DrawText(nil,yorigin,val.clip1max,"lcd36",ScrW()-306,ScrH()-142,Color(255,255,255,255*hf.a),0)
			ephud.usrskipright = false
		end
		
		//Compass and environment
		surface.SetTexture(ephud.white)
		surface.SetDrawColor(0,0,0,50*hf.a)
		
	end
	hook.Add("HUDPaint","ephud.draw",ephud.draw)
	
	function ephud.HideHUD(name)
		if name == "CHudHealth" then return false end
		if name == "CHudBattery" then return false end
		if name == "CHudAmmo" then return false end
		if name == "CHudSecondaryAmmo" then return false end
	end
	hook.Add("HUDShouldDraw","ephud.HideHUD",ephud.HideHUD)
end

function test()
	local screen = ents.Create("prop_physics")
	screen:Spawn()
	screen:SetModel("models/props_phx/construct/glass/glass_dome360.mdl")
	screen:SetAngles(Angle(90,0,0))
	screen:SetPos(LocalPlayer():LocalToWorld(LocalPlayer():GetViewOffset() + Vector(0,0,0)))
	screen:SetParent(LocalPlayer())
end
--ephud.load()

local function LS_umsg_hook1( um )
	SRP.suit.o2 = um:ReadFloat()
	SRP.suit.air = um:ReadShort()
	SRP.suit.temperature = um:ReadShort()
	SRP.suit.coolant = um:ReadShort()
	SRP.suit.energy = um:ReadShort()
end
usermessage.Hook("LS_umsg1", LS_umsg_hook1) 


