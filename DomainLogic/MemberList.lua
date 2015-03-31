-- ***************************************************************************************************************************************************
-- * LL/MemberList.lua                                                                                                                               *
-- ***************************************************************************************************************************************************
-- * Maintains guild member list data                                                                                                                *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local CMBroadcast = Command.Message.Broadcast
local GetPlayerName = Internal.Utility.GetPlayerName
local SChar = string.char
local StorageRefresh = Internal.GSM.Refresh
local StorageClear = Internal.GSM.Clear
local StorageSet = Internal.GSM.Set
local TInsert = table.insert
local pairs = pairs
local tonumber = tonumber
local type = type

local memberName2ID = {}
local memberID2Name = {}

local MemberListEvent = Utility.Event.Create(addonID, "MemberList")

local ENTRYNAME_MEMBERLIST = "BiSCalMembers"
local PATTERN_MEMBERLIST = "^BiSCalMembers$"
local MESSAGE_MEMBERLIST = "BiSCalMemberListChanged"

local function LoadMemberList()
	StorageRefresh()
end

local function SaveMemberList()
	if type(memberID2Name) == "table" then
		local data = ""
		for id, name in pairs(memberID2Name) do
			data = data .. SChar(name:len(), id) .. name
		end
		if data:len() > 0 then
			StorageSet(ENTRYNAME_MEMBERLIST, "guild", "officer", data, true,
				function() CMBroadcast("guild", nil, MESSAGE_MEMBERLIST, "dummy") end) -- FIXME Should check the "message" queue
		else
			StorageClear(ENTRYNAME_MEMBERLIST,
				function() CMBroadcast("guild", nil, MESSAGE_MEMBERLIST, "dummy") end) -- FIXME Should check the "message" queue
		end
	end
end

local function OnMemberList(identifier, data)
	if identifier == ENTRYNAME_MEMBERLIST then
		memberName2ID, memberID2Name = {}, {}
		
		data = type(data) == "string" and data or ""
		while data:len() > 0 do
			local length = data:sub(1, 1):byte()
			
			local memberData = data:sub(2, 2 + length)
			data = data:sub(3 + length)
			
			local memberID = memberData:sub(1, 1):byte()
			local memberName = memberData:sub(2):gsub(" ", "")
			if type(memberID) == "number" and memberName:len() > 0 then
				memberID2Name[memberID] = memberName
				memberName2ID[memberName] = memberID
			end
		end
			
		MemberListEvent()
	end
end

local function OnMessage(h, from, msgType, channel, identifier, data)
	if msgType == "guild" and identifier == MESSAGE_MEMBERLIST then
		LoadMemberList()
	end
end


Command.Message.Accept("guild", MESSAGE_MEMBERLIST)
Internal.GSM.StartMonitoring(PATTERN_MEMBERLIST, true, OnMemberList)
CEAttach(Event.Message.Receive, OnMessage, addonID .. ".MemberList.Message")
TInsert(Internal.DataChain, LoadMemberList)


Internal.MemberList = Internal.MemberList or {}

Internal.MemberList.ReloadMembers = LoadMemberList

function Internal.MemberList.GetList()
	local result = {}
	for id, name in pairs(memberID2Name) do
		result[id] = name
	end
	return result
end

function Internal.MemberList.GetName(memberID)
	return memberID and memberID2Name[memberID] or nil
end

function Internal.MemberList.GetID(name)
	return name and memberName2ID[name] or nil
end

function Internal.MemberList.AssignID(memberID, name)
	if type(memberID) ~= "number" or memberID < 0 or memberID > 255 then return false end
	if type(name) ~= "string" then return false end
	
	memberID2Name[memberID] = name
	memberName2ID[name] = memberID
	
	SaveMemberList()
	
	return true
end

function Internal.MemberList.FreeID(memberID)
	if type(memberID) ~= "number" or memberID < 0 or memberID > 255 then return false end
	
	local name = memberID2Name[memberID]
	
	if not name then return false end
	
	memberID2Name[memberID] = nil
	memberName2ID[name] = nil
	
	SaveMemberList()
	
	return true	
end

function Internal.MemberList.MassChange(memberList)
	if type(memberList) ~= "table" then return false end
	
	memberID2Name = {}
	memberName2ID = {}
	
	for memberID, memberName in pairs(memberList) do
		if type(memberID) == "number" and memberID >= 0 and memberID <= 255 then
			memberID2Name[memberID] = memberName
			memberName2ID[memberName] = memberID
		end
	end
	
	SaveMemberList()
	
	return true
end
