import os
import shutil
from datetime import datetime

from services.logging import LoggerSingleton


class DailyRulesetService:
    SOURCE_PATH = "../paul-daily-rulesets"
    DESTINATION_PATH = "../update"

    def __init__(self) -> None:
        self.logger = LoggerSingleton.get_logger()

    def process_daily_rulesets(self):
        if not os.path.exists(self.SOURCE_PATH):
            self.logger.error(f"Source directory {self.SOURCE_PATH} does not exist.")
            return

        current_day = datetime.now().strftime("%A").lower()
        daily_path = os.path.join(self.SOURCE_PATH, current_day)

        if not os.path.exists(daily_path):
            self.logger.info(f"Daily directory {daily_path} does not exist. Using universal ruleset.")
            daily_path = os.path.join(self.SOURCE_PATH, "universal")
            if not os.path.exists(daily_path):
                self.logger.error(f"Source directory {self.SOURCE_PATH} does not exist.")
                return

        self.copy_directory(daily_path, self.DESTINATION_PATH)
        self.logger.info(f"Files copied from {daily_path} to {self.DESTINATION_PATH}")

    def copy_directory(self, source_dir, dest_dir):
        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)

        for item in os.listdir(source_dir):
            source_item = os.path.join(source_dir, item)
            dest_item = os.path.join(dest_dir, item)

            if os.path.isdir(source_item):
                self.copy_directory(source_item, dest_item)
            else:
                shutil.copy2(source_item, dest_item)
