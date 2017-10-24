
if SERVER then
	mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
		if not IsValid(caller) then return end

		local ok = hook.Run("CanPlayerSuicide", ply)
		if ok == false then
			return false, "Can't suicide"
		end

		caller:KillSilent()
		caller:CreateRagdoll()
	end)

	mingeban.CreateCommand({"revive", "respawn"}, function(caller)
		if not IsValid(caller) then return end

		local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
		caller:Spawn()
		caller:SetPos(oldPos)
		caller:SetEyeAngles(oldAng)
	end)

	mingeban.CreateCommand("cmd", function(caller, line)
		if not IsValid(caller) then return end

		caller:SendLua(string.format("LocalPlayer():ConCommand(%q)", line))
	end)

	mingeban.CreateCommand({"vol", "volume"}, function(caller, line)
		if not IsValid(caller) then return end

		caller:ConCommand("mingeban cmd volume " .. line)
	end)

	mingeban.CreateCommand("retry", function(caller)
		if not IsValid(caller) then return end

		caller:ConCommand("retry")
	end)

	util.AddNetworkString("mingeban-command-tool")
	local tool = mingeban.CreateCommand("tool", function(caller, line, tool)
		if not IsValid(caller) then return end

		net.Start("mingeban-command-tool")
			net.WriteString(tool)
		net.Send(caller)
	end)
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

