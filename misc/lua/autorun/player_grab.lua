
local tag = "player_grab"

local physgun_noplayergrab
if CLIENT then
	physgun_noplayergrab = CreateClientConVar("physgun_noplayergrab", "0", true, true)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetPhysgunner()
	if isentity(self.Physgunner) and not IsValid(self.Physgunner) then
		self.Physgunner = nil
	end
	return self.Physgunner
end
function PLAYER:GetPhysgunning()
	if isentity(self.Physgunning) and not IsValid(self.Physgunning) then
		self.Physgunning = nil
	end
	return self.Physgunning
end

hook.Add("PhysgunPickup", tag, function(ply, ent)
	if ent:GetClass():lower() == "player" then
		local friend = false
		if CLIENT then
			friend = friend or ent:GetFriendStatus(ply) == "friend"
		elseif SERVER then
			friend = friend or (ent:IsFriend(ply) and ent:GetInfoNum("physgun_noplayergrab", 1) == 0)
		end
		friend = friend or ply:IsAdmin()
		friend = friend or ent:IsBot()
		local ret = hook.Run("PlayerCanGrabPlayer", ply, ent)
		if ret ~= nil then
			friend = ret
		end
		if friend and not ply.Physgunning and not ent.Physgunner then
			ent:SetMoveType(MOVETYPE_NONE)
			ent:SetOwner(ply)
			ent.Physgunner = ply
			ply.Physgunning = ent
			return true
		end
	end
end)

hook.Add("PhysgunDrop", tag, function(ply, ent)
	if ent:IsPlayer() then
		ent:SetMoveType((isentity(ply) and ply:IsPlayer() and ply:KeyDown(IN_ATTACK2) and ply:IsAdmin()) and MOVETYPE_NOCLIP or MOVETYPE_WALK)
		ent:SetOwner()
		ent.Physgunner = nil
		ply.Physgunning = nil
	end
end)

hook.Add("PlayerDisconnected", tag, function(ply)
	hook.Run("PhysgunDrop", tag, ply, ply.Physgunning)
end)

