
if not game.GetMap():lower():match("abstraction") then return end

local classes = {
	["trigger_teleport"] = true,
	["beam"] = true,
	["point_spotlight"] = true,
	["spotlight_end"] = true,
	["env_sprite"] = true,
}
hook.Add("InitPostEntity", "abstraction-changepos", function()
	for _, ent in next, ents.FindInSphere(Vector(7440, 16, 64), 64) do
		if classes[ent:GetClass()] then
			ent:SetPos(Vector(8138, -145, 24) + Vector(0, 0, 32))
		end
	end
end)

