"""
PaulLib
"""

from __future__ import annotations
from typing import Union
from sqlalchemy import (
    BigInteger,
    Column,
    Integer,
    Null,
    SmallInteger,
    TIMESTAMP,
    ForeignKey,
    String,
    Boolean,
    CHAR,
    BLOB,
    LargeBinary,
    null,
)
from sqlalchemy.orm import relationship, Mapped, aliased
from models.base import Base
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.sql import exists, or_


class ObjectType(Base):
    __tablename__ = "objects_types"

    id = Column("ID", Integer, primary_key=True)
    parent_id = Column("ParentID", Integer, ForeignKey("objects_types.ID"), nullable=True)
    name = Column("Name", String(45), nullable=False, default="")
    is_container = Column("IsContainer", Boolean, nullable=False, default=False)
    is_movable_object = Column("IsMovableObject", Boolean, nullable=False, default=False)
    is_unmovable_object = Column("IsUnmovableObject", Boolean, nullable=False, default=False)
    is_tool = Column("IsTool", Boolean, nullable=False, default=False)
    is_device = Column("IsDevice", Boolean, nullable=False, default=False)
    is_door = Column("IsDoor", Boolean, nullable=False, default=False)
    is_premium = Column("IsPremium", Boolean, nullable=False, default=False)
    max_cont_size = Column("MaxContSize", Integer, nullable=True, comment="3 digits after point (gramm)")
    length = Column("Length", SmallInteger, nullable=True)
    max_stack_size = Column(
        "MaxStackSize",
        Integer,
        nullable=True,
        comment="For unmovable objects stores max amount of bind slots for players",
    )
    unit_weight = Column("UnitWeight", Integer, nullable=True)


class Feature(Base):
    __tablename__ = "features"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    customtext_id = Column("CustomtextID", Integer, ForeignKey("custom_texts.ID"), nullable=True)
    created_region_id = Column(
        "CreatedRegionID",
        Integer,
        ForeignKey("regions.ID"),
        nullable=True,
        comment="Region of item's origin",
    )
    blueprint_id = Column(
        "BlueprintID",
        Integer,
        ForeignKey("blueprints.ID"),
        nullable=True,
        comment="ID of actual blueprint for blueprint items",
    )
    horse_hp = Column("HorseHP", Integer, nullable=True, comment="6 digits after point")
    horse_stamina = Column("HorseStamina", Integer, nullable=True, comment="6 digits after point")
    has_effects = Column("has_effects", Boolean, nullable=False, default=False)

    custom_text = relationship("CustomText")
    created_region = relationship("Region")
    blueprint = relationship("Blueprint")


class Container(Base):
    __tablename__ = "containers"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    parent_id = Column("ParentID", Integer, ForeignKey("containers.ID"), nullable=True)
    object_type_id = Column("ObjectTypeID", Integer, ForeignKey("objects_types.ID"), nullable=False)
    quality = Column("Quality", SmallInteger, nullable=False, default=0, comment="0-100")
    feature_id = Column("FeatureID", Integer, ForeignKey("features.ID"), nullable=True)

    parent = relationship("Container", remote_side=[id], backref="children")
    object_type: Mapped["ObjectType"] = relationship("ObjectType")
    feature = relationship("Feature")

    _movable_object = relationship("MovableObject", back_populates="root_container", uselist=False)
    _unmovable_object = relationship("UnmovableObject", back_populates="root_container", uselist=False)

    @hybrid_property
    def unmovable_or_movable_object(self) -> Union[MovableObject, UnmovableObject]:
        if self._movable_object:
            return self._movable_object
        elif self._unmovable_object:
            return self._unmovable_object
        else:
            raise ValueError("Container must have either a MovableObject or an UnmovableObject")


class CustomText(Base):
    __tablename__ = "custom_texts"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    text = Column("Text", String(4096), nullable=True)


class Region(Base):
    __tablename__ = "regions"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    region_type = Column("RegionType", String(255), nullable=False)
    x = Column("X", Integer, nullable=False)
    y = Column("Y", Integer, nullable=False)
    z = Column("Z", Integer, nullable=False)
    width = Column("Width", Integer, nullable=False)
    length = Column("Length", Integer, nullable=False)
    height = Column("Height", Integer, nullable=False)


class SkillType(Base):
    __tablename__ = "skill_types"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    description = Column("Description", String(255), nullable=True)
    icon = Column("Icon", String(255), nullable=True)
    parent_id = Column("ParentID", Integer, ForeignKey("skill_types.ID"), nullable=True)

    parent = relationship("SkillType", remote_side=[id], backref="children")


class Recipe(Base):
    __tablename__ = "recipes"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    skill_type_id = Column("SkillTypeID", Integer, ForeignKey("skill_types.ID"), nullable=False)

    skill_type = relationship("SkillType")


class Blueprint(Base):
    __tablename__ = "blueprints"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    recipe_id = Column("RecipeID", Integer, ForeignKey("recipes.ID"), nullable=False)

    recipe = relationship("Recipe")


class Item(Base):
    __tablename__ = "items"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    object_type_id = Column("ObjectTypeID", Integer, ForeignKey("objects_types.ID"), nullable=False)
    container_id = Column("ContainerID", Integer, ForeignKey("containers.ID"), nullable=True)
    quality = Column("Quality", SmallInteger, nullable=False, default=0)
    quantity = Column("Quantity", Integer, nullable=False, default=0)
    durability = Column("Durability", SmallInteger, nullable=False, default=0)
    created_durability = Column("CreatedDurability", SmallInteger, nullable=False, default=0)
    feature_id = Column("FeatureID", Integer, nullable=True, default=None)

    object_type = relationship("ObjectType")
    container = relationship("Container")


class UnmovableObject(Base):
    __tablename__ = "unmovable_objects"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    object_type_id = Column("ObjectTypeID", Integer, ForeignKey("objects_types.ID"), nullable=False)
    root_container_id = Column("RootContainerID", Integer, ForeignKey("containers.ID"), nullable=True)
    durability = Column(
        "Durability",
        SmallInteger,
        nullable=False,
        default=0,
        comment="2 digits after point Less then 10 = object is damaged",
    )
    created_durability = Column(
        "CreatedDurability",
        SmallInteger,
        nullable=False,
        default=0,
        comment="2 digits after point, also acts as MaxDurability",
    )
    is_complete = Column("IsComplete", Boolean, nullable=False)
    geo_data_id = Column("GeoDataID", Integer, nullable=False)
    owner_id = Column("OwnerID", Integer, ForeignKey("character.ID"), nullable=True)
    custom_name_id = Column("CustomNameID", Integer, ForeignKey("custom_texts.ID"), nullable=True)
    dropped_time = Column("DroppedTime", TIMESTAMP, nullable=False, default="0000-00-00 00:00:00")
    turn_angle = Column("TurnAngle", SmallInteger, nullable=False)

    object_type = relationship("ObjectType")
    root_container = relationship("Container", foreign_keys=[root_container_id])
    owner = relationship("Character", foreign_keys=[owner_id])
    custom_name = relationship("CustomText", foreign_keys=[custom_name_id])

    @hybrid_property
    def quality(self):
        return (self.durability / 20000) * 100


class MovableObject(Base):
    __tablename__ = "movable_objects"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    object_type_id = Column("ObjectTypeID", Integer, ForeignKey("objects_types.ID"), nullable=False)
    root_container_id = Column("RootContainerID", Integer, ForeignKey("containers.ID"), nullable=True)
    durability = Column(
        "Durability",
        SmallInteger,
        nullable=False,
        default=100,
        comment="Less then 10 - object is damaged",
    )
    created_durability = Column(
        "CreatedDurability",
        SmallInteger,
        nullable=False,
        default=0,
        comment="2 digits after point, also acts as MaxDurability",
    )
    is_complete = Column("IsComplete", Boolean, nullable=False)
    geo_data_id = Column("GeoDataID", Integer, nullable=False)
    owner_id = Column("OwnerID", Integer, ForeignKey("character.ID"), nullable=True)
    custom_name_id = Column("CustomNameID", Integer, ForeignKey("custom_texts.ID"), nullable=True)
    dropped_time = Column("DroppedTime", TIMESTAMP, nullable=False, default="0000-00-00 00:00:00")
    turn_angle = Column("TurnAngle", SmallInteger, nullable=False)
    offset_mm_x = Column("OffsetMmX", SmallInteger, nullable=False, comment="ingame millimeters")
    offset_mm_y = Column("OffsetMmY", SmallInteger, nullable=False, comment="ingame millimeters")
    offset_mm_z = Column("OffsetMmZ", Integer, nullable=False, comment="ingame millimeters")

    object_type = relationship("ObjectType")
    root_container = relationship("Container", foreign_keys=[root_container_id])
    owner = relationship("Character", foreign_keys=[owner_id])
    custom_name = relationship("CustomText", foreign_keys=[custom_name_id])

    @hybrid_property
    def quality(self):
        return (self.durability / 20000) * 100


class Character(Base):
    __tablename__ = "character"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    account_id = Column("AccountID", Integer, ForeignKey("accounts.ID"), nullable=False)
    region_id = Column("RegionID", Integer, ForeignKey("regions.ID"), nullable=True)
    guild_id = Column("GuildID", Integer, ForeignKey("guilds.ID"), nullable=True)
    guild_role_id = Column("GuildRoleID", Integer, ForeignKey("guild_roles.ID"), nullable=True)
    race_id = Column("RaceID", Integer, ForeignKey("races.ID"), nullable=False)
    name = Column("Name", String(255), nullable=False)
    level = Column("Level", Integer, nullable=False, default=1)
    experience = Column("Experience", Integer, nullable=False, default=0)

    account = relationship("Account")
    region = relationship("Region")
    guild = relationship("Guild")
    guild_role = relationship("GuildRole")
    race = relationship("Race")

    mounted_horses = relationship(
        "Horse",
        primaryjoin="Horse.mounted_character_id == Character.id",
        back_populates="mounted_character",
        foreign_keys="[Horse.mounted_character_id]",
    )
    owned_horses = relationship(
        "Horse",
        primaryjoin="Horse.owner_id == Character.id",
        back_populates="owner",
        foreign_keys="[Horse.owner_id]",
    )


class Account(Base):
    __tablename__ = "accounts"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    is_active = Column("IsActive", Boolean, nullable=False, default=True)
    is_gm = Column("IsGM", Boolean, nullable=False, default=False)
    steam_id = Column("SteamID", BigInteger, nullable=False, unique=True)


class Race(Base):
    __tablename__ = "races"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    description = Column("Description", String(255), nullable=True)


class Guild(Base):
    __tablename__ = "guilds"

    id = Column("ID", Integer, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)
    description = Column("Description", String(255), nullable=True)
    region_id = Column("RegionID", Integer, ForeignKey("regions.ID"), nullable=True)

    region = relationship("Region")


class GuildRole(Base):
    __tablename__ = "guild_roles"

    id = Column("ID", SmallInteger, primary_key=True, autoincrement=True)
    name = Column("Name", String(255), nullable=False)


class Horse(Base):
    __tablename__ = "horses"

    id = Column("ID", Integer, primary_key=True)
    object_type_id = Column("ObjectTypeID", Integer, ForeignKey("objects_types.ID"), nullable=False)
    quality = Column("Quality", SmallInteger, nullable=False, default=0)
    hp = Column("HP", Integer, nullable=False, default=1000000)
    geo_id = Column("GeoID", Integer, nullable=False)
    geo_alt = Column("GeoAlt", SmallInteger, nullable=False)
    offset_x = Column("OffsetX", SmallInteger, nullable=False)
    offset_y = Column("OffsetY", SmallInteger, nullable=False)
    offset_z = Column("OffsetZ", Integer, nullable=False)
    turn_angle = Column("TurnAngle", SmallInteger, nullable=False)
    mounted_character_id = Column("MountedCharacterID", Integer, ForeignKey("characters.ID"), nullable=True)
    owner_id = Column("OwnerID", Integer, ForeignKey("characters.ID"), nullable=True)
    dropped_time = Column("DroppedTime", TIMESTAMP, nullable=False, default="0000-00-00 00:00:00")
    durability = Column("Durability", SmallInteger, nullable=False, default=100)
    created_durability = Column("CreatedDurability", SmallInteger, nullable=False, default=100)

    mounted_character = relationship(
        "Character",
        primaryjoin="Horse.mounted_character_id == Character.id",
        foreign_keys=[mounted_character_id],
        back_populates="mounted_horses",
    )
    owner = relationship(
        "Character",
        primaryjoin="Horse.owner_id == Character.id",
        foreign_keys=[owner_id],
        back_populates="owned_horses",
    )
