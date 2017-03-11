
hook.Add("PlayerLoadout", "temp_loadout", function(ply)
	ply:Give("weapon_physgun")
	ply:Give("weapon_physcannon")
	ply:Give("weapon_crowbar")

	ply:Give("gmod_tool")
	ply:Give("gmod_camera")

	ply:Give("none")
	if ply:HasWeapon("none") then
		ply:SelectWeapon("none")
	end

	return true
end)


