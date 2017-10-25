
if SERVER then
	local kill = mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
		local ok = hook.Run("CanPlayerSuicide", ply)
		if ok == false then
			return false, "Can't suicide"
		end

		caller:KillSilent()
		caller:CreateRagdoll()
	end)
	kill:SetAllowConsole(false)

	local revive = mingeban.CreateCommand({"revive", "respawn"}, function(caller)
		local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
		caller:Spawn()
		caller:SetPos(oldPos)
		caller:SetEyeAngles(oldAng)
	end)
	revive:SetAllowConsole(false)

	local cmd = mingeban.CreateCommand("cmd", function(caller, line)
		caller:SendLua(string.format("LocalPlayer():ConCommand(%q)", line))
	end)
	cmd:SetAllowConsole(false)

	local vol = mingeban.CreateCommand({"vol", "volume"}, function(caller, line)
		caller:ConCommand("mingeban cmd volume " .. line)
	end)
	vol:SetAllowConsole(false)

	local retry = mingeban.CreateCommand("retry", function(caller)
		caller:ConCommand("retry")
	end)
	retry:SetAllowConsole(false)

	local maps = mingeban.CreateCommand("maps", function(caller)
		for _, map in next, (file.Find("maps/*.bsp", "GAME")) do
			caller:PrintMessage(HUD_PRINTCONSOLE, map)
		end
	end)
	maps:SetAllowConsole(false)

	util.AddNetworkString("mingeban-command-tool")
	local tool = mingeban.CreateCommand("tool", function(caller, line, tool)
		net.Start("mingeban-command-tool")
			net.WriteString(tool)
		net.Send(caller)
	end)
	tool:SetAllowConsole(false)
	tool:AddArgument(ARGTYPE_STRING)
		:SetName("tool")
elseif CLIENT then
	net.Receive("mingeban-command-tool", function()
		local name = net.ReadString()

		local tools = weapons.Get("gmod_tool").Tool
		for class, tool in SortedPairs(tools) do
			local toolName = language.GetPhrase(tool.Name and tool.Name:gsub("^#", "") or class)
			if toolName:lower():find(name:lower()) then
				LocalPlayer():ConCommand("gmod_tool " .. class)

				chat.AddText(color_white, "Found tool: " .. toolName)
				surface.PlaySound("garrysmod/content_downloaded.wav")
				return
			end
		end
	end)
end

