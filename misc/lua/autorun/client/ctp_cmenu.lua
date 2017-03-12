
local printed = false
local w = Color(194, 210, 225)
local g = Color(127, 255, 127)
list.Set(
	"DesktopWindows",
	"ZCTP",
	{
		title = "Thirdperson",
		icon = "icon32/zoom_extend.png",
		width = 960,
		height = 700,
		onewindow = true,
		init = function(icn, pnl)
			pnl:Remove()
			if not printed then
				chat.AddText(w, "Go in the ", g, "Spawn Menu", w, " > ", g, "Utilities", w, " > ", g, "CTP", w, " category to customize the third person!")
				printed = true
			end
			RunConsoleCommand("ctp")

			return false
		end
	}
)

