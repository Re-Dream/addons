local tag = "joinleave"

if SERVER then
	util.AddNetworkString(tag)

	local geoip
	pcall(function() geoip = requirex("geoip") end)

	local function JoinMessage(name, steamid, entid)
		local info = {}
		info.name = name
		info.steamid = steamid
		info.index = entid
		net.Start(tag)
			net.WriteTable(info)
		net.Broadcast()
	end

	local function LeaveMessage(name, steamid, reason)
		local info = {}
		info.name = name
		info.steamid = steamid
		info.reason = reason
		net.Start(tag)
			net.WriteTable(info)
		net.Broadcast()
	end

	gameevent.Listen("player_connect")
	hook.Add("player_connect", tag, function(data)
		local name = data.name
		local ip = data.address
		local steamid = data.networkid
		local entid = data.index
		if geoip then
			local geoipres = geoip.Get(ip:Split(":")[1])
			local geoipinfo = { geoipres.country_name,geoipres.city,geoipres.asn }

			MsgC(Color(0, 255, 0),"[Join] ") print(name .. " (" .. steamid .. ") is connecting to the server! [" .. ip .. (steamid ~= "BOT" and table.Count(geoipinfo) ~= 0 and " | " .. table.concat(geoipinfo, ", ") .. "]" or "]"))
		else
			MsgC(Color(0, 255, 0),"[Join] ") print(name .. " (" .. steamid .. ") is connecting to the server! [" .. ip .. "]")
		end

		JoinMessage(name, steamid, entid)
	end)

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", tag, function(data)
		local name = data.name
		local steamid = data.networkid
		local reason = data.reason

		LeaveMessage(name, steamid, reason)
	end)

	hook.Add("Initialize", tag, function()
		function GAMEMODE:PlayerConnect() end
		function GAMEMODE:PlayerDisconnected() end
	end)
end

if CLIENT then
	local bullet = "●"
	net.Receive(tag, function()
		local info = net.ReadTable()

		if not info.reason then
			local tcol = team.GetColor(1001)
			chat.AddText(Color(127, 255, 127), bullet, " ", tcol, info.name, Color(127, 127, 127), " (" .. info.steamid .. ") ", Color(210, 210, 225), "is ", Color(127, 255, 127), "joining", Color(210, 210, 225), " the server!")
		else
			chat.AddText(Color(255, 127, 127), bullet, " ", Color(210, 210, 225), info.name, Color(127, 127, 127), " (" .. info.steamid .. ") ", Color(255, 127, 127), "left", Color(210, 210, 225), " the server!", Color(127, 127, 127), " (" .. info.reason .. ")")
		end
	end)

	hook.Add("ChatText", tag, function(_, _, _, mode)
		if mode == "joinleave" then
			return true
		end
	end)
end


