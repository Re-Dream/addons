
local tag = "LookAt"

if CLIENT then

	local target
	local startAng
	local tStart
	local tEnd
	local lookLength
	local newAng
	local lply
	local function stop()
		target = nil
		startAng = nil
		tStart = nil
		tEnd = nil
		lookLength = nil
		newAng = nil
		hook.Remove("CreateMove", tag)
	end
	local function LookAt(userCmd)
		if not target or not tEnd then stop() return end
		if not lply then lply = LocalPlayer() return end
		if RealTime() >= tEnd then stop() return end

		userCmd:SetMouseX(0)
		userCmd:SetMouseY(0)

		local target = target
		if isentity(target) then
			local bone = target:LookupBone("ValveBiped.Bip01_Head1")
			if bone then
				target = target:GetBonePosition(bone)
			else
				target = target:EyePos()
			end
		end
		target = target - lply:EyePos()
		newAng = LerpAngle((RealTime() - tStart) / lookLength, newAng or startAng, target:Angle())

		userCmd:SetViewAngles(newAng)
	end

	net.Receive(tag, function()
		local pos
		local succ = pcall(function()
			pos = Entity(net.ReadInt(16))
		end)
		if not succ then
			succ = pcall(function()
				pos = net.ReadVector()
			end)
		end
		local length = net.ReadFloat()

		startAng = LocalPlayer():EyeAngles()
		tStart = RealTime()
		tEnd = tStart + length
		lookLength = length
		target = pos

		hook.Add("CreateMove", tag, LookAt)
	end)

end

if SERVER then

	local PLAYER = FindMetaTable("Player")
	util.AddNetworkString(tag)
	function PLAYER:LookAt(pos, length)
		assert(isvector(pos) or isentity(pos), "bad argument #1 to 'LookAt' (Vector/Entity expected, got " .. type(pos) .. ")")

		net.Start(tag)
			if isentity(pos) then
				net.WriteInt(pos:EntIndex(), 16)
			else
				net.WriteVector(pos)
			end
			net.WriteFloat(length)
		net.Send(self)

	end

end

