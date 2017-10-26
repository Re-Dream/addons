
luascreen = {}

function luascreen.Print(msg)
	Msg("[luascreen] ") print(msg)
end

-- AddCSLuaFile("sh_entity.lua")
AddCSLuaFile("sh_screens.lua")
-- include("sh_entity.lua")
include("sh_screens.lua")

