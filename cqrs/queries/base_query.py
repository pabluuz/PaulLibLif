from services.db_connector import DBConnector


class BaseQuery:
    def __init__(self):
        self.dbConnector = DBConnector()

    def __enter__(self):
        self.session = self.dbConnector.get_session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.session.close()
