
local tag = "lua_screen"

local ENT = {}

ENT.ClassName = tag
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Coords = {
	s = 0.2,
	w = 512,
	h = 256,
}

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	local gpo = self:GetPhysicsObject()
	if IsValid(gpo) then
		gpo:Wake()
		gpo:EnableMotion(false)
	end

	if CLIENT then
		local w, h, s = self.Coords.w, self.Coords.h, self.Coords.s
		local pos, ang = self:GetPos(), self:GetAngles()
		local min = -(
			ang:Right() * (w * s)
		+	ang:Up() * (h * s)
		+ 	ang:Forward() * 5
		)
		local max =
			ang:Right() * (w * s)
		+	ang:Up() * (h * s)
		+ 	ang:Forward() * 5
		self:SetRenderBounds(min, max)
	end
end

if SERVER then
	hook.Add("PhysgunDrop", tag, function(ply, ent)
		if ent:GetClass() == tag then
			local gpo = ent:GetPhysicsObject()
			if IsValid(gpo) then
				gpo:Wake()
				gpo:EnableMotion(false)
			end
		end
	end)

	function ENT:Grip(b)
		self:SetSolid(b and SOLID_VPHYSICS or SOLID_NONE)
	end
end

if CLIENT then
	function ENT:ScreenCoords()
		local ang = self:GetAngles()
		-- ang:RotateAroundAxis(ang:Right(), 90)
		ang:RotateAroundAxis(ang:Up(), 270)

		local pos = self:GetPos()
		pos = pos - ang:Forward() * ((self.Coords.w * 0.5) * self.Coords.s)
		pos = pos - ang:Right() * ((self.Coords.h * 0.5) * self.Coords.s)
		pos = pos + ang:Up() * -2

		return pos, ang
	end

	function ENT:CursorPos()
		local pos, ang = self:ScreenCoords()
		local w, h, s = self.Coords.w, self.Coords.h, self.Coords.s

		local normal = -ang:Up()
		local maxRange = 128
		local p = util.IntersectRayWithPlane(LocalPlayer():EyePos(), LocalPlayer():GetAimVector(), pos, normal)

		-- if there wasn't an intersection, don't calculate anything.
		if not p then return end
		if WorldToLocal(LocalPlayer():GetShootPos(), Angle(0, 0, 0), pos, ang).z < 0 then return end

		if maxRange > 0 then
			if p:Distance(LocalPlayer():EyePos()) > maxRange then
				return
			end
		end

		local pos = WorldToLocal(p, Angle(0, 0, 0), pos, ang)
		pos.x = pos.x * (1 / s)
		pos.y = -pos.y * (1 / s)

		if pos.x < 0 or pos.x > w or pos.y < 0 or pos.y > h then return end

		return pos.x, pos.y
	end

	function ENT:Draw()
		self:DrawShadow(false)
	end

	local cursor = Material("icon16/cursor.png")
	function ENT:DrawTranslucent()
		local pos, ang = self:ScreenCoords()

		local w, h, s = self.Coords.w, self.Coords.h, self.Coords.s
		cam.Start3D2D(pos, ang, self.Coords.s)
			if self.Draw3D2D then
				self:Draw3D2D(w, h, s)
			else
				surface.SetDrawColor(Color(127, 64, 0, 255))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(255, 64, 0, 255))
				surface.DrawOutlinedRect(0, 0, w, h)

				draw.SimpleText("Test!", "DermaDefault", 8, 8, color_white)

				local x, y = self:CursorPos()
				if x and y then
					surface.SetMaterial(cursor)
					surface.SetDrawColor(Color(255, 255, 255))
					surface.DrawTexturedRect(x - 4, y, 16, 16)
				end
			end
		cam.End3D2D()

		if self:GetSolid() ~= SOLID_NONE then
			render.SetBlend(0.15)
			render.SuppressEngineLighting(true)
			self:DrawModel()
			render.SuppressEngineLighting(false)
			render.SetBlend(1)
		end
		self:DrawShadow(false)
	end
end

scripted_ents.Register(ENT, tag)

