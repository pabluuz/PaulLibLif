import shutil
import sys
import yaml
import os
from models.production_object import ProductionObject
from services.logging import LoggerSingleton


class ConfigChecker:
    """
    The `ConfigChecker` class is responsible for checking the existence of configuration files in the `config` subdirectory. If a configuration file is not found, it will attempt to create the file from a template file (if it exists). If neither the configuration file nor the template file is found, it will log an error and exit the program.
    """

    def __init__(self) -> None:
        self.logger = LoggerSingleton.get_logger()

    def checkConfigs(self, valid_configs: list[str]) -> bool:
        """The `checkConfigs` method takes a list of valid configuration file names and checks if each file exists. If a file is not found, it will create the file from the template file (if it exists) and return `False` to indicate that a file was created. If neither the configuration file nor the template file is found, it will log an error and exit the program. If all files are found, it will return `True`.

        Args:
            valid_configs (list[str]): Target config file names.

        Returns:
            bool: True if all found, False if one or more not found but created
        """
        status = True
        for config in valid_configs:
            file_path = os.path.join(os.path.dirname(__file__), "..", "config", config)

            if not os.path.exists(file_path):
                template_file_path = os.path.join(os.path.dirname(__file__), "..", "templates", config + ".template")
                if os.path.exists(template_file_path):
                    self.logger.info(
                        config + " config file not found, creating from template. Find it in config subdirectory"
                    )
                    shutil.copy(template_file_path, file_path)
                    status = False
                else:
                    self.logger.error(f"Neither config file nor template file found: {file_path}, {template_file_path}")
                    self.data = None
                    sys.exit()
        return status


class YAMLIndustriesProcessor:
    """
    The `YAMLIndustriesProcessor` class is responsible for loading and processing YAML files located in the `PaulIndustries` directory. It ensures the base directory exists, loads all YAML files in the directory, and creates `ProductionObject` instances from the loaded data.

    The class provides the following methods:
    - `get_objects()`: Returns the dictionary of `ProductionObject` instances.
    - `display_objects()`: Prints the data for each `ProductionObject` instance (for debugging purposes).
    """

    def __init__(self):
        self.base_dir = os.path.join(os.path.dirname(__file__), "..", "..", "PaulIndustries")
        self.data = {}
        self.objects = {}
        self.logger = LoggerSingleton.get_logger()
        self.__ensure_base_dir_exists()
        self.__load_yaml_files()
        self.__create_objects()

    def __ensure_base_dir_exists(self):
        if not os.path.exists(self.base_dir):
            self.logger.info(f"Creating directory: {self.base_dir}")
            os.makedirs(self.base_dir)

    def __load_yaml_files(self):
        for root, dirs, files in os.walk(self.base_dir):
            for file in files:
                if file.endswith(".yaml"):
                    file_path = os.path.join(root, file)
                    self.__load_yaml(file_path)

    def __load_yaml(self, file_path):
        try:
            with open(file_path, "r") as file:
                data = yaml.safe_load(file)
                if not data:
                    return

                for name, attributes in data.items():
                    if name in self.data:
                        self.logger.error(
                            f"An industry with the name '{name}' already exists. Redeclared in file {file_path}"
                        )
                        sys.exit(1)

                    self.data[name] = attributes

        except yaml.YAMLError as e:
            self.logger.error(f"Error reading YAML file {file_path}: {e}")
            sys.exit(1)

    def __create_objects(self):
        for name, attributes in self.data.items():
            if not isinstance(attributes, dict):
                self.logger.error(f"Error: An industry with the name '{name}' with non-dict attributes")
                sys.exit(1)
            self.objects[name] = ProductionObject.from_dict(attributes)

    def get_objects(self):
        return dict(sorted(self.objects.items()))

    def display_objects(self):
        """
        For debugging purposes
        """
        for name, obj in self.objects.items():
            print(f"{name} Data:")
            print(obj)


class ConfigStorage:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ConfigStorage, cls).__new__(cls)
            cls._instance.file_path = os.path.join(os.path.dirname(__file__), "..", "config", "lib.yaml")
            cls._instance.config_data = {}
            cls._instance.logger = LoggerSingleton.get_logger()
            cls._instance.load_yaml()

        return cls._instance

    def load_yaml(self):
        try:
            with open(self.file_path, "r") as file:
                self.config_data = yaml.safe_load(file)
        except FileNotFoundError:
            self.logger.error("Config file not found. Exiting.")
            self.config_data = {}
            sys.exit()
        except yaml.YAMLError as e:
            self.logger.error(f"Error reading YAML file: {e}")
            self.config_data = {}
            sys.exit()

    def get_config(self):
        return self.config_data

    def get_element(self, name: str):
        return self.config_data[name]

    def __repr__(self):
        return f"{self.__class__.__name__}({self.config_data})"
