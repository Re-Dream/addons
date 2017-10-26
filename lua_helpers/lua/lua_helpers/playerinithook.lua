
local tag = "PlayerInitializeHook"
local tag2 = "PlayerInitPostEntityHook"

if CLIENT then
	hook.Add("Initialize", tag2, function()
		net.Start(tag)
		net.SendToServer()
	end)
	hook.Add("InitPostEntity", tag2, function()
		net.Start(tag2)
		net.SendToServer()
	end)
end

if SERVER then
	util.AddNetworkString(tag)
	util.AddNetworkString(tag2)

	net.Receive(tag, function(_, ply)
		hook.Run("PlayerInitialize", ply)
	end)
	net.Receive(tag2,function(_, ply)
		hook.Run("PlayerInitPostEntity", ply)
	end)
end

