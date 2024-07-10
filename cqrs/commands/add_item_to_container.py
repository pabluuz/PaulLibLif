from cqrs.commands.base_command import BaseCommand
from models.game_data import Item, Container, MovableObject, ObjectType, UnmovableObject


class AddItemToContainerCommand(BaseCommand):

    def run(
        self,
        container: Container,
        item_object_type_name,
        quantity,
        quality,
        durability=0,
        created_durability=0,
        feature_id=None,
    ):
        try:
            # Get the object by its object type name
            object_type = self.session.query(ObjectType).filter(ObjectType.name == item_object_type_name).first()
            if not object_type:
                self.logger.warning(f"Item with object type name '{item_object_type_name}' not found.")
                return

            # Get the item's unit weight
            item_unit_weight = object_type.unit_weight

            # Calculate the total weight of the items being added
            total_weight_to_add = item_unit_weight * quantity

            # Get the container's maximum size
            container_object_type = container.object_type
            max_cont_size = container_object_type.max_cont_size

            # Calculate the total weight of the existing items in the container
            existing_items = self.session.query(Item).filter(Item.container_id == container.id).all()
            total_existing_weight = sum(item.object_type.unit_weight * item.quantity for item in existing_items)

            # Calculate the total weight after adding the new items
            total_weight = total_existing_weight + total_weight_to_add

            # Check if the container has enough space for the items
            if total_weight <= max_cont_size:
                # Find the unmovable object or movable object associated with the container
                unmovable_object = (
                    self.session.query(UnmovableObject)
                    .filter(UnmovableObject.root_container_id == container.id)
                    .filter(UnmovableObject.is_complete == 1)
                    .first()
                )
                movable_object = (
                    self.session.query(MovableObject)
                    .filter(MovableObject.root_container_id == container.id)
                    .filter(MovableObject.is_complete == 1)
                    .first()
                )

                new_item = Item(
                    container_id=container.id,
                    object_type=object_type,
                    quality=quality,
                    quantity=quantity,
                    durability=durability,
                    created_durability=created_durability,
                    feature_id=feature_id,
                )

                self.session.add(new_item)

                self.logger.info(
                    f"{object_type.name} x {quantity} (q{quality}) added to container with object type name '{container.object_type.name}' and ID '{container.id}'"
                )
            else:
                self.logger.warning(
                    f"Container with object type name '{container.object_type.name}' and ID '{container.id}' does not have enough space for {quantity} items of type '{item_object_type_name}'."
                )

        except Exception as e:
            self.logger.error(f"Error adding item to container: {e}")
