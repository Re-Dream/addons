
local tag = "MWP"

local PLAYER = FindMetaTable("Player")
PLAYER._Give = PLAYER._Give or PLAYER.Give

function PLAYER:Give(class, ...)
	self._mwp_allowpickup = true
	self:_Give(class, ...)
	self._mwp_allowpickup = false
end

hook.Add("PlayerCanPickupWeapon", tag, function(ply, wep)
	local trace = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
		filter = ply,
		mask = MASK_PLAYERSOLID,
		ignoreworld = true
	})
	if ply:HasWeapon(wep:GetClass()) or ply:KeyDown(IN_USE) and trace.Entity == wep then
		ply._mwp_allowpickup = true
	end

	if ply._mwp_allowpickup then
		timer.Simple(0, function()
			ply._mwp_allowpickup = false
		end)
	end

	if not ply._mwp_allowpickup then
		return false
	end

end)

