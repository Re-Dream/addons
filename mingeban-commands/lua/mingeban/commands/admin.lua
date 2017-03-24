
if CLIENT then return end

mingeban.CreateCommand("restart", function(caller)
	game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
end)

mingeban.CreateCommand("rcon", function(caller, line)
	game.ConsoleCommand(line .. "\n")
end)

local cexec = mingeban.CreateCommand("cexec", function(caller, line, plys, cmd)
	if #plys < 2 then
		plys[1]:ConCommand(cmd)
	else
		for _, ply in next, plys do
			ply:ConCommand(cmd)
		end
	end
end)
cexec:AddArgument(ARGTYPE_PLAYERS)
cexec:AddArgument(ARGTYPE_STRING)
	:SetName("command")

mingeban.CreateCommand("map", function(caller, line)
	line = line:gsub(".bsp", "")
	game.ConsoleCommand("changelevel " .. line .. "\n")
end)

mingeban.CreateCommand("maps", function(caller)
	for _, map in next, (file.Find("maps/*.bsp", "GAME")) do
		caller:PrintMessage(HUD_PRINTCONSOLE, map)
	end
end)

local kick = mingeban.CreateCommand("kick", function(caller, line, ply, reason)
	ply:Kick(reason or "byebye!!")
end)
kick:AddArgument(ARGTYPE_PLAYER)
kick:AddArgument(ARGTYPE_STRING)
	:SetName("reason")
	:SetOptional(true)

--[[ server stays dead with _restart rip

mingeban.CreateCommand("reboot",function(caller)
	if not caller:IsAdmin() then return end
	game.ConsoleCommand("_restart\n")
end)

]]
