from sqlalchemy.orm import joinedload
from models.game_data import Container, ObjectType
from cqrs.queries.base_query import BaseQuery


class FetchContainersByObjectTypeNameQuery(BaseQuery):
    def execute(self, object_type_name: str) -> list[Container]:
        query = (
            self.session.query(Container)
            .join(ObjectType)
            .filter(ObjectType.name == object_type_name)
            .options(joinedload(Container.object_type))
        )

        return query.all()
