AddCSLuaFile("autorun/EnvBigWorld.lua")
AddCSLuaFile("EnvBigWorld/cl_Main.lua")
AddCSLuaFile("EnvBigWorld/shrinker_lib.lua")

EnvBigWorld = {}
EnvBigWorld.Version = 0.1

include( "EnvBigWorld/shrinker_lib.lua" )

if(SERVER) then
	include("EnvBigWorld/sv_Main.lua")
else
	include("EnvBigWorld/cl_Main.lua")
end
