
hook.Add("CanTool", "ToolAbuseRestrict", function(ply, _, tool)
	if tool == "fading_door" and not table.HasValue(list.Get("FDoorMaterials"), ply:GetInfo("fading_door_mat")) then
		a:ChatPrint("Restricted to allowed materials only!")
		return false
	end
end)

