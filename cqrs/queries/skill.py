from models.game_data import SkillType
from cqrs.queries.base_query import BaseQuery


class FindSkillByName(BaseQuery):
    def execute(self, skill_name: str) -> SkillType | None:
        query = self.session.query(SkillType).filter(SkillType.name == skill_name)
        return query.first()
