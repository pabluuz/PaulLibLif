from typing import Dict
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from models.production_object import ProductionObject
from services.db_connector import DBConnector
from services.logging import LoggerSingleton


class IndustryValidator:
    def __init__(self):
        self.logger = LoggerSingleton.get_logger()
        self.db_connector = DBConnector()
        self.session = self.db_connector.get_session()

    def check_fuel_valid(self, industries: Dict[str, ProductionObject]) -> bool:
        for industry_name, industry_data in industries.items():
            if industry_data.FuelRequired:
                if industry_data.Fuel is False or industry_data.Fuel == "" or industry_data.Fuel is None:
                    self.logger.error(f"Error in '{industry_name}': Fuel is required but it's name is not provided.")
                    return False
            elif industry_data.Fuel is not False and industry_data.Fuel != "" and industry_data.Fuel is not None:
                fuel_name = industry_data.Fuel
                with FetchObjectTypeByNameQuery() as query:
                    if query.execute(fuel_name) is None:
                        self.logger.error(
                            f"Error in '{industry_name}': Fuel '{fuel_name}' does not exist as an ObjectType."
                        )
                        return False

        return True
