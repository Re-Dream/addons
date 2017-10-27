local tag = "playtime"
local META = FindMetaTable("Player")

if SERVER then	
	util.AddNetworkString(tag)
	
	META.pt = nil
	
	META.SetPT = function(self,pt)
		self.pt = pt
	end
	
	META.GetPlaytime = function(self)
		return self.pt
	end
	
	playtime = {}
	
	function playtime.net(tbl)
		net.Start(tag)
		net.WriteTable(tbl)
		net.Broadcast()
	end
	
	function playtime.initplayer(ply)
		local thiccboi = ply:GetPData(tag, 0)
		
		if(thiccboi == 0) then
			ply:SetPData(tag.."_joinedin",os.time())
		end
		
		ply:SetPT(thiccboi)
		
		
		playtime.net({
			{ ent = ply, playtime = ply:GetPData(tag, 0) } 
		})
		
	end
	
	timer.Create(tag,1,0,function()
		local tbl = {}
		
		for _,ply in pairs(player.GetAll()) do
			local a = os.time()-ply:GetPData(tag.."_joinedin", 0)
			
			ply:SetPData(tag, a)
			table.insert(tbl, {
				ent = ply,
				playtime = a
			})
			
			ply:SetPT(a)
		end
		
		playtime.net(tbl)
	end)
	
	hook.Add("PlayerInitialSpawn", tag, function(ply)
		playtime.initplayer(ply)
	end)
elseif CLIENT then
	META.pt = nil
	
	META.SetPT = function(self,pt)
		self.pt = pt
	end
	
	META.GetPlaytime = function(self)
		return self.pt
	end
	
	net.Receive(tag, function()
		local tbl = net.ReadTable()
		
		for k,v in pairs(tbl) do
			if(v.ent.SetPT) then
				v.ent:SetPT(v.playtime)
			end
		end
	end)
end
