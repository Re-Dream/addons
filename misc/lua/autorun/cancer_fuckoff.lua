
hook.Add("EntityEmitSound", "drown_fuckoff", function(data)
	if type(data.Entity) ~= "Player" then return end
	if data.Entity:WaterLevel() < 1 and data.OriginalSoundName == "Player.DrownStart" then return false end
end)

if SERVER then
	concommand.Remove("rb655_playsound_all")
end

