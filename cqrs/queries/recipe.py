from models.game_data import Recipe
from cqrs.queries.base_query import BaseQuery


class FindRecipeByName(BaseQuery):
    def execute(self, recipe_name: str) -> Recipe | None:
        query = self.session.query(Recipe).filter(Recipe.name == recipe_name)
        return query.first()
