do return end

-- Remove this when a proper admin mod comes about

toolkit = {}
toolkit.cmds = {}

toolkit.pattern = "[!|/|%.]"

function toolkitMsg(...)
	Msg("[tk] ") print(...)
end

function toolkit.parseArgs(str)
	local ret 		= {}
	local inString 	= false
	local strchar 	= ""
	local chr 		= ""
	local escaped 	= false

	for i = 1, #str do
		local char = str[i]

		if escaped then
			chr = chr .. char
			escaped = false
		continue end

		if char:find("[\"|']") and not inString and not escaped then
			inString 	= true
			strchar 	= char
		elseif char:find("[\\]") then
			escaped 	= true

			continue
		elseif inString and char == strchar then
			ret[#ret + 1] = chr:Trim()
			chr 		= ""
			inString 	= false
		elseif char:find("[ ]") and not inString and chr ~= "" then
			ret[#ret + 1] = chr
			chr 		= ""
		else
			chr = chr .. char
		end
	end

	if chr:Trim():len() ~= 0 then
		ret[#ret + 1] = chr
	end

	return ret
end

function toolkit.callCommand(ply, cmd, line, args)
	local ok, msg = pcall(function()
		local allowed, reason = hook.Run("toolkitCommand", cmd, ply, line, unpack(args))

		cmd = toolkit.cmds[cmd]

		if allowed ~= false and (cmd.admin and IsValid(ply) and not ply:IsAdmin()) then
			allowed, reason = false, "Access denied!"
		end

		if allowed ~= false then
			if easylua then easylua.Start(ply) end
				allowed, reason = cmd.callback(ply, line, unpack(args))
			if easylua then easylua.End() end
		end

		if ply:IsValid() and allowed == false then
			ply:EmitSound("buttons/button8.wav")

			if reason then
				ply:SendLua(string.format([[local s = "%s" notification.AddLegacy(s, 1, 4)]], reason))
			end

			toolkitMsg("FAIL", ply, "->", cmd.cmd)
		end
	end)

	if not ok then
		ErrorNoHalt(msg)

		return msg
	end
end

function toolkit.conCommand(ply, _, args)
	local cmd = args[1]
	if not cmd then return end

	local tbl = toolkit.cmds[cmd]
	if not tbl then return end

	if ply.IsBanned and ply:IsBanned() then return end
	table.remove(args, 1)

	toolkit.callCommand(ply, cmd, table.concat(args, " "), args)
end

function toolkit.sayCommand(ply, txt, team)
	if not txt:sub(1, 1):find(toolkit.pattern) then return end

	local cmd 	= txt:match(toolkit.pattern .. "(.-) ") or txt:match(toolkit.pattern .. "(.+)") or ""
	local line 	= txt:match(toolkit.pattern .. ".- (.+)")
	cmd = cmd:lower()

	if not cmd then return end

	local tbl = toolkit.cmds[cmd]
	if not tbl then return end
	toolkit.callCommand(ply, cmd, line, line and toolkit.parseArgs(line) or {})
end

function toolkit.addCommand(cmd, callback, admin)
	if istable(cmd) then
		for k, v in next, cmd do
			toolkit.addCommand(v, callback, admin)
		end

		return
	end

	toolkit.cmds[cmd] = {callback = callback, cmd = cmd, admin = admin}
end

concommand.Add("toolkit", toolkit.conCommand)
hook.Add("PlayerSay", "toolkit.commands", toolkit.sayCommand)

local function ExecuteExpression (ownerId, hostId, expression)
	if GLib.CallSelfInThread() then return end

	-- Execution context
	local executionContext, returnCode = GCompute.Execution.ExecutionService:CreateExecutionContext(ownerId, hostId, "GLua", GCompute.Execution.ExecutionContextOptions.EasyContext + GCompute.Execution.ExecutionContextOptions.Repl)
	if not executionContext then
		print ("Failed to create execution context (" .. GCompute.ReturnCode[returnCode] .. ").")
		return
	end

	local executionInstance
	executionInstance, returnCode = executionContext:CreateExecutionInstance(expression, nil, GCompute.Execution.ExecutionInstanceOptions.EasyContext + GCompute.Execution.ExecutionInstanceOptions.ExecuteImmediately + GCompute.Execution.ExecutionInstanceOptions.CaptureOutput + GCompute.Execution.ExecutionInstanceOptions.SuppressHostOutput)

	if executionInstance then
		executionInstance:GetCompilerStdOut():ChainTo(GCompute.Text.ConsoleTextSink)
		executionInstance:GetCompilerStdErr():ChainTo(GCompute.Text.ConsoleTextSink)
		executionInstance:GetStdOut():AddEventListener("Text",
			function(_, text, color)
				color = color or GLib.Colors.White

				-- Translate color
				local colorId = GCompute.SyntaxColoring.PlaceholderSyntaxColoringScheme:GetIdFromColor(color)
				if colorId then
					color = GCompute.SyntaxColoring.DefaultSyntaxColoringScheme:GetColor(colorId) or color
				end

				GCompute.Text.ConsoleTextSink:WriteColor(text, color)
			end
		)
		executionInstance:GetStdErr():ChainTo(GCompute.Text.ConsoleTextSink)

		-- Line break
		GCompute.Text.ConsoleTextSink:WriteOptionalLineBreak()
	else
		print("Failed to create execution instance (" .. GCompute.ReturnCode[returnCode] .. ").")
	end
end

local executionCommands =
{
	["p"      ] = GLib.GetServerId(),
	["t2"     ] = GLib.GetServerId(),
	["tbl"    ] = GLib.GetServerId(),
	["print2" ] = GLib.GetServerId(),
	["table2" ] = GLib.GetServerId(),

	["pc"     ] = "Clients",
	["tc2"    ] = "Clients",
	["tblc"   ] = "Clients",
	["printc2"] = "Clients",
	["tablec" ] = "Clients",
	["tablec2"] = "Clients",

	["ps"     ] = "Shared",
	["ts"     ] = "Shared",
	["tbls"   ] = "Shared",
	["prints" ] = "Shared",
	["tables" ] = "Shared",
	["prints2"] = "Shared",
	["tables2"] = "Shared",

	["pm2"    ] = "^",
	["tm"     ] = "^",
	["tblm"   ] = "^",
	["printm2"] = "^",
	["tablem" ] = "^",
	["tablem2"] = "^"
}

for command, hostId in pairs(executionCommands) do
	toolkit.addCommand(
		command,
		function(ply, expression)
			expression = expression or ""

			local userId
			if ply == NULL then
				-- Console
				userId = GLib.GetServerId()
				toolkitMsg("!" .. command .. " CONSOLE", expression)
			else
				userId = GLib.GetPlayerId (ply)
				toolkitMsg("!" .. command .. " " .. ply:Nick () .. " (" .. ply:SteamID () .. ")", expression)
			end

			ExecuteExpression(userId, hostId == "^" and userId or hostId, expression)
		end,
		true
	)
end

if not easylua then return end

toolkit.addCommand({"goto", "go"}, function(ply, line)
	local targ = easylua.FindEntity(line)
	if IsValid(targ) then
		toolkitMsg("goto", ply, " -> ", targ)

		local pos = targ:GetPos() + targ:GetForward() * 50
		ply:SetPos(pos)
		local pos2 = targ:GetPos() + Vector(0, 0, 60)
		ply:SetEyeAngles((pos2 - ply:GetShootPos()):Angle())

		ply:EmitSound("buttons/button9.wav")
	end
end)
