local api = require("api")

--Logging
local is_debug_logging_enabled = false

local function debug_logging(message)
	if is_debug_logging_enabled then
		api.Log:Err(message)
	end
end

--Submodules
local settings_window = require("WhatTheBuff/settings")
local local_buff_tracker = require("WhatTheBuff/local_buff_tracker")
local target_buff_tracker = require("WhatTheBuff/target_buff_tracker")


local function on_load()
	api.Log:Info("Loaded WhatTheBuff controller.")
end

local function on_unload()
	if local_buff_tracker ~= nil then
		local_buff_tracker:Show(false)
	end
	if settings_window ~= nil then
		settings_window.cleanup()
	end
	if target_buff_tracker ~= nil then
		target_buff_tracker.cleanup()
	end
end

return {
	name = "WhatTheBuff",
	desc = "Pretty buff tracking",
	author = "Aguru",
	version = "1.0",
	OnLoad = on_load,
	OnUnload = on_unload,
}
