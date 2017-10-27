
local tag = "ReDreamScoreboard"

surface.CreateFont(tag .. "Player", {
	font = "Roboto Medium",
	size = 20,
	antialias = true,
})

local Player = {}

local avatars = {}
local hovered
local function GetAvatar(sid)
	if not avatars[sid] then
		local a = vgui.Create("AvatarImage", vgui.GetWorldPanel())
		a.Avatar = true
		a:SetSteamID(sid, 184)
		a:SetSize(184, 184)
		a:ParentToHUD()
		a.Alpha = 0
		a:SetAlpha(a.Alpha)
		function a:Think()
			self.Alpha = math.Clamp(self.Alpha + (FrameTime() * 2000) * (self.Hide and -1 or 1), 0, 255)
			self:SetAlpha(self.Alpha)
			if not IsValid(hovered) then
				self.Hide = true
			end
		end
		avatars[sid] = a
	end
	return avatars[sid]
end

hook.Add("PostRenderVGUI", tag .. "Player", function()
	if IsValid(hovered) then
		local avatar = GetAvatar(hovered.Player:SteamID64())
		avatar.Hide = false
		local x, y = hovered:LocalToScreen(0, 0)
		avatar:SetPos(x - avatar:GetWide(), y - avatar:GetTall() * 0.5 + hovered:GetTall() * 0.5)
		avatar:SetPaintedManually(true)
		avatar:PaintManual()
		avatar:SetPaintedManually(false)
	end
	hovered = nil
end)

function Player:Init()
	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:Dock(LEFT)

	self.Avatar.Click = vgui.Create("DButton", self.Avatar)
	self.Avatar.Click:Dock(FILL)
	function self.Avatar.Click.Paint(s, w, h)
		if s:IsHovered() then
			hovered = self
		end

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
	self.Info.Ping:SetTooltip("Ping / AFK Time")
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
			local m = math.floor(AFKTime / 60 % 60)
			local s = math.floor(AFKTime % 60)
			txt = string.format("%d:%.2d", h >= 1 and h or m, h >= 1 and m or s)
		else
			txt = ply:Ping()
		end
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(4 + 16 + 4, h * 0.5 - txtH * 0.5)
		surface.SetTextColor(Color(0, 0, 0, 230))
		surface.DrawText(txt)

		return true
	end

	if LocalPlayer().GetPlaytime then
		self.Info.Playtime = vgui.Create("DButton", self.Info)
		self.Info.Playtime:Dock(RIGHT)
		self.Info.Playtime:SetWide(46)
		self.Info.Playtime:SetCursor("arrow")
		self.Info.Playtime:SetTooltip("Playtime")
		function self.Info.Playtime.Paint(s, w, h)
			local ply = self.Player
			if not IsValid(ply) then return end

			surface.SetFont("DermaDefault")
			local playtime = ply:GetPlaytime()
			local _h = math.floor(playtime / 60 / 60)
			local _m = math.floor(playtime / 60 % 60)
			local _s = math.floor(playtime % 60)
			local txt
			if _h < 1 then
				txt = string.format("%d m", _m, _s)
			elseif _h < 10 then
				txt = string.format("%d:%.2d h", _h, _m)
			else
				txt = string.format("%d h", _h, _m)
			end
			local txtW, txtH = surface.GetTextSize(txt)
			surface.SetTextPos(w * 0.5 - txtW * 0.5, h * 0.5 - txtH * 0.5)
			surface.SetTextColor(Color(0, 0, 0, 230))
			surface.DrawText(txt)

			return true
		end
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

Player.Friend = Material("icon16/user_green.png")
Player.Self = Material("icon16/user.png")
Player.Shield = Material("icon16/shield.png")
Player.Typing = Material("icon16/comments.png")
Player.Wrench = Material("icon16/wrench.png")
Player.NoClip = Material("icon16/collision_off.png")
local building = {
	weapon_physgun = true,
	gmod_tool = true,
}
Player.Tags = {
	Admin = {
		display = function(ply)
			if ply:IsAdmin() then
				return "admin", Player.Shield
			end
		end
	},
	Typing = {
		display = function(ply)
			if ply:IsTyping() then
				return "typing", Player.Typing
			end
		end
	},
	Building = {
		display = function(ply)
			if IsValid(ply:GetActiveWeapon()) and building[ply:GetActiveWeapon():GetClass()] then
				return "building", Player.Wrench
			end
		end
	},
	NoClip = {
		display = function(ply)
			if ply:GetMoveType() == MOVETYPE_NOCLIP then
				return "noclip", Player.NoClip
			end
		end
	},
}
function Player:Paint(w, h)
	local lply = LocalPlayer()
	local ply = self.Player
	if not IsValid(ply) then return true end
	local hovered = self.Info:IsHovered() or self.Info:IsChildHovered()

	local isAFK = (IsValid(ply) and ply.IsAFK) and ply:IsAFK() or false

	surface.SetDrawColor(isAFK and Color(225, 229, 240, 190) or Color(244, 248, 255, 190))
	surface.DrawRect(0, 0, w, h)

	if hovered then
		surface.SetDrawColor(Color(255, 255, 255, self.Info.Depressed and 40 or 90))
		surface.DrawRect(0, 0, w, h)
	end

	local infoW = 0
	for _, pnl in next, self.Info:GetChildren() do
		infoW = infoW + pnl:GetWide()
	end
	local x = w - infoW - 4
	for _, tag in next, self.Tags do
		local text, icon = tag.display(ply)
		if text and icon then
			if hovered then
				surface.SetFont("DermaDefault")
				local txtW, txtH = surface.GetTextSize(text)
				x = x - txtW
				surface.SetTextColor(Color(0, 0, 0, 192))
				surface.SetTextPos(x, h * 0.5 - txtH * 0.5)
				surface.DrawText(text)
				x = x - 4
			end

			x = x - 16
			surface.SetDrawColor(Color(255, 255, 255, 192))
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(x, h * 0.5 - 8, 16, 16)

			x = x - 4
		end
	end

	if (lply ~= ply and ply:IsFriend()) or lply == ply then
		DisableClipping(true)
			surface.SetDrawColor(Color(255, 255, 255, 127))
			surface.SetMaterial(lply == ply and self.Self or self.Friend)
			surface.DrawTexturedRect(-16 - 4, h * 0.5 - 8, 16, 16)
		DisableClipping(false)
	end

	return true
end

vgui.Register(tag .. "Player", Player, "EditablePanel")

