local PLAYER = FindMetaTable("Player")
PLAYER.Coins = 0

function PLAYER:GetCoins()
	return self.Coins
end

function PLAYER:SetCoins(c)
    self.Coins = c
    self:SetNWInt("Coins", self.Coins)
    file.Write("coins/" .. self:SteamID64() .. ".txt", self.Coins) -- writes a steamid64 of required user
end

hook.Add("PlayerInitialSpawn", "Cl_CoinInit", function(ply)
    if not file.Exists("coins/" .. ply:SteamID64() .. ".txt", "DATA") then
        ply:SetCoins(0)
    else
        ply:SetCoins(file.Read("coins/" .. ply:SteamID64() .. ".txt", "DATA"))
    end
end)

coins = {}
function coins.CreateCoin(amount, pos)
    local ent = ents.Create("sent_coin")
    ent:SetCoins(amount)
    ent:SetPos(pos)
    ent:Spawn()
end

