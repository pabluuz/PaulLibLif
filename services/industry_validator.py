from typing import Dict
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from models.production_object import ProductionObject
from services.configs import YAMLIndustriesProcessor
from services.db_connector import DBConnector


class IndustryValidator:
    def __init__(self):
        self.db_connector = DBConnector()
        self.session = self.db_connector.get_session()
        self.yaml_processor = YAMLIndustriesProcessor()
        self.industries: Dict[str, ProductionObject] = self.yaml_processor.get_objects()

    def check_fuel_required(self):
        errors = []

        for industry_name, industry_data in self.industries.items():
            if industry_data.FuelRequired:
                if industry_data.Fuel == "False" or industry_data.Fuel == "" or industry_data.Fuel is None:
                    errors.append(f"Error in '{industry_name}': Fuel is required but it's name is not provided.")
            elif industry_data.Fuel != "False" and industry_data.Fuel != "" and industry_data.Fuel is not None:
                fuel_name = industry_data.Fuel
                with FetchObjectTypeByNameQuery() as query:
                    if query.execute(fuel_name) is None:
                        errors.append(
                            f"Error in '{industry_name}': Fuel '{fuel_name}' does not exist as an ObjectType."
                        )

        return errors
