
local tag = "lua_screen"

luascreen.Screens = {}
for _, file in next, (file.Find("luascreen/screens/*.lua", "LUA")) do
	AddCSLuaFile("luascreen/screens/" .. file)

	_G.ENT = {}
	include("luascreen/screens/" .. file)
	if ENT.Identifier then
		luascreen.Screens[ENT.Identifier] = ENT
	else
		ErrorNoHalt("no identifier for screen " .. file)
	end
	ENT = nil
end

if SERVER then
	function luascreen.SpawnScreen(id, pos, ang)
		local screen = ents.Create(tag)
		if id  then screen:SetScreen(id) end
		if pos then	screen:SetPos(pos)   end
		if ang then screen:SetAngles()   end
		return screen
	end

	hook.Add("InitPostEntity", tag, function()
		if file.Exists("luascreen/placement/" .. game.GetMap() .. ".lua", "LUA") then
			luascreen.Placement = include("luascreen/placement/" .. game.GetMap() .. ".lua")

			local ok, err = pcall(function()
				for _, data in next, luascreen.Placement do
					local screen = luascreen.SpawnScreen(data.id, data.pos, data.ang)
					screen:Grip(false)
				end
			end)
		end
	end)
end

