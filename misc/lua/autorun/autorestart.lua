
if not mingeban then return end

local autorestarting = false
hook.Add("Think", "autorestart", function()
	if (CurTime() / 60 / 60) >= 6 then
		if player.GetCount() < 1 and not mingeban.IsCountdownActive() and not autorestarting then
			mingeban.utils.print(mingeban.colors.Cyan, "Automatic restart, CurTime is imprecise.")
			game.ConsoleCommand("mingeban restart 30\n")
			autorestarting = true
		elseif player.GetCount() > 0 and mingeban.IsCountdownActive() and autorestarting then
			mingeban.utils.print(mingeban.colors.Cyan, "Restart cancelled, players are on.")
			game.ConsoleCommand("mingeban abort\n")
			autorestarting = false
		end
	end
end)

