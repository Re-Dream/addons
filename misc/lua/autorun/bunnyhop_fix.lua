
hook.Add("Initialize", "bunnyhop_fix", function()
	hook.Remove("Initialize", "bunnyhop_fix")

	function GAMEMODE:StartMove() end
	function GAMEMODE:FinishMove() end
end)

