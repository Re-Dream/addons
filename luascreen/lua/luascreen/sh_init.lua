
luascreen = {}

function luascreen.Print(msg)
	Msg"[luascreen] "print(msg)
end

AddCSLuaFile("sh_screens.lua")
include("sh_screens.lua")

