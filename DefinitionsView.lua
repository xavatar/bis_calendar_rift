-- ***************************************************************************************************************************************************
-- * DefinitionsView.lua                                                                                                                             *
-- ***************************************************************************************************************************************************
-- * Provides access to the Definitions table                                                                                                        *
-- ***************************************************************************************************************************************************
-- * 0.0.6 / 2013.01.14 / Baanano: Extracted event definitions to a separate file                                                                    *
-- * 0.0.6 / 2013.01.13 / Odine:   Updated list to include all known raids and other various misc events                                             *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local CopyTableSimple = Internal.Utility.CopyTableSimple
local pairs = pairs

local UNKNOWN_EVENT_NAME = "Unknown"
local UNKNOWN_EVENT_ICON = { "Rift", "zone_event_icon.png.dds", }
local DEFAULT_SQUAD_LARGEICON = { "Rift", "vfx_ui_mob_tag_no.png.dds", }
local DEFAULT_SQUAD_SMALLICON = { "Rift", "vfx_ui_mob_tag_no_mini.png.dds", }

Internal.DefinitionsView = Internal.DefinitionsView or {}

function Internal.DefinitionsView.GetEventCategories()
	local result = {}
	
	for categoryID, categoryData in pairs(Internal.Definitions.EventTypes) do
		result[categoryID] = { name = categoryData.name, id = categoryID, order = categoryData.order, }
	end
	
	return result
end

function Internal.DefinitionsView.GetEventSubcategories(category)
	local result = {}
	if not category or not Internal.Definitions.EventTypes[category] then return result end
	
	for subcategoryID, subcategoryData in pairs(Internal.Definitions.EventTypes[category].subcategories) do
		result[subcategoryID] = { name = subcategoryData.name, id = subcategoryID, order = subcategoryData.order, }
	end
	
	return result
end

function Internal.DefinitionsView.GetEventName(category, subcategory)
	return category and subcategory and Internal.Definitions.EventTypes[category] and Internal.Definitions.EventTypes[category].subcategories[subcategory] and Internal.Definitions.EventTypes[category].subcategories[subcategory].name or UNKNOWN_EVENT_NAME
end

function Internal.DefinitionsView.GetEventIcon(category, subcategory)
	return category and subcategory and Internal.Definitions.EventTypes[category] and Internal.Definitions.EventTypes[category].subcategories[subcategory] and Internal.Definitions.EventTypes[category].subcategories[subcategory].icon or UNKNOWN_EVENT_ICON
end



function Internal.DefinitionsView.GetSquads()
	local result = {}
	
	for squad, squadData in pairs(Internal.Definitions.Squads) do
		result[squad] = { name = squadData.name, id = squad, }
	end
	
	return result
end

function Internal.DefinitionsView.GetSquadLargeIcon(squad)
	return squad and Internal.Definitions.Squads[squad] and Internal.Definitions.Squads[squad].icon_large or DEFAULT_SQUAD_LARGEICON
end

function Internal.DefinitionsView.GetSquadSmallIcon(squad)
	return squad and Internal.Definitions.Squads[squad] and Internal.Definitions.Squads[squad].icon_small or DEFAULT_SQUAD_SMALLICON
end



function Internal.DefinitionsView.GetThemes()
	local result = {}
	
	for theme, themeData in pairs(Internal.Definitions.Themes) do
		result[theme] = { name = themeData.name, number = themeData.number, squads = CopyTableSimple(themeData.squads), id = theme, }
	end
	
	return result
end
