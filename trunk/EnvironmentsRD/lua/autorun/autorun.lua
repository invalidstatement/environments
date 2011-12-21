//Creates Tools
AddCSLuaFile("autorun/autorun.lua") --yay me
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

local scripted_ents = scripted_ents
local table = table
local util = util
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

if not Environments then
	Environments = {}
end


if SERVER then
	//Load Main Luas
	AddCSLuaFile("environments/cl_init.lua")

	include("environments/init.lua")

	include("environments/shared.lua")
	AddCSLuaFile("environments/shared.lua")

	include("environments/EntRegister.lua") --sort this file
	AddCSLuaFile("environments/EntRegister.lua")
else
	include("environments/cl_init.lua")
	
	include("environments/shared.lua")
	
	include("environments/EntRegister.lua")
end


print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")

//Load devices and stuff from addons
local Files = file.FindInLua( "environments/lifesupport/*.lua" )
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "environments/lifesupport/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "environments/lifesupport/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	else
		Msg("Loaded: Successfully\n")
	end
end