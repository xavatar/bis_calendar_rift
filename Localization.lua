-- ***************************************************************************************************************************************************
-- * Localization.lua                                                                                                                                *
-- ***************************************************************************************************************************************************
-- * Provides support for localization                                                                                                               *
-- ***************************************************************************************************************************************************
-- * 0.0.3 / 2013.01.12 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier
Internal.Localization = Internal.Localization or {}

local CopyTableSimple = Internal.Utility.CopyTableSimple
local TInsert = table.insert
local pairs = pairs
local rawset = rawset
local setmetatable = setmetatable
local type = type

local languages = {}

local function SelectLocale()
	local locale = Internal.AccountSettings.Language
	locale = locale and languages[locale] or languages["English"]
	for key, englishPhrase in pairs(languages["English"]) do
		Internal.Localization.L[key] = locale[key] or englishPhrase
	end
	
	for language in pairs(languages) do
		languages[language] = true
	end
end

TInsert(Internal.UIChain, SelectLocale)

-- ***************************************************************************************************************************************************
-- * L (table)                                                                                                                                       *
-- ***************************************************************************************************************************************************
-- * Returns the translation of the key in the loaded locale                                                                                         *
-- * Source: http://wowprogramming.com/forums/development/596                                                                                        *
-- ***************************************************************************************************************************************************
Internal.Localization.L = Internal.Localization.L or {}
setmetatable(Internal.Localization.L,
	{
		__index = 
			function(tab, key)
				rawset(tab, key, key)
				return key
			end,
		
		__newindex = 
			function(tab, key, value)
				if value == true then
					rawset(tab, key, key)
				else
					rawset(tab, key, value)
				end
			end,
	}
)

-- ***************************************************************************************************************************************************
-- * RegisterLocale                                                                                                                                  *
-- ***************************************************************************************************************************************************
-- * Loads a localization table if it matches the current game language                                                                              *
-- * Source: http://wowprogramming.com/forums/development/596                                                                                        *
-- ***************************************************************************************************************************************************
function Internal.Localization.RegisterLocale(locale, tab)
	if type(locale) == "string" and type(tab) == "table" then
		languages[locale] = tab
	end
end


function Internal.Localization.GetLanguages()
	return CopyTableSimple(languages)
end
