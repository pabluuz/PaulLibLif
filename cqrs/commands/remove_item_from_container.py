from typing import List, Optional
from cqrs.commands.base_command import BaseCommand
from models.game_data import Container, Item


class RemoveItemFromContainerCommand(BaseCommand):

    def run(
        self, container: Container, item_object_type_name: str, required_quantity: int, items: list[Item]
    ) -> Optional[float]:
        try:
            remaining_quantity = required_quantity
            total_quality = 0
            fully_consumed_items = []
            partially_consumed_items = []

            for item in items:
                if remaining_quantity >= item.quantity:
                    self.logger.info(
                        f"Removing {item.quantity} {item_object_type_name} from {container.id} of q {item.quality}."
                    )
                    total_quality += item.quality * item.quantity
                    remaining_quantity -= item.quantity
                    fully_consumed_items.append(item)
                else:
                    self.logger.info(
                        f"Removing {remaining_quantity} {item_object_type_name} from {container.id} of q {item.quality}."
                    )
                    total_quality += item.quality * remaining_quantity
                    item.quantity -= remaining_quantity
                    partially_consumed_items.append(item)
                    remaining_quantity = 0
                    break

            for item in fully_consumed_items:
                self.session.delete(item)

            for item in partially_consumed_items:
                self.session.add(item)

            avg_quality = total_quality / required_quantity if required_quantity > 0 else 0
            return avg_quality

        except Exception as e:
            self.logger.error(f"Error removing item from container: {e}")
            return None
