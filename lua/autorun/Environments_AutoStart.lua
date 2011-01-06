------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local version = 17

UseLS = true --Should the ALPHA lifesupport be loaded? Not recomended, its still in development.
local UseRD = false --Should the EXTREME WIP RD be loaded?

if CLIENT then	
	include("environments/spawn_menu.lua")
	include("environments/core/cl_environments.lua")
	
	if UseLS then
		include("vgui/lsinfo.lua")
		include("vgui/HUD.lua")
		include("environments/ls/cl_lifesupport.lua")
	end
	
	local function Reload()
		include("vgui/HUD.lua")
		include("vgui/lsinfo.lua")
	end
	concommand.Add("env_reload_hud", Reload)
	
	if UseRD then
	
	end
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	
	AddCSLuaFile("environments/core/cl_environments.lua")
	AddCSLuaFile("environments/spawn_menu.lua")
	
	if UseLS then
		include("environments/ls/sv_lifesupport.lua")
		resource.AddFile("resource/fonts/digital-7 (italic).ttf")
		AddCSLuaFile("vgui/HUD.lua")
		AddCSLuaFile("vgui/lsinfo.lua")
		AddCSLuaFile("environments/ls/cl_lifesupport.lua")
	end

	if UseRD then
	
	end
end
print("==============================================")
print("== Environments ALPHA Revision "..version.." Installed ==")
print("==============================================")

local function GetOnlineVersion( callback )
	http.Get("http://environments.googlecode.com/svn/trunk/","",function(contents,size)
		local rev = tonumber(string.match( contents, "Revision ([0-9]+)" ))
		callback(rev,contents,size)
	end)
end

local function VersionCheck(rev, contents, size)
	if version >= rev then
		print("Environments Is Up To Date")
	else
		print("A newer version of Environments is availible! Version: "..rev)
	end
end
GetOnlineVersion(VersionCheck)