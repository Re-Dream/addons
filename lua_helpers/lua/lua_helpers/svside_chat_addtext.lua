
local tag = "sv_chat_addtext"

if SERVER then

	util.AddNetworkString(tag)

	local PLAYER = FindMetaTable("Player")

	function PLAYER:ChatAddText(...)

		net.Start(tag)
			net.WriteTable({...})
		net.Send(self)

	end

	function ChatAddText(...)

		net.Start(tag)
			net.WriteTable({...})
		net.Broadcast()

	end

end

if CLIENT then

	net.Receive(tag, function()

		local tbl = net.ReadTable()
		if not istable(tbl) then return end

		chat.AddText(unpack(tbl))

	end)

end

