
local tag = "ReDreamScoreboard"

surface.CreateFont(tag .. "Player", {
	font = "Roboto Medium",
	size = 20,
	antialias = true,
})

local Player = {}

function Player:Init()
	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:Dock(LEFT)

	self.Avatar.Click = vgui.Create("DButton", self.Avatar)
	self.Avatar.Click:Dock(FILL)
	function self.Avatar.Click:Paint(w, h)
		return true
	end
	function self.Avatar.Click.DoClick()
		if self.Player:SteamID64() == nil then return end
		gui.OpenURL("https://steamcommunity.com/profiles/" .. self.Player:SteamID64())
	end
	function self.Avatar.Click.DoRightClick()
		local menu = DermaMenu()
		local ply = self.Player

		menu:AddOption("Open Profile", function()
			gui.OpenURL("https://steamcommunity.com/profiles/" .. ply:SteamID64())
		end):SetIcon("icon16/book_go.png")
		menu:AddOption("Copy Profile URL", function()
			SetClipboardText("http://steamcommunity.com/profiles/" .. ply:SteamID64())
		end):SetIcon("icon16/book_link.png")

		menu:AddSpacer()

		menu:AddOption("Copy SteamID", function()
			SetClipboardText(ply:SteamID())
		end):SetIcon("icon16/tag_blue.png")
		menu:AddOption("Copy Community ID", function()
			SetClipboardText(tostring(ply:SteamID64()))
		end):SetIcon("icon16/tag_yellow.png")

		menu:Open()
	end

	self.Info = vgui.Create("DButton", self)
	self.Info:Dock(FILL)
	self.Info:SetCursor("arrow")
	function self.Info.DoDoubleClick()
		if mingeban and mingeban.commands.goto then
			LocalPlayer():ConCommand("mingeban goto _" .. self.Player:EntIndex())
		end
	end
	function self.Info.DoRightClick()
		local menu = DermaMenu()
		local lply = LocalPlayer()
		local ply = self.Player
		if mingeban and mingeban.commands then
			local cmds = mingeban.commands
			if lply ~= ply then
				if cmds.goto then
					menu:AddOption("Go To", function()
						lply:ConCommand("mingeban goto _" .. ply:EntIndex())
					end):SetIcon("icon16/bullet_go.png")
				end

				if LocalPlayer():IsAdmin() then
					if cmds.bring then
						menu:AddOption("Bring", function()
							lply:ConCommand("mingeban bring _" .. ply:EntIndex())
						end):SetIcon("icon16/arrow_in.png")
					end

					menu:AddSpacer()

					if cmds.kick then
						menu:AddOption("Kick", function()
							lply:ConCommand("mingeban kick _" .. ply:EntIndex())
						end):SetIcon("icon16/door_in.png")
					end
				end
			end
		end
		menu:Open()
	end
	function self.Info.Paint(s, w, h)
		local ply = self.Player
		if not IsValid(ply) then
			self.Player = _G.Player(self.UserID)
			if not IsValid(self.Player) then
				self:Remove()
			end
			return
		end

		surface.SetFont(tag .. "Player")
		local txt = ply:Nick()
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(6 + 1, h * 0.5 - txtH * 0.5 + 1)
		surface.SetTextColor(Color(0, 0, 0, 64))
		surface.DrawText(txt)

		surface.SetTextPos(6, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(0, 0, 0, 240))
		surface.DrawText(txt)

		return true
	end
	function self.Info:PaintOver(w, h)
		surface.SetDrawColor(Color(0, 0, 0, 20))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.Info.Ping = vgui.Create("DButton", self.Info)
	self.Info.Ping:Dock(RIGHT)
	self.Info.Ping:SetWide(58)
	self.Info.Ping:SetCursor("arrow")
	self.Info.Ping.Clock = Material("icon16/clock.png")
	self.Info.Ping.Latency = Material("icon16/transmit_blue.png")
	function self.Info.Ping.Paint(s, w, h)
		local ply = self.Player
		if not IsValid(ply) then return end

		local isAFK = ply.IsAFK and ply:IsAFK() or false
		if isAFK then
			surface.SetDrawColor(Color(127, 64, 255, 70))
		else
			surface.SetDrawColor(Color(127, 167, 99, 70))
		end

		surface.DrawRect(0, 0, w, h)

		surface.SetMaterial(isAFK and s.Clock or s.Latency)
		surface.SetDrawColor(Color(255, 255, 255))
		surface.DrawTexturedRect(4, h * 0.5 - 8, 16, 16)

		surface.SetFont("DermaDefault")
		local txt
		if isAFK then
			local AFKTime = math.max(0, CurTime() - ply:AFKTime())
			local h = math.floor(AFKTime / 60 / 60)
			local m = math.floor(AFKTime / 60 - h * 60)
			local s = math.floor(AFKTime - m * 60 - h * 60 * 60)
			txt = string.format("%.2d:%.2d", h > 1 and h or m, h > 1 and m or s)
		else
			txt = ply:Ping()
		end
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(4 + 16 + 4, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(0, 0, 0, 230))
		surface.DrawText(txt)

		return true
	end
end

function Player:RefreshAvatar()
	if not IsValid(self.Player) or not self.Player:SteamID64() then return end

	local w = 32
	if self.Avatar:GetTall() > 32 then w = 64 end
	if self.Avatar:GetTall() > 64 then w = 184 end
	self.Avatar:SetSteamID(self.Player:SteamID64(), w)
end
function Player:SetPlayer(ply)
	self.Player = ply
	self:RefreshAvatar()
end

function Player:PerformLayout()
	self.Avatar:SetWide(self.Avatar:GetTall())
	self:RefreshAvatar()
end

function Player:Paint(w, h)
	local ply = self.Player
	local isAFK = (IsValid(ply) and ply.IsAFK) and ply:IsAFK() or false

	surface.SetDrawColor(isAFK and Color(225, 229, 240, 190) or Color(244, 248, 255, 190))
	surface.DrawRect(0, 0, w, h)

	if self.Info:IsHovered() then
		surface.SetDrawColor(Color(255, 255, 255, self.Info.Depressed and 40 or 90))
		surface.DrawRect(0, 0, w, h)
	end

	return true
end

vgui.Register(tag .. "Player", Player, "EditablePanel")

