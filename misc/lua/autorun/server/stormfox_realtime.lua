
hook.Add("Initialize", "stormfox_realtime", function()
	if not StormFox then return end

	StormFox.SetTime(os.date("%H:%M"))
	RunConsoleCommand("sf_timespeed", 1 / 60)
end)

