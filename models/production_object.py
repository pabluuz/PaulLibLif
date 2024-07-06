from typing import Dict, Any
from dataclasses import dataclass


@dataclass
class ProductionObject:
    ObjectTypeName: str = ""
    ItemToAdd: str = ""
    Amount: int = 0
    Fuel: str = ""
    FuelRequired: bool = False
    FuelBonusQuality: int = 0
    FuelBonusQuantity: int = 0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]):
        return cls(
            ObjectTypeName=data.get("ObjectTypeName", ""),
            ItemToAdd=data.get("ItemToAdd", ""),
            Amount=data.get("Amount", 0),
            Fuel=data.get("Fuel", ""),
            FuelRequired=data.get("FuelRequired", False),
            FuelBonusQuality=data.get("FuelBonusQuality", 0),
            FuelBonusQuantity=data.get("FuelBonusQuantity", 0),
        )
