from models.game_data import ObjectType
from cqrs.queries.base_query import BaseQuery


class FetchObjectTypeByNameQuery(BaseQuery):
    def execute(self, object_type_name: str) -> ObjectType | None:
        query = self.session.query(ObjectType).filter(ObjectType.name == object_type_name)
        return query.one_or_none()
