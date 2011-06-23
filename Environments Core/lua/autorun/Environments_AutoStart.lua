------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

if not Environments then
	Environments = {}
end

Environments.Hooks = {}
Environments.Version = 112
Environments.CurrentVersion = 0 --for update checking
Environments.FileVersion = 5
//User Options
Environments.ForceLoad = false
Environments.UseSuit = true
Environments.Debug = true

local start = SysTime()
if CLIENT then
	include("environments/core/cl_logging.lua")
	include("environments/menu.lua")
	function Load(msg)
		include("vgui/lsinfo.lua")
		include("vgui/HUD.lua")
		include("environments/core/cl_core.lua")
		if Environments.UseSuit then
			include("environments/spacesuits/cl_suit.lua")
		end
        
		local function Reload()
			include("vgui/HUD.lua")
			include("vgui/lsinfo.lua")
			LoadHud()
		end
		concommand.Add("env_reload_hud", Reload)
        
		if msg then
			LoadHud()
			print("Environments Version "..msg:ReadShort().." Running On Server")
		end
	end
	usermessage.Hook("Environments", Load)
	
	timer.Create("ShouldDoBackupLoad", 2, 1, function()
		if Environments.Suit then return end --has it already loaded?
		if CAF and CAF.GetAddon("Spacebuild") then --load in case of SB
			Load()
		end
		if SinglePlayer then
			--Load()
		end
	end)
        
	concommand.Add("env_update_check", function(ply, cmd, args)
		GetOnlineVersion(true)
	end)
else
	include("environments/core/sv_environments.lua")
	include("environments/core/sv_environments_planets.lua")
	include("environments/core/sv_environments_players.lua")
	if Environments.UseSuit then
		include("environments/spacesuits/sv_suit.lua")
	end
	include("environments/events/sv_events.lua")
	include("environments/core/sv_ls_support.lua")
        
	AddCSLuaFile("autorun/Environments_AutoStart.lua")
	AddCSLuaFile("environments/core/cl_core.lua")
	AddCSLuaFile("environments/spawn_menu.lua")
	AddCSLuaFile("vgui/HUD.lua")
	AddCSLuaFile("environments/menu.lua")
	AddCSLuaFile("vgui/lsinfo.lua")
	AddCSLuaFile("environments/spacesuits/cl_suit.lua")
	AddCSLuaFile("environments/core/cl_logging.lua")
        
	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
	resource.AddFile( "materials/models/null.vmt" )
	resource.AddFile( "materials/models/null.vtf" )
end
print("==============================================")
print("==    Environments Revision "..Environments.Version.." Installed   ==")
print("==============================================")

if Environments.Debug then
	print("Environments Load Time: "..(SysTime() - start))
end

local onlineversion
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
		print("A newer version of Environments is availible! Version: "..rev.." You have Version: "..Environments.Version)
		print("Please update!")
	end
	Environments.CurrentVersion = rev
	
	if CLIENT then
		if Environments.ConfigPanel then
			Environments.ConfigMenu(Environments.ConfigPanel) --update the config panel to show that it is up to date
		end
	end
end
GetOnlineVersion()

//Add The Server Tag
if SERVER then
	timer.Create("SetTagsEnvironments", 10, 0, function()
		local servertags = GetConVarString("sv_tags")
		if servertags == nil then
			RunConsoleCommand("sv_tags", "Environments")
		elseif not string.find(servertags, "Environments", 1, true) then
			servertags = servertags .. ",Environments"
			RunConsoleCommand("sv_tags", servertags)        
		end
	end)
end

//Fixes the crazy death notices
if CLIENT then
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
end
