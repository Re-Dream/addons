
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
aowl.AddCommand = function(name, callback, group)
	mingeban.CreateCommand(name, callback)
	for _, rank in next, mingeban.ranks do
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

hook.Run("AowlInitialized")

