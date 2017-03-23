
if SERVER then return end

team.SetUp(1, "Admins", Color(164, 210, 213))
team.SetUp(2, "Players", Color(129, 171, 213))

local PLAYER = FindMetaTable("Player")

PLAYER.RealTeam = PLAYER.RealTeam or PLAYER.Team
function PLAYER:Team()
	if self:RealTeam() == 1001 then
		return self:IsAdmin() and 1 or 2
	end
	return self:RealTeam()
end

