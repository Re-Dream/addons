
hook.Add("PostReloadToolsMenu", "ToolSearch", function()
	local toolPanel = g_SpawnMenu.ToolMenu.ToolPanels[1]
	local divider = toolPanel.HorizontalDivider
	local list = toolPanel.List

	local panel = vgui.Create("EditablePanel", divider)
	list:SetParent(panel)
	list:Dock(FILL)

	local text = panel:Add("EditablePanel")
	text:Dock(TOP)
	text:DockMargin(0, 0, 0, 2)
	text:SetTall(20)

	local search = text:Add("DTextEntry")
	search:Dock(FILL)
	search:DockMargin(0, 0, 2, 0)
	search:SetText("Search Tool...")
	search._OnGetFocus = search.OnGetFocus
	function search:OnGetFocus(...)
		if not self.Clicked then
			self:SetText("")
			self.Clicked = true
		end
		self:_OnGetFocus(...)
	end
	search:SetUpdateOnType(true)
	function search:OnValueChange(str)
		for _, cat in next, list.pnlCanvas:GetChildren() do
			local hidden = 0
			for _, pnl in next, cat:GetChildren() do
				if pnl.ClassName ~= "DCategoryHeader" then
					if language.GetPhrase(pnl:GetText()):lower():match(str:lower()) then
						pnl:SetVisible(true)
					else
						pnl:SetVisible(false)
						hidden = hidden + 1
					end
				end
			end
			if hidden >= #cat:GetChildren() - 1 then
				cat:SetVisible(false)
			else
				cat:SetVisible(true)
				cat:InvalidateLayout()
			end
		end
	end

	local clear = text:Add("DButton")
	clear:Dock(RIGHT)
	clear:SetWide(20)
	clear:SetText("")
	function clear:DoClick()
		search:SetValue("")
	end
	local close = Material("icon16/cross.png")
	function clear:Paint(w, h)
		derma.SkinHook("Paint", "Button", self, w, h)

		surface.SetMaterial(close)
		surface.SetDrawColor(Color(255, 255, 255))
		surface.DrawTexturedRect(w * 0.5 - 16 * 0.5, h * 0.5 - 16 * 0.5, 16, 16)
	end

	divider:SetLeft(panel)
end)

-- RunConsoleCommand("spawnmenu_reload")

