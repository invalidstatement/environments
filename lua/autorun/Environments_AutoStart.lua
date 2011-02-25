------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
//TO DO
//1. Work on 3D HUD
//2. Fix player models and suits, charred not working, and fingers on HL2 chars
Environments = {}
Environments.Version = 60
Environments.FileVersion = 1
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
	
	local override = false
	if override then
		Load()
	end
	
	concommand.Add("env_update_check", function(ply, cmd, args)
		GetOnlineVersion(VersionCheck, true)
	end)
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	include("environments/core/sv_environments_players.lua")
	include("environments/spacesuits/sv_suit.lua")
	
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
print("== Environments Beta Revision "..Environments.Version.." Installed  ==")
print("==============================================")

function GetOnlineVersion( callback, printChecking )
	if printChecking then
		print("Checking for updates....")
	end
	http.Get("http://environments.googlecode.com/svn/trunk/","",function(contents,size)
		local rev = tonumber(string.match( contents, "Revision ([0-9]+)" ))
		VersionCheck(rev,contents,size,printChecking)
	end)
end

local function VersionCheck(rev, contents, size, pc)
	if not pc then
		if Environments.Version >= rev then
			print("   Environments Is Up To Date")
		else
			print("   A newer version of Environments is availible! Version: "..rev)
			print("   Please update!")
		end
	end
	onlineversion = rev
end
GetOnlineVersion(VersionCheck)