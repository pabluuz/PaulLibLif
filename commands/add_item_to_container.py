from commands.base_command import BaseCommand
from models.game_data import Item, Container, ObjectType


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

            # Set the quality of the new item to the container's quality
            quality = container.quality

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
