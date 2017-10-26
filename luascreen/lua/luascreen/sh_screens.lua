
local tag = "lua_screen"

luascreen.Screens = {}

function luascreen.RegisterScreen(id, scr)
	local found = false
	for _, ent in next, ents.FindByClass(tag) do
		found = true
		table.Merge(ent, scr)
	end
	if found then
		luascreen.Print("refreshed \"" .. id .. "\" screens")
	end
	luascreen.Screens[id] = scr
end

for _, file in next, (file.Find("luascreen/screens/*.lua", "LUA")) do
	AddCSLuaFile("luascreen/screens/" .. file)

	_G.ENT = {}
	include("luascreen/screens/" .. file)
	if ENT.Identifier then
		luascreen.RegisterScreen(ENT.Identifier, table.Copy(ENT))
	else
		ErrorNoHalt("no identifier for file " .. file)
	end
	ENT = nil
end

if SERVER then
	function luascreen.SpawnScreen(id, pos, ang)
		local screen = ents.Create(tag)
		if id  then screen:SetScreen(id) end
		if pos then	screen:SetPos(pos)   end
		if ang then screen:SetAngles(ang)end
		screen:Spawn()
		return screen
	end

	hook.Add("InitPostEntity", tag, function()
		if file.Exists("luascreen/placement/" .. game.GetMap() .. ".lua", "LUA") then
			luascreen.Placement = include("luascreen/placement/" .. game.GetMap() .. ".lua")

			for _, data in next, luascreen.Placement do
				local screen = luascreen.SpawnScreen(data.id, data.pos, data.ang)
				screen:Grip(false)
			end
		end
	end)
end

function luascreen.GetScreens(id)
	local tbl = {}
	for _, ent in next, ents.FindByClass("lua_screen") do
		if not id or ent.Identifier == id then
			tbl[#tbl + 1] = ent
		end
	end
	return tbl
end

