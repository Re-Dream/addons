
local ENT
if istable(GAMEMODE) then
	ENT = {}
else
	ENT = _G.ENT
end

ENT.Identifier = "motd"
ENT.ScreenWidth = 1175
ENT.ScreenHeight = 645
ENT.ScreenScale = 0.15
ENT.MaxRange = 192

if SERVER then
	function ENT:Receive()

	end
end

if CLIENT then
	surface.CreateFont("lua_screen_motd_header", {
		font = "Roboto Cn",
		size = 64,
		weight = 500,
	})
	surface.CreateFont("lua_screen_motd_header2", {
		font = "Roboto Cn",
		size = 52,
		weight = 500,
	})
	surface.CreateFont("lua_screen_motd_button", {
		font = "Roboto Cn",
		size = 32,
		weight = 500,
	})
	surface.CreateFont("lua_screen_motd_status", {
		font = "Roboto Cn",
		size = 24,
		weight = 500,
	})
	local grad = Material("vgui/gradient-d")
	local clock = Material("icon16/clock.png")
	local function DrawOutlinedRect(x, y, w, h, thicc)
		for i = 0, thicc - 1 do
			surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
		end
	end

	local buttons = {
		{
			text = "Control Panel",
			func = function()
				LocalPlayer():ConCommand("mingeban rocket")
			end,
			req  = function()
				return LocalPlayer():IsAdmin()
			end
		},
		{
			text = "GitHub",
			func = function()
				LocalPlayer():ConCommand("mingeban github")
			end
		},
		{
			text = "Collection",
			func = function()
				LocalPlayer():ConCommand("mingeban collection")
			end
		},
		{
			text = "Discord",
			func = function()
				LocalPlayer():ConCommand("mingeban discord")
			end
		},
		{
			text = "Steam Group",
			func = function()
				LocalPlayer():ConCommand("mingeban steam")
			end
		},
		{	-- logo button
			func = function()
				LocalPlayer():ConCommand("mingeban website")
			end
		}
	}
	local function IsHovering(x, y, w, h, mX, mY)
		if not mX or not mY then return false end
		return (mX < x + w and mX > x and mY < y + h and mY > y)
	end
	function ENT:Draw3D2D(w, h, s)
		local buttX = 64
		local buttY = h * 0.925
		local buttW, buttH = 256, 48
		local mX, mY = self:CursorPos()
		local hovering = false

		-- background
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(Color(175, 190, 225, 225))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(32, 32, 32, 100 + math.abs(math.sin(RealTime() * 0.25)) * 27))
		surface.SetMaterial(grad)
		surface.DrawTexturedRect(0, 0, w, h)

		-- logo
		local logoW, logoH = 512, 512
		local logoX = (w + buttW + buttX) * 0.5 - logoW * 0.5
		local logoY = h * 0.5 - logoH * 0.5

		local logo = WebMaterial("redream_logo_transparent_text_stroke", "https://gmlounge.us/media/redream-logo-transparent-text-stroke.png")
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(logo)
		surface.DrawTexturedRect(logoX, logoY, logoW, logoH)

		local padding = 32
		local _hovering = IsHovering(logoX + padding, logoY + padding, logoW - padding * 2, logoH - padding * 2, mX, mY)
		hovering = hovering and hovering or _hovering
		local a = 0
		if _hovering and not self.Using then
			a = 30
		elseif _hovering and self.Using then
			self.Choice = #buttons
			a = 45
		end
		surface.SetDrawColor(Color(255, 255, 255, a))
		surface.DrawRect(logoX + padding, logoY + padding, logoW - padding * 2, logoH - padding * 2)
		surface.SetDrawColor(Color(255, 255, 255, a * 5))
		surface.DrawOutlinedRect(logoX + padding, logoY + padding, logoW - padding * 2, logoH - padding * 2)

		for k, butt in next, buttons do
			if butt.text and (not butt.req or isfunction(butt.req) and butt.req()) then
				local _x = buttX
				local _y = buttY - buttH
				local _hovering = IsHovering(_x, _y, buttW, buttH, mX, mY)
				local a = 194
				if _hovering and not self.Using then
					a = 218
				elseif _hovering and self.Using then
					self.Choice = k
					a = 230
				end
				surface.SetDrawColor(Color(0, 46, 92, a))
				surface.DrawRect(_x, _y, buttW, buttH)

				surface.SetFont("lua_screen_motd_button")
				local txt = butt.text
				local txtW, txtH = surface.GetTextSize(txt)
				surface.SetTextColor(Color(235, 235, 255, 255))
				surface.SetTextPos(_x + buttW * 0.5 - txtW * 0.5, _y + txtH * 0.5 - 7)
				surface.DrawText(txt)
				buttY = buttY - buttH - 8
				hovering = hovering and hovering or _hovering
			end
		end
		if self.Hovering ~= hovering and hovering then
			EmitSound("garrysmod/ui_hover.wav", LocalPlayer():GetEyeTrace().HitPos, LocalPlayer():EntIndex())
		end
		self.Hovering = hovering

		surface.SetFont("lua_screen_motd_header2")
		local txt = "Welcome!"
		local txtW, txtH = surface.GetTextSize(txt)
		draw.SimpleTextOutlined(txt, "lua_screen_motd_header2", buttX + buttW * 0.5 - txtW * 0.5, buttY - buttH - 7 + math.sin(RealTime() * 2.5) * 2, Color(235, 235, 255, 255), 0, 0, 3, Color(0, 0, 0, 41))

		local thicc = 5
		surface.SetDrawColor(Color(0, 64, 127, 225))
		surface.DrawRect(thicc, thicc, w - thicc * 2, 32)

		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(clock)
		surface.DrawTexturedRect(thicc + 4, thicc + 16 - 8, 16, 16)

		surface.SetFont("lua_screen_motd_status")
		local time = CurTime()
		local txt = string.format("Uptime: %.2d:%.2d:%.2d",
			math.floor(CurTime() / 60 / 60), -- hours
			math.floor(CurTime() / 60 % 60), -- minutes
			math.floor(CurTime() % 60) -- seconds
		)
		surface.SetTextColor(Color(235, 235, 255, 192))
		surface.SetTextPos(thicc + 4 + 16 + 4, thicc + 4)
		surface.DrawText(txt)

		local txt = os.date("%H:%M:%S")
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextColor(Color(235, 235, 255, 192))
		surface.SetTextPos(w * 0.5 - txtW * 0.5, thicc + 4)
		surface.DrawText(txt)

		surface.SetDrawColor(Color(0, 64, 127, 192))
		DrawOutlinedRect(0, 0, w, h, thicc)
	end

	function ENT:OnMousePressed()
		self._Using = true
	end

	local nextUse = 0
	function ENT:OnMouseReleased()
		if self.Hovering and self._Using and self.Choice and nextUse < RealTime() then
			print(self.Hovering, self.Choice)
			buttons[self.Choice].func()
			EmitSound("garrysmod/ui_click.wav", LocalPlayer():GetEyeTrace().HitPos, LocalPlayer():EntIndex())
			nextUse = RealTime() + 1
		end
		self._Using = false
	end
end

if istable(GAMEMODE) then
	luascreen.RegisterScreen(ENT.Identifier, ENT)
end

