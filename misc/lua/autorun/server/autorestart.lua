
hook.Add("Initialize", "autorestart", function()
	hook.Remove("Initialize", "autorestart")

	if not mingeban then return end

	local autorestarting = false
	local function abort()
		mingeban.utils.print(mingeban.colors.Cyan, "Restart cancelled, players are on.")
		game.ConsoleCommand("mingeban abort\n")
		autorestarting = false
	end
	timer.Create("autorestart", 60, 0, function()
		if (CurTime() / 60 / 60) >= 6 then
			if player.GetCount() < 1 and not mingeban.IsCountdownActive() and not autorestarting then
				mingeban.utils.print(mingeban.colors.Cyan, "Automatic restart, CurTime is imprecise.")
				game.ConsoleCommand("mingeban restart 30\n")
				autorestarting = true
			elseif player.GetCount() > 0 and mingeban.IsCountdownActive() and autorestarting then
				abort()
			end
		end
	end)

	hook.Add("PlayerConnect", "autorestart", function()
		if mingeban.IsCountdownActive() and autorestarting then
			abort()
		end
	end)
end)

