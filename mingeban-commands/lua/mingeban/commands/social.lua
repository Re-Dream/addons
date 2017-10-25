
if CLIENT then return end

local w = Color(194, 210, 225)
local g = Color(127, 255, 127)
local function doLinkOpenFunc(link)
	return function(caller)
		if not caller.ChatAddText or not caller.OpenURL then
			return false, "ChatAddText / OpenURL missing?"
		end

		caller:ChatAddText(w, "Link opened in the ", g, "Steam Overlay", w, "! If you have it disabled, here's the link:")
		caller:ChatAddText(g, link)
		caller:OpenURL(link)
	end
end

mingeban.CreateCommand({"steam", "steamgroup", "group"}, doLinkOpenFunc("https://steamcommunity.com/groups/Re-Dream")):SetAllowConsole(false)
mingeban.CreateCommand({"rocket", "liftoff", "cp"}, doLinkOpenFunc("https://gmlounge.us/redream/rcon")):SetAllowConsole(false)
mingeban.CreateCommand("discord", doLinkOpenFunc("https://discord.gg/9Gc8DeA")):SetAllowConsole(false)

