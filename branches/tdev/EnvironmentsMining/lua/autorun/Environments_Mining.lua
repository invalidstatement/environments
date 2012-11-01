------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

if not Environments then
	Environments = {}
end

if SERVER then
	AddCSLuaFile("autorun/Environments_Mining.lua")
end

function Environments.LoadMining()
	if CLIENT then
		include("environments/miningmod.lua")
	else
		include("environments/miningmod.lua")
		AddCSLuaFile("environments/miningmod.lua")
	end
end
Environments.LoadMining()

print("==============================================")
print("==     Environments Mining Mod Installed    ==")
print("==============================================")

