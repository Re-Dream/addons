
if CLIENT then return end

mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
	caller:KillSilent()
	caller:CreateRagdoll()
end)

mingeban.CreateCommand("revive", function(caller, line)
	local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
	caller:Spawn()
	caller:SetPos(oldPos)
	caller:SetEyeAngles(oldAng)
end)

mingeban.CreateCommand("map",function(caller, line)
	if not caller:IsAdmin() then return end
	line = line:gsub(".bsp", "")
	game.ConsoleCommand("changelevel " .. line .. "\n")
end)

mingeban.CreateCommand("maps",function(caller)
	if not caller:IsAdmin() then return end
	for _, v in next, (file.Find("maps/*.bsp", "GAME")) do
		caller:PrintMessage(HUD_PRINTCONSOLE, v)
	end
end)
