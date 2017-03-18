
local addons = {
	["prone-mod"] = 775573383,
	["notifications"] = 650064006, -- to be redone by ourselves
	["jumppads"] = 431422041,
}
local maps = {
	["gm_bluehills_test3"] = 243902601,
	["gm_freespace_09_extended"] = 278492798,
	["gm_freespace_13"] = 115510325,
	["gm_abstraction_ex-night"] = 741592270,
	["gm_abstraction_ex-sunset"] = 740691120,
}

for name, id in next, addons do
	resource.AddWorkshop(id)
end
for name, id in next, maps do
	if game.GetMap() == name then
		resource.AddWorkshop(id)
	end
end


