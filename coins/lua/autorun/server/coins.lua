local PLAYER = FindMetaTable("Player")

function PLAYER:GetCoins()
	return self.Coins
end

function PLAYER:SetCoins(c)
	self.Coins = c
	self:SetNWInt("Coins", self.Coins)
	self:SetPData("Coins", self.Coins) --Save this into MySQL cloud or something.	
	hook.Run( "CoinsChange", self.Coins, self )
end

hook.Add("PlayerInitialSpawn", "Cl_CoinInit", function(ply)
	ply:SetCoins(tonumber(ply:GetPData( "Coins", 0 ))) --Save this into MySQL cloud or something.
end)

coins = {}
function coins.CreateCoin(amount, pos)
	local ent = ents.Create("sent_coin")
	ent:SetCoins(amount)
	ent:SetPos(pos)
	ent:Spawn()
end
