
if not chatexp then return end

hook.Add("HUDPaint", "chathud.remove", function()
	hook.Remove("HUDShouldDraw", "chathud.disable")
	hook.Remove("HUDPaint", "chathud.draw")
	hook.Remove("HUDPaint", "chathud.remove")
end)

function chat.AddText(...)
	local old_pos_x, old_pos_y = chat.old_pos()

	if old_pos_x < 0 then
		chat.old_open(0)
		chat.old_close()
	end

	local args = {...}
	for k, v in next, args do
		if type(v):lower() == "player" then
			args[k] = team.GetColor(v:Team())
			table.insert(args, k + 1, v:Nick())
		end
	end

	if chatbox and IsValid(chatbox.frame) then
		chatbox.ParseInto(chatbox.GetChatFeed(), unpack(args))
	end
	chat.old_text(unpack(args))
	chat.PlaySound()
end

