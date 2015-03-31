-- ***************************************************************************************************************************************************
-- * OptionsTab.lua                                                                                                                                  *
-- ***************************************************************************************************************************************************
-- * Description                                                                                                                                     *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.3 / 2012.01.12 / Baanano: Added Interface options                                                                                           *
-- * 0.0.2 / 2012.01.12 / Odine: First version                                                                                                       *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local CMBroadcast = Command.Message.Broadcast
local ChangeSquads = Internal.ModelView.ChangeSquads
local ClearStorage = Internal.GSM.Clear
local DataGrid = Yague.DataGrid
local DeleteEvent = Internal.ModelView.DeleteEvent
local Dropdown = Yague.Dropdown
local GetEventList = Internal.ModelView.GetEventList
local GetEventName = Internal.DefinitionsView.GetEventName
local GetGuildSettings = Internal.ModelView.GetGuildSettings
local GetLanguages = Internal.Localization.GetLanguages
local GetPermissions = Internal.ModelView.GetPermissions
local GetPlayerName = Internal.Utility.GetPlayerName
local GetRoster = Internal.ModelView.GetRoster
local GetSquadIcon = Internal.DefinitionsView.GetSquadLargeIcon
local GetSquads = Internal.DefinitionsView.GetSquads
local GetStorageMax = Internal.GSM.GetMaximumStorage
local GetStorageSize = Internal.GSM.GetSize
local GetStorageUsed = Internal.GSM.GetUsedStorage
local GetThemes = Internal.DefinitionsView.GetThemes
local L = Internal.Localization.L
local MFloor = math.floor
local MMax = math.max
local MMin = math.min
local ODate = os.date
local OTime = os.time
local Panel = Yague.Panel
local ReloadGuildSettings = Internal.ModelView.ReloadGuildSettings
local RestoreDefaultGuildSettings = Internal.ModelView.RestoreDefaultGuildSettings
local SaveGuildSettings = Internal.ModelView.SaveGuildSettings
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local ipairs = ipairs
local next = next
local pairs = pairs
local pcall = pcall
local tonumber = tonumber
local unpack = unpack

local ENTRYNAME_GUILDSETTINGS = "BiSCalGuildSettings"
local ENTRYNAME_MEMBERLIST = "BiSCalMembers"
local ENTRYNAME_EVENTPREFIX = "BC2E"
local MESSAGE_GUILDSETTINGS = "BiSCalGuildSettingsChanged"

local function DateFormatter(formatString, timestamp)
	local weekdayName = ({ L["Misc/WeekdayNames"]:match((L["Misc/WeekdayNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%w", timestamp)) + 1]
	local monthName = ({ L["Misc/MonthNames"]:match((L["Misc/MonthNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%m", timestamp))]
	
	formatString = formatString:gsub("%%A", weekdayName)
	formatString = formatString:gsub("%%B", monthName)

	return ODate(formatString, timestamp)
end

local function InterfaceFrame(parent)
	local frame = UICreateFrame("Frame", parent:GetName() .. ".InterfaceConfigFrame", parent)

	local clockTitle = UICreateFrame("Text", frame:GetName() .. ".ClockTitle", frame)
	local clockDropdown = Dropdown(frame:GetName() .. ".ClockDropdown", frame)
	local weekTitle = UICreateFrame("Text", frame:GetName() .. ".WeekTitle", frame)
	local weekDropdown = Dropdown(frame:GetName() .. ".WeekDropdown", frame)
	local languageTitle = UICreateFrame("Text", frame:GetName() .. ".LanguageTitle", frame)
	local languageDropdown = Dropdown(frame:GetName() .. ".LanguageDropdown", frame)
	local warningText = UICreateFrame("Text", frame:GetName() .. ".WarningText", frame)

	clockTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 5)
	clockTitle:SetFontSize(14)
	clockTitle:SetText(L["ConfigInterface/ClockTitle"])
	
	weekTitle:SetPoint("TOPLEFT", clockTitle, "BOTTOMLEFT", 0, 30)
	weekTitle:SetFontSize(14)
	weekTitle:SetText(L["ConfigInterface/FirstWeekdayTitle"])
	
	languageTitle:SetPoint("TOPLEFT", weekTitle, "BOTTOMLEFT", 0, 30)
	languageTitle:SetFontSize(14)
	languageTitle:SetText(L["ConfigInterface/LanguageTitle"])
	
	local offset = MMax(MMax(clockTitle:GetWidth(), weekTitle:GetWidth()), languageTitle:GetWidth()) + 10
	
	clockDropdown:SetPoint("CENTERLEFT", clockTitle, "CENTERLEFT", offset, 0)
	clockDropdown:SetPoint("RIGHT", frame, "RIGHT")
	clockDropdown:SetHeight(32)
	clockDropdown:SetTextSelector("text")
	clockDropdown:SetOrderSelector("text")
	clockDropdown:SetValues(
	{
		[1] = { text = L["ConfigInterface/Clock12"], },
		[2] = { text = L["ConfigInterface/Clock24"], },
	})
	clockDropdown:SetSelectedKey(Internal.AccountSettings.Use24Time and 2 or 1)

	weekDropdown:SetPoint("CENTERLEFT", weekTitle, "CENTERLEFT", offset, 0)
	weekDropdown:SetPoint("RIGHT", frame, "RIGHT")
	weekDropdown:SetHeight(32)
	weekDropdown:SetTextSelector("text")
	weekDropdown:SetOrderSelector("text")
	weekDropdown:SetValues(
	{
		[1] = { text = L["ConfigInterface/FirstWeekdaySunday"], },
		[2] = { text = L["ConfigInterface/FirstWeekdayMonday"], },
	})
	weekDropdown:SetSelectedKey(Internal.AccountSettings.FirstWeekDayMonday and 2 or 1)

	languageDropdown:SetPoint("CENTERLEFT", languageTitle, "CENTERLEFT", offset, 0)
	languageDropdown:SetPoint("RIGHT", frame, "RIGHT")
	languageDropdown:SetHeight(32)
	languageDropdown:SetOrderSelector(true)
	local languages = GetLanguages()
	languageDropdown:SetValues(languages)
	if languages[Internal.AccountSettings.Language] then
		languageDropdown:SetSelectedKey(Internal.AccountSettings.Language)
	end

	-- SetSelectedKey(key)
	-- when you prepare the dropdown you use SetValues({ ["key1"] = { valueField1 = "xxx", ... }, ["keyN"] = { ... } })
	-- to have it select an specific item you'd use SetSelectedKey("key1"), for example	
	
	warningText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -5)
	warningText:SetPoint("RIGHT", frame, "RIGHT")
	warningText:SetFontSize(14)
	warningText:SetWordwrap(true)
	warningText:SetText(L["ConfigInterface/Warning"])
	
	function clockDropdown.Event:SelectionChanged(key)
		Internal.AccountSettings.Use24Time = key == 2 and true or false
	end
	
	function weekDropdown.Event:SelectionChanged(key)
		Internal.AccountSettings.FirstWeekDayMonday = key == 2 and true or false
	end
	
	function languageDropdown.Event:SelectionChanged(key)
		Internal.AccountSettings.Language = key
	end
	
	return frame
end

local function GuildFrame(parent)
	local frame = UICreateFrame("Frame", parent:GetName() .. ".GuildConfigFrame", parent)
	
	local wallPostCheckbox = UICreateFrame("RiftCheckbox", frame:GetName() .. ".StorageOfficerCheckbox", frame)
	local wallPostTitle = UICreateFrame("Text", frame:GetName() .. ".StorageOfficerTitle", frame)
	local storageLimitTitle = UICreateFrame("Text", frame:GetName() .. ".StorageLimitTitle", frame)
	local storageLimitSlider = UICreateFrame("RiftSlider", frame:GetName() .. ".StorageLimitSlider", frame)
	local storageLimitValue = UICreateFrame("Text", frame:GetName() .. ".StorageLimitValue", frame)
	local squadNumberTitle = UICreateFrame("Text", frame:GetName() .. ".SquadNumberTitle", frame)
	local squadNumberSlider = UICreateFrame("RiftSlider", frame:GetName() .. ".SquadNumberSlider", frame)
	local squadNumberValue = UICreateFrame("Text", frame:GetName() .. ".SquadNumberValue", frame)
	local squadsFrame = UICreateFrame("Frame", frame:GetName() .. ".SquadsFrame", frame)
	local squadFrames = {}
	local themeTitle = UICreateFrame("Text", frame:GetName() .. ".ThemeTitle", frame)
	local themeDropdown = Dropdown(frame:GetName() .. ".ThemeDropdown", frame)
	local themeButton = UICreateFrame("RiftButton", frame:GetName() .. ".ThemeButton", frame)
	local reloadButton = UICreateFrame("RiftButton", frame:GetName() .. ".ReloadButton", frame)
	local saveButton = UICreateFrame("RiftButton", frame:GetName() .. ".SaveButton", frame)
	local defaultButton = UICreateFrame("RiftButton", frame:GetName() .. ".DefaultButton", frame)
	
	local function ReloadSettings()
		local guildSettings = GetGuildSettings()
		
		wallPostCheckbox:SetChecked(guildSettings.PostEventsToWall)
		storageLimitSlider:SetPosition(guildSettings.StorageLimit)
		squadNumberSlider:SetPosition(guildSettings.SquadNumber)
		
		for index, squadPanel in ipairs(squadFrames) do
			squadPanel:SetSquad(guildSettings.Squads[index])
		end
	end
	
	local function CheckPermissions()
		local permissions = GetPermissions()

		local enable = permissions and permissions.assignID and true or false 
		local alpha = enable and 1 or 0.5
		
		wallPostTitle:SetAlpha(alpha)
		storageLimitValue:SetAlpha(alpha)
		storageLimitTitle:SetAlpha(alpha)
		squadNumberTitle:SetAlpha(alpha)
		squadNumberValue:SetAlpha(alpha)
		themeTitle:SetAlpha(alpha)

		wallPostCheckbox:SetEnabled(enable)
		storageLimitSlider:SetEnabled(enable)
		squadNumberSlider:SetEnabled(enable)
		themeDropdown:SetEnabled(enable)
		
		themeButton:SetEnabled(enable)
		saveButton:SetEnabled(enable)
		defaultButton:SetEnabled(enable)
		
		for i = 1, 8 do
			squadFrames[i]:SetEnabled(enable)
		end
	end	
	
	local function CollectSettings()
		local settings = {}
		
		settings.PostEventsToWall = wallPostCheckbox:GetChecked()
		settings.StorageLimit = storageLimitSlider:GetPosition()
		settings.SquadNumber = squadNumberSlider:GetPosition()
		settings.Squads = {}
		
		for index, squadPanel in ipairs(squadFrames) do
			settings.Squads[index] = squadPanel:GetSquad()
		end
		
		return settings
	end
	
	wallPostCheckbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 5)
	
	wallPostTitle:SetPoint("CENTERLEFT", wallPostCheckbox, "CENTERRIGHT", 5, 0)
	wallPostTitle:SetFontSize(14)
	wallPostTitle:SetText(L["ConfigGuild/WallPostTitle"])
	
	storageLimitTitle:SetPoint("TOPLEFT", wallPostCheckbox, "BOTTOMLEFT", 0, 20)
	storageLimitTitle:SetFontSize(14)
	storageLimitTitle:SetText(L["ConfigGuild/StorageLimitTitle"])
	
	storageLimitValue:SetPoint("CENTERY", storageLimitTitle, "CENTERY")
	storageLimitValue:SetPoint("RIGHT", frame, "RIGHT")
	storageLimitValue:SetFontSize(13)
	storageLimitValue:SetText(L["ConfigGuild/StorageLimitFormat"]:format(storageLimitSlider:GetPosition() * 512))
	
	squadNumberTitle:SetPoint("TOPLEFT", storageLimitTitle, "BOTTOMLEFT", 0, 20)
	squadNumberTitle:SetFontSize(14)
	squadNumberTitle:SetText(L["ConfigGuild/SquadNumberTitle"])
	
	squadNumberValue:SetPoint("CENTERY", squadNumberTitle, "CENTERY")
	squadNumberValue:SetPoint("RIGHT", frame, "RIGHT")
	squadNumberValue:SetFontSize(13)
	squadNumberValue:SetText(L["ConfigGuild/SquadNumberFormat"]:format(8))
	
	local offset = MMax(storageLimitTitle:GetWidth(), squadNumberTitle:GetWidth()) + 20
	
	storageLimitSlider:SetPoint("CENTERLEFT", storageLimitTitle, "CENTERLEFT", offset, 7)
	storageLimitSlider:SetPoint("CENTERRIGHT", storageLimitValue, "CENTERRIGHT", -100, 7)
	storageLimitSlider:SetRange(1, 16)
	
	squadNumberSlider:SetPoint("CENTERLEFT", squadNumberTitle, "CENTERLEFT", offset, 7)
	squadNumberSlider:SetPoint("CENTERRIGHT", squadNumberValue, "CENTERRIGHT", -100, 7)
	squadNumberSlider:SetRange(0, 3)
	squadNumberSlider:SetPosition(3)
	
	squadsFrame:SetPoint("TOPLEFT", squadNumberTitle, "BOTTOMLEFT", 25, 15)
	squadsFrame:SetPoint("BOTTOMCENTER", frame, "BOTTOMCENTER", 0, -90)
	
	for index = 1, 8 do
		local column = (index - 1) % 4
		local row = MFloor((index - 1) / 4)

		local squadPanel = Panel(squadsFrame:GetName() .. ".Squads." .. index, squadsFrame)
		local squadContent = squadPanel:GetContent()
		local squadDropdown = Dropdown(squadPanel:GetName() .. ".Dropdown", squadsFrame)
		local squadTexture = UICreateFrame("Texture", squadPanel:GetName() .. ".Texture", squadContent)
		
		squadPanel:SetPoint("TOPCENTER", squadsFrame, (column + 0.5) / 4, row / 2)
		squadPanel:SetWidth(68)
		squadPanel:SetHeight(68)
		squadPanel:SetInvertedBorder(true)
		
		squadDropdown:SetPoint("TOPLEFT", squadsFrame, column / 4, row / 2, 5, 71)
		squadDropdown:SetPoint("TOPRIGHT", squadsFrame, (column + 1) / 4, row / 2, -5, 71)
		squadDropdown:SetHeight(30)
		squadDropdown:SetTextSelector("name")
		squadDropdown:SetOrderSelector("name")
		squadDropdown:SetValues(GetSquads())
		
		squadTexture:SetAllPoints()
		squadTexture:SetBackgroundColor(0, 0, 0, 1)
		
		function squadDropdown.Event:SelectionChanged(squad)
			squadTexture:SetTextureAsync(unpack(GetSquadIcon(squad)))
		end
		
		function squadPanel:GetSquad()
			return (squadDropdown:GetSelectedValue())
		end
		
		function squadPanel:SetSquad(squad)
			squadDropdown:SetSelectedKey(squad)
		end
		
		function squadPanel:SetHidden(hide)
			squadPanel:SetVisible(not hide)
			squadDropdown:SetVisible(not hide)
		end
		
		function squadPanel:SetEnabled(enable)
			squadDropdown:SetEnabled(enable)
			squadTexture:SetAlpha(enable and 1 or 0.5)
		end
		
		squadFrames[index] = squadPanel
	end
	
	themeTitle:SetPoint("CENTERLEFT", squadsFrame, "BOTTOMLEFT", -15, 20)
	themeTitle:SetFontSize(14)
	themeTitle:SetText(L["ConfigGuild/ThemeTitle"])
	
	themeDropdown:SetPoint("CENTERLEFT", themeTitle, "CENTERRIGHT", 10, 0)
	themeDropdown:SetPoint("CENTERRIGHT", themeButton, "CENTERLEFT", -10, 0)
	themeDropdown:SetHeight(32)
	themeDropdown:SetReverseUnfold(true)
	themeDropdown:SetTextSelector("name")
	themeDropdown:SetOrderSelector("name")
	themeDropdown:SetValues(GetThemes())
	
	themeButton:SetPoint("CENTERRIGHT", squadsFrame, "BOTTOMRIGHT", 15, 20)
	themeButton:SetText(L["ConfigGuild/ThemeButton"])
	
	reloadButton:SetPoint("BOTTOMCENTER", frame, 1/4, 1, 0, -5)
	reloadButton:SetText(L["ConfigGuild/ReloadButton"])
	
	saveButton:SetPoint("BOTTOMCENTER", frame, 2/4, 1, 0, -5)
	saveButton:SetText(L["ConfigGuild/SaveButton"])
	saveButton:SetEnabled(false)
	
	defaultButton:SetPoint("BOTTOMCENTER", frame, 3/4, 1, 0, -5)
	defaultButton:SetText(L["ConfigGuild/DefaultButton"])
	defaultButton:SetEnabled(false)
	
	storageLimitSlider:EventAttach(Event.UI.Input.Mouse.Wheel.Forward,
		function()
			local minRange, maxRange = storageLimitSlider:GetRange()
			storageLimitSlider:SetPosition(MMin(storageLimitSlider:GetPosition() + 1, maxRange))
		end, storageLimitSlider:GetName() .. ".OnWheelForward")
	
	storageLimitSlider:EventAttach(Event.UI.Input.Mouse.Wheel.Back,
		function()
			local minRange, maxRange = storageLimitSlider:GetRange()
			storageLimitSlider:SetPosition(MMax(storageLimitSlider:GetPosition() - 1, minRange))
		end, storageLimitSlider:GetName() .. ".OnWheelBack")
	
	squadNumberSlider:EventAttach(Event.UI.Input.Mouse.Wheel.Forward,
		function()
			local minRange, maxRange = squadNumberSlider:GetRange()
			squadNumberSlider:SetPosition(MMin(squadNumberSlider:GetPosition() + 1, maxRange))
		end, squadNumberSlider:GetName() .. ".OnWheelForward")
	
	squadNumberSlider:EventAttach(Event.UI.Input.Mouse.Wheel.Back,
		function()
			local minRange, maxRange = squadNumberSlider:GetRange()
			squadNumberSlider:SetPosition(MMax(squadNumberSlider:GetPosition() - 1, minRange))
		end, squadNumberSlider:GetName() .. ".OnWheelBack")
	
	storageLimitSlider:EventAttach(Event.UI.Slider.Change,
		function()
			storageLimitValue:SetText(L["ConfigGuild/StorageLimitFormat"]:format(storageLimitSlider:GetPosition() * 512))
		end, storageLimitSlider:GetName() .. ".OnSliderChange")
	
	squadNumberSlider:EventAttach(Event.UI.Slider.Change,
		function()
			local squadNumber = 2 ^ squadNumberSlider:GetPosition()
			squadNumberValue:SetText(L["ConfigGuild/SquadNumberFormat"]:format(squadNumber))
			for index, squadPanel in ipairs(squadFrames) do
				squadPanel:SetHidden(index > squadNumber)
			end
		end, squadNumberSlider:GetName() .. ".OnSliderChange")
	
	themeButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local theme, themeData = themeDropdown:GetSelectedValue()
			squadNumberSlider:SetPosition(themeData.number)
			for index, squad in ipairs(themeData.squads) do
				squadFrames[index]:SetSquad(squad)
			end
		end, themeButton:GetName() .. ".OnLeftPress")
	
	reloadButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			ReloadGuildSettings()
		end, reloadButton:GetName() .. ".OnLeftPress")
	
	saveButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			SaveGuildSettings(CollectSettings())
		end, saveButton:GetName() .. ".OnLeftPress")
	
	defaultButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			RestoreDefaultGuildSettings()
		end, defaultButton:GetName() .. ".OnLeftPress")

	CEAttach(Event[addonID].Roster, CheckPermissions, addonID .. ".OptionsTab.Guild.OnRoster")
	CEAttach(Event[addonID].Rank, CheckPermissions, addonID .. ".OptionsTab.Guild.OnRank")
	CEAttach(Event[addonID].GuildSettings, ReloadSettings, addonID .. ".OptionsTab.Guild.OnGuildSettings")
	
	ReloadSettings()
	CheckPermissions()
	
	return frame
end

local function MaintenanceFrame(parent)
	local frame = UICreateFrame("Frame", parent:GetName() .. ".MaintenanceConfigFrame", parent)
	
	local storagePanel = Panel(frame:GetName() .. ".StoragePanel", frame)
	local storageContent = storagePanel:GetContent()
	local addonStorageBar = UICreateFrame("Frame", frame:GetName() .. ".AddonStorageBar", storageContent)
	local othersStorageBar = UICreateFrame("Frame", frame:GetName() .. ".OthersStorageBar", storageContent)
	local limitStorageBar = UICreateFrame("Frame", frame:GetName() .. ".LimitStorageBar", storageContent)
	local guildSettingsTitle = UICreateFrame("Text", frame:GetName() .. ".GuildSettingsTitle", frame)
	local guildSettingsValue = UICreateFrame("Text", frame:GetName() .. ".GuildSettingsValue", frame)
	local guildSettingsClear = UICreateFrame("RiftButton", frame:GetName() .. ".GuildSettingsClear", frame)
	local squadsTitle = UICreateFrame("Text", frame:GetName() .. ".SquadsTitle", frame)
	local squadsValue = UICreateFrame("Text", frame:GetName() .. ".SquadsValue", frame)
	local squadsDeleteOld = UICreateFrame("RiftButton", frame:GetName() .. ".SquadsDeleteOld", frame)
	local squadsClear = UICreateFrame("RiftButton", frame:GetName() .. ".SquadsClear", frame)
	local eventGrid = DataGrid(frame:GetName() .. ".EventGrid", frame)
	local eventContent = eventGrid:GetContent()
	local eventFrame = UICreateFrame("Frame", frame:GetName() .. ".EventFrame", eventContent)
	local eventDeleteSelected = UICreateFrame("RiftButton", frame:GetName() .. ".EventDeleteSelected", eventFrame)
	local eventDeleteExpired = UICreateFrame("RiftButton", frame:GetName() .. ".EventDeleteExpired", eventFrame)
	local eventDeleteAll = UICreateFrame("RiftButton", frame:GetName() .. ".EventDeleteAll", eventFrame)
	local resetAddon = UICreateFrame("RiftButton", frame:GetName() .. ".ResetAddon", frame)
	
	local refreshPermissions = true
	local refreshStorage = true
	
	local function RefreshDelete()
		local permissions = GetPermissions() or {}
		local eventID, eventData = eventGrid:GetSelectedData()
		local playerName = GetPlayerName()
		local author = eventData and eventData.author
		eventDeleteSelected:SetEnabled((permissions.removeEvent or (permissions.removeOwnEvent and playerName == author)) and eventID and true or false)
	end
	
	local function RefreshPermissions()
		refreshPermissions = false
		
		local permissions = GetPermissions() or {}
		local guildSettingsSize = GetStorageSize(ENTRYNAME_GUILDSETTINGS) or 0
		local squadsSize = GetStorageSize(ENTRYNAME_MEMBERLIST) or 0
		
		local playerName = GetPlayerName()
		local events = GetEventList() or {}
		local canRemove = permissions.removeEvent and next(events) and true or false
		local expired = false
		local currentTime = OTime()
		for eventID, eventData in pairs(events) do
			canRemove = canRemove or (permissions.removeOwnEvent and eventData.author == playerName)
			expired = expired or (currentTime > eventData.timestamp and (permissions.removeEvent or (permissions.removeOwnEvent and eventData.author == playerName)))
		end
		
		guildSettingsClear:SetEnabled(permissions.assignID and guildSettingsSize > 0 and true or false)
		squadsDeleteOld:SetEnabled(permissions.assignID and squadsSize > 0 and true or false)
		squadsClear:SetEnabled(permissions.assignID and squadsSize > 0 and true or false)
		eventDeleteExpired:SetEnabled(expired and true or false)
		eventDeleteAll:SetEnabled(canRemove and true or false)
		resetAddon:SetEnabled(permissions.assignID and permissions.removeEvent and true or false)
		
		RefreshDelete()
	end
	
	local function RefreshStorage()
		refreshStorage = false
		
		local guildSettingsSize = GetStorageSize(ENTRYNAME_GUILDSETTINGS) or 0
		local squadsSize = GetStorageSize(ENTRYNAME_MEMBERLIST) or 0
		local totalSize = guildSettingsSize + squadsSize
		
		local events = GetEventList() or {}
		for eventID, eventData in pairs(events) do
			local eventSize = GetStorageSize(ENTRYNAME_EVENTPREFIX .. ("%X"):format(eventID)) or 0
			totalSize = totalSize + eventSize
			
			eventData.size = eventSize
			eventData.type = GetEventName(eventData.category, eventData.subcategory)
		end
		eventGrid:SetData(events)
		
		local maxSize = GetStorageMax()
		local addonFactor = MMin(MMax(totalSize / maxSize, 0), 100)
		local othersFactor = MMin(MMax((GetStorageUsed() - totalSize) / maxSize, 0), 100)

		local barWidth = storageContent:GetWidth()
		addonStorageBar:SetWidth(addonFactor * barWidth)
		othersStorageBar:SetWidth(othersFactor * barWidth)
		
		local limitSize = GetGuildSettings().StorageLimit * 512
		limitStorageBar:SetPoint("TOPCENTER", storageContent, limitSize / maxSize, 0)
		
		guildSettingsValue:SetText(L["ConfigMaintenance/SizeFormat"]:format(guildSettingsSize))
		squadsValue:SetText(L["ConfigMaintenance/SizeFormat"]:format(squadsSize))
		
		RefreshPermissions()
	end
	
	storagePanel:SetPoint("TOPLEFT", frame, "TOPLEFT")
	storagePanel:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 36)
	storagePanel:SetInvertedBorder(true)
	storageContent:SetBackgroundColor(0, 0, 0, 1)
	
	addonStorageBar:SetPoint("TOPLEFT", storageContent, "TOPLEFT")
	addonStorageBar:SetPoint("BOTTOMLEFT", storageContent, "BOTTOMLEFT")
	addonStorageBar:SetWidth(0)
	addonStorageBar:SetBackgroundColor(0, 0.85, 0, 1)
	
	othersStorageBar:SetPoint("TOPRIGHT", storageContent, "TOPRIGHT")
	othersStorageBar:SetPoint("BOTTOMRIGHT", storageContent, "BOTTOMRIGHT")
	othersStorageBar:SetWidth(0)
	othersStorageBar:SetBackgroundColor(1, 1, 0, 1)
	
	limitStorageBar:SetPoint("TOPCENTER", storageContent, 1/2, 0)
	limitStorageBar:SetWidth(2)
	limitStorageBar:SetHeight(storageContent:GetHeight())
	limitStorageBar:SetBackgroundColor(1, 0, 0, 1)
	
	guildSettingsTitle:SetPoint("TOPLEFT", storagePanel, "BOTTOMLEFT", 5, 20)
	guildSettingsTitle:SetFontColor(1, 1, 0.75)
	guildSettingsTitle:SetText(L["ConfigMaintenance/GuildSettingsTitle"])
	
	guildSettingsClear:SetPoint("RIGHT", storagePanel, "CENTERX")
	guildSettingsClear:SetPoint("CENTERY", guildSettingsTitle, "CENTERY")
	guildSettingsClear:SetText(L["ConfigMaintenance/GuildSettingsClear"])
	
	guildSettingsValue:SetPoint("CENTERRIGHT", guildSettingsClear, "CENTERLEFT", -5, 0)
	
	squadsTitle:SetPoint("CENTERLEFT", guildSettingsClear, "CENTERRIGHT", 5, 0)
	squadsTitle:SetFontColor(1, 1, 0.75)
	squadsTitle:SetText(L["ConfigMaintenance/SquadsTitle"])
	
	squadsDeleteOld:SetPoint("RIGHT", storagePanel, "RIGHT")
	squadsDeleteOld:SetPoint("CENTERY", squadsTitle, "CENTERY")
	squadsDeleteOld:SetText(L["ConfigMaintenance/SquadsDeleteOld"])
	
	squadsClear:SetPoint("TOPCENTER", squadsDeleteOld, "BOTTOMCENTER")
	squadsClear:SetText(L["ConfigMaintenance/SquadsClear"])
	
	squadsValue:SetPoint("CENTERRIGHT", squadsDeleteOld, "CENTERLEFT", -10, 0)
	
	eventGrid:SetPadding(2, 2, 2, 36)
	eventGrid:SetHeadersVisible(true)
	eventGrid:SetRowHeight(20)
	eventGrid:SetRowMargin(0)
	eventGrid:SetUnselectedRowBackgroundColor({0.05, 0, 0.05, 0})
	eventGrid:SetSelectedRowBackgroundColor({0, 0.4, 0.4, 0.35})
	eventGrid:SetPoint("TOPRIGHT", squadsClear, "BOTTOMRIGHT", 0, 10)
	eventGrid:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -36)
	eventGrid:AddColumn("date", L["ConfigMaintenance/EventsColumnDate"], "Text", 120, 0, "timestamp", true, { Alignment = "right", Formatter = function(timestamp) return DateFormatter(Internal.AccountSettings.Use24Time and L["ConfigMaintenance/DateFormat24"] or L["ConfigMaintenance/DateFormat12"], timestamp) end, Color = { 0.75, 0.75, 0.5 } })
	eventGrid:AddColumn("eventName", L["ConfigMaintenance/EventsColumnEvent"], "Text", 140, 1, "type", true, { Alignment = "left", Formatter = "none" })
	eventGrid:AddColumn("size", L["ConfigMaintenance/EventsColumnSize"], "Text", 80, 0, "size", true, { Alignment = "right", Formatter = function(size) return L["ConfigMaintenance/SizeFormat"]:format(size) end, Color = { 0.75, 0.75, 0.5 } })
	eventGrid:SetOrder("date", false)	
	eventGrid:GetInternalContent():SetBackgroundColor(0.05, 0, 0.05, 0.5)
	
	eventFrame:SetPoint("TOPLEFT", eventContent, "BOTTOMLEFT", 5, -34)
	eventFrame:SetPoint("BOTTOMRIGHT", eventContent, "BOTTOMRIGHT", -5, -2)
	
	eventDeleteSelected:SetPoint("CENTERRIGHT", eventFrame, "CENTERRIGHT")
	eventDeleteSelected:SetText(L["ConfigMaintenance/EventsClearSelected"])
	
	eventDeleteExpired:SetPoint("CENTERLEFT", eventFrame, "CENTERLEFT")
	eventDeleteExpired:SetText(L["ConfigMaintenance/EventsClearExpired"])
	
	eventDeleteAll:SetPoint("CENTERLEFT", eventDeleteExpired, "CENTERRIGHT")
	eventDeleteAll:SetText(L["ConfigMaintenance/EventsClearAll"])
	
	resetAddon:SetPoint("BOTTOMCENTER", frame, "BOTTOMCENTER", 0, 4)
	resetAddon:SetText(L["ConfigMaintenance/ResetAll"])

	storageContent:EventAttach(Event.UI.Layout.Size,
		function()
			refreshStorage = true
		end, storageContent:GetName() .. ".OnSize")
	
	function eventGrid.Event:SelectionChanged()
		RefreshDelete()
	end
	
	guildSettingsClear:EventAttach(Event.UI.Button.Left.Press,
		function()
			ClearStorage(ENTRYNAME_GUILDSETTINGS, function() CMBroadcast("guild", nil, MESSAGE_GUILDSETTINGS, "dummy") end)
		end, guildSettingsClear:GetName() .. ".OnLeftPress")
	
	squadsClear:EventAttach(Event.UI.Button.Left.Press,
		function()
			ChangeSquads({})
		end, squadsClear:GetName() .. ".OnLeftPress")
	
	squadsDeleteOld:EventAttach(Event.UI.Button.Left.Press,
		function()
			local cleanSquads = {}
			for memberName, memberData in pairs(GetRoster() or {}) do
				if memberData.squadID then
					cleanSquads[memberData.squadID] = memberName
				end
			end
			ChangeSquads(cleanSquads)
		end, squadsDeleteOld:GetName() .. ".OnLeftPress")
	
	eventDeleteSelected:EventAttach(Event.UI.Button.Left.Press,
		function()
			local eventID = eventGrid:GetSelectedData()
			if eventID then
				DeleteEvent(eventID)
			end
		end, eventDeleteSelected:GetName() .. ".OnLeftPress")
	
	eventDeleteAll:EventAttach(Event.UI.Button.Left.Press,
		function()
			for eventID in pairs(GetEventList() or {}) do
				DeleteEvent(eventID)
			end
		end, eventDeleteAll:GetName() .. ".OnLeftPress")
	
	eventDeleteExpired:EventAttach(Event.UI.Button.Left.Press,
		function()
			local currentTime = OTime()
			for eventID, eventData in pairs(GetEventList() or {}) do
				if currentTime > eventData.timestamp then
					DeleteEvent(eventID)
				end
			end
		end, eventDeleteExpired:GetName() .. ".OnLeftPress")
	
	resetAddon:EventAttach(Event.UI.Button.Left.Press,
		function()
			local events = GetEventList()
			for eventID in pairs(events) do
				DeleteEvent(eventID)
			end

			local clearError = function() CMBroadcast("guild", nil, MESSAGE_GUILDSETTINGS, "dummy") end
			local clearSuccess = function() CMBroadcast("guild", nil, MESSAGE_GUILDSETTINGS, "dummy") end
			local clearGuildSettings = function() ClearStorage(ENTRYNAME_GUILDSETTINGS, clearSuccess, clearError, clearSuccess) end
			ClearStorage(ENTRYNAME_MEMBERLIST, clearGuildSettings, clearError, clearGuildSettings)
		end, resetAddon:GetName() .. ".OnLeftPress")
	
	local function OnUpdate()
		if refreshPermissions then
			RefreshPermissions()
		end
		if refreshStorage then
			RefreshStorage()
		end
	end
	CEAttach(Event.System.Update.Begin, OnUpdate, addonID .. ".OptionsTab.Maintenance.OnUpdate")
	
	local function OnPermissions()
		refreshPermissions = true
	end
	CEAttach(Event[addonID].Roster, OnPermissions, addonID .. ".OptionsTab.Maintenance.OnRoster")
	CEAttach(Event[addonID].Rank, OnPermissions, addonID .. ".OptionsTab.Maintenance.OnRank")
	
	local function OnStorage()
		refreshStorage = true
	end
	Internal.GSM.StartMonitoring(".", false, OnStorage)
	
	return frame
end

Internal.UI = Internal.UI or {}
function Internal.UI.OptionsTab(name, parent)
	local frame = Panel(name, parent)
	local frameContent = frame:GetContent()
	
	local menu = DataGrid(name .. ".Menu", frameContent)
	local configArea = UICreateFrame("Mask", name .. ".ConfigArea", frameContent)
	
	local lastShownFrame = nil
	
	menu:SetRowHeight(26)
	menu:SetSelectedRowBackgroundColor({0, 0.4, 0.4, 0.35})
	menu:SetPoint("TOPLEFT", frameContent, "TOPLEFT", 5, 5)
	menu:SetPoint("BOTTOMRIGHT", frameContent, "BOTTOMLEFT", 245, -5)
	menu:AddColumn("title", nil, "Text", 200, 1, "title", false, { FontSize = 16, Color = { 1, 1, 0.75, } })
	menu:AddColumn("order", nil, "Text", 0, 0, "order", true)
	menu:GetInternalContent():SetBackgroundColor(0.05, 0, 0.05, 0.5)

	configArea:SetPoint("TOPLEFT", frameContent, "TOPLEFT", 250, 10)
	configArea:SetPoint("BOTTOMRIGHT", frameContent, "BOTTOMRIGHT", -5, -10)	
	
	function menu.Event:SelectionChanged(selectedKey, selectedValue)
		if not selectedKey then return end
		
		if lastShownFrame then
			lastShownFrame:SetVisible(false)
		end
		
		lastShownFrame = selectedValue.frame

		if lastShownFrame then
			lastShownFrame:SetAllPoints()
			lastShownFrame:SetVisible(true)
		end
	end

	local baseMenu =
	{
		{ title = L["ConfigMenu/Interface"], order = 1, frame = InterfaceFrame(configArea) },
		{ title = L["ConfigMenu/Guild"], order = 2, frame = GuildFrame(configArea) },
		{ title = L["ConfigMenu/Maintenance"], order = 3, frame = MaintenanceFrame(configArea) },
	}
	
	for pluginID, pluginData in pairs(Internal.Plugin.GetPlugins()) do
		if pluginData.configConstructor then
			local ok, configFrame = pcall(pluginData.configConstructor, configArea)
			if ok and configFrame then
				TInsert(baseMenu, { title = pluginData.configName, order = #baseMenu + 1, frame = configFrame })
			else
				print(L["Plugin/ErrorMessage"]:format(pluginID, configFrame or L["Plugin/ErrorNoConfig"]))
			end
		end
	end
	
	menu:SetData(baseMenu)

	local function eventSink() end
	frame:EventAttach(Event.UI.Input.Mouse.Left.Click, eventSink, "dummy")
	frame:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, eventSink, "dummy")

	return frame
end