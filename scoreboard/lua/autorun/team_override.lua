
if SERVER then return end

team.SetUp(2, "Administrators", Color(133, 199, 166))
team.SetUp(1, "Players", Color(140	, 180, 225))

local PLAYER = FindMetaTable("Player")

PLAYER.RealTeam = PLAYER.RealTeam or PLAYER.Team
function PLAYER:Team()
	if self:RealTeam() == 1001 then
		return self:IsAdmin() and 2 or 1
	end
	return self:RealTeam()
end

