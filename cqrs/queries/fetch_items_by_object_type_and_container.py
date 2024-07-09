from models.game_data import Item
from cqrs.queries.base_query import BaseQuery


class FetchItemsByObjectTypeAndContainerQuery(BaseQuery):
    def execute(self, object_type_id: int, container_id: int) -> list[Item]:
        query = self.session.query(Item).filter(
            Item.object_type_id == object_type_id, Item.container_id == container_id
        )
        return query.all()
