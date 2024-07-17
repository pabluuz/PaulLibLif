from services.daily_ruleset_service import DailyRulesetService
from services.logging import LoggerSingleton


def daily_ruleset() -> None:
    logger = LoggerSingleton.get_logger()
    logger.info("Copying rules from today weekday to update")
    daily_ruleset_service = DailyRulesetService()
    daily_ruleset_service.process_daily_rulesets()
