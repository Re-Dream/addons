
if CLIENT then return end

pcall(function()
	if not system.IsLinux() then return end

	require("cllup")

	function RefreshLua(line)
		if not isstring(line) then return false, "invalid path" end
		line = line:Trim()
		if line == "" or not line:match("%.lua$") then return false, "invalid file extension" end

		local path = line:match(".+/") or ""
		local filename = line:match("([^/]+)%.lua$")

		local _, folders = file.Find("addons/*", "GAME")
		for _, folder in next, folders do
			local _path = "addons/" .. folder .. "/lua/" .. path .. filename .. ".lua"
			if file.Exists(_path, "GAME") then
				path = _path:match(".+/")
				break
			end
		end

		if path:Trim() == "" or file.IsDir(path, "GAME") then return false, "doesn't exist" end

		local exists = file.Exists(path, "GAME")
		if not exists then return false, "doesn't exist" end

		Msg("[RefreshLua] ") print("Updating " .. path .. filename .. ".lua...")
		return HandleChange_Lua(path .. "/", filename, "lua")
	end

	mingeban.CreateCommand("refreshlua", function(caller, line)
		local success, info = RefreshLua(line)

		if success == false then
			return false, info
		end
	end)
end)

mingeban.CreateCommand("lfind", function(caller, line)
	RunConsoleCommand("lua_find", line)
end)

mingeban.CreateCommand("lmfind", function(caller, line)
	caller:ConCommand("lua_find_cl " .. line)
end)

mingeban.commands.pm = mingeban.commands.pm2

