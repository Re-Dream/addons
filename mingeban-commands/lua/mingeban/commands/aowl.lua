
if CLIENT then return end

local alias =
{
	players = "user",
	default = "user",
	admin = "superadmin",
	moderators = "superadmin",
	developers = "superadmin",
	owners = "superadmin",
	superadmins = "superadmin",
	administrator = "superadmin",
}

aowl = {}

--[[ this might not be needed
local handle = {
	vote = function(cmd)
		cmd:AddArgument(ARGTYPE_VARARGS)
	end
}
]]
aowl.AddCommand = function(name, callback, group)
	local cmd = mingeban.CreateCommand(name, callback)
	cmd:AddArgument(ARGTYPE_VARARGS)
		:SetName("any")
	-- if handle[name] then handle[name](cmd) end

	if not group then group = "players" end
	for _, rank in next, mingeban:GetRanks() do
		if alias[group] == rank:GetName() then
			if istable(name) then
				for _, name in next, name do
					local perm = "command." .. name
					if not rank:GetPermission(perm) then
						rank:AddPermission(perm)
					end
				end
			else
				local perm = "command." .. name
				if not rank:GetPermission(perm) then
					rank:AddPermission(perm)
				end
			end
		end
	end
end

concommand.Add("aowl", concommand.GetTable().mingeban)

hook.Run("AowlInitialized")
function aowlMsg(cmd, line)
	mingeban.utils.print(mingeban.colors.Cyan, (cmd and cmd .. " " or "") .. line)
end

