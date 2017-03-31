
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

local lply
local maxDist = 1024

local h
local function DrawText(txt, font, y, col)
	if not h then
		surface.SetFont(tag)
		h = select(2, surface.GetTextSize("WAW"))
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
local awayPhrases = {
	"Zzz",
	"Peacefully dreaming",
	"Passed out",
	"Gone for a walk",
	"Brainstorming",
	"Out of coffee"
}
hook.Add("PostDrawTranslucentRenderables", tag, function()
	if not IsValid(lply) then lply = LocalPlayer() return end
	local players = player.GetAll()
	table.sort(players, function(a, b)
		local distA = (lply:GetPos() - a:GetPos()):Length()
		local distB = (lply:GetPos() - b:GetPos()):Length()
		return distB < distA
	end)
	for _, ply in next, players do
		local isLply = ply:EntIndex() ~= lply:EntIndex()
		local shouldDraw = false
		shouldDraw = not ply:Crouching() and true or shouldDraw
		shouldDraw = (isLply or ply:ShouldDrawLocalPlayer()) and shouldDraw or false

		local alpha = 1
		local dist = ply:GetPos() - lply:GetShootPos()
		alpha = dist:Length() >= maxDist and math.Clamp(1 - (dist:Length() - maxDist) / 128, 0, 1) or alpha

		if isLply then
			local lookAng = lply:GetAimVector():Dot(dist) / dist:Length()
			local looking = math.Clamp(lookAng / (math.pi / 8), 0, 1)
			alpha = alpha * looking
		end

		if shouldDraw and alpha > 0 then
			local pos
			local ent = not ply:Alive() and IsValid(ply:GetRagdollEntity()) and ply:GetRagdollEntity() or ply
			local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
			if bone then
				pos = ent:GetBonePosition(bone)
			else
				local maxs, center = ent:OBBMaxs(), ent:OBBCenter()
				pos = Vector(center.x, center.y, maxs.z)
			end
			pos = pos + Vector(0, 0, 20)
			local ang = EyeAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), -90)
			cam.Start3D2D(pos, ang, 0.045)
				local txt = ply:Nick()

				surface.SetAlphaMultiplier(alpha)

				DrawText(ply:Nick(), tag, 0, team.GetColor(ply:Team()))
				if lply.IsAFK and ply:IsAFK() then
					local AFKTime = math.abs(math.max(0, CurTime() - ply:AFKTime()))
					local h = math.floor(AFKTime / 60 / 60)
					local m = math.floor(AFKTime / 60 - h * 60)
					local s = math.floor(AFKTime - m * 60 - h * 60 * 60)
					local txt = h > 1 and string.format("%.2d:%.2d", h, m, s) or string.format("%.2d:%.2d", m, s)

					local choice = math.Clamp(math.Round(RealTime() * 0.125 % #awayPhrases), 1, #awayPhrases)
					DrawText(txt .. " - " .. awayPhrases[choice] .. "...", tag .. "2", 1, Color(160, 160, 255))
				end

				surface.SetAlphaMultiplier(1)
			cam.End3D2D()
		end
	end
end)

