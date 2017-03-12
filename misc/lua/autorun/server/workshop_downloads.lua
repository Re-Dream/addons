
local addons = {
	["prone-mod"] = 775573383,
}
local maps = {
	["gm_bluehills_test3"] = 243902601,
	["gm_freespace_09_extended"] = 278492798,
	["gm_freespace_13"] = 115510325,
}

for name, id in next, addons do
	resource.AddWorkshop(id)
end
for name, id in next, maps do
	if game.GetMap() == name then
		resource.AddWorkshop(id)
	end
end


