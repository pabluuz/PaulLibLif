import unittest
from unittest.mock import MagicMock, patch
from datetime import date, timedelta
from cqrs.queries.check_if_next_day import CheckIfNextDayQuery
from models.lib_data import PaulLibData


class TestCheckIfNextDay(unittest.TestCase):

    def setUp(self):
        self.query = CheckIfNextDayQuery()
        self.query.session = MagicMock()

    def test_execute_when_last_checked_entry_exists(self):
        yesterday = date.today() - timedelta(days=1)
        mock_entry = MagicMock(spec=PaulLibData)
        mock_entry.get_value.return_value = yesterday.isoformat()
        self.query.session.query.return_value.filter_by.return_value.first.return_value = mock_entry

        result = self.query.execute()

        self.assertTrue(result)

    def test_execute_when_last_checked_entry_does_not_exist(self):
        self.query.session.query.return_value.filter_by.return_value.first.return_value = None

        result = self.query.execute()

        self.assertTrue(result)

    def test_execute_when_last_checked_date_is_not_string(self):
        yesterday = date.today() - timedelta(days=1)
        mock_entry = MagicMock(spec=PaulLibData)
        mock_entry.get_value.return_value = yesterday
        self.query.session.query.return_value.filter_by.return_value.first.return_value = mock_entry

        result = self.query.execute()

        self.assertTrue(result)

    def test_execute_when_last_checked_date_is_today(self):
        today = date.today()
        mock_entry = MagicMock(spec=PaulLibData)
        mock_entry.get_value.return_value = today.isoformat()
        self.query.session.query.return_value.filter_by.return_value.first.return_value = mock_entry

        result = self.query.execute()

        self.assertFalse(result)
