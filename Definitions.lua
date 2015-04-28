-- ***************************************************************************************************************************************************
-- * Definitions.lua                                                                                                                                 *
-- ***************************************************************************************************************************************************
-- * Definitions table                                                                                                                               *
-- ***************************************************************************************************************************************************
-- * 0.5.137/ 2015.01.20 / Llien: Added Nightmare Tide Raids and Rifts                                                                                         *
-- * 0.5.134/ 2013.09.22 / Baanano: Added new raids, chronicles & dungeons                                                                           *
-- * 0.0.6 / 2013.01.14 / Baanano: Extracted event definitions to a separate file and added squad & theme definitions                                *
-- * 0.0.6 / 2013.01.13 / Odine:   Updated list to include all known raids and other various misc events                                             *
-- * 0.0.1 / 2012.01.06 / Baanano: First version                                                                                                     *
-- ***************************************************************************************************************************************************

local addonInfo, Internal = ...
local addonID = addonInfo.identifier

local L = Internal.Localization.L
local TInsert = table.insert

Internal.Definitions = Internal.Definitions or
{
	EventTypes = {},
	Squads = {},
	Themes = {},
}

local function BuildDefinitions()
	Internal.Definitions.EventTypes =
	{
	
		
		
		[11] = 
		{
			name = L["Events/NMT_Raids"],
			order=1,
			subcategories = 
			{
				[0]=
				{
					name = L["Events/NMT_ROF_10"],
					order = 1,
					icon = { "Rift", "stormcaller_lightning_storm_01_a.dds",},
				},
				[1]=
				{
					name = L["Events/NMT_MS_20"],
					order = 2,
					icon = { "Rift", "generic_ability_026.dds",},
				},
				[3]=
				{
					name = L["Events/NMT_FT_20"],
					order = 3,
					icon = { "Rift", "caustic_artifact.dds",},
				},
			}
		},
		
		[14] = 
		{
			name = L["Events/NMT_DRR_Title"],
			order=2,
			subcategories = 
			{
				[0]=
				{
					name = L["Events/NMT_DRR_Ladon"],
					order = 1,
					icon = { "Rift", "stormcaller_lightning_storm_01_a.dds",},
				},
				[1]=
				{
					name = L["Events/NMT_DRR_Crawler"],
					order = 2,
					icon = { "Rift", "generic_ability_026.dds",},
				},
				[3]=
				{
					name = L["Events/NMT_DRR_Darkmagic"],
					order = 3,
					icon = { "Rift", "generic_ability_026.dds",},
				},
			}
		},
		
		[0] =
		{
			name = L["Events/Storm Legion Raids"],
			order = 3,
			subcategories =
			{
				[0] =
				{
					name = L["Events/Triumph of the Dragon Queen (10 man)"],
					order = 1,
					icon = { "Rift", "stormcaller_lightning_storm_01_a.dds", },
				},
				[1] =
				{
					name = L["Events/Frozen Tempest (20 man)"],
					order = 2,
					icon = { "Rift", "generic_ability_026.dds", },
				},
				[2] =
				{
					name = L["Events/Endless Eclipse (20 man)"],
					order = 3,
					icon = { "Rift", "caustic_artifact.dds", },
				},
				[3] =
				{
					name = L["Events/RAID_GRIM_AWAKENING"],
					order = 4,
					icon = { "Rift", "defiler_mask_of_depravity_d.dds", },
				},
				[4] =
				{
					name = L["Events/RAID_PLANEBREAKER_BASTION"],
					order = 5,
					icon = { "Rift", "paladin_face_slam.dds", },
				},
				[5] =
				{
					name = L["Events/RAID_INFINITY_GATE"],
					order = 6,
					icon = { "Rift", "riftstalker_toughened_soul_01_b.dds", },
				},
				[6] =
				{
					name = L["Events/RAID_INTREPID_DROWNED_HALLS"],
					order = 7,
					icon = { "Rift", "drowning2.dds", },
				},
			}
		},
		[9] =
		{
			name = L["Events/GROUP_HM_SL_RAIDS"],
			order = 4,
			subcategories =
			{
				[0] =
				{
					name = L["Events/RAID_FROZEN_TEMPEST_HM"],
					order = 1,
					icon = { "Rift", "riftstalker_unseen_fury_01.dds", },
				},
				[1] =
				{
					name = L["Events/RAID_ENDLESS_ECLIPSE_HM"],
					order = 2,
					icon = { "Rift", "pet_regulos_b.dds", },
				},
			}
		},
		[12]=
		{
			name = L["Events/NMT_TITLE"],
			order = 5,
			subcategories =
			{
				[0] =
				{
					name = L["Events/NMT_IT"],
					order = 1,
					icon = { "Rift", "doctrine_of_loyalty_01.dds", },
				},
				[1] =
				{
					name = L["Events/NMT_EC"],
					order = 2,
					icon = { "Rift", "bomb_fragment_a.dds", },
				},	
				[2] =
				{
					name = L["Events/NMT_GM"],
					order = 3,
					icon = { "Rift", "enchanting_material_26a.dds",  },
				},		
				[3] =
				{
					name = L["Events/NMT_GYEL"],
					order = 4,
					icon = { "Rift", "strong_constitution_01.dds", },
				},
				[4] =
				{
					name = L["Events/NMT_NMC"],
					order = 5,
					icon = { "Rift",  "whrilwind4a.dds", },
				},	
				[5] =
				{
					name = L["Events/NMT_COI"],
					order = 6,
					icon = { "Rift",  "stormcaller_lightning_storm_01_a.dds",},
				},					
			},
		},
		[13]=
		{
			name = L["Events/EXP_NMT_TITLE"],
			order = 6,
			subcategories =
			{
				[0] =
				{
					name = L["Events/EXP_NMT_IT"],
					order = 1,
					icon = { "Rift", "doctrine_of_loyalty_01.dds", },
				},
				[1] =
				{
					name = L["Events/EXP_NMT_EC"],
					order = 2,
					icon = { "Rift", "bomb_fragment_a.dds", },
				},	
				[2] =
				{
					name = L["Events/EXP_NMT_GM"],
					order = 3,
					icon = { "Rift", "enchanting_material_26a.dds",  },
				},		
				[3] =
				{
					name = L["Events/EXP_NMT_GYEL"],
					order = 4,
					icon = { "Rift", "strong_constitution_01.dds", },
				},
				[4] =
				{
					name = L["Events/EXP_NMT_NMC"],
					order = 5,
					icon = { "Rift",  "whrilwind4a.dds", },
				},	
				[5] =
				{
					name = L["Events/EXP_NMT_COI"],
					order = 6,
					icon = { "Rift",  "stormcaller_lightning_storm_01_a.dds",},
				},
			},
		},
		[1] =
		{
			name = L["Events/SL_TITLE"],
			order = 7,
			subcategories =
			{
				[0] =
				{
					name = L["Events/SL_EXO"],
					order = 1,
					icon = { "Rift", "strong_constitution_01.dds", },
				},
				[1] =
				{
					name = L["Events/SL_SB"],
					order = 2,
					icon = { "Rift", "whrilwind4a.dds", },
				},
				[2] =
				{
					name = L["Events/SL_UB"],
					order = 3,
					icon = { "Rift", "summonskeleton2.dds", },
				},
				[3] =
				{
					name = L["Events/SL_GF"],
					order = 4,
					icon = { "Rift", "enchanting_material_26a.dds", },
				},
				[4] =
				{
					name = L["Events/SL_AF"],
					order = 5,
					icon = { "Rift", "riftstalker_planar_refuge_01.dds", },
				},
				[5] =
				{
					name = L["Events/SL_EC"],
					order = 6,
					icon = { "Rift", "bomb_fragment_a.dds", },
				},
				[6] =
				{
					name = L["Events/SL_TS"],
					order = 7,
					icon = { "Rift", "stormcaller_lightning_storm_01_a.dds", },
				},
				[7] =
				{
					name = L["Events/DUNGEON_TWISTED_DREAMS"],
					order = 8,
					icon = { "Rift", "invoker_prerogative1.dds", },
				},
			}
		},
		[2] =
		{
			name = L["Events/EXP_SL_TITLE"],
			order = 8,
			subcategories =
			{
				[0] =
				{
					name = L["Events/EXP_SL_EXO"],
					order = 1,
					icon = { "Rift", "strong_constitution_01.dds", },
				},
				[1] =
				{
					name = L["Events/EXP_SL_SB"],
					order = 2,
					icon = { "Rift", "whrilwind4a.dds", },
				},
				[2] =
				{
					name = L["Events/EXP_SL_UB"],
					order = 3,
					icon = { "Rift", "summonskeleton2.dds", },
				},
				[3] =
				{
					name = L["Events/EXP_SL_GF"],
					order = 4,
					icon = { "Rift", "enchanting_material_26a.dds", },
				},
				[4] =
				{
					name = L["Events/EXP_SL_AF"],
					order = 5,
					icon = { "Rift", "riftstalker_planar_refuge_01.dds", },
				},
				[5] =
				{
					name = L["Events/EXP_SL_EC"],
					order = 6,
					icon = { "Rift", "bomb_fragment_a.dds", },
				},
				[6] =
				{
					name = L["Events/EXP_SL_TS"],
					order = 7,
					icon = { "Rift", "stormcaller_lightning_storm_01_a.dds", },
				},
				[7] =
				{
					name = L["Events/DUNGEON_EXP_TWISTED_DREAMS"],
					order = 8,
					icon = { "Rift", "fiery_blessing.dds", },
				},
			}
		},
		[10] =
		{
			name = L["Events/GROUP_SL_CHRONICLES"],
			order = 9,
			subcategories =
			{
				[0] =
				{
					name = L["Events/CHRONICLE_QUEEN_GAMBIT"],
					order = 1,
					icon = { "Rift", "invigorate2.dds", },
				},
				[1] =
				{
					name = L["Events/CHRONICLE_INFERNAL_DAWN"],
					order = 2,
					icon = { "Rift", "ressurection1z.dds", },
				},
				[2] =
				{
					name = L["Events/CHRONICLE_PLANEBREAKER_BASTION"],
					order = 3,
					icon = { "Rift", "castigation2.dds", },
				},
				[3] =
				{
					name = L["Events/CHRONICLE_INT_GREENSCALE_BLIGHT"],
					order = 4,
					icon = { "Rift", "doctrine_of_loyalty_01.dds", },
				},
				[4] =
				{
					name = L["Events/CHRONICLE_INT_RIVER_SOULS"],
					order = 5,
					icon = { "Rift", "reign_of_despair.dds", },
				},
				[5] =
				{
					name = L["Events/CHRONICLE_INT_HAMMERKNELL"],
					order = 6,
					icon = { "Rift", "dirtytricks4.dds", },
				},
			}
		},
		[3] =
		{
			name = L["Events/CHO_TITLE"],
			order = 10,
			subcategories =
			{
				[0] =
				{
					name = L["Events/CHO_GSB"],
					order = 1,
					icon = { "Rift", "rune_5_f_green_a.dds", },
				},
				[1] =
				{
					name = L["Events/CHO_ROS"],
					order = 2,
					icon = { "Rift", "trinket31.dds", },
				},
				[2] =
				{
					name = L["Events/CHO_GP"],
					order = 3,
					icon = { "Rift", "pet_scorpion.dds", },
				},
				[3] =
				{
					name = L["Events/CHO_DH"],
					order = 4,
					icon = { "Rift", "underwaterbreath1a.dds", },
				},
				[4] =
				{
					name = L["Events/CHO_HK"],
					order = 5,
					icon = { "Rift", "2h_hammer_water_epic_a.dds", },
				},
				[5] =
				{
					name = L["Events/CHO_ROP"],
					order = 6,
					icon = { "Rift", "ressurection1.dds", },
				},
				[6] =
				{
					name = L["Events/CHO_ID"],
					order = 7,
					icon = { "Rift", "vengeful_justice_01.dds", },
				},
				[7] =
				{
					name = L["Events/CHO_PF"],
					order = 8,
					icon = { "Rift", "berserk1.dds", },
				},	
			}
		},
		[4] =
		{
			name = L["Events/CL_TITLE"],
			order = 11,
			subcategories =
			{
				[0] =
				{
					name = L["Events/CL_AP"],
					order = 1,
					icon = { "Rift", "eye_of_the_storm_a.dds", },
				},
				[1] =
				{
					name = L["Events/CL_CR"],
					order = 2,
					icon = { "Rift", "2h_mace_082_a", },
				},
				[2] =
				{
					name = L["Events/CL_UCR"],
					order = 3,
					icon = { "Rift", "mug_07_a.dds", },
				},
				[3] =
				{
					name = L["Events/CL_CC"],
					order = 4,
					icon = { "Rift", "flame_speaker1.dds", },
				},
				[4] =
				{
					name = L["Events/CL_DD"],
					order = 5,
					icon = { "Rift", "berserk1a.dds", },
				},
				[5] =
				{
					name = L["Events/CL_DM"],
					order = 6,
					icon = { "Rift", "invigoration2a.dds", },
				},
				[6] =
				{
					name = L["Events/CL_IT"],
					order = 7,
					icon = { "Rift", "doctrine_of_loyalty_01.dds", },
				},
				[7] =
				{
					name = L["Events/CL_LH"],
					order = 8,
					icon = { "Rift", "upperhand1.dds", },
				},
				[8] =
				{
					name = L["Events/CL_FAE"],
					order = 9,
					icon = { "Rift", "freemarch_rabbit.dds", },
				},
				[9] =
				{
					name = L["Events/CL_RD"],
					order = 10,
					icon = { "Rift", "shielded.dds", },
				},
				[10] =
				{
					name = L["Events/CL_FC"],
					order = 11,
					icon = { "Rift", "headshot3.dds", },
				},
				[11] =
				{
					name = L["Events/CL_KB"],
					order = 12,
					icon = { "Rift", "defensivestrike2.dds", },
				},
			}
		},
		[5] =
		{
			name = L["Events/EXP_CL_TITLE"],
			order = 12,
			subcategories =
			{
				[0] =
				{
					name = L["Events/EXP_CL_AP"],
					order = 1,
					icon = { "Rift", "eye_of_the_storm_a.dds", },
				},
				[1] =
				{
					name = L["Events/EXP_CL_CR"],
					order = 2,
					icon = { "Rift", "2h_mace_082_a", },
				},
				[2] =
				{
					name = L["Events/EXP_CL_UCR"],
					order = 3,
					icon = { "Rift", "mug_07_a.dds", },
				},
				[3] =
				{
					name = L["Events/EXP_CL_CC"],
					order = 4,
					icon = { "Rift", "flame_speaker1.dds", },
				},
				[4] =
				{
					name = L["Events/EXP_CL_DD"],
					order = 5,
					icon = { "Rift", "campfire1.dds", },
				},
				[5] =
				{
					name = L["Events/EXP_CL_DM"],
					order = 6,
					icon = { "Rift", "invigoration2a.dds", },
				},
				[6] =
				{
					name = L["Events/EXP_CL_IT"],
					order = 7,
					icon = { "Rift", "doctrine_of_loyalty_01.dds", },
				},
				[7] =
				{
					name = L["Events/EXP_CL_LH"],
					order = 8,
					icon = { "Rift", "upperhand1.dds", },
				},
				[8] =
				{
					name = L["Events/EXP_CL_FAE"],
					order = 9,
					icon = { "Rift", "freemarch_rabbit.dds", },
				},
				[9] =
				{
					name = L["Events/EXP_CL_RD"],
					order = 10,
					icon = { "Rift", "shielded.dds", },
				},
				[10] =
				{
					name = L["Events/EXP_CL_FC"],
					order = 11,
					icon = { "Rift", "headshot3.dds", },
				},
				[11] =
				{
					name = L["Events/EXP_CL_KB"],
					order = 12,
					icon = { "Rift", "defensivestrike2.dds", },
				},
			}
		},
		[7] =
		{
			name = L["WF/Title"],
			order = 13,
			subcategories =
			{
				[0] =
				{
					name = L["WF/RWAR"],
					order = 2,
					icon = { "Rift", "scroll4b.dds", },
				},
				[1] =
				{
					name = L["WF/TBG"],
					order = 3,
					icon = { "Rift", "serla_irmgard_head.dds", },
				},
				[2] =
				{
					name = L["WF/LR"],
					order = 4,
					icon = { "Rift", "campfire1.dds", },
				},
				[3] =
				{
					name = L["WF/BPS"],
					order = 5,
					icon = { "Rift", "campfire1.dds", },
				},
				[4] =
				{
					name = L["WF/KR"],
					order = 6,
					icon = { "Rift", "campfire1.dds", },
				},
				[5] =
				{
					name = L["WF/EWS"],
					order = 7,
					icon = { "Rift", "map6.dds", },
				},
				[6] =
				{
					name = L["WF/TC"],
					order = 8,
					icon = { "Rift", "channelhealth4a.dds", },
				},
				[7] =
				{
					name = L["Events/WF_RANKED_BLACK_GARDEN"],
					order = 1,
					icon = { "Rift", "relic_1j.dds", },
				},
				[8] =
				{
					name = L["Events/WF_FLAG_BLACK_GARDEN"],
					order = 9,
					icon = { "Rift", "shadow_blitz_b.dds", },
				},
				[9] =
				{
					name = L["Events/WF_FLAG_KARTHAN_RIDGE"],
					order = 10,
					icon = { "Rift", "defiler_empowered_affliction.dds", },
				},
			}
		},
		[8] =
		{
			name = L["Events/OTHER_TITLE"],
			order = 14,
			subcategories =
			{
				[0] =
				{
					name = L["Events/OTHER_DRR"],
					order = 1,
					icon = { "Rift", "scroll4b.dds", },
				},
				[1] =
				{
					name = L["Events/OTHER_HUNT"],
					order = 2,
					icon = { "Rift", "serla_irmgard_head.dds", },
				},
				[2] =
				{
					name = L["Events/OTHER_QREP"],
					order = 3,
					icon = { "Rift", "campfire1.dds", },
				},
				[3] =
				{
					name = L["Events/OTHER_ECREP"],
					order = 4,
					icon = { "Rift", "campfire1.dds", },
				},
				[4] =
				{
					name = L["Events/OTHER_NCREP"],
					order = 5,
					icon = { "Rift", "campfire1.dds", },
				},
				[5] =
				{
					name = L["Events/OTHER_MEETING"],
					order = 6,
					icon = { "Rift", "map6.dds", },
				},
				[6] =
				{
					name = L["Events/OTHER_CRAFT"],
					order = 7,
					icon = { "Rift", "campfire1.dds", },
				},
				[7]=
				{
					name = L["Events/OTHER_NIGHTMARE"],
					order = 8,
					icon = { "Rift",  "invigoration2a.dds"},
				},
			}
		},
	}

	Internal.Definitions.Squads =
	{
		[0] =
		{
			name = L["Roles/Tank"],
			icon_large = { "Rift", "vfx_ui_mob_tag_tank.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_tank_mini.png.dds" },
		},
		[1] =
		{
			name = L["Roles/Healer"],
			icon_large = { "Rift", "vfx_ui_mob_tag_heal.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_heal_mini.png.dds" },
		},
		[2] =
		{
			name = L["Roles/Damage"],
			icon_large = { "Rift", "vfx_ui_mob_tag_damage.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_damage_mini.png.dds" },
		},
		[3] =
		{
			name = L["Roles/Support"],
			icon_large = { "Rift", "vfx_ui_mob_tag_support.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_support_mini.png.dds" },
		},
		[4] =
		{
			name = L["Squads/Skull"],
			icon_large = { "Rift", "vfx_ui_mob_tag_skull.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_skull_mini.png.dds" },
		},
		[5] =
		{
			name = L["Squads/Arrow"],
			icon_large = { "Rift", "vfx_ui_mob_tag_arrow.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_arrow_mini.png.dds" },
		},
		[6] =
		{
			name = L["Squads/Smile"],
			icon_large = { "Rift", "vfx_ui_mob_tag_smile.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_smile_mini.png.dds" },
		},
		[7] =
		{
			name = L["Squads/Squirrel"],
			icon_large = { "Rift", "vfx_ui_mob_tag_squirrel.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_squirrel_mini.png.dds" },
		},
		[8] =
		{
			name = L["Squads/Forbidden"],
			icon_large = { "Rift", "vfx_ui_mob_tag_no.png.dds" },
			icon_small = { "Rift", "vfx_ui_mob_tag_no_mini.png.dds" },
		},
		[9] =
		{
			name = L["Squads/Dominion"],
			icon_large = { "Rift", "faction_dominion_med.png.dds" },
			icon_small = { "Rift", "NPCDialog_conquest_dominion.png.dds" },
		},
		[10] =
		{
			name = L["Squads/Nightfall"],
			icon_large = { "Rift", "faction_nightfall_med.png.dds" },
			icon_small = { "Rift", "NPCDialog_conquest_nightfall.png.dds" },
		},
		[11] =
		{
			name = L["Squads/Oathsworn"],
			icon_large = { "Rift", "faction_oathsworn_med.png.dds" },
			icon_small = { "Rift", "NPCDialog_conquest_oathsworn.png.dds" },
		},
		[12] =
		{
			name = L["Callings/Warrior"],
			icon_large = { addonID, "Textures/Warrior.png" },
			icon_small = { addonID, "Textures/Warrior.png" },
		},
		[13] =
		{
			name = L["Callings/Cleric"],
			icon_large = { addonID, "Textures/Cleric.png" },
			icon_small = { addonID, "Textures/Cleric.png" },
		},
		[14] =
		{
			name = L["Callings/Rogue"],
			icon_large = { addonID, "Textures/Rogue.png" },
			icon_small = { addonID, "Textures/Rogue.png" },
		},
		[15] =
		{
			name = L["Callings/Mage"],
			icon_large = { addonID, "Textures/Mage.png" },
			icon_small = { addonID, "Textures/Mage.png" },
		},
		[16] =
		{
			name = L["Callings/Guardian"],
			icon_large = { "Rift", "Guardian_Color_256.png.dds" },
			icon_small = { "Rift", "GenericGameIcon_Guardians.png.dds" },
		},
		[17] =
		{
			name = L["Callings/Defiant"],
			icon_large = { "Rift", "Defiant_Color_256.png.dds" },
			icon_small = { "Rift", "GenericGameIcon_Defiants.png.dds" },
		},
	}
	
	Internal.Definitions.Themes = 
	{
		[1] =
		{
			name = L["Themes/Callings"],
			number = 2, -- Number means: 0 = 1 squad, 1 = 2 squads, 2 = 4 squads, 3 = 8 squads
			squads = { 13, 15, 14, 12, },
		},
		[2] =
		{
			name = L["Themes/Roles"],
			number = 2,
			squads = { 0, 1, 2, 3, },
		},
		[3] =
		{
			name = L["Themes/Faction"],
			number = 1,
			squads = { 16, 17, },
		},
		[4] =
		{
			name = L["Themes/Conquest"],
			number = 2,
			squads = { 9, 10, 11, 8, },
		},
	}
end

TInsert(Internal.UIChain, BuildDefinitions)
