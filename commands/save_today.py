import datetime
from models.lib_data import PaulLibData
from commands.base_command import BaseCommand


class SaveTodayCommand(BaseCommand):
    def execute(self):
        last_checked_entry = self.session.query(PaulLibData).filter_by(name="LastChecked").first()
        if last_checked_entry:
            last_checked_entry.value = datetime.datetime.now().date().isoformat()
        else:
            new_entry = PaulLibData(
                name="LastChecked",
                type="date",
                value=datetime.date.today().isoformat(),
            )
            self.session.add(new_entry)
