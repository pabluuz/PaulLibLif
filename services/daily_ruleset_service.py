import os
import shutil
from datetime import datetime
import xml.dom.minidom as minidom
import yaml
import re

from services.logging import LoggerSingleton


class DailyRulesetService:
    SOURCE_PATH = "../PaulDailyRulesets"
    SOURCE_PATH_FOR_PATCH = "../PaulDailyPatches"
    DESTINATION_PATH = ".."

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

    def patch_yaml_to_xml(self):
        if not os.path.exists(self.SOURCE_PATH_FOR_PATCH):
            self.logger.error(f"Source directory {self.SOURCE_PATH_FOR_PATCH} does not exist.")
            return

        current_day = datetime.now().strftime("%A").lower()
        daily_path = os.path.join(self.SOURCE_PATH_FOR_PATCH, current_day)

        if not os.path.exists(daily_path):
            self.logger.error(f"Daily directory {daily_path} does not exist. No patch to apply.")
            return

        if not os.path.exists(self.DESTINATION_PATH):
            try:
                os.makedirs(self.DESTINATION_PATH)
            except Exception as e:
                self.logger.error(f"Failed to create destination directory {self.DESTINATION_PATH}: {e}")
                return

        for yaml_file in os.listdir(daily_path):
            if yaml_file.endswith(".yaml"):
                xml_file, _ = os.path.splitext(yaml_file)  # Remove extension
                yaml_path = os.path.join(daily_path, yaml_file)
                xml_path = os.path.join(self.DESTINATION_PATH, xml_file)

                if os.path.exists(xml_path):
                    try:
                        # Load YAML patch
                        with open(yaml_path, "r", encoding="utf-8") as f:
                            patch = yaml.safe_load(f)

                        # Load XML
                        dom = minidom.parse(xml_path)

                        # Apply patch
                        self.apply_patch(dom.documentElement, patch)

                        # Replace newlines with XML entity within <string> elements
                        self.replace_newlines_in_strings(dom)

                        # Save patched XML
                        xml_str = dom.toxml()
                        # Correctly handle specific entities
                        xml_str = xml_str.replace("&quot;", '"')

                        # Convert <string id="256"/> to <string id="256"></string>
                        xml_str = re.sub(r'<string id="(\d+)"\s*/>', r'<string id="\1"></string>', xml_str)

                        with open(xml_path, "w", encoding="utf-8") as f:
                            f.write(xml_str)
                        self.logger.info(f"Patched {xml_file} with {yaml_file}")

                    except Exception as e:
                        self.logger.error(f"Failed to patch {xml_file} with {yaml_file}: {e}")
                else:
                    self.logger.warning(f"No matching XML file found for {yaml_file}")

    def apply_patch(self, element, patch):
        for key, value in patch.items():
            if isinstance(value, list):
                for item in value:
                    if "id" in item and "value" in item:
                        string_elem = element.getElementsByTagName("string")
                        for elem in string_elem:
                            if elem.getAttribute("id") == item["id"]:
                                elem.firstChild.data = item["value"]
                                break
                        else:
                            new_string = element.ownerDocument.createElement("string")
                            new_string.setAttribute("id", item["id"])
                            new_string.appendChild(element.ownerDocument.createTextNode(item["value"]))
                            element.appendChild(new_string)
            elif isinstance(value, dict):
                sub_elements = element.getElementsByTagName(key)
                if sub_elements:
                    self.apply_patch(sub_elements[0], value)
            else:
                element.setAttribute(key, str(value))

    def replace_newlines_in_strings(self, dom):
        string_elements = dom.getElementsByTagName("string")
        for string_elem in string_elements:
            if string_elem.firstChild and string_elem.firstChild.nodeType == string_elem.TEXT_NODE:
                string_elem.firstChild.data = string_elem.firstChild.data.replace("\n", "&#xA;")
