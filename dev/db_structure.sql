-- Zrzut struktury bazy danych lif_1
CREATE DATABASE IF NOT EXISTS `lif_1` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `lif_1`;

-- Zrzut struktury tabela lif_1.account
CREATE TABLE IF NOT EXISTS `account` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `IsActive` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `IsGM` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `SteamID` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_SteamID` (`SteamID`)
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.admin_lands
CREATE TABLE IF NOT EXISTS `admin_lands` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Priority` int(11) unsigned NOT NULL DEFAULT '0',
  `GeoID1` int(10) unsigned NOT NULL,
  `GeoID2` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.blueprints
CREATE TABLE IF NOT EXISTS `blueprints` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RecipeID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_blueprints_recipe` (`RecipeID`),
  CONSTRAINT `FK_blueprints_recipe` FOREIGN KEY (`RecipeID`) REFERENCES `recipe` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.blueprint_requirements
CREATE TABLE IF NOT EXISTS `blueprint_requirements` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `BlueprintID` int(10) unsigned NOT NULL,
  `RecipeRequirementID` int(10) unsigned NOT NULL,
  `RegionID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_blueprint_requirements_blueprints` (`BlueprintID`),
  KEY `FK_blueprint_requirements_recipe_requirement` (`RecipeRequirementID`),
  KEY `FK_blueprint_requirements_regions` (`RegionID`),
  CONSTRAINT `FK_blueprint_requirements_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`),
  CONSTRAINT `FK_blueprint_requirements_recipe_requirement` FOREIGN KEY (`RecipeRequirementID`) REFERENCES `recipe_requirement` (`ID`),
  CONSTRAINT `FK_blueprint_requirements_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.building_items
CREATE TABLE IF NOT EXISTS `building_items` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ContainerID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `Quality` tinyint(6) unsigned NOT NULL DEFAULT '0' COMMENT '0-100',
  `Quantity` int(6) unsigned NOT NULL DEFAULT '0',
  `Durability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point',
  PRIMARY KEY (`ID`),
  KEY `FK_BuildingItemsContainerID` (`ContainerID`),
  KEY `FK_BuildingItemTypeID` (`ObjectTypeID`) USING BTREE,
  CONSTRAINT `FK_BuildingItemsContainerID` FOREIGN KEY (`ContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_BuildingItemTypeID` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Used for holding building materials in a construction site.';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character
CREATE TABLE IF NOT EXISTS `character` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `IsActive` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `Name` varchar(9) COLLATE utf8_unicode_ci NOT NULL,
  `LastName` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `GeoID` int(10) unsigned DEFAULT '0',
  `AccountID` int(10) unsigned NOT NULL,
  `GeoAlt` smallint(5) unsigned DEFAULT '0',
  `OffsetMmX` smallint(6) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the center of GeoID',
  `OffsetMmY` smallint(6) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the center of GeoID',
  `OffsetMmZ` tinyint(3) NOT NULL DEFAULT '0' COMMENT 'in millimeters from the GeoAlt',
  `RaceID` tinyint(3) unsigned NOT NULL,
  `Alignment` int(10) NOT NULL COMMENT '6 digits after point',
  `CriminalSecondsLeft` int(10) unsigned NOT NULL DEFAULT '0',
  `Strength` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `StrengthLock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'up 1 lock 0 down -1',
  `Agility` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `AgilityLock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'up 1 lock 0 down -1',
  `Intellect` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `IntellectLock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'up 1 lock 0 down -1',
  `Willpower` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `WillpowerLock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'up 1 lock 0 down -1',
  `Constitution` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `ConstitutionLock` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'up 1 lock 0 down -1',
  `RootContainerID` int(10) unsigned NOT NULL,
  `EquipmentContainerID` int(10) unsigned NOT NULL,
  `HardHP` int(10) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
  `HardStam` int(10) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
  `SoftHP` int(10) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
  `SoftStam` int(10) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
  `Luck` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `HungerRate` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point',
  `AlchemyHash` binary(90) NOT NULL COMMENT 'Hash of effects sets IDs',
  `VisibilityHash` binary(90) NOT NULL COMMENT 'Hash of effects visibility for player',
  `appearance` blob,
  `GuildID` int(10) unsigned DEFAULT NULL,
  `GuildRoleID` tinyint(3) unsigned DEFAULT NULL,
  `TitleMessageID` int(10) unsigned DEFAULT NULL,
  `BindedObjectID` int(10) unsigned DEFAULT NULL,
  `RallyObjectID` int(10) unsigned DEFAULT NULL,
  `LastTimeUsedPraiseYourGodAbility` int(10) unsigned NOT NULL DEFAULT '0',
  `LastTimeUsedTransmuteIntoGold` int(10) unsigned NOT NULL DEFAULT '0',
  `CreateTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeleteTimestamp` timestamp NULL DEFAULT NULL,
  `WasInJudgmentHourOnLogout` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_Name` (`Name`),
  UNIQUE KEY `UNQ_FK_RootContainerID` (`RootContainerID`),
  UNIQUE KEY `UNQ_FK_character_EquipmentContainerID` (`EquipmentContainerID`),
  KEY `FK_AccountID` (`AccountID`),
  KEY `FK_character_unmovable_objects` (`BindedObjectID`),
  KEY `IDX_IsActive` (`IsActive`),
  KEY `FK_character_race` (`RaceID`),
  KEY `FK_GuildID` (`GuildID`),
  KEY `FK_character_guild_roles` (`GuildRoleID`),
  KEY `FK_character_unmovable_objects2` (`RallyObjectID`),
  CONSTRAINT `FK_AccountID` FOREIGN KEY (`AccountID`) REFERENCES `account` (`ID`),
  CONSTRAINT `FK_character_EquipmentContainerID` FOREIGN KEY (`EquipmentContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_character_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`),
  CONSTRAINT `FK_character_race` FOREIGN KEY (`RaceID`) REFERENCES `race` (`ID`),
  CONSTRAINT `FK_character_unmovable_objects` FOREIGN KEY (`BindedObjectID`) REFERENCES `unmovable_objects` (`ID`),
  CONSTRAINT `FK_character_unmovable_objects2` FOREIGN KEY (`RallyObjectID`) REFERENCES `unmovable_objects` (`ID`),
  CONSTRAINT `FK_GuildID` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_RootContainerID` FOREIGN KEY (`RootContainerID`) REFERENCES `containers` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_blueprints
CREATE TABLE IF NOT EXISTS `character_blueprints` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharID` int(10) unsigned NOT NULL,
  `BlueprintID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `FK_character_blueprints_blueprints` (`BlueprintID`),
  KEY `FK_character_blueprints_character` (`CharID`),
  CONSTRAINT `FK_character_blueprints_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`),
  CONSTRAINT `FK_character_blueprints_character` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_effects
CREATE TABLE IF NOT EXISTS `character_effects` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PlayerEffectID` tinyint(3) unsigned NOT NULL,
  `CharacterID` int(10) unsigned NOT NULL,
  `Magnitude` int(10) unsigned NOT NULL COMMENT '6 digits after point',
  `DurationLeft` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'In seconds',
  `UpdateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `FK_character_effects_character` (`CharacterID`),
  CONSTRAINT `FK_character_effects_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores player''s effects';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_server_id_ranges
CREATE TABLE IF NOT EXISTS `character_server_id_ranges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ServerID` int(10) unsigned NOT NULL,
  `RangeStartID` int(10) unsigned NOT NULL,
  `RangeEndID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_RangeEndID` (`RangeEndID`),
  KEY `IDX_ServerID` (`ServerID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='character ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_character';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_server_id_ranges_lock
CREATE TABLE IF NOT EXISTS `character_server_id_ranges_lock` (
  `ID` tinyint(3) unsigned NOT NULL,
  `IsLocked` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_character. Do not store actual data, using only for internal needs';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_titles
CREATE TABLE IF NOT EXISTS `character_titles` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `TitleMessageID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_CharacterID_TitleMessageID` (`CharacterID`,`TitleMessageID`),
  CONSTRAINT `FK_character_titles_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.character_wounds
CREATE TABLE IF NOT EXISTS `character_wounds` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `BodyPart` tinyint(3) unsigned NOT NULL COMMENT 'Head = 0, LHand = 1, RHand = 2, Torso=3,	LLeg=4, RLeg=5 enum PartOfBodyType in cpp',
  `WoundType` tinyint(3) unsigned NOT NULL COMMENT 'Wound = 0, BigWound = 1 FractureHead = 3 enum WoundsType in cpp',
  `DurationLeft` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'In seconds',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_character_wounds_CharacterID_BodyPart_WoundType` (`CharacterID`,`BodyPart`,`WoundType`),
  CONSTRAINT `FK_character_wound_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.chars_deathlog
CREATE TABLE IF NOT EXISTS `chars_deathlog` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CharID` int(10) unsigned NOT NULL,
  `KillerID` int(10) unsigned NOT NULL,
  `IsKnockout` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IDX_CharID_Time` (`CharID`,`Time`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.claims
CREATE TABLE IF NOT EXISTS `claims` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GuildLandID` int(10) unsigned DEFAULT NULL,
  `PersonalLandID` int(10) unsigned DEFAULT NULL,
  `AdminLandID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_GuildLandID` (`GuildLandID`),
  UNIQUE KEY `UNQ_PersonalLandID` (`PersonalLandID`),
  UNIQUE KEY `UNQ_AdminLandID` (`AdminLandID`),
  KEY `FK_claims_admin_lands` (`AdminLandID`),
  CONSTRAINT `FK_claims_admin_lands` FOREIGN KEY (`AdminLandID`) REFERENCES `admin_lands` (`ID`),
  CONSTRAINT `FK_claims_guild_lands` FOREIGN KEY (`GuildLandID`) REFERENCES `guild_lands` (`ID`),
  CONSTRAINT `FK_claims_personal_lands` FOREIGN KEY (`PersonalLandID`) REFERENCES `personal_lands` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.claim_rules
CREATE TABLE IF NOT EXISTS `claim_rules` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ClaimID` int(10) unsigned NOT NULL,
  `ClaimSubjectID` int(10) unsigned NOT NULL,
  `CanEnter` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CanBuild` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CanClaim` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CanUse` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CanDestroy` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_ClaimID_ClaimSubjectID` (`ClaimID`,`ClaimSubjectID`),
  KEY `FK_claim_rules_claims` (`ClaimID`),
  KEY `FK_claim_rules_claim_subjects` (`ClaimSubjectID`),
  CONSTRAINT `FK_claim_rules_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`),
  CONSTRAINT `FK_claim_rules_claim_subjects` FOREIGN KEY (`ClaimSubjectID`) REFERENCES `claim_subjects` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=368 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.claim_rules_unmovable
CREATE TABLE IF NOT EXISTS `claim_rules_unmovable` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableClaimID` int(10) unsigned NOT NULL,
  `ClaimSubjectID` int(10) unsigned NOT NULL,
  `CanUse` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CanDestroy` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_UnmovableClaimID_ClaimSubjectID` (`UnmovableClaimID`,`ClaimSubjectID`),
  KEY `FK_claim_rules_unmovable_unmovable_objects_claims` (`UnmovableClaimID`),
  KEY `FK_claim_rules_unmovable_claim_subjects` (`ClaimSubjectID`),
  CONSTRAINT `FK_claim_rules_unmovable_claim_subjects` FOREIGN KEY (`ClaimSubjectID`) REFERENCES `claim_subjects` (`ID`),
  CONSTRAINT `FK_claim_rules_unmovable_unmovable_objects_claims` FOREIGN KEY (`UnmovableClaimID`) REFERENCES `unmovable_objects_claims` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.claim_subjects
CREATE TABLE IF NOT EXISTS `claim_subjects` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharID` int(10) unsigned DEFAULT NULL,
  `GuildRoleID` tinyint(3) unsigned DEFAULT NULL,
  `GuildID` int(10) unsigned DEFAULT NULL,
  `StandingTypeID` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_FK_claim_subjects_character` (`CharID`),
  UNIQUE KEY `UNQ_FK_claim_subjects_guild_roles` (`GuildRoleID`),
  UNIQUE KEY `UNQ_FK_claim_subjects_guilds` (`GuildID`),
  UNIQUE KEY `UNQ_FK_claim_subjects_standing_types` (`StandingTypeID`),
  CONSTRAINT `FK_claim_subjects_character` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_claim_subjects_guilds` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_claim_subjects_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`),
  CONSTRAINT `FK_claim_subjects_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.containers
CREATE TABLE IF NOT EXISTS `containers` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ParentID` int(10) unsigned DEFAULT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `Quality` tinyint(6) unsigned NOT NULL DEFAULT '0' COMMENT '0-100',
  `FeatureID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_ParentID` (`ParentID`),
  KEY `FK_ContainerTypeID` (`ObjectTypeID`) USING BTREE,
  KEY `FK_ContanersFeaturesID` (`FeatureID`),
  CONSTRAINT `FK_ContainersObjectTypeID` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_ContanersFeaturesID` FOREIGN KEY (`FeatureID`) REFERENCES `features` (`ID`),
  CONSTRAINT `FK_ParentID` FOREIGN KEY (`ParentID`) REFERENCES `containers` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=504 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.custom_texts
CREATE TABLE IF NOT EXISTS `custom_texts` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Custom_text` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `BYTEXT` (`Custom_text`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.deleted_character_info
CREATE TABLE IF NOT EXISTS `deleted_character_info` (
  `ID` int(10) unsigned NOT NULL,
  `AccountID` int(10) unsigned DEFAULT NULL,
  `CharName` varchar(9) COLLATE utf8_unicode_ci NOT NULL,
  `CharLastName` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `DeletedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CreateTimestamp` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.deleted_guild_info
CREATE TABLE IF NOT EXISTS `deleted_guild_info` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ExGuildID` int(10) unsigned NOT NULL,
  `GuildName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `DeletedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.effects
CREATE TABLE IF NOT EXISTS `effects` (
  `ID` tinyint(10) unsigned NOT NULL AUTO_INCREMENT,
  `Effect_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ResultPreparationID` int(10) unsigned DEFAULT NULL,
  `ResultPotionID` int(10) unsigned DEFAULT NULL,
  `PlayerEffectID` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_effects_result_preparation_objects_types` (`ResultPreparationID`),
  KEY `FK_effects_result_potion_objects_types` (`ResultPotionID`),
  CONSTRAINT `FK_effects_result_potion_objects_types` FOREIGN KEY (`ResultPotionID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_effects_result_preparation_objects_types` FOREIGN KEY (`ResultPreparationID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.effects_sets
CREATE TABLE IF NOT EXISTS `effects_sets` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `EffectID1` tinyint(10) unsigned NOT NULL,
  `EffectID2` tinyint(10) unsigned DEFAULT NULL,
  `EffectID3` tinyint(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_effects_sets_effects_2` (`EffectID2`),
  KEY `FK_effects_sets_effects_3` (`EffectID3`),
  KEY `FK_effects_sets_effects_1` (`EffectID1`),
  CONSTRAINT `FK_effects_sets_effects_1` FOREIGN KEY (`EffectID1`) REFERENCES `effects` (`ID`),
  CONSTRAINT `FK_effects_sets_effects_2` FOREIGN KEY (`EffectID2`) REFERENCES `effects` (`ID`),
  CONSTRAINT `FK_effects_sets_effects_3` FOREIGN KEY (`EffectID3`) REFERENCES `effects` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.equipment_slots
CREATE TABLE IF NOT EXISTS `equipment_slots` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `Slot` tinyint(3) unsigned NOT NULL COMMENT 'Valid slots: 1-16',
  `ItemID` int(10) unsigned DEFAULT NULL,
  `SkinID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_equipment_slots_CharacterID_Slot` (`CharacterID`,`Slot`),
  KEY `FK_equipment_slots_items` (`ItemID`),
  CONSTRAINT `FK_equipment_slots_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_equipment_slots_items` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.features
CREATE TABLE IF NOT EXISTS `features` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CustomtextID` int(10) unsigned DEFAULT NULL,
  `CreatedRegionID` int(10) unsigned DEFAULT NULL COMMENT 'Region of item''s origin',
  `BlueprintID` int(10) unsigned DEFAULT NULL COMMENT 'ID of actual blueprint for blueprint items',
  `HorseHP` int(11) DEFAULT NULL COMMENT '6 digits after point',
  `HorseStamina` int(11) DEFAULT NULL COMMENT '6 digits after point',
  `has_effects` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `FK_features_blueprints` (`BlueprintID`),
  KEY `FK_FeauturesCustomTextID` (`CustomtextID`),
  KEY `FK_features_regions` (`CreatedRegionID`),
  CONSTRAINT `FK_features_blueprints` FOREIGN KEY (`BlueprintID`) REFERENCES `blueprints` (`ID`),
  CONSTRAINT `FK_features_regions` FOREIGN KEY (`CreatedRegionID`) REFERENCES `regions` (`ID`),
  CONSTRAINT `FK_FeauturesCustomTextID` FOREIGN KEY (`CustomtextID`) REFERENCES `custom_texts` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.food_eaten
CREATE TABLE IF NOT EXISTS `food_eaten` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharID` int(10) unsigned NOT NULL,
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `FoodTypeID` int(10) unsigned NOT NULL,
  `Complexity` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_food_eaten_objects_types` (`FoodTypeID`),
  KEY `IDX_CharID_Time` (`CharID`,`Time`),
  CONSTRAINT `FK_food_eaten_objects_types` FOREIGN KEY (`FoodTypeID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.forest
CREATE TABLE IF NOT EXISTS `forest` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GeoDataID` int(10) unsigned NOT NULL,
  `TreeType` tinyint(3) unsigned NOT NULL,
  `TreePlantMethod` tinyint(3) unsigned NOT NULL,
  `SubcellMask` tinyint(3) unsigned NOT NULL,
  `AgeTime` int(10) unsigned NOT NULL,
  `Quality` float NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `GeoDataID_unique` (`GeoDataID`)
) ENGINE=InnoDB AUTO_INCREMENT=246775 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.forest_patch
CREATE TABLE IF NOT EXISTS `forest_patch` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TerID` int(10) unsigned NOT NULL,
  `Version` int(10) unsigned NOT NULL,
  `Action` tinyint(3) unsigned NOT NULL COMMENT '1=Add; 2=UpdateHealth; 3=Remove; 4=Cut; 5=GrowAll',
  `GeoDataID` int(10) unsigned DEFAULT NULL COMMENT 'NULL for GrowAll operation, which needs only TerID',
  `SubcellMask` tinyint(3) unsigned DEFAULT NULL COMMENT '4x4 offset within game cell. Stores as "yyxx" bits',
  `TreeType` tinyint(3) unsigned DEFAULT NULL COMMENT '0=Apple; 1=Birch; 2=Elm; 3=Spruce; 4=Pine; 5=Maple; 6=Mulberry; 7=Oak; 8=Willow;',
  `TreeHealth` tinyint(3) unsigned DEFAULT NULL COMMENT '0=Ill; 1=Normal; 2=Great; 3=Stump',
  `TreePlantMethod` tinyint(3) unsigned DEFAULT NULL,
  `AddTime` int(10) unsigned DEFAULT NULL COMMENT 'Used in Add and GrowAll operations',
  PRIMARY KEY (`ID`),
  KEY `FK_forest_patch_terrain_blocks` (`TerID`),
  CONSTRAINT `FK_forest_patch_terrain_blocks` FOREIGN KEY (`TerID`) REFERENCES `terrain_blocks` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=237009 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.geo_patch
CREATE TABLE IF NOT EXISTS `geo_patch` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TerID` int(10) unsigned NOT NULL,
  `Version` int(10) unsigned NOT NULL,
  `ChangeIndex` int(10) unsigned NOT NULL COMMENT 'Internal index of change within one version (starts from 1)',
  `IsServerOnly` tinyint(3) unsigned NOT NULL,
  `Action` tinyint(3) unsigned NOT NULL COMMENT '1=Add; 2=Delete;',
  `GeoDataID` int(10) unsigned NOT NULL,
  `Altitude` smallint(5) unsigned NOT NULL,
  `Substance` tinyint(3) unsigned DEFAULT NULL COMMENT 'GeoSubstanceID',
  `LevelFlags` tinyint(3) unsigned DEFAULT NULL COMMENT 'Level flags from geo-file',
  `Quantity` smallint(5) unsigned DEFAULT NULL COMMENT 'substance quantity (using as decay counter for air)',
  `Quality` tinyint(3) unsigned DEFAULT NULL COMMENT 'substance quality',
  PRIMARY KEY (`ID`),
  KEY `IDX_TerID_Version` (`TerID`,`Version`),
  CONSTRAINT `FK_geo_patch_terrain_blocks` FOREIGN KEY (`TerID`) REFERENCES `terrain_blocks` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4828931 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.gm_action_log
CREATE TABLE IF NOT EXISTS `gm_action_log` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `AccountID` int(10) unsigned NOT NULL,
  `Action` varchar(10000) COLLATE utf8_unicode_ci NOT NULL,
  `ActionTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3704 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guilds
CREATE TABLE IF NOT EXISTS `guilds` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTypeID` tinyint(3) unsigned NOT NULL,
  `Derelicted` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'derelicted status',
  `IsActive` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `HeraldryID` int(10) unsigned DEFAULT NULL,
  `CreateTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DeleteTimestamp` timestamp NULL DEFAULT NULL,
  `HeraldryChangedTimestamp` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_Name` (`Name`),
  UNIQUE KEY `UNQ_GuildTag` (`GuildTag`),
  UNIQUE KEY `FK_guilds_heraldries` (`HeraldryID`),
  KEY `IDX_IsActive` (`IsActive`),
  KEY `FK_guilds_guild_types` (`GuildTypeID`),
  CONSTRAINT `FK_guilds_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`),
  CONSTRAINT `FK_guilds_heraldries` FOREIGN KEY (`HeraldryID`) REFERENCES `heraldries` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_actions_processed
CREATE TABLE IF NOT EXISTS `guild_actions_processed` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TicketID` bigint(20) unsigned NOT NULL COMMENT 'Unique number for identifying query',
  `ActionType` enum('guild_create','guild_destroy','player_invite_to_guild','player_invite_cancelled','player_invite_accepted','player_invite_declined','player_left_guild','player_guild_kicked','player_new_guild_role','guild_change_standing','monument_built','monument_destroyed','set_claim_char_rule','set_claim_role_rule','set_claim_guild_rule','set_claim_standing_rule','set_unmovable_char_rule','set_unmovable_role_rule','set_unmovable_guild_rule','set_unmovable_standing_rule','remove_unmovable_char_rule','remove_unmovable_role_rule','remove_unmovable_guild_rule','remove_unmovable_standing_rule','set_guild_heraldry','guild_rename','remove_claim_char_rule','remove_claim_role_rule','remove_claim_guild_rule','remove_claim_standing_rule') COLLATE utf8_unicode_ci NOT NULL,
  `ProcessedStatus` enum('failed','processed','user_accepted','user_declined') COLLATE utf8_unicode_ci NOT NULL,
  `ProducerCharID` int(10) unsigned DEFAULT NULL COMMENT 'character.ID',
  `GuildID` int(10) unsigned DEFAULT NULL COMMENT 'guilds.ID',
  `GuildDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_guild_info.ID',
  `CharID` int(10) unsigned DEFAULT NULL COMMENT 'character.ID',
  `GuildName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTypeID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_types.ID',
  `CharIsKicked` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CharGuildRoleID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_roles.ID',
  `OtherGuildID` int(10) unsigned DEFAULT NULL COMMENT 'guilds.ID',
  `OtherGuildDeletedID` int(10) unsigned DEFAULT NULL COMMENT 'deleted_guild_info.ID',
  `StandingTypeID` tinyint(3) unsigned DEFAULT NULL COMMENT 'guild_standing_types',
  `UnmovableObjectID` int(10) unsigned DEFAULT NULL,
  `ClaimID` int(10) unsigned DEFAULT NULL,
  `HeraldryID` int(10) unsigned DEFAULT NULL,
  `CanEnter` tinyint(3) unsigned DEFAULT NULL,
  `CanBuild` tinyint(3) unsigned DEFAULT NULL,
  `CanClaim` tinyint(3) unsigned DEFAULT NULL,
  `CanUse` tinyint(3) unsigned DEFAULT NULL,
  `CanDestroy` tinyint(3) unsigned DEFAULT NULL,
  `ProcessedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_TicketID` (`TicketID`),
  KEY `FK_guild_actions_processed_character1` (`ProducerCharID`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_actions_queue
CREATE TABLE IF NOT EXISTS `guild_actions_queue` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TicketID` bigint(20) unsigned NOT NULL COMMENT 'Unique number for identifying query',
  `ActionType` enum('guild_create','guild_destroy','player_invite_to_guild','player_invite_cancelled','player_invite_accepted','player_invite_declined','player_left_guild','player_guild_kicked','player_new_guild_role','guild_change_standing','monument_built','monument_destroyed','set_claim_char_rule','set_claim_role_rule','set_claim_guild_rule','set_claim_standing_rule','set_unmovable_char_rule','set_unmovable_role_rule','set_unmovable_guild_rule','set_unmovable_standing_rule','remove_unmovable_char_rule','remove_unmovable_role_rule','remove_unmovable_guild_rule','remove_unmovable_standing_rule','set_guild_heraldry','guild_rename','remove_claim_char_rule','remove_claim_role_rule','remove_claim_guild_rule','remove_claim_standing_rule') COLLATE utf8_unicode_ci NOT NULL,
  `ProducerCharID` int(10) unsigned NOT NULL,
  `GuildID` int(10) unsigned DEFAULT NULL,
  `CharID` int(10) unsigned DEFAULT NULL,
  `GuildName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTag` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildCharter` varchar(10000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `GuildTypeID` tinyint(3) unsigned DEFAULT NULL,
  `CharIsKicked` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `CharGuildRoleID` tinyint(3) unsigned DEFAULT NULL,
  `OtherGuildID` int(10) unsigned DEFAULT NULL,
  `StandingTypeID` tinyint(3) unsigned DEFAULT NULL,
  `UnmovableObjectID` int(10) unsigned DEFAULT NULL,
  `ClaimID` int(10) unsigned DEFAULT NULL,
  `HeraldryID` int(10) unsigned DEFAULT NULL,
  `CanEnter` tinyint(3) unsigned DEFAULT NULL,
  `CanBuild` tinyint(3) unsigned DEFAULT NULL,
  `CanClaim` tinyint(3) unsigned DEFAULT NULL,
  `CanUse` tinyint(3) unsigned DEFAULT NULL,
  `CanDestroy` tinyint(3) unsigned DEFAULT NULL,
  `AddedTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OwnerConnectionID` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'For internal processing',
  `OwnedTimestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'For internal processing. Updates with OwnerConnectionID',
  PRIMARY KEY (`ID`),
  KEY `IDX_OwnerConnectionID_OwnedTime` (`OwnerConnectionID`,`OwnedTimestamp`),
  KEY `FK_guild_actions_queue_character1` (`ProducerCharID`),
  KEY `FK_guild_actions_queue_character2` (`CharID`),
  KEY `FK_guild_actions_queue_guilds1` (`GuildID`),
  KEY `FK_guild_actions_queue_guilds2` (`OtherGuildID`),
  KEY `FK_guild_actions_queue_guild_types` (`GuildTypeID`),
  KEY `FK_guild_actions_queue_guild_roles` (`CharGuildRoleID`),
  KEY `FK_guild_actions_queue_guild_standing_types` (`StandingTypeID`),
  KEY `FK_guild_actions_queue_unmovable_objects` (`UnmovableObjectID`),
  KEY `FK_guild_actions_queue_claims` (`ClaimID`),
  KEY `FK_guild_actions_queue_heraldries` (`HeraldryID`),
  CONSTRAINT `FK_guild_actions_queue_character1` FOREIGN KEY (`ProducerCharID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_character2` FOREIGN KEY (`CharID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_guilds1` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_guilds2` FOREIGN KEY (`OtherGuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_guild_roles` FOREIGN KEY (`CharGuildRoleID`) REFERENCES `guild_roles` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_guild_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_heraldries` FOREIGN KEY (`HeraldryID`) REFERENCES `heraldries` (`ID`),
  CONSTRAINT `FK_guild_actions_queue_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_invites
CREATE TABLE IF NOT EXISTS `guild_invites` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GuildID` int(10) unsigned NOT NULL,
  `SenderCharID` int(10) unsigned NOT NULL,
  `ReceiverCharID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_guild_invites_guild` (`GuildID`),
  KEY `FK_guild_invites_sender_char` (`SenderCharID`),
  KEY `FK_guild_invites_receiver_char` (`ReceiverCharID`),
  CONSTRAINT `FK_guild_invites_guild` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_guild_invites_receiver_char` FOREIGN KEY (`ReceiverCharID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_guild_invites_sender_char` FOREIGN KEY (`SenderCharID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_lands
CREATE TABLE IF NOT EXISTS `guild_lands` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GuildID` int(10) unsigned NOT NULL,
  `Name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `CenterGeoID` int(10) unsigned NOT NULL,
  `Radius` int(10) unsigned NOT NULL,
  `LandType` int(10) unsigned NOT NULL COMMENT '3=Yo, 4=Outpost',
  `SupportPoints` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_guild_lands_guilds` (`GuildID`),
  CONSTRAINT `FK_guild_lands_guilds` FOREIGN KEY (`GuildID`) REFERENCES `guilds` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_roles
CREATE TABLE IF NOT EXISTS `guild_roles` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_standings
CREATE TABLE IF NOT EXISTS `guild_standings` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GuildID1` int(10) unsigned NOT NULL,
  `GuildID2` int(10) unsigned NOT NULL,
  `StandingTypeID` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_GuildID1_GuildID2` (`GuildID1`,`GuildID2`),
  KEY `FK_guild_standings_guild_standing_types` (`StandingTypeID`),
  KEY `IDX_GuildID2_GuildID1` (`GuildID2`,`GuildID1`),
  CONSTRAINT `FK_guild_standings_guilds1` FOREIGN KEY (`GuildID1`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_guild_standings_guilds2` FOREIGN KEY (`GuildID2`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_guild_standings_guild_standing_types` FOREIGN KEY (`StandingTypeID`) REFERENCES `guild_standing_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_standing_types
CREATE TABLE IF NOT EXISTS `guild_standing_types` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_types
CREATE TABLE IF NOT EXISTS `guild_types` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `MessageID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.guild_type_role_msgs
CREATE TABLE IF NOT EXISTS `guild_type_role_msgs` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `GuildTypeID` tinyint(3) unsigned NOT NULL,
  `GuildRoleID` tinyint(3) unsigned NOT NULL,
  `Gender` enum('male','female') COLLATE utf8_unicode_ci NOT NULL,
  `MessageID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_guild_type_role_msgs_guild_roles` (`GuildRoleID`),
  KEY `FK_guild_type_role_msgs_guild_types` (`GuildTypeID`),
  CONSTRAINT `FK_guild_type_role_msgs_guild_roles` FOREIGN KEY (`GuildRoleID`) REFERENCES `guild_roles` (`ID`),
  CONSTRAINT `FK_guild_type_role_msgs_guild_types` FOREIGN KEY (`GuildTypeID`) REFERENCES `guild_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.heraldic_charges
CREATE TABLE IF NOT EXISTS `heraldic_charges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `SymbolIndex` tinyint(3) unsigned NOT NULL,
  `ColorIndex` tinyint(3) unsigned NOT NULL,
  `Position` enum('top_left','top_center','top_right','middle_left','true_center','middle_right','bottom_left','bottom_center','bottom_right') COLLATE utf8_unicode_ci NOT NULL,
  `Size` enum('small','medium','large') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_SymbolIndex_ColorIndex_Position_Size` (`SymbolIndex`,`ColorIndex`,`Position`,`Size`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.heraldries
CREATE TABLE IF NOT EXISTS `heraldries` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `BackgroundIndex` tinyint(3) unsigned NOT NULL,
  `BackgroundColorIndex1` tinyint(3) unsigned NOT NULL,
  `BackgroundColorIndex2` tinyint(3) unsigned NOT NULL,
  `ChargeID1` int(10) unsigned DEFAULT NULL,
  `ChargeID2` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_heraldries_heraldic_charges1` (`ChargeID1`),
  KEY `FK_heraldries_heraldic_charges2` (`ChargeID2`),
  CONSTRAINT `FK_heraldries_heraldic_charges1` FOREIGN KEY (`ChargeID1`) REFERENCES `heraldic_charges` (`ID`),
  CONSTRAINT `FK_heraldries_heraldic_charges2` FOREIGN KEY (`ChargeID2`) REFERENCES `heraldic_charges` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.horses
CREATE TABLE IF NOT EXISTS `horses` (
  `ID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `Quality` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `HP` int(11) NOT NULL DEFAULT '1000000' COMMENT '6 digits after point',
  `GeoID` int(10) unsigned NOT NULL,
  `GeoAlt` smallint(5) unsigned NOT NULL,
  `OffsetX` smallint(6) NOT NULL COMMENT 'ingame millimeters',
  `OffsetY` smallint(6) NOT NULL COMMENT 'ingame millimeters',
  `OffsetZ` int(10) NOT NULL COMMENT 'ingame millimeters',
  `TurnAngle` smallint(6) NOT NULL COMMENT 'rotation angle',
  `MountedCharacterID` int(10) unsigned DEFAULT NULL,
  `OwnerID` int(10) unsigned DEFAULT NULL,
  `DroppedTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Durability` smallint(10) unsigned NOT NULL DEFAULT '100' COMMENT '2 digits after point',
  `CreatedDurability` smallint(10) unsigned NOT NULL DEFAULT '100' COMMENT '2 digits after point',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_MountedCharacterID` (`MountedCharacterID`),
  KEY `FK_horses_character` (`ObjectTypeID`),
  KEY `FK_horses_character2` (`OwnerID`),
  CONSTRAINT `FK_horses_character` FOREIGN KEY (`MountedCharacterID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_horses_character2` FOREIGN KEY (`OwnerID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_horses_objects_types` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.horses_server_id_ranges
CREATE TABLE IF NOT EXISTS `horses_server_id_ranges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ServerID` int(10) unsigned NOT NULL,
  `RangeStartID` int(10) unsigned NOT NULL,
  `RangeEndID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_RangeEndID` (`RangeEndID`),
  KEY `IDX_ServerID` (`ServerID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='horses ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_horses';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.horses_server_id_ranges_lock
CREATE TABLE IF NOT EXISTS `horses_server_id_ranges_lock` (
  `ID` tinyint(3) unsigned NOT NULL,
  `IsLocked` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_horses. Do not store actual data, using only for internal needs';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.items
CREATE TABLE IF NOT EXISTS `items` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ContainerID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `Quality` tinyint(6) unsigned NOT NULL DEFAULT '0',
  `Quantity` int(6) unsigned NOT NULL DEFAULT '0',
  `Durability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point',
  `CreatedDurability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point, also acts as MaxDurability',
  `FeatureID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_FeatureID` (`FeatureID`),
  KEY `FK_ItemsContainerID` (`ContainerID`),
  KEY `FK_ItemTypeID` (`ObjectTypeID`) USING BTREE,
  CONSTRAINT `FK_ItemsContainerID` FOREIGN KEY (`ContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_ItemsFeaturesID` FOREIGN KEY (`FeatureID`) REFERENCES `features` (`ID`),
  CONSTRAINT `FK_ItemsObjectTypeID` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=860 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.item_effects
CREATE TABLE IF NOT EXISTS `item_effects` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ItemID` int(10) unsigned NOT NULL,
  `EffectID` tinyint(10) unsigned NOT NULL,
  `Magnitude` smallint(10) unsigned NOT NULL COMMENT '3 digits after point',
  PRIMARY KEY (`ID`),
  KEY `FK_ItemEffectsItemID` (`ItemID`),
  KEY `FK_item_effects_effects` (`EffectID`),
  CONSTRAINT `FK_ItemEffectsItemID` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`),
  CONSTRAINT `FK_item_effects_effects` FOREIGN KEY (`EffectID`) REFERENCES `effects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.movable_objects
CREATE TABLE IF NOT EXISTS `movable_objects` (
  `ID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `RootContainerID` int(10) unsigned DEFAULT NULL,
  `TurnAngle` smallint(11) NOT NULL,
  `Durability` smallint(10) unsigned NOT NULL COMMENT 'Less then 10 - object is damaged',
  `CreatedDurability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point, also acts as MaxDurability',
  `GeoDataID` int(10) unsigned NOT NULL,
  `Altitude` smallint(5) unsigned NOT NULL COMMENT 'Altitude in ingame decimeters',
  `IsComplete` tinyint(3) unsigned NOT NULL,
  `CarrierCharacterID` int(10) unsigned DEFAULT NULL,
  `CarrierHorseID` int(10) unsigned DEFAULT NULL,
  `DroppedItemID` int(10) unsigned DEFAULT NULL,
  `CarrierMovableID` int(10) unsigned DEFAULT NULL,
  `OwnerID` int(10) unsigned DEFAULT NULL,
  `CustomNameID` int(10) unsigned DEFAULT NULL,
  `DroppedTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `OffsetMmX` smallint(6) NOT NULL COMMENT 'ingame millimeters',
  `OffsetMmY` smallint(6) NOT NULL COMMENT 'ingame millimeters',
  `OffsetMmZ` int(11) NOT NULL COMMENT 'ingame millimeters',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_CarrierCharacterID` (`CarrierCharacterID`),
  UNIQUE KEY `FK_carrier_horse_to_horses` (`CarrierHorseID`),
  UNIQUE KEY `UNQ_dropped_item_items` (`DroppedItemID`),
  KEY `FK_MovableObjectsContainerID` (`RootContainerID`),
  KEY `FK_MovableObjectTypeID` (`ObjectTypeID`) USING BTREE,
  KEY `FK_ownerID` (`OwnerID`),
  KEY `FK_carrier_movable_to_movables` (`CarrierMovableID`),
  KEY `FK_movable_objects_custom_text` (`CustomNameID`),
  CONSTRAINT `FK_carrier_horse_to_horses` FOREIGN KEY (`CarrierHorseID`) REFERENCES `horses` (`ID`),
  CONSTRAINT `FK_carrier_movable_to_movables` FOREIGN KEY (`CarrierMovableID`) REFERENCES `movable_objects` (`ID`),
  CONSTRAINT `FK_dropped_item_items` FOREIGN KEY (`DroppedItemID`) REFERENCES `items` (`ID`),
  CONSTRAINT `FK_MovableObjectsContainerID` FOREIGN KEY (`RootContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_MovableObjectsObjectTypeID` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_movable_objects_character` FOREIGN KEY (`CarrierCharacterID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_movable_objects_custom_text` FOREIGN KEY (`CustomNameID`) REFERENCES `custom_texts` (`ID`),
  CONSTRAINT `FK_ownerID` FOREIGN KEY (`OwnerID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.movable_objects_server_id_ranges
CREATE TABLE IF NOT EXISTS `movable_objects_server_id_ranges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ServerID` int(10) unsigned NOT NULL,
  `RangeStartID` int(10) unsigned NOT NULL,
  `RangeEndID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_RangeEndID` (`RangeEndID`),
  KEY `FK_movable_objects_server_id_ranges_servers` (`ServerID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='movable_objects ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_movable_objects';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.movable_objects_server_id_ranges_lock
CREATE TABLE IF NOT EXISTS `movable_objects_server_id_ranges_lock` (
  `ID` tinyint(3) unsigned NOT NULL,
  `IsLocked` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_movable_objects. Do not store actual data, using only for internal needs';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.nav_mesh_cache
CREATE TABLE IF NOT EXISTS `nav_mesh_cache` (
  `ServerID` smallint(5) unsigned NOT NULL,
  `FileCRC` int(10) unsigned NOT NULL,
  `FileSize` int(10) unsigned NOT NULL,
  `FileTimestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ServerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.nav_mesh_cache_ter_versions
CREATE TABLE IF NOT EXISTS `nav_mesh_cache_ter_versions` (
  `ServerID` smallint(5) unsigned NOT NULL,
  `TerID` int(10) unsigned NOT NULL,
  `ObjectsVersion` int(10) unsigned NOT NULL,
  `ForestVersion` int(10) unsigned NOT NULL,
  `GeoVersion` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ServerID`,`TerID`),
  UNIQUE KEY `UNQ_TerID` (`TerID`),
  CONSTRAINT `FK_nav_mesh_cache_ter_versions_terrain_blocks` FOREIGN KEY (`TerID`) REFERENCES `terrain_blocks` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.neighbor_regions
CREATE TABLE IF NOT EXISTS `neighbor_regions` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RegionID` int(10) unsigned NOT NULL,
  `NeighborRegionID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_neighbor_regions_regions` (`RegionID`),
  KEY `FK_neighbor_regions_regions2` (`NeighborRegionID`),
  CONSTRAINT `FK_neighbor_regions_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`),
  CONSTRAINT `FK_neighbor_regions_regions2` FOREIGN KEY (`NeighborRegionID`) REFERENCES `regions` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.objects_conversions
CREATE TABLE IF NOT EXISTS `objects_conversions` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ObjectTypeID1` int(10) unsigned DEFAULT NULL,
  `ObjectTypeID2` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_objects_conversions_objects_types1` (`ObjectTypeID1`),
  KEY `KEY_objects_conversions_objects_types2` (`ObjectTypeID2`),
  CONSTRAINT `FK_objects_conversions_objects_types1` FOREIGN KEY (`ObjectTypeID1`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_objects_conversions_objects_types2` FOREIGN KEY (`ObjectTypeID2`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.objects_patch
CREATE TABLE IF NOT EXISTS `objects_patch` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TerID` int(10) unsigned NOT NULL,
  `Version` int(10) unsigned NOT NULL,
  `Action` tinyint(3) unsigned NOT NULL COMMENT '1=Create; 2=Delete; 3=CompleteChange; 4=RotateChange',
  `ObjectSuperType` tinyint(3) unsigned NOT NULL COMMENT '1=Movable; 2=Unmovable',
  `ObjectID` int(10) unsigned NOT NULL,
  `GeoDataID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned DEFAULT NULL,
  `TurnAngle` smallint(6) DEFAULT NULL,
  `Altitude` smallint(5) unsigned DEFAULT NULL,
  `OffsetX` smallint(6) DEFAULT NULL,
  `OffsetY` smallint(6) DEFAULT NULL,
  `OffsetZ` int(11) DEFAULT NULL,
  `IsComplete` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_TerID_Version` (`TerID`,`Version`),
  KEY `FK_objects_patch_terrain_blocks` (`TerID`),
  KEY `FK_objects_patch_objects_types` (`ObjectTypeID`),
  CONSTRAINT `FK_objects_patch_objects_types` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_objects_patch_terrain_blocks` FOREIGN KEY (`TerID`) REFERENCES `terrain_blocks` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1300 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.objects_types
CREATE TABLE IF NOT EXISTS `objects_types` (
  `ID` int(10) unsigned NOT NULL,
  `ParentID` int(10) unsigned DEFAULT NULL,
  `Name` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `IsContainer` tinyint(1) NOT NULL DEFAULT '0',
  `IsMovableObject` tinyint(1) NOT NULL DEFAULT '0',
  `IsUnmovableobject` tinyint(1) NOT NULL DEFAULT '0',
  `IsTool` tinyint(1) NOT NULL DEFAULT '0',
  `IsDevice` tinyint(1) NOT NULL DEFAULT '0',
  `IsDoor` tinyint(1) NOT NULL DEFAULT '0',
  `IsPremium` tinyint(1) NOT NULL DEFAULT '0',
  `MaxContSize` int(10) unsigned DEFAULT NULL COMMENT '3 digits after point (gramm)',
  `Length` tinyint(10) unsigned DEFAULT NULL,
  `MaxStackSize` int(10) unsigned DEFAULT NULL COMMENT 'For unmovable objects stores max amount of bind slots for players',
  `UnitWeight` int(10) unsigned DEFAULT NULL COMMENT '3 digits after point (gramm)',
  `BackgndImage` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `WorkAreaTop` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `WorkAreaLeft` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `WorkAreaWidth` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `WorkAreaHeight` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `BtnCloseTop` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `BtnCloseLeft` smallint(5) unsigned DEFAULT NULL COMMENT 'obsolete',
  `FaceImage` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Description` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `BasePrice` int(10) unsigned DEFAULT NULL COMMENT 'BasePrice for Q=50 item in 0.01*copper coins',
  `OwnerTimeout` int(10) unsigned DEFAULT NULL COMMENT 'Timeout in seconds, when ownership keeping to dropper',
  `AllowExportFromRed` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'If export of this object type is allowed from red worlds',
  `AllowExportFromGreen` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'If export of this object type is allowed from green worlds',
  PRIMARY KEY (`ID`),
  KEY `FKObjectsTypesParentID` (`ParentID`),
  CONSTRAINT `FKObjectsTypesParentID` FOREIGN KEY (`ParentID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.outposts
CREATE TABLE IF NOT EXISTS `outposts` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `ProductionObjectTypeID` int(10) unsigned DEFAULT NULL,
  `SecondaryContainerID` int(10) unsigned NOT NULL,
  `OwnerGuildID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_outpost_UnmovableObjectID` (`UnmovableObjectID`),
  UNIQUE KEY `UNQ_outpost_SecondaryContainerID` (`SecondaryContainerID`),
  KEY `KEY_outpost_ProductionObjectTypeID` (`ProductionObjectTypeID`),
  KEY `KEY_outpost_OwnerGuildID` (`OwnerGuildID`),
  CONSTRAINT `FK_outposts_containers` FOREIGN KEY (`SecondaryContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_outposts_guilds` FOREIGN KEY (`OwnerGuildID`) REFERENCES `guilds` (`ID`),
  CONSTRAINT `FK_outposts_object_types` FOREIGN KEY (`ProductionObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_outposts_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.quests_answers
CREATE TABLE IF NOT EXISTS `quests_answers` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `QuestID` int(10) unsigned NOT NULL,
  `AnswerID` int(10) unsigned NOT NULL,
  `Status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_CharQuestAnswer` (`CharacterID`,`QuestID`,`AnswerID`),
  CONSTRAINT `FK_quests_answers_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.quests_progress
CREATE TABLE IF NOT EXISTS `quests_progress` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `QuestSubjectID` int(10) unsigned NOT NULL,
  `QuestID` int(10) unsigned NOT NULL,
  `ConversationID` int(10) unsigned NOT NULL,
  `NodeID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_CharSubjQuest` (`CharacterID`,`QuestSubjectID`,`QuestID`),
  CONSTRAINT `FK_quests_progress_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.quests_tasks
CREATE TABLE IF NOT EXISTS `quests_tasks` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `QuestID` int(10) unsigned NOT NULL,
  `TaskID` int(10) unsigned NOT NULL,
  `Status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_CharQuestTask` (`CharacterID`,`QuestID`,`TaskID`),
  CONSTRAINT `FK_quests_tasks_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.race
CREATE TABLE IF NOT EXISTS `race` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.recipe
CREATE TABLE IF NOT EXISTS `recipe` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `StartingToolsID` int(10) unsigned DEFAULT NULL,
  `SkillTypeID` int(10) unsigned DEFAULT NULL,
  `SkillLvl` tinyint(3) unsigned DEFAULT NULL COMMENT 'Minimum skill required',
  `ResultObjectTypeID` int(10) unsigned DEFAULT NULL,
  `SkillDepends` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Quantity` smallint(5) unsigned NOT NULL DEFAULT '0',
  `Autorepeat` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'bool',
  `IsBlueprint` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'bool',
  `ImagePath` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_recipe_starting_objects_types` (`StartingToolsID`),
  KEY `FK_recipe_skill_type` (`SkillTypeID`),
  KEY `FK_recipe_result_objects_types` (`ResultObjectTypeID`),
  CONSTRAINT `FK_recipe_result_objects_types` FOREIGN KEY (`ResultObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_recipe_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`),
  CONSTRAINT `FK_recipe_starting_objects_types` FOREIGN KEY (`StartingToolsID`) REFERENCES `objects_types` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8567 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.recipe_possible_blueprints
CREATE TABLE IF NOT EXISTS `recipe_possible_blueprints` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RecipeID` int(10) unsigned NOT NULL,
  `BaseRecipeID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_recipe_possible_blueprints_recipe` (`RecipeID`),
  KEY `FK_recipe_possible_blueprints_baserecipe` (`BaseRecipeID`),
  CONSTRAINT `FK_recipe_possible_blueprints_baserecipe` FOREIGN KEY (`BaseRecipeID`) REFERENCES `recipe` (`ID`),
  CONSTRAINT `FK_recipe_possible_blueprints_recipe` FOREIGN KEY (`RecipeID`) REFERENCES `recipe` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=438 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.recipe_requirement
CREATE TABLE IF NOT EXISTS `recipe_requirement` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RecipeID` int(10) unsigned DEFAULT NULL,
  `MaterialObjectTypeID` int(10) unsigned DEFAULT NULL,
  `Quality` tinyint(6) unsigned DEFAULT NULL,
  `Influence` tinyint(6) unsigned DEFAULT NULL,
  `Quantity` smallint(6) unsigned DEFAULT NULL COMMENT 'also amount of durability loss of a tool.',
  `IsRegionItemRequired` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'bool',
  PRIMARY KEY (`ID`),
  KEY `FK_recipe_requirement_recipe` (`RecipeID`),
  KEY `FK_recipe_requirement_objects_types` (`MaterialObjectTypeID`),
  CONSTRAINT `FK_recipe_requirement_objects_types` FOREIGN KEY (`MaterialObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_recipe_requirement_recipe` FOREIGN KEY (`RecipeID`) REFERENCES `recipe` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9012 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.regions
CREATE TABLE IF NOT EXISTS `regions` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `NameMessageID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.server_uuid
CREATE TABLE IF NOT EXISTS `server_uuid` (
  `ID` tinyint(3) unsigned NOT NULL,
  `Uuid` char(36) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.skills
CREATE TABLE IF NOT EXISTS `skills` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharacterID` int(10) unsigned NOT NULL,
  `SkillTypeID` int(10) unsigned NOT NULL,
  `SkillAmount` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '7 digits after point',
  `LockStatus` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'up 1 lock 0 down -1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_skills_CharacterID_SkillTypeID` (`CharacterID`,`SkillTypeID`),
  KEY `FK_skills_skill_type` (`SkillTypeID`),
  CONSTRAINT `FK_skills_character` FOREIGN KEY (`CharacterID`) REFERENCES `character` (`ID`),
  CONSTRAINT `FK_skills_skill_type` FOREIGN KEY (`SkillTypeID`) REFERENCES `skill_type` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=765 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.skill_raise_logs
CREATE TABLE IF NOT EXISTS `skill_raise_logs` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `SkillID` int(10) unsigned NOT NULL,
  `AbilityID` int(10) unsigned DEFAULT NULL,
  `PlayerID` int(10) unsigned NOT NULL,
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `RaiseAmount` int(10) unsigned NOT NULL COMMENT '7 digits after point',
  `SkillMult` int(10) unsigned NOT NULL,
  `FedRate` int(10) unsigned NOT NULL COMMENT '3 digits after point',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.skill_type
CREATE TABLE IF NOT EXISTS `skill_type` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `Description` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `Parent` int(10) unsigned DEFAULT NULL,
  `Group` tinyint(3) unsigned DEFAULT NULL,
  `PrimaryStat` char(4) COLLATE utf8_unicode_ci NOT NULL,
  `SecondaryStat` char(4) COLLATE utf8_unicode_ci NOT NULL,
  `MasterMessageID` int(10) unsigned DEFAULT '0',
  `GMMessageID` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `FK_skill_type_skill_type` (`Parent`),
  CONSTRAINT `FK_skill_type_skill_type` FOREIGN KEY (`Parent`) REFERENCES `skill_type` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.stables_data
CREATE TABLE IF NOT EXISTS `stables_data` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `FoodConsumeRatio` float NOT NULL DEFAULT '0',
  `DungMeter` float NOT NULL DEFAULT '0',
  `HarvestAmount` float NOT NULL DEFAULT '0',
  `HarvestQuality` float NOT NULL DEFAULT '0',
  `FoodLeft` float NOT NULL DEFAULT '0',
  `FoodQuality` float NOT NULL DEFAULT '0',
  `DungQuantity` float NOT NULL DEFAULT '0',
  `DungQuality` float NOT NULL DEFAULT '0',
  `Starving` tinyint(4) NOT NULL DEFAULT '0',
  `Dirty` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `FK_stables_data_UnmovableObjectID` (`UnmovableObjectID`),
  CONSTRAINT `FK_stables_data_UnmovableObjectID` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.stables_logs
CREATE TABLE IF NOT EXISTS `stables_logs` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `EventTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `MsgID` int(10) unsigned NOT NULL,
  `Param1` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Param2` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Param3` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_stables_logs_UnmovableObjectID` (`UnmovableObjectID`),
  CONSTRAINT `FK_stables_logs_UnmovableObjectID` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.stables_pens
CREATE TABLE IF NOT EXISTS `stables_pens` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `ItemID` int(10) unsigned NOT NULL,
  `Slot` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_stables_pens_UnmovableObjectID` (`UnmovableObjectID`),
  KEY `FK_stables_pens_ItemID` (`ItemID`),
  CONSTRAINT `FK_stables_pens_ItemID` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`),
  CONSTRAINT `FK_stables_pens_UnmovableObjectID` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.terrain_blocks
CREATE TABLE IF NOT EXISTS `terrain_blocks` (
  `ID` int(10) unsigned NOT NULL,
  `RegionID` int(10) unsigned NOT NULL,
  `ObjectsVersion` int(10) unsigned NOT NULL DEFAULT '1',
  `ForestVersion` int(10) unsigned NOT NULL DEFAULT '1',
  `GeoVersion` int(10) unsigned NOT NULL DEFAULT '1',
  `TerCRC` int(10) unsigned DEFAULT NULL,
  `GeoIdxCRC` int(10) unsigned DEFAULT NULL,
  `GeoDatCRC` int(10) unsigned DEFAULT NULL,
  `ObjectsCRC` int(10) unsigned DEFAULT NULL,
  `ForestCRC` int(10) unsigned DEFAULT NULL,
  `CachedGeoVersion` int(10) unsigned DEFAULT NULL,
  `CachedTerCRC` int(10) unsigned DEFAULT NULL,
  `CachedServerGeoIdxCRC` int(10) unsigned DEFAULT NULL,
  `CachedServerGeoDatCRC` int(10) unsigned DEFAULT NULL,
  `CachedClientGeoIdxCRC` int(10) unsigned DEFAULT NULL,
  `CachedClientGeoDatCRC` int(10) unsigned DEFAULT NULL,
  `PackedTerCRC` int(10) unsigned DEFAULT NULL,
  `PackedClientGeoIdxCRC` int(10) unsigned DEFAULT NULL,
  `PackedClientGeoDatCRC` int(10) unsigned DEFAULT NULL,
  `CachedClientGeoIdxSize` int(10) unsigned DEFAULT NULL,
  `CachedClientGeoDatSize` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_terrain_blocks_regions` (`RegionID`),
  CONSTRAINT `FK_terrain_blocks_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.unmovable_objects
CREATE TABLE IF NOT EXISTS `unmovable_objects` (
  `ID` int(10) unsigned NOT NULL,
  `ObjectTypeID` int(10) unsigned NOT NULL,
  `TurnAngle` smallint(11) NOT NULL,
  `RootContainerID` int(10) unsigned DEFAULT NULL,
  `Durability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point Less then 10 = object is damaged',
  `CreatedDurability` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '2 digits after point, also acts as MaxDurability',
  `IsComplete` tinyint(1) unsigned NOT NULL,
  `GeoDataID` int(10) unsigned NOT NULL,
  `OwnerID` int(10) unsigned DEFAULT NULL,
  `CustomNameID` int(10) unsigned DEFAULT NULL,
  `DroppedTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`ID`),
  KEY `FK_UnmovableTypeID` (`ObjectTypeID`) USING BTREE,
  KEY `FK_unmovable_objects_RootContainerID` (`RootContainerID`),
  KEY `byGeoID` (`GeoDataID`),
  KEY `FK_uownerID` (`OwnerID`),
  KEY `FK_unmovable_objects_custom_text` (`CustomNameID`),
  CONSTRAINT `FK_UnmovableObjectsObjectTypeID` FOREIGN KEY (`ObjectTypeID`) REFERENCES `objects_types` (`ID`),
  CONSTRAINT `FK_unmovable_objects_custom_text` FOREIGN KEY (`CustomNameID`) REFERENCES `custom_texts` (`ID`),
  CONSTRAINT `FK_unmovable_objects_RootContainerID` FOREIGN KEY (`RootContainerID`) REFERENCES `containers` (`ID`),
  CONSTRAINT `FK_uownerID` FOREIGN KEY (`OwnerID`) REFERENCES `character` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.unmovable_objects_claims
CREATE TABLE IF NOT EXISTS `unmovable_objects_claims` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `ClaimID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_UnmovableObjectID` (`UnmovableObjectID`),
  KEY `FK_unmovable_objects_claims_claims` (`ClaimID`),
  CONSTRAINT `FK_unmovable_objects_claims_claims` FOREIGN KEY (`ClaimID`) REFERENCES `claims` (`ID`),
  CONSTRAINT `FK_unmovable_objects_claims_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.unmovable_objects_requirements
CREATE TABLE IF NOT EXISTS `unmovable_objects_requirements` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `UnmovableObjectID` int(10) unsigned NOT NULL,
  `RecipeRequirementID` int(10) unsigned NOT NULL,
  `RegionID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UNQ_UnmovableObjectID_RecipeRequirementID` (`UnmovableObjectID`,`RecipeRequirementID`),
  KEY `FK_unmovable_objects_requirements_regions` (`RegionID`),
  KEY `FK_unmovable_objects_requirements_recipe_requirements` (`RecipeRequirementID`),
  CONSTRAINT `FK_unmovable_objects_requirements_recipe_requirements` FOREIGN KEY (`RecipeRequirementID`) REFERENCES `recipe_requirement` (`ID`),
  CONSTRAINT `FK_unmovable_objects_requirements_regions` FOREIGN KEY (`RegionID`) REFERENCES `regions` (`ID`),
  CONSTRAINT `FK_unmovable_objects_requirements_unmovable_objects` FOREIGN KEY (`UnmovableObjectID`) REFERENCES `unmovable_objects` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.unmovable_objects_server_id_ranges
CREATE TABLE IF NOT EXISTS `unmovable_objects_server_id_ranges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ServerID` int(10) unsigned NOT NULL,
  `RangeStartID` int(10) unsigned NOT NULL,
  `RangeEndID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `IDX_RangeEndID` (`RangeEndID`),
  KEY `IDX_ServerID` (`ServerID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='unmovable_objects ID ranges assigned to servers. Should be accessed only by using p_issueIdRange_unmovable_objects';

-- Data exporting was unselected.
-- Zrzut struktury tabela lif_1.unmovable_objects_server_id_ranges_lock
CREATE TABLE IF NOT EXISTS `unmovable_objects_server_id_ranges_lock` (
  `ID` tinyint(3) unsigned NOT NULL,
  `IsLocked` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Dummy table for locking from p_issueIdRange_unmovable_objects. Do not store actual data, using only for internal needs';

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
