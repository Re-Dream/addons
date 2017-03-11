-- commands. placeholder until we have admin mod

if CLIENT then return end

local cmds = {}

local w = Color(194, 210, 225)
local g = Color(127, 255, 127)
local function doLinkOpenFunc(link)
	return function(ply)
		ply:ChatAddText(w, "Link opened in the ", g, "Steam Overlay", w, "! If you have it disabled, here's the link:")
		ply:ChatAddText(g, link)
		ply:OpenURL(link)
	end
end
local function addCmd(cmd, func)

	if istable(cmd) then
		for _, name in next, cmd do
			cmds[name] = func
		end
	elseif isstring(cmd) then
		cmds[cmd] = func
	end

end

addCmd({"steam", "steamgroup", "group"}, doLinkOpenFunc("https://steamcommunity.com/groups/Re-Dream"))
addCmd({"rocket", "liftoff", "cp"}, doLinkOpenFunc("https://gmlounge.us/redream/rcon"))
addCmd("discord", doLinkOpenFunc("https://discord.gg/9Gc8DeA"))

local prefixPattern = "[/%.!]"
hook.Add("PlayerSay", "placeholder_commands", function(ply, txt)
	if ply:IsPlayer() then

		local prefix = txt:sub(1, 1):match(prefixPattern)

		if prefix then
			local args = txt:Split(" ")
			local cmd = args[1]:sub(prefix:len() + 1):lower()

			if cmds[cmd] then
				cmds[cmd](ply)
			end
		end

	end
end)

