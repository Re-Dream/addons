
local tag = "nicks"

local PLAYER = FindMetaTable("Player")

PLAYER.SteamNick   = PLAYER.SteamNick or PLAYER.Nick
PLAYER.SteamName   = PLAYER.SteamNick or PLAYER.Nick
PLAYER.RealName    = PLAYER.SteamNick or PLAYER.Nick
PLAYER.RealNick    = PLAYER.SteamNick or PLAYER.Nick
PLAYER.GetRealName = PLAYER.SteamNick or PLAYER.Nick
PLAYER.GetRealNick = PLAYER.SteamNick or PLAYER.Nick

function PLAYER:Nick()
	local nick = self:GetNWString("Nick")
	return nick:Trim() == "" and self:RealName() or nick
end
PLAYER.Name = PLAYER.Nick
PLAYER.GetNick = PLAYER.Nick
PLAYER.GetName = PLAYER.Nick

if CLIENT then
	function PLAYER:SetNick(nick)
		net.Start(tag)
			net.WriteString(nick)
		net.SendToServer()
	end
else
	util.AddNetworkString(tag)

	function PLAYER:SetNick(nick)
		self:SetPData("Nick", nick)
		self:SetNWString("Nick", nick)
	end

	local nextChange = {}
	local nick = mingeban.CreateCommand({"name", "nick"}, function(caller, line)
		local cd = nextChange[caller:UserID()]
		if cd and cd > CurTime() then
			return false, "You're changing nicks too quickly!"
		end

		caller:SetNick(line)
		nextChange[caller:UserID()] = CurTime() + 2
	end)

	hook.Add("PlayerInitialSpawn", tag, function(caller)
		caller:SetNick(caller:GetPData("Nick"))
	end)

	net.Receive(tag, function(caller)
		local nick = net.ReadString()
		mingeban.RunCommand("nick", caller, nick)
	end)
end


