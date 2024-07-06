from typing import Optional
from sqlalchemy.orm import joinedload
from models.game_data import UnmovableObject, ObjectType
from cqrs.queries.base_query import BaseQuery


class FetchUnmovableObjectsQuery(BaseQuery):
    def execute(self, identifier: Optional[int] = None, name: Optional[str] = None):
        query = self.session.query(UnmovableObject).options(joinedload(UnmovableObject.object_type))
        if identifier is not None:
            query = query.filter(UnmovableObject.id == identifier)
        elif name is not None:
            query = query.join(ObjectType).filter(ObjectType.name == name)
        return query.all()
