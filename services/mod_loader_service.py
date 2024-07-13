import os
import string
import sys
import xml.etree.ElementTree as ET
import yaml
from legacy.xdziura import find_free_ids
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from services.logging import LoggerSingleton


class YamlToXmlConverter:
    def __init__(self, yaml_dir_path, objects_types_xml_file_path):
        self.found_all_ids = True
        self.logger = LoggerSingleton.get_logger()
        self.yaml_dir_path = yaml_dir_path
        self.objects_types_xml_file_path = objects_types_xml_file_path

    def _item_name_to_id(self, name: string):
        # look in DB first, maybe it's easy
        with FetchObjectTypeByNameQuery() as get_object_query:
            object_type = get_object_query.execute(name)
            if object_type is not None:
                return object_type.name

        # now look in yamls, maybe it's not yet added
        # we will use 0 as ID, and reschedule whole procedure
        data = []
        for yaml_file in os.listdir(self.yaml_dir_path):
            if yaml_file.endswith(".yaml"):
                yaml_file_path = os.path.join(self.yaml_dir_path, yaml_file)
                with open(yaml_file_path, "r") as yaml_file:
                    data.append(yaml.safe_load(yaml_file))
                for datum in data:
                    if datum and "objects" in datum:
                        for obj in datum["objects"]:
                            if obj["name"] == name:
                                return 0

        # else we'll crash. not found anywhere
        self.logger.error(f"Error: '{name}' does not exist as name of any object.")
        sys.exit(1)

    def convert(self):
        all_obj_names_found = True
        # Read the existing XML file
        parser = ET.XMLParser(encoding="utf-8")
        tree = ET.parse(self.objects_types_xml_file_path, parser=parser)
        table = tree.getroot()
        for row in table:
            for child in row:
                # print(child.tag, child.text)
                pass
        rows_with_paulmod = table.findall('.//row[@PaulMod="yes"]')

        # Find the <table name="objects_types"> element
        # table = root.find('table[@name="objects_types"]')
        free_ids = find_free_ids(50)

        free_ids_obj_types = free_ids[0]
        free_ids_rec_reqs = free_ids[1]
        free_ids_index_obj_types = 0
        free_ids_index_rec_reqs = 0
        data = []
        # Process YAML files and add new rows
        for yaml_file in os.listdir(self.yaml_dir_path):
            if yaml_file.endswith(".yaml"):
                yaml_file_path = os.path.join(self.yaml_dir_path, yaml_file)
                with open(yaml_file_path, "r") as yaml_file:
                    data.append(yaml.safe_load(yaml_file))
                for datum in data:
                    if datum and "objects" in datum:
                        for obj in datum["objects"]:

                            # find if already exists
                            found = False
                            if rows_with_paulmod is not None and rows_with_paulmod != []:
                                for row_with_paulmod in rows_with_paulmod:
                                    print(row_with_paulmod.find("Name"))
                                    if (
                                        row_with_paulmod.find("Name") is not None
                                        and row_with_paulmod.find("Name").text == obj["name"]
                                    ):
                                        found = True
                                        row = row_with_paulmod

                            parent_id = self._item_name_to_id(obj["parent"])
                            if parent_id == 0:
                                # skip this for now, we'll do it again
                                all_obj_names_found = False
                                continue

                            if found is False:
                                row = ET.SubElement(table, "row")
                                row.set("PaulMod", "yes")
                                # Only set new ID if not found

                                ET.SubElement(row, "ID").text = str(free_ids_obj_types[free_ids_index_obj_types])
                                free_ids_index_obj_types += 1
                                ET.SubElement(row, "ParentID").text = parent_id
                                ET.SubElement(row, "Name").text = obj["name"]
                                ET.SubElement(row, "IsContainer").text = "1" if obj["isContainer"] else "0"
                                ET.SubElement(row, "IsMovableObject").text = "1" if obj["isMovableObject"] else "0"
                                ET.SubElement(row, "IsUnmovableobject").text = "1" if obj["isUnmovableObject"] else "0"
                                ET.SubElement(row, "IsTool").text = "1" if obj["isTool"] else "0"
                                ET.SubElement(row, "IsDevice").text = "1" if obj["isDevice"] else "0"
                                ET.SubElement(row, "IsDoor").text = "1" if obj["isDoor"] else "0"
                                ET.SubElement(row, "IsPremium").text = "1" if obj["isPremium"] else "0"
                                ET.SubElement(row, "MaxContSize").text = str(obj["maxContSize"])
                                ET.SubElement(row, "Length").text = str(obj["length"])
                                ET.SubElement(row, "MaxStackSize").text = str(obj["maxStackSize"])
                                ET.SubElement(row, "UnitWeight").text = str(obj["unitWeight"])
                                ET.SubElement(row, "BackgndImage").text = obj["backgndImage"]
                                ET.SubElement(row, "FaceImage").text = obj["faceImage"]
                                ET.SubElement(row, "Description").text = obj["description"]
                            else:
                                row.find("ParentID").text = parent_id
                                row.find("IsContainer").text = "1" if obj["isContainer"] else "0"
                                row.find("IsMovableObject").text = "1" if obj["isMovableObject"] else "0"
                                row.find("IsUnmovableobject").text = "1" if obj["isUnmovableObject"] else "0"
                                row.find("IsTool").text = "1" if obj["isTool"] else "0"
                                row.find("IsDevice").text = "1" if obj["isDevice"] else "0"
                                row.find("IsDoor").text = "1" if obj["isDoor"] else "0"
                                row.find("IsPremium").text = "1" if obj["isPremium"] else "0"
                                row.find("MaxContSize").text = str(obj["maxContSize"])
                                row.find("Length").text = str(obj["length"])
                                row.find("MaxStackSize").text = str(obj["maxStackSize"])
                                row.find("UnitWeight").text = str(obj["unitWeight"])
                                row.find("BackgndImage").text = obj["backgndImage"]
                                row.find("FaceImage").text = obj["faceImage"]
                                row.find("Description").text = obj["description"]
        # Write the updated XML to the file
        print(row.keys())
        tree.write(self.objects_types_xml_file_path, encoding="utf-8", xml_declaration=True)

        return all_obj_names_found
