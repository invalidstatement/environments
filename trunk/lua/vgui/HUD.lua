------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

//localize stuff
local surface = surface
local cam = cam
local render = render
local math = math
local string = string
local os = os
local ScrW = ScrW
local ScrH = ScrH
local EyePos = EyePos
local EyeAngles = EyeAngles
local SetMaterialOverride = SetMaterialOverride
local Color = Color
local tostring = tostring
local Vector = Vector
local IsValid = IsValid

surface.CreateFont( "digital-7", 36, 2, true, true, "lcd2")
surface.CreateFont( "coolvetica", 20, 2, true, true, "env")

temp_unit = "F"
function LoadHud()
	HUD={}
	HUD.mode = 0
	HUD.Convar=CreateConVar( "env_hud_enabled", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the custom hud" )
	HUD.Unit=CreateConVar( "env_hud_unit", "F", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the custom hud" )
	HUD.CS_Model=nil
	HUD.Model="models/props_phx/construct/glass/glass_curve90x1.mdl"
	HUD.EyeAngleOffset=Angle(0,135,0)
	
	//1024x768
	--HUD.ModelScale=Vector(1,1,1.8)
	--HUD.EyeVectorOffset=Vector(-2,55,-53)
	--HUD.EyeAngleOffset=Angle(0,135,0)
	
	//1280x960
	--HUD.ModelScale=Vector(1,1,1.7)
	--HUD.EyeVectorOffset=Vector(-2,55,-50)
	--HUD.EyeAngleOffset=Angle(0,135,0)
	
	//1280x1024
	--HUD.ModelScale=Vector(1,1,1.7)
	--HUD.EyeVectorOffset=Vector(-2,55,-48)
	--HUD.EyeAngleOffset=Angle(0,135,0)

	//Set it up for different resolutions
	local ratio = ScrW()/1152
	if ScrW() == 1920 then --1920x1024 MOSTLY WORKING
		ratio = 3
		HUD.ModelScale=Vector(1.53,1.53,1.5) 
		HUD.EyeVectorOffset=Vector(-2,55,-41)
		HUD.mode = 1
	elseif ScrW() == 1920 and ScrH() >= 1200 then --1920x1200 UNTESTED
		ratio = 3
		HUD.ModelScale=Vector(1.53,1.53,1.5) 
		HUD.EyeVectorOffset=Vector(-2,55,-41)
		HUD.mode = 1
	elseif ScrW() == 1024 and ScrH() == 768 then --1024x768 WORKING
		ratio = 1
		HUD.ModelScale=Vector(1,1,1.8)
		HUD.EyeVectorOffset=Vector(-2,55,-53)
		HUD.mode = 3
	elseif ScrW() == 1280 and ScrH() == 720 then --1280x720 WORKING
		ratio = 1
		HUD.ModelScale=Vector(1.25,1.25,1.8)
		HUD.EyeVectorOffset=Vector(-2,55,-53)
	elseif ScrW() == 1280 and ScrH() == 800 then --1280x800 WORKING
		ratio = 1
		HUD.ModelScale=Vector(1.25,1.25,1.8)
		HUD.EyeVectorOffset=Vector(-2,55,-53)
	elseif ScrW() == 1280 and ScrH() == 1024 then --1280x1024 WORKING
		ratio = 1
		HUD.ModelScale=Vector(1,1,1.8)
		HUD.EyeVectorOffset=Vector(-2,55,-53)
		print("1280x1024")
		HUD.mode = 2
	else
		ratio = 1
		HUD.ModelScale=Vector(1,1,1.8)
		HUD.EyeVectorOffset=Vector(-2,55,-53)
	end

	HUD.RT_W=ScrW()
	HUD.RT_H=ScrH()*1.3
	HUD.RenderTarget=GetRenderTarget( "ENV_HUD_15",HUD.RT_W,HUD.RT_H,false);
	HUD.RenderPos=nil;
	HUD.RenderAng=nil;
	HUD.ScreenMaterial=CreateMaterial(
		"sprites/DDD_ScreenMat22",
		"UnlitGeneric",
		{
			[ '$basetexture' ] = HUD.RenderTarget,
			[ '$basetexturetransform' ] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
			[ '$additive' ] = 1
		}
	)
	HUD.TransparentMat=CreateMaterial(
		"sprites/DDD_TransparentMat",
		"Refract",
		{
			[ '$basetexturetransform' ] = "center 0.5 .5 scale -1 1 rotate 0 translate 0 0",
			[ '$refractamount' ] = ".02",
			[ '$nocull' ] = "1",
			[ '$model' ] = "1",
			[ '$bluramount' ] = "1",
			[ '$nowritez' ] = "1",
		}
	)

	function HideThings( name )
		if (name == "CHudHealth" or name == "CHudBattery") then
			return false
		end
			-- We don't return anything here otherwise it will overwrite all other 
			-- HUDShouldDraw hooks.
	end
	--hook.Add( "HUDShouldDraw", "HideThings", HideThings )
	local client = LocalPlayer()
	--Think hook
	function HUD:Think()
		--first, check if the player is in a vehicle
		if HUD.mode == 1 then --1920x1024 and such
			if LocalPlayer():InVehicle() then
				HUD.EyeVectorOffset = Vector(-2,44,-41)
			else
				HUD.EyeVectorOffset = Vector(-2,55,-41)
			end
		elseif HUD.mode == 3 then --1024x768
			if LocalPlayer():InVehicle() then
				HUD.EyeVectorOffset = Vector(-2,42,-54)
			else
				HUD.EyeVectorOffset = Vector(-2,55,-54)
			end
		else --everyone else
			if LocalPlayer():InVehicle() then
				HUD.EyeVectorOffset = Vector(-2,44,-53)
			else
				HUD.EyeVectorOffset = Vector(-2,55,-53)
			end
		end
		
		if not IsValid(HUD.CS_Model) then
			HUD.CS_Model=ClientsideModel(HUD.Model,RENDERGROUP_OPAQUE)
			HUD.CS_Model:SetNoDraw(true)
			HUD.CS_Model:SetModelScale(HUD.ModelScale or Vector(0,0,0))
		end
	end
	
	/*function Paint()
		NeedUpdate = true
	end
	timer.Create("HudDraws", 0.2, 0, Paint)*/
	
	function HUD:DrawHUD()
		local Air = environments.suit.air / 40
		local Energy = environments.suit.energy / 40
		local Coolant = environments.suit.coolant / 40
		if Air >= 10 then
			Air = math.Round(Air)
		end
		if Energy >= 10 then
			Energy = math.Round(Energy)
		end
		if Coolant >= 10 then
			Coolant = math.Round(Coolant)
		end
		//upper bar
		surface.SetDrawColor(150,150,150,255)
		surface.DrawRect(0,0,ScrW(),100)
		
		//lower bar
		if HUD.mode == 2 then
			surface.DrawRect(0,ScrH()-450,ScrW(),100)
		else
			surface.DrawRect(0,ScrH()-350,ScrW(),100)
		end

		//actual
		draw.SimpleText("Air: "..Air .. "%", "ScoreboardText", 105*ratio, 125, Color(255,255,255,255), 0, 0)
		draw.SimpleText("Energy: "..Energy.."%","ScoreboardText",105*ratio, 160,Color(250,230,10,255),0,0)
		draw.SimpleText("Coolant: "..Coolant.."%","ScoreboardText",105*ratio, 195,Color(5,150,255,255),0,0)
		draw.RoundedBox(0, 105*ratio, 140, math.Clamp(Air,0,100)*1.8,15, Color(255,255,255,255))
		draw.RoundedBox(0, 105*ratio, 175, math.Clamp(Energy,0,100)*1.8,15, Color(255,170,0,255))
		draw.RoundedBox(0, 105*ratio, 210, math.Clamp(Coolant,0,100)*1.8,15, Color(0,120,255,255))
		draw.SimpleText("Clock: "..tostring(os.date()),"ScoreboardText",ScrW()-(300*ratio),140,Color(220,220,220,255),0,0)
		surface.SetDrawColor(255,0,0,255)
		surface.DrawOutlinedRect(105*ratio,140,180,15)
		surface.DrawOutlinedRect(105*ratio,175,180,15)
		surface.DrawOutlinedRect(105*ratio,210,180,15)
		surface.DrawOutlinedRect(105*ratio,140,math.Clamp(Air,0,100)*1.8,15)
		surface.DrawOutlinedRect(105*ratio,175,math.Clamp(Energy,0,100)*1.8,15)
		surface.DrawOutlinedRect(105*ratio,210,math.Clamp(Coolant,0,100)*1.8,15)
		
		local air = environments.suit.air
		local coolant = environments.suit.coolant
		local energy = environments.suit.energy
		local temperature = environments.suit.temperature
		local o2 = environments.suit.o2per
		local temp = environments.suit.temp
		if temperature then
			if string.upper(HUD.Unit:GetString()) == "C" then
				temperature = temperature - 273
				temp = temp - 273
				temp_unit = "C"
			elseif string.upper(HUD.Unit:GetString()) == "F" then
				temperature = (temperature * (9/5)) - 459.67
				temp = (temp * (9/5)) - 459.67
				temp_unit = "F"
			else
				temp_unit = "K"
			end
		end
		
		local length     = ScrW()/2 - 455 --should make 5 w/ spacer
		local spacer     = 40
		
		surface.SetFont( "env" )
		
		surface.SetTextColor( 255, 255, 255, 255 )
		draw.RoundedBox(0, 0, 100, ScrW(), 24, Color(0, 0, 0, 150))
		draw.RoundedBox(0, 0, 124, ScrW(), 2, Color(255, 255, 255, 255))

		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Air: " ..tostring(air) )
		local x = surface.GetTextSize( "Air: " ..tostring(air) )
		length = length + x + spacer
		
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Coolant: " ..coolant )
		x = surface.GetTextSize( "Coolant: " ..tostring(coolant) )
		length = length + x + spacer
		
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Energy: " .. tostring(energy) )
		x = surface.GetTextSize( "Energy: " .. tostring(energy) )
		length = length + x + spacer
			
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Suit Temp: " .. string.Left(tostring(temp),6) .. temp_unit )
		x = surface.GetTextSize( "Suit Temp: " .. "      " .. temp_unit )
		length = length + x + spacer
		
		if planet then	
			surface.SetTextPos( length + spacer, 105 )
			surface.DrawText( "Planet: " .. tostring(planet.name) )
			x = surface.GetTextSize( "Planet: " .. tostring(planet.name) )
			length = length + x + spacer
		else
			surface.SetTextPos( length + spacer, 105 )
			surface.DrawText( "Planet: " .. tostring("Space") )
			x = surface.GetTextSize( "Planet: " .. tostring("Space") )
			length = length + x + spacer
		end

		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Temperature: " .. string.Left(tostring(temperature), 6) .. temp_unit )
		x = surface.GetTextSize( "Temperature: " .. "      " .. temp_unit )
		length = length + x + spacer
			
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "O2 Percent: " .. string.Left(tostring(o2),6) )
	end

	function HUD:CalcOffset(pos,ang,off)
		return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
	end
	local Draw = HUD.DrawHUD
	local Mat = HUD.ScreenMaterial
	HUD.ontime = 0
	HUD.offtime = 0
	HUD.ang = 0
	--RenderScreenspaceEffects hook
	function HUD:DrawHUDScreen()
		if not IsValid(HUD.CS_Model) || not HUD.Convar:GetBool() then return end
		if not LocalPlayer():GetNWBool("helmet") then 
			local mult = 0
			if HUD.offtime != 0 then --it is being taken off
				mult = HUD.offtime - RealTime()
				
				if mult < -1.4 then return end --dont draw it, it is off
				HUD.ang = mult*25
				if HUD.ang < -50 then
					HUD.ang = -50
				end
				HUD.EyeVectorOffset = HUD.EyeVectorOffset - Vector(0,0,mult*50)
			else --it just got taken off
				HUD.offtime = RealTime() --tell it it was put on
			end
			HUD.ontime = 0
		else
			local old = HUD.EyeVectorOffset
			local mult = 0
			if HUD.ontime != 0 then --it is being taken off
				mult = (HUD.ontime - RealTime())
				--if mult < -1.4 then return end --dont draw it, it is off
				HUD.ang = (50-(math.abs(mult)*40))*-1
				HUD.EyeVectorOffset = HUD.EyeVectorOffset - Vector(0,0,-1.4*50) + Vector(0,0,mult*50)
				if HUD.ang > 0 or HUD.ang < -45 then
					HUD.ang = 0
				end
				if HUD.EyeVectorOffset.z < old.z then
					HUD.EyeVectorOffset = old
				end
			else --it just got taken off
				HUD.ontime = RealTime() --tell it it was put on
				HUD.ang = -50
			end
			HUD.offtime = 0--set it as off
		end

		cam.Start3D( EyePos(), EyeAngles() )
			cam.IgnoreZ( true )
				--draw the screen in 3D,then
				RenderPos = EyePos()
				RenderAng = EyeAngles() + Angle(HUD.ang,0,0)
				RenderPos=HUD:CalcOffset(RenderPos,RenderAng,HUD.EyeVectorOffset)
				RenderAng:RotateAroundAxis(RenderAng:Right(),HUD.EyeAngleOffset.p)
				RenderAng:RotateAroundAxis(RenderAng:Up(),HUD.EyeAngleOffset.y)
				RenderAng:RotateAroundAxis(RenderAng:Forward(),HUD.EyeAngleOffset.r)
				
				HUD.CS_Model:SetRenderAngles(RenderAng)
				HUD.CS_Model:SetRenderOrigin(RenderPos)
				SetMaterialOverride(Mat)
					HUD.CS_Model:DrawModel()
				SetMaterialOverride(0)
			cam.IgnoreZ( false )
		cam.End3D()
		
		--if NeedUpdate then
			local oldRT = render.GetRenderTarget()
			render.SetRenderTarget(HUD.RenderTarget)
			render.Clear(0,0,0,0)
			render.SetViewPort(0,0,HUD.RT_W,HUD.RT_H)
			--Draw the HUD on the rendertarget
			Draw()
			render.SetRenderTarget(oldRT)
			render.SetViewPort(0,0,ScrW(),ScrH())
			Mat:SetMaterialTexture( "$basetexture", HUD.RenderTarget )
			NeedUpdate = false
		--end
	end

	hook.Add("Think","Environments HUD Think", HUD.Think)
	hook.Add("RenderScreenspaceEffects","Environments Draw HUD", HUD.DrawHUDScreen)
end
//old hud
/*function LoadHud()
	function Draw()
		local alpha = 255
		local max = 4000
		local speed = SRP.suit.energy
		local per = speed/max
		local a = Vector(ScrW()-120,100,0)
		local s = 90--math.ceil(ScrW()/12/8)*8
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
		
		local speedstr = ""

		local Air = SRP.suit.air / 40
		local Energy = SRP.suit.energy / 40
		local Coolant = SRP.suit.coolant / 40
		if Air >= 10 then
			Air = math.Round(Air)
		end
		if Energy >= 10 then
			Energy = math.Round(Energy)
		end
		if Coolant >= 10 then
			Coolant = math.Round(Coolant)
		end
		--surface.DrawOutlinedRect(a.x+s*.5+55, a.y-33, 50,40)
		draw.DrawText(tostring(Air),"lcd2",a.x+s*.5+55,a.y-33,Color(0,255,0,255),2)
		draw.DrawText("Air %", nil,a.x+100,a.y-40, Color(0,255,0,255), 2)
		
		draw.DrawText(tostring(SRP.suit.temperature),"lcd2",a.x+s*.5+55,a.y-73,Color(255,0,0,255),2)
		draw.DrawText("Temperature", nil,a.x+100,a.y-80, Color(255,0,0,255), 2)
		
		draw.DrawText(tostring(Energy),"lcd2",a.x+s*.5-30,a.y-73,Color(255,255,255,255),2)
		draw.DrawText("Energy %", nil,a.x+15,a.y-80, Color(255,255,255,255), 2)
		
		draw.DrawText(tostring(Coolant),"lcd2",a.x+s*.5-30,a.y-33,color_black,2)
		draw.DrawText("Coolant %", nil,a.x+15,a.y-40, color_black, 2)
		
		--draw.DrawText("Pressure", nil,a.x+s*.5-30,a.y-40, color_black, 2)
		--draw.DrawText("atm", nil,a.x+s*.5-10,a.y-16, color_black, 2)
		--draw.DrawText("1.00", "lcd2",a.x+s*.5-30,a.y-33, color_black, 2)
	end
	hook.Add("HUDPaint", "LsDisplay", Draw)
end*/

//old cool draw code
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
