
if SERVER then return end

local playerColor = Color(140, 160, 225)
team.SetUp(1, "Players", playerColor)
team.SetUp(1001, "Unassigned", playerColor)
team.SetUp(2, "Administrators", Color(100, 101, 255))

local PLAYER = FindMetaTable("Player")

PLAYER.RealTeam = PLAYER.RealTeam or PLAYER.Team
function PLAYER:Team()
	if self:RealTeam() == 1001 then
		return self:IsAdmin() and 2 or 1
	end
	return self:RealTeam()
end

