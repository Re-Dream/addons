
if SERVER then
	AddCSLuaFile("scoreboard/scoreboard.lua")
	AddCSLuaFile("scoreboard/team_panel.lua")
	AddCSLuaFile("scoreboard/player_panel.lua")
	AddCSLuaFile("scoreboard/config_panel.lua")
else
	include("scoreboard/scoreboard.lua")
end

