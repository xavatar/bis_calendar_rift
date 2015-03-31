-- ***************************************************************************************************************************************************
-- * TabControl.lua                                                                                                                                  *
-- ***************************************************************************************************************************************************
-- * BiSCal tabs frame                                                                                                                               *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local Panel = Yague.Panel
local ShadowedText = Yague.ShadowedText
local TInsert = table.insert
local UICreateFrame = UI.CreateFrame
local ipairs = ipairs

Internal.UI = Internal.UI or {}

function Internal.UI.TabControl(name, parent)
	local tabFrame = UICreateFrame("Frame", name, parent)
	
	local tabFrames = {}
	local tabContents = {}
	local selectedTabIndex = 0
	
	function tabFrame:AddTab(title, frame)
		local tabIndex = #tabFrames + 1

		local tab = Panel(tabFrame:GetName() .. ".Tabs." .. tabIndex, tabFrame)
		local tabContent = tab:GetContent()
		local tabText = ShadowedText(tab:GetName() .. ".Text", tabContent)
		
		if #tabFrames <= 0 then
			tab:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -4)
			tab:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT")
		else
			tab:SetPoint("TOPLEFT", tabFrames[#tabFrames], "TOPRIGHT", 5, 0)
			tab:SetPoint("BOTTOMLEFT", tabFrames[#tabFrames], "BOTTOMRIGHT", 5, 0)
		end
		tab:SetTopBorderVisible(false)
		
		tabText:SetPoint("CENTER", tabContent, "CENTER")
		tabText:SetText(title)
		tabText:SetFontSize(13)
		tabText:SetShadowOffset(2, 2)
		tabText:SetFontColor(0.75, 0.75, 0.5)
		
		tab:SetWidth(tabText:GetWidth() + 40)
		
		tab:EventAttach(Event.UI.Input.Mouse.Cursor.In,
			function()
				tabText:SetFontSize(14)
			end, tab:GetName() .. ".OnMouseIn")
		
		tab:EventAttach(Event.UI.Input.Mouse.Cursor.Out,
			function()
				tabText:SetFontSize(13)
			end, tab:GetName() .. ".OnMouseOut")
		
		tab:EventAttach(Event.UI.Input.Mouse.Left.Click,
			function()
				tabFrame:SetSelectedTab(tabIndex)
			end, tab:GetName() .. ".OnLeftClick")
		
		function tab:SetSelectedAppearance(selected)
			if selected then
				tabText:SetFontColor(1, 1, 1)
			else
				tabText:SetFontColor(0.75, 0.75, 0.5)
			end
		end
		
		TInsert(tabFrames, tab)
		if frame then
			tabContents[tabIndex] = frame
			frame:SetVisible(false)
		end

		if selectedTabIndex <= 0 then
			 tabFrame:SetSelectedTab(tabIndex)
		end
	end
	
	function tabFrame:SetSelectedTab(tabIndex)
		selectedTabIndex = tabIndex
		for index, tab in ipairs(tabFrames) do
			tab:SetSelectedAppearance(index == selectedTabIndex)
			if tabContents[index] then
				tabContents[index]:SetVisible(index == selectedTabIndex)
			end
		end
	end
	
	return tabFrame
end
