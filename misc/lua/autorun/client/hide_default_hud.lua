
local tag = "hide_default_hud"

local lply = LocalPlayer()
local drawCrosshair = false
local fn = 0

local cl_crosshair = CreateClientConVar("cl_crosshair", "1")

hook.Add("HUDShouldDraw", tag, function(elem)
	if not IsValid(lply) then lply = LocalPlayer() return end

	local maxHP = lply:GetMaxHealth()
	if elem == "CHudHealth" and lply:Health() == maxHP then
		return false
	end

	if elem == "CHudCrosshair" and cl_crosshair:GetBool() then
		local wep = lply:GetActiveWeapon()
		if IsValid(wep) and wep:IsWeapon() then
			if isfunction(wep.DoDrawCrosshair) then
				drawCrosshair = false
				return
			end
		end

		drawCrosshair = true
		return false
	end
end)

local function drawCircle(x, y, radius, seg, poly)
	local cir

	if poly and (poly.prevX ~= x or poly.prevY ~= y) or not poly then
		radius = radius * 0.5

		cir = {}

		table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
		for i = 0, seg do
			local a = math.rad((i / seg) * -360)
			table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) * 0.5 + 0.5, v = math.cos(a) * 0.5 + 0.5 })
		end

		local a = math.rad(0) -- This is needed for non absolute segment counts
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) * 0.5 + 0.5, v = math.cos(a) * 0.5 + 0.5 })

		cir.prevX = x
		cir.prevY = y
	else
		cir = poly
	end

	surface.DrawPoly(cir)

	return cir
end

local cl_crosshairsize = CreateClientConVar("cl_crosshairsize", "5")
local cl_crosshairquality = CreateClientConVar("cl_crosshairquality", "3")
local cl_crosshaircolor_r = CreateClientConVar("cl_crosshaircolor_r", "255")
local cl_crosshaircolor_g = CreateClientConVar("cl_crosshaircolor_g", "255")
local cl_crosshaircolor_b = CreateClientConVar("cl_crosshaircolor_b", "255")
local cl_crosshaircolor_a = CreateClientConVar("cl_crosshaircolor_a", "192")

local shadowCircle
local circle
cvars.AddChangeCallback("cl_crosshairsize", function()
	shadowCircle = nil
	circle = nil
end, "cl_crosshairsize_change")
cvars.AddChangeCallback("cl_crosshairquality", function()
	shadowCircle = nil
	circle = nil
end, "cl_crosshairquality_change")

local eyeDistAlpha = 0
hook.Add("HUDPaint", tag .. "_crosshair", function()
	if not cl_crosshair:GetBool() then return end
	if ctp and ctp:IsEnabled() and not ctp:IsCrosshairEnabled() then return end
	if not IsValid(lply) then lply = LocalPlayer() return end
	if not lply:Alive() or lply:Health() == 0 then return end

	local wep = lply:GetActiveWeapon()
	if wep.DrawCrosshair == false then
		drawCrosshair = false
	end

	if not drawCrosshair then return end

	local trace = lply:GetEyeTrace()
	local dist = lply:EyePos():Distance(trace.HitPos)
	eyeDistAlpha = Lerp(FrameTime() * 10, eyeDistAlpha, dist >= 32 and 1 or 0.15)

	fn = FrameNumber()

	if eyeDistAlpha < 0.1 then return end

	surface.SetAlphaMultiplier(eyeDistAlpha)

	local x, y
	if lply:ShouldDrawLocalPlayer() then
		local trace = util.QuickTrace(lply:GetShootPos(), lply:EyeAngles():Forward() * 16384, lply)
		local scrPos = trace.HitPos:ToScreen()
		x, y = scrPos.x, scrPos.y
	else
		x, y = ScrW() * 0.5, ScrH() * 0.5
	end
	x, y = math.Round(x), math.Round(y)

	draw.NoTexture()
	local alpha = cl_crosshaircolor_a:GetInt()
	surface.SetDrawColor(Color(0, 0, 0, 192 * (alpha / 255)))
	local size = cl_crosshairsize:GetInt()
	local qual = 2^(math.min(5, cl_crosshairquality:GetInt()))
	shadowCircle = drawCircle(x, y, size + 2, qual, shadowCircle)

	surface.SetDrawColor(Color(cl_crosshaircolor_r:GetInt(), cl_crosshaircolor_g:GetInt(), cl_crosshaircolor_b:GetInt(), alpha))
	circle = drawCircle(x, y, size, qual, circle)

	surface.SetAlphaMultiplier(1)
end)

if ctp then
	ctp._DrawCrosshair = ctp.DrawCrosshair

	function ctp:DrawCrosshair(...)
		if cl_crosshair:GetBool() then return false end

		return ctp._DrawCrosshair(...)
	end
end

hook.Add("PostRender", tag, function()
	if fn ~= FrameNumber() then
		drawCrosshair = false
	end
end)

hook.Add("HUDPaint", tag .. "_hide_voicetalk", function()
	hook.Remove("HUDPaint", tag .. "_hide_voicetalk")

	local mat = Material("voice/icntlk_local")
	mat:SetFloat("$alpha", 0)
	local mat = Material("voice/icntlk_sv")
	mat:SetFloat("$alpha", 0)
	local mat = Material("voice/icntlk_pl")
	mat:SetFloat("$alpha", 0)
end)

