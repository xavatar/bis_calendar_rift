-- ***************************************************************************************************************************************************
-- * DomainLogic/GuildSettings.lua                                                                                                                   *
-- ***************************************************************************************************************************************************
-- * Maintains guild settings                                                                                                                        *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.8 / 2012.01.13 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local BRShift = bit.rshift
local Bytes2String = Internal.Utility.Bytes2String
local CEAttach = Command.Event.Attach
local CMBroadcast = Command.Message.Broadcast
local CheckFlag = function(value, flag) return bit.band(value, flag) == flag end
local CopyTableRecursive = Internal.Utility.CopyTableRecursive
local GetPlayerName = Internal.Utility.GetPlayerName
local StorageRefresh = Internal.GSM.Refresh
local StorageSet = Internal.GSM.Set
local String2Bytes = Internal.Utility.String2Bytes
local TInsert = table.insert
local tonumber = tonumber
local type = type
local unpack = unpack

local guildSettings = {}

local GuildSettingsEvent = Utility.Event.Create(addonID, "GuildSettings")

local ENTRYNAME_GUILDSETTINGS = "BiSCalGuildSettings"
local PATTERN_GUILDSETTINGS = "^BiSCalGuildSettings$"
local MESSAGE_GUILDSETTINGS = "BiSCalGuildSettingsChanged"

local DATA_DEFAULT = "\000\001\115\000\001\002\003\004\005\006\007"

local function LoadSettings()
	StorageRefresh()
end

local function OnGuildSettings(identifier, data)
	if identifier == ENTRYNAME_GUILDSETTINGS then
		data = type(data) == "string" and data:len() >= DATA_DEFAULT:len() and data or DATA_DEFAULT
		
		local bytes = String2Bytes(data)
		
		guildSettings =
		{
			PostEventsToWall = CheckFlag(bytes[2], 1),
			StorageLimit = BRShift(bytes[3], 4) + 1,
			SquadNumber = bytes[3] % 16,
			Squads = { bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], },
		}

		GuildSettingsEvent()
	end
end

local function SaveSettings()
	local data = Bytes2String({ 0, (guildSettings.PostEventsToWall and 1 or 0), (guildSettings.StorageLimit - 1) * 16 + guildSettings.SquadNumber, unpack(guildSettings.Squads) })
	
	StorageSet(ENTRYNAME_GUILDSETTINGS, "guild", "officer", data, false,
		function() CMBroadcast("guild", nil, MESSAGE_GUILDSETTINGS, "dummy") end) -- FIXME Should check the "message" queue
end

local function DefaultSettings()
	OnGuildSettings(ENTRYNAME_GUILDSETTINGS, DATA_DEFAULT)
end

local function OnMessage(h, from, msgType, channel, identifier, data)
	if msgType == "guild" and identifier == MESSAGE_GUILDSETTINGS then
		LoadSettings()
	end
end

Command.Message.Accept("guild", MESSAGE_GUILDSETTINGS)
Internal.GSM.StartMonitoring(PATTERN_GUILDSETTINGS, false, OnGuildSettings)
CEAttach(Event.Message.Receive, OnMessage, addonID .. ".GuildSettings.Message")
TInsert(Internal.DataChain, LoadSettings)

DefaultSettings()


Internal.GuildSettings = Internal.GuildSettings or {}

Internal.GuildSettings.ReloadSettings = LoadSettings

function Internal.GuildSettings.GetSettings()
	return CopyTableRecursive(guildSettings)
end

function Internal.GuildSettings.SetSettings(newSettings)
	if type(newSettings) ~= "table" then return end
	
	local function ValidateSquadsOrDefault(squads)
		local result = {}
		
		local usedIDs = {}
		for index = 1, 8 do
			local squad = type(squads) == "table" and type(squads[index]) == "number" and squads[index] >= 0 and squads[index] <= 255 and squads[index] or nil
			if not squad then for id = 0, 255 do if not usedIDs[id] then squad = id break end end end
			result[index] = squad
			usedIDs[squad] = true
		end
		
		return result
	end
	
	guildSettings =
	{
		PostEventsToWall =         newSettings.PostEventsToWall and true or false,
		StorageLimit =             newSettings.StorageLimit >= 1 and newSettings.StorageLimit <= 16 and newSettings.StorageLimit or 8,
		SquadNumber =              newSettings.SquadNumber >= 0 and newSettings.SquadNumber <= 3 and newSettings.SquadNumber or 3,
		Squads = ValidateSquadsOrDefault(newSettings.Squads)
	}
	
	SaveSettings()
end

function Internal.GuildSettings.RestoreDefaultSettings()
	DefaultSettings()
	SaveSettings()
end
