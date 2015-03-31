-- ***************************************************************************************************************************************************
-- * DomainLogic/Rank.lua                                                                                                                            *
-- ***************************************************************************************************************************************************
-- * Maintains guild rank data                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.0.3 / 2012.01.12 / Baanano: Added noteOfficer, modifyOwnEvent and removeOwnEvent permissions                                                               *
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local IGKDetail = Inspect.Guild.Rank.Detail
local IGKList = Inspect.Guild.Rank.List
local TInsert = table.insert
local pairs = pairs
local type = type

local loaded = false
local ranks = {}

local RankEvent = Utility.Event.Create(addonID, "Rank")

local function UpdateRankPermissions(rank, rankData)
	if type(rank) ~= "string" then return end
	if type(tankData) ~= "table" then
		rankData = IGKDetail(rank)
	end
	ranks[rank] = rankData and
	{
		name = rankData.name,
		officer = rankData.officer,
		storagePost = rankData.addonStorageWrite,
		storageDelete = rankData.addonStorageDelete,
		wallPost = rankData.wallPost,
		wallDelete = rankData.wallDelete,
		noteOfficer = rankData.noteOfficer,
	} or nil
	RankEvent()
end

local function BuildFullRankPermissions()
	ranks = {}
	local list = IGKList()
	if list then
		for rank, rankData in pairs(IGKDetail(list)) do
			UpdateRankPermissions(rank, rankData)
		end
	end
	RankEvent()
end

CEAttach(Event.Guild.Rank, function(h, ranks) for rank in pairs(ranks) do UpdateRankPermissions(rank) end end, addonID .. ".OnRank")
TInsert(Internal.DataChain, BuildFullRankPermissions)


Internal.Rank = Internal.Rank or {}

function Internal.Rank.GetRanks()
	local result = {}
	for rank, rankData in pairs(ranks) do
		result[rank] = rankData.name
	end
	return result
end

function Internal.Rank.GetRankPermissions(rank)
	local rankData = rank and ranks[rank] or nil
	return rankData and
	{
		name = rankData.name,
		assignID = rankData.officer and rankData.storagePost and rankData.storageDelete and true or false,
		addEvent = rankData.wallPost and rankData.storagePost and true or false,
		modifyEvent = rankData.wallPost and rankData.wallDelete and rankData.storagePost and rankData.storageDelete and true or false,
		modifyOwnEvent = rankData.wallPost and rankData.storagePost and rankData.storageDelete and true or false,
		removeEvent = rankData.wallDelete and rankData.storageDelete and true or false,
		removeOwnEvent = rankData.storageDelete and true or false,
		signEvent = rankData.storagePost and rankData.storageDelete and true or false,
		noteOfficer = rankData.noteOfficer and true or false,
	} or nil
end
