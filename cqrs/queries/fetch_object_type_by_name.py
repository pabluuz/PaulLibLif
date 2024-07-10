import sys
import sqlalchemy
from models.game_data import ObjectType
from cqrs.queries.base_query import BaseQuery
from services.logging import LoggerSingleton


class FetchObjectTypeByNameQuery(BaseQuery):
    def execute(self, object_type_name: str) -> ObjectType | None:
        query = self.session.query(ObjectType).filter(ObjectType.name == object_type_name)
        try:
            return query.one_or_none()
        except sqlalchemy.exc.MultipleResultsFound:
            LoggerSingleton.get_logger().error(f"Multiple object types found with name '{object_type_name}'.")
            sys.exit()
