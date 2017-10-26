
-- local ENT = {}

ENT.Identifier = "motd"
ENT.Coords = {
	s = 0.15,
	w = 1175,
	h = 645,
}

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

	surface.CreateFont("lua_screen_motd_button", {
		font = "Roboto Cn",
		size = 32,
		weight = 500,
	})

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
				LocalPlayer():ConCommand("mingeban steamgroup")
			end
		},
	}
	local grad = Material("vgui/gradient-d")
	local function DrawOutlinedRect(x, y, w, h, thicc)
		for i = 0, thicc - 1 do
			surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
		end
	end
	local function IsHovering(x, y, w, h, mX, mY)
		if not mX or not mY then return false end
		return (mX < x + w and mX > x and mY < y + h and mY > y)
	end
	function ENT:Draw3D2D(w, h, s)
		surface.SetDrawColor(Color(48, 48, 92, 255))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(Color(32, 32, 32, 127 + math.abs(math.sin(RealTime() * 0.1)) * 32))
		surface.SetMaterial(grad)
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(Color(192, 192, 255, 24))
		DrawOutlinedRect(0, 0, w, h, 5)

		surface.SetFont("lua_screen_motd_header")
		local txt = "Welcome to Re-Dream!"
		local txtW, txtH = surface.GetTextSize(txt)

		surface.SetTextColor(Color(0, 0, 0, 192))
		surface.SetTextPos(w * 0.5 - txtW * 0.5 + 4, h * 0.075 + 4)
		surface.DrawText(txt)

		surface.SetTextColor(Color(220, 220, 255, 192))
		surface.SetTextPos(w * 0.5 - txtW * 0.5, h * 0.075)
		surface.DrawText(txt)

		local y = h * 0.925
		local buttW, buttH = 256, 48
		local mX, mY = self:CursorPos()
		local hovering = false
		for k, butt in next, buttons do
			if not butt.req or isfunction(butt.req) and butt.req() then
				local _x = w * 0.5 - buttW * 0.5
				local _y = y - buttH
				local _hovering = IsHovering(_x, _y, buttW, buttH, mX, mY)
				local a = 164
				if _hovering and not self.Using then
					a = 194
				elseif _hovering and self.Using then
					self.Choice = k
					a = 224
				end
				surface.SetDrawColor(Color(0, 0, 0, a))
				surface.DrawRect(w * 0.5 - buttW * 0.5, y - buttH, buttW, buttH)

				surface.SetFont("lua_screen_motd_button")
				local txt = butt.text
				local txtW, txtH = surface.GetTextSize(txt)
				surface.SetTextColor(Color(220, 220, 255, 192))
				surface.SetTextPos(w * 0.5 - txtW * 0.5, y - buttH + txtH * 0.5 - 7)
				surface.DrawText(txt)
				y = y - buttH - 8
				hovering = hovering and hovering or _hovering
			end
		end
		self.Hovering = hovering
	end

	function ENT:OnMousePressed()
		self._Using = true
	end

	local nextUse = 0
	function ENT:OnMouseReleased()
		if self.Hovering and self._Using and self.Choice and nextUse < RealTime() then
			buttons[self.Choice].func()
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
			nextUse = RealTime() + 1
		end
		self._Using = false
	end
end

-- luascreen.RegisterScreen(ENT.Identifier, ENT)

