
local tag = "AFK"

afk = {}
afk.AFKTime = CreateConVar("mp_afktime", "90", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "The time it takes for a player to become AFK while inactive.")

local PLAYER = FindMetaTable("Player")
function PLAYER:IsAFK()
	return self.isAFK
end
function PLAYER:AFKTime()
	return self.afkTime
end

if SERVER then
	util.AddNetworkString(tag)

	net.Receive(tag, function(_, ply)
		local is = net.ReadBool()
		ply.isAFK = is
		ply.afkTime = is and CurTime() - afk.AFKTime:GetInt() or nil
		hook.Run("AFK", ply, is)
		net.Start(tag)
			net.WriteUInt(ply:EntIndex(), 8)
			net.WriteBool(is)
		net.Broadcast()
	end)

	hook.Add("AFK", "AFKSound", function(ply, is)
		ply:EmitSound(not is and "replay/cameracontrolmodeentered.wav" or "replay/cameracontrolmodeexited.wav")
	end)
elseif CLIENT then
	afk.Mouse = { x = 0, y = 0 }
	afk.Focus = system.HasFocus()
	afk.Is = false

	hook.Add("RenderScene", tag, function()
		if LocalPlayer() == NULL or not LocalPlayer() then return end
		afk.When = CurTime() + afk.AFKTime:GetInt()
		hook.Remove("RenderScene", tag)
	end)
	local function Input()
		if not afk.When then return end
		afk.When = CurTime() + afk.AFKTime:GetInt()
		if afk.Is then
			net.Start(tag)
				net.WriteBool(false)
			net.SendToServer()
		end
		afk.Is = false
	end
	hook.Add("StartCommand", tag, function(ply, cmd)
		if ply ~= LocalPlayer() or not afk.When then return end
		local mouseMoved = (system.HasFocus() and (afk.Mouse.x ~= gui.MouseX() or afk.Mouse.y ~= gui.MouseY()) or false)
		if  mouseMoved or
			cmd:GetMouseX() ~= 0 or
			cmd:GetMouseY() ~= 0 or
			cmd:GetButtons() ~= 0 or
			(afk.Focus == false and afk.Focus ~= system.HasFocus())
		then
			Input()
		end
		if afk.When < CurTime() and not afk.Is then
			afk.Is = true
			net.Start(tag)
				net.WriteBool(true)
			net.SendToServer()
		end
	end)
	hook.Add("KeyPress", tag, Input)
	hook.Add("KeyRelease", tag, Input)
	hook.Add("PlayerBindPress", tag, Input)
	local function getAFKtime()
		return math.abs(math.max(CurTime() - afk.When, 0))
	end

	net.Receive(tag, function()
		local ply = Entity(net.ReadUInt(8))
		local is = net.ReadBool()
		ply.isAFK = is
		ply.afkTime = is and CurTime() - afk.AFKTime:GetInt() or nil
		hook.Run("AFK", ply, is)
	end)

	surface.CreateFont(tag, {
		font = "Roboto Cn",
		size = 36,
		italic = true,
		weight = 800,
	})
	surface.CreateFont(tag .. "Normal", {
		font = "Roboto Bk",
		size = 48,
		italic = false,
		weight = 800,
	})

	local function plural(num)
		return ((num > 1 or num == 0) and "s" or "")
	end
	local function DrawTranslucentText(txt, x, y, a, col)
		surface.SetTextPos(x + 2, y + 2)
		surface.SetTextColor(Color(0, 0, 0, 127 * (a / 255)))
		surface.DrawText(txt)

		surface.SetTextPos(x, y)
		if col then
			surface.SetTextColor(Color(col.r, col.g, col.b, 190 * (a / 255)))
		else
			surface.SetTextColor(Color(255, 255, 255, 190 * (a / 255)))
		end
		surface.DrawText(txt)
	end
	local a = 0
	afk.Draw = CreateConVar("cl_afk_hud_draw", "1", { FCVAR_ARCHIVE }, "Should we draw the AFK HUD?")
	hook.Add("HUDPaint", tag, function()
		if not afk.Draw:GetBool() then return end
		afk.Focus = system.HasFocus()
		if not afk.Is then a = 0 return end

		a = math.Clamp(a + FrameTime() * 120, 0, 255)

		local AFKTime = getAFKtime()
		--[[
		local h = math.floor(AFKTime / 60 / 60)
		local m = math.floor(AFKTime / 60 - h * 60)
		local s = math.floor(AFKTime - m * 60 - h * 60 * 60)

		local timeString = ""
		if h > 0 then
			timeString = timeString .. h .. " hour" .. plural(h) .. ", "
		end
		if m > 0 then
			timeString = timeString .. m .. " minute" .. plural(m) .. ", "
		end
		timeString = timeString .. s .. " second" .. plural(s)
		]]
		local timeString = string.NiceTime(AFKTime)

		surface.SetFont(tag)
		local txt = "You've been away for"
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetFont(tag .. "Normal")
		local timeW, timeH = surface.GetTextSize(timeString)
		local wH = txtH + timeH

		surface.SetDrawColor(Color(0, 0, 0, 127 * (a / 255)))
		surface.DrawRect(0, ScrH() * 0.5 * 0.5 - wH * 0.5 - txtH * 0.33, ScrW(), wH + txtH * 0.33 * 2 - 3)

		surface.SetFont(tag)
		DrawTranslucentText(txt, ScrW() / 2 - txtW / 2, ScrH() / 2 / 2 - wH / 2, a * 0.5)

		surface.SetFont(tag .. "Normal")
		DrawTranslucentText(timeString, ScrW() / 2 - timeW / 2, ScrH() / 2 / 2 - wH / 2 + txtH, a, Color(197, 167, 255))
	end)

end

