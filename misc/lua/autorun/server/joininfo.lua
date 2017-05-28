local function HandleSharedPlayer(ply)
		if ply:IsFamilySharing() then
		print(string.format("Family Sharing: %s|%s has been lent Garry's Mod by %s",
			ply:Nick(),
			ply:SteamID(),
			ply:GetLender()
		))
	end
end

hook.Add("PlayerAuth","FamilyShareChecker",HandleSharedPlayer)
