
if not easylua then return end

local reload = theater and theater.screen
theater = {screen = reload}

theater.locations = {
	gm_bluehills_test3 = {
		offset = Vector(0, 0, 0),
		angle  = Angle(-90, 90, 0),
		height = 352,
		width  = 704,
		mins   = Vector(353, 81, -35),
		maxs   = Vector(1184, 1184, 434),
		mpos   = Vector(416.03125, 1175.3011474609, 351.95498657227),
		mang   = Angle(0, -90, 0),
	},
	["gm_abstraction_ex-sunset"] = {
		offset = Vector(0, 0, 0),
		angle  = Angle(-90, 90, 0),
		height = 200,
		width  = 320,
		mins   = Vector(-764, -2142, 0),
		maxs   = Vector(-145, -1507, 914),
		mpos   = Vector(-720, -2080, 249),
		mang   = Angle(0, 0, 0),
	},
}

theater.locations["gm_abstraction_ex-night"] = theater.locations["gm_abstraction_ex-sunset"]

local l = theater.locations[game.GetMap()]
if not l then
	theater.spawn = function() ErrorNoHalt("No theater location for this map! " .. game.GetMap() .. "\n") end

	return
end

easylua.StartEntity("theater_screen")
	ENT.PrintName = "Theater Screen"
	ENT.Base = "mediaplayer_base"
	ENT.Type = "point"

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
	hook.Add("PostCleanupMap", "theater", theater.spawn)
end

