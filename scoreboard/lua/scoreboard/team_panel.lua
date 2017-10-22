
local tag = "ReDreamScoreboard"

surface.CreateFont(tag .. "Team", {
	font = "Roboto",
	size = 19,
	antialias = true,
})

local Team = {}

function Team:SetTeam(t) self.Team = t end
function Team:GetTeam() return self.Team end

function Team:SetLone(b)
	self.Lone = b
	self:DockPadding(0, self:GetLone() and 0 or 24, 0, 0)
	self:GetParent():InvalidateLayout()
	self:InvalidateLayout()
end
function Team:GetLone() return self.Lone end

function Team:PerformLayout()
	self.HeightTo = Lerp(FrameTime() * 10, self.HeightTo or ({self:GetContentSize()})[2], (not self.Lone and self.Hidden) and 24 or ({self:GetContentSize()})[2])
	self:SetTall(self.HeightTo)
end

function Team:Paint(w, h)
	if not self:GetLone() then
		local t = self:GetTeam()
		local tCol = team.GetColor(t)
		tCol.a = 192
		local brightness = (0.299 * tCol.r + 0.587 * tCol.g + 0.114 * tCol.b)

		surface.SetDrawColor(tCol)
		surface.DrawRect(0, 0, w, 24)

		surface.SetDrawColor(Color(0, 0, 0, 127))
		surface.DrawOutlinedRect(0, 0, w, 24)

		surface.SetFont(tag .. "Team")
		local txt = team.GetName(t) .. " (" .. #self:GetChildren() .. ")"
		local txtW, txtH = surface.GetTextSize(txt)
		if brightness <= 177 then
			surface.SetTextPos(6 + 1, 24 * 0.5 - txtH * 0.5 + 1)
			surface.SetTextColor(Color(0, 0, 0, 192))
			surface.DrawText(txt)
		end

		surface.SetTextPos(6, 24 * 0.5 - txtH * 0.5)
		surface.SetTextColor(brightness > 177 and Color(0, 0, 0) or Color(255, 255, 255))
		surface.DrawText(txt)

		local mX, mY = self:LocalCursorPos()
		if self:IsHovered() and mY <= 24 then
			self:SetCursor("hand")
			surface.SetDrawColor(Color(255, 255, 255, self.Depressed and 10 or 20))
			surface.DrawRect(0, 0, w, 24)
		else
			self:SetCursor("arrow")
		end

		return true
	end
end
function Team:DoClick()
	local mX, mY = self:LocalCursorPos()
	if mY > 24 then return end
	self.Hidden = not self.Hidden
end
if Debug then
	function Team:PaintOver(w, h)
		surface.SetDrawColor(Color(255, 255, 0))
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end
Team.GetContentSize = scoreboard.GetContentSize

vgui.Register(tag .. "Team", Team, "DButton")

