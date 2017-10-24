
if CLIENT then return end

mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
	local ok = hook.Run("CanPlayerSuicide", ply)
	if ok == false then
		return false, "Can't suicide"
	end

	caller:KillSilent()
	caller:CreateRagdoll()
end)

mingeban.CreateCommand("revive", function(caller)
	local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
	caller:Spawn()
	caller:SetPos(oldPos)
	caller:SetEyeAngles(oldAng)
end)

mingeban.CreateCommand("cmd", function(caller, line)
	caller:ConCommand(line)
end)

mingeban.CreateCommand("retry", function(caller)
	caller:ConCommand("retry")
end)

