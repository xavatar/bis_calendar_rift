-- ***************************************************************************************************************************************************
-- * UI.lua                                                                                                                                          *
-- ***************************************************************************************************************************************************
-- * Main BiSCal frame                                                                                                                                *
-- ***************************************************************************************************************************************************
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local L = Internal.Localization.L
local NativeGuildFrame = UI.Native.Guild
local TInsert = table.insert
local UICreateContext = UI.CreateContext
local UICreateFrame = UI.CreateFrame
local pairs = pairs
local pcall = pcall
local print = print

local function InitializeUI()
	local mainContext = UICreateContext(addonID .. ".MainContext")
	
	local mainFrame = UICreateFrame("Frame", mainContext:GetName() .. ".MainFrame", mainContext)
	local tabControl = Internal.UI.TabControl(mainContext:GetName() .. ".TabControl", mainContext)
	local calendarTab = Internal.UI.CalendarTab(mainFrame:GetName() .. ".CalendarTab", mainFrame)
	local squadsTab = Internal.UI.SquadsTab(mainFrame:GetName() .. ".SquadsTab", mainFrame)
	local optionsTab = Internal.UI.OptionsTab(mainFrame:GetName() .. ".OptionsTab", mainFrame)
	
	mainFrame:SetPoint("TOPLEFT", NativeGuildFrame, "TOPLEFT", 19, 94)
	mainFrame:SetPoint("BOTTOMRIGHT", NativeGuildFrame, "BOTTOMRIGHT", -17, -18)
	mainFrame:SetVisible(false)
	mainFrame:SetLayer(20)
	
	tabControl:SetPoint("TOPLEFT", NativeGuildFrame, "BOTTOMLEFT", 30, -2)
	tabControl:SetPoint("TOPRIGHT", NativeGuildFrame, "BOTTOMRIGHT", -30, -2)
	tabControl:SetHeight(30)
	tabControl:SetVisible(false)
	tabControl:SetLayer(10)
	
	calendarTab:SetAllPoints()
	squadsTab:SetAllPoints()
	optionsTab:SetAllPoints()
	
	tabControl:AddTab(L["Tabs/Original"])
	tabControl:AddTab(L["Tabs/Calendar"], calendarTab)
	tabControl:AddTab(L["Tabs/Squads"], squadsTab)
	for pluginID, pluginData in pairs(Internal.Plugin.GetPlugins()) do
		local ok, pluginFrame = pcall(pluginData.tabConstructor, mainFrame)
		if ok and pluginFrame then
			pluginFrame:SetAllPoints()
			tabControl:AddTab(pluginData.tabName, pluginFrame)
		else
			print(L["Plugin/ErrorMessage"]:format(pluginID, pluginFrame or L["Plugin/ErrorNoTab"]))
		end
	end
	tabControl:AddTab(L["Tabs/Config"], optionsTab)
	
	NativeGuildFrame:EventAttach(Event.UI.Layout.Layer,
		function()
			if NativeGuildFrame:GetLoaded() then
				mainContext:SetLayer(NativeGuildFrame:GetLayer() + 1)
			end
		end, NativeGuildFrame:GetName() .. ".OnLayer")

	NativeGuildFrame:EventAttach(Event.UI.Native.Loaded,
		function()
			local visible = NativeGuildFrame:GetLoaded()
			mainFrame:SetVisible(visible)
			tabControl:SetVisible(visible)
		end, NativeGuildFrame:GetName() .. ".OnLoaded")
	
	-- Display version info to console
	Command.Console.Display("general", false, string.format("BiSCal v%s loaded...", addonInfo.toc.Version), false)
end

TInsert(Internal.UIChain, InitializeUI)
