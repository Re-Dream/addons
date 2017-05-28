
-- This will not work
concommand.Add("read_last_commit", function()
	local exists = file.Exists("last_commit.txt")
	if exists then
		for k, v in next, file.Read("last_commit.txt", "DATA"):Split("\n") do
			ChatAddText(Color(155, 255, 0), v)
		end
	end
end)

