
CreateClientConVar("env_suit_color_r",255,true,true);
CreateClientConVar("env_suit_color_g",255,true,true);
CreateClientConVar("env_suit_color_b",255,true,true);
Environments.EffectsCvar = CreateClientConVar("env_effects_enable","1",true,true)

local function AddToolTab()
	-- Add Tab
	local logo;
	--if(file.Exists("../materials/gui/stargate_logo.vmt")) then logo = "gui/stargate_logo" end;
	spawnmenu.AddToolTab("Environments","Environments",logo);
	-- Add Config Category
	spawnmenu.AddToolCategory("Environments","Config"," Config");
	-- Add the entry for config
	spawnmenu.AddToolMenuOption("Environments","Config","Settings","Settings","","",Environments.ConfigMenu,{});
	-- Add the entry for Credits and Bugreporting!
	--spawnmenu.AddToolMenuOption("Environments","Config","Credits","Credits and Bugs","","",Environments.Credits);
	-- Add our tools to the tab
	/*local toolgun = weapons.Get("gmod_tool");
	if(toolgun and toolgun.Tool) then
		for k,v in pairs(toolgun.Tool) do
			if(not v.AddToMenu and v.Tab == "Stargate") then
				spawnmenu.AddToolMenuOption(
					v.Tab,
					v.Category or "",
					k,
					v.Name or "#"..k,
					v.Command or "gmod_tool "..k,
					v.ConfigName or k,
					v.BuildCPanel
				);
			end
		end
	end*/
end
hook.Add("AddToolMenuTabs", "EnvironmentsAddTabs", AddToolTab);

function Environments.ConfigMenu(Panel)
	Panel:ClearControls();
	
	if(Environments.CurrentVersion > Environments.Version) then
		local RED = Color(255,0,0,255);
		Panel:Help("Your build of Environments is out of date"):SetTextColor(RED);
		Panel:Help("LATEST BUILD: "..Environments.CurrentVersion):SetTextColor(RED);
		Panel:Help("If you are getting this message on an internet server, tell the admin to update.");
	elseif(Environments.CurrentVersion == 0) then
		local ORANGE = Color(255,128,0,255);
		Panel:Help("Couldn't determine latest BUILD. Make sure, you are connected to the Internet."):SetTextColor(ORANGE);
	else
		local GREEN = Color(0,255,0,255);
		Panel:Help("Your Environments BUILD is up-to-date."):SetTextColor(GREEN);
	end
	Panel:Help("Current BUILD: "..Environments.Version)
	
	Panel:Help("Suit Color")
	Panel:AddControl("Color", {
		Label = "#suit_color",
		Red = "env_suit_color_r",
		Green = "env_suit_color_g",
		Blue = "env_suit_color_b",
		ShowAlpha = "0",
		ShowHSV = "1",
		ShowRGB = "1",
		Multiplier = "255"
	})
	
	Panel:Help("HUD Temperature Unit")
	local options = {}
	options["Fahrenheit"] = {env_hud_unit = "f"}
	options["Kelvin"] = {env_hud_unit = "k"}
	options["Celcius"] = {env_hud_unit = "c"}
	Panel:AddControl("ComboBox", { Label = "Hud Temperature Unit", MenuButton = 0, Options = options})
	
	Panel:Help("Enable Planet Effects")
	Panel:AddControl("CheckBox", {Label = "Enable Planet Effects?", Command = "env_effects_enable"} )
	
	Panel:Help("Enable HUD")
	Panel:AddControl("CheckBox", {Label = "Enable HUD?", Command = "env_hud_enabled"} )
	
	Panel:Help("Enable Breathing Sound")
	Panel:AddControl("CheckBox", {Label = "Enable Breathing Sound?", Command = "env_breathing_sound_enabled"} )
	
	/*Panel:Button( "Open Help Page", "pp_superdof" )
	-- The HELP Button
	if(Environments.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end*/
end

/*function Environments.Credits(Panel)
	-- The Credits Button
	if(Enviroments.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("credits");
		VGUI:SetTopic("Credits");
		VGUI:SetText("Credits");
		VGUI:SetImage("gui/silkicons/star");
		Panel:AddPanel(VGUI);
		Panel:Help("Here, you can report bugs. If you can't type in the HTML-Formulars, visit "..Environments.HTTP.BUGS.." with your webbrowser");
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetTopic("Bugs");
		VGUI:SetText("Bugs");
		VGUI:SetImage("gui/silkicons/exclamation");
		VGUI:SetURL(Environments.HTTP.BUGS);
		Panel:AddPanel(VGUI);
		Panel:Help("");
		
		local HTML = vgui.Create("HTML",self);
		-- Crappy Quicks-HTML for a crappy browser (Internet-Explorer)
		HTML:SetHTML([[
			<html>
				<body margin="0" padding="0">
					<center><img margin="0" padding="0" border="0" alt="Latest Environments BUILD" src="]]..Environments.HTTP.VERSION_LOGO..[["/ ></center>
				</body>
			</html>
		]]);
		HTML:SetSize(128,164);
		Panel:AddPanel(HTML);
		
		-- Tells, if he is out-of-date
		if(Environments.CurrentVersion > Environments.Version) then
			HasLatestVersion(Panel);
		elseif(Environments.CurrentVersion == 0) then
			local ORANGE = Color(255,128,0,255);
			Panel:Help("Couldn't determine latest BUILD. Make sure, you are connected to the Internet."):SetTextColor(ORANGE);
		else
			local GREEN = Color(0,255,0,255);
			Panel:Help("Your Environments BUILD is up-to-date."):SetTextColor(GREEN);
		end
		Panel:Help("BUILD: "..Environments.Version)
	else
		Panel:Help("It seems like, you are not connected to the Internet. Therefore, the Credits and Bugreport can't be shown. If you are sure, you are connected and have receive this message accidently, you can manually enable the online help below.");
		Panel:CheckBox("Manual Override","cl_has_internet"):SetToolTip("Changes apply after you restarted GMod");
	end
end*/
