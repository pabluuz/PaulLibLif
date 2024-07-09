from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models.base import Base
from services.configs import ConfigStorage
from services.logging import LoggerSingleton


class DBConnector:
    def __init__(self):
        self.logger = LoggerSingleton.get_logger()
        config = ConfigStorage()
        db_uri = config.get_element("DatabaseUri")
        if "xep624" in db_uri:
            self.logger.error(
                "You need to provide password to database in config/lib.yaml. I see that you still have example password in config/lib.yaml."
            )
        self.engine = create_engine(db_uri)
        self.Session = sessionmaker(bind=self.engine)

    def get_session(self):
        return self.Session()

    def check_if_can_connect(self):
        try:
            self.engine.connect()
        except Exception as e:
            self.logger.error(f"Error connecting to database: {e}")
            return False
        return True

    def create_all_tables(self):
        Base.metadata.create_all(self.engine)
