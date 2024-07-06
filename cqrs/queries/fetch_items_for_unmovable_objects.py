from typing import Optional
from cqrs.queries.base_query import BaseQuery
from cqrs.queries.fetch_unmovable_objects import FetchUnmovableObjectsQuery


class FetchItemsForUnmovableObjectsQuery(BaseQuery):
    def execute(self, identifier: Optional[int] = None, name: Optional[str] = None):
        with FetchUnmovableObjectsQuery() as fetch_query:
            unmovable_objects = fetch_query.execute(identifier, name)

        all_items = []
        for unmovable_object in unmovable_objects:
            items = unmovable_object.get_items(self.session)
            all_items.extend(items)
        return all_items
