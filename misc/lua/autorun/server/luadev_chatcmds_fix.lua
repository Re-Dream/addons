do return end

hook.Add("PlayerSay","luadev_chatcmds",function(ply,txt,target)
	local txt = string.Explode(" ",txt)
	local function X(ply,i) return luadev.GetPlayerIdentifier(ply,'cmd:'..i) end
	local line = table.concat(txt," ",2)

	if (string.match(txt[1],"^[!/%.]l$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line) =="" then return false,ply:PrintMessage(HUD_PRINTTALK,"[LuaDev] invalid script") end
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,"l") if not valid then return ply:PrintMessage(HUD_PRINTTALK,err) end end
		return luadev.RunOnServer(line, X(ply,"l"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]ls$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return false,ply:PrintMessage(HUD_PRINTTALK,"[LuaDev] invalid script") end
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,"ls") if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end
		return luadev.RunOnShared(line, X(ply,"ls"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]lc$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,"lc") if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end
		return luadev.RunOnClients(line,  X(ply,"lc"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]lsc$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return false,ply:PrintMessage(HUD_PRINTTALK,"[LuaDev] invalid script") end

		local args = txt[2]:gsub(","," ",1):Split(" ")
		txt[2] = args[1]
		if not args[2] or string.Trim(args[2])=="" then return false,ply:PrintMessage(HUD_PRINTTALK,"[LuaDev] invalid script") end
		local script = args[2].." "..table.concat(txt," ",3) -- ugly but works

		/*local pos = 0
		while true do
		  local a = string.find(txt[2],",",pos+1,true)
		  if a == nil then break end
		  pos = a
		end
		print(pos)*/

		local ent = easylua.FindEntity(txt[2])
		if ent:IsPlayer() then
			--local script = string.sub(line, string.find(line[2], target, 1, true)+#target+1)
			if luadev.ValidScript then local valid,err = luadev.ValidScript(script,'lsc') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end
			luadev.RunOnClient(script,  ent,  X(ply,"lsc"), {ply=ply})
		else
			return false
		end
	end

	local sv_allowcslua = GetConVar"sv_allowcslua"
	if (string.match(txt[1],"^[!/%.]lm$")) then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,'lm') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err)end end

		if not ply:IsSuperAdmin() and not sv_allowcslua:GetBool() then return false,ply:PrintMessage(HUD_PRINTTALK,"sv_allowcslua is 0") end

		luadev.RunOnClient(line, ply,X(ply,"lm"), {ply=ply})

	end

	if (string.match(txt[1],"^[!/%.]lb$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,'lb') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		luadev.RunOnClient(line, ply, X(ply,"lb"), {ply=ply})
		return luadev.RunOnServer(line, X(ply,"lb"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]print$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript('x('..line..')','print') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		return luadev.RunOnServer("print(" .. line .. ")",  X(ply,"print"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]table$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript('x('..line..')','table') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		return luadev.RunOnServer("PrintTable(" .. line .. ")",  X(ply,"table"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]keys$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript('x('..line..')','keys') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		return luadev.RunOnServer("for k, v in pairs(" .. line .. ") do print(k) end",  X(ply,"keys"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]printc$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		line = "easylua.PrintOnServer(" .. line .. ")"
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,'printc') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		return luadev.RunOnClients(line,  X(ply,"printc"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]printm$")) and ply:IsSuperAdmin() then
		if not line or string.Trim(line)=="" then return end
		line = "easylua.PrintOnServer(" .. line .. ")"
		if luadev.ValidScript then local valid,err = luadev.ValidScript(line,'printm') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		luadev.RunOnClient(line,  ply,  X(ply,"printm"), {ply=ply})
	end

	if (string.match(txt[1],"^[!/%.]printb$")) and ply:IsSuperAdmin() then
		if not line or line=="" then return end
		if luadev.ValidScript then local valid,err = luadev.ValidScript('x('..line..')','printb') if not valid then return false,ply:PrintMessage(HUD_PRINTTALK,err) end end

		luadev.RunOnClient("easylua.PrintOnServer(" .. line .. ")",  ply, X(ply,"printb"), {ply=ply})
		return luadev.RunOnServer("print(" .. line .. ")",  X(ply,"printb"), {ply=ply})
	end

end)
