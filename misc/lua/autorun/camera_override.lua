
hook.Add("Initialize", "gmod_camera_override", function()
	local SWEP = weapons.GetStored("gmod_camera")

	SWEP._Reload = SWEP._Reload or SWEP.Reload

	SWEP.NextReload = 0
	function SWEP:Reload()
		if self.NextReload > CurTime() then return end
		if self.Owner:KeyDown(IN_USE) then
			self:SetNWBool("Hidden", not self:GetNWBool("Hidden"))
			if self:GetNWBool("Hidden") then
				self:SetHoldType("normal")
			else
				self:SetHoldType("camera")
			end
			self.NextReload = CurTime() + 1
			return
		end
		self:_Reload()
	end

	function SWEP:DrawWorldModel()
		if not self:GetNWBool("Hidden") then
			self:DrawModel()
		end
	end
end)

