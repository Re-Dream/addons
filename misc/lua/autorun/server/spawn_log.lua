local Cyan, White, Grey = Color(0,255,255), Color(255,255,255), Color(192, 192, 192)

local function playerToString(ply)
	local s = ""
	s = s .. "[" .. ply:EntIndex() .. "]"
	s = s .. ply:Nick()
	s = s .. " (" .. ply:SteamID() .. ")"
	return s
end

local function Log(event, ply, ...)
	MsgC(Cyan, "[", event, "] ")
	Msg(ply, " ")
	MsgC(...)
	Msg("\n")
end

local prev
local function LogProp(ply, model, entity)
	if prev == "duplicator" then return end
	Log("SPAWN prop", ply, White, entity:GetModel(), Grey, " (" .. tostring(entity) .. " @ " .. tostring(entity:GetPos()) .. ")")
end

local function LogEffect(ply, model, entity)
	Log("SPAWN effect", ply, White, entity:GetModel(), Grey, " (" .. tostring(entity) .. " @ " .. tostring(entity:GetPos()) .. ")")
end

local function LogSENT(ply, entity)
	Log("SPAWN sent", ply, White, entity.PrintName or entity:GetClass(), Grey, " (" .. tostring(entity) .. " @ " .. tostring(entity:GetPos()) .. ")")
end

local function LogVehicle(ply, entity)
	Log("SPAWN vehicle", ply, White, entity.VehicleTable.Name, Grey, " (" .. tostring(entity) .. ")")
end

local ignoreTools = {
	paint = true,
	inflator = true,
}
local function LogTool(ply, tr, tool)
	if ignoreTools[tool] then return end
	Log("TOOL", ply, White, tool, Grey, " " .. tostring(tr.Entity) .. " @ " .. tostring(tr.HitPos))
	prev = tool
	timer.Simple(0, function() prev = nil end)
end

hook.Add("PlayerSpawnedProp", "sandbox_logger", LogProp)
hook.Add("PlayerSpawnedEffect", "sandbox_logger", LogEffect)
hook.Add("PlayerSpawnedSENT", "sandbox_logger", LogSENT)
hook.Add("PlayerSpawnedVehicle", "sandbox_logger", LogVehicle)
hook.Add("CanTool", "sandbox_logger", LogTool)
