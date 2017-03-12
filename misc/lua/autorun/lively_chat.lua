
local tag = "lively_chat"

if CLIENT then

	team.SetUp(1001, "Unassigned", Color(129, 171, 213)) -- custom chat color

	hook.Add("ChatText", tag .. "_nojoinleave" , function(_, _, _, typ)
		if typ == "joinleave" then return true end
	end)

	gameevent.Listen("player_connect")
	gameevent.Listen("player_discconnect")

	local bullet = "•"
	hook.Add("player_connect", tag, function(data)
		local ent = Entity(data.index)

		chat.AddText(Color(127, 255, 127), bullet, team.GetColor(ent:Team()), " ", data.name, color_white, " is joining the server!")
	end)
	hook.Add("player_disconnect", tag, function(data)

	end)

end

if SERVER then

	-- timed messages, dunno if this is a good idea

	local w = Color(194, 210, 225)
	local g = Color(127, 255, 127)
	local msgs = {
		{
			message = {
				w, "If you wish to get news about the server and participate in its discussions, feel free to join the ", g, "Discord", w, " or ", g, "Steam Group", w, "!"
			},
			time = 60
		},
		{
			message = {
				w, "To do so, type ", g, "!discord", w, " and ", g, "!steam", w, " to join them!"
			},
			time = 10
		},
		{
			message = {
				w, "Thanks for joining ", g, "Re-Dream", w, ", we hope you have a good time on here!"
			},
			time = 900
		},
	}
	local curMsg = 1
	lively_chat = {}
	function lively_chat.PrintNextAnnouncement()
		ChatAddText(unpack(msgs[curMsg].message))

		curMsg = curMsg + 1
		if curMsg > #msgs then
			curMsg = 1
		end

		timer.Adjust(tag .. "_announcements", msgs[curMsg].time, 0, lively_chat.PrintNextAnnouncement)
	end
	timer.Create(tag .. "_announcements", msgs[1].time, 0, lively_chat.PrintNextAnnouncement)

end

