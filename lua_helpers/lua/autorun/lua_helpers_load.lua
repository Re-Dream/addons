
local path = "lua_helpers"

-- shared stuff
for _, filename in pairs((file.Find("lua_helpers/*.lua", "LUA"))) do
	local path = "lua_helpers/" .. filename
	if SERVER and filename:StartWith("sv_") then
		include(path)
	elseif filename:StartWith("cl_") then
		if SERVER then
			AddCSLuaFile(path)
		end

		if CLIENT then
			include(path)
		end
	else
		if SERVER then
			AddCSLuaFile(path)
		end

		include(path)
	end
end

-- server stuff
if SERVER then
	for _, filename in pairs((file.Find("lua_helpers/server/*.lua", "LUA"))) do
		include("lua_helpers/server/" .. filename)
	end
end

-- client stuff
for _, filename in pairs((file.Find("lua_helpers/client/*.lua", "LUA"))) do
	if SERVER then
		AddCSLuaFile("lua_helpers/client/" .. filename)
	end

	if CLIENT then
		include("lua_helpers/client/" .. filename)
	end
end

