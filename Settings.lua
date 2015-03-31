-- ***************************************************************************************************************************************************
-- * Settings.lua                                                                                                                                    *
-- ***************************************************************************************************************************************************
-- * BiSCal player settings                                                                                                                          *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.3 / 2012.01.12 / Baanano: Moved settings to account. Added language                                                                         *
-- * 0.0.2 / 2012.01.12 / Odine:   First version                                                                                                     *
-- ***************************************************************************************************************************************************
local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local ISLanguage = Inspect.System.Language
local TInsert = table.insert
local ipairs = ipairs

Internal = Internal or {}
Internal.AccountSettings = Internal.AccountSettings or {}

Internal.Version = Internal.Version or {}
Internal.Version.Users = {}

local started = false
local loaded = false

local function ExecuteUIChain()
	if loaded and started then
		for _, Load in ipairs(Internal.UIChain) do
			Load()
		end
	end
end

local function DefaultSettings()
	-- Account Settings
	-- Use24Time: If true it'll use 24 hour clock, if false, 12 hour clock
	if Internal.AccountSettings.Use24Time == nil then Internal.AccountSettings.Use24Time = false end
	
	-- FirstWeekDayMonday: If true, weeks will start on Monday, if false, on Sunday
	if Internal.AccountSettings.FirstWeekDayMonday == nil then Internal.AccountSettings.FirstWeekDayMonday = false end
	
	-- Language: Stores the preferred language of the player
	Internal.AccountSettings.Language = Internal.AccountSettings.Language or ISLanguage()
	
	--Internal.AccountSettings.Debug = Internal.AccountSettings.Debug or false
	if Internal.AccountSettings.Debug == nil then Internal.AccountSettings.Debug = false end
end

local function LoadSettings(h, addonId)
	if addonId == addonID then
		Internal.AccountSettings = _G[addonID .. "AccountSettings"] or {}
		Internal.Version.Users = _G[addonID .. "Users"] or {}
		
		DefaultSettings()
		
		loaded = true
		ExecuteUIChain()
	end
end
CEAttach(Event.Addon.SavedVariables.Load.End, LoadSettings, addonID .. ".Settings.Load")

local function SaveSettings(h, addonId)
	if addonId == addonID then
		_G[addonID .. "AccountSettings"] = Internal.AccountSettings
		_G[addonID .. "Users"] = Internal.Version.Users
	end
end
CEAttach(Event.Addon.SavedVariables.Save.Begin, SaveSettings, addonID .. ".Settings.Save")

local function Startup()
	started = true
	ExecuteUIChain()
end
CEAttach(Event.Addon.Startup.End, Startup, addonID .. ".Startup")
