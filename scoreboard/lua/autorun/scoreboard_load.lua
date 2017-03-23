
if SERVER then
	AddCSLuaFile("scoreboard/scoreboard.lua")
end
if CLIENT then
	include("scoreboard/scoreboard.lua")
end

