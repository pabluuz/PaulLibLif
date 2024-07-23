from typing import Union
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from models.game_data import Container, Item
from models.production_object import ProductionObject
from services.db_connector import DBConnector
from services.logging import LoggerSingleton
from cqrs.commands.add_item_to_container import AddItemToContainerCommand
from cqrs.commands.remove_item_from_container import RemoveItemFromContainerCommand
from cqrs.queries.fetch_items_by_object_type_and_container import FetchItemsByObjectTypeAndContainerQuery
import math


class IndustryProcessor:
    def __init__(self):
        self.logger = LoggerSingleton.get_logger()
        self.db_connector = DBConnector()
        self.session = self.db_connector.get_session()

    def processContainer(
        self,
        container: Container,
        industry_data: ProductionObject,
        add_item_command: AddItemToContainerCommand,
        industry_name: str,
    ):
        # Do x times
        for _ in range(industry_data.RepeatMax):
            # Check for fuel
            if industry_data.ItemRequired is False:

            if industry_data.Fuel is not None:
                with FetchObjectTypeByNameQuery() as get_fuel_object_type_query:
                    fuel_object_type = get_fuel_object_type_query.execute(industry_data.Fuel)
                with FetchItemsByObjectTypeAndContainerQuery() as fetch_fuel_query:
                    fuel_items = fetch_fuel_query.execute(
                        container_id=container.id,
                        object_type_id=fuel_object_type.id,
                    )
                if fuel_items:
                    enough_fuel = True
                    result_quality = container.unmovable_or_movable_object.quality
                    total_fuel_quantity = sum(item.quantity for item in fuel_items)
                    if total_fuel_quantity >= industry_data.FuelConsumedQuantity:
                        with RemoveItemFromContainerCommand() as remove_fuel_from_container:
                            avg_quality = remove_fuel_from_container.run(
                                container,
                                fuel_object_type.name,
                                industry_data.FuelConsumedQuantity,
                                fuel_items,
                            )
                            if avg_quality is not None:
                                result_quality = result_quality + (avg_quality * industry_data.FuelBonusQuality)
                                if result_quality > 100:
                                    result_quality = 100
                    else:
                        enough_fuel = False
                    if enough_fuel is True:
                        self.logger.info(
                            f"Removing {industry_data.FuelConsumedQuantity} {industry_data.Fuel} from {container.object_type.name} ({container.id}). {industry_data.Fuel} left: {total_fuel_quantity - industry_data.FuelConsumedQuantity} eta {math.floor((total_fuel_quantity - industry_data.FuelConsumedQuantity) / industry_data.FuelConsumedQuantity)} days."
                        )
                        add_item_command.run(
                            container=container,
                            item_object_type_name=industry_data.ResultItemToAdd,
                            quantity=industry_data.Amount + industry_data.FuelBonusQuantity,
                            quality=result_quality,
                        )
                    elif industry_data.FuelRequired is False and enough_fuel is False:
                        self.logger.info(
                            f"Not enough fuel in container {container.id}. Required: {industry_data.FuelConsumedQuantity}, Available: {total_fuel_quantity}"
                        )
                        add_item_command.run(
                            container=container,
                            item_object_type_name=industry_data.ResultItemToAdd,
                            quantity=industry_data.Amount,
                            quality=container.unmovable_or_movable_object.quality,
                        )
            else:
                self.logger.info(f"No fuel specified for {industry_name}.")
                add_item_command.run(
                    container=container,
                    item_object_type_name=industry_data.ResultItemToAdd,
                    quantity=industry_data.Amount,
                    quality=container.unmovable_or_movable_object.quality,
                )

def get_fuel_quality(fuel_items: list[Item], industry_data: ProductionObject, container: Container)->Union[int, False]:
    with FetchObjectTypeByNameQuery() as get_fuel_object_type_query:
        fuel_object_type = get_fuel_object_type_query.execute(industry_data.Fuel)
    with FetchItemsByObjectTypeAndContainerQuery() as fetch_fuel_query:
        fuel_items = fetch_fuel_query.execute(
            container_id=container.id,
            object_type_id=fuel_object_type.id,
        )
    if fuel_items:
        result_quality = container.unmovable_or_movable_object.quality
        total_fuel_quantity = sum(item.quantity for item in fuel_items)
        if total_fuel_quantity >= industry_data.FuelConsumedQuantity:
            with RemoveItemFromContainerCommand() as remove_fuel_from_container:
                avg_quality = remove_fuel_from_container.run(
                    container,
                    fuel_object_type.name,
                    industry_data.FuelConsumedQuantity,
                    fuel_items,
                )
                if avg_quality is not None:
                    result_quality = result_quality + (avg_quality * industry_data.FuelBonusQuality)
                    if result_quality > 100:
                        result_quality = 100
        else:
            return False
    return False