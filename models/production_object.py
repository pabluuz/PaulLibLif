from typing import Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class ProductionObject:
    ObjectTypeName: str = ""
    ResultItemToAdd: str = ""
    Amount: int = 0
    Fuel: Optional[str] = None
    FuelRequired: bool = False
    FuelBonusQuality: int = 0
    FuelBonusQuantity: int = 0
    FuelConsumedQuantity: int = 1
    RepeatMax: int = 1
    QualityMultiplier: int = 1
    ItemRequired: bool = False
    ItemToConsume: Optional[str] = None
    ItemAmountToConsume: int = 1
    ItemQualityPercentage: int = 0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]):
        return cls(
            ObjectTypeName=data.get("ObjectTypeName", ""),
            ResultItemToAdd=data.get("ResultItemToAdd", ""),
            Amount=data.get("Amount", 0),
            Fuel=data.get("Fuel", ""),
            FuelRequired=data.get("FuelRequired", False),
            FuelBonusQuality=data.get("FuelBonusQuality", 0),
            FuelBonusQuantity=data.get("FuelBonusQuantity", 0),
            FuelConsumedQuantity=data.get("FuelConsumedQuantity", 0),
            RepeatMax=data.get("RepeatMax", 1),
            QualityMultiplier=data.get("QualityMultiplier", 1),
            ItemRequired=data.get("ItemRequired", False),
            ItemToConsume=data.get("ItemToConsume", ""),
            ItemAmountToConsume=data.get("ItemAmountToConsume", 1),
            ItemQualityPercentage=data.get("ItemQualityPercentage", 0),
        )
