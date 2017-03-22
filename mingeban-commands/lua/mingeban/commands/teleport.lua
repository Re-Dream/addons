
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

local function goto(from, to, istp)
	if not IsValid(from) then return end

	local ent = to
	if not ent then return end
	if not isentity(to) and not isvector(to) then
		ent = mingeban.utils.findEntity(to, false)[1]
	end

	if not from:Alive() then
		from:Spawn()
	end

	if isentity(ent) and IsValid(ent) then
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
			from:LookAt(ent, 0.25)
			from:EmitSound("buttons/button15.wav")
		else
			from:EmitSound("player/jumplanding" .. (math.random(1, 2) == 1 and math.random(0, 5) or "") .. ".wav")
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
go:AddArgument(ARGTYPE_VARARGS)
	:SetName("target")

local bring = mingeban.CreateCommand("bring", function(caller, line, pos)
	return goto(pos, caller)
end)
bring:AddArgument(ARGTYPE_PLAYER)
	:SetName("target")

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

