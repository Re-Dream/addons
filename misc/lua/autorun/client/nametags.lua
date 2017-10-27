
local tag = "nametags"

local function CreateFont(name, data, blurSize)
	surface.CreateFont(name, data)
	data.blursize = blurSize
	data.additive = false
	surface.CreateFont("blur_" .. name, data)
end

CreateFont(tag, {
	font = "Roboto",
	weight = 800,
	size = 128,
	additive = true
}, 12)
CreateFont(tag .. "2", {
	font = "Roboto",
	weight = 550,
	size = 64,
	additive = true
}, 12)

local awayPhrases = {
	"Zzz",
	"Peacefully dreaming",
	"Passed out",
	"Gone for a walk",
	"Brainstorming",
	"Out of coffee"
}
local function PlayersByRange()
	local plys = player.GetAll()
	table.sort(plys, function(a, b)
		return a:GetPos():Distance(EyePos()) > b:GetPos():Distance(EyePos())
	end)
	return plys
end
local lply
local maxDist = 1024
local h
local function DrawText(txt, font, y, col)
	if not h then
		surface.SetFont(tag)
		local _, _h = surface.GetTextSize("W")
		h = _h
	end
	local y = y * h or 0
	surface.SetFont("blur_" .. font)
	local txtW, txtH = surface.GetTextSize(txt)
	for i = 1, 3 do
		surface.SetTextPos(-txtW * 0.5, y)
		surface.SetTextColor(Color(0, 0, 0))
		surface.DrawText(txt)
	end

	surface.SetFont(font)
	local txtW, txtH = surface.GetTextSize(txt)
	surface.SetTextPos(-txtW * 0.5, y)
	surface.SetTextColor(col)
	surface.DrawText(txt)
end
hook.Add("PostDrawTranslucentRenderables", tag, function()
	if not IsValid(lply) then lply = LocalPlayer() return end
	for _, ply in next, PlayersByRange() do
		local isLply = lply == ply
		local shouldDraw = false
		shouldDraw = not ply:Crouching() and true or shouldDraw
		shouldDraw = (not isLply or ply:ShouldDrawLocalPlayer()) and shouldDraw or false

		local alpha = 1
		local dist = ply:GetPos():Distance(EyePos())
		alpha = dist >= maxDist and math.Clamp(1 - (dist - maxDist) / 128, 0, 1) or alpha

		--[[ can't tell what this was for
		if not isLply then
			local lookAng = lply:GetAimVector():Dot(dist) / dist:Length()
			local looking = math.Clamp(lookAng / (math.pi / 8), 0, 1)
			alpha = alpha * looking
		end
		]]

		if shouldDraw and alpha > 0 then
			local pos
			local ent = not ply:Alive() and IsValid(ply:GetRagdollEntity()) and ply:GetRagdollEntity() or ply
			local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
			if bone then
				pos = ent:GetBonePosition(bone)
			else
				pos = ent:EyePos()
			end
			pos = pos + Vector(0, 0, 22.5)

			local ang = EyeAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), -90)

			cam.Start3D2D(pos, ang, 0.045)
				surface.SetAlphaMultiplier(alpha)

				local txt = ply:Nick()
				DrawText(ply:Nick(), tag, 0, team.GetColor(ply:Team()))

				if lply.IsAFK and ply:IsAFK() then
					local AFKTime = math.max(0, CurTime() - ply:AFKTime())
					local h = math.floor(AFKTime / 60 / 60)
					local m = math.floor(AFKTime / 60 % 60)
					local s = math.floor(AFKTime % 60)
					txt = string.format("%.2d:%.2d", h >= 1 and h or m, h >= 1 and m or s)
					local choice = math.Clamp(math.Round((RealTime() * 0.125 + ply:EntIndex()) % #awayPhrases), 1, #awayPhrases)
					DrawText(txt .. " - " .. awayPhrases[choice] .. "...", tag .. "2", 1, Color(160, 160, 255))
				end

				surface.SetAlphaMultiplier(1)
			cam.End3D2D()
		end
	end
end)

