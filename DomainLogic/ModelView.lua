-- ***************************************************************************************************************************************************
-- * DomainLogic/ModelView.lua                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * Puts together the rest of the logic layer and offers a single interface for the view                                                            *
-- ***************************************************************************************************************************************************
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local AssignSquadID = Internal.MemberList.AssignID
local ChangeMemberList = Internal.MemberList.MassChange
local FreeSquadID = Internal.MemberList.FreeID
local GetEventDescription = Internal.Wall.GetDescription
local GetEventDetail = Internal.EventList.GetEventData
local GetEventList = Internal.EventList.GetList
local GetGuildSettings = Internal.GuildSettings.GetSettings
local GetMemberLevel = Internal.Roster.GetLevel
local GetMemberList = Internal.MemberList.GetList
local GetMemberRank = Internal.Roster.GetRank
local GetPlayerName = Internal.Utility.GetPlayerName
local GetRanks = Internal.Rank.GetRanks
local GetRankPermissions = Internal.Rank.GetRankPermissions
local GetRoster = Internal.Roster.GetRoster
local GetSquadID = Internal.MemberList.GetID
local GetSquadName = Internal.MemberList.GetName
local GetSquadLargeIcon = Internal.DefinitionsView.GetSquadLargeIcon
local GetSquadSmallIcon = Internal.DefinitionsView.GetSquadSmallIcon
local GetWallAuthor = Internal.Wall.GetAuthor
local ITServer = Inspect.Time.Server
local MFloor = math.floor
local OTime = os.time
local ReloadGuildSettings = Internal.GuildSettings.ReloadSettings
local RestoreDefaultGuildSettings = Internal.GuildSettings.RestoreDefaultSettings
local RemoveEvent = Internal.EventList.DeleteEvent
local SChar = string.char
local SaveEvent = Internal.EventList.SaveEvent
local SetGuildSettings = Internal.GuildSettings.SetSettings
local WallDeleteEvent = Internal.Wall.DeleteEvent
local WallPostEvent = Internal.Wall.PostEvent
local pairs = pairs
local type = type

Internal.ModelView = {}

function Internal.ModelView.GetRanks()
	return GetRanks()
end

function Internal.ModelView.GetPermissions()
	return GetRankPermissions(GetMemberRank(GetPlayerName()))
end

function Internal.ModelView.GetRoster()
	local roster = GetRoster()
	for memberName in pairs(roster) do
		local rankID = GetMemberRank(memberName)
		local level = GetMemberLevel(memberName)
		local permissions = GetRankPermissions(rankID)
		if permissions then
			permissions.rank = rankID
			permissions.rankName = permissions.name
			permissions.name = memberName
			permissions.squadID = GetSquadID(memberName)
			permissions.level = level
			roster[memberName] = permissions
		else
			roster[memberName] = nil
		end
	end
	return roster
end

function Internal.ModelView.GetAllSquadIDs()
	return GetMemberList()
end

local function ReassignSquadID(eventID, oldSquadID, newSquadID, nextStep)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.signEvent then return end

	local oldData = GetEventDetail(eventID)
	if not oldData or not oldSquadID or not oldData.members[oldSquadID] then return end
	
	if newSquadID then
		oldData.members[newSquadID] = oldData.members[oldSquadID]
	end
	oldData.members[oldSquadID] = nil
	
	local extra =
	{
		restrictLevel = oldData.restrictLevel,
		restrictSquad = oldData.restrictSquad,
	}
	
	return function() SaveEvent(eventID, oldData.category, oldData.subcategory, oldData.timestamp, oldData.duration, oldData.members, extra, nextStep) end
end

function Internal.ModelView.AssignSquadID(memberName, squadID)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.assignID then return false end
	
	local oldSquadID = GetSquadID(memberName)
	local eventsToChange = {}
	local changeImmediately = true

	if oldSquadID and oldSquadID ~= squadID then
		local events = GetEventList()
		for eventID in pairs(events) do
			local eventData = GetEventDetail(eventID)
			if eventData and eventData.members and eventData.members[oldSquadID] then
				eventsToChange[eventID] = true
				changeImmediately = false
			end
		end
	end
	
	if changeImmediately then
		return (oldSquadID and FreeSquadID(oldSquadID) or true) and AssignSquadID(squadID, memberName)
	else
		local result = AssignSquadID(oldSquadID, "\000\001" .. SChar(squadID)) and AssignSquadID(squadID, memberName)
		if result then
			local nextStep = nil
			for eventID in pairs(eventsToChange) do
				nextStep = ReassignSquadID(eventID, oldSquadID, squadID, nextStep or function() FreeSquadID(oldSquadID) end)
			end
			nextStep()
		end
		return result
	end
end

function Internal.ModelView.FreeSquadID(squadID)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.assignID then return false end

	local events = GetEventList()
	local eventsToClear = {}
	local clearImmediately = true
	for eventID in pairs(events) do
		local eventData = GetEventDetail(eventID)
		if eventData and eventData.members and eventData.members[squadID] then
			eventsToClear[eventID] = true
			clearImmediately = false
		end
	end
	
	if clearImmediately then
		return FreeSquadID(squadID)
	else
		local result = AssignSquadID(squadID, "\000\000")
		if result then
			local nextStep = nil
			for eventID in pairs(eventsToClear) do
				nextStep = ReassignSquadID(eventID, squadID, nil, nextStep or function() FreeSquadID(squadID) end)
			end
			nextStep()
		end
		return result
	end
end

function Internal.ModelView.ChangeSquads(squadList)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.assignID then return false end

	local oldMemberList = GetMemberList()
	local signedMembers = {}
	local signedMembersReverse = {}
	
	local allEvents = GetEventList()
	if allEvents then
		for eventID in pairs(allEvents) do
			local eventData = GetEventDetail(eventID)
			for memberID in pairs(eventData and eventData.members or {}) do
				if oldMemberList[memberID] then
					signedMembers[memberID] = oldMemberList[memberID]
					signedMembersReverse[oldMemberList[memberID]] = memberID
				end
			end
		end
	end
	
	for memberID, memberName in pairs(squadList) do
		if not signedMembers[memberID] and not signedMembersReverse[memberID] then
			signedMembers[memberID] = memberName
			signedMembersReverse[memberName] = memberID
		end
	end
	
	return ChangeMemberList(signedMembers)
end

function Internal.ModelView.GetEventList()
	local events = GetEventList()
	
	for eventID, eventData in pairs(events) do
		eventData.timestamp = MFloor((OTime() + eventData.timestamp - ITServer()) / 300 + .5) * 300
		eventData.author = GetWallAuthor(eventID)
	end
	
	return events
end

function Internal.ModelView.GetEventDetail(eventID)
	local eventData = GetEventDetail(eventID)
	if not eventData then return nil end
	
	eventData.timestamp = MFloor((OTime() + eventData.timestamp - ITServer()) / 300 + .5) * 300
	
	eventData.description = GetEventDescription(eventID)
	eventData.author = GetWallAuthor(eventID)
	
	local memberNames = {}
	local squadIDs = GetMemberList()
	for squadID in pairs(eventData.members) do
		memberNames[squadID] = GetSquadName(squadID)
	end
	eventData.memberNames = memberNames
	
	return eventData
end

function Internal.ModelView.CreateEvent(category, subcategory, year, month, day, hour, minute, duration, description, extra)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.addEvent then return end

	local timestamp = ITServer() + OTime({year = year, month = month, day = day, hour = hour, min = minute, }) - OTime()

	SaveEvent(nil, category, subcategory, timestamp, duration, {}, extra, GetGuildSettings().PostEventsToWall and function(eventID) WallPostEvent(eventID, description) end or nil)
end

function Internal.ModelView.ModifyEvent(eventID, category, subcategory, year, month, day, hour, minute, duration, description, extra)
	local playerName = GetPlayerName()
	local playerPermissions = GetRankPermissions(GetMemberRank(playerName))
	if not playerPermissions.modifyEvent then
		if not playerPermissions.modifyOwnEvent or author ~= GetWallAuthor(eventID) then
			return
		end
	end

	local oldData = GetEventDetail(eventID)
	if not oldData then return end
	
	if not category or not subcategory then
		category = oldData.category
		subcategory = oldData.subcategory
	end
	
	local timestamp = nil
	if not year or not month or not day or not hour or not minute then
		timestamp = oldData.timestamp
	else
		timestamp = ITServer() + OTime({year = year, month = month, day = day, hour = hour, min = minute, }) - OTime()
	end
	
	duration = duration or oldData.duration
	
	description = description or GetEventDescription(eventID)
	
	SaveEvent(eventID, category, subcategory, timestamp, duration, oldData.members, extra, GetGuildSettings().PostEventsToWall and function(eventID) WallPostEvent(eventID, description) end or nil)
end

function Internal.ModelView.DeleteEvent(eventID)
	local playerName = GetPlayerName()
	local playerPermissions = GetRankPermissions(GetMemberRank(playerName))
	if not playerPermissions.removeEvent then
		if not playerPermissions.removeOwnEvent or author ~= GetWallAuthor(eventID) then
			return
		end
	end

	RemoveEvent(eventID, function() WallDeleteEvent(eventID) end)
end

function Internal.ModelView.SignEvent(eventID, memberName, tank, healer, dps, support, standby, declined, accepted, rejected)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.signEvent then return end

	local oldData = GetEventDetail(eventID)
	local memberID = GetSquadID(memberName)
	if not oldData or not memberID then return end
	
	oldData.members[memberID] =
	{
		tank = tank and true or false,
		healer = healer and true or false,
		dps = dps and true or false,
		support = support and true or false,
		standby = standby and true or false,
		declined = declined and true or false,
		accepted = accepted and true or false,
		rejected = rejected and true or false		
	}
	
	local extra =
	{
		restrictLevel = oldData.restrictLevel,
		restrictSquad = oldData.restrictSquad,
	}
	
	SaveEvent(eventID, oldData.category, oldData.subcategory, oldData.timestamp, oldData.duration, oldData.members, extra)
end

function Internal.ModelView.UnsignEvent(eventID, memberName)
	local playerPermissions = GetRankPermissions(GetMemberRank(GetPlayerName()))
	if not playerPermissions.signEvent then return end

	local oldData = GetEventDetail(eventID)
	local memberID = GetSquadID(memberName)
	if not oldData or not memberID or not oldData.members[memberID] then return end
	
	oldData.members[memberID] = nil
	
	local extra =
	{
		restrictLevel = oldData.restrictLevel,
		restrictSquad = oldData.restrictSquad,
	}
	
	SaveEvent(eventID, oldData.category, oldData.subcategory, oldData.timestamp, oldData.duration, oldData.members, extra)
end

function Internal.ModelView.GetSquadsNumber()
	return 2 ^ GetGuildSettings().SquadNumber
end

function Internal.ModelView.GetSquadSize()
	return 2 ^ (8 - GetGuildSettings().SquadNumber)
end

function Internal.ModelView.GetSquadLargeIcon(index)
	return GetSquadLargeIcon(GetGuildSettings().Squads[index])
end

function Internal.ModelView.GetSquadSmallIcon(index)
	return GetSquadSmallIcon(GetGuildSettings().Squads[index])
end

function Internal.ModelView.GetSquadSmallIconAndNumber(squadID)
	local guildSettings = GetGuildSettings()
	local divisor = 2 ^ (8 - guildSettings.SquadNumber)
	return GetSquadSmallIcon(guildSettings.Squads[MFloor(squadID / divisor) + 1]), (squadID % divisor) + 1
end

function Internal.ModelView.GetGuildSettings()
	return GetGuildSettings()
end

function Internal.ModelView.ReloadGuildSettings()
	ReloadGuildSettings()
end

function Internal.ModelView.SaveGuildSettings(settings)
	SetGuildSettings(settings)
end

function Internal.ModelView.RestoreDefaultGuildSettings()
	RestoreDefaultGuildSettings()
end
