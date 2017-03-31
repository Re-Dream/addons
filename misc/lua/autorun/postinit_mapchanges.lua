
do return end -- never worked

if CLIENT then return end

local classes = {
	["trigger_teleport"] = true,
	["beam"] = true,
	["point_spotlight"] = true,
	["spotlight_end"] = true,
	["env_sprite"] = true,
}
hook.Add("InitPostEntity", "abstraction-changepos", function()
	if not game.GetMap():lower():match("abstraction") then
		hook.Remove("InitPostEntity", "abstraction-changepos")
		return
	end

	timer.Simple(0, function()
		for _, ent in next, ents.FindInSphere(Vector(7440, 16, 64), 128) do
			if classes[ent:GetClass()] then
				ent:SetPos(Vector(6725, -143, 28))
			end
		end

		hook.Remove("InitPostEntity", "abstraction-changepos")
	end)
end)

