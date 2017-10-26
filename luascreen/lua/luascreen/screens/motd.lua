
-- local ENT = {}

ENT.Identifier = "motd"
ENT.Coords = {
	s = 0.15,
	w = 1175,
	h = 645,
}
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
		local buttX = 64
		local buttY = h * 0.925
		local buttW, buttH = 256, 48
		local mX, mY = self:CursorPos()
		local hovering = false

		-- background
		surface.SetDrawColor(Color(210, 210, 245, 255))
		surface.DrawRect(0, 0, w, h)

		-- logo
		local logoW, logoH = 512, 512
		local logoX = (w + buttW + buttX) * 0.5 - logoW * 0.5
		local logoY = h * 0.5 - logoH * 0.5
		local _hovering = IsHovering(logoX, logoY, logoW, logoH, mX, mY)
		hovering = hovering and hovering or _hovering
		local a = 0
		if _hovering and not self.Using then
			a = 30
		elseif _hovering and self.Using then
			self.Choice = #buttons
			a = 45
		end

		local logo = WebMaterial("redream_logo_transparent", "https://gmlounge.us/media/redream-logo-transparent.png")
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(logo)
		surface.DrawTexturedRect(logoX, logoY, logoW, logoH)

		surface.SetDrawColor(Color(255, 255, 255, a))
		surface.DrawRect(logoX, logoY, logoW, logoH)
		surface.SetDrawColor(Color(255, 255, 255, a * 5))
		surface.DrawOutlinedRect(logoX, logoY, logoW, logoH)

		surface.SetDrawColor(Color(32, 32, 32, 100 + math.abs(math.sin(RealTime() * 0.1)) * 27))
		surface.SetMaterial(grad)
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(Color(0, 0, 127, 192))
		DrawOutlinedRect(0, 0, w, h, 5)

		for k, butt in next, buttons do
			if butt.text and (not butt.req or isfunction(butt.req) and butt.req()) then
				local _x = buttX
				local _y = buttY - buttH
				local _hovering = IsHovering(_x, _y, buttW, buttH, mX, mY)
				local a = 194
				if _hovering and not self.Using then
					a = 208
				elseif _hovering and self.Using then
					self.Choice = k
					a = 224
				end
				surface.SetDrawColor(Color(0, 0, 92, a))
				surface.DrawRect(_x, _y, buttW, buttH)

				surface.SetFont("lua_screen_motd_button")
				local txt = butt.text
				local txtW, txtH = surface.GetTextSize(txt)
				surface.SetTextColor(Color(220, 220, 255, 255))
				surface.SetTextPos(_x + buttW * 0.5 - txtW * 0.5, _y + txtH * 0.5 - 7)
				surface.DrawText(txt)
				buttY = buttY - buttH - 8
				hovering = hovering and hovering or _hovering
			end
		end
		self.Hovering = hovering

		surface.SetFont("lua_screen_motd_header2")
		local txt = "Welcome!"
		local txtW, txtH = surface.GetTextSize(txt)
		draw.SimpleTextOutlined(txt, "lua_screen_motd_header2", buttX + buttW * 0.5 - txtW * 0.5, buttY - buttH - 7, Color(225, 225, 255, 255), 0, 0, 3, Color(0, 0, 0, 41))
	end

	function ENT:OnMousePressed()
		self._Using = true
	end

	local nextUse = 0
	function ENT:OnMouseReleased()
		if self.Hovering and self._Using and self.Choice and nextUse < RealTime() then
			print(self.Hovering, self.Choice)
			buttons[self.Choice].func()
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
			nextUse = RealTime() + 1
		end
		self._Using = false
	end
end

-- luascreen.RegisterScreen(ENT.Identifier, ENT)

