from services.db_connector import DBConnector
from services.logging import LoggerSingleton


class BaseCommand:
    def __init__(self):
        self.dbConnector = DBConnector()
        self.logger = LoggerSingleton.get_logger()

    def __enter__(self):
        self.session = self.dbConnector.get_session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            self.session.rollback()
        else:
            self.session.commit()
        self.session.close()
