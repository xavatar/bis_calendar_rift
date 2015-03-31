-- ***************************************************************************************************************************************************
-- * BatchAssignDialog.lua                                                                                                                           *
-- ***************************************************************************************************************************************************
-- * BiSCal Batch squad assign dialog frame                                                                                                          *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.1.59 / 2012.01.22 / Baanano: First version                                                                                                    *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local ChangeSquads = Internal.ModelView.ChangeSquads
local Dropdown = Yague.Dropdown
local GetRanks = Internal.ModelView.GetRanks
local GetRoster = Internal.ModelView.GetRoster
local GetSquadSize = Internal.ModelView.GetSquadSize
local GetSquads = Internal.ModelView.GetAllSquadIDs
local L = Internal.Localization.L
local MMax = math.max
local Popup = Yague.Popup
local RegisterPopupConstructor = Yague.RegisterPopupConstructor
local ShadowedText = Yague.ShadowedText
local Slider = Yague.Slider
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local next = next
local pairs = pairs

local function BatchAssignPopup(parent)
	local popup = Popup("BatchAssignPopup", parent)
	local popupContent = popup:GetContent()
	local rightAnchor = UICreateFrame("Frame", popup:GetName() .. ".RightAnchor", popupContent)
	
	local minLevelTitle = ShadowedText(popup:GetName() .. ".MinLevelTitle", popupContent)
	local minLevelSlider = Slider(popup:GetName() .. ".MinLevelSlider", popupContent)
	local maxLevelTitle = ShadowedText(popup:GetName() .. ".MaxLevelTitle", popupContent)
	local maxLevelSlider = Slider(popup:GetName() .. ".MaxLevelSlider", popupContent)
	local minRankTitle = ShadowedText(popup:GetName() .. ".MinRankTitle", popupContent)
	local minRankDropdown = Dropdown(popup:GetName() .. ".MinRankDropdown", popupContent)
	local maxRankTitle = ShadowedText(popup:GetName() .. ".MaxRankTitle", popupContent)
	local maxRankDropdown = Dropdown(popup:GetName() .. ".MaxRankDropdown", popupContent)
	local callingTitle = ShadowedText(popup:GetName() .. ".CallingTitle", popupContent)
	local callingDropdown = Dropdown(popup:GetName() .. ".CallingDropdown", popupContent)
	local assignButton = UICreateFrame("RiftButton", popup:GetName() .. ".AssignButton", popupContent)
	local cancelButton = UICreateFrame("RiftButton", popup:GetName() .. ".CancelButton", popupContent)

	local squad = nil
	
	local ranks = {}
	local function ResetRanks()
		ranks = {}
	
		local highestRank = nil
		local lowestRank = nil
	
		for rankID, rankName in pairs(GetRanks()) do
			ranks[rankID] = { name = rankName, id = rankID, }
			if not highestRank or highestRank > rankID then
				highestRank = rankID
			end
			if not lowestRank or lowestRank < rankID then
				lowestRank = rankID
			end
		end
		
		minRankDropdown:SetValues(ranks)
		minRankDropdown:SetSelectedKey(lowestRank)
		maxRankDropdown:SetValues(ranks)
		maxRankDropdown:SetSelectedKey(highestRank)
	end
	
	popup:SetWidth(500)
	popup:SetHeight(270)
	
	rightAnchor:SetPoint("CENTERRIGHT", popupContent, "CENTERRIGHT", -10, 0)
	rightAnchor:SetVisible(false)

	minLevelTitle:SetPoint("TOPLEFT", popupContent, "TOPLEFT", 10, 20)
	minLevelTitle:SetFontColor(.75, .75, .5)
	minLevelTitle:SetFontSize(14)
	minLevelTitle:SetText(L["BatchAssignDialog/MinLevelTitle"])	
	
	maxLevelTitle:SetPoint("TOPLEFT", minLevelTitle, "BOTTOMLEFT", 0, 15)
	maxLevelTitle:SetFontColor(.75, .75, .5)
	maxLevelTitle:SetFontSize(14)
	maxLevelTitle:SetText(L["BatchAssignDialog/MaxLevelTitle"])	
	
	minRankTitle:SetPoint("TOPLEFT", maxLevelTitle, "BOTTOMLEFT", 0, 15)
	minRankTitle:SetFontColor(.75, .75, .5)
	minRankTitle:SetFontSize(14)
	minRankTitle:SetText(L["BatchAssignDialog/MinRankTitle"])	
	
	maxRankTitle:SetPoint("TOPLEFT", minRankTitle, "BOTTOMLEFT", 0, 15)
	maxRankTitle:SetFontColor(.75, .75, .5)
	maxRankTitle:SetFontSize(14)
	maxRankTitle:SetText(L["BatchAssignDialog/MaxRankTitle"])	
	
	callingTitle:SetPoint("TOPLEFT", maxRankTitle, "BOTTOMLEFT", 0, 15)
	callingTitle:SetFontColor(.75, .75, .5)
	callingTitle:SetFontSize(14)
	callingTitle:SetText(L["BatchAssignDialog/CallingTitle"])	
	
	local offset = MMax(MMax(MMax(MMax(minLevelTitle:GetWidth(), maxLevelTitle:GetWidth()), minRankTitle:GetWidth()), maxRankTitle:GetWidth()), callingTitle:GetWidth()) + 20
	
	minLevelSlider:SetPoint("CENTERLEFT", minLevelTitle, "CENTERLEFT", offset, -2)
	minLevelSlider:SetPoint("RIGHT", rightAnchor, "RIGHT")
	minLevelSlider:SetRange(1, 60)
	minLevelSlider:SetPosition(1)
	
	maxLevelSlider:SetPoint("CENTERLEFT", maxLevelTitle, "CENTERLEFT", offset, -2)
	maxLevelSlider:SetPoint("RIGHT", rightAnchor, "RIGHT")
	maxLevelSlider:SetRange(1, 60)
	maxLevelSlider:SetPosition(60)
	
	minRankDropdown:SetPoint("CENTERLEFT", minRankTitle, "CENTERLEFT", offset, 0)
	minRankDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	minRankDropdown:SetHeight(30)
	minRankDropdown:SetTextSelector("name")
	minRankDropdown:SetOrderSelector("id")
	
	maxRankDropdown:SetPoint("CENTERLEFT", maxRankTitle, "CENTERLEFT", offset, 0)
	maxRankDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	maxRankDropdown:SetHeight(30)
	maxRankDropdown:SetTextSelector("name")
	maxRankDropdown:SetOrderSelector("id")
	
	callingDropdown:SetPoint("CENTERLEFT", callingTitle, "CENTERLEFT", offset, 0)
	callingDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	callingDropdown:SetHeight(30)
	callingDropdown:SetTextSelector("name")
	callingDropdown:SetOrderSelector("order")
	callingDropdown:SetValues(
	{
		{ name = L["BatchAssignDialog/CallingAny"], order = 0, }
	})
	callingDropdown:SetEnabled(false)
	
	assignButton:SetPoint("BOTTOMCENTER", popupContent, 1/4, 1, 0, -10)
	assignButton:SetText(L["BatchAssignDialog/ButtonSave"])
	
	cancelButton:SetPoint("BOTTOMCENTER", popupContent, 3/4, 1, 0, -10)
	cancelButton:SetText(L["BatchAssignDialog/ButtonCancel"])
	
	assignButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local minLevel = minLevelSlider:GetPosition()
			local maxLevel = maxLevelSlider:GetPosition()
			local minRank = minRankDropdown:GetSelectedValue()
			local maxRank = maxRankDropdown:GetSelectedValue()
			
			if not squad or minLevel > maxLevel or minRank < maxRank then
				parent:HidePopup(addonID .. ".BatchAssign", popup)
				return
			end

			local roster = GetRoster()
			local squads = GetSquads()
			local squadSize = GetSquadSize()
			
			local newMembers = {}
			for name, data in pairs(roster) do
				if data.level and data.level >= minLevel and data.level <= maxLevel and data.rank and data.rank <= minRank and data.rank >= maxRank and not data.squadID then
					newMembers[name] = true
				end
			end
			
			for squadID = (squad - 1) * squadSize, squad * squadSize - 1 do
				if not squads[squadID] then
					local member = next(newMembers)
					if not member then break end
					newMembers[member] = nil
					squads[squadID] = member
				end
			end
			
			ChangeSquads(squads)
			parent:HidePopup(addonID .. ".BatchAssign", popup)
		end, assignButton:GetName() .. ".OnLeftPress")
	
	cancelButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			parent:HidePopup(addonID .. ".BatchAssign", popup)
		end, cancelButton:GetName() .. ".OnLeftPress")
	
	function popup:SetData(selectedSquad)
		squad = selectedSquad
	end
	
	CEAttach(Event[addonID].Rank, ResetRanks, addonID .. ".BatchAssignDialog.OnRank")

	ResetRanks()
	
	return popup
end

RegisterPopupConstructor(addonID .. ".BatchAssign", BatchAssignPopup)
