if CLIENT then
	function Say(x)
		RunConsoleCommand("say", tostring(x))
	end
else
	function Say(x)
		game.ConsoleCommand("say " .. tostring(x) .. "\n")
	end
end