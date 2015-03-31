-- ***************************************************************************************************************************************************
-- * JoinDialog.lua                                                                                                                                  *
-- ***************************************************************************************************************************************************
-- * BiSCal Join dialog frame                                                                                                                        *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.3.114 / 2012.03.05 / Baanano: First version                                                                                                   *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local Dropdown = Yague.Dropdown
local GetEventDetail = Internal.ModelView.GetEventDetail
local GetPermissions = Internal.ModelView.GetPermissions
local GetPlayerName = Internal.Utility.GetPlayerName
local GetSquadID = Internal.MemberList.GetID
local GetSquads = Internal.ModelView.GetAllSquadIDs
local IUDetail = Inspect.Unit.Detail
local L = Internal.Localization.L
local MFloor = math.floor
local MMax = math.max
local Popup = Yague.Popup
local RegisterPopupConstructor = Yague.RegisterPopupConstructor
local ShadowedText = Yague.ShadowedText
local SignEvent = Internal.ModelView.SignEvent
local UICreateFrame = UI.CreateFrame
local pairs = pairs

local function JoinPopup(parent)
	local popup = Popup("JoinPopup", parent)
	local popupContent = popup:GetContent()
	local rightAnchor = UICreateFrame("Frame", popup:GetName() .. ".RightAnchor", popupContent)
	
	local nameTitle = ShadowedText(popup:GetName() .. ".NameTitle", popupContent)
	local nameDropdown = Dropdown(popup:GetName() .. ".NameDropdown", popupContent)
	local rolesTitle = ShadowedText(popup:GetName() .. ".RolesTitle", popupContent)
	local tankTexture = UICreateFrame("Texture", popup:GetName() .. ".TankTexture", popupContent)
	local healerTexture = UICreateFrame("Texture", popup:GetName() .. ".HealerTexture", popupContent)
	local dpsTexture = UICreateFrame("Texture", popup:GetName() .. ".DpsTexture", popupContent)
	local supportTexture = UICreateFrame("Texture", popup:GetName() .. ".SupportTexture", popupContent)
	local stateTitle = ShadowedText(popup:GetName() .. ".StateTitle", popupContent)
	local stateDropdown = Dropdown(popup:GetName() .. ".StateDropdown", popupContent)
	local acceptanceTitle = ShadowedText(popup:GetName() .. ".AcceptanceTitle", popupContent)
	local acceptanceDropdown = Dropdown(popup:GetName() .. ".AcceptanceDropdown", popupContent)
	local errorText = ShadowedText(popup:GetName() .. ".ErrorText", popupContent)
	local joinButton = UICreateFrame("RiftButton", popup:GetName() .. ".JoinButton", popupContent)
	local cancelButton = UICreateFrame("RiftButton", popup:GetName() .. ".CancelButton", popupContent)

	local eventID = nil
	local playerRoles = { tank = false, healer = false, dps = false, support = false, standby = false, declined = false, accepted = false, rejected = false, }
	
	local function RefreshNames()
		local squads = GetSquads()
		for squadID, squadName in pairs(squads) do
			squads[squadID] = { name = squadName }
		end
		nameDropdown:SetValues(squads)
	end
	
	local function RefreshPlayerRoles()
		tankTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_tank_mini" .. (playerRoles.tank and "" or "_disabled") .. ".png.dds")
		healerTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_heal_mini" .. (playerRoles.healer and "" or "_disabled") .. ".png.dds")
		dpsTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_damage_mini" .. (playerRoles.dps and "" or "_disabled") .. ".png.dds")
		supportTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_support_mini" .. (playerRoles.support and "" or "_disabled") .. ".png.dds")
	end
	
	local function RefreshPermissions()
		local permissions = GetPermissions()
		local playerName = GetPlayerName()
		local squadID, squadData = nameDropdown:GetSelectedValue()
		
		local officer = permissions and permissions.assignID and true or false
		
		nameDropdown:SetEnabled(officer)
		stateDropdown:SetEnabled(squadData and squadData.name == playerName and true or false)
		acceptanceDropdown:SetEnabled(officer)
		
		if officer then
			joinButton:SetEnabled(true)
			errorText:SetVisible(false)
		else
			local showError = nil

			local eventDetail = GetEventDetail(eventID)
			if not eventDetail then
				showError = L["JoinDialog/ErrorNoEvent"]
			else
				if eventDetail.restrictLevel then
					local unitDetail = IUDetail("player")
					local level = unitDetail and unitDetail.level or 0
					local minLevel, maxLevel = eventDetail.restrictLevel[1], eventDetail.restrictLevel[2]
					if level < minLevel or level > maxLevel then
						showError = L["JoinDialog/ErrorLevelRequirement"]:format(minLevel, maxLevel)
					end
				end
				if eventDetail.restrictSquad then
					if not eventDetail.restrictSquad[MFloor((squadID or 256) / 32) + 1] then
						showError = L["JoinDialog/ErrorSquadRequirement"]
					end
				end
			end
			
			if showError then
				joinButton:SetEnabled(false)
				errorText:SetVisible(true)
				errorText:SetText(showError)
			else
				joinButton:SetEnabled(true)
				errorText:SetVisible(false)
			end
		end
	end
	
	local function ReloadPopup()
		RefreshNames()
		RefreshPlayerRoles()
	end
	
	popup:SetWidth(500)
	popup:SetHeight(270)
	
	rightAnchor:SetPoint("CENTERRIGHT", popupContent, "CENTERRIGHT", -20, 0)
	rightAnchor:SetVisible(false)

	nameTitle:SetPoint("TOPLEFT", popupContent, "TOPLEFT", 10, 20)
	nameTitle:SetFontColor(.75, .75, .5)
	nameTitle:SetFontSize(14)
	nameTitle:SetText(L["JoinDialog/NameTitle"])
	
	rolesTitle:SetPoint("TOPLEFT", nameTitle, "BOTTOMLEFT", 0, 15)
	rolesTitle:SetFontColor(.75, .75, .5)
	rolesTitle:SetFontSize(14)
	rolesTitle:SetText(L["JoinDialog/RolesTitle"])
	
	stateTitle:SetPoint("TOPLEFT", rolesTitle, "BOTTOMLEFT", 0, 15)
	stateTitle:SetFontColor(.75, .75, .5)
	stateTitle:SetFontSize(14)
	stateTitle:SetText(L["JoinDialog/StateTitle"])
	
	acceptanceTitle:SetPoint("TOPLEFT", stateTitle, "BOTTOMLEFT", 0, 15)
	acceptanceTitle:SetFontColor(.75, .75, .5)
	acceptanceTitle:SetFontSize(14)
	acceptanceTitle:SetText(L["JoinDialog/AcceptanceTitle"])
	
	errorText:SetPoint("CENTER", popupContent, "BOTTOMCENTER", 0, -70)
	errorText:SetFontColor(1, 0, 0)
	errorText:SetVisible(false)
	
	local offset = MMax(MMax(MMax(nameTitle:GetWidth(), rolesTitle:GetWidth()), stateTitle:GetWidth()), acceptanceTitle:GetWidth()) + 20
	
	nameDropdown:SetPoint("CENTERLEFT", nameTitle, "CENTERLEFT", offset, 0)
	nameDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	nameDropdown:SetHeight(30)
	nameDropdown:SetTextSelector("name")
	nameDropdown:SetOrderSelector("name")
	
	tankTexture:SetPoint("CENTERRIGHT", healerTexture, "CENTERLEFT", -10, 0)
	
	healerTexture:SetPoint("CENTERRIGHT", dpsTexture, "CENTERLEFT", -10, 0)
	
	dpsTexture:SetPoint("CENTERRIGHT", supportTexture, "CENTERLEFT", -10, 0)
	
	supportTexture:SetPoint("RIGHT", rightAnchor, "RIGHT")
	supportTexture:SetPoint("CENTERY", rolesTitle, "CENTERY")
	
	stateDropdown:SetPoint("CENTERLEFT", stateTitle, "CENTERLEFT", offset, 0)
	stateDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	stateDropdown:SetHeight(30)
	stateDropdown:SetTextSelector("name")
	stateDropdown:SetOrderSelector("order")
	stateDropdown:SetColorSelector("color")
	stateDropdown:SetValues({
		["normal"] = { name = L["JoinDialog/StateNormal"], order = 1, color = { 1, 1, 1, }, },
		["standby"] = { name = L["JoinDialog/StateStandby"], order = 2, color = { 1, 1, 0, }, },
		["declined"] = { name = L["JoinDialog/StateDeclined"], order = 3, color = { 1, 0, 0, }, },
	})
	
	
	acceptanceDropdown:SetPoint("CENTERLEFT", acceptanceTitle, "CENTERLEFT", offset, 0)
	acceptanceDropdown:SetPoint("RIGHT", rightAnchor, "RIGHT")
	acceptanceDropdown:SetHeight(30)
	acceptanceDropdown:SetTextSelector("name")
	acceptanceDropdown:SetOrderSelector("order")
	acceptanceDropdown:SetColorSelector("color")
	acceptanceDropdown:SetValues({
		["accepted"] = { name = L["JoinDialog/AcceptanceAccepted"], order = 1, color = { 0, 1, 0, }, },
		["pending"] = { name = L["JoinDialog/AcceptancePending"], order = 2, color = { 1, 1, 1, }, },
		["rejected"] = { name = L["JoinDialog/AcceptanceRejected"], order = 3, color = { 1, 0, 0, }, },
	})
	
	joinButton:SetPoint("BOTTOMCENTER", popupContent, 1/4, 1, 0, -10)
	joinButton:SetText(L["JoinDialog/ButtonSave"])
	
	cancelButton:SetPoint("BOTTOMCENTER", popupContent, 3/4, 1, 0, -10)
	cancelButton:SetText(L["JoinDialog/ButtonCancel"])

	function nameDropdown.Event:SelectionChanged(memberID)
		local eventDetail = GetEventDetail(eventID)
		
		playerRoles = eventDetail and eventDetail.members and eventDetail.members[memberID] or
			{ tank = false, healer = false, dps = false, support = false, standby = false, declined = false, accepted = false, rejected = false, }
			
		stateDropdown:SetSelectedKey(playerRoles.standby and "standby" or (playerRoles.declined and "declined" or "normal"))
		acceptanceDropdown:SetSelectedKey(playerRoles.accepted and "accepted" or (playerRoles.rejected and "rejected" or "pending"))
		
		RefreshPlayerRoles()
		RefreshPermissions()
	end

	tankTexture:EventAttach(Event.UI.Input.Mouse.Left.Click,
		function()
			playerRoles.tank = not playerRoles.tank
			RefreshPlayerRoles()
		end, tankTexture:GetName() .. ".OnLeftClick")
	
	healerTexture:EventAttach(Event.UI.Input.Mouse.Left.Click,
		function()
			playerRoles.healer = not playerRoles.healer
			RefreshPlayerRoles()
		end, healerTexture:GetName() .. ".OnLeftClick")
	
	dpsTexture:EventAttach(Event.UI.Input.Mouse.Left.Click,
		function()
			playerRoles.dps = not playerRoles.dps
			RefreshPlayerRoles()
		end, dpsTexture:GetName() .. ".OnLeftClick")
	
	supportTexture:EventAttach(Event.UI.Input.Mouse.Left.Click,
		function()
			playerRoles.support = not playerRoles.support
			RefreshPlayerRoles()
		end, supportTexture:GetName() .. ".OnLeftClick")
	
	function stateDropdown.Event:SelectionChanged(state)
		playerRoles.standby = state == "standby"
		playerRoles.declined = state == "declined"
	end
	
	function acceptanceDropdown.Event:SelectionChanged(acceptance)
		playerRoles.accepted = acceptance == "accepted"
		playerRoles.rejected = acceptance == "rejected"
	end
	
	joinButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			local _, squadData = nameDropdown:GetSelectedValue()
			local name = squadData and squadData.name or nil
			
			if eventID and name then
				SignEvent(eventID, name, playerRoles.tank, playerRoles.healer, playerRoles.dps, playerRoles.support, playerRoles.standby, playerRoles.declined, playerRoles.accepted, playerRoles.rejected)
			end

			parent:HidePopup(addonID .. ".Join", popup)
		end, joinButton:GetName() .. ".OnLeftPress")
	
	cancelButton:EventAttach(Event.UI.Button.Left.Press,
		function()
			parent:HidePopup(addonID .. ".Join", popup)
		end, cancelButton:GetName() .. ".OnLeftPress")
	
	function popup:SetData(event, name)
		eventID = event or nil
		ReloadPopup()
		nameDropdown:SetSelectedKey(GetSquadID(name))
	end
	
	return popup
end

RegisterPopupConstructor(addonID .. ".Join", JoinPopup)
