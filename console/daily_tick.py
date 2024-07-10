# console/daily_tick.py
import sys
from typing import Dict
from cqrs.commands.add_item_to_container import AddItemToContainerCommand
from cqrs.commands.remove_item_from_container import RemoveItemFromContainerCommand
from cqrs.commands.save_today import SaveTodayCommand
from cqrs.queries.fetch_items_by_object_type_and_container import FetchItemsByObjectTypeAndContainerQuery
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from models.production_object import ProductionObject
from cqrs.queries.check_if_next_day import CheckIfNextDayQuery
from cqrs.queries.fetch_containers_by_object_type_name import FetchContainersByObjectTypeNameQuery
from services.configs import ConfigStorage, YAMLIndustriesProcessor
from services.industry_validator import IndustryValidator
from services.logging import LoggerSingleton
import math


def daily_tick() -> None:
    logger = LoggerSingleton()
    logger = LoggerSingleton.get_logger()
    logger.info("Daily tick!")

    processor = YAMLIndustriesProcessor()
    if processor.data is None:
        logger.error("Failed to load config/industries.yaml from YAML. Exiting.")
        return

    industries: Dict[str, ProductionObject] = processor.get_objects()

    # Validate industries
    validator = IndustryValidator()
    if validator.check_fuel_valid(industries) is False:
        sys.exit()

    config = ConfigStorage()
    with CheckIfNextDayQuery() as next_day_query:
        next_day_query_result = next_day_query.execute()
        if next_day_query_result or config.get_element("DebugIgnoreDayWait"):
            with SaveTodayCommand() as save_today_command:
                save_today_command.execute()
                logger.info("Saved today's date, so we won't repeat this tick today.")

            for industry_name, industry_data in industries.items():
                industry_data: ProductionObject
                with AddItemToContainerCommand() as add_item_command:
                    if industry_data.FuelRequired:
                        logger.info(
                            f"Adding {industry_data.Amount} {industry_data.ItemToAdd} to every {industry_data.ObjectTypeName} containing fuel ({industry_data.FuelConsumedQuantity} x {industry_data.Fuel}) defined in {industry_name}."
                        )
                    else:
                        logger.info(
                            f"Adding {industry_data.Amount} {industry_data.ItemToAdd} to every {industry_data.ObjectTypeName} defined in {industry_name}."
                        )
                    with FetchContainersByObjectTypeNameQuery() as fetch_containers_query:
                        fetch_containers_result = fetch_containers_query.execute(industry_data.ObjectTypeName)
                        for container in fetch_containers_result:
                            # Check for fuel
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
                                            # logger.info(
                                            #     f"Removing {industry_data.FuelConsumedQuantity} {industry_data.Fuel} from {container.object_type.name} ({container.id}). {industry_data.Fuel} left: {total_fuel_quantity - industry_data.FuelConsumedQuantity} eta {(total_fuel_quantity - industry_data.FuelConsumedQuantity) / industry_data.FuelConsumedQuantity} days."
                                            # )
                                            avg_quality = remove_fuel_from_container.run(
                                                container,
                                                fuel_object_type.name,
                                                industry_data.FuelConsumedQuantity,
                                                fuel_items,
                                            )
                                            if avg_quality is not None:
                                                result_quality = result_quality + (
                                                    avg_quality * industry_data.FuelBonusQuality
                                                )
                                                if result_quality > 100:
                                                    result_quality = 100
                                    else:
                                        enough_fuel = False
                                    if enough_fuel is True:
                                        logger.info(
                                            f"Removing {industry_data.FuelConsumedQuantity} {industry_data.Fuel} from {container.object_type.name} ({container.id}). {industry_data.Fuel} left: {total_fuel_quantity - industry_data.FuelConsumedQuantity} eta {math.floor((total_fuel_quantity - industry_data.FuelConsumedQuantity) / industry_data.FuelConsumedQuantity)} days."
                                        )
                                        add_item_command.run(
                                            container=container,
                                            item_object_type_name=industry_data.ItemToAdd,
                                            quantity=industry_data.Amount + industry_data.FuelBonusQuantity,
                                            quality=result_quality,
                                        )
                                    elif industry_data.FuelRequired is False and enough_fuel is False:
                                        logger.info(
                                            f"Not enough fuel in container {container.id}. Required: {industry_data.FuelConsumedQuantity}, Available: {total_fuel_quantity}"
                                        )
                                        add_item_command.run(
                                            container=container,
                                            item_object_type_name=industry_data.ItemToAdd,
                                            quantity=industry_data.Amount,
                                            quality=container.unmovable_or_movable_object.quality,
                                        )
                            else:
                                logger.info(f"No fuel specified for {industry_name}.")
                                add_item_command.run(
                                    container=container,
                                    item_object_type_name=industry_data.ItemToAdd,
                                    quantity=industry_data.Amount,
                                    quality=container.unmovable_or_movable_object.quality,
                                )
        else:
            logger.info("There hasn't been a day since the last check. Skipping.")
