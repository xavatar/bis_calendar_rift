-- ***************************************************************************************************************************************************
-- * Plugin.lua                                                                                                                                      *
-- ***************************************************************************************************************************************************
-- * Provides support so other addons are able to work as plugins for BiSCal                                                                         *
-- ***************************************************************************************************************************************************
-- * 0.2.89 / 2012.01.30 / Baanano: First version                                                                                                    *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

_G[addonID] = _G[addonID] or {}
local Public = _G[addonID]

local CopyTableRecursive = Internal.Utility.CopyTableRecursive
local type = type

local plugins = {}

Internal.Plugin = Internal.Plugin or {}

function Internal.Plugin.GetPlugins()
	return CopyTableRecursive(plugins)
end

function Public.RegisterPlugin(pluginName, tabName, tabConstructor, configName, configConstructor)
	print("Registered" .. pluginName)
	if type(pluginName) == "string" and not plugins[pluginName] and type(tabName) == "string" and type(tabConstructor) == "function" and ((not configName and not configConstructor) or (type(configName) == "string" and type(configConstructor) == "function")) then
		plugins[pluginName] =
		{
			tabName = tabName,
			tabConstructor = tabConstructor,
			configName = configName,
			configConstructor = configConstructor,
		}
		return true
	end
	return false
end