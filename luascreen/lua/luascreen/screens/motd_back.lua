
local ENT = _G.ENT or {}

ENT.Identifier = "motd_back"
ENT.ScreenWidth = 1175
ENT.ScreenHeight = 645
ENT.ScreenScale = 0.15
ENT.MaxRange = 192

if CLIENT then
	local grad = Material("vgui/gradient-d")
	local function DrawOutlinedRect(x, y, w, h, thicc)
		for i = 0, thicc - 1 do
			surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
		end
	end

	function ENT:Draw3D2D(w, h, s)
		local mX, mY = self:CursorPos()

		-- background
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(Color(175, 190, 225, 225))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(32, 32, 32, 100 + math.abs(math.sin(RealTime() * 0.25)) * 27))
		surface.SetMaterial(grad)
		surface.DrawTexturedRect(0, 0, w, h)

		local thicc = 5
		surface.SetDrawColor(Color(0, 64, 127, 192))
		DrawOutlinedRect(0, 0, w, h, thicc)
	end
end

if istable(GAMEMODE) then
	luascreen.RegisterScreen(ENT.Identifier, ENT)
end

