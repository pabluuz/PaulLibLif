from sqlalchemy import Column, Integer, String
import datetime
from models.base import Base


# Define the model
class PaulLibData(Base):
    __tablename__ = "paul_lib_data"
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    type = Column(String(50), nullable=False)
    value = Column(String(255), nullable=False)

    def __repr__(self):
        return f"<PaulLibData(name={self.name}, type={self.type}, value={self.value})>"

    def get_value(self):
        if self.type == "int":
            return int(self.value)
        elif self.type == "float":
            return float(self.value)
        elif self.type == "datetime":
            return datetime.datetime.fromisoformat(self.value)
        elif self.type == "date":
            return datetime.date.fromisoformat(self.value)
        else:
            return self.value
