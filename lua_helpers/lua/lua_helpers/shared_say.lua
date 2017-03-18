
if CLIENT then
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
		LocalPlayer():ConCommand("say " .. msg)
	end
elseif SERVER then
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
		game.ConsoleCommand("say " .. msg .. "\n")
	end
end

