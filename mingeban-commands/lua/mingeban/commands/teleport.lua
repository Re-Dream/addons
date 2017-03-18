
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

local function goto(from, to)
	if not IsValid(from) then return end

	local ent = to
	if not isentity(to) and not isvector(to) then
		ent = mingeban.utils.findEntity(to, false)[1]
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
				if IsStuck(from) then
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
			return false, "Couldn't find a position without getting you stuck"
		else
			if from:IsPlayer() then
				from:LookAt(ent, 0.6)
			end
			from:EmitSound("buttons/button15.wav")
		end
	elseif isvector(ent) then
		from:SetPos(ent)
		from:LookAt(ent, 0.6)
		from:EmitSound("buttons/button15.wav")
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

