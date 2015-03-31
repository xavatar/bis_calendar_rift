local _, InternalInterface = ...

InternalInterface.Localization.RegisterLocale("Spanish",
{
	-- Tabs
	["Tabs/Original"] = "ORIGINAL",
	["Tabs/Calendar"] = "CALENDARIO",
	["Tabs/Squads"] = "EQUIPOS",
	["Tabs/Config"] = "OPCIONES",
	
	-- EventDialog
	["EventDialog/DefaultDescription"] = " -- %s --\nFecha: %s\nHora: %s\nDuración: %s",
	["EventDialog/DateFormat"] = "%d de %B de %Y",
	["EventDialog/HourFormat12"] = "%I:%M %p",
	["EventDialog/HourFormat24"] = "%H:%M",
	["EventDialog/DurationHours"] = " h",
	["EventDialog/DurationMinutes"] = " min",
	["EventDialog/DurationNil"] = "Ilimitado",
	["EventDialog/DateTitle"] = "Fecha:",
	["EventDialog/TimeTitle"] = "Hora:",
	["EventDialog/HourAM"] = " AM",
	["EventDialog/HourPM"] = " PM",
	["EventDialog/TimeSeparator"] = ":",
	["EventDialog/DurationTitle"] = "Duración:",
	["EventDialog/LevelRestriction"] = "Restringir por nivel",
	["EventDialog/SquadRestriction"] = "Restringir por equipo",
	["EventDialog/ButtonSave"] = "Guardar",
	["EventDialog/ButtonCancel"] = "Cancelar",

	-- BatchAssignDialog
	["BatchAssignDialog/MinLevelTitle"] = "Nivel mínimo:",
	["BatchAssignDialog/MaxLevelTitle"] = "Nível máximo:",
	["BatchAssignDialog/MinRankTitle"] = "Rango mínimo:",
	["BatchAssignDialog/MaxRankTitle"] = "Rango máximo:",
	["BatchAssignDialog/CallingTitle"] = "Clase:",
	["BatchAssignDialog/CallingAny"] = "Cualquiera",
	["BatchAssignDialog/ButtonSave"] = "Asignar",
	["BatchAssignDialog/ButtonCancel"] = "Cancelar",
	
	-- JoinDialog
	["JoinDialog/NameTitle"] = "Nombre:",
	["JoinDialog/RolesTitle"] = "Roles:",
	["JoinDialog/StateTitle"] = "Estado:",
	["JoinDialog/AcceptanceTitle"] = "Aceptación:",
	["JoinDialog/StateNormal"] = "Normal",
	["JoinDialog/StateStandby"] = "Dudoso",
	["JoinDialog/StateDeclined"] = "Declinado",
	["JoinDialog/AcceptanceAccepted"] = "Aceptado",
	["JoinDialog/AcceptancePending"] = "Pendiente",
	["JoinDialog/AcceptanceRejected"] = "Rechazado",
	["JoinDialog/ButtonSave"] = "Save",
	["JoinDialog/ButtonCancel"] = "Cancel",
	["JoinDialog/ErrorNoEvent"] = "Evento desconocido",
	["JoinDialog/ErrorLevelRequirement"] = "El evento está restringido para los niveles %d a %d",
	["JoinDialog/ErrorSquadRequirement"] = "El evento está restringido para otros equipos",	
	
	-- CalendarTab
	["CalendarTab/DateFormat"] = "%d de %B de %Y",
	["CalendarTab/MonthFormat"] = "%B de %Y",
	["CalendarTab/HourFormat12"] = "%I:%M %p",
	["CalendarTab/HourFormat24"] = "%H:%M",
	["CalendarTab/DurationHours"] = "h",
	["CalendarTab/DurationMinutes"] = "m",
	["CalendarTab/ColumnTime"] = "Hora",
	["CalendarTab/ColumnEvent"] = "Evento",
	["CalendarTab/ColumnDuration"] = "Duración",
	["CalendarTab/ColumnSquad"] = "Equipo",
	["CalendarTab/ColumnName"] = "Nombre",
	["CalendarTab/ColumnRole"] = "Roles",
	["CalendarTab/ButtonJoin"] = "Unirse",
	["CalendarTab/ButtonChange"] = "Cambiar",
	["CalendarTab/ButtonLeave"] = "Abandonar",
	["CalendarTab/ButtonNew"] = "Crear",
	["CalendarTab/ButtonModify"] = "Modificar",
	["CalendarTab/ButtonDelete"] = "Eliminar",
	["CalendarTab/DeclinedText"] = "Declinado",
	["CalendarTab/OnStandbyText"] = "Dudoso", 	
	
	-- SquadsTab
	["SquadsTab/ColumnSquad"] = "Equipo",
	["SquadsTab/ColumnName"] = "Nombre",
	["SquadsTab/NameNil"] = "Libre",
	["SquadsTab/NameBlocked"] = "Bloqueado",
	["SquadsTab/ButtonAssign"] = "Asignar",
	["SquadsTab/ButtonUnassign"] = "Desasignar",
	["SquadsTab/ButtonAuto"] = "Multiasignar...",
	["SquadsTab/ButtonReset"] = "Vaciar equipo",	
	
	-- Config: Menu
	["ConfigMenu/Interface"] = "Interfaz",
	["ConfigMenu/Guild"] = "Opciones de Hermandad",
	["ConfigMenu/Maintenance"] = "Mantenimiento",
	
	-- Config: Interface
	["ConfigInterface/ClockTitle"] = "Modo de reloj:",
	["ConfigInterface/Clock12"] = "12 horas",
	["ConfigInterface/Clock24"] = "24 horas",
	["ConfigInterface/FirstWeekdayTitle"] = "Comenzar las semanas en:",
	["ConfigInterface/FirstWeekdaySunday"] = "Domingo",
	["ConfigInterface/FirstWeekdayMonday"] = "Lunes",
	["ConfigInterface/LanguageTitle"] = "Idioma:",
	["ConfigInterface/Warning"] = "Si modifica alguna de estas opciones, asegúrese de reiniciar la interfaz mediante el comando /reloadui para que los cambios tomen efecto.",	
	
	-- Config: Guild
	["ConfigGuild/WallPostTitle"] = "Notificar eventos en el Wall",
	["ConfigGuild/StorageLimitTitle"] = "Tamaño máximo de almacenamiento:",
	["ConfigGuild/StorageLimitFormat"] = "%d bytes",
	["ConfigGuild/SquadNumberTitle"] = "Número de equipos:",
	["ConfigGuild/SquadNumberFormat"] = "%d equipo(s)",
	["ConfigGuild/ThemeTitle"] = "Temas:",
	["ConfigGuild/ThemeButton"] = "Aplicar",
	["ConfigGuild/ReloadButton"] = "Recargar",
	["ConfigGuild/SaveButton"] = "Guardar",
	["ConfigGuild/DefaultButton"] = "Por defecto",
	
	-- Config: Maintenance
	["ConfigMaintenance/GuildSettingsTitle"] = "Opciones:",
	["ConfigMaintenance/GuildSettingsClear"] = "Limpiar",
	["ConfigMaintenance/SquadsTitle"] = "Equipos:",
	["ConfigMaintenance/SquadsDeleteOld"] = "Borrar antiguos",
	["ConfigMaintenance/SquadsClear"] = "Limpiar",
	["ConfigMaintenance/SizeFormat"] = "%d bytes",
	["ConfigMaintenance/DateFormat24"] = "%d/%m/%y %H:%M",
	["ConfigMaintenance/DateFormat12"] = "%d/%m/%y %I:%M %p",
	["ConfigMaintenance/EventsColumnDate"] = "Fecha",
	["ConfigMaintenance/EventsColumnEvent"] = "Evento",
	["ConfigMaintenance/EventsColumnSize"] = "Tamaño",
	["ConfigMaintenance/EventsClearSelected"] = "Eliminar",
	["ConfigMaintenance/EventsClearExpired"] = "Limpiar antiguos",
	["ConfigMaintenance/EventsClearAll"] = "Limpiar todos",
	["ConfigMaintenance/ResetAll"] = "Desinstalar",
	
	-- Misc
	["Misc/MonthNames"] = "Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre,",
	["Misc/WeekdayNames"] = "Domingo,Lunes,Martes,Miércoles,Jueves,Viernes,Sábado,",	
	
	-- Version Check stuff
	["VersionCheck/OldVersion"] = "Hay una versión más reciente de BisCal, por favor actualiza tan pronto como puedas",
	["VersionCheck/NewVersion"] = "La versión más reciente conocida es v",
	
	-- Plugin
	["Plugin/ErrorMessage"] = "Error al cargar el plugin '%s':\n%s",
	["Plugin/ErrorNoTab"] = "La pestaña está vacía.",
	["Plugin/ErrorNoConfig"] = "La configuración está vacía.",
	
	--Events
	["Events/Storm Legion Raids"] = "Raids de Storm Legion",
	["Events/Triumph of the Dragon Queen (10 man)"] = "Triumph of the Dragon Queen (10)",
	["Events/Frozen Tempest (20 man)"] = "Frozen Tempest (20)",
	["Events/Endless Eclipse (20 man)"] = "Endless Eclipse (20)",
	["Events/RAID_GRIM_AWAKENING"] = "Grim Awakening (10)",
	["Events/RAID_PLANEBREAKER_BASTION"] = "Planebreaker Bastion (20)",
	["Events/RAID_INFINITY_GATE"] = "Infinity Gate (20)",
	["Events/RAID_INTREPID_DROWNED_HALLS"] = "Intrepid: Drowned Halls (10)",
	["Events/NMT_Raids"] = "Raids de Nightmare Tide",
	["Events/NMT_ROF_10"] = "Rhen of Fate (10)",
	["Events/NMT_MS_20"] = "Mount Sharax (20)",
	
	-- SL Hardmode Raids
	["Events/GROUP_HM_SL_RAIDS"] = "Raids de Storm Legion (modo difícil)",
	["Events/RAID_FROZEN_TEMPEST_HM"] = "Frozen Tempest (20 modo difícil)",
	["Events/RAID_ENDLESS_ECLIPSE_HM"] = "Endless Eclipse (20 modo difícil)",
	
	--NMT Dungeons
	["Events/NMT_TITLE"] = "Mazmorras de Nightmare Tide",
	["Events/NMT_EC"] = "Return to Empyrean Core",
	["Events/NMT_NMC"] = "Nightmare Coast",
	["Events/NMT_GYEL"] = "Gyel Fortress",
	["Events/NMT_COI"] = "Citadel of Insanity",
	["Events/NMT_IT"] = "Return to Iron Tomb",
	["Events/NMT_GM"] = "Glacial Maw",
	
	--NMT Expert Dungeons
	["Events/EXP_NMT_TITLE"] = "Mazmorras expertas de Nightmare Tide",
	["Events/EXP_NMT_EC"] = "Expert: Return to Empyrean Core",
	["Events/EXP_NMT_NMC"] = "Expert: Nightmare Coast",
	["Events/EXP_NMT_GYEL"] = "Expert: Gyel Fortress",
	["Events/EXP_NMT_COI"] = "Expert: Citadel of Insanity",
	["Events/EXP_NMT_IT"] = "Expert: Return to Iron Tomb",
	["Events/EXP_NMT_GM"] = "Expert: Glacial Maw",
	
	--SL Dungeons
	["Events/SL_TITLE"] = "Mazmorras de Storm Legion",
	["Events/SL_EXO"] = "Exodus of the Storm Queen",
	["Events/SL_SB"] = "Storm Breaker Protocol",
	["Events/SL_UB"] = "Unhallowed Boneforge",
	["Events/SL_GF"] = "Golem Foundry",
	["Events/SL_AF"] = "Archive of Flesh",
	["Events/SL_EC"] = "Empyrean Core",
	["Events/SL_TS"] = "Tower of the Shattered",
	["Events/DUNGEON_TWISTED_DREAMS"] = "Realm of Twisted Dreams",
	
	--Storm Legion Expert Dungeons
	["Events/EXP_SL_TITLE"] = "Mazmorras expertas de Storm Legion",
	["Events/EXP_SL_EXO"] = "Expert: Exodus of the Storm Queen",
	["Events/EXP_SL_SB"] = "Expert: Storm Breaker Protocol",
	["Events/EXP_SL_UB"] = "Expert: Unhallowed Boneforge",
	["Events/EXP_SL_GF"] = "Expert: Golem Foundry",
	["Events/EXP_SL_AF"] = "Expert: Archive of Flesh",
	["Events/EXP_SL_EC"] = "Expert: Empyrean Core",
	["Events/EXP_SL_TS"] = "Expert: Tower of the Shattered",
	["Events/DUNGEON_EXP_TWISTED_DREAMS"] = "Expert: Realm of Twisted Dreams",
	
	-- Storm Legion Chronicles
	["Events/GROUP_SL_CHRONICLES"] = "Crónicas de Storm Legion",
	["Events/CHRONICLE_QUEEN_GAMBIT"] = "Hive Kaaz'Gfuu: Queen's Gambit",
	["Events/CHRONICLE_INFERNAL_DAWN"] = "Infernal Dawn: Laethys",
	["Events/CHRONICLE_PLANEBREAKER_BASTION"] = "Planebreaker Bastion: Aftermath",
	["Events/CHRONICLE_INT_GREENSCALE_BLIGHT"] = "Intrepid: Greenscale's Blight",
	["Events/CHRONICLE_INT_RIVER_SOULS"] = "Intrepid: River of Souls",
	["Events/CHRONICLE_INT_HAMMERKNELL"] = "Intrepid: Hammerknell",
	
	--Chocolate Raids
	["Events/CHO_TITLE"] = "Raids clásicas",
	["Events/CHO_GSB"] = "Greenscales Blight (20)",
	["Events/CHO_ROS"] = "River of Souls (20)",
	["Events/CHO_GP"] = "Gilded Prophecy (10)",
	["Events/CHO_DH"] = "Drowned Halls (10)",
	["Events/CHO_HK"] = "Hammerknell (20)",
	["Events/CHO_ROP"] = "Rise of the Phoenix (10)",
	["Events/CHO_ID"] = "Infernal Dawn (20)",
	["Events/CHO_PF"] = "Primeval Feast (10)",
	
	--Classic Dungeons
	["Events/CL_TITLE"] = "Mazmorras clásicas",
	["Events/CL_AP"] = "Abyssal Precipice",
	["Events/CL_CR"] = "Caduceus Rise",
	["Events/CL_UCR"] = "Upper Caduceus Rise",
	["Events/CL_CC"] = "Charmer's Caldera",
	["Events/CL_DD"] = "Darkening Deeps",
	["Events/CL_DM"] = "The Deepstrike Mines",
	["Events/CL_IT"] = "The Iron Tomb",
	["Events/CL_LH"] = "The Fall of Lantern Hook",
	["Events/CL_FAE"] = "The Realm of the Fae",
	["Events/CL_RD"] = "Runic Descent",
	["Events/CL_FC"] = "Foul Cascade",
	["Events/CL_KB"] = "Kings Breach",
	
	--Classic Expert Dungeons
	["Events/EXP_CL_TITLE"] = "Mazmorras clásicas expertas",
	["Events/EXP_CL_AP"] = "Expert: Abyssal Precipice",
	["Events/EXP_CL_CR"] = "Expert: Caduceus Rise",
	["Events/EXP_CL_UCR"] = "Expert: Upper Caduceus Rise",
	["Events/EXP_CL_CC"] = "Expert: Charmer's Caldera",
	["Events/EXP_CL_DD"] = "Expert: Darkening Deeps",
	["Events/EXP_CL_DM"] = "Expert: The Deepstrike Mines",
	["Events/EXP_CL_IT"] = "Expert: The Iron Tomb",
	["Events/EXP_CL_LH"] = "Expert: The Fall of Lantern Hook",
	["Events/EXP_CL_FAE"] = "Expert: The Realm of the Fae",
	["Events/EXP_CL_RD"] = "Expert: Runic Descent",
	["Events/EXP_CL_FC"] = "Expert: Foul Cascade",
	["Events/EXP_CL_KB"] = "Expert: Kings Breach",
	
	--Misc Events
	["Events/OTHER_TITLE"] = "Otros",
	["Events/OTHER_DRR"] = "Rift de Raid",
	["Events/OTHER_HUNT"] = "Hunt Rifts",
	["Events/OTHER_CRAFT"] = "Crafting Rifts",
	["Events/OTHER_MEETING"] = "Reunión",
	["Events/OTHER_QREP"] = "Reputación Qaijiri",
	["Events/OTHER_ECREP"] = "Reputación Eternal City Survivors",
	["Events/OTHER_NCREP"] = "Reputación Necropolis Caretakers",
	["Events/OTHER_NIGHTMARE"] = "Nightmare Rifts",
	["Events/OTHER_NIGHTMARE_INST"] = "Nightmare Rifts: Instanced",
	
	--Warfronts
	["WF/Title"] = "Frentes de combate",
	["WF/RWAR"] = "Al azar",
	["WF/TBG"] = "The Black Garden",
	["WF/LR"] = "Library of the Runemasters",
	["WF/BPS"] = "The Battle for Port Scion",
	["WF/KR"] = "Karthan Ridge",
	["WF/EWS"] = "Escalation: Whitefall Steppes",
	["WF/TC"] = "The Codex",	
	["Events/WF_RANKED_BLACK_GARDEN"] = "Ranked: The Black Garden",
	["Events/WF_FLAG_BLACK_GARDEN"] = "Domination: The Black Garden",
	["Events/WF_FLAG_KARTHAN_RIDGE"] = "Domination: Karthan Ridge",
	["WF/GSN"] = "Ghar Station Eyn",
	["WF/BA"] = "Blighted Antechamber",
	
	--Roles
	["Roles/Tank"] = "Protector",
	["Roles/Healer"] = "Sanador",
	["Roles/Damage"] = "Dañador",
	["Roles/Support"] = "Soporte",
	
	--Callings
	["Callings/Warrior"] = "Guerrero",
	["Callings/Cleric"] = "Clérigo",
	["Callings/Rogue"] = "Pícaro",
	["Callings/Mage"] = "Mago",
	
	--Factions
	["Callings/Guardian"] = "Guardian",
	["Callings/Defiant"] = "Defiant",
	
	--Custom Squads
	["Squads/Skull"] = "Calavera",
	["Squads/Arrow"] = "Flecha",	
	["Squads/Smile"] = "Risitas",
	["Squads/Squirrel"] = "Ardilla",
	["Squads/Forbidden"] = "Prohibido",
	["Squads/Dominion"] = "Dominion",
	["Squads/Nightfall"] = "Nightfall",
	["Squads/Oathsworn"] = "Oathsworn",
	
	--Themes
	["Themes/Callings"] = "Clases",
	["Themes/Roles"] = "Roles",
	["Themes/Faction"] = "Facciones",
	["Themes/Conquest"] = "Conquest",
	
}
)

