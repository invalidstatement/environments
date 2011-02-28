//MAKE IT LIKE GAUGES WITH DRAW.ROUNDED BOX :D :D :D and digital ones too!!!
//move most of the stuff from the top bar into a box in the top left hand corner
surface.CreateFont( "digital-7", 36, 2, true, true, "lcd2")
function LoadHud()
	function Draw()
		/*local alpha = 255
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
		draw.DrawText("Coolant %", nil,a.x+15,a.y-40, color_black, 2)*/
		
		/*draw.DrawText("Pressure", nil,a.x+s*.5-30,a.y-40, color_black, 2)
		draw.DrawText("atm", nil,a.x+s*.5-10,a.y-16, color_black, 2)
		draw.DrawText("1.00", "lcd2",a.x+s*.5-30,a.y-33, color_black, 2)*/
	end
	hook.Add("HUDPaint", "LsDisplay", Draw)
end

//Spacebuild Compatibility :D
local function LS_umsg_hook1( um )
	environments.suit.o2per = um:ReadFloat()
	environments.suit.air = um:ReadShort()
	environments.suit.temperature = um:ReadShort()
	environments.suit.coolant = um:ReadShort()
	environments.suit.energy = um:ReadShort()
end
usermessage.Hook("LS_umsg1", LS_umsg_hook1) 

function LoadHud()
	HUD={}
	HUD.Convar=CreateConVar( "env_hud_enabled", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the custom hud" )
	HUD.CS_Model=nil
	HUD.Model="models/props_phx/construct/glass/glass_curve90x1.mdl"
	HUD.ModelScale=Vector(ScrW()/1152,ScrW()/1152,1.8)
	HUD.EyeVectorOffset=Vector(-2,55,-53)
	HUD.EyeAngleOffset=Angle(0,135,0)

	//Set it up for different resolutions
	local ratio = ScrW()/1152
	if ScrW() == 1920 then
		ratio = 3
		HUD.ModelScale=Vector(ScrW()/1252,ScrW()/1252,1.5) --1920x1024
		HUD.EyeVectorOffset=Vector(-2,55,-53)
	elseif ScrW() == 1024 and ScrH() == 768 then --1024x768
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
		if ScrW() == 1920 then --1920x1024
			if client:InVehicle() then
				HUD.EyeVectorOffset = Vector(-2,44,-41)
			else
				HUD.EyeVectorOffset = Vector(-2,55,-41)
			end
		else --everyone else
			if client:InVehicle() then
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

	
	--HUDPaint like hook,but called after the screen gets rendered,not associated with HUDPaint however
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
		surface.DrawRect(0,ScrH()-350,ScrW(),100)

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
		
		local length     = ScrW()/2 - 410 --should make 5 w/ spacer
		local spacer     = 40
		
		surface.SetFont( "Default" )
		
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
		surface.DrawText( "Suit Temp: " .. tostring(environments.suit.temp) )
		x = surface.GetTextSize( "Suit Temp: " .. tostring(environments.suit.temp) )
		length = length + x + spacer
			
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Planet: " .. tostring(planet) )
		x = surface.GetTextSize( "Planet: " .. tostring(planet) )
		length = length + x + spacer

		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "Temperature: " .. tostring(temperature) )
		x = surface.GetTextSize( "Temperature: " .. tostring(temperature) )
		length = length + x + spacer
			
		surface.SetTextPos( length + spacer, 105 )
		surface.DrawText( "O2 Percent: " .. tostring(o2) )
	end

	function HUD:CalcOffset(pos,ang,off)
		return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
	end

	--RenderScreenspaceEffects hook
	function HUD:DrawHUDScreen()
		if not IsValid(HUD.CS_Model) || not HUD.Convar:GetBool() then return end
		if not client:GetNWBool("helmet") then return end
		
		cam.Start3D( EyePos(), EyeAngles() )
			cam.IgnoreZ( true )
				--draw the screen in 3D,then
				RenderPos = EyePos()
				RenderAng = EyeAngles()
				RenderPos=HUD:CalcOffset(RenderPos,RenderAng,HUD.EyeVectorOffset)
				RenderAng:RotateAroundAxis(RenderAng:Forward(),HUD.EyeAngleOffset.p)
				RenderAng:RotateAroundAxis(RenderAng:Up(),HUD.EyeAngleOffset.y)
				RenderAng:RotateAroundAxis(RenderAng:Right(),HUD.EyeAngleOffset.r)
				HUD.CS_Model:SetRenderAngles(RenderAng)
				HUD.CS_Model:SetRenderOrigin(RenderPos)
				SetMaterialOverride(HUD.ScreenMaterial)
					HUD.CS_Model:DrawModel()
				SetMaterialOverride(0)
			cam.IgnoreZ( false )
		cam.End3D()
		
		local oldRT = render.GetRenderTarget()
		render.SetRenderTarget(HUD.RenderTarget)
		render.Clear(0,0,0,0)
		render.SetViewPort(0,0,HUD.RT_W,HUD.RT_H)
		--Draw the HUD on the rendertarget
		HUD:DrawHUD()
		render.SetRenderTarget(oldRT)
		render.SetViewPort(0,0,ScrW(),ScrH())
		HUD.ScreenMaterial:SetMaterialTexture( "$basetexture", HUD.RenderTarget )
	end

	hook.Add("Think","Environments HUD Think", HUD.Think)
	hook.Add("RenderScreenspaceEffects","Environments Draw HUD", HUD.DrawHUDScreen)
end
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
