-- ***************************************************************************************************************************************************
-- * SquadsTab.lua                                                                                                                                   *
-- ***************************************************************************************************************************************************
-- * BiSCal Squads tab frame                                                                                                                         *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.6 / 2012.01.13 / Baanano: Localization ready                                                                                                *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local AssignSquadID = Internal.ModelView.AssignSquadID
local AutocompleteTextfield = Yague.AutocompleteTextfield
local CEAttach = Command.Event.Attach
local ChangeSquads = Internal.ModelView.ChangeSquads
local DataGrid = Yague.DataGrid
local FreeSquadID = Internal.ModelView.FreeSquadID
local GetPermissions = Internal.ModelView.GetPermissions
local GetRoster = Internal.ModelView.GetRoster
local GetSquadLargeIcon = Internal.ModelView.GetSquadLargeIcon
local GetSquadSize = Internal.ModelView.GetSquadSize
local GetSquads = Internal.ModelView.GetAllSquadIDs
local GetSquadsNumber = Internal.ModelView.GetSquadsNumber
local L = Internal.Localization.L
local Panel = Yague.Panel
local PopupManager = Yague.PopupManager
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local ipairs = ipairs
local pairs = pairs
local unpack = unpack

Internal.UI = Internal.UI or {}

function Internal.UI.SquadsTab(name, parent)
	local frame = Panel(name, parent)
	local frameContent = frame:GetContent()
	local popupManager = PopupManager(name .. ".PopupManager", frame)
	local squadPanels = {}
	local squadGrid = DataGrid(name .. ".SquadGrid", frameContent)
	local gridContent = squadGrid:GetContent()
	local assignFrame = UICreateFrame("Frame", name .. ".AssignFrame", gridContent)
	local assignTextfield = AutocompleteTextfield(assignFrame:GetName() .. ".AssignTextfield", assignFrame)
	local assignButton = UICreateFrame("RiftButton", assignFrame:GetName() .. ".AssignButton", assignFrame)
	local autoButton = UICreateFrame("RiftButton", assignFrame:GetName() .. ".AutoButton", assignFrame)
	local resetButton = UICreateFrame("RiftButton", assignFrame:GetName() .. ".ResetButton", assignFrame)
	
	local selectedSquad = nil
	
	local function ResetAssignButtons()
		local permissions = GetPermissions()
		local squadID, squadData = squadGrid:GetSelectedData()
		assignButton:SetEnabled(permissions and permissions.assignID and squadID and (squadData.assigned or (assignTextfield:GetText()):gsub("%A", "") ~= "") and true or false)
		autoButton:SetEnabled(permissions and permissions.assignID and true or false)
		resetButton:SetEnabled(permissions and permissions.assignID and true or false)
	end
	
	local function LoadSquad()
		if not selectedSquad then return end
		
		local squads = GetSquads() or {}
		local squadSize = GetSquadSize()
		
		local data = {}
		for index = (selectedSquad - 1) * squadSize, selectedSquad * squadSize - 1 do
			data[index] =
			{
				squadID = index,
				memberName = squads[index] or L["SquadsTab/NameNil"],
				memberOrder = squads[index] or "¦",
				assigned = squads[index] and true or false,
			}
			if data[index].memberName:sub(1, 1) == "\000" then
				data[index].memberName = L["SquadsTab/NameBlocked"]
				data[index].memberOrder = "§"
			end
		end
		squadGrid:SetData(data, nil, nil, true)
		
		local roster = GetRoster()
		local unassignedMembers = {}
		for memberID, memberData in pairs(roster) do
			if not memberData.squadID then
				unassignedMembers[memberID] = true
			end
		end
		assignTextfield:SetMatchingTexts(unassignedMembers)
		
		ResetAssignButtons()
	end
	
	local function ResetSquads()
		local numSquads = GetSquadsNumber()
		
		for index, squadPanel in ipairs(squadPanels) do
			if index > numSquads then
				squadPanel:SetVisible(false)
			else
				squadPanel:SetVisible(true)
				
				squadPanel:ClearAll()
				squadPanel:SetPoint("TOPCENTER", frameContent, index / (numSquads + 1), 0, 0, 15)
				squadPanel:SetWidth(76)
				squadPanel:SetHeight(76)
				
				squadPanel:SetSquadIcon(GetSquadLargeIcon(index))
			end
		end
		
		if not selectedSquad or selectedSquad > numSquads then
			frame:SetSelectedSquad(1)
		end
		
		LoadSquad()
	end
	
	for index = 1, 8 do
		local squadPanel = Panel(name .. ".SquadPanels." .. index, frameContent)
		local squadContent = squadPanel:GetContent()
		local squadTexture = UICreateFrame("Texture", squadPanel:GetName() .. ".Texture", squadContent)


		squadPanel:SetInvertedBorder(true)
		
		squadTexture:SetPoint("TOPLEFT", squadContent, "TOPLEFT", 1, 1)
		squadTexture:SetPoint("BOTTOMRIGHT", squadContent, "BOTTOMRIGHT", -1, -1)
		squadTexture:SetBackgroundColor(0, 0, 0, 1)
		
		squadPanel:EventAttach(Event.UI.Input.Mouse.Left.Click,
			function()
				frame:SetSelectedSquad(index)
			end, squadPanel:GetName() .. ".OnLeftClick")
		
		function squadPanel:SetSelectedAppearance(selected)
			if selected then
				squadContent:SetBackgroundColor(1, 0.5, 0.25, 1)
			else
				squadContent:SetBackgroundColor(0, 0.25, 0.5, 1)
			end
		end
		
		function squadPanel:SetSquadIcon(packedTexture)
			squadTexture:SetTextureAsync(unpack(packedTexture))
		end
		
		squadPanels[index] = squadPanel
	end
	
	local function ColorSelector(value, key)
		local data = squadGrid:GetData()
		return data and data[key] and data[key].assigned and { 1, 1, 1 } or { 0.4, 0.4, 0.4 }
	end
	
	squadGrid:SetPadding(2, 2, 2, 40)
	squadGrid:SetHeadersVisible(true)
	squadGrid:SetRowHeight(20)
	squadGrid:SetRowMargin(0)
	squadGrid:SetUnselectedRowBackgroundColor({0.05, 0, 0.05, 0})
	squadGrid:SetSelectedRowBackgroundColor({0, 0.4, 0.4, 0.35})
	squadGrid:SetPoint("TOPLEFT", frameContent, "TOPLEFT", 5, 100)
	squadGrid:SetPoint("BOTTOMRIGHT", frameContent, "BOTTOMRIGHT", -5, -5)
	squadGrid:AddColumn("squadNumber", L["SquadsTab/ColumnSquad"], addonID .. ".CalendarSquad", 70, 0, "squadID", true)
	squadGrid:AddColumn("name", L["SquadsTab/ColumnName"], "Text", 140, 1, "memberName", "memberOrder", { Alignment = "left", Formatter = "none", Color = ColorSelector })
	squadGrid:SetOrder("squadNumber", false)	
	squadGrid:GetInternalContent():SetBackgroundColor(0.05, 0, 0.05, 0.5)
	
	assignFrame:SetPoint("TOPLEFT", gridContent, "BOTTOMLEFT", 5, -38)
	assignFrame:SetPoint("BOTTOMRIGHT", gridContent, "BOTTOMRIGHT", -5, -2)
	assignFrame:SetLayer(squadGrid:GetInternalContent():GetParent():GetLayer() + 100)
	
	autoButton:SetPoint("CENTERRIGHT", assignFrame, "CENTERRIGHT", 0, 0)
	autoButton:SetText(L["SquadsTab/ButtonAuto"])
	
	resetButton:SetPoint("CENTERRIGHT", autoButton, "CENTERLEFT", 0, 0)
	resetButton:SetText(L["SquadsTab/ButtonReset"])
	
	assignButton:SetPoint("CENTERRIGHT", resetButton, "CENTERLEFT", 0, 0)
	assignButton:SetText(L["SquadsTab/ButtonAssign"])
	
	assignTextfield:SetPoint("CENTERLEFT", assignFrame, "CENTERLEFT", 0, 0)
	assignTextfield:SetPoint("CENTERRIGHT", assignButton, "CENTERLEFT", -5, 0)
	assignTextfield:SetHeight(32)
	assignTextfield:SetIgnoreCase(true)
	
	function squadGrid.Event:SelectionChanged(key, value)
		local unassigned = value and not value.assigned and true or false
		if unassigned then
			assignTextfield:SetVisible(true)
			assignButton:SetText(L["SquadsTab/ButtonAssign"])
		else
			assignTextfield:SetVisible(false)
			assignButton:SetText(L["SquadsTab/ButtonUnassign"])
		end
		ResetAssignButtons()
	end
	
	function assignTextfield.Event:TextChanged()
		ResetAssignButtons()
	end
	
	local function AssignButtonLeftPress()
		local squadID, value = squadGrid:GetSelectedData()
		if not value then return end
		if value.assigned then
			FreeSquadID(squadID)
		else
			local member = (assignTextfield:GetText()):gsub("%A", "")
			if member == "" then return end
			AssignSquadID(member:sub(1, 1):upper() .. member:sub(2):lower(), squadID)
			assignTextfield:SetText("")
			squadGrid:SetSelectedKey(squadID + 1)
		end
	end
	
	function assignTextfield.Event:EnterPressed()
		local squadID, value = squadGrid:GetSelectedData()
		if assignButton:GetEnabled() and value then
			AssignButtonLeftPress()
		end
	end
	
	assignButton:EventAttach(Event.UI.Button.Left.Press, AssignButtonLeftPress, assignButton:GetName() .. ".OnLeftPress")
	
	resetButton:EventAttach(Event.UI.Button.Left.Press, 
		function()
			if not selectedSquad then return end
			local squadSize = GetSquadSize()
			local squads = GetSquads()
			for squadID = (selectedSquad - 1) * squadSize, selectedSquad * squadSize - 1 do
				squads[squadID] = nil
			end
			ChangeSquads(squads)
		end, resetButton:GetName() .. ".OnLeftPress")
	
	autoButton:EventAttach(Event.UI.Button.Left.Press, 
		function()
			popupManager:ShowPopup(addonID .. ".BatchAssign", selectedSquad)
		end, autoButton:GetName() .. ".OnLeftPress")
	
	local function eventSink() end
	frame:EventAttach(Event.UI.Input.Mouse.Left.Click, eventSink, "dummy")
	frame:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, eventSink, "dummy")
	
	function frame:SetSelectedSquad(squad)
		if squad ~= selectedSquad then
			selectedSquad = squad
			for index, squadPanel in ipairs(squadPanels) do
				squadPanel:SetSelectedAppearance(index == selectedSquad)
			end
			LoadSquad()
		end
	end
	
	CEAttach(Event[addonID].MemberList, LoadSquad, addonID .. ".SquadsTab.OnMemberList")
	CEAttach(Event[addonID].Roster, LoadSquad, addonID .. ".SquadsTab.OnRoster")
	CEAttach(Event[addonID].Rank, LoadSquad, addonID .. ".SquadsTab.OnRank")
	CEAttach(Event[addonID].GuildSettings, ResetSquads, addonID .. ".SquadsTab.OnGuildSettings")
	
	ResetSquads()
		
	return frame
end
