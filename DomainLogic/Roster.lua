-- ***************************************************************************************************************************************************
-- * DomainLogic/Roster.lua                                                                                                                          *
-- ***************************************************************************************************************************************************
-- * Maintains guild roster data                                                                                                                     *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.3 / 2012.01.12 / Baanano: Added calling, level and officerNote                                                                              *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local IGRDetail = Inspect.Guild.Roster.Detail
local IGRList = Inspect.Guild.Roster.List
local TInsert = table.insert
local pairs = pairs
local type = type

local rosterData = {}

local RosterEvent = Utility.Event.Create(addonID, "Roster")

local function UpdateRoster(memberID)
	if type(memberID) ~= "string" then return end
	
	local memberData = IGRDetail(memberID)
	
	rosterData[memberID] = memberData and { rank = memberData.rank, calling = memberData.calling, level = memberData.level, officerNote = memberData.noteOfficer, } or nil -- Calling doesn't exist yet
	
	RosterEvent()
end

local function BuildFullRoster()
	rosterData = {}
	for memberID in pairs(IGRList() or {}) do
		UpdateRoster(memberID)
	end
	RosterEvent()
end

local function OnRosterDetail(h, changes)
	for memberID in pairs(changes) do
		UpdateRoster(memberID)
	end
end


CEAttach(Event.Guild.Roster.Add, function(h, memberID) UpdateRoster(memberID) end, addonID .. ".OnRosterAdd")
CEAttach(Event.Guild.Roster.Remove, function(h, memberID) UpdateRoster(memberID) end, addonID .. ".OnRosterRemove")
CEAttach(Event.Guild.Roster.Detail.Rank, OnRosterDetail, addonID .. ".OnRosterRank")
--TInsert(Event.Guild.Roster.Detail.Calling, { OnRosterDetail, addonID, addonID .. ".OnRosterCalling" }) -- This doesn't exist yet
CEAttach(Event.Guild.Roster.Detail.Level, OnRosterDetail, addonID .. ".OnRosterLevel")
CEAttach(Event.Guild.Roster.Detail.NoteOfficer, OnRosterDetail, addonID .. ".OnRosterOfficerNote")
TInsert(Internal.DataChain, BuildFullRoster)


Internal.Roster = Internal.Roster or {}

function Internal.Roster.GetRoster()
	local result = {}
	for memberID in pairs(rosterData) do
		result[memberID] = true
	end
	return result	
end

function Internal.Roster.GetRank(memberID)
	return memberID and rosterData[memberID] and rosterData[memberID].rank or nil
end

function Internal.Roster.GetCalling(memberID)
	return memberID and rosterData[memberID] and rosterData[memberID].calling or nil
end

function Internal.Roster.GetLevel(memberID)
	return memberID and rosterData[memberID] and rosterData[memberID].level or nil
end

function Internal.Roster.GetOfficerNote(memberID)
	return memberID and rosterData[memberID] and rosterData[memberID].officerNote or nil
end
