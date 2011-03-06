------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
//TO DO
//1. Work on 3D HUD
//2. Fix player models and suits, charred not working, and fingers on HL2 chars
//3. Make it so you can refill your suit without LS3
//4. HUD customizations
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//MAKE A TAB!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Environments = {}
Environments.Hooks = {}
Environments.Version = 84
Environments.FileVersion = 2
local onlineversion

if CLIENT then
	function Load(msg)
		include("vgui/lsinfo.lua")
		include("vgui/HUD.lua")
		include("environments/core/cl_core.lua")
		include("environments/spacesuits/cl_suit.lua")
	
		local function Reload()
			include("vgui/HUD.lua")
			include("vgui/lsinfo.lua")
			LoadHud()
		end
		concommand.Add("env_reload_hud", Reload)
		
		if msg then
			print("Environments Version "..msg:ReadShort().." Running On Server")
		end
	end
	usermessage.Hook("Environments", Load)
	
	timer.Create("Sbcheck", 2, 1, function()
		if CAF and CAF.GetAddon("Spacebuild") then
			Load()
		end
	end)
	
	concommand.Add("env_update_check", function(ply, cmd, args)
		GetOnlineVersion(true)
	end)
	
	local usetab = CreateClientConVar( "CAF_UseTab", "1", true, false )

	/*local function ENVTab()
		spawnmenu.AddToolTab( "Environments", "Environments" )
	end
	hook.Add( "AddToolMenuTabs", "EnvTab", ENVTab)*/
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	include("environments/core/sv_environments_players.lua")
	include("environments/spacesuits/sv_suit.lua")
	include("environments/events/sv_events.lua")
	include("environments/core/sv_ls_support.lua")
	
	AddCSLuaFile("autorun/Environments_AutoStart.lua")
	AddCSLuaFile("environments/core/cl_core.lua")
	AddCSLuaFile("environments/spawn_menu.lua")
	AddCSLuaFile("vgui/HUD.lua")
	AddCSLuaFile("vgui/lsinfo.lua")
	AddCSLuaFile("environments/spacesuits/cl_suit.lua")
	
	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
	resource.AddFile( "materials/models/null.vmt" )
	resource.AddFile( "materials/models/null.vtf" )
end
print("==============================================")
print("==    Environments Revision "..Environments.Version.." Installed    ==")
print("==============================================")

function GetOnlineVersion( printChecking )
	if printChecking then
		print("Checking for updates....")
	end
	http.Get("http://environments.googlecode.com/svn/trunk/","",function(contents,size)
		local rev = tonumber(string.match( contents, "Revision ([0-9]+)" ))
		VersionCheck(rev,contents,size)
	end)
end

function VersionCheck(rev, contents, size)
	if Environments.Version >= rev then
		print("Environments Is Up To Date")
	else
		print("A newer version of Environments is availible! Version: "..rev)
		print("Please update!")
	end
	onlineversion = rev
end
GetOnlineVersion()

//Add The Server Tag
if SERVER then
	timer.Create("SetTagsEnvironments", 5, 1, function()
		local servertags = GetConVarString("sv_tags")
		if servertags == nil then
			RunConsoleCommand("sv_tags", "Environments")
		else
			servertags = servertags .. ",".."Environments"
			RunConsoleCommand("sv_tags", servertags)	
		end
	end)
end


