local reload = theater and theater.screen
theater = {screen = reload}

theater.locations = {
	gm_bluehills_test3 = {
		offset = Vector(7.5, 31, 39),
		angle  = Angle(-90, 90, 0),
		height = 350,
		width  = 704,
		mins   = Vector(353, 81, -35),
		maxs   = Vector(1184, 1184, 434),
		mpos   = Vector(446.4, 1175.6, 313),
		mang   = Angle(0, -90, 0),
	},
}

local l = theater.locations[game.GetMap()]
if not l then return end

easylua.StartEntity("theater_screen")
	ENT.PrintName = "Theater Screen"
	ENT.Base = "mediaplayer_base"
	ENT.Type = "point"
	ENT.RenderGroup = RENDERGROUP_OTHER

	ENT.PlayerConfig = l
	ENT.IsMediaPlayerEntity = true

	if SERVER then
		local box = ents.FindInBox

		function ENT:Initialize()
			local mp = self:InstallMediaPlayer("entity")

			function mp:UpdateListeners()
				local listeners = {}
				for _, v in ipairs(box(l.mins, l.maxs)) do
					if v:IsPlayer() then
						listeners[#listeners + 1] = v
					end
				end

				self:SetListeners(listeners)
			end
		end
	else
		function ENT:Draw()
		end
	end
easylua.EndEntity()

if CLIENT then
	hook.Add("GetMediaPlayer", "theater", function()
		local ply = LocalPlayer()

		if ply:GetPos():WithinAABox(l.mins, l.maxs) then
			local ent = ents.FindByClass("theater_screen")[1]

			if ent then
				return MediaPlayer.GetByObject(ent)
			end
		end
	end)
else
	function theater.spawn()
		if IsValid(theater.screen) then
			theater.screen:Remove()
		end

		theater.screen = ents.Create("theater_screen")
		local screen = theater.screen
			screen:SetPos(l.mpos)
			screen:SetAngles(l.mang)
			screen:SetMoveType(MOVETYPE_NONE)
		screen:Spawn()
		screen:Activate()

		return screen
	end

	if reload then theater.spawn() end
	hook.Add("InitPostEntity", "theater", theater.spawn)
end
