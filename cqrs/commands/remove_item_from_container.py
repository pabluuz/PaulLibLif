# cqrs/commands/remove_fuel_from_container.py
from typing import List, Optional
from cqrs.commands.base_command import BaseCommand
from models.game_data import Item


def remove_fuel_from_container(
    container, fuel_object_type_name, required_quantity, fuel_items: List[Item]
) -> Optional[float]:
    with RemoveFuelFromContainerCommand(container, fuel_object_type_name, required_quantity, fuel_items) as command:
        return command.run()


class RemoveFuelFromContainerCommand(BaseCommand):
    def __init__(self, container, fuel_object_type_name, required_quantity, fuel_items):
        super().__init__()
        self.container = container
        self.fuel_object_type_name = fuel_object_type_name
        self.required_quantity = required_quantity
        self.fuel_items = fuel_items

    def run(self) -> Optional[float]:
        try:
            remaining_quantity = self.required_quantity
            total_quality = 0
            consumed_items = []

            for item in self.fuel_items:
                if remaining_quantity >= item.quantity:
                    total_quality += item.quality * item.quantity
                    remaining_quantity -= item.quantity
                    consumed_items.append(item)
                else:
                    total_quality += item.quality * remaining_quantity
                    item.quantity -= remaining_quantity
                    remaining_quantity = 0
                    break

            for item in consumed_items:
                self.session.delete(item)

            avg_quality = total_quality / self.required_quantity if self.required_quantity > 0 else 0
            self.logger.info(
                f"Removed {self.required_quantity} fuel from container {self.container.id}. Average quality: {avg_quality}"
            )
            return avg_quality

        except Exception as e:
            self.logger.error(f"Error removing fuel from container: {e}")
            return None
