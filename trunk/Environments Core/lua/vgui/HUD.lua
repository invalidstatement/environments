------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
print("hey")
//localize stuff
local surface = surface
local cam = cam
local render = render
local draw = draw
local math = math
local string = string
local os = os
local Angle = Angle
local ClientsideModel = ClientsideModel
local Color = Color
local CreateSound = CreateSound
local EyePos = EyePos
local EyeAngles = EyeAngles
local GetRenderTarget = GetRenderTarget
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local print = print
local RealTime = RealTime
local ScrW = ScrW
local ScrH = ScrH
local SetMaterialOverride = SetMaterialOverride
local Sound = Sound
local tostring = tostring
local Vector = Vector

//Custom Locals
local Environments = Environments

render.MaterialOverride = render.MaterialOverride or SetMaterialOverride //beta and normal compatibility

local t = {}
t.font = "digital-7"
t.size = 36
t.weight = nil
t.additive = false
t.antialias = false
surface.CreateFont("lcd2", t)
t.font = "coolvetica"
t.size = 20
surface.CreateFont("env", t)

//New Code For Resolutions
local Resolutions = {}
function AddResolution(w,h,scale,offset,vehoffset)
	local name = w.."x"..h
	Resolutions[name] = {}
	Resolutions[name].Scale = scale
	Resolutions[name].Offset = offset
	Resolutions[name].VehOffset = vehoffset
end

local DefaultRes = {}
DefaultRes.Scale = Vector(1,1,1.8)
DefaultRes.Offset = Vector(-2,55,-53)
DefaultRes.VehOffset = Vector(-2,44,-53)

function GetResInfo(w,h)
	local tab = Resolutions[w.."x"..h]
	if not tab then
		return DefaultRes
	end
	return tab
end
//End Resolution Stuff

//Define your resolutions here
AddResolution(1920, 1080, Vector(1.46,1.45,1.8), Vector(-2,55,-53), Vector(-2,55,-53))
AddResolution(1920, 1200, Vector(1.53,1.53,1.5), Vector(-2,55,-41), Vector(-2,44,-41))--untested
AddResolution(1680, 1050, Vector(1.3,1.3,1.5), Vector(-2,55,-41), Vector(-2,44,-41))--untested
AddResolution(1600, 900, Vector(1.3,1.3, 1.72), Vector(-2.222, 56.04,-49.91), Vector(-2.222, 46.04,-49.91))
AddResolution(1440, 900, Vector(1,1,1.8), Vector(-2,55,-53), Vector(-2,44,-53)) --untested
AddResolution(1280, 1024, Vector(1,1,1.8), Vector(-2,55,-53), Vector(-2,44,-53))
AddResolution(1280, 960, Vector(1,1,1.7), Vector(-2,55,-50), Vector(-2,44,-50))
AddResolution(1280, 900, Vector(1.1,1.1,1.7), Vector(-2,55,-50), Vector(-2,44,-50))
AddResolution(1280, 800, Vector(1.25,1.25,1.8), Vector(-2,55,-53), Vector(-2,44,-53))
AddResolution(1280, 720, Vector(1.25,1.25,1.8), Vector(-2,55,-53), Vector(-2,44,-53))
AddResolution(1024, 768, Vector(1,1,1.8), Vector(-2,55,-53), Vector(-2,42,-54) )


HUD = {}
HUD.Convar = CreateConVar( "env_hud_enabled", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the custom hud" )
HUD.Unit = CreateConVar( "env_hud_unit", "F", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the custom hud" )
HUD.Mode = CreateConVar( "env_hud_mode", "0", { FCVAR_ARCHIVE, }, "The display mode of the HUD /n 0 = Basic    1 = Advanced" )
	
local scale_x = CreateConVar("env_hud_scale_x", 0.9, { FCVAR_ARCHIVE, },"")
local scale_y = CreateConVar("env_hud_scale_y", 1.35, { FCVAR_ARCHIVE, },"")
local scale_z = CreateConVar("env_hud_scale_z", 0.9, { FCVAR_ARCHIVE, },"")

local off_x = CreateConVar("env_hud_offset_x", 0, { FCVAR_ARCHIVE, },"")
local off_y = CreateConVar("env_hud_offset_y", 45.24, { FCVAR_ARCHIVE, },"")
local off_z = CreateConVar("env_hud_offset_z", -40.2, { FCVAR_ARCHIVE, },"")

temp_unit = "F"
function LoadHud()
	print("Setting Up HUD for "..ScrW().."x"..ScrH())
	if HUD.Mode:GetBool() then
		hook.Remove("HUDPaint", "LsDisplay")
		HUD.CS_Model = nil
		HUD.Model = "models/props_phx/construct/glass/glass_curve90x1.mdl"
		HUD.EyeAngleOffset = Angle(0,135,0)
		
		//Set it up for different resolutions
		local ratio = 1
		if ScrW() == 1920 then --1920x1024 MOSTLY WORKING
			ratio = 3
		elseif ScrW() == 1920 and ScrH() >= 1200 then --1920x1200 UNTESTED
			ratio = 3
		elseif ScrW() == 1280 and ScrH() == 1024 then --1280x1024 WORKING
			HUD.mode = 2
		else
			HUD.mode = 0
		end

		HUD.RT_W = ScrW()
		HUD.RT_H = ScrH()*1.3
		HUD.RenderTarget = GetRenderTarget( "ENV_HUD_16",HUD.RT_W,HUD.RT_H,false);
		HUD.RenderPos = nil;
		HUD.RenderAng = nil;
		HUD.ScreenMaterial = CreateMaterial(
			"sprites/DDD_ScreenMat46",
			"UnlitGeneric",
			{
				[ "$translucent" ] = 1, //OMG WTF BBQ
				[ '$basetexture' ] = HUD.RenderTarget:GetName(),
				[ '$basetexturetransform' ] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
				/*[ '$additive' ] = 1*/
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

		local client = LocalPlayer()
		function HUD:Think()
			--first, check if the player is in a vehicle
			local tab = GetResInfo(ScrW(),ScrH())
			if LocalPlayer():InVehicle() then
				HUD.EyeVectorOffset = tab.VehOffset
			else
				HUD.EyeVectorOffset = Vector(off_x:GetFloat(), off_y:GetFloat(), off_z:GetFloat())--tab.Offset
			end
			
			if not IsValid(HUD.CS_Model) then
				HUD.CS_Model=ClientsideModel("models/props_phx/construct/glass/glass_curve90x1.mdl",RENDERGROUP_OPAQUE)
				HUD.CS_Model:SetNoDraw(true)
			end
			local scale = Vector( scale_x:GetFloat(), scale_y:GetFloat(), scale_z:GetFloat() )

			local mat = Matrix()
			mat:Scale( scale )
			HUD.CS_Model:EnableMatrix( "RenderMultiply", mat )
			//HUD.CS_Model:SetModelScale(Vector(scale_x:GetFloat(), scale_y:GetFloat(), scale_z:GetFloat()))--tab.Scale or Vector(0,0,0))
		end
		
		/*function Paint()
			NeedUpdate = true
		end
		timer.Create("HudDraws", 0.2, 0, Paint)*/
		
		function HUD:DrawHUD()
			local Air = Environments.suit.air / 40
			local Energy = Environments.suit.energy / 40
			local Coolant = Environments.suit.coolant / 40
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
			surface.SetDrawColor(225,225,225,255)
			surface.DrawRect(0,0,ScrW(),100)
			
			//lower bar
			if HUD.mode == 2 then
				surface.DrawRect(0,ScrH()-450,ScrW(),100)
			else
				surface.DrawRect(0,ScrH()-350,ScrW(),100)
			end

			//actual
			surface.SetDrawColor(255,255,255,255)
			surface.DrawRect(105*ratio, 140, math.Clamp(Air, 0, 100)*1.8,15)
			draw.SimpleText("Air: "..Air .. "%", "Default", 105*ratio, 125, Color(255,255,255,255), 0, 0)
			
			surface.SetDrawColor(255,170,0,255)
			surface.DrawRect(105*ratio, 175, math.Clamp(Energy, 0, 100)*1.8,15)
			draw.SimpleText("Energy: "..Energy.."%","Default",105*ratio, 160,Color(250,230,10,255),0,0)
			
			surface.SetDrawColor(0,120,255,255)
			surface.DrawRect(105*ratio, 210, math.Clamp(Coolant, 0, 100)*1.8,15)
			draw.SimpleText("Coolant: "..Coolant.."%","Default",105*ratio, 195,Color(5,150,255,255),0,0)
			--draw.RoundedBox(0, 105*ratio, 140, math.Clamp(Air,0,100)*1.8,15, Color(255,255,255,255))
			--draw.RoundedBox(0, 105*ratio, 175, math.Clamp(Energy,0,100)*1.8,15, Color(255,170,0,255))
			--draw.RoundedBox(0, 105*ratio, 210, math.Clamp(Coolant,0,100)*1.8,15, Color(0,120,255,255))
			draw.SimpleText("Clock: "..tostring(os.date()),"Default",ScrW()-(300*ratio),140,Color(240,240,240,255),0,0)
			surface.SetDrawColor(255,0,0,255)
			surface.DrawOutlinedRect(105*ratio,140,180,15)
			surface.DrawOutlinedRect(105*ratio,175,180,15)
			surface.DrawOutlinedRect(105*ratio,210,180,15)
			surface.DrawOutlinedRect(105*ratio,140,math.Clamp(Air,0,100)*1.8,15)
			surface.DrawOutlinedRect(105*ratio,175,math.Clamp(Energy,0,100)*1.8,15)
			surface.DrawOutlinedRect(105*ratio,210,math.Clamp(Coolant,0,100)*1.8,15)
			
			local air = Environments.suit.air
			local coolant = Environments.suit.coolant
			local energy = Environments.suit.energy
			local temperature = Environments.suit.temperature
			local o2 = Environments.suit.o2per
			local temp = Environments.suit.temp
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
			
			surface.SetFont( "Default" )
			surface.SetTextColor(255,255,255,255)
			surface.SetDrawColor(255,255,255,255)
			
			surface.DrawRect(0, 124, ScrW(), 2)

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
			x = surface.GetTextSize( "Suit Temp:       " .. temp_unit )
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
			x = surface.GetTextSize( "Temperature:       " .. temp_unit )
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
		
		Sound("npc/env_headcrabcanister/hiss.wav")
		timer.Simple(5, function() HUD.sound = CreateSound(LocalPlayer(),"npc/env_headcrabcanister/hiss.wav") end) --create the sound
		function HUD:DrawHUDScreen()
			if !IsValid(HUD.CS_Model) or !HUD.Convar:GetBool() then return end
			if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().GetPrintName and LocalPlayer():GetActiveWeapon():GetPrintName() == "#GMOD_Camera" then return end
			if !LocalPlayer():GetNWBool("helmet") and Environments.UseSuit and !SBONSERVER then --stay on if suits are off
				local mult = 0
				if HUD.offtime != 0 then --it is being taken off
					mult = HUD.offtime - RealTime()
					
					if mult < -1.4 then 
						return 
					elseif mult < -1.2 then
						if HUD.sound then HUD.sound:Stop() end
					end
					
					HUD.ang = mult*25
					if HUD.ang < -50 then
						HUD.ang = -50
					end
					HUD.EyeVectorOffset = HUD.EyeVectorOffset - Vector(0,0,mult*50)
				else --it just got taken off
					if HUD.sound then HUD.sound:Play() HUD.sound:FadeOut(0.5) end
					HUD.offtime = RealTime() --tell it it was put on
				end
				HUD.ontime = 0
			else
				local old = HUD.EyeVectorOffset
				local mult = 0
				if HUD.ontime != 0 then --it is being put on
					mult = ((HUD.ontime or 0) - RealTime())
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
					RenderPos=RenderPos + RenderAng:Right() * HUD.EyeVectorOffset.x + RenderAng:Forward() * HUD.EyeVectorOffset.y + RenderAng:Up() * HUD.EyeVectorOffset.z;//HUD:CalcOffset(RenderPos,RenderAng,HUD.EyeVectorOffset)
					RenderAng:RotateAroundAxis(RenderAng:Right(),HUD.EyeAngleOffset.p)
					RenderAng:RotateAroundAxis(RenderAng:Up(),HUD.EyeAngleOffset.y)
					RenderAng:RotateAroundAxis(RenderAng:Forward(),HUD.EyeAngleOffset.r)
					
					HUD.CS_Model:SetRenderAngles(RenderAng)
					HUD.CS_Model:SetRenderOrigin(RenderPos)
					render.MaterialOverride(Mat)
						HUD.CS_Model:DrawModel()
					render.MaterialOverride(0)
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
				--Mat:SetMaterialTexture( "$basetexture", HUD.RenderTarget )
			--	NeedUpdate = false
			--end
		end

		hook.Add("Think","Environments HUD Think", HUD.Think)
		hook.Add("RenderScreenspaceEffects","Environments Draw HUD", HUD.DrawHUDScreen)
	else
		hook.Remove("Think", "Environments HUD Think")
		hook.Remove("RenderScreenspaceEffects", "Environments Draw HUD")
		
		local function Draw()
			if !HUD.Convar:GetBool() then return end
			local alpha = 255
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
			
			local temperature = Environments.suit.temperature
			local Air = Environments.suit.air / 40
			local Energy = Environments.suit.energy / 40
			local Coolant = Environments.suit.coolant / 40
			if Air >= 10 then
				Air = math.Round(Air)
			end
			if Energy >= 10 then
				Energy = math.Round(Energy)
			end
			if Coolant >= 10 then
				Coolant = math.Round(Coolant)
			end
			
			if string.upper(HUD.Unit:GetString()) == "C" then
				temperature = temperature - 273
				--temp = temp - 273
				temp_unit = "C"
			elseif string.upper(HUD.Unit:GetString()) == "F" then
				temperature = (temperature * (9/5)) - 459.67
				--temp = (temp * (9/5)) - 459.67
				temp_unit = "F"
			else
				temp_unit = "K"
			end
			
			--surface.DrawOutlinedRect(a.x+s*.5+55, a.y-33, 50,40)
			draw.DrawText(tostring(Air),"lcd2",a.x+s*.5+55,a.y-33,Color(0,255,0,255),2)
			draw.DrawText("Air %", "DermaDefault",a.x+100,a.y-40, Color(0,255,0,255), 2)
			
			draw.DrawText(tostring(math.Round(temperature))..temp_unit,"lcd2",a.x+s*.5+55,a.y-73,Color(255,0,0,255),2)
			draw.DrawText("Temperature", "DermaDefault",a.x+100,a.y-80, Color(255,0,0,255), 2)
			
			draw.DrawText(tostring(Energy),"lcd2",a.x+s*.5-30,a.y-73,Color(255,255,255,255),2)
			draw.DrawText("Energy %", "DermaDefault",a.x+15,a.y-80, Color(255,255,255,255), 2)
			
			draw.DrawText(tostring(Coolant),"lcd2",a.x+s*.5-30,a.y-33,Color(0,0,0,255),2)
			draw.DrawText("Coolant %", "DermaDefault",a.x+15,a.y-40, Color(0,0,0,255), 2)
			
			--draw.DrawText("Pressure", nil,a.x+s*.5-30,a.y-40, color_black, 2)
			--draw.DrawText("atm", nil,a.x+s*.5-10,a.y-16, color_black, 2)
			--draw.DrawText("1.00", "lcd2",a.x+s*.5-30,a.y-33, color_black, 2)
		end
		hook.Add("HUDPaint", "LsDisplay", Draw)
	end
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
