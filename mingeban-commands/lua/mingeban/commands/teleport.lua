
if CLIENT then return end

local trace = {
	start = nil,
	endpos = nil,
	mask = MASK_PLAYERSOLID,
	filter = nil
}
local function IsStuck(ply)
	trace.start = ply:GetPos()
	trace.endpos = trace.start
	trace.filter = ply

	return util.TraceEntity(trace, ply).StartSolid
end

local teleportSounds = {
	"jumplanding",
	"jumplanding2",
	"jumplanding3",
	"jumplanding4",
	"jumplanding_zombie",
}
local function goto(from, to, istp)
	if not IsValid(from) then return end

	local ent = to
	if not ent then return end
	if not isentity(to) and not isvector(to) then
		ent = mingeban.utils.findEntity(to)[1]
	end
	if ent == from then return false, "Can't goto yourself" end

	if from:IsPlayer() then
		if not from:Alive() then from:Spawn() end
		if from:InVehicle() then from:ExitVehicle() end
	end

	if IsValid(ent) and isentity(ent) then
		local pos = ent:GetPos()
		local oldPos = from:GetPos()
		local goodPos
		local ang = Angle(0, ent:EyeAngles().y, 0)
		local right = false
		if pos:Distance(oldPos) <= 130 then
			right = true
		else
			for i = 0, 7 do
				ang.y = ang.y + 360 * (i / 7)
				goodPos = pos + ang:Forward() * 80 + Vector(0, 0, 8)
				from:SetPos(goodPos)
				if from:GetMoveType() ~= MOVETYPE_NOCLIP and IsStuck(from) then
					for i = 1, 8 do
						goodPos = pos + ang:Forward() * (80 + 16 * i) + Vector(0, 0, 8)
						from:SetPos(goodPos)
						if not IsStuck(from) then
							right = true
							break
						end
					end
				else
					right = true
					break
				end
			end
		end
		if not right then
			from:SetPos(oldPos)
			return false, "Couldn't teleport you without getting you stuck"
		else
			if from:IsPlayer() then
				from:LookAt(ent, 0.25)
			end
			from:EmitSound("buttons/button15.wav")
		end
	elseif isvector(ent) then
		from:SetPos(ent)
		if not istp then
			if from:IsPlayer() then
				from:LookAt(ent, 0.25)
			else
				local gpo = from:GetPhysicsObject()
				if IsValid(gpo) then
					gpo:EnableMotion(false)
				end
			end
			from:EmitSound("buttons/button15.wav")
		else
			from:EmitSound("player/" .. table.Random(teleportSounds) .. ".wav")
		end
	else
		return false, "Invalid location!"
	end

end

local go = mingeban.CreateCommand({"go", "goto"}, function(caller, line, pos, y, z)
	if caller:IsAdmin() and y and z then
		pos = Vector(tonumber(pos), tonumber(y), tonumber(z))
	end
	return goto(caller, pos)
end)
go:SetAllowConsole(false)
go:AddArgument(ARGTYPE_VARARGS)
	:SetName("target")

local bring = mingeban.CreateCommand("bring", function(caller, line, plys)
	if #plys < 2 then
		return goto(plys[1], caller)
	else
		for _, ent in next, plys do
			local isPlayer = ent:IsPlayer()
			local ok, err = goto(ent, isPlayer and caller or caller:GetEyeTrace().HitPos)
			if ok == false then
				mingeban.utils.print(mingeban.colors.Red, tostring(ent) .. " bring: " .. err)
			end
		end
	end
end)
bring:SetAllowConsole(false)
bring:AddArgument(ARGTYPE_PLAYERS)
	:SetName("target")
	:SetFilter(function(caller, ent)
		return caller:IsAdmin() and true or caller:IsFriend(ent)
	end)

local tp = mingeban.CreateCommand({"tp", "teleport", "blink"}, function(caller)
	local traceData = util.GetPlayerTrace(caller)
	traceData.mask = bit.bor(CONTENTS_PLAYERCLIP, MASK_PLAYERSOLID_BRUSHONLY, MASK_SHOT_HULL)

	local plyTrace = util.TraceLine(traceData)
	local start = caller:GetPos() + Vector(0, 0, 1)
	local endPos = plyTrace.HitPos
	local wasInWorld = util.IsInWorld(start)

	local dist = start - endPos
	local length = dist:Length()
	length = length > 100 and 100 or length
	dist:Normalize()
	dist = dist * length

	if not wasInWorld and util.IsInWorld(endPos - plyTrace.HitNormal * 120) then
		plyTrace.HitNormal = -plyTrace.HitNormal
	end
	start = endPos + plyTrace.HitNormal * 120

	local traceData = {
		start = start,
		endpos = endPos,
		filter = caller,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		mask = bit.bor(CONTENTS_PLAYERCLIP, MASK_PLAYERSOLID_BRUSHONLY, MASK_SHOT_HULL)
	}
	local trace = util.TraceHull(traceData)

	if trace.StartSolid or (wasInWorld and not util.IsInWorld(trace.HitPos)) then
		trace = util.TraceHull(traceData)
		traceData.start = endPos + plyTrace.HitNormal * 3
	end
	if trace.StartSolid or (wasInWorld and not util.IsInWorld(trace.HitPos)) then
		trace = util.TraceHull(traceData)
		traceData.start = caller:GetPos() + Vector(0, 0, 1)
	end
	if trace.StartSolid or (wasInWorld and not util.IsInWorld(trace.HitPos)) then
		trace = util.TraceHull(traceData)
		traceData.start = endPos + dist
	end

	if trace.StartSolid then
		return false, "Couldn't teleport you without getting you stuck"
	end

	return goto(caller, trace.HitPos, true)
end)
tp:SetAllowConsole(false)

