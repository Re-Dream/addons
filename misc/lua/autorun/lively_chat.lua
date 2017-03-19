
local tag = "lively_chat"

local prefix = mingeban and mingeban.utils.CmdPrefix or "^[%$%.!/]"

if CLIENT then

	team.SetUp(1001, "Unassigned", Color(129, 171, 213)) -- custom chat color

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
	function lively_chat.StartAnnouncements()
		curMsg = 1
		timer.Create(tag .. "_announcements", msgs[1].time, 0, lively_chat.PrintNextAnnouncement)
	end
	-- lively_chat.StartAnnouncements()

	hook.Add("PreChatSoundsSay", tag, function(ply, txt)
		if txt:match(prefix) then return false end
	end)

end


