
local tag = "webmaterial"

local webMatLoc = "webmaterial"
if not file.IsDir(webMatLoc, "DATA") then
	file.CreateDir(webMatLoc)
end
local webMatFallback = Material("debug/debugwhite")
local webMatCache = {}
local function FetchWebMaterial(name, url)
	local function WebMatError(err)
		Msg"[WebMaterial] "print("HTTP fetch failed for ", url, ": " .. tostring(err))
	end
	http.Fetch(url, function(data, len, _, err)
		file.Write(webMatLoc .. "/" .. name .. ".png", data)

		local mat = Material("../data/" .. webMatLoc .. "/" .. name .. ".png")

		if not mat or mat:IsError() then
			Msg"[WebMaterial] "print("Downloaded material, but it's an error: ", name)
			return
		end

		webMatCache[name] = mat
	end, WebMatError)
end
function WebMaterial(name, url)
	if not file.Exists(webMatLoc .. "/" .. name .. ".png", "DATA") then
		FetchWebMaterial(name, url)
	else
		local mat = Material("../data/" .. webMatLoc .. "/" .. name .. ".png")

		if not mat or mat:IsError() then
			Msg"[WebMaterial] "print("Material found, but it's an error: ", name, ", redownloading")
			FetchWebMaterial(name, url)
		else
			webMatCache[name] = mat
		end
	end
	local c = webMatCache[name]
	c = (not c or c:IsError()) and webMatFallback or c
	return c
end

