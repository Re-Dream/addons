
-- This works! kind of
concommand.Add("read_last_commit", function()
	local exists = file.Exists("last_commit.txt", "DATA")
	if exists then
		local commit = util.JSONToTable(file.Read("last_commit.txt", "DATA"))
		local text = {}
		if commit.head_commit.message and commit.head_commit.message:Trim() ~= "" then
			local txt = ""
			local lines = commit.head_commit.message:Trim():Split("\n")
			for k, v in next, lines do
				txt = txt .. "    > " .. v .. "\n" -- (k == #lines and "" or "\n")
			end
			text[#text + 1] = txt
		end
		local operations = {
			modified = { Symbol = "*", Color = Color(96, 96, 255) },
			added = { Symbol = "+", Color = Color(96, 255, 96) },
			removed = { Symbol = "-", Color = Color(255, 96, 96) }
		}
		for op, info in next, operations do
			if #commit.head_commit[op] > 0 then
				text[#text + 1] = info.Color
				local txt = ""
				for k, v in next, commit.head_commit[op] do
					txt = txt .. "    " .. info.Symbol .. " " .. v .. "\n" -- (k == #commit.head_commit[op] and "" or "\n")
				end
				text[#text + 1] = txt
			end
		end
		text[#text] = text[#text]:gsub("\n$", "")
		ChatAddText(
			Color(175, 235, 225),
			"Update in " .. commit.repository.name .. " by " .. commit.head_commit.author.username .. " (" .. commit.head_commit.author.email .. "):\n",
			unpack(text)
		)

	end
end)

