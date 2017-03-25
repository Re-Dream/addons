
hook.Add("PostReloadToolsMenu", "ToolSearch", function()
	local toolPanel = g_SpawnMenu.ToolMenu.ToolPanels[1]
	local divider = toolPanel.HorizontalDivider
	local list = toolPanel.List

	local panel = vgui.Create("EditablePanel", divider)
	list:SetParent(panel)
	list:Dock(FILL)

	local search = panel:Add("DTextEntry")
	search:Dock(TOP)
	search:DockMargin(0, 0, 0, 2)
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
			for _, pnl in next, cat:GetChildren() do
				if pnl.ClassName ~= "DCategoryHeader" then
					if language.GetPhrase(pnl:GetText()):lower():match(str:lower()) then
						pnl:SetVisible(true)
					else
						pnl:SetVisible(false)
					end
				end
			end
			cat:InvalidateLayout()
		end
	end

	divider:SetLeft(panel)

end)

RunConsoleCommand("spawnmenu_reload")

