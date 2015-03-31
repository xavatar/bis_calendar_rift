-- ***************************************************************************************************************************************************
-- * LL/EventList.lua                                                                                                                                *
-- ***************************************************************************************************************************************************
-- * Maintains guild event list data                                                                                                                 *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local BRShift = bit.rshift
local Bytes2String = Internal.Utility.Bytes2String
local CEAttach = Command.Event.Attach
local CMBroadcast = Command.Message.Broadcast
local CheckFlag = function(value, flag) return bit.band(value, flag) == flag end
local ClearStorageLimit = Internal.GSM.ClearStorageLimit
local CopyTableRecursive = Internal.Utility.CopyTableRecursive
local GetGuildSettings = Internal.GuildSettings.GetSettings
local GetPlayerName = Internal.Utility.GetPlayerName
local MFloor = math.floor
local MMax = math.max
local SetStorageLimit = Internal.GSM.SetStorageLimit
local StorageClear = Internal.GSM.Clear
local StorageRefresh = Internal.GSM.Refresh
local StorageSet = Internal.GSM.Set
local String2Bytes = Internal.Utility.String2Bytes
local TInsert = table.insert
local next = next
local pairs = pairs
local pcall = pcall
local tonumber = tonumber
local type = type

local ENTRYNAME_GUILDSETTINGS = "BiSCalGuildSettings"
local ENTRYNAME_MEMBERLIST = "BiSCalMembers"
local ENTRYNAME_EVENTPREFIX = "BC2E"
local PATTERN_EVENT = "^BC2E%x+$"
local MESSAGE_EVENT = "BiSCalEvent"
local EVENT_EXTRA =
{
	MEMBER_LIST = 0,
	LEVEL_RESTRICTION = 1,
	SQUAD_RESTRICTION = 2,
}

local eventTable = {}
local EventListEvent = Utility.Event.Create(addonID, "EventList")
local storageGroup = nil

local function ResetStorageLimits(extra)
	if storageGroup then
		ClearStorageLimit(storageGroup)
	end

	local identifiers = { ENTRYNAME_GUILDSETTINGS, ENTRYNAME_MEMBERLIST }
	
	for eventID in pairs(eventTable) do
		local storageID = ENTRYNAME_EVENTPREFIX .. ("%X"):format(eventID)
		TInsert(identifiers, storageID)
		if extra == storageID then
			extra = nil
		end
	end

	if extra then
		TInsert(identifiers, extra)
	end
	
	storageGroup = SetStorageLimit(identifiers, GetGuildSettings().StorageLimit * 512)
end

local function LoadAllEvents()
	StorageRefresh()
end

local function OnEvent(identifier, data)
	if identifier:sub(1, ENTRYNAME_EVENTPREFIX:len()) == ENTRYNAME_EVENTPREFIX then
		local eventID = tonumber(identifier:sub(ENTRYNAME_EVENTPREFIX:len() + 1), 16)
		
		if eventID then
			if data then
				local bytes = String2Bytes(data)
				
				local category = bytes[1]
				local subcategory = bytes[2]
				local timestamp = bytes[3] * 16777216 + bytes[4] * 65536 + bytes[5] * 256 + bytes[6]
				local duration = bytes[7] % 16
				
				local extras = {}
				local nextExtra = 8
				while nextExtra + 2 <= #bytes do
					local length = bytes[nextExtra] * 256 + bytes[nextExtra + 1]
					local extraID = bytes[nextExtra + 2]
					
					local extra = {}
					for index = nextExtra + 3, nextExtra + length + 1 do
						TInsert(extra, bytes[index])
					end
					extras[extraID] = extra
					
					nextExtra = nextExtra + length + 2
				end
				
				local members = {}
				local restrictLevel = nil
				local restrictSquad = nil
				for extraID, extraBytes in pairs(extras) do
					if extraID == EVENT_EXTRA.MEMBER_LIST then
						for index = 1, #extraBytes, 2 do
							local memberID = extraBytes[index]
							local memberFlags = extraBytes[index + 1]
							
							members[memberID] =
							{
								accepted = CheckFlag(memberFlags, 128),
								rejected = CheckFlag(memberFlags, 64),
								declined = CheckFlag(memberFlags, 32),
								standby = CheckFlag(memberFlags, 16),
								tank = CheckFlag(memberFlags, 8),
								healer = CheckFlag(memberFlags, 4),
								dps = CheckFlag(memberFlags, 2),
								support = CheckFlag(memberFlags, 1),
							}
						end
					elseif extraID == EVENT_EXTRA.LEVEL_RESTRICTION then
						restrictLevel = { extraBytes[1], extraBytes[2], }
					elseif extraID == EVENT_EXTRA.SQUAD_RESTRICTION then
						local restriction = extraBytes[1]
						restrictSquad = {}
						for index = 8, 1, -1 do
							restrictSquad[index] = restriction % 2 == 1
							restriction = MFloor(restriction / 2)
						end
					end
				end
			
				eventTable[eventID] =
				{
					category = category,
					subcategory = subcategory,
					timestamp = timestamp,
					duration = duration,
					members = members,
					restrictLevel = restrictLevel,
					restrictSquad = restrictSquad,
				}
			else
				eventTable[eventID] = nil
			end

			ResetStorageLimits()
			EventListEvent()
		end
	end
end

local function OnMessage(h, from, msgType, channel, identifier, data)
	if msgType == "guild" and identifier == MESSAGE_EVENT then
		LoadAllEvents()
	end
end


Command.Message.Accept("guild", MESSAGE_EVENT)
Internal.GSM.StartMonitoring(PATTERN_EVENT, true, OnEvent)
CEAttach(Event.Message.Receive, OnMessage, addonID .. ".EventList.Message")
CEAttach(Event[addonID].GuildSettings, function() ResetStorageLimits() end, addonID .. ".EventList.OnGuildSettings")
TInsert(Internal.DataChain, LoadAllEvents)


Internal.EventList = Internal.EventList or {}

Internal.EventList.ReloadEvents = LoadAllEvents

function Internal.EventList.GetList()
	local result = {}
	for id, eventData in pairs(eventTable) do
		result[id] = { category = eventData.category, subcategory = eventData.subcategory, timestamp = eventData.timestamp, duration = eventData.duration, }
	end
	return result
end

function Internal.EventList.GetEventData(eventID)
	local eventData = eventID and eventTable[eventID] or nil
	if not eventData then return nil end
	
	return CopyTableRecursive(eventData)
end

function Internal.EventList.SaveEvent(eventID, category, subcategory, timestamp, duration, members, extra, callback)
	if type(category) ~= "number" or category < 0 or category > 15 then return nil end
	if type(subcategory) ~= "number" or subcategory < 0 or subcategory > 255 then return nil end
	if type(timestamp) ~= "number" or timestamp < 0 or timestamp > 4294967296 then return nil end
	if type(duration) ~= "number" or duration < 0 or duration > 15 then return nil end
	if type(members) ~= "table" then return nil end
	
	if type(eventID) ~= "number" then
		eventID = 0
		for id in pairs(eventTable) do
			eventID = MMax(eventID, id + 1)
		end
	end
	
	local mainBytes = { category, subcategory, BRShift(timestamp, 24) % 256, BRShift(timestamp, 16) % 256, BRShift(timestamp, 8) % 256, timestamp % 256, duration }
	local mainString = Bytes2String(mainBytes)
	
	local memberBytes = {}
	if next(members) then
		TInsert(memberBytes, EVENT_EXTRA.MEMBER_LIST)
		for memberID, memberFlags in pairs(members) do
			memberFlags = (memberFlags.accepted and 128 or 0) + 
			              (memberFlags.rejected and 64 or 0) + 
						  (memberFlags.declined and 32 or 0) + 
						  (memberFlags.standby and 16 or 0) + 
						  (memberFlags.tank and 8 or 0) + 
						  (memberFlags.healer and 4 or 0) + 
						  (memberFlags.dps and 2 or 0) + 
						  (memberFlags.support and 1 or 0)
			TInsert(memberBytes, memberID)
			TInsert(memberBytes, memberFlags)
		end
	end
	local memberLength = #memberBytes
	if memberLength > 0 then
		TInsert(memberBytes, 1, memberLength % 256)
		TInsert(memberBytes, 1, MFloor(memberLength / 256))
	end
	local memberString = Bytes2String(memberBytes)
	
	
	local levelRestrictionBytes = {}
	if extra.restrictLevel then
		TInsert(levelRestrictionBytes, EVENT_EXTRA.LEVEL_RESTRICTION)
		TInsert(levelRestrictionBytes, extra.restrictLevel[1])
		TInsert(levelRestrictionBytes, extra.restrictLevel[2])
	end
	local levelRestrictionLength = #levelRestrictionBytes
	if levelRestrictionLength > 0 then
		TInsert(levelRestrictionBytes, 1, levelRestrictionLength % 256)
		TInsert(levelRestrictionBytes, 1, MFloor(levelRestrictionLength / 256))
	end
	local levelRestrictionString = Bytes2String(levelRestrictionBytes)
	
	local squadRestrictionBytes = {}
	if extra.restrictSquad then
		local totalSquad = 0
		for squad = 1, 8 do
			totalSquad = totalSquad * 2 + (extra.restrictSquad[squad] and 1 or 0)
		end
		TInsert(squadRestrictionBytes, EVENT_EXTRA.SQUAD_RESTRICTION)
		TInsert(squadRestrictionBytes, totalSquad)
	end
	local squadRestrictionLength = #squadRestrictionBytes
	if squadRestrictionLength > 0 then
		TInsert(squadRestrictionBytes, 1, squadRestrictionLength % 256)
		TInsert(squadRestrictionBytes, 1, MFloor(squadRestrictionLength / 256))
	end
	local squadRestrictionString = Bytes2String(squadRestrictionBytes)
	
	local eventString = mainString .. levelRestrictionString .. squadRestrictionString .. memberString

	local storageID = ENTRYNAME_EVENTPREFIX .. ("%X"):format(eventID)
	ResetStorageLimits(storageID)
	StorageSet(storageID, "guild", "guild", eventString, true,
		function() CMBroadcast("guild", nil, MESSAGE_EVENT, "dummy") if type(callback) == "function" then pcall(callback, eventID) end end) -- FIXME Should check the "message" queue

	return eventID
end

function Internal.EventList.DeleteEvent(eventID, callback)
	if not eventID or not eventTable[eventID] then return false end
	
	StorageClear(ENTRYNAME_EVENTPREFIX .. ("%X"):format(eventID),
		function() CMBroadcast("guild", nil, MESSAGE_EVENT, "dummy") if type(callback) == "function" then pcall(callback, eventID) end end) -- FIXME Should check the "message" queue
	
	return true
end
