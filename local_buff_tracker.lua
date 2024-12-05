local api = require("api")

--Logging
local is_debug_logging_enabled = true

local function debug_logging(message)
	if is_debug_logging_enabled then
		api.Log:Err(message)
	end
end

debug_logging("Loaded WhatTheBuff local_buff_tracker.")

local function CreateBuffTrackerView(frame, settings, offset)
	local i = 1

	if frame.trackers ~= nil then
		i = #frame.trackers
	else
		frame.trackers = {}
	end

	local tracker = frame:CreateChildWidget("emptywidget", "tracker." .. i, 0, true)
	tracker:SetExtent(172, 40)
	tracker.settings = settings
	tracker.is_visible = false

	local buffIcon = CreateItemIconButton(i .. ".buffIcon", tracker)
	buffIcon:Show(true)
	F_SLOT.ApplySlotSkin(buffIcon, buffIcon.back, SLOT_STYLE.BUFF)
	buffIcon:AddAnchor("TOPLEFT", tracker, "TOPLEFT", 0, 0)
	-- F_SLOT.SetIconBackGround(zealIcon, trackedBuffInfo.path)
	-- local buffTime = ...
	local buffTimeBar = api.Interface:CreateStatusBar("speedo", tracker, "item_evolving_material")
	buffTimeBar:SetBarColor({
		ConvertColor(55),
		ConvertColor(200),
		ConvertColor(66),
		1
	})
	buffTimeBar.bg:SetColor(ConvertColor(76), ConvertColor(45), ConvertColor(8), 0.4)
	buffTimeBar:SetMinMaxValues(0, 100)
	buffTimeBar:AddAnchor("TOPLEFT", tracker, 42, 1)
	buffTimeBar:AddAnchor("BOTTOMRIGHT", tracker, -1, 1)

	local buffTimeLabel = tracker:CreateChildWidget("label", "buffTimeLabel", 0, true)
	buffTimeLabel:AddAnchor("TOPLEFT", tracker, "CENTER", 0, 0)
	buffTimeLabel.style:SetFontSize(20)

	--TODO: See if changing this to negative results in an upwards stack
	tracker:AddAnchor("TOPLEFT", frame, 0, 0 + (40 * offset))
	tracker:Show(false)

	local maxBuffTime = 0
	tracker.lastTime = 0

	function tracker:UpdateBuff(buff)
		F_SLOT.SetIconBackGround(buffIcon, buff.path)
		if maxBuffTime < buff.timeLeft then
			maxBuffTime = buff.timeLeft
		end

		buffTimeBar:SetValue((buff.timeLeft / maxBuffTime) * 100)
		buffTimeLabel:SetText(string.format("%.1fs", buff.timeLeft / 1000))

		--
		-- Need to change the default anchor to being at the bottom of the stack rather than the top
		-- Before we show the tracker we need to set its anchor to the top of the stack
		-- When we hide an anchor we need to cascade all the other trackers above this one so they're lower
		-- RemoveAllAnchors()

		if buff.timeLeft > 20 then
			if not tracker:IsVisible() then
				tracker:Reset()
				debug_logging("Tracker reset?")
			end
			tracker:Show(true)
			tracker.is_visible = true
			debug_logging("Tracker show: true tracker.is_visible: " .. tracker.is_visible)
		else
			tracker:Show(false)
			tracker.is_visible = false
			debug_logging("Tracker show: false tracker.is_visible: " .. tracker.is_visible)
		end

		-- Compute keyframes
		for ki, kf in ipairs(settings.keyframes) do
			if tracker.lastTime > kf.time and buff.timeLeft <= kf.time then
				if kf.type == "color" then
					self:SetColor(kf.value)
				end
			end
		end

		tracker.lastTime = buff.timeLeft
	end

	function tracker:SetColor(color)
		buffTimeBar:SetBarColor({
			ConvertColor(color[1]),
			ConvertColor(color[2]),
			ConvertColor(color[3]),
			1
		})
		buffTimeBar.bg:SetColor(ConvertColor(76), ConvertColor(45), ConvertColor(8), 0.4)
	end

	function tracker:Reset()
		buffTimeBar:SetBarColor({
			ConvertColor(55),
			ConvertColor(200),
			ConvertColor(66),
			1
		})
		buffTimeBar.bg:SetColor(ConvertColor(76), ConvertColor(45), ConvertColor(8), 0.4)
	end

	table.insert(frame.trackers, tracker)
end

local frame = api.Interface:CreateEmptyWindow("buffTracker")
frame:Show(true)
frame:AddAnchor("TOPLEFT", "UIParent", 1200, 1100)

local trackedSettings = {
	{
		nameFilter = "Baleful Recharge",
		trg = "player",
		keyframes = {
			{ type = "color", time = 24000, value = { 200, 50, 50 } }
		}
	},
	{
		nameFilter = "Frenzy",
		trg = "player",
		keyframes = {
			{ type = "color", time = 24000, value = { 200, 50, 50 } }
		}
	},
	{
		nameFilter = "Greater Inspire",
		trg = "player",
		keyframes = {
			{ type = "color", time = 24000, value = { 200, 50, 50 } }
		}
	},
	{
		nameFilter = "Battle Focus (Rank 2)",
		trg = "player",
		keyframes = {
			{ type = "color", time = 24000, value = { 200, 50, 50 } }
		}
	},
}

local function RefreshTracked()
	for i, v in ipairs(trackedSettings) do
		CreateBuffTrackerView(frame, v, (i-1))
	end
end

local function BuffLoop(trg)
	local buffCount = api.Unit:UnitBuffCount(trg)
	for i = 1, buffCount, 1 do
		local buff = api.Unit:UnitBuff(trg, i)
		local buffInfo = api.Ability:GetBuffTooltip(buff.buff_id)

		local x = 1
		for k, v in pairs(frame.trackers) do
			debug_logging("BuffLoop k: " .. k .. " v: " .. v)
			if buffInfo.name == frame.trackers[x].settings.nameFilter then
				frame.trackers[x]:UpdateBuff(buff)
			end
			x = x + 1
		end
	end
end

local function OnUpdate()
	BuffLoop("player")
end

RefreshTracked()

api.On("UPDATE", OnUpdate)

return frame
