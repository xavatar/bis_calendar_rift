-- ***************************************************************************************************************************************************
-- * EventDialog.lua                                                                                                                                 *
-- ***************************************************************************************************************************************************
-- * BiSCal Event dialog frame                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.5 / 2012.01.13 / Baanano: Extracted from CalendarTab.lua                                                                                    *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CreateEvent = Internal.ModelView.CreateEvent
local Dropdown = Yague.Dropdown
local GetEventCategories = Internal.DefinitionsView.GetEventCategories
local GetEventIcon = Internal.DefinitionsView.GetEventIcon
local GetEventSubcategories = Internal.DefinitionsView.GetEventSubcategories
local GetSquadLargeIcon = Internal.ModelView.GetSquadLargeIcon
local GetSquadsNumber = Internal.ModelView.GetSquadsNumber
local L = Internal.Localization.L
local MFloor = math.floor
local ModifyEvent = Internal.ModelView.ModifyEvent
local ODate = os.date
local OTime = os.time
local Panel = Yague.Panel
local Popup = Yague.Popup
local RegisterPopupConstructor = Yague.RegisterPopupConstructor
local ShadowedText = Yague.ShadowedText
local Slider = Yague.Slider
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local ipairs = ipairs
local tonumber = tonumber
local unpack = unpack

local function DurationFormatter(duration)
	local hours, minutes = MFloor(duration / 2), (duration % 2) * 30
	local result = (hours > 0 and hours .. L["EventDialog/DurationHours"] or "") .. (hours > 0 and minutes > 0 and " " or "") .. (minutes > 0 and minutes .. L["EventDialog/DurationMinutes"] or "")
	return result ~= "" and result or L["EventDialog/DurationNil"]
end

local function DateFormatter(formatString, timestamp)
	local weekdayName = ({ L["Misc/WeekdayNames"]:match((L["Misc/WeekdayNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%w", timestamp)) + 1]
	local monthName = ({ L["Misc/MonthNames"]:match((L["Misc/MonthNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%m", timestamp))]
	
	formatString = formatString:gsub("%%A", weekdayName)
	formatString = formatString:gsub("%%B", monthName)

	return ODate(formatString, timestamp)
end

local function EventPopup(parent)
	local popup = Popup("EventPopup", parent)
	local popupContent = popup:GetContent()
	
	local typePanel = Panel(popup:GetName() .. ".TypePanel", popupContent)
	local typeContent = typePanel:GetContent()
	local typeTexture = UICreateFrame("Texture", popup:GetName() .. ".TypeTexture", typeContent)
	local categoryDropdown = Dropdown(popup:GetName() .. ".CategoryDropdown", popupContent)
	local subcategoryDropdown = Dropdown(popup:GetName() .. ".SubcategoryDropdown", popupContent)
	local descriptionPanel = Panel(popup:GetName() .. ".DescriptionPanel", popupContent)
	local descriptionContent = descriptionPanel:GetContent()
	local descriptionText = UICreateFrame("RiftTextfield", popup:GetName() .. ".DescriptionText", descriptionContent)
	local dateTitle = ShadowedText(popup:GetName() .. ".DateTitle", popupContent)
	local dateText = UICreateFrame("Text", popup:GetName() .. ".DateText", popupContent)
	local timeTitle = ShadowedText(popup:GetName() .. ".TimeTitle", popupContent)
	local hourDropdown = Dropdown(popup:GetName() .. ".HourDropdown", popupContent)
	local timeSeparator = UICreateFrame("Text", popup:GetName() .. ".TimeSeparator", popupContent)
	local minuteDropdown = Dropdown(popup:GetName() .. ".MinuteDropdown", popupContent)
	local durationTitle = ShadowedText(popup:GetName() .. ".DurationTitle", popupContent)
	local durationDropdown = Dropdown(popup:GetName() .. ".DurationDropdown", popupContent)
	local saveButton = UICreateFrame("RiftButton", popup:GetName() .. ".SaveButton", popupContent)
	local cancelButton = UICreateFrame("RiftButton", popup:GetName() .. ".CancelButton", popupContent)
	local levelCheck = UICreateFrame("RiftCheckbox", popup:GetName() .. ".LevelCheck", popupContent)
	local levelText = ShadowedText(popup:GetName() .. ".LevelText", popupContent)
	local minLevelSlider = Slider(popup:GetName() .. ".MinLevelSlider", popupContent)
	local maxLevelSlider = Slider(popup:GetName() .. ".MaxLevelSlider", popupContent)
	local squadCheck = UICreateFrame("RiftCheckbox", popup:GetName() .. ".SquadCheck", popupContent)
	local squadText = ShadowedText(popup:GetName() .. ".SquadText", popupContent)
	local squadContainer = UICreateFrame("Frame", popup:GetName() .. ".SquadContainer", popupContent)
	local squadFrames = {}
	
	local lastEventID = nil
	local eventDate = OTime()
	local defaultDescription = false
	
	local function CheckDefaultDescription()
		if defaultDescription then
			local _, where = subcategoryDropdown:GetSelectedValue()
			where = where.name
			
			local start = ODate("*t", eventDate)
			start.hour = hourDropdown:GetSelectedValue()
			start.min = minuteDropdown:GetSelectedValue()
			start.sec = 0
			local start = DateFormatter((Internal.AccountSettings.Use24Time and L["EventDialog/HourFormat24"] or L["EventDialog/HourFormat12"]) .. " (%z)", OTime(start))
			
			local duration = DurationFormatter(durationDropdown:GetSelectedValue())
			
			descriptionText:SetText(L["EventDialog/DefaultDescription"]:format(where, DateFormatter(L["EventDialog/DateFormat"], eventDate), start, duration))
			
			defaultDescription = true
		end
	end
	
	local function ResetSquadContainer()
		local numSquads = GetSquadsNumber()
		for index = 1, 8 do
			local squadFrame = squadFrames[index]
			if index < 9 - numSquads then
				squadFrame:SetVisible(false)
			else
				squadFrame:SetVisible(true)
				squadFrame:SetSelected(true)
				squadFrame:SetTexture(GetSquadLargeIcon(index + numSquads - 8))
			end
		end
	end
	
	popup:SetWidth(600)
	popup:SetHeight(550)
	
	typePanel:SetPoint("TOPLEFT", popupContent, "TOPLEFT", 13, 10)
	typePanel:SetPoint("BOTTOMRIGHT", popupContent, "TOPLEFT", 85, 82)
	typePanel:SetInvertedBorder(true)
	
	typeContent:SetBackgroundColor(0, 0, 0, 1)
	
	categoryDropdown:SetPoint("CENTERLEFT", typePanel, 1, 1/4, 10, 0)
	categoryDropdown:SetHeight(30)
	categoryDropdown:SetWidth(470)
	categoryDropdown:SetTextSelector("name")
	categoryDropdown:SetOrderSelector("order")
	local categories = GetEventCategories()
	local minCategory = nil
	for category, categoryData in pairs(categories) do
		if not minCategory or categoryData.order < categories[minCategory].order then
			minCategory = category
		end
	end
	categoryDropdown:SetValues(categories)
	if minCategory then
		categoryDropdown:SetSelectedKey(minCategory)
	end
	
	subcategoryDropdown:SetPoint("CENTERLEFT", typePanel, 1, 3/4, 10, 0)
	subcategoryDropdown:SetHeight(30)
	subcategoryDropdown:SetWidth(470)
	subcategoryDropdown:SetTextSelector("name")
	subcategoryDropdown:SetOrderSelector("order")
	local subcategories = GetEventSubcategories(categoryDropdown:GetSelectedValue())
	local minSubcategory = nil
	for subcategory, subcategoryData in pairs(subcategories) do
		if not minSubcategory or subcategoryData.order < subcategories[minSubcategory].order then
			minSubcategory = subcategory
		end
	end
	subcategoryDropdown:SetValues(subcategories)
	if minSubcategory then
		subcategoryDropdown:SetSelectedKey(minSubcategory)
	end
	
	typeTexture:SetAllPoints()
	typeTexture:SetTextureAsync(unpack(GetEventIcon((categoryDropdown:GetSelectedValue()), (subcategoryDropdown:GetSelectedValue()))))
	
	descriptionPanel:SetPoint("TOPLEFT", typePanel, "BOTTOMLEFT", 0, 10)
	descriptionPanel:SetPoint("RIGHT", subcategoryDropdown, "RIGHT")
	descriptionPanel:SetHeight(120)
	
	descriptionContent:SetBackgroundColor(0, 0, 0, 1)
	
	descriptionText:SetAllPoints()
	descriptionText:SetText("")
	
	dateTitle:SetPoint("TOPLEFT", descriptionPanel, "BOTTOMLEFT", 0, 10)
	dateTitle:SetFontColor(.75, .75, .5)
	dateTitle:SetFontSize(14)
	dateTitle:SetText(L["EventDialog/DateTitle"])
	
	dateText:SetPoint("TOPRIGHT", descriptionPanel, "BOTTOMRIGHT", 0, 10)
	dateText:SetFontSize(14)
	
	timeTitle:SetPoint("TOPLEFT", dateTitle, "BOTTOMLEFT", 0, 15)
	timeTitle:SetFontColor(.75, .75, .5)
	timeTitle:SetFontSize(14)
	timeTitle:SetText(L["EventDialog/TimeTitle"])
	
	minuteDropdown:SetPoint("RIGHT", dateText, "RIGHT")
	minuteDropdown:SetPoint("CENTERLEFT", timeTitle, "CENTERLEFT", 420, 0)
	minuteDropdown:SetHeight(30)
	minuteDropdown:SetReverseUnfold(true)
	minuteDropdown:SetTextSelector("text")
	minuteDropdown:SetOrderSelector("text")
	local minutes = {}
	for index = 0, 59, 5 do
		minutes[index] = { text = ("%02d"):format(index), }
	end
	minuteDropdown:SetValues(minutes)
	
	timeSeparator:SetPoint("CENTER", minuteDropdown, "CENTERLEFT", -10, 0)
	timeSeparator:SetText(L["EventDialog/TimeSeparator"])
	
	hourDropdown:SetPoint("CENTERRIGHT", timeSeparator, "CENTER", -10, 0)
	hourDropdown:SetWidth(152)
	hourDropdown:SetHeight(30)
	hourDropdown:SetReverseUnfold(true)
	hourDropdown:SetTextSelector(function(hour) return Internal.AccountSettings.Use24Time and hour or ((hour % 12 == 0 and 12 or hour % 12) .. (hour >= 12 and L["EventDialog/HourPM"] or L["EventDialog/HourAM"])) end)
	hourDropdown:SetOrderSelector(function(a, b) if Internal.AccountSettings.Use24Time then return a < b else return (a + 24) % 25 < (b + 24) % 25 end end)
	local hours = {}
	for index = 0, 23 do hours[index] = { } end
	hourDropdown:SetValues(hours)
	
	durationTitle:SetPoint("TOPLEFT", timeTitle, "BOTTOMLEFT", 0, 15)
	durationTitle:SetFontColor(.75, .75, .5)
	durationTitle:SetFontSize(14)
	durationTitle:SetText(L["EventDialog/DurationTitle"])
	
	durationDropdown:SetPoint("RIGHT", dateText, "RIGHT")
	durationDropdown:SetPoint("CENTERLEFT", durationTitle, "CENTERLEFT", 248, 0)
	durationDropdown:SetHeight(30)
	durationDropdown:SetReverseUnfold(true)
	durationDropdown:SetTextSelector("text")
	durationDropdown:SetOrderSelector("index")
	local durations = {}
	for index = 0, 15 do
		local durationText = DurationFormatter(index)
		durations[index] = { text = durationText, index = index, }
	end
	durationDropdown:SetValues(durations)
	
	levelCheck:SetPoint("TOPLEFT", durationTitle, "BOTTOMLEFT", 0, 40)
	levelCheck:SetEnabled(true)
	levelCheck:SetChecked(false)
	
	levelText:SetPoint("CENTERLEFT", levelCheck, "CENTERRIGHT", 5, 0)
	levelText:SetFontColor(.75, .75, .5)
	levelText:SetFontSize(14)
	levelText:SetText(L["EventDialog/LevelRestriction"])
	
	minLevelSlider:SetPoint("RIGHT", dateText, "RIGHT")
	minLevelSlider:SetPoint("BOTTOMLEFT", levelCheck, "CENTERLEFT", 248, 0)
	minLevelSlider:SetRange(1, 60)
	minLevelSlider:SetVisible(false)
	
	maxLevelSlider:SetPoint("RIGHT", dateText, "RIGHT")
	maxLevelSlider:SetPoint("TOPLEFT", levelCheck, "CENTERLEFT", 248, 0)
	maxLevelSlider:SetRange(1, 60)
	maxLevelSlider:SetVisible(false)
	
	squadCheck:SetPoint("TOPLEFT", levelCheck, "BOTTOMLEFT", 0, 55)
	squadCheck:SetEnabled(true)
	squadCheck:SetChecked(false)
	
	squadText:SetPoint("CENTERLEFT", squadCheck, "CENTERRIGHT", 5, 0)
	squadText:SetFontColor(.75, .75, .5)
	squadText:SetFontSize(14)
	squadText:SetText(L["EventDialog/SquadRestriction"])
	
	squadContainer:SetPoint("RIGHT", dateText, "RIGHT")
	squadContainer:SetPoint("CENTERLEFT", squadCheck, "CENTERLEFT", 248, 0)
	squadContainer:SetVisible(false)

	for index = 1, 8 do
		local squadFrame = UICreateFrame("Frame", squadContainer:GetName() .. ".SquadFrames." .. index, squadContainer)
		squadFrame:SetPoint("TOPLEFT", squadContainer, "CENTERLEFT", (index - 1) * 38, -35/2)
		squadFrame:SetPoint("BOTTOMRIGHT", squadContainer, "CENTERLEFT", index * 38 - 3, 35/2)
		squadFrame:SetBackgroundColor(.5, 0, 0, 1)
		
		local squadTexture = UICreateFrame("Texture", squadFrame:GetName() .. ".Texture", squadFrame)
		squadTexture:SetPoint("TOPLEFT", squadFrame, "TOPLEFT", 1, 1)
		squadTexture:SetPoint("BOTTOMRIGHT", squadFrame, "BOTTOMRIGHT", -1, -1)
		squadTexture:SetBackgroundColor(0, 0, 0, 1)
		
		local selected = false
		
		function squadFrame:GetSelected()
			return selected
		end
		
		function squadFrame:SetSelected(value)
			selected = value and true or false
			if selected then
				squadFrame:SetBackgroundColor(0, 1, 0, 1)
			else
				squadFrame:SetBackgroundColor(.5, 0, 0, 1)				
			end
		end
		
		function squadFrame:SetTexture(texture)
			squadTexture:SetTextureAsync(unpack(texture))
		end
		
		squadFrame:EventAttach(Event.UI.Input.Mouse.Left.Click,
			function(self)
				self:SetSelected(not self:GetSelected())
			end, squadFrame:GetName() .. ".OnLeftClick")
		
		squadFrames[index] = squadFrame
	end
	
	saveButton:SetPoint("BOTTOMCENTER", popupContent, 1/4, 1, 0, -10)
	saveButton:SetText(L["EventDialog/ButtonSave"])
	
	cancelButton:SetPoint("BOTTOMCENTER", popupContent, 3/4, 1, 0, -10)
	cancelButton:SetText(L["EventDialog/ButtonCancel"])
	
	function categoryDropdown.Event:SelectionChanged(category)
		subcategories = GetEventSubcategories(categoryDropdown:GetSelectedValue())
		minSubcategory = nil
		for subcategory, subcategoryData in pairs(subcategories) do
			if not minSubcategory or subcategoryData.order < subcategories[minSubcategory].order then
				minSubcategory = subcategory
			end
		end
		subcategoryDropdown:SetValues(subcategories)
		if minSubcategory then
			subcategoryDropdown:SetSelectedKey(minSubcategory)
		end	
	end
	
	function subcategoryDropdown.Event:SelectionChanged(subcategory)
		typeTexture:SetTextureAsync(unpack(GetEventIcon((categoryDropdown:GetSelectedValue()), subcategory)))
		CheckDefaultDescription()
	end
	
	hourDropdown.Event.SelectionChanged = CheckDefaultDescription
	minuteDropdown.Event.SelectionChanged = CheckDefaultDescription
	durationDropdown.Event.SelectionChanged = CheckDefaultDescription
	
	descriptionText:EventAttach(Event.UI.Input.Key.Down,
		function(self, h, key)
			if key == "Return" then
				local cursor = self:GetCursor()
				local startPosition, endPosition = self:GetSelection()
				startPosition = startPosition or cursor
				endPosition = (endPosition or cursor) + 1
				local text = self:GetText()
				self:SetText(text:sub(1, startPosition) .. "\n" .. text:sub(endPosition))
				self:SetCursor(startPosition + 1)
			end
		end, descriptionText:GetName() .. ".OnKeyDown")
	
	descriptionText:EventAttach(Event.UI.Textfield.Change,
		function()
			defaultDescription = false
		end, descriptionText:GetName() .. ".OnTextfieldChange")
	
	saveButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local category = categoryDropdown:GetSelectedValue()
			local subcategory = subcategoryDropdown:GetSelectedValue()
			local timeTable = ODate("*t", eventDate)
			local year, month, day = timeTable.year, timeTable.month, timeTable.day
			local hour = hourDropdown:GetSelectedValue()
			local minute = minuteDropdown:GetSelectedValue()
			local duration = durationDropdown:GetSelectedValue()
			local description = descriptionText:GetText():sub(1, 1000)
			local restrictLevel = levelCheck:GetChecked() or nil
			local restrictSquad = squadCheck:GetChecked() or nil
			
			if restrictLevel then
				restrictLevel =
				{
					minLevelSlider:GetPosition(),
					maxLevelSlider:GetPosition(),
				}
			end
			
			if restrictSquad then
				local validSquads = {}
				for _, squadFrame in ipairs(squadFrames) do
					if squadFrame:GetVisible() then
						TInsert(validSquads, squadFrame:GetSelected())
					end
				end
				
				restrictSquad = {}
				for _, selected in ipairs(validSquads) do
					for _ = 1, 8 / #validSquads do
						TInsert(restrictSquad, selected)
					end
				end
			end
			
			if not lastEventID then
				CreateEvent(category, subcategory, year, month, day, hour, minute, duration, description, { restrictLevel = restrictLevel, restrictSquad = restrictSquad })
			else
				ModifyEvent(lastEventID, category, subcategory, year, month, day, hour, minute, duration, description, { restrictLevel = restrictLevel, restrictSquad = restrictSquad })
			end
			parent:HidePopup(addonID .. ".Event", popup)
		end, saveButton:GetName() .. ".OnLeftPress")
	
	cancelButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			parent:HidePopup(addonID .. ".Event", popup)
		end, cancelButton:GetName() .. ".OnLeftPress")
	
	levelCheck:EventAttach(Event.UI.Checkbox.Change,
		function(self)
			local checked = self:GetChecked()
			minLevelSlider:SetVisible(checked)
			maxLevelSlider:SetVisible(checked)
		end, levelCheck:GetName() .. ".OnCheckboxChange")
	
	squadCheck:EventAttach(Event.UI.Checkbox.Change,
		function(self)
			squadContainer:SetVisible(self:GetChecked())
		end, squadCheck:GetName() .. ".OnCheckboxChange")
	
	function popup:SetData(eventID, eventData)
		minLevelSlider:SetPosition(1)
		maxLevelSlider:SetPosition(60)
		ResetSquadContainer()

		categoryDropdown:SetSelectedKey(eventData.category or minCategory)
		subcategoryDropdown:SetSelectedKey(eventData.subcategory or minSubcategory)
		
		descriptionText:SetText(eventData.description or "")
		defaultDescription = not eventData.description
		
		eventDate = eventData.timestamp or OTime()
		local timeTable = ODate("*t", eventDate)
		dateText:SetText(DateFormatter(L["EventDialog/DateFormat"], eventDate))
		hourDropdown:SetSelectedKey(timeTable.hour)
		minuteDropdown:SetSelectedKey((MFloor(timeTable.min / 5 + .5) * 5) % 60)
		
		durationDropdown:SetSelectedKey(eventData.duration or 0)
		
		if eventData.restrictLevel then
			levelCheck:SetChecked(true)
			minLevelSlider:SetPosition(eventData.restrictLevel[1] or 1)
			maxLevelSlider:SetPosition(eventData.restrictLevel[2] or 60)
		else
			levelCheck:SetChecked(false)
		end
		
		if eventData.restrictSquad then
			squadCheck:SetChecked(true)
			
			local visibleSquads = 8
			local offset = 0
			for _, squadFrame in ipairs(squadFrames) do
				if squadFrame:GetVisible() then
					local selected = false
					for index = offset + 1, offset + 8 / visibleSquads do
						selected = selected or eventData.restrictSquad[index]
					end
					squadFrame:SetSelected(selected)
					offset = offset + 8 / visibleSquads
				else
					visibleSquads = visibleSquads - 1
				end
			end
		else
			squadCheck:SetChecked(false)
		end
		
		CheckDefaultDescription()
		
		lastEventID = eventID
	end
	
	return popup
end

RegisterPopupConstructor(addonID .. ".Event", EventPopup)
