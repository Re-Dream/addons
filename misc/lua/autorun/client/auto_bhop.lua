local bhop = CreateClientConVar("auto_bhop", "0", true)

hook.Add("CreateMove","auto_bhop",function(cmd)
	if not bhop:GetBool() then return end
	if bit.band(cmd:GetButtons(), IN_JUMP) == 2 and LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP and LocalPlayer():WaterLevel() <= 1 and not LocalPlayer():OnGround() then
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
	end
end)