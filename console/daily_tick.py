# console/daily_tick.py
from typing import Dict
from cqrs.commands.add_item_to_container import AddItemToContainerCommand
from cqrs.commands.save_today import SaveTodayCommand
from cqrs.queries.fetch_items_by_object_type_and_container import FetchItemsByObjectTypeAndContainerQuery
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from models.production_object import ProductionObject
from cqrs.queries.check_if_next_day import CheckIfNextDayQuery
from cqrs.queries.fetch_containers_by_object_type_name import FetchContainersByObjectTypeNameQuery
from services.configs import ConfigStorage, YAMLIndustriesProcessor
from services.logging import LoggerSingleton


def daily_tick(logger: LoggerSingleton) -> None:
    logger = LoggerSingleton.get_logger()
    logger.info("Daily tick!")

    processor = YAMLIndustriesProcessor()
    processor.load_yaml()
    if processor.data is None:
        logger.error("Failed to load config/industries.yaml from YAML. Exiting.")
        return

    industries: Dict[str, ProductionObject] = processor.get_objects()

    config = ConfigStorage()
    with CheckIfNextDayQuery() as next_day_query:
        next_day_query_result = next_day_query.execute()
        if next_day_query_result or config.get_element("DebugIgnoreDayWait"):
            with SaveTodayCommand() as save_today_command:
                save_today_command.execute()

            # Check if container has fuel item

            # Remove fuel item

            for industry_name, industry_data in industries.items():
                with AddItemToContainerCommand() as add_item_command:
                    logger.info(
                        f"Adding {industry_data.Amount} {industry_data.ItemToAdd} to every {industry_data.ObjectTypeName}."
                    )
                    with FetchContainersByObjectTypeNameQuery() as fetch_containers_query:
                        fetch_containers_result = fetch_containers_query.execute(industry_data.ObjectTypeName)
                        for container in fetch_containers_result:
                            # Check for fuel
                            if industry_data.Fuel is not None:
                                with FetchObjectTypeByNameQuery() as get_fuel_object_type_query:
                                    get_fuel_object_type_result = get_fuel_object_type_query.execute(industry_data.Fuel)
                                if get_fuel_object_type_result is not None:
                                    with FetchItemsByObjectTypeAndContainerQuery() as fetch_fuel_query:
                                        fetch_fuel_result = fetch_fuel_query.execute(
                                            container_id=container.id,
                                            object_type_id=industry_data.Fuel,
                                        )
                            add_item_command.run(
                                container=container,
                                item_object_type_name=industry_data.ItemToAdd,
                                quantity=industry_data.Amount,
                            )
                    # Add additional logic to handle fuel, fuel_required, fuel_bonus_quality, and fuel_bonus_quantity
        else:
            logger.info("There hasn't been a day since the last check. Skipping.")
