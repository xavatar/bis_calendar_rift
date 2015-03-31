-- ***************************************************************************************************************************************************
-- * DomainLogic/Wall.lua                                                                                                                            *
-- ***************************************************************************************************************************************************
-- * Maintains guild wall data                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.1 / 2012.01.05 / Baanano: Now tracks wallpost author too                                                                                    *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local CGWDelete = Command.Guild.Wall.Delete
local CGWPost = Command.Guild.Wall.Post
local CGWRequest = Command.Guild.Wall.Request
local IGRList = Inspect.Guild.Roster.List
local IQStatus = Inspect.Queue.Status
local TInsert = table.insert
local pairs = pairs
local tonumber = tonumber
local type = type

local WALL_FORMAT = "[BiSCal|%X] %s"
local WALL_PATTERN = "^%[BiSCal|(%x*)%] (.*)"

local wallEvents = {}
local needRefresh = false

local WallEvent = Utility.Event.Create(addonID, "Wall")

local function LoadWall()
	if IGRList() then
		needRefresh = true
	end
end

local function OnFrame()
	if needRefresh and IQStatus("bulk") then
		CGWRequest()
		needRefresh = false
	end
end

local function BuildWallTable(h, wall)
	wallEvents = {}
	for _, wallData in pairs(wall) do
		local wallID = wallData.id
		local wallText = wallData.text
		
		local eventID, eventDescription = nil, nil
		if wallText then
			wallText:gsub(WALL_PATTERN, function(id, description) eventID, eventDescription = tonumber(id, 16), description end)
		end
		
		if eventID and eventDescription then
			if not wallEvents[eventID] or wallEvents[eventID].time < wallData.time then
				local oldID = wallEvents[eventID] and wallEvents[eventID].wallID or nil
				if oldID then
					CGWDelete(oldID)
				end
				wallEvents[eventID] = { wallID = wallID, description = eventDescription, time = wallData.time, author = wallData.poster, }
			end
		end
	end
	WallEvent()
end


CEAttach(Event.Guild.Wall, BuildWallTable, addonID .. ".Wall.OnWall")
CEAttach(Event.System.Update.Begin, OnFrame, addonID .. ".Wall.OnFrame")
TInsert(Internal.DataChain, LoadWall)


Internal.Wall = Internal.Wall or {}

function Internal.Wall.GetDescription(eventID)
	return eventID and wallEvents[eventID] and wallEvents[eventID].description or ""
end

function Internal.Wall.GetWallID(eventID)
	return eventID and wallEvents[eventID] and wallEvents[eventID].wallID or nil
end

function Internal.Wall.GetAuthor(eventID)
	return eventID and wallEvents[eventID] and wallEvents[eventID].author or nil
end

function Internal.Wall.PostEvent(eventID, description)
	if not eventID or type(description) ~= "string" then return false end
	if wallEvents[eventID] then
		CGWDelete(wallEvents[eventID].wallID)
	end
	CGWPost(WALL_FORMAT:format(eventID, description), function(failed) LoadWall() end)
end

function Internal.Wall.DeleteEvent(eventID)
	if eventID and wallEvents[eventID] then
		CGWDelete(wallEvents[eventID].wallID, function(failed) LoadWall() end)
	end
end
