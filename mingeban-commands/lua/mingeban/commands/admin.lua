
if CLIENT then return end

mingeban.CreateCommand("restart", function(caller)
	if not caller:IsAdmin() then return end
	game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
end)

--[[ server stays dead with _restart rip

mingeban.CreateCommand("reboot",function(caller)
	if not caller:IsAdmin() then return end
	game.ConsoleCommand("_restart\n")
end)

]]
