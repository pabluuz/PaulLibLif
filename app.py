import os
import sys
from typing import Dict
from models.production_object import ProductionObject
from services.configs import YAMLIndustriesProcessor, ConfigStorage
from services.db_connector import DBConnector
from services.logging import LoggerSingleton
import subprocess


def main():
    logger = LoggerSingleton.get_logger()
    logger.info(f"Paul Lib LiF v{get_git_version()}")
    # Initialize the database connector
    db_connector = DBConnector()

    # Create all tables
    db_connector.create_all_tables()

    processor = YAMLIndustriesProcessor()
    processor.load_yaml()
    if processor.data is None:
        logger.error("Failed to load config/industries.yaml from YAML. Exiting.")
        return

    processor.create_objects()
    industries: Dict[str, ProductionObject] = processor.get_objects()

    lib_config = ConfigStorage()
    lib_config.load_yaml()
    if lib_config.config_data is None:
        logger.error("Failed to load config/lib.yaml from YAML. Exiting.")
        return

    lib_config.get_config()

    # Check if a command is provided as an argument
    if len(sys.argv) > 1:
        command = sys.argv[1]
        console_dir = os.path.join(os.path.dirname(__file__), "console")
        valid_commands = [
            f.split(".")[0]
            for f in os.listdir(console_dir)
            if f.endswith(".py") and not f.startswith("__")
        ]

        if command in valid_commands:
            module_name = f"console.{command}"
            try:
                module = __import__(module_name, fromlist=[""])
                command_function = getattr(module, command)
                command_function(industries, logger)
            except (ImportError, AttributeError) as e:
                logger.error(f"Error executing command '{command}': {e}")
        else:
            logger.error(f"Invalid command: {command}")
    else:
        logger.error("No command provided. Please provide a command as an argument.")


def get_git_version():
    try:
        # Get the latest tag, the number of commits since the tag, and the commit hash
        describe_command = ["git", "describe", "--tags", "--long", "--always"]
        version = subprocess.check_output(describe_command).strip().decode("utf-8")

        # If there are tags, version looks like: "v1.0.0-14-gabcdef"
        # If there are no tags, it looks like: "abcdef"
        if "-" in version:
            tag, commits_since_tag, commit_hash = version.rsplit("-", 2)
            version = f"{tag}.{commits_since_tag}"
        else:
            # commit_hash = version
            commit_count = (
                subprocess.check_output(["git", "rev-list", "--count", "HEAD"])
                .strip()
                .decode("utf-8")
            )
            version = f"0.0.{commit_count}"

        return version
    except subprocess.CalledProcessError:
        return "0.0.0"


version = get_git_version()
print(f"Version: {version}")


if __name__ == "__main__":
    main()
