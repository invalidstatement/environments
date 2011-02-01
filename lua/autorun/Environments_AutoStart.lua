------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local version = 31
local onlineversion

if CLIENT then	
	function Load()
		include("vgui/lsinfo.lua")
		include("vgui/HUD.lua")
		include("environments/core/cl_core.lua")
	
		local function Reload()
			include("vgui/HUD.lua")
			include("vgui/lsinfo.lua")
			LoadHud()
		end
		concommand.Add("env_reload_hud", Reload)
	end
	usermessage.Hook("Environments", Load)
	
	timer.Create("Sbcheck", 2, 1, function()
		if CAF and CAF.GetAddon("Spacebuild") then
			Load()
		end
	end)
	
	concommand.Add("env_update_check", function(ply, cmd, args)
		GetOnlineVersion(VersionCheck, true)
	end)
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	include("environments/core/sv_environments_players.lua")
	
	AddCSLuaFile("autorun/Environments_AutoStart.lua")
	AddCSLuaFile("environments/core/cl_core.lua")
	AddCSLuaFile("environments/spawn_menu.lua")
	AddCSLuaFile("vgui/HUD.lua")
	AddCSLuaFile("vgui/lsinfo.lua")
	
	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
end
print("==============================================")
print("== Environments ALPHA Revision "..version.." Installed ==")
print("==============================================")

function GetOnlineVersion( callback, printChecking )
	if printChecking then
		print("Checking for updates....")
	end
	http.Get("http://environments.googlecode.com/svn/trunk/","",function(contents,size)
		local rev = tonumber(string.match( contents, "Revision ([0-9]+)" ))
		callback(rev,contents,size,printChecking)
	end)
end

local function VersionCheck(rev, contents, size, pc)
	if not pc then
		if version >= rev then
			print("   Environments Is Up To Date")
		else
			print("   A newer version of Environments is availible! Version: "..rev)
			print("   Please update!")
		end
	end
	onlineversion = rev
end
GetOnlineVersion(VersionCheck)