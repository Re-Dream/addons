
-- This works!
concommand.Add("read_last_commit", function()
	local exists = file.Exists("last_commit.txt", "DATA")
	if exists then
		local text = file.Read("last_commit.txt", "DATA")
		ChatAddText(Color(155, 255, 0), text)
	end
end)

