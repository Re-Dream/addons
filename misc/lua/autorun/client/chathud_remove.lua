
hook.Add("HUDPaint", "chathud.remove", function()
	hook.Remove("HUDShouldDraw", "chathud.disable")
	hook.Remove("HUDPaint", "chathud.draw")
	hook.Remove("HUDPaint", "chathud.remove")
end)

