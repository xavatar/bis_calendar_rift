-- ***************************************************************************************************************************************************
-- * DomainLogic/Public.lua                                                                                                                          *
-- ***************************************************************************************************************************************************
-- * Exposes the public interface of BiSCal                                                                                                          *
-- ***************************************************************************************************************************************************
-- * 0.2.89 / 2012.01.30 / Baanano: First version                                                                                                    *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

-- Public Interface
_G[addonID] = _G[addonID] or {}
local Public = _G[addonID]

Public.GetRoster = Internal.ModelView.GetRoster
Public.GetSquadSize = Internal.ModelView.GetSquadSize
Public.GetSquadsNumber = Internal.ModelView.GetSquadsNumber

Public.GetRankPermissions = Internal.Rank.GetRankPermissions
Public.GetPermissions = Internal.ModelView.GetPermissions

Public.GetSquadID = Internal.MemberList.GetID
Public.GetSquadLargeIcon = Internal.ModelView.GetSquadLargeIcon
Public.GetSquadSmallIcon = Internal.ModelView.GetSquadSmallIcon
Public.GetSquadSize = Internal.ModelView.GetSquadSize
Public.GetSquads = Internal.ModelView.GetAllSquadIDs

Public.GetEventList = Internal.ModelView.GetEventList
Public.GetEventDetail = Internal.ModelView.GetEventDetail
