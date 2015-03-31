-- ***************************************************************************************************************************************************
-- * CustomGridCells.lua                                                                                                                             *
-- ***************************************************************************************************************************************************
-- * Custom DataGrid cells used by BiSCal                                                                                                            *
-- ***************************************************************************************************************************************************
-- * 0.0.6 / 2013.01.13 / Odine: adjusted textures to show the correct ones
-- * 0.0.5 / 2013.01.13 / Baanano: Extracted from CalendarTab.lua                                                                                    *
-- * 0.0.1 / 2013.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local GetSquadSmallIconAndNumber = Internal.ModelView.GetSquadSmallIconAndNumber
local L = Internal.Localization.L
local MFloor = math.floor
local RegisterCellType = Yague.RegisterCellType
local ShadowedText = Yague.ShadowedText
local UICreateFrame = UI.CreateFrame
local tostring = tostring
local unpack = unpack

local function SquadCellType(name, parent)
	local cell = UICreateFrame("Frame", name, parent)
	local squadTexture = UICreateFrame("Texture", name .. ".SquadTexture", cell)
	local squadText = ShadowedText(name .. ".SquadText", cell)
	
	squadTexture:SetPoint("CENTERRIGHT", cell, "CENTERRIGHT", -2, 0)
	squadTexture:SetWidth(20)
	squadTexture:SetHeight(20)
	
	squadText:SetPoint("CENTERRIGHT", cell, "CENTERRIGHT", -24, 0)
	squadText:SetFontColor(.75, .75, .5)
	
	function cell:SetValue(key, value, width, extra)
		local squad, squadNumber = GetSquadSmallIconAndNumber(value)
		squadTexture:SetTextureAsync(unpack(squad))
		squadText:SetText(tostring(squadNumber))
	end
	
	return cell
end
RegisterCellType(addonID .. ".CalendarSquad", SquadCellType)

local function RoleCellType(name, parent)
	local cell = UICreateFrame("Frame", name, parent)
	local tankTexture = UICreateFrame("Texture", name .. ".TankTexture", cell)
	local healerTexture = UICreateFrame("Texture", name .. ".HealerTexture", cell)
	local dpsTexture = UICreateFrame("Texture", name .. ".DpsTexture", cell)
	local supportTexture = UICreateFrame("Texture", name .. ".SupportTexture", cell)
	local declinedText = ShadowedText(name .. ".DeclinedText", cell)
	local standbyText = ShadowedText(name .. ".StandbyText", cell)
	
	tankTexture:SetPoint("CENTERLEFT", cell, "CENTERLEFT", 0, 0)
	tankTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_tank_mini.png.dds")
	
	healerTexture:SetPoint("CENTERLEFT", tankTexture, "CENTERRIGHT", 2, 0)
	healerTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_heal_mini.png.dds")
	
	dpsTexture:SetPoint("CENTERLEFT", healerTexture, "CENTERRIGHT", 2, 0)
	dpsTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_damage_mini.png.dds")
	
	supportTexture:SetPoint("CENTERLEFT", dpsTexture, "CENTERRIGHT", 2, 0)
	supportTexture:SetTextureAsync("Rift", "vfx_ui_mob_tag_support_mini.png.dds")

	declinedText:SetPoint("CENTER", cell, "CENTER")
	declinedText:SetFontColor(1, 0, 0)
	declinedText:SetText(L["CalendarTab/DeclinedText"])
	declinedText:SetVisible(false)
	
	standbyText:SetPoint("CENTER", cell, "CENTER")
	standbyText:SetFontColor(1, 0.96, 0.41)
	standbyText:SetText(L["CalendarTab/OnStandbyText"])
	standbyText:SetVisible(false)
	
	function cell:SetValue(key, value, width, extra)
		tankTexture:SetVisible(value.tank and not (value.declined or value.standby))
		healerTexture:SetVisible(value.healer and not (value.declined or value.standby))
		dpsTexture:SetVisible(value.dps and not (value.declined or value.standby))
		supportTexture:SetVisible(value.support and not (value.declined or value.standby))
		declinedText:SetVisible(value.declined)
		standbyText:SetVisible(value.standby and not value.declined)
	end
	
	return cell
end
RegisterCellType(addonID .. ".CalendarRole", RoleCellType)
