local PLAYER = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString("coins_net")
	
	function PLAYER:GetCoins()
		return self.Coins
	end
	
	function PLAYER:SetCoins(c)
		self.Coins = c
		self:SetNWInt("Coins", self.Coins)
		self:SetPData("Coins", self.Coins) 
		hook.Run( "CoinsChange", self.Coins, self )
		
		net.Start("coins_net")
		net.WriteEntity(self)
		net.WriteFloat(c)
		net.Broadcast()
	end
	
	hook.Add("PlayerInitialSpawn", "Cl_CoinInit", function(ply)
		ply:SetCoins(tonumber(ply:GetPData( "Coins", 0 )))
	end)
	
	coins = {}
	function coins.CreateCoin(amount, pos)
		local ent = ents.Create("sent_coin")
		ent:SetCoins(amount)
		ent:SetPos(pos)
		ent:Spawn()
	end
elseif CLIENT then
	function PLAYER:GetCoins()
		return self.Coins
	end
	
	net.Receive("coins_net", function()
		local ent = net.ReadEntity()
		
		ent.Coins = net.ReadFloat()
	end)
end
