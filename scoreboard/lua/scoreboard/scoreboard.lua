
local tag = "ReDreamScoreboard"

if IsValid(Scoreboard) then Scoreboard:Remove() end

local Debug = false

local function GetContentSize(self)
	local w, h = 0, 0

	local padding = { self:GetDockPadding() }
	w = w + padding[1] + padding[3]
	h = h + padding[2] + padding[4]

	for _, pnl in next, self:GetChildren() do
		if pnl:IsVisible() then
			w = w + pnl:GetWide()
			h = h + pnl:GetTall()

			local margin = { pnl:GetDockMargin() }
			w = w + margin[1] + margin[3]
			h = h + margin[2] + margin[4]
		end
	end

	return w, h
end

local hostnameFont = {
	font = "Roboto",
	size = ScreenScale(12.5),
	weight = 550,
	antialias = true,
}
surface.CreateFont(tag .. "HostnameSmall", hostnameFont)
hostnameFont.size = ScreenScale(16)
surface.CreateFont(tag .. "HostnameBig", hostnameFont)

surface.CreateFont(tag .. "Team", {
	font = "Roboto",
	size = 18,
	weight = 550,
	antialias = true,
})
surface.CreateFont(tag .. "Player", {
	font = "Roboto",
	size = 20,
	weight = 550,
	antialias = true,
})

-- Team panel start!

local Team = {}

function Team:SetTeam(t) self.Team = t end
function Team:GetTeam() return self.Team end

function Team:SetLone(b)
	self.Lone = b
	self:DockPadding(0, self:GetLone() and 0 or 24 + 1, 0, 0)
	self:GetParent():InvalidateLayout()
	self:InvalidateLayout()
end
function Team:GetLone() return self.Lone end

function Team:PerformLayout()
	self:SizeToContentsY()
end

function Team:Paint(w, h)
	if not self:GetLone() then
		local t = self:GetTeam()
		local tCol = team.GetColor(t)
		tCol.a = 192
		draw.RoundedBox(6, 0, 0, w, 24, tCol)

		surface.SetFont(tag .. "Team")
		local txt = team.GetName(t) .. " (" .. #self:GetChildren() .. ")"
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(6 + 1, 24 * 0.5 - txtH * 0.5 + 1)
		surface.SetTextColor(Color(0, 0, 0, 192))
		surface.DrawText(txt)

		surface.SetTextPos(6, 24 * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(255, 255, 255))
		surface.DrawText(txt)
	end
end
if Debug then
	function Team:PaintOver(w, h)
		surface.SetDrawColor(Color(255, 255, 0))
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end
Team.GetContentSize = GetContentSize

vgui.Register(tag .. "Team", Team, "EditablePanel")

-- Team panel end
-- Player panel start!

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

-- Player panel end

scoreboard = {}

scoreboard.GetContentSize = GetContentSize

local Options = {
	Center = {
		icon = Material("icon16/arrow_in.png"),
		callback = function(self, option)
			self.Config.Center = not self.Config.Center
			self:SaveConfig()
			self:InvalidateLayout()
		end,
		name = "Toggle Center",
		type = "boolean",
		w = 112
	}
}
local totype = {
	boolean = tobool,
	number = tonumber,
}

function scoreboard:LoadConfig()
	self.Config = {}
	local config = util.JSONToTable(file.Read(tag:lower() .. "_config.txt", "DATA") or "{}")
	if not config then return end

	for k, v in next, config do
		if Options[k] then
			self.Config[k] = Options[k].type and totype[Options[k].type](v) or v
		end
	end
end
function scoreboard:SaveConfig()
	file.Write(tag:lower() .. "_config.txt", util.TableToJSON(self.Config))
end

local maxH = ScrH() * 0.9
function scoreboard:Init()
	self:SetSize(ScrW() * 0.375, maxH)

	self.Header = vgui.Create("DButton", self)
	self.Header:Dock(TOP)
	self.Header:SetTall(64)
	self.Header:InvalidateLayout(true)
	self.Header.lastTxt = ""
	self.Header.fontSize = ""
	function self.Header:DoClick()
		self.Expanded = not self.Expanded
		self:SizeTo(self:GetWide(), self.Expanded and 112 or 64, 0.3)
	end
	function self.Header:PerformLayout()
		self.Options:SetSize(self:GetWide(), 112 - 64)
	end
	function self.Header:Paint(w, h)
		surface.SetDrawColor(Color(77, 81, 96, 230))
		surface.DrawRect(0, 0, w, h)

		local txt = GetHostName()

		if txt ~= self.lastTxt then
			self.lastTxt  = txt
			self.fontSize = nil
		end
		if self.fontSize == nil then
			surface.SetFont(tag .. "HostnameBig")
			local _txtW = surface.GetTextSize(txt)
			if _txtW >= w - 32 then
				self.fontSize = true
			else
				self.fontSize = false
			end
		end
		if self.fontSize == true then
			surface.SetFont(tag .. "HostnameSmall")
		else
			surface.SetFont(tag .. "HostnameBig")
		end

		local txtW, txtH = surface.GetTextSize(txt)

		local space = 3
		surface.SetTextPos(w * 0.5 - txtW * 0.5 + space, 32 - txtH * 0.5 + space)
		surface.SetTextColor(Color(0, 0, 0, 164))
		surface.DrawText(txt)

		surface.SetTextPos(w * 0.5 - txtW * 0.5, 32 - txtH * 0.5)
		surface.SetTextColor(Color(255, 255, 255, 255))
		surface.DrawText(txt)

		surface.SetDrawColor(Color(255, 255, 255, 40))
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 15))
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

		if self:IsHovered() then
			surface.SetDrawColor(Color(255, 255, 255, self.Depressed and 5 or 10))
			surface.DrawRect(0, 0, w, h)
		end

		return true
	end
	self.Header.Options = vgui.Create("EditablePanel", self.Header)
	self.Header.Options:SetPos(0, 64)
	self.Header.Options:DockPadding(8, 8, 8, 8)
	function self.Header.Options:Paint(w, h)
		surface.SetDrawColor(Color(0, 0, 0, 90))
		surface.DrawRect(0, 0, w, h)
	end
	for name, info in next, Options do
		self.Header.Options[name] = vgui.Create("DButton", self.Header.Options)
		local option = self.Header.Options[name]
		option:Dock(LEFT)
		option:DockMargin(0, 0, 0, 2)
		option:SetWide(info.w or 64)
		function option:Paint(w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 96))

			surface.SetMaterial(info.icon)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(8, h * 0.5 - 8, 16, 16)

			local txt = info.name
			surface.SetFont("DermaDefault")
			local txtW, txtH = surface.GetTextSize(txt)
			surface.SetTextPos((w + 8 + 16) * 0.5 - txtW * 0.5, h * 0.5 - txtH * 0.5)
			surface.SetTextColor(Color(255, 255, 255, 192))
			surface.DrawText(txt)

			if self:IsHovered() then
				draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, self.Depressed and 5 or 10))
			end

			return true
		end
		function option.DoClick(s)
			info.callback(self, s)
		end
	end

	self.Teams = vgui.Create("PanelList", self)
	self.Teams:Dock(TOP)
	self.Teams:EnableVerticalScrollbar(true)
	self.Teams:DockMargin(4, 0, 4, 0)
	self.Teams:SetSpacing(0)
	self.Teams:SetPadding(0)
	self.Teams.GetContentSize = GetContentSize
	self.Teams.pnlCanvas.GetContentSize = GetContentSize
	self.Teams._PerformLayout = self.Teams.PerformLayout
	function self.Teams.PerformLayout(s)
		s:_PerformLayout()

		local h = ({s.pnlCanvas:GetContentSize()})[2]
		s.pnlCanvas:SetTall(h)
		h = h > maxH and maxH - self.Header:GetTall() or h
		s:SetTall(h)
	end
	function self.Teams:OnMouseWheeled(d)
		if IsValid(self.VBar) and self.VBar.Enabled then
			return self.VBar:AddVelocity(d)
		end
	end
	function self.Teams:Paint()
		return true
	end
	if Debug then
		self.Teams.isTeam = true
		function self.Teams:PaintOver(w, h)
			surface.SetDrawColor(Color(0, 255, 0))
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	self:MakePopup()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	self:SetAlpha(255)

	self:LoadConfig()
	self:InvalidateLayout()
end

function scoreboard:HandlePlayers()
	local i = 0
	local setLone = false
	for id, info in next, team.GetAllTeams() do
		local pnl = self.Teams[id]
		if not pnl or pnl.Last ~= #team.GetPlayers(id) then
			setLone = true
			self:RefreshPlayers(id)
		end
		if setLone and pnl and pnl:IsVisible() then
			i = i + 1
		end
	end
	if setLone then
		for id, info in next, team.GetAllTeams() do
			local pnl = self.Teams[id]
			if pnl and pnl:IsVisible() then
				pnl:SetLone(i < 2)
			end
		end
	end
end

function scoreboard:RefreshPlayers(id)
	if id then
		local pnl = self.Teams[id]
		if not pnl then
			pnl = vgui.Create(tag .. "Team")
			self.Teams:AddItem(pnl)
			pnl:SetTeam(id)
			pnl:Dock(TOP)
			pnl:DockMargin(0, 4, 0, 0)
			self.Teams[id] = pnl
		end

		if #team.GetPlayers(id) < 1 then
			pnl:SetVisible(false)
		else
			pnl:SetVisible(true)
			for _, _pnl in next, pnl:GetChildren() do
				if not IsValid(_pnl.Player) or _pnl.Player:Team() ~= id then
					pnl[_pnl.UserID] = nil
					_pnl:SetVisible(false)
					_pnl:SetParent() -- ugly hack to call PerformLayout
					_pnl:Remove()
				end
			end
		end
		local dead = 0
		if pnl:IsVisible() then
			for _, ply in next, team.GetPlayers(id) do
				if IsValid(ply) then
					local _pnl = pnl[ply:UserID()]
					if not _pnl then
						_pnl = vgui.Create(tag .. "Player", pnl)
						_pnl.UserID = ply:UserID()
						_pnl:SetPlayer(ply)
						pnl[ply:UserID()] = _pnl
					end
					_pnl:Dock(TOP)
					_pnl:DockMargin(8, 0, 8, 0)
					_pnl:SetTall(30)
				else
					dead = dead + 1
				end
			end
		end

		if pnl._first then
			pnl.Last = #team.GetPlayers(id) - dead
		else
			pnl._first = true
		end
	end
end

function scoreboard:Think()
	if not self.Popup and input.IsMouseDown(MOUSE_RIGHT) then
		self:SetMouseInputEnabled(true)
		self.Popup = true
	end

	self:HandlePlayers()
end

function scoreboard:Show()
	self:SetVisible(true)
end
function scoreboard:Hide()
	CloseDermaMenus()
	self:SetVisible(false)
	if self.Popup then
		self:SetMouseInputEnabled(false)
		self.Popup = false
	end
end
function scoreboard:PerformLayout()
	self:SizeToContentsY()
	if self:GetTall() > maxH then
		self:SetTall(maxH)
	end
	if self.Config.Center then
		self:Center()
	else
		local y = ScrH() * 0.2 - (ScrH() * 0.1 * (self:GetTall() / maxH))
		self:SetPos(ScrW() * 0.5 - self:GetWide() * 0.5, y)
	end
end

if Debug then
	function scoreboard:Paint(w, h)
		surface.SetDrawColor(Color(255, 0, 0))
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

vgui.Register(tag, scoreboard, "EditablePanel")

local redream_scoreboard_enable = CreateClientConVar("redream_scoreboard_enable", "1")

hook.Add("ScoreboardShow", tag, function()
	if not redream_scoreboard_enable:GetBool() then return end

	if not IsValid(Scoreboard) then
		Scoreboard = vgui.Create(tag)
	end
	Scoreboard:Show()

	return true
end)

hook.Add("ScoreboardHide", tag, function()
	if not redream_scoreboard_enable:GetBool() then return end

	if not IsValid(Scoreboard) then
		Scoreboard = vgui.Create(tag)
	end
	Scoreboard:Hide()

	return true
end)

