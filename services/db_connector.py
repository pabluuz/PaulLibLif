from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models.base import Base

from services.configs import ConfigStorage


class DBConnector:
    def __init__(self):
        config = ConfigStorage()
        self.engine = create_engine(config.get_element("DatabaseUri"))
        self.Session = sessionmaker(bind=self.engine)

    def get_session(self):
        return self.Session()

    def create_all_tables(self):
        Base.metadata.create_all(self.engine)
