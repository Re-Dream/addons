
--[[

Player [1][TrashAlert] ERR: addons/misc/lua/autorun/engine_protection.lua:92: table index is nil
  1. unknown - addons/misc/lua/autorun/engine_protection.lua:92

]]

-- do return end

local maxidx = 5
local tbl = hook.Hooks

if not tbl then
	for i = 1, maxidx do
		local name, v = debug.getupvalue(hook.GetTable, i)
		if name == "Hooks" then tbl = v break end
	end
end

hook.Hooks = tbl or {}
function hook.GetTable() return hook.Hooks end

function hook.Add(event_name, name, func)
	if not isfunction(func) then return end
	if not isstring(event_name) then return end

	if not hook.Hooks[event_name] then
		hook.Hooks[event_name] = {}
	end

	hook.Hooks[event_name][name] = func
end

function hook.Remove(event_name, name)
	if not isstring(event_name) then return end
	if not hook.Hooks[event_name] then return end

	hook.Hooks[event_name][name] = nil
end

local function removeIfError(func, name, id, ...)
	local ok, a, b, c, d, e, f = pcall(func, ...)
	if ok then return a, b, c, d, e, f end

	local f = debug.getinfo(func)

	if f.what == "C" or file.Exists(f.short_src, "GAME") then
		print("Hook errored: '" .. name .. "' ->", id)
		ErrorNoHalt(a .. "\n")
		print("Could not remove hook as there could be potentially fatal consequences")
		return
	end

	hook.Hooks[name][id] = nil

	print("Removing broken Hook: '" .. name .. "' ->", id)
	ErrorNoHalt(a .. "\n")
end

function hook.Call(name, gm, ...)
	local HookTable = hook.Hooks[name]
	if HookTable then
		local a, b, c, d, e, f

		for k, v in pairs(HookTable) do
			if isstring(k) then
				a, b, c, d, e, f = removeIfError(v, name, k, ...)
			else
				if IsValid(k) then
					a, b, c, d, e, f = removeIfError(v, name, k, k, ...)
				else
					HookTable[k] = nil
				end
			end

			if a ~= nil or b then
				return a, b, c, d, e, f
			end
		end
	end

	if not gm then return end

	local GamemodeFunction = gm[name]
	if not GamemodeFunction then return end

	return GamemodeFunction(gm, ...)
end

function hook.Run(name, ...)
	return hook.Call(name, gmod and gmod.GetGamemode(), ...)
end

function hook.overwriteRegistry()
	if not hook.oldCall then
		local _R = debug.getregistry()
		local hookCall

		local lookingFor = "lua/includes/modules/hook.lua"
		local maxRegScan = 2^16

		for i = 1, maxRegScan do
			local v = _R[i]
			local info = isfunction(v) and debug.getinfo(v).short_src
			if info == lookingFor then hookCall = i break end
		end

		if not hookCall then return end
		print("Found hook.Call in registry at index", hookCall)

		hook.oldCall = _R[hookCall]
		hook.oldCallIndex = hookCall
		_R[hookCall] = hook.Call
	end
end

hook.overwriteRegistry()
timer.Simple(0, hook.overwriteRegistry)

hooks = hook.GetTable()
setmetatable(hook, {
	__call = function(self, event, name, callback)
		if not name then
			return hooks[event]
		elseif not callback then
			hook.Remove(event, name)
		else
			hook.Add(event, name, callback)
		end
	end
})

