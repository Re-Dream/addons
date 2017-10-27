
local tag = "playtime"

local PLAYER = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString(tag)

	function PLAYER:GetPlaytime()
		return self.Playtime
	end
	function PLAYER:LoadPlaytime()
		if not self:GetPData(tag) then
			self:SetPData(tag, "0")
		end
		local playtime = tonumber(self:GetPData(tag))
		self:SetNWFloat(tag, playtime)
		self.Playtime = playtime
	end
	function PLAYER:SavePlaytime()
		self:SetPData(tag, self.Playtime)
	end
	timer.Create(tag, 1, 0, function()
		for _, ply in next, player.GetAll() do
			local addTime = ply:TimeConnected() - (ply.LastPlaytimeUpdate or 0)
			ply.Playtime = ply.Playtime and ply.Playtime + addTime or 0
			ply:SetNWFloat(tag, ply.Playtime)

			ply.LastPlaytimeUpdate = ply:TimeConnected()
		end
	end)
	timer.Create(tag .. "_saving", 60, 0, function()
		for _, ply in next, player.GetAll() do
			ply:SavePlaytime()
		end
	end)
	hook.Add("PlayerInitialSpawn", tag, function(ply)
		ply:LoadPlaytime()
	end)
	hook.Add("PlayerDisconnected", tag, function(ply)
		ply:SavePlaytime()
	end)
	hook.Add("ShutDown", tag, function()
		for _, ply in next, player.GetAll() do
			ply:SavePlaytime()
		end
	end)
	if istable(GAMEMODE) then
		for _, ply in next, player.GetAll() do
			ply:LoadPlaytime()
		end
	end
end

if CLIENT then
	function PLAYER:GetPlaytime()
		return self:GetNWFloat(tag)
	end
end

