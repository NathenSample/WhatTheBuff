--Logging
local is_debug_logging_enabled = true

local function debug_logging(message)
	if is_debug_logging_enabled then
		api.Log:Err(message)
	end
end

local function create_buff_tracker_view(frame, settings, offset)
	offset = offset - 1;
	local i = 1
	if frame.trackers ~= nil then 
	  i = #frame.trackers
	else
		frame.trackers = {}
	end

	local tracker = frame:CreateChildWidget("emptywidget", "tracker." .. i, 0, true)
	tracker:SetExtent(172, 40)
	tracker.settings = settings

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

	tracker:AddAnchor("TOPLEFT", frame, 0, 0 + (40 * offset))
	tracker:Show(false)

	local maxBuffTime = 0
	tracker.lastTime = 0

	function tracker:update_buff(buff)
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
			end
			tracker:Show(true)
		else
			tracker:Show(false)
		end

		-- Compute keyframes
		for ki, kf  in ipairs(settings.keyframes) do
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

local tracked_settings = {
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

local function refresh_tracked()
	for i, v  in ipairs(tracked_settings) do
  		create_buff_tracker_view(frame, v, i)
  end
end

local function buff_name_matches(buff_name, filter)
	local buff_name_lowered = string.lower(buff_name:gsub("([%(%)])", "%%%1"))
    local filtered_lowered = string.lower(filter)
	return string.find(filtered_lowered, buff_name_lowered) ~= nil
end

local function buff_loop(trg)
	local buffCount = api.Unit:UnitBuffCount(trg)
	for i = 1, buffCount, 1 do
		local buff = api.Unit:UnitBuff(trg, i)
		local buffInfo = api.Ability:GetBuffTooltip(buff.buff_id)
		for k, v in pairs(frame.trackers) do
			if buff_name_matches(buffInfo.name, frame.trackers[k].settings.nameFilter) then
				frame.trackers[k]:update_buff(buff)
			end
		end
	end
end

local function on_update()
	buff_loop("player")
end

refresh_tracked()

api.On("UPDATE", on_update)

return frame
