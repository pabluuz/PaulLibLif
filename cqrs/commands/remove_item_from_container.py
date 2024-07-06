from cqrs.commands.base_command import BaseCommand
from models.game_data import Item, Container, MovableObject, ObjectType, UnmovableObject


class RemoveItemFromContainerCommand(BaseCommand):

    def run(
        self,
        containerId,
        itemName,
        quantity,
    ):
        try:
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

            # Get all containers with the given object type name
            containers = (
                self.session.query(Container)
                .join(ObjectType)
                .filter(ObjectType.name == container_object_type_name)
                .all()
            )

            for container in containers:
                # Get the container's maximum size
                container_object_type = container.object_type
                max_cont_size = container_object_type.max_cont_size

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

                    # Calculate the quality based on durability
                    if unmovable_object:
                        quality = int(
                            (
                                unmovable_object.durability
                                / unmovable_object.object_type.max_cont_size
                            )
                            * 100
                        )
                    elif movable_object:
                        quality = int(
                            (movable_object.durability / movable_object.object_type.max_cont_size)
                            * 100
                        )
                    else:
                        if container_object_type_name == "Monument":
                            self.logger.debug(
                                f"Container with ID = '{container.id}' not found in neither unmovable object nor movable object. It's normal, because monuments get orphaned container row when they expire. Ignore it."
                            )
                        else:
                            self.logger.warning(
                                f"Container with ID = '{container.id}' not found in neither unmovable object nor movable object. Is it orphaned? Check the database."
                            )
                        continue

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
                        f"Item added to container with object type name '{container_object_type_name}' and ID '{container.id}'"
                    )
                else:
                    self.logger.warning(
                        f"Container with object type name '{container_object_type_name}' and ID '{container.id}' does not have enough space for {quantity} items of type '{item_object_type_name}'."
                    )

        except Exception as e:
            self.logger.error(f"Error adding item to container: {e}")
