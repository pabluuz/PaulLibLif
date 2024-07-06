from commands.base_command import BaseCommand
from models.game_data import Item, Container, MovableObject, ObjectType, UnmovableObject


class AddItemToContainerCommand(BaseCommand):

    def run(
        self,
        container_object_type_name,
        item_object_type_name,
        quantity,
        durability=0,
        created_durability=0,
        feature_id=None,
    ):
        try:
            # Get the container object by its object type name
            container = (
                self.session.query(Container)
                .join(ObjectType)
                .filter(ObjectType.name == container_object_type_name)
                .first()
            )
            if not container:
                self.logger.warning(
                    f"Container with object type name '{container_object_type_name}' not found."
                )
                return

            # Get the container's maximum size
            container_object_type = container.object_type
            max_cont_size = container_object_type.max_cont_size

            # Get the object by its object type name
            object_type = (
                self.session.query(ObjectType)
                .filter(ObjectType.name == item_object_type_name)
                .first()
            )
            if not object_type:
                self.logger.warning(
                    f"Item with object type name '{item_object_type_name}' not found."
                )
                return

            # Get the item's unit weight
            item_unit_weight = object_type.unit_weight

            # Calculate the total weight of the items being added
            total_weight_to_add = item_unit_weight * quantity

            # Calculate the total weight of the existing items in the container
            existing_items = (
                self.session.query(Item).filter(Item.container_id == container.id).all()
            )
            total_existing_weight = sum(
                item.object_type.unit_weight * item.quantity for item in existing_items
            )

            # Calculate the total weight after adding the new items
            total_weight = total_existing_weight + total_weight_to_add

            # Check if the container has enough space for the items
            if total_weight > max_cont_size:
                self.logger.warning(
                    f"Container with object type name '{container_object_type_name}' does not have enough space for {quantity} items of type '{item_object_type_name}'."
                )
                return

            # Find container in objects
            unmovable_object = (
                self.session.query(UnmovableObject)
                .filter(UnmovableObject.root_container_id == container.id)
                .first()
            )
            movable_object = (
                self.session.query(MovableObject)
                .filter(MovableObject.root_container_id == container.id)
                .first()
            )

            # Calculate the quality based on durability
            if unmovable_object:
                quality = int((unmovable_object.durability / 20000) * 100)
            elif movable_object:
                quality = int((movable_object.durability / 20000) * 100)
            else:
                self.logger.error(
                    f"Container with ID = '{container.id}' not found in neither unmovable object nor movable object."
                )
                return

            new_item = Item(
                container=container,
                object_type=object_type,
                quality=quality,
                quantity=quantity,
                durability=durability,
                created_durability=created_durability,
                feature_id=feature_id,
            )

            self.session.add(new_item)

            self.logger.info(
                f"Item added to container with object type name '{container_object_type_name}'"
            )
        except Exception as e:
            self.logger.error(f"Error adding item to container: {e}")
