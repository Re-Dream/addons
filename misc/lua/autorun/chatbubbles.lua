
local tag = "chatbubbles"

if SERVER then
	util.AddNetworkString(tag)

	net.Receive(tag, function(_, ply)
		local typing = net.ReadBool()
		local text = net.ReadData(1024*1024)

		ply.Typing = typing and (util.Decompress(text) or "") or nil

		net.Start(tag)
			net.WriteEntity(ply)
			net.WriteBool(typing)
			net.WriteData(text, #text)
		net.Broadcast()
	end)

	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetTypingMessage()
		return self.Typing
	end
end

if CLIENT then
	-- networking

	net.Receive(tag, function()
		local ply = net.ReadEntity()
		local typing = net.ReadBool()
		local text = net.ReadData(1024*1024) or ""
		text = util.Decompress(text) or ""

		ply.Chatbubbles = ply.Chatbubbles or {}
		local bub = ply.Chatbubbles
		bub.typing = typing
		bub.text = text
	end)

	local started = false
	local easychat_enable = GetConVar("easychat_enable")
	if easychat_enable and easychat_enable:GetBool() then
		hook.Add("ECOpened", tag, function()
			started = true
			net.Start(tag)
				net.WriteBool(true)
				net.WriteData("", #(""))
			net.SendToServer()
		end)
	end
	hook.Add("StartChat", tag, function()
		started = true
		net.Start(tag)
			net.WriteBool(true)
			net.WriteData("", #(""))
		net.SendToServer()
		-- print("StartChat")
	end)
	hook.Add("FinishChat", tag, function()
		started = false
		net.Start(tag)
			net.WriteBool(false)
			net.WriteData("", #(""))
		net.SendToServer()
		-- print("FinishChat")
	end)
	hook.Add("ChatTextChanged", tag, function(text)
		net.Start(tag)
			local typing = (text ~= "" or text == "" and started) and true or false
			net.WriteBool(typing)
			local text = util.Compress(text) or ""
			net.WriteData(text, #text)
		net.SendToServer()
		-- print("ChatTextChanged")
	end)

	local oldBubbles = {}
	hook.Add("OnPlayerChat", tag, function(ply, text)
		local bub = ply.Chatbubbles
		if not bub then return end
		if not oldBubbles[ply] then oldBubbles[ply] = {} end
		local oldBub = oldBubbles[ply]
		oldBub[#oldBub + 1] = {
			text = text,
			time = RealTime(),
			pos  = ply:EyePos(),
			ang  = ply:EyeAngles()
		}
	end)

	-- draw

	surface.CreateFont(tag, {
		font = "Roboto Cn",
		size = 52,
		weight = 200
	})
	local function PlayersByRange()
		local plys = player.GetAll()
		table.sort(plys, function(a, b)
			return a:GetPos():Distance(EyePos()) > b:GetPos():Distance(EyePos())
		end)
		return plys
	end
	local function GetEyePos(ply, _ang)
		local eyes = false -- ply:LookupAttachment("eyes")
		if eyes then
			eyes = ply:GetAttachment(eyes)
			return eyes.Pos, eyes.Ang
		else
			local pos, ang
			if type(ply) == "Player" and not _ang then
				pos, ang = ply:EyePos(), ply:EyeAngles()
			else
				pos, ang = Vector(ply.x, ply.y, ply.z), Angle(_ang.p, _ang.y, _ang.r)
			end
			ang:RotateAroundAxis(ang:Up(), 90)
			ang:RotateAroundAxis(ang:Forward(), 90)

			pos = pos + ang:Forward() * 7.5
			pos = pos + ang:Right() * -10

			local diff = EyePos() - pos
			diff:Normalize()
			local behind = -diff:Dot(ang:Up()) > 0
			if behind then
				ang:RotateAroundAxis(ang:Right(), 180)
			end

			pos = pos + Vector(0, 0, math.sin(RealTime() * 2) * 1)

			return pos, ang, behind
		end
	end
	local maxLength = 32
	local MAXLength = 46
	local function WordWrap(text)
		local newText = ""
		local i = 0
		for _, c in next, text:Split("") do
			newText = newText .. c
			i = i + 1
			if (i > maxLength and c:match("[,.%s]")) or i > MAXLength then
				i = 0
				newText = newText .. "\n"
			end
		end
		local lines = {}
		for _, str in next, newText:Split("\n") do
			lines[#lines + 1] = str:Trim()
		end
		return lines
	end
	local function Draw(pos, ang, txt, mono, col, behind)
		local lines = istable(txt) and txt or (mono and { txt } or WordWrap(txt))
		cam.Start3D2D(pos, ang, mono and 0.25 or 0.066)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetFont(mono and "defaultfixed" or tag)
			local _, lineH = surface.GetTextSize("W")
			local txtH = lineH * #lines
			local largestW = 0
			for _, str in next, lines do
				local txtW, _ = surface.GetTextSize(str)
				if largestW < txtW then
					largestW = txtW
				end
			end
			local margin = mono and 3 or 9
			local h = math.max(4, txtH) + margin * 2

			surface.SetDrawColor(Color(27, 27, 40, 255))
			surface.DrawRect(0 - (behind and largestW or 0), -(lineH * (#lines - 1)), largestW + margin * 2, h)

			surface.SetDrawColor(Color(255, 255, 255, 2))
			for i = 0, (mono and 0 or 3) do
				surface.DrawOutlinedRect(i - (behind and largestW or 0), i - (lineH * (#lines - 1)), largestW + margin * 2 - i * 2, h - i * 2)
			end

			for i, str in next, lines do
				surface.SetTextPos(margin - (behind and largestW or 0), -(lineH * (#lines - 1)) + margin + lineH * (i - 1))
				surface.SetTextColor(col and col or Color(235, 235, 255, 255))
				surface.DrawText(str)
			end

			render.PopFilterMag()
		cam.End3D2D()
	end
	hook.Add("PostDrawEffects", tag, function()
		cam.Start3D()
			local ok, err = pcall(function()
				for _, ply in next, PlayersByRange() do
					if oldBubbles[ply] then
						for i, data in next, oldBubbles[ply] do
							local pos, ang, behind = GetEyePos(data.pos, data.ang)

							data.addPos = data.addPos or Vector(0, 0, 0)
							data.addPos.z = Lerp(FrameTime() * 3, data.addPos.z, 7)
							pos = pos + data.addPos

							data.alpha = data.alpha or 1
							if data.time + 6 < RealTime() then
								data.alpha = Lerp(FrameTime() * 5, data.alpha, 0)
							end

							if data.alpha <= 0.005 then
								table.remove(oldBubbles[ply], i)
							else
								surface.SetAlphaMultiplier(data.alpha)
								Draw(pos, ang, data.text, false, nil, behind)
								surface.SetAlphaMultiplier(1)
							end
						end
					end
					local bub = ply.Chatbubbles
					if bub and bub.typing then
						local pos, ang, behind = GetEyePos(ply)

						local txt, col
						local dots = bub.text:Trim() == ""
						if dots then
							txt = ("."):rep(math.ceil(RealTime() % 3))
							col = Color(164, 164, 255)
						else
							txt = bub.text
						end
						Draw(pos, ang, txt, dots, col, behind)
					end
				end
			end)
			if not ok then
				ErrorNoHalt(err)
			end
		cam.End3D()
	end)
end

