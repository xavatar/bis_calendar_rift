-- ***************************************************************************************************************************************************
-- * CalendarTab.lua                                                                                                                                 *
-- ***************************************************************************************************************************************************
-- * BiSCal calendar tab frame                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.5 / 2012.01.13 / Baanano: Extracted dialogs & custom grid cells                                                                             *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local DataGrid = Yague.DataGrid
local DeleteEvent = Internal.ModelView.DeleteEvent
local GetEventDetail = Internal.ModelView.GetEventDetail
local GetEventIcon = Internal.DefinitionsView.GetEventIcon
local GetEventList = Internal.ModelView.GetEventList
local GetEventName = Internal.DefinitionsView.GetEventName
local GetPermissions = Internal.ModelView.GetPermissions
local GetPlayerName = Internal.Utility.GetPlayerName
local GetSquadID = Internal.MemberList.GetID
local ITServer = Inspect.Time.Server
local L = Internal.Localization.L
local MFloor = math.floor
local ODate = os.date
local Panel = Yague.Panel
local PopupManager = Yague.PopupManager
local ScrollableText = Yague.ScrollableText
local ShadowedText = Yague.ShadowedText
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local UnsignEvent = Internal.ModelView.UnsignEvent
local next = next
local pairs = pairs
local unpack = unpack

Internal.UI = Internal.UI or {}

local function DurationFormatter(duration)
	local hours, minutes = MFloor(duration / 2), (duration % 2) * 30
	return (hours > 0 and hours .. L["CalendarTab/DurationHours"] or "") .. (hours > 0 and minutes > 0 and " " or "") .. (minutes > 0 and minutes .. L["CalendarTab/DurationMinutes"] or "")
end

local function DateFormatter(formatString, timestamp)
	local weekdayName = ({ L["Misc/WeekdayNames"]:match((L["Misc/WeekdayNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%w", timestamp)) + 1]
	local monthName = ({ L["Misc/MonthNames"]:match((L["Misc/MonthNames"]:gsub("[^,]*,", "([^,]*),"))) })[tonumber(ODate("%m", timestamp))]
	
	formatString = formatString:gsub("%%A", weekdayName)
	formatString = formatString:gsub("%%B", monthName)

	return ODate(formatString, timestamp)
end

function Internal.UI.CalendarTab(name, parent)
	local frame = Panel(name, parent)
	local frameContent = frame:GetContent()
	local popupManager = PopupManager(name .. ".PopupManager", frame)

	local infoFrame = UICreateFrame("Frame", name .. ".InfoFrame", frameContent)
	local calendarControl = Yague.Calendar(name .. ".CalendarControl", frameContent)
	local titleText = ShadowedText(name .. ".TitleText", infoFrame)
	local eventGrid = DataGrid(name .. ".EventGrid", infoFrame)
	local eventContent = eventGrid:GetContent()
	local eventPanel = Panel(name .. ".EventPanel", eventContent)
	local panelContent = eventPanel:GetContent()
	local panelBackdrop = UICreateFrame("Texture", name .. ".PanelBackdrop", panelContent)
	local eventFrame = UICreateFrame("Frame", name .. ".EventFrame", panelContent)
	local descriptionText = ScrollableText(name .. ".DescriptionText", eventFrame)
	local membersGrid = DataGrid(name .. ".MembersGrid", eventFrame)
	local joinButton = UICreateFrame("RiftButton", name .. ".JoinButton", eventFrame)
	local leaveButton = UICreateFrame("RiftButton", name .. ".LeaveButton", eventFrame)
	local newButton = UICreateFrame("RiftButton", name .. ".NewButton", eventContent)
	local modifyButton = UICreateFrame("RiftButton", name .. ".ModifyButton", eventContent)
	local deleteButton = UICreateFrame("RiftButton", name .. ".DeleteButton", eventContent)

	local function ReloadEvents()
		local events = GetEventList()
		local startTime = calendarControl:GetSelectedDate()
		local endTime = startTime + 24 * 60 * 60
		
		for eventID, eventData in pairs(events) do
			if eventData.timestamp < startTime or eventData.timestamp >= endTime then
				events[eventID] = nil
			else
				eventData.type = GetEventName(eventData.category, eventData.subcategory)
			end
		end
		
		eventGrid:SetData(nil, nil, nil, true)
		eventGrid:SetData(events)		
	end
	
	local function LoadCalendarData()
		local events = GetEventList()
		for eventID, eventData in pairs(events) do
			eventData.overlay = GetEventIcon(eventData.category, eventData.subcategory)
		end
		calendarControl:SetData(nil)
		calendarControl:SetData(events)
		ReloadEvents()
	end
	
	local function CheckPermissions()
		local permissions = GetPermissions()
		local eventID, eventData = eventGrid:GetSelectedData()
		local playerName = GetPlayerName()
		local squadID = GetSquadID(playerName)
		local expired = eventData and eventData.timestamp < ITServer()
		local calendarDate = calendarControl:GetSelectedDate()
		local author = eventData and eventData.author
		
		newButton:SetEnabled(squadID and permissions and permissions.addEvent and calendarDate + 24 * 60 * 60 > ITServer() and true or false)
		modifyButton:SetEnabled(squadID and permissions and (permissions.modifyEvent or (permissions.modifyOwnEvent and playerName == author)) and eventID and not expired and true or false)
		deleteButton:SetEnabled(squadID and permissions and(permissions.removeEvent or (permissions.removeOwnEvent and playerName == author)) and eventID and true or false)
		joinButton:SetEnabled(squadID and permissions and permissions.signEvent and eventID and not expired and true or false)
		leaveButton:SetEnabled(squadID and permissions and permissions.signEvent and eventID and not expired and true or false)
		
		if squadID and permissions and permissions.assignID and eventID and not expired then
			membersGrid:SetSelectedRowBackgroundColor({0, 0.4, 0.4, 0.35})
		else
			membersGrid:SetSelectedRowBackgroundColor({0.05, 0, 0.05, 0})
		end
		
		if eventID then
			local eventData = GetEventDetail(eventID)
			
			local officer = permissions and permissions.assignID and true or false
			local members = eventData and eventData.members and next(eventData.members) and true or false
			local found = eventData and eventData.members and eventData.members[squadID] and true or false
			local active = found or (officer and members)
			
			joinButton:SetText(active and L["CalendarTab/ButtonChange"] or L["CalendarTab/ButtonJoin"])
			leaveButton:SetEnabled(leaveButton:GetEnabled() and active)
		end
	end	
	
	infoFrame:SetPoint("TOPRIGHT", frameContent, "TOPRIGHT")
	infoFrame:SetPoint("BOTTOMLEFT", frameContent, "BOTTOMRIGHT", -400, 0)
	
	calendarControl:SetPoint("TOPLEFT", frameContent, "TOPLEFT", 5, 15)
	calendarControl:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMLEFT", -5, -10)
	calendarControl:SetWeekdays({ L["Misc/WeekdayNames"]:match((L["Misc/WeekdayNames"]:gsub("[^,]*,", "([^,]*),"))) })
	calendarControl:SetMonths({ L["Misc/MonthNames"]:match((L["Misc/MonthNames"]:gsub("[^,]*,", "([^,]*),"))) })
	calendarControl:SetMonthFormat(L["CalendarTab/MonthFormat"])
	calendarControl:SetHourFormat(Internal.AccountSettings.Use24Time and L["CalendarTab/HourFormat24"] or L["CalendarTab/HourFormat12"])
	calendarControl:SetStartOnMonday(Internal.AccountSettings.FirstWeekDayMonday)
	
	titleText:SetPoint("CENTER", infoFrame, "TOPCENTER", 0, 20)
	titleText:SetFontSize(18)
	titleText:SetFontColor(0.75, 0.75, 0.5)
	titleText:SetShadowOffset(2, 2)
	titleText:SetText(DateFormatter(L["CalendarTab/DateFormat"], calendarControl:GetSelectedDate()))
	
	eventGrid:SetPadding(2, 2, 2, 315)
	eventGrid:SetHeadersVisible(true)
	eventGrid:SetRowHeight(20)
	eventGrid:SetRowMargin(0)
	eventGrid:SetUnselectedRowBackgroundColor({0.05, 0, 0.05, 0})
	eventGrid:SetSelectedRowBackgroundColor({0, 0.4, 0.4, 0.35})
	eventGrid:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT", -5, 35)
	eventGrid:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", 0, -5)
	eventGrid:AddColumn("time", L["CalendarTab/ColumnTime"], "Text", 70, 0, "timestamp", true, { Alignment = "right", Formatter = function(timestamp) return DateFormatter(Internal.AccountSettings.Use24Time and L["CalendarTab/HourFormat24"] or L["CalendarTab/HourFormat12"], timestamp) end, Color = { 0.75, 0.75, 0.5 } })
	eventGrid:AddColumn("type", L["CalendarTab/ColumnEvent"], "Text", 50, 1, "type", true, { Alignment = "left", Formatter = "none" })
	eventGrid:AddColumn("duration", L["CalendarTab/ColumnDuration"], "Text", 70, 0, "duration", false, { Alignment = "right", Formatter = DurationFormatter, Color = { 0.75, 0.75, 0.5 } })
	eventGrid:SetOrder("time", false)
	eventGrid:GetInternalContent():SetBackgroundColor(0.05, 0, 0.05, 0.5)
	
	eventPanel:SetPoint("TOPLEFT", eventContent, "BOTTOMLEFT", 2, -313)
	eventPanel:SetPoint("BOTTOMRIGHT", eventContent, "BOTTOMRIGHT", -2, -30)
	eventPanel:SetInvertedBorder(true)
	
	panelBackdrop:SetAllPoints()
	panelBackdrop:SetTexture(addonID, "dummy")
	panelBackdrop:SetBackgroundColor(0, 0, 0, 0.75)
	panelBackdrop:SetLayer(5)
	
	eventFrame:SetAllPoints()
	eventFrame:SetBackgroundColor(0, 0.0375, 0.05, 0.95)
	eventFrame:SetLayer(10)
	
	descriptionText:SetPoint("TOPLEFT", eventFrame, "TOPLEFT", 10, 5)
	descriptionText:SetPoint("BOTTOMRIGHT", eventFrame, 1, 7/20, -10, -10)

	local function NameFormatter(memberData)
		return memberData and memberData.name or ""
	end
	

	local function NameColor(memberData)
		if memberData and memberData.roles then
			if memberData.roles.accepted then 
				return { 0, 1, 0 }
			elseif memberData.roles.rejected then
				return { 1, 0, 0 }
			else
				return { 1, 1, 1 }
			end
		end
		return { 0.4, 0.4, 0.4 }
	end
	
	local function RolesOrder(keyA, keyB, rolesA, rolesB)
		local orderA = not rolesA and 30 or ((rolesA.rejected and 20 or (rolesA.accepted and 0 or 10)) + (rolesA.declined and 3 or (rolesA.standby and 2 or 1)))
		local orderB = not rolesB and 30 or ((rolesB.rejected and 20 or (rolesB.accepted and 0 or 10)) + (rolesB.declined and 3 or (rolesB.standby and 2 or 1)))
		if orderA == orderB then return keyA < keyB end
		return orderA < orderB
	end
	
	membersGrid:SetPadding(1, 1, 1, 1)
	membersGrid:SetHeadersVisible(true)
	membersGrid:SetRowHeight(20)
	membersGrid:SetRowMargin(0)
	membersGrid:SetUnselectedRowBackgroundColor({0.05, 0, 0.05, 0})
	membersGrid:SetSelectedRowBackgroundColor({0.05, 0, 0.05, 0})
	membersGrid:SetPoint("TOPLEFT", eventFrame, 0, 7/20, 5, 0)
	membersGrid:SetPoint("BOTTOMRIGHT", eventFrame, "BOTTOMRIGHT", -5, -35)	
	membersGrid:AddColumn("squadID", L["CalendarTab/ColumnSquad"], addonID .. ".CalendarSquad", 70, 0, "squadID", true)
	membersGrid:AddColumn("name", L["CalendarTab/ColumnName"], "Text", 50, 1, nil, "name", { Alignment = "left", Formatter = NameFormatter, Color = NameColor, })
	membersGrid:AddColumn("roles", L["CalendarTab/ColumnRole"], addonID .. ".CalendarRole", 70, 0, "roles", RolesOrder)
	membersGrid:SetOrder("roles", false)
	membersGrid:GetInternalContent():SetBackgroundColor(0.05, 0, 0.05, 0.5)
	
	joinButton:SetPoint("BOTTOMRIGHT", eventFrame, "BOTTOMCENTER")
	joinButton:SetText(L["CalendarTab/ButtonJoin"])
	
	leaveButton:SetPoint("BOTTOMLEFT", eventFrame, "BOTTOMCENTER")
	leaveButton:SetText(L["CalendarTab/ButtonLeave"])
	
	newButton:SetPoint("BOTTOMCENTER", eventContent, 1/6, 1, 2, 2)
	newButton:SetText(L["CalendarTab/ButtonNew"])
	newButton:SetEnabled(false)
	
	modifyButton:SetPoint("BOTTOMCENTER", eventContent, 3/6, 1, 0, 2)
	modifyButton:SetText(L["CalendarTab/ButtonModify"])
	modifyButton:SetEnabled(false)
	
	deleteButton:SetPoint("BOTTOMCENTER", eventContent, 5/6, 1, -2, 2)
	deleteButton:SetText(L["CalendarTab/ButtonDelete"])
	deleteButton:SetEnabled(false)
	
	function calendarControl.Event:DateChanged(newDate)
		titleText:SetText(DateFormatter(L["CalendarTab/DateFormat"], newDate))
		ReloadEvents()
	end
	
	function eventGrid.Event:SelectionChanged(eventID, eventData)
		local fullEventData = eventID and GetEventDetail(eventID)
		if fullEventData then
			panelBackdrop:SetTexture(unpack(GetEventIcon(eventData.category, eventData.subcategory)))
			eventFrame:SetVisible(true)
			
			descriptionText:SetText(fullEventData.description or "")
			
			local playerName = GetPlayerName()
			local members = {}
			for memberID, roles in pairs(fullEventData.members) do repeat
				local name = fullEventData.memberNames[memberID]
				if name then
					if name:sub(1, 1) == "\000" then
						break
					end
				
					members[memberID] = { squadID = memberID, name = name, roles = roles, }
				end
			until true end
			membersGrid:SetData(members)
		else
			panelBackdrop:SetTexture(addonID, "dummy")
			eventFrame:SetVisible(false)
		end
		CheckPermissions()
	end
	
	newButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			popupManager:ShowPopup(addonID .. ".Event", nil, { timestamp = calendarControl:GetSelectedDate(), })
		end, newButton:GetName() .. ".OnLeftPress")
	
	modifyButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local eventID = eventGrid:GetSelectedData()
			local fullEventData = eventID and GetEventDetail(eventID)
			if eventID and fullEventData then
				popupManager:ShowPopup(addonID .. ".Event", eventID, fullEventData)
			end
		end, modifyButton:GetName() .. ".OnLeftPress")
	
	deleteButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local eventID = eventGrid:GetSelectedData()
			if eventID then
				DeleteEvent(eventID)
			end
		end, deleteButton:GetName() .. ".OnLeftPress")
	
	joinButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local eventID = eventGrid:GetSelectedData()
			if not eventID then return end

			local permissions = GetPermissions()
			local playerName = GetPlayerName()
			local memberID, memberData = membersGrid:GetSelectedData()
			
			popupManager:ShowPopup(addonID .. ".Join", eventID, permissions and permissions.assignID and memberData and memberData.name or playerName)
		end, joinButton:GetName() .. ".OnLeftPress")
	
	leaveButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local eventID = eventGrid:GetSelectedData()
			if not eventID then return end
			
			local permissions = GetPermissions()
			local playerName = GetPlayerName()
			local memberID, memberData = membersGrid:GetSelectedData()
			
			UnsignEvent(eventID, permissions and permissions.assignID and memberData and memberData.name or playerName)
		end, leaveButton:GetName() .. ".OnLeftPress")
	
	local function eventSink() end
	frame:EventAttach(Event.UI.Input.Mouse.Left.Click, eventSink, "dummy")
	frame:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, eventSink, "dummy")
	
	CEAttach(Event[addonID].Rank, CheckPermissions, addonID .. ".CalendarTab.OnRank")
	CEAttach(Event[addonID].Roster, CheckPermissions, addonID .. ".CalendarTab.OnRoster")	
	CEAttach(Event[addonID].MemberList, LoadCalendarData, addonID .. ".CalendarTab.OnMember")	
	CEAttach(Event[addonID].EventList, LoadCalendarData, addonID .. ".CalendarTab.OnEvent")	
	CEAttach(Event[addonID].Wall, LoadCalendarData, addonID .. ".CalendarTab.OnWall")	
	
	return frame
end
