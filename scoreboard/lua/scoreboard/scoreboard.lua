
local tag = "ReDreamScoreboard"

if IsValid(Scoreboard) then Scoreboard:Remove() end

scoreboard = {}
local Debug = false

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
surface.CreateFont(tag .. "Option", {
	font = "Roboto Condensed",
	size = 16,
	antialias = true,
})

function scoreboard:GetContentSize()
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

if not istable(GAMEMODE) then
	include("scoreboard/team_panel.lua")
	include("scoreboard/player_panel.lua")
end

local wantsToClose = false
local activeFrame
local function OpenColorSelect()
	if IsValid(activeFrame) then return end

	local frame = vgui.Create("EditablePanel")
	frame:SetSize(250, 175)
	frame:SetPos(ScrW() * 0.5 - frame:GetWide() * 0.5, ScrH() * 0.75 - frame:GetTall() * 0.5)
	frame:DockPadding(6, 6, 6, 6)
	function frame:Paint(w, h)
		local col = Color(77, 81, 96, 192)
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
	self.Teams.GetContentSize = scoreboard.GetContentSize
	self.Teams.pnlCanvas.GetContentSize = scoreboard.GetContentSize
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
			if pnl.Last ~= #team.GetPlayers(id) or pnl.Last ~= #pnl:GetChildren() then
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
			_pnl:SetTall(36)
		end

		for _, _pnl in next, pnl:GetChildren() do
			if _pnl.ClassName == (tag .. "Player") and (not IsValid(_pnl.Player) or _pnl.Player:Team() ~= id) then
				pnl[_pnl.UserID] = nil
				_pnl:SetVisible(false)
				_pnl:SetParent() -- ugly hack to call PerformLayout
				_pnl:Remove()
			end
		end

		pnl.Last = #pnl:GetChildren()

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

