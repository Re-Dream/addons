
local tag = "ReDreamScoreboard"

local Config = {}

function Config:Init()
	self:SetSize(192, 256)

	self:MakePopup()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function Config:Paint(w, h)
	surface.SetDrawColor(77, 81, 96, 230)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(255, 255, 255, 40)
	surface.DrawOutlinedRect(0, 0, w, h)

	surface.SetFont(tag .. "Option")
	local txt = "Configuration"
	surface.SetTextPos(6 + 2, 6 + 2)
	surface.SetTextColor(0, 0, 0, 164)
	surface.DrawText(txt)

	surface.SetTextPos(6, 6)
	surface.SetTextColor(255, 255, 255)
	surface.DrawText(txt)
end

vgui.Register(tag .. "Config", Config, "EditablePanel")

