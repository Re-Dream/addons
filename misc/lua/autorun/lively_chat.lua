
local tag = "lively_chat"

local prefix = mingeban and mingeban.utils.CmdPrefix or "^[%$%.!/]"

if CLIENT then
	local gray = Color(192, 212, 222)

	local luaPatterns = {
		[2]  = "([%a_][%w_]*)", -- keyword or text
		[4]  = "(\".-\")", -- string
		[5]  = "([%d]+%.?%d*)", -- number
		[6]  = "([%+%-%*/%%%(%)%.,<>~=#:;{}%[%]])", -- operator
		[7]  = "(//[^\n]*)", -- c comment
		[8]  = "(/%*.-%*/)", -- c multiline comment
		[9]  = "(%-%-[^%[][^\n]*)", -- lua comment
		[10] = "(%-%-%[%[.-%]%])", -- lua multiline comment
		[11] = "(%[%[.-%]%])", -- odd string
		[12] = "('.-')", -- quote string
		[13] = "(!+)", -- c not
	}

	local defCol 	  = Color(192, 197, 206)
	local keywordCol  = Color(180, 142, 173)
	local strCol 	  = Color(163, 190, 140)
	local numberCol   = Color(208, 135, 112)
	local operatorCol = defCol
	local commentCol  = Color(153, 157, 164)
	local colors = {
		Color(255, 255, 255), -- unused
		keywordCol,
		defCol,
		strCol,
		numberCol,
		operatorCol,
		commentCol,
		commentCol,
		commentCol,
		commentCol,
		strCol,
		strCol,
		Color(255,   0,   0), -- c not
	}

	local keywords = {
		["local"]    = true,
		["function"] = true,
		["return"]   = true,
		["break"]    = true,
		["continue"] = true,
		["end"]      = true,
		["if"]       = true,
		["not"]      = true,
		["while"]    = true,
		["for"]      = true,
		["repeat"]   = true,
		["until"]    = true,
		["do"]       = true,
		["then"]     = true,
		["true"]     = true,
		["false"]    = true,
		["nil"]      = true,
		["in"]       = true
	}

	local function syntax_highlight(code) -- borrowed from Meta, made by Morten
		local output = {}
		local finds = {}
		local types = {}
		local startPos, lastPos, type = 0, 0, 0

		while true do
			local temp = {}

			for type, pattern in pairs(luaPatterns) do
				local startPos, endPos = code:find(pattern, lastPos + 1)
				if startPos then
					table.insert(temp, {type, startPos, endPos})
				end
			end

			-- nothing to see
			if #temp == 0 then break end

			-- pick the first detected pattern
			table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)

			-- we will use these in the next loop and to determine if we're using a keyword
			type, startPos, lastPos = unpack(temp[1])

			table.insert(finds, startPos)
			table.insert(finds, lastPos)

			-- are we a keyword?
			table.insert(types, type == 2 and (keywords[code:sub(startPos, lastPos)] and 2 or 3) or type)
		end

		-- this fixes stuff, apparently
		for i = 1, #finds - 1 do
			local fix = (i - 1) % 2
			local sub = code:sub(finds[i] + fix, finds[i + 1] - fix)

			local i2 = 1
			local before = output[#output - i2]
			while isstring(before) and before:Trim() == "" do
				i2 = i2 + 1
				before = output[#output - i2]
			end
			local col = colors[types[1 + (i - 1) / 2]]
			if sub:Trim() ~= "" and before and before ~= col then
				table.insert(output, fix == 0 and col or Color(0, 0, 0, 255))
			end -- add color
			table.insert(output, (fix == 1 and sub:find("^%s+$")) and sub:gsub("%s", " ") or sub) -- add text
			-- not sure what the fix is for here, but let's keep it
		end

		return output
	end

	local client = Color(103, 215, 220)
	local server = Color(114, 241, 129)
	local shared = Color(210, 161, 141)

	local states = {
		["l"]   = { c = server, n = "server",  a = "ran"     },
		["p"]   = { c = server, n = "server",  a = "printed" },
		["lm"]  = { c = client, n = "self",    a = "ran"     },
		["pm"] =  { c = client, n = "self",    a = "printed" },
		["pm2"] = { c = client, n = "self",    a = "printed" },
		["ls"]  = { c = shared, n = "shared",  a = "ran"     },
		["ps"]  = { c = shared, n = "shared",  a = "printed" },
		["lb"]  = { c = shared, n = "both",    a = "ran"     },
		["lc"]  = { c = client, n = "clients", a = "ran"     },
		["pc"]  = { c = client, n = "clients", a = "printed" },
		["lsc"] = { c = client, a = "ran"					 },
		["psc"] = { c = client, a = "printed"				 },
	}

	hook.Add("OnPlayerChat", tag .. "-syntax", function(ply, txt, tc, dead)
		local prefix = txt:match(prefix)
		if prefix then
			local method = txt:lower():match("^" .. prefix .. "(%w+)%s?")
			local methodInfo = states[method]
			if not methodInfo then return end

			local code = txt:sub(prefix:len() + 1 + method:len() + 1)
			local name = methodInfo.n
			if method == "lsc" or method == "psc" then
				name = code:Split(",")[1] or "no one"
				name = name:Trim()
				code = code:sub(name:len() + 2)
			end

			local stuff = { team.GetColor(ply:Team()), ply:Nick(), " ", Color(160, 170, 220), methodInfo.a, gray, "@", methodInfo.c, name, gray, ": " }
			-- stuff[#stuff + 1] = code

			local highlight = syntax_highlight(code)
			for _, thing in next, highlight do
				stuff[#stuff + 1] = thing
			end

			chat.AddText(unpack(stuff))

			return true
		end
	end)
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

