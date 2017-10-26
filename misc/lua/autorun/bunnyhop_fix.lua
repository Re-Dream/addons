
hook.Add("Initialize", "bunnyhop_fix", function()
	function GAMEMODE:StartMove() end
	function GAMEMODE:FinishMove() end
end)

