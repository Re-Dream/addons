
if SERVER then
	AddCSLuaFile("luascreen/cl_init.lua")
	AddCSLuaFile("luascreen/sh_init.lua")
end

include("luascreen/sh_init.lua")

if SERVER then
	include("luascreen/sv_init.lua")
end

if CLIENT then
	include("luascreen/cl_init.lua")
end

