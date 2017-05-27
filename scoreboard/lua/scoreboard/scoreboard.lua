
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
	font = "Roboto Bold",
	size = ScreenScale(8),
	antialias = true,
}
surface.CreateFont(tag .. "HostnameSmaller", hostnameFont)
hostnameFont.size = ScreenScale(12)
surface.CreateFont(tag .. "HostnameSmall", hostnameFont)
hostnameFont.size = ScreenScale(16)
surface.CreateFont(tag .. "HostnameBig", hostnameFont)

surface.CreateFont(tag .. "Team", {
	font = "Roboto",
	size = 19,
	antialias = true,
})
surface.CreateFont(tag .. "Player", {
	font = "Roboto Medium",
	size = 20,
	antialias = true,
})
surface.CreateFont(tag .. "Option", {
	font = "Roboto Condensed",
	size = 16,
	antialias = true,
})

-- Team panel start!

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
Team.GetContentSize = GetContentSize

vgui.Register(tag .. "Team", Team, "DButton")

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

local wantsToClose = false
local activeFrame
local function OpenColorSelect()
	if IsValid(activeFrame) then return end

	local frame = vgui.Create("EditablePanel")
	frame:SetSize(250, 175)
	frame:SetPos(ScrW() * 0.5 - frame:GetWide() * 0.5, ScrH() * 0.75 - frame:GetTall() * 0.5)
	frame:DockPadding(6, 6, 6, 6)
	function frame:Paint(w, h)
		local col = Color(77, 81, 96)
		col.a = 245
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(0, 0, 0, 80))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local top = frame:Add("EditablePanel")
	top:Dock(TOP)
	top:SetTall(20)
	top:DockMargin(0, 0, 0, 4)
	function top:Paint(w, h)
		surface.SetFont(tag .. "Option")
		local txt = "Header Color Selection"
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(2, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(255, 255, 255))
		surface.DrawText(txt)
	end

	local close = top:Add("DButton")
	close:Dock(RIGHT)
	close:SetWide(20)
	close:DockMargin(4, 0, 0, 0)
	function close:Paint(w, h)
		surface.SetDrawColor(Color(255, 96, 96, 192))
		surface.DrawRect(0, 0, w, h)

		surface.SetFont("marlett")
		local txt = "r"
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(w * 0.5 - txtW * 0.5, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(0, 0, 0))
		surface.DrawText(txt)

		surface.SetDrawColor(Color(255, 255, 255, 20))
		surface.DrawOutlinedRect(0, 0, w, h)

		return true
	end
	function close:DoClick()
		activeFrame:Remove()
		if wantsToClose then
			Scoreboard:Hide()
		end
	end

	local reset = top:Add("DButton")
	reset:Dock(RIGHT)
	reset:SetWide(38)
	function reset:Paint(w, h)
		surface.SetDrawColor(Color(255, 96, 96, 192))
		surface.DrawRect(0, 0, w, h)

		surface.SetFont(tag .. "Option")
		local txt = "Reset"
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(w * 0.5 - txtW * 0.5, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(0, 0, 0))
		surface.DrawText(txt)

		surface.SetDrawColor(Color(255, 255, 255, 20))
		surface.DrawOutlinedRect(0, 0, w, h)

		return true
	end
	function reset:DoClick()
		Scoreboard.Config.Color = nil
		Scoreboard:SaveConfig()
	end

	local mixer = frame:Add("DColorMixer")
	mixer:Dock(FILL)
	mixer:SetAlphaBar(false)
	mixer:SetPalette(false)
	local last = RealTime()
	local changed = true
	function mixer:ValueChanged(col)
		last = RealTime() + 0.1
		changed = false
	end

	function frame:Think()
		if last < RealTime() and not changed then
			Scoreboard.Config.Color = mixer:GetColor()
			Scoreboard:SaveConfig()
			changed = true
		end
	end

	frame:MakePopup()

	activeFrame = frame
end

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
	},
	Color = {
		icon = Material("icon16/palette.png"),
		callback = function(self, option)
			OpenColorSelect()
		end,
		name = "Change Header Color",
		type = "table",
		w = 144
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
			local convert = totype[Options[k].type]
			self.Config[k] = (Options[k].type and convert) and convert(v) or v
		end
	end
end
function scoreboard:SaveConfig()
	file.Write(tag:lower() .. "_config.txt", util.TableToJSON(self.Config))
end

local maxH = ScrH() * 0.9
function scoreboard:Init()
	local scoreboard = self

	self:SetSize(ScrW() * 0.375, maxH)

	self.Header = vgui.Create("DButton", self)
	self.Header:Dock(TOP)
	self.Header:SetTall(64)
	self.Header:InvalidateLayout(true)
	self.Header.lastTxt = ""
	function self.Header:DoClick()
		self.Expanded = not self.Expanded
		self:SizeTo(self:GetWide(), self.Expanded and 112 or 64, 0.3)
	end
	function self.Header:PerformLayout()
		self.Options:SetSize(self:GetWide(), 112 - 64)
	end
	function self.Header:Paint(w, h)
		local col = scoreboard.Config.Color or Color(77, 81, 96)
		col.a = 230
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, w, h)

		local txt = GetHostName()

		if txt ~= self.lastTxt then
			self.lastTxt  = txt
		end

		surface.SetFont(tag .. "HostnameBig")
		local _txtW = surface.GetTextSize(txt)
		if _txtW >= w - 32 then
			surface.SetFont(tag .. "HostnameSmall")
			local _txtW = surface.GetTextSize(txt)
			if _txtW >= w - 32 then
				surface.SetFont(tag .. "HostnameSmaller")
			end
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
		option:DockMargin(0, 0, 4, 0)
		option:SetWide(info.w or 64)
		function option:Paint(w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 96))

			surface.SetMaterial(info.icon)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(8, h * 0.5 - 8, 16, 16)

			local txt = info.name
			surface.SetFont(tag .. "Option")
			local txtW, txtH = surface.GetTextSize(txt)
			surface.SetTextPos((w + 8 + 16) * 0.5 - txtW * 0.5 + 2, h * 0.5 - txtH * 0.5 + 2)
			surface.SetTextColor(Color(0, 0, 0, 164))
			surface.DrawText(txt)

			surface.SetTextPos((w + 8 + 16) * 0.5 - txtW * 0.5, h * 0.5 - txtH * 0.5)
			surface.SetTextColor(Color(255, 255, 255, 192))
			surface.DrawText(txt)

			if self:IsHovered() then
				draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, self.Depressed and 2 or 4))
			end

			return true
		end
		function option:DoClick()
			info.callback(scoreboard, self)
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
	function self.Teams:PerformLayout()
		self:_PerformLayout()

		local h = ({self.pnlCanvas:GetContentSize()})[2]
		self.pnlCanvas:SetTall(h)
		h = h > maxH and maxH - scoreboard.Header:GetTall() or h
		self:SetTall(h)
	end
	function self.Teams:OnMouseWheeled(d)
		if IsValid(self.VBar) and self.VBar.Enabled then
			return self.VBar:AddVelocity(d)
		end
	end
	function self.Teams:Paint()
		return true
	end
	function self.Teams:GetTeams()
		local teams = {}
		for k, v in next, self:GetTable() do
			if isnumber(k) then
				teams[k] = v
			end
		end
		return teams
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

player.GetCount = player.GetCount or function()
	return #player.GetAll()
end
function scoreboard:HandlePlayers()
	local done = {}
	for _, ply in next, player.GetAll() do
		local id = ply:Team()
		local pnl = self.Teams[id]
		if (not self.Last or self.Last ~= player.GetCount()) and not done[id] then
			self:RefreshPlayers(id)
			done[id] = true
		end
	end
	self.Last = player.GetCount()
	local i = 0
	for id, pnl in next, self.Teams:GetTeams() do
		if IsValid(pnl) and pnl:IsVisible() then -- #team.GetPlayers(id) > 0 then
			if pnl.Last ~= #team.GetPlayers(id) then
				self:RefreshPlayers(id)
			end
			i = i + 1
		end
	end
	for id, pnl in next, self.Teams:GetTeams() do
		if pnl and pnl:IsVisible() then
			pnl:SetLone(i < 2)
		end
	end
end

function scoreboard:RefreshPlayers(id)
	if id then
		local pnl = self.Teams[id]
		if not pnl then
			pnl = vgui.Create(tag .. "Team")
			self.Teams:AddItem(pnl)
			pnl.Team = id
			pnl:SetTeam(id)
			pnl:SetZPos(-id)
			pnl:Dock(TOP)
			pnl:DockMargin(0, 2, 0, 0)
			self.Teams[id] = pnl
		end

		for _, ply in next, team.GetPlayers(id) do
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
		end
		pnl.Last = #team.GetPlayers(id)

		for _, _pnl in next, pnl:GetChildren() do
			if not IsValid(_pnl.Player) or _pnl.Player:Team() ~= id then
				pnl[_pnl.UserID] = nil
				_pnl:SetVisible(false)
				_pnl:SetParent() -- ugly hack to call PerformLayout
				_pnl:Remove()
			end
		end

		if #pnl:GetChildren() < 1 then
			pnl:SetVisible(false)
		else
			pnl:SetVisible(true)
		end
	end
end

function scoreboard:Think()
	self:HandlePlayers()
end

function scoreboard:Show()
	wantsToClose = false
	self:SetVisible(true)
end
function scoreboard:Hide()
	wantsToClose = true
	if IsValid(activeFrame) then return end
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

hook.Add("PlayerBindPress", tag, function(ply, bind, pressed)
	if not redream_scoreboard_enable:GetBool() then return end
	if not IsValid(Scoreboard) then return end

	if bind:lower():match("+attack2") and pressed and Scoreboard:IsVisible() and not Scoreboard.Popup then
		Scoreboard:SetMouseInputEnabled(true)
		Scoreboard.Popup = true
		return true
	end
end)

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

