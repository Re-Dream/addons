
local function HandleSharedPlayer(ply)
		if ply:IsFamilySharing() then
	end
end

hook.Add("PlayerAuth", "FamilyShareChecker", function(ply)
	if ply:IsFamilySharing() then
		Msg("[FamilySharing]") print(string.format("%s (%s) has been lent Garry's Mod by %s",
			ply:Nick(),
			ply:SteamID(),
			ply:GetLender()
		))
	end
end)

