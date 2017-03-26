local META = FindMetaTable("Player")

META.Coins = 0

function META:GetCoins(  )
	return META.Coins
end

function META:SetCoins( c )
    META.Coins = c
    file.Write("coins/".. self:SteamID64() ..".txt", META.Coins) --writes a steamid64 of required user
end

hook.Add("PlayerInitialSpawn", "Cl_CoinInit", function(ply)
    if(file.Exists("coins/".. ply:SteamID64() ..".txt", "DATA") == false) then 
        file.Write("coins/".. ply:SteamID64() ..".txt", 0) --write 0 coins
        ply:SetCoins(0)
    else
        ply:SetCoins(file.Read("coins/".. ply:SteamID64() ..".txt", "DATA"))
    end
end)

for _,ply in pairs(player.GetAll()) do
	if(file.Exists("coins/".. ply:SteamID64() ..".txt", "DATA") == false) then 
        file.Write("coins/".. ply:SteamID64() ..".txt", 0) --write 0 coins
        ply:SetCoins(0)
    else
        ply:SetCoins(file.Read("coins/".. ply:SteamID64() ..".txt", "DATA"))
    end
end

local ENTT = FindMetaTable("Entity")
ENTT.Coins = 0

function ENTT:SetCoins(v)
	ENTT.Coins = v
end

function ENTT:GetCoins()
		return ENTT.Coins
end