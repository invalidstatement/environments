------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local Version = 0.1

UseLS = true --Should the ALPHA lifesupport be loaded? Not recomended, its still in development.
local UseRD = true --Should the EXTREME WIP RD be loaded?

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
	end
	concommand.Add("Env_Reload_Hud", Reload)
	
	if UseRD then
	
	end
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	
	AddCSLuaFile("environments/core/cl_environments.lua")
	AddCSLuaFile("environments/spawn_menu.lua")
	
	if UseLS then
		include("environments/ls/sv_lifesupport.lua")
	
		AddCSLuaFile("vgui/HUD.lua")
		AddCSLuaFile("vgui/lsinfo.lua")
		AddCSLuaFile("environments/ls/cl_lifesupport.lua")
	end
	
	if UseRD then
	
	end
end

print("==============================================")
print("== Environments ALPHA Version "..Version.." Installed ==")
print("==============================================")
