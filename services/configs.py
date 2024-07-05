import logging
import yaml
import os
from models.production_object import ProductionObject
from services.logging import LoggerSingleton


class YAMLIndustriesProcessor:
    def __init__(self):
        self.file_path = os.path.join(os.path.dirname(__file__), "..", "config", "industries.yaml")
        self.data = None
        self.objects = {}
        self.logger = LoggerSingleton.get_logger()

    def load_yaml(self):
        try:
            with open(self.file_path, "r") as file:
                self.data = yaml.safe_load(file)
        except yaml.YAMLError as e:
            self.logger.error(f"Error reading YAML file: {e}")
            self.data = None
        except FileNotFoundError:
            self.logger.error(f"File not found: {self.file_path}")
            self.data = None

    def create_objects(self):
        if not self.data:
            return

        for name, attributes in self.data.items():
            if not isinstance(attributes, dict):
                self.logger.warning(
                    f"Warning: Skipping invalid entry '{name}' with non-dict attributes"
                )
                continue
            self.objects[name] = ProductionObject.from_dict(attributes)

    def get_objects(self):
        return self.objects

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
            cls._instance.file_path = os.path.join(
                os.path.dirname(__file__), "..", "config", "lib.yaml"
            )
            cls._instance.config_data = {}
            cls._instance.logger = LoggerSingleton.get_logger()
            cls._instance.load_yaml()

        return cls._instance

    def load_yaml(self):
        try:
            with open(self.file_path, "r") as file:
                self.config_data = yaml.safe_load(file)
        except yaml.YAMLError as e:
            self.logger.error(f"Error reading YAML file: {e}")
            self.config_data = {}
        except FileNotFoundError:
            self.logger.error(f"File not found: {self.file_path}")
            self.config_data = {}

    def get_config(self):
        return self.config_data

    def get_element(self, name: str):
        return self.config_data[name]

    def __repr__(self):
        return f"{self.__class__.__name__}({self.config_data})"
