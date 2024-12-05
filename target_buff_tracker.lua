-- local currentTarget = api.Unit:GetUnitId("target")
-- -- Calculate when to move the anchor for the buff tracker
-- local x, y, z = api.Unit:GetUnitScreenPosition("target")

local api = require("api")

--Logging
local is_debug_logging_enabled = true

local function debug_logging(message)
	if is_debug_logging_enabled then
		api.Log:Err(message)
	end
end

debug_logging("Loaded WhatTheBuff target_buff_tracker.")

local target_buff_tracker = {}

function target_buff_tracker.cleanup()
end

return target_buff_tracker