
if CLIENT then return end

local w = Color(194, 210, 225)
local g = Color(127, 255, 127)
local function doLinkOpenFunc(link)
	return function(ply)
		if not ply.ChatAddText or not ply.OpenURL then
			return false, "ChatAddText / OpenURL missing?"
		end

		ply:ChatAddText(w, "Link opened in the ", g, "Steam Overlay", w, "! If you have it disabled, here's the link:")
		ply:ChatAddText(g, link)
		ply:OpenURL(link)
	end
end

mingeban.CreateCommand({"steam", "steamgroup", "group"}, doLinkOpenFunc("https://steamcommunity.com/groups/Re-Dream"))
mingeban.CreateCommand({"rocket", "liftoff", "cp"}, doLinkOpenFunc("https://gmlounge.us/redream/rcon"))
mingeban.CreateCommand("discord", doLinkOpenFunc("https://discord.gg/9Gc8DeA"))

