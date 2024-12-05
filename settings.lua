local api = require("api")

--Logging
local is_debug_logging_enabled = true

local function debug_logging(message)
	if is_debug_logging_enabled then
		api.Log:Err(message)
	end
end

debug_logging("Loaded WhatTheBuff settings.")

local settings = {}

settings.ui_toggle_button = nil
settings.ui_settings_window = nil

function settings.initialize()
    --Create and show the button
    --Create and show the settings UI
end

function settings.cleanup()
    if settings.ui_toggle_button ~= nil then
        settings.ui_toggle_button:Show(false)
        settings.ui_toggle_button = nil
    end
    if settings.ui_settings_window ~nil then
        settings.ui_settings_window:Show(false)
        settings.ui_settings_window = nil
    end
end

return settings