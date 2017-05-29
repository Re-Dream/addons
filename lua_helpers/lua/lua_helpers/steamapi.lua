
if CLIENT then return end

if not file.Exists("cfg/apikey.cfg", "GAME") or file.Read("cfg/apikey.cfg", "GAME") == nil then
	print("Error! SteamAPI library wasn't provided with any auth key!")
	return
end
local authkey = file.Read("cfg/apikey.cfg", "GAME"):Trim()
local apiList
if not file.Exists("steamapi_list.txt", "DATA") then
	http.Fetch("http://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key=" .. authkey, function(content)
		if content and content ~= "" then
			local list = util.JSONToTable(content)
			local api = {}
			for k, interface in next, list.apilist.interfaces do
				api[interface.name] = {}
				for k, method in next, interface.methods do
					api[interface.name][method.name] = {}
					api[interface.name][method.name][method.version] = method
				end
			end
			-- PrintTable(api)
			file.Write("steamapi_list.txt", util.TableToJSON(api))
			apiList = api
		end
	end)
else
	apiList = util.JSONToTable(file.Read("steamapi_list.txt", "DATA") or "{}")
end

local requesting = false
steamapi = setmetatable({}, {
	__call = function(self, api, method, v, args, callback)
		if requesting then
			-- print("Don't try to DDoS the SteamAPI!")
			return
		end
		if not apiList[api] then
			Msg("[SteamAPI] ") print("Invalid API! (" .. api .. ")")
			return
		end
		if not apiList[api][method] then
			Msg("[SteamAPI] ") print("Invalid method! (" .. api .. "." .. method .. ")")
			return
		end
		if not apiList[api][method][v] then
			Msg("[SteamAPI] ") print("Invalid version! (" .. api .. "." .. method .. "." .. v .. ")")
			return
		end
		local url = "http://api.steampowered.com/" .. api .. "/" .. method .. "/v000" .. tostring(v) .. "/?key=" .. authkey
		for k, v in next, args do
			url = url .. "&" .. k .. "=" .. v
		end

		local response = {}
		requesting = true
		http.Fetch(url, function(content, ...)
			if content and content:Trim() ~= "" then
				response = util.JSONToTable(content)
				requesting = false
				callback(response, {url, content, ...})
			end
		end, function(err)
			ErrorNoHalt("SteamAPI http.Fetch Error: " .. err)
		end)
		return response
	end
})
steamapi.List = apiList

function steamapi.GetFriendList(ply)
	steamapi("ISteamUser", "GetFriendList", 1, {
		steamid = (isentity(ply) and ply:IsPlayer()) and ply:SteamID64() or ply,
		relationship = "friend"
	}, function(response, other)
		-- PrintTable(other)

		if not response.friendslist or not response.friendslist.friends then
			-- private profile or some shit
			return
		end
		if isentity(ply) and ply:IsPlayer() and (not ply.FriendsList or table.Count(ply.FriendsList) ~= #response.friendslist.friends) then
			ply.FriendsList = {}
			for k, info in next, response.friendslist.friends do
				ply.FriendsList[info.steamid] = true
			end
			ply.LastFriendListUpdate = CurTime() + 60
		end
	end)
end

function steamapi.GetFamilySharing(ply)
	steamapi("IPlayerService", "IsPlayingSharedGame", 1, {
		steamid = (isentity(ply) and ply:IsPlayer()) and ply:SteamID64() or ply,
		appid_playing = 4000
	},	function(response, other)
		-- PrintTable(other)

		local response = response.response
		if not response or not response.lender_steamid then
			ErrorNoHalt(string.format("SteamAPI FamilySharing: Invalid response for %s (%s)\n", ply:Nick(), ply:SteamID()))
			return
		end

		local lender = response.lender_steamid
		if lender ~= "0" then
			ply.Lender = util.SteamIDFrom64(lender)
		else
			ply.Lender = false
		end
	end)
end

local PLAYER = FindMetaTable("Player")

timer.Create("steamapi_RefreshFriendLists", 60, 0, function()
	for k, ply in next, player.GetAll() do
		if not ply.LastFriendListUpdate or ply.LastFriendListUpdate < CurTime() then
			steamapi.GetFriendList(ply)
		end
	end
end)

function PLAYER:GetFriends()
	if not self.FriendsList then
		steamapi.GetFriendList(self)
	end
	return self.FriendsList or {}
end

function PLAYER:GetOnlineFriends()
	local tbl = {}
	for sid, _ in next, self:GetFriends() do
		local ply = player.GetBySteamID64(sid)
		if IsValid(ply) then
			tbl[#tbl + 1] = ply
		end
	end
	return tbl
end

function PLAYER:IsFriend(ply)
	if (not self.FriendsList or not self.FriendsList[ply:SteamID64()]) and (not ply.LastFriendListUpdate or ply.LastFriendListUpdate < CurTime()) then
		steamapi.GetFriendList(self)
		return false
	end
	return self.FriendsList and self.FriendsList[ply:SteamID64()] or false
end

function PLAYER:GetLender()
	if self.Lender == nil then
		steamapi.GetFamilySharing(self)
	end
	return self.Lender
end

function PLAYER:IsFamilySharing()
	if not self.Lender then
		steamapi.GetFamilySharing(self)
	end
	return self.Lender and true or false
end

