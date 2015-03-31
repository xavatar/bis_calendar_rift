-- ***************************************************************************************************************************************************
-- * Utility.lua                                                                                                                                     *
-- ***************************************************************************************************************************************************
-- * Description                                                                                                                                     *
-- ***************************************************************************************************************************************************
-- * 0.0.1 / 2012.01.05 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier
_G[addonID] = _G[addonID] or {}

local CSGet = Command.Storage.Get
local CSList = Command.Storage.List
local IUDetail = Inspect.Unit.Detail
local SChar = string.char
local TConcat = table.concat
local TInsert = table.insert
local pairs = pairs
local type = type

local playerName = nil

Internal.Utility = Internal.Utility or {}

function Internal.Utility.GetPlayerName()
	if not playerName then
		local playerDetail = IUDetail("player")
		playerName = playerDetail and playerDetail.name or nil
	end
	return playerName
end

-- ***************************************************************************************************************************************************
-- * CopyTableSimple                                                                                                                                 *
-- ***************************************************************************************************************************************************
-- * Returns a shallow copy of a table, without its metatable                                                                                        *
-- ***************************************************************************************************************************************************
function Internal.Utility.CopyTableSimple(sourceTable)
	local copy = {}
	for key, value in pairs(sourceTable) do 
		copy[key] = value 
	end
	return copy
end

-- ***************************************************************************************************************************************************
-- * CopyTableRecursive                                                                                                                              *
-- ***************************************************************************************************************************************************
-- * Returns a deep copy of a table, without its metatable                                                                                           *
-- ***************************************************************************************************************************************************
function Internal.Utility.CopyTableRecursive(sourceTable)
	local copy = {}
	for key, value in pairs(sourceTable) do
		copy[key] = type(value) == "table" and Internal.Utility.CopyTableRecursive(value) or value
	end
	return copy
end

function Internal.Utility.String2Bytes(str)
	local result = {}
	str:gsub("(.)", function(c) TInsert(result, c:byte()) end)
	return result
end

function Internal.Utility.Bytes2String(bytes)
	local result = {}
	for index, byte in ipairs(bytes) do result[index] = SChar(byte) end
	return TConcat(result)
end

function Internal.Utility.Debug(msg)
	if Internal.AccountSettings.Debug then
		print(msg)
	end
end
