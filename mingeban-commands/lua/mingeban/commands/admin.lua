
if CLIENT then return end

mingeban.CreateCommand("restart", function(caller)
	if not caller:IsAdmin() then return end
	game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
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
