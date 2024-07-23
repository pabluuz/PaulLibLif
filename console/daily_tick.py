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
from services.industry_processor import IndustryProcessor
from services.industry_validator import IndustryValidator
from services.logging import LoggerSingleton
import math


def daily_tick() -> None:
    logger = LoggerSingleton()
    logger = LoggerSingleton.get_logger()
    logger.info("Daily tick!")
    industry_processor = IndustryProcessor()

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
                            f"Adding {industry_data.Amount} {industry_data.ResultItemToAdd} to every {industry_data.ObjectTypeName} containing fuel ({industry_data.FuelConsumedQuantity} x {industry_data.Fuel}) defined in {industry_name}."
                        )
                    else:
                        logger.info(
                            f"Adding {industry_data.Amount} {industry_data.ResultItemToAdd} to every {industry_data.ObjectTypeName} defined in {industry_name}."
                        )
                    with FetchContainersByObjectTypeNameQuery() as fetch_containers_query:
                        fetch_containers_result = fetch_containers_query.execute(industry_data.ObjectTypeName)
                        for container in fetch_containers_result:
                            industry_processor.processContainer(
                                container, industry_data, add_item_command, industry_name
                            )
        else:
            logger.info("There hasn't been a day since the last check. Skipping.")
