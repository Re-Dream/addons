
if CLIENT then

	function GetHostName()
		return GetGlobalString("ServerName")
	end

else

	local prefix = "Re-Dream: "
	local titles = -- STOP INDENTING IT, IT BREAKS.
[[We do shit better.
:blox:
:sadbarf:
sexual tension
We have blackjack and hookers
GCompute inside
come fuck around
build stupid shit
code stupid shit
make stupid shit
professionalism itself
out of hostnames
pac4 when?
better than outfitter
trust no one, not even the workshop
gmlounge.us
gmlounge.us
gmlounge.us
The Lounge]]
-------------------------------------->            max hostname size i believe

	titles = string.Split(titles, "\n")
	for key, title in next, titles do
		if title:Trim():len() < 1 then
			table.remove(titles, key)
		end
	end

	local stopped -- some workaround because timer.Stop is aids
	function SetHostName(hostname)
		if not hostname then ResetHostName() return end
		stopped = hostname and true
		RunConsoleCommand("hostname", tostring(hostname))
		SetGlobalString("ServerName", tostring(hostname))
	end

	function SwitchHostName()
		local hostname = prefix .. titles[math.random(1, #titles)]
		RunConsoleCommand("hostname", hostname)
		SetGlobalString("ServerName", hostname)
	end

	function ResetHostName()
		if stopped then stopped = nil end
		SwitchHostName()
	end

	function StopHostName()
		if not stopped then stopped = true end
	end

	timer.Create("HostName", 15, 0, function()
		if stopped then return end
		SwitchHostName()
	end)

end

