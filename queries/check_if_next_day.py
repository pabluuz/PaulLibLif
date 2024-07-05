import datetime
from models.lib_data import PaulLibData
from queries.base_query import BaseQuery


class CheckIfNextDayQuery(BaseQuery):
    def execute(self) -> bool:
        last_checked_entry = self.session.query(PaulLibData).filter_by(name="LastChecked").first()
        if last_checked_entry:
            last_checked_date = last_checked_entry.get_value()
            if not isinstance(last_checked_date, datetime.date):
                last_checked_date = datetime.date.fromisoformat(last_checked_date)
            return (datetime.date.today() - last_checked_date).days >= 1
        return True
