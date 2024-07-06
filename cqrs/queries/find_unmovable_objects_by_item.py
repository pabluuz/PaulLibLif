from typing import Optional
from sqlalchemy.orm import joinedload
from models.game_data import UnmovableObject, ObjectType, Item, Container
from cqrs.queries.base_query import BaseQuery


class FindUnmovableObjectsByItemQuery(BaseQuery):
    def execute(
        self,
        item_object_type_id: Optional[int] = None,
        item_name: Optional[str] = None,
        object_type_id: Optional[int] = None,
        unmovable_object_name: Optional[str] = None,
    ):
        query = (
            self.session.query(UnmovableObject)
            .join(Container, UnmovableObject.root_container_id == Container.id)
            .join(Item, Container.id == Item.container_id)
        )

        if item_object_type_id is not None:
            query = query.filter(Item.object_type_id == item_object_type_id)
        elif item_name is not None:
            query = query.join(ObjectType, Item.object_type_id == ObjectType.id).filter(
                ObjectType.name == item_name
            )

        if object_type_id is not None:
            query = query.filter(UnmovableObject.object_type_id == object_type_id)
        elif unmovable_object_name is not None:
            query = query.join(ObjectType).filter(ObjectType.name == unmovable_object_name)

        return query.options(joinedload(UnmovableObject.object_type)).all()
