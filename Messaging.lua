-- ***************************************************************************************************************************************************
-- * VersionCheck.lua 
-- ***************************************************************************************************************************************************
-- * This lets other addon users know if their version of BiSCal is out-of-date                                                                                                                             *
-- ***************************************************************************************************************************************************
-- * 0.5.134/ 2013.09.22 / Baanano: Updated to the new event model                                                                                   *
-- * 0.1.75 / 2013.01.26 / Odine: 3rd take
-- ***************************************************************************************************************************************************
local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CEAttach = Command.Event.Attach
local playerName = nil
local TInsert = table.insert
local L = Internal.Localization.L
local version = addonInfo.toc.Version
local latestVersionSeen = addonInfo.toc.Version

local messageBuilders = {}


function Internal.Version.Version()
	return "Version;" .. version
end

function Internal.Version.Startup()
	local message = Internal.Version.Version()
	
	Command.Message.Broadcast("guild", nil, "CALVersion", message, function(failure, message) end)
	Command.Message.Broadcast("yell", nil, "CALVersion", message, function(failure, message) end)
end


local function compareVersions(va, vb)
	local a = string.split(va, "[%. ]+", true)
	local b = string.split(vb, "[%. ]+", true)
	
	for i = 1, math.max(#a, #b), 1 do
		if a[i] == nil then
			return 1
		elseif b[i] == nil then
			return -1
		elseif a[i] == b[i] then
			-- Do nothing
		else
			local na = tonumber(a[i])
			local nb = tonumber(b[i])
			
			if na and nb then
				return (nb - na) / math.abs(nb - na)
			elseif na == nil and nb ~= nil then
				return 1
			elseif na ~= nil and nb == nil then
				return -1
			elseif a[i] < b[i] then
				return 1
			else
				return -1
			end
		end
	end
	
	return 0
end


function Internal.Version.MsgHandler(h, from, type, channel, identifier, data)
	if identifier ~= "CALVersion" then return end
	if from == playerName then return end
	
	local msg = string.split(data, ";")
	
	if msg[1] == "Version" then
		Internal.Utility.Debug(string.format("Player %s has BiSCal v%s", from, msg[2]))

		if msg[3] ~= nil and compareVersions(version, msg[3]) > 0 then
			print(string.format(L["VersionCheck/OldVersion"], msg[3]))
			latestVersionSeen = msg[3]
		end
		
		local reply = false
		local existingUser = Internal.Version.Users[from]
		if existingUser then
			reply = Inspect.Time.Real() - (existingUser.discovered or 0) > 120
			existingUser.version = msg[2]
			existingUser.discovered = Inspect.Time.Real()
		else
			reply = true
			Internal.Version.AddUser(from, msg[2])
		end
		
		if type ~= "send" and reply then
			Command.Message.Send(from, "CALVersion", Internal.Version.Version(), function(failure, message) end)
		end
	end
	
end

function Internal.Version.AddUser(character, version, calling)
	Internal.Version.Users[character] =
	{
		version = version,
		discovered = Inspect.Time.Real(),
	}
end


local runOnce = false
local function checkUnitAvail()
	if not runOnce then
		local detail = Inspect.Unit.Detail("player")
		
		if detail.name then
			playerName = detail.name
			Internal.Version.Startup()
			CEAttach(Event.Message.Receive, Internal.Version.MsgHandler, addonID .. ".Event.Message.Receive")
			Command.Message.Accept(nil, "CALVersion")
			runOnce = true
		end		
	end
end
CEAttach(Event.Unit.Availability.Full, checkUnitAvail, addonID ..  ".Version.Check.Start")
