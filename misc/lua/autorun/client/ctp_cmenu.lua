
hook.Add("HUDPaint", "_ctp_cmenu", function()
	-- If you're wondering why I'm doing all this;
	-- Not ass looking icon. Why not?

	DImage._SetImage = DImage._SetImage or DImage.SetImage
	function DImage:SetImage(path, backup)
		if type(path) == "IMaterial" then
			self:SetMaterial(path)
		else
			DImage._SetImage(self, path, backup)
		end
	end

	local mat = Material("icon32/zoom_extend.png")

	local TEXTURE_FLAGS_CLAMP_S = 0x0004
	local TEXTURE_FLAGS_CLAMP_T = 0x0008

	local iconTex = GetRenderTargetEx("_ctp_cmenu",
		64,
		64,
		RT_SIZE_NO_CHANGE,
		MATERIAL_RT_DEPTH_SEPARATE,
		bit.bor(TEXTURE_FLAGS_CLAMP_S, TEXTURE_FLAGS_CLAMP_T),
		CREATERENDERTARGETFLAGS_UNFILTERABLE_OK,
	    IMAGE_FORMAT_RGBA8888
	)
	local iconMat = CreateMaterial("_ctp_cmenu", "UnlitGeneric", {
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nolod"] = 1,
		["$basetexture"] = iconTex:GetName()
	})

	local oldRT = render.GetRenderTarget()

	render.SetRenderTarget(iconTex)
		render.ClearDepth()
		render.Clear(0, 0, 0, 0)

		local oldW, oldH = ScrW(), ScrH()
		render.SetViewPort(0, 0, 64, 64)
		cam.Start2D()

			render.ClearStencil()
			render.SetStencilEnable(true)

				render.SetStencilWriteMask(1)
				render.SetStencilTestMask(1)

				render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilPassOperation(STENCILOPERATION_ZERO)
				render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
				render.SetStencilReferenceValue(1)

			 	local margin = 3
			 	local add = 2
				surface.SetDrawColor(Color(255, 255, 255, 255))
			 	surface.DrawRect(margin + add, margin + add, 64 - margin * 2 - add * 2, 64 - margin * 2 - add * 2)

				local inside = false
				render.SetStencilFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilCompareFunction(inside and STENCILCOMPARISONFUNCTION_EQUAL or STENCILCOMPARISONFUNCTION_NOTEQUAL)
				render.SetStencilReferenceValue(1)

				draw.RoundedBox(6, margin, margin, 64 - margin * 2, 64 - margin * 2, Color(255, 255, 255))

			render.SetStencilEnable(false)
			render.ClearStencil()

			surface.SetDrawColor(Color(0, 0, 0, 138))
		 	surface.DrawRect(margin + add, margin + add, 64 - margin * 2 - add * 2, 64 - margin * 2 - add * 2)

			surface.SetMaterial(mat)
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawTexturedRect(18, 20, 32, 32)

		cam.End2D()
		render.SetViewPort(0, 0, oldW, oldH)
		mat = iconMat

	render.SetRenderTarget(oldRT)

	local printed = false
	local w = Color(194, 210, 225)
	local g = Color(127, 255, 127)
	list.Set(
		"DesktopWindows",
		"ZCTP",
		{
			title = "Thirdperson",
			icon = mat,
			width = 960,
			height = 700,
			onewindow = true,
			init = function(icn, pnl)
				pnl:Remove()
				if not printed then
					chat.AddText(w, "Go in the ", g, "Spawn Menu", w, " > ", g, "Utilities", w, " > ", g, "CTP", w, " category to customize the third person!")
					printed = true
				end
				RunConsoleCommand("ctp")

				return false
			end
		}
	)

	CreateContextMenu()

	hook.Remove("HUDPaint", "_ctp_cmenu")
end)

