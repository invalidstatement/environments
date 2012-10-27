------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

if not Environments then
	Environments = {}
end

Environments.Hooks = {}
Environments.Version = 164
Environments.CurrentVersion = 0 --for update checking
Environments.FileVersion = 8

//User Options
Environments.ForceLoad = false
Environments.UseSuit = true
Environments.Debug = true

if !SinglePlayer then
	SinglePlayer = game.SinglePlayer
end

if file.Open then
	local oldex = file.Exists
	function file.Exists(path, sub)
		if sub then
			if type(sub) == "boolean" and sub == true then
				return oldex(path, "GAME");
			else
				return oldex(path, sub);
			end
		else
			return oldex(path, "DATA");
		end
	end
end


local start = SysTime()
function Environments.Load()
if CLIENT then
	include("environments/core/cl_logging.lua")
	include("environments/menu.lua")
	function Load(msg)
		include("vgui/HUD.lua")
		include("environments/core/cl_core.lua")
		if Environments.UseSuit then
			include("environments/spacesuits/cl_suit.lua")
		end
        
		local function Reload()
			include("vgui/HUD.lua")
			LoadHud()
		end
		concommand.Add("env_reload_hud", Reload)
        LoadHud()
		
		if msg then
			print("Environments Version "..msg:ReadShort().." Running On Server")
		end
		
		//Overwrite CAF to fix issues with tools
		timer.Create("registerCAFOverwrites", 10, 1, function()
			if CAF then
				local old = CAF.GetAddon
				local SB = {}
				local LS = {}
					
				function SB.GetStatus()
					return true
				end
				
				SB.Fake = true

				function LS.GetStatus()
					return true
				end
					
				function CAF.GetAddon(name)
					if name == "Spacebuild" then
						return SB
					elseif name == "Life Support" then
						return LS
					end
					return old(name)
				end
			end
			include("vgui/HUD.lua")
			LoadHud()//it was being retarded
		end)
	end
	usermessage.Hook("Environments", Load)
	
	timer.Create("ShouldDoBackupLoad", 2, 1, function()
		if Environments.Suit then return end --has it already loaded?
		if CAF and CAF.GetAddon and CAF.GetAddon("Spacebuild") and CAF.GetAddon("Spacebuild").Fake != false then --load in case of SB
			SBONSERVER = true
			Load()
		end
	end)
    
	concommand.Add("env_update_check", function(ply, cmd, args)
		GetOnlineVersion(true)
	end)
else
	include("environments/core/sv_overrides.lua")
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
	AddCSLuaFile("environments/spacesuits/cl_suit.lua")
	AddCSLuaFile("environments/core/cl_logging.lua")
    
	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
	resource.AddFile( "materials/models/null.vmt" )
	resource.AddFile( "materials/models/null.vtf" )
end
end
Environments.Load()
print("==============================================")
print("==    Environments Revision "..Environments.Version.." Installed   ==")
print("==============================================")

if Environments.Debug then
	print("Environments Load Time: "..(SysTime() - start))
end

function GetOnlineVersion( printChecking )
	if printChecking then
		print("Checking for updates....")
	end
	if http and http.Get then
		http.Get("http://environments.googlecode.com/svn/trunk/","",function(contents,size)
			local rev = tonumber(string.match( contents, "Revision ([0-9]+)" ))
			if rev and Environments.Version >= rev then
				print("Environments Is Up To Date, Latest Version: "..rev)
			elseif !rev then
				print("No Internet Connection Detected! Environments Update Check Failed")
			else
				print("A newer version of Environments is availible! Version: "..rev..", You have Version: "..Environments.Version)
				print("Please update!")
			end
			Environments.CurrentVersion = rev
			
			if CLIENT then --update the config panel to show that it is up to date
				if Environments.ConfigPanel then
					Environments.ConfigMenu(Environments.ConfigPanel) 
				end
			end
		end)
	end
end
GetOnlineVersion()


//server messages
local desc = {}
desc[1] = "Environments"
desc[2] = "Spacebuild"
--desc[3] = "Environments Spacebuild"

//Add The Server Tag
if SERVER then
	hook.Add("GetGameDescription", "EnvironmentsStatus", function() 
		--if Environments.CurrentVersion and Environments.CurrentVersion > Environments.Version then
			--return "ENVIRONMENTS IS OUT OF DATE"
		--else
			return table.Random(desc)
		--end
	end)
	
	local function Reload(ply, cmd, args)
		if ply != NULL and !ply:IsAdmin() then return end
		if environments then
			for k,v in pairs(environments) do
				if v and v:IsValid() then
					v:Remove()
					v = nil
				else
					v = nil
				end
			end
		end
		Environments.Load()
		environments = {}
		hook.GetTable().InitPostEntity.EnvLoad() --load
		ply:ChatPrint("Environments Has Been Reloaded!")
	end
	concommand.Add("env_reload", Reload) --reloads everything, mainly for dev'ing
end

//Fixes the crazy death notices
if CLIENT then
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
end
