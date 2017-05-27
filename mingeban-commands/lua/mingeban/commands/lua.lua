
if CLIENT then return end

pcall(function()
	if not system.IsLinux() then return end

	require("cllup")

	function RefreshLua(line)
		if not isstring(line) then return false, "invalid path" end
		line = line:Trim()
		if line == "" or not line:match("%.lua$") then return false, "invalid file extension" end

		local exists = file.Exists(line, "GAME")
		if not exists then return false, "doesn't exist" end

		local path = line:match(".+/")
		local filename = line:match("([^/]+)%.lua$")

		Msg("[RefreshLua] ") print("Updating " .. path .. filename .. ".lua...")
		HandleChange_Lua(path .. "/", filename, "lua")
	end

	mingeban.CreateCommand("refreshlua", function(caller, line)
		RefreshLua(line)
	end)
end)

mingeban.CreateCommand("lfind", function(caller, line)
	RunConsoleCommand("lua_find", line)
end)

mingeban.CreateCommand("lmfind", function(caller, line)
	caller:ConCommand("lua_find_cl " .. line)
end)

mingeban.commands.pm = mingeban.commands.pm2

