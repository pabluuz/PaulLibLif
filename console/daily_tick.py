# console/daily_tick.py
from typing import Dict
from cqrs.commands.add_item_to_container import AddItemToContainerCommand
from cqrs.commands.save_today import SaveTodayCommand
from models.production_object import ProductionObject
from cqrs.queries.check_if_next_day import CheckIfNextDayQuery
from cqrs.queries.fetch_containers_by_object_type_name import FetchContainersByObjectTypeNameQuery
from services.configs import ConfigStorage
from services.logging import LoggerSingleton


def daily_tick(industries: Dict[str, ProductionObject], logger: LoggerSingleton):
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
                        fetch_containers_result = fetch_containers_query.execute(
                            industry_data.ObjectTypeName
                        )
                        for container in fetch_containers_result:
                            add_item_command.run(
                                container=container,
                                item_object_type_name=industry_data.ItemToAdd,
                                quantity=industry_data.Amount,
                            )
                    # Add additional logic to handle fuel, fuel_required, fuel_bonus_quality, and fuel_bonus_quantity
        else:
            logger.info("There hasn't been a day since the last check. Skipping.")
