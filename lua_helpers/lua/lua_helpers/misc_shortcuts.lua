
if CLIENT then
	function cmd(cmd)
		LocalPlayer():ConCommand(cmd)
	end

	function Say(...)
		local first = true
		local msg = ""
		for _, v in pairs({...}) do
			if first then
				first = false
			else
				msg = msg .. " "
			end
			msg = msg .. tostring(v)
		end
		msg = msg:gsub("\n", ""):gsub(";", ":"):gsub("\"", "'")
		cmd("say " .. msg)
	end
elseif SERVER then
	require("fps")
	hook.Add("Think", "serverfps", function()
		SetGlobalInt("serverfps", 1 / engine.RealFrameTime())
	end)

	function cmd(cmd)
		game.ConsoleCommand(cmd .. "\n")
	end

	function Say(...)
		local first = true
		local msg = ""
		for _, v in pairs({...}) do
			if first then
				first = false
			else
				msg = msg .. " "
			end
			msg = msg .. tostring(v)
		end
		msg = msg:gsub("\n", ""):gsub(";", ":"):gsub("\"", "'")
		cmd("say " .. msg)
	end
end

function engine.ServerFPS()
	return GetGlobalInt("serverfps")
end

