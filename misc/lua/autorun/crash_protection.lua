local t = SysTime
crash_protection = crash_protection or {}

crash_protection.maxExecTime = 5
crash_protection.instructionInterval = 2^24

crash_protection.lastChecked = t()

do
	local hookFunc = function()
		if t() - crash_protection.lastChecked > crash_protection.maxExecTime then
			error("Infinite loop detected!", 2)
		end
	end

	hook.Add("Think", "crash_protection.think", function()
		crash_protection.lastChecked = t()
		debug.sethook(hookFunc, "", crash_protection.instructionInterval)
	end)
end

if CLIENT then
	crash_protection.cams = crash_protection.cams or {}
	crash_protection.backup = crash_protection.backup or {}

	local cams = {
		["3D2D"]  = {cam.Start3D2D, cam.End3D2D, 0},
		["3D"]    = {cam.Start3D, cam.End3D, 0},
		["2D"]    = {cam.Start2D, cam.End2D, 0},
		[""]      = {cam.Start, cam.End, 2},
	}

	for n, f in pairs(cams) do
		crash_protection.cams[n] = crash_protection.cams[n] or 0
		crash_protection.backup[n] = crash_protection.backup[n] or f

		cam["Start" .. n] = function(...)
			crash_protection.cams[n] = crash_protection.cams[n] + 1
			return crash_protection.backup[n][1](...)
		end

		cam["End" .. n] = function(...)
			if crash_protection.cams[n] <= crash_protection.backup[n][3] then
				collectgarbage()
				error("cam.End" .. n .. " called before cam.Start" .. n, 2)
			end

			crash_protection.cams[n] = crash_protection.cams[n] - 1
			return crash_protection.backup[n][2](...)
		end
	end
end
