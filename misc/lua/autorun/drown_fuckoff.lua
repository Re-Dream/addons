
hook.Add("EntityEmitSound", "drown_fuckoff", function(data)
	if type(data.Entity) ~= "Player" then return end
	if data.Entity.m_bWasOnGround == nil and data.OriginalSoundName == "Player.DrownStart" then return false end
end)

