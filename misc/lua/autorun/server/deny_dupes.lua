--noo no no

hook.Add("CanTool", "deny_duplicator", function(ply,tr,tool)
	if tool == "duplicator" and not ply:IsAdmin() then
		return false
	end
end)
