
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
local go = mingeban.CreateCommand({"go", "goto"}, function(caller, line, pos)
	if not IsValid(caller) then return end

	local ent = mingeban.utils.findEntity(pos, false)[1]

	if ent then
		local pos = ent:GetPos()
		local oldPos = caller:GetPos()
		local goodPos
		local ang = Angle(0, ent:EyeAngles().y, 0)
		local right = false
		if pos:Distance(oldPos) <= 130 then
			right = true
		else
			for i = 0, 7 do
				ang.y = ang.y + 360 * (i / 7)
				goodPos = pos + ang:Forward() * 80 + Vector(0, 0, 8)
				caller:SetPos(goodPos)
				if IsStuck(caller) then
					for i = 1, 8 do
						goodPos = pos + ang:Forward() * (80 + 16 * i) + Vector(0, 0, 8)
						caller:SetPos(goodPos)
						if not IsStuck(caller) then
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
			caller:SetPos(oldPos)
			return false, "Couldn't find a position without getting you stuck"
		else
			caller:LookAt(ent, 0.6)
			caller:EmitSound("buttons/button15.wav")
		end
	end
end)
go:AddArgument(ARGTYPE_VARARGS)
	:SetName("target")

