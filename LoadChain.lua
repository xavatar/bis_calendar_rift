 -- ***************************************************************************************************************************************************
-- * LoadChain.lua                                                                                                                                   *
-- ***************************************************************************************************************************************************
-- * Stores the load chain to be executed when player data is fully available                                                                        *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local GetPlayerName = Internal.Utility.GetPlayerName
local IGRList = Inspect.Guild.Roster.List
local TInsert = table.insert

Internal.DataChain = {}
Internal.UIChain = {}

local availabilityChecked = false
local needLoad = false

local function ExecuteLoader()
	if needLoad then
		for _, Load in ipairs(Internal.DataChain) do
			Load()
		end
		needLoad = false
	end
end
CEAttach(Event.System.Update.Begin, ExecuteLoader, addonID .. ".OnUpdate")

local function OnAvailabilityFull(h, units)
	if not availabilityChecked then
		for unitID, unitSpecifier in pairs(units) do
			if unitSpecifier == "player" then
				needLoad = true
				availabilityChecked = true
				break
			end
		end
	end
end
CEAttach(Event.Unit.Availability.Full, OnAvailabilityFull, addonID .. ".OnUnitAvailable")

local function CheckRoster(h, units)
	local playerName = GetPlayerName()
	if units[playerName] then
		needLoad = true
	end
end
CEAttach(Event.Guild.Roster.Add, CheckRoster, addonID .. ".OnRosterAdd")
CEAttach(Event.Guild.Roster.Remove, CheckRoster, addonID .. ".OnRosterRemove")
