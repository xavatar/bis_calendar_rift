-- ***************************************************************************************************************************************************
-- * GSM.lua                                                                                                                                         *
-- ***************************************************************************************************************************************************
-- * Guild storage monitor                                                                                                                           *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- *  1.0.0 / 2012.02.05 / Baanano: Made a separate library                                                                                          *
-- * 0.0.70 / 2012.01.24 / Baanano: First version                                                                                                    *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

_G[addonID] = _G[addonID] or {}
local Public = _G[addonID]

local CEAttach = Command.Event.Attach
local CSClear = Command.Storage.Clear
local CSGet = Command.Storage.Get
local CSList = Command.Storage.List
local CSSet = Command.Storage.Set
local Deflate = function(x) return zlib.deflate(zlib.BEST_COMPRESSION)(x, "finish") end
local IQStatus = Inspect.Queue.Status
local ISUsed = Inspect.Storage.Used
local ITFrame = Inspect.Time.Frame
local IUDetail = Inspect.Unit.Detail
local Inflate = function(x) return zlib.inflate()(x) end
local MFloor = math.floor
local MMax = math.max
local TInsert = table.insert
local TRemove = table.remove
local USChecksum = Utility.Storage.Checksum
local ipairs = ipairs
local next = next
local pairs = pairs
local pcall = pcall
local type = type

local DEFAULT_RETRIES = 3
local DEFAULT_REFRESH = 60

local playerName = nil

local defaultRetries = DEFAULT_RETRIES
local defaultRefresh = DEFAULT_REFRESH

local queue = {}
local lastRefresh = nil

local knownIdentifiers = {}
local values = {}

local deliverOnce = {}
local monitoring = { compressed = {}, plain = {}, }

local limitedIdentifiers = {}
local limitedGroups = {}
local lastGroup = 0

local function GetPlayerName()
	if not playerName then
		local playerDetail = IUDetail("player")
		playerName = playerDetail and playerDetail.name or nil
	end
	return playerName
end

local function Enqueue(func, onSuccess, onError, onExpire, retries)
	if type(func) == "function" then
		TInsert(queue,
		{
			work = func, 
			success = type(onSuccess) == "function" and onSuccess or function() end,
			error = type(onSuccess) == "function" and onError or function() end,
			expired = type(onExpire) == "function" and onExpire or function() end,
			retries = type(retries) == "number" and MFloor(retries) or defaultRetries,
		})
	end
end

local function OnFrame()
	while IQStatus("storage") do
		local task = TRemove(queue, 1)
		if task then
			if task.retries < 0 then
				pcall(task.expired)
			else
				if not pcall(task.work, function(failed) if failed then Enqueue(task.work, task.success, task.error, task.expired, task.retries - 1) else pcall(task.success) end end) then
					pcall(task.error)
				end
			end
		else
			break
		end
	end

	if defaultRefresh > 0 and (next(monitoring.compressed) or next(monitoring.plain)) and (not lastRefresh or lastRefresh + defaultRefresh < ITFrame()) then
		local playerName = GetPlayerName()
		if playerName then
			lastRefresh = ITFrame()
			Enqueue(function(callback) CSList(playerName, "guild", callback) end, nil, nil, nil, 0)
		end
	end
end
CEAttach(Event.System.Update.Begin, OnFrame, addonID .. ".Event.System.Update.Begin")

local function VariableRetrieved(identifier, value)
	if value and not knownIdentifiers[identifier] then
		knownIdentifiers[identifier] = USChecksum(value)
	end
	local lastValue = values[identifier]
	values[identifier] = value
	
	if deliverOnce[identifier] then
		for _, Deliver in ipairs(deliverOnce[identifier]) do
			Deliver(identifier, value)
		end
		deliverOnce[identifier] = nil
	end
	
	if value ~= lastValue then
		for id, observers in pairs(monitoring.plain) do
			if identifier:find(id) then
				for Observer in pairs(observers) do
					pcall(Observer, identifier, value)
				end
			end
		end

		local ok, uncompressedValue
		if value == nil then
			ok, uncompressedValue = true, nil
		else
			ok, uncompressedValue = pcall(Inflate, value)
		end
		if ok then
			for id, observers in pairs(monitoring.compressed) do
				if identifier:find(id) then
					for Observer in pairs(observers) do
						pcall(Observer, identifier, uncompressedValue)
					end
				end
			end
		end
	end
end

local function VariableModified(identifier, checksum, value)
	knownIdentifiers[identifier] = checksum
	
	if value or not checksum then
		VariableRetrieved(identifier, value or nil)
	else
		values[identifier] = nil
		local playerName = GetPlayerName()
		if playerName then
			Enqueue(function(callback) CSGet(playerName, "guild", identifier, callback) end)
		end
	end
end

function Public.GetDefaultRetries()
	return defaultRetries
end

function Public.SetDefaultRetries(retries)
	defaultRetries = type(retries) == "number" and MFloor(retries) >= 0 and MFloor(retries) or defaultRetries
end

function Public.GetDefaultRefresh()
	return defaultRefresh
end

function Public.SetDefaultRefresh(refresh)
	defaultRefresh = type(refresh) == "number" and MFloor(refresh) >= 0 and MFloor(refresh) or defaultRefresh
end

function Public.GetUsedStorage()
	return (ISUsed("guild"))
end

function Public.GetMaximumStorage()
	local _, maximum = ISUsed("guild")
	return maximum
end

function Public.GetAvailableStorage()
	local current, maximum = ISUsed("guild")
	return maximum - current
end

function Public.Refresh(onSuccess, onError, onExpire, retries)
	local playerName = GetPlayerName()
	if playerName then
		lastRefresh = ITFrame()
		Enqueue(function(callback) CSList(playerName, "guild", callback) end, onSuccess, onError, onExpire, retries)
	elseif type(onError) == "function" then
		pcall(onError)
	end
end

local function OnList(h, target, segment, identifiers)
	if target == GetPlayerName() and segment == "guild" then
		lastRefresh = ITFrame()

		for identifier, checksum in pairs(knownIdentifiers) do
			if not identifiers[identifier] then
				VariableModified(identifier)
			elseif identifiers[identifier] ~= checksum then
				VariableModified(identifier, identifiers[identifier])
			end
		end
		
		for identifier, checksum in pairs(identifiers) do
			if not knownIdentifiers[identifier] then
				VariableModified(identifier, checksum)
			end
		end
	end
end
CEAttach(Event.Storage.List, OnList, addonID .. ".Event.Storage.List")

function Public.Get(identifier, compressed, deliverTo, forceRefresh, onSuccess, onError, onExpire, retries)
	if type(identifier) ~= "string" or identifier:len() < 3 then
		if type(onError) == "function" then
			pcall(onError)
		end
		return
	end
	
	local function Deliver(id, value)
		if type(deliverTo) == "function" then
			if compressed then
				local ok, uncompressedValue = pcall(Inflate, value)
				if ok then
					pcall(deliverTo, id, uncompressedValue)
				elseif type(onError) == "function" then
					pcall(onError)
				end
			else
				pcall(deliverTo, id, value)
			end
		end
	end
	
	if not forceRefresh and values[identifier] then
		if type(onSuccess) == "function" then
			pcall(onSuccess)
		end
		Deliver(identifier, values[identifier])
	else
		local playerName = GetPlayerName()
		if playerName then
			deliverOnce[identifier] = deliverOnce[identifier] or {} 
			TInsert(deliverOnce[identifier], Deliver)
			Enqueue(function(callback) CSGet(playerName, "guild", identifier, callback) end, onSuccess, onError, onExpire, retries)
		elseif type(onError) == "function" then
			pcall(onError)
		end
	end
end

function Public.GetSize(identifier)
	if identifier and values[identifier] then
		return MMax(values[identifier]:len() + identifier:len(), 64)
	else
		Enqueue(function(callback) CSGet(playerName, "guild", identifier, callback) end)
		return 0
	end
end

local function OnGet(h, target, segment, identifier, read, write, data)
	if segment == "guild" and target == GetPlayerName() then
		VariableRetrieved(identifier, data)
	end
end
CEAttach(Event.Storage.Get, OnGet, addonID .. ".Event.Storage.Get")

function Public.Set(identifier, read, write, value, compress, onSuccess, onError, onExpire, retries)
	if type(identifier) ~= "string" or identifier:len() < 3 then
		if type(onError) == "function" then
			pcall(onError)
		end	
		return
	end

	if compress then
		local ok
		ok, value = pcall(Deflate, value)
		if not ok then
			if type(onError) == "function" then
				pcall(onError)
			end	
			return
		end
	end
	
	local current, maximum = ISUsed("guild")
	local availableStorage = maximum - current
	if values[identifier] then
		availableStorage = availableStorage + MMax(values[identifier]:len() + identifier:len(), 64)
	end
	if MMax(value:len() + identifier:len(), 64) > availableStorage then
		if type(onError) == "function" then
			pcall(onError)
		end	
		return
	end
	
	if limitedIdentifiers[identifier] then
		for groupID in pairs(limitedIdentifiers[identifier]) do
			local group = limitedGroups[groupID]
			if group then
				local groupMaxSize = group.size
				
				local groupTotalSize = MMax(value:len() + identifier:len(), 64)
				for _, groupIdentifier in pairs(group.identifiers) do
					if groupIdentifier ~= identifier and values[groupIdentifier] then
						groupTotalSize = groupTotalSize + MMax(groupIdentifier:len() + values[groupIdentifier]:len(), 64)
					end
				end
				
				if groupTotalSize > groupMaxSize then
					if type(onError) == "function" then
						pcall(onError)
					end	
					return
				end
			end
		end
	end
	
	local function success()
		local checksum, lastChecksum = USChecksum(value), knownIdentifiers[identifier]
		
		if not lastChecksum or lastChecksum ~= checksum then
			VariableModified(identifier, checksum, value)
		end
		
		if type(onSuccess) == "function" then
			pcall(onSuccess)
		end
	end
	Enqueue(function(callback) CSSet("guild", identifier, read, write, value, callback) end, success, onError, onExpire, retries)
end

function Public.Clear(identifier, onSuccess, onError, onExpire, retries)
	local function success()
		VariableModified(identifier)
		
		if type(onSuccess) == "function" then
			pcall(onSuccess)
		end
	end
	Enqueue(function(callback) CSClear("guild", identifier, callback) end, success, onError, onExpire, retries)
end

function Public.StartMonitoring(pattern, compressed, observer)
	if type(pattern) ~= "string" or type(observer) ~= "function" then return end
	
	local assignTo = monitoring[compressed and "compressed" or "plain"]
	assignTo[pattern] = assignTo[pattern] or {}
	assignTo[pattern][observer] = true
	
	for identifier, value in pairs(values) do
		if identifier:find(pattern) then
			if compressed then
				local ok
				ok, value = pcall(Inflate, value)
				if not ok then
					value = nil
				end
			end
			pcall(observer, identifier, value)
		end
	end
end

function Public.StopMonitoring(pattern, compressed, observer)
	if not pattern or not observer then return end
	
	local unassignFrom = monitoring[compressed and "compressed" or "plain"]
	if unassignFrom[pattern] then
		unassignFrom[pattern][observer] = nil
	end
end

function Public.SetStorageLimit(identifiers, size)
	if type(identifiers) == "string" then
		identifiers = { identifiers }
	end
	size = type(size) == "number" and MFloor(size) or 0
	if type(identifiers) ~= "table" or size < 64 then return nil end
	
	lastGroup = lastGroup + 1
	
	local validIdentifiers = {}
	
	for _, identifier in pairs(identifiers) do
		if type(identifier) == "string" then
			limitedIdentifiers[identifier] = limitedIdentifiers[identifier] or {}
			limitedIdentifiers[identifier][lastGroup] = true
			TInsert(validIdentifiers, identifier)
		end
	end
	
	if #validIdentifiers < 1 then
		lastGroup = lastGroup - 1
		return nil
	end
	
	limitedGroups[lastGroup] =
	{
		identifiers = validIdentifiers,
		size = size,
	}
	
	return lastGroup
end

function Public.ClearStorageLimit(group)
	local clearIdentifiers = group and limitedGroups[group] and limitedGroups[group].identifiers or nil
	if clearIdentifiers then
		limitedGroups[group] = nil
		for _, identifier in pairs(clearIdentifiers) do
			limitedIdentifiers[identifier][group] = nil
		end
	end
end
