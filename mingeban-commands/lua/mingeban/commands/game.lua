
if CLIENT then return end

mingeban.CreateCommand({"kill", "wrist", "suicide"}, function(caller, line)
	local ok = hook.Run("CanPlayerSuicide", ply)
	if ok == false then
		return false, "Can't suicide"
	end

	caller:KillSilent()
	caller:CreateRagdoll()
end)

mingeban.CreateCommand({"revive", "respawn"}, function(caller)
	local oldPos, oldAng = caller:GetPos(), caller:EyeAngles()
	caller:Spawn()
	caller:SetPos(oldPos)
	caller:SetEyeAngles(oldAng)
end)

mingeban.CreateCommand("cmd", function(caller, line)
	caller:SendLua(string.format("LocalPlayer():ConCommand(%q)", line))
end)

mingeban.CreateCommand({"vol", "volume"}, function(caller, line)
	caller:ConCommand("mingeban cmd volume " .. line)
end)

mingeban.CreateCommand("retry", function(caller)
	caller:ConCommand("retry")
end)

local defaultWeapons = {
	["weapon_357"] = true,
	["weapon_ar2"] = true,
	["weapon_bugbait"] = true,
	["weapon_crossbow"] = true,
	["weapon_crowbar"] = true,
	["weapon_frag"] = true,
	["weapon_physcannon"] = true,
	["weapon_pistol"] = true,
	["weapon_rpg"] = true,
	["weapon_shotgun"] = true,
	["weapon_slam"] = true,
	["weapon_smg1"] = true,
	["weapon_stunstick"] = true
}
local give = mingeban.CreateCommand("give", function(caller, line, ply, wep)
	if not weapons.Get(wep) then
		wep = "weapon_" .. wep
	end
	if not weapons.Get(wep) or not defaultWeapons[wep] then
		return false, "Invalid weapon"
	end
	ply:Give(wep)
	ply:SelectWeapon(wep)
end)
give:AddArgument(ARGTYPE_PLAYER)
give:AddArgument(ARGTYPE_STRING)
	:SetName("weapon_class")

