# console/daily_tick.py
from typing import Dict
from commands.add_item_to_container import AddItemToContainerCommand
from commands.save_today import SaveTodayCommand
from models.production_object import ProductionObject
from queries.check_if_next_day import CheckIfNextDayQuery
from services.logging import LoggerSingleton


def daily_tick(industries: Dict[str, ProductionObject], logger: LoggerSingleton):
    with CheckIfNextDayQuery() as next_day_query:
        next_day_query_result = next_day_query.execute()
        if next_day_query_result:
            with SaveTodayCommand() as save_today_command:
                save_today_command.execute()

            for industry_name, industry_data in industries.items():
                object_type_name = industry_data.ObjectTypeName
                item_to_add = industry_data.ItemToAdd
                amount = industry_data.Amount
                with AddItemToContainerCommand() as add_item_command:
                    add_item_command.run(
                        container_object_type_name=industry_data.ObjectTypeName,
                        item_object_type_name=item_to_add,
                        quantity=industry_data.Amount,
                    )
                    # Add additional logic to handle fuel, fuel_required, fuel_bonus_quality, and fuel_bonus_quantity
                    logger.info(f"Adding {amount} {item_to_add} to {object_type_name}.")
        else:
            logger.info("There hasn't been a day since the last check. Skipping.")
