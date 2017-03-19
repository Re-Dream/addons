
if CLIENT then return end

local kill = mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
	caller:KillSilent()
	caller:CreateRagdoll()
end)

local revive = mingeban.CreateCommand("revive", function(caller, line)
	local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
	caller:Spawn()
	caller:SetPos(oldPos)
	caller:SetEyeAngles(oldAng)
end)

