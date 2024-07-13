from ast import List
import os
import string
import sys
import xml.etree.ElementTree as ET
import xml.dom.minidom
import yaml
from legacy.xdziura import find_free_ids
from cqrs.queries.fetch_object_type_by_name import FetchObjectTypeByNameQuery
from services.logging import LoggerSingleton


class CommentedTreeBuilder(ET.TreeBuilder):
    def comment(self, data):
        self.start(ET.Comment, {})
        self.data(data)
        self.end(ET.Comment)


class YamlToXmlConverter:
    def __init__(self, yaml_dir_path, objects_types_xml_file_path):
        self.found_all_ids = True
        self.logger = LoggerSingleton.get_logger()
        self.yaml_dir_path = yaml_dir_path
        self.objects_types_xml_file_path = objects_types_xml_file_path

        free_ids = find_free_ids(50)
        self.free_ids_obj_types = free_ids[0]
        self.free_ids_rec_reqs = free_ids[1]
        self.free_ids_index_obj_types = 0
        self.free_ids_index_rec_reqs = 0

    def _item_name_to_id(self, name: string):
        # look in DB first, maybe it's easy
        with FetchObjectTypeByNameQuery() as get_object_query:
            object_type = get_object_query.execute(name)
            if object_type is not None:
                return object_type.id

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
                                if "idX" not in obj or obj["idX"] is None:
                                    obj["idX"] = self.free_ids_obj_types[self.free_ids_index_obj_types]
                                    self.free_ids_index_obj_types += 1
                                    self.logger.info(f"Added ID {obj['idX']} to ObjectType '{name}'.")
                                return obj["idX"]

        # else we'll crash. not found anywhere
        self.logger.error(f"Error: '{name}' does not exist as name of any object.")
        sys.exit(1)

    def _fill_default_values_to_missing_keys_in_yaml(self, data):
        defaults_false = [
            "isContainer",
            "isMovableObject",
            "isUnmovableObject",
            "isTool",
            "isDevice",
            "isDoor",
            "isPremium",
        ]
        for key in defaults_false:
            if key not in data:
                data[key] = False

        default_zeros = ["maxContSize", "length", "maxStackSize", "unitWeight", "monumentPoints", "ownerTimeout"]
        for key in default_zeros:
            if key not in data:
                data[key] = 0

        default_empty_strings = ["faceImage", "description", "fuel", "fuelConsumption", "fuelConsumptionUnits"]
        for key in default_empty_strings:
            if key not in data:
                data[key] = ""

        if "parent" not in data:
            data["parent"] = "Inventory objects"

        return data

    def _add_object_name_translation(self, obj: List):
        if "nameTranslations" in obj:
            for lang in obj["nameTranslations"]:
                target_file_path = "../update/data/loc/" + lang + "/data/objects_types_Name.xml"
                parser = ET.XMLParser(encoding="utf-8", target=CommentedTreeBuilder())
                tree = ET.parse(target_file_path, parser=parser)
                root = tree.getroot()
                strings = root.find(".//strings")
                found_name = strings.find(f".//string[@id='{obj['idX']}']")
                if found_name is None:
                    name = ET.SubElement(strings, "string")
                    name.set("id", str(obj["idX"]))
                    name.text = obj["nameTranslations"][lang]
                    self.logger.info(f"Added name translation for {lang} to {obj['name']}.")
                else:
                    found_name.text = obj["nameTranslations"][lang]
                tree.write(target_file_path, encoding="utf-8", xml_declaration=True)

    def _pretty_save(self, data: ET.ElementTree, path, xsd_name: str = None):
        with open(path, "w", encoding="utf-8") as f:
            xml_data = ET.tostring(data.getroot(), encoding="utf-8")
            dom_string = xml.dom.minidom.parseString(xml_data).toprettyxml(encoding="UTF-8")
            dom_string = "\n".join([s for s in dom_string.decode("utf-8").splitlines() if s.strip()])

            # Add the XML model line manually
            if xsd_name is not None:
                xml_model_line = f'<?xml-model href="{xsd_name}"?>'
                dom_string = dom_string.replace(
                    '<?xml version="1.0" encoding="UTF-8"?>',
                    f'<?xml version="1.0" encoding="UTF-8"?>\n{xml_model_line}',
                )

            f.write(dom_string)

    def convert(self):
        # Read the existing XML file
        parser = ET.XMLParser(encoding="utf-8", target=CommentedTreeBuilder())
        tree = ET.parse(self.objects_types_xml_file_path, parser=parser)
        table = tree.getroot()
        for row in table:
            for child in row:
                # print(child.tag, child.text)
                pass
        rows_with_paulmod = table.findall('.//row[@PaulMod="yes"]')

        data = []
        # Process YAML files and add new rows
        for yaml_file in os.listdir(self.yaml_dir_path):
            if yaml_file.endswith(".yaml"):
                yaml_file_path = os.path.join(self.yaml_dir_path, yaml_file)
                with open(yaml_file_path, "r", encoding="utf-8") as yaml_file:
                    data.append(yaml.safe_load(yaml_file))
                for datum in data:
                    if datum and "objects" in datum:
                        for obj in datum["objects"]:
                            obj = self._fill_default_values_to_missing_keys_in_yaml(obj)
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
                                continue

                            if found is False:
                                row = ET.SubElement(table, "row")
                                row.set("PaulMod", "yes")
                                obj["idX"] = str(self._item_name_to_id(obj["name"]))
                                ET.SubElement(row, "ID").text = obj["idX"]
                                ET.SubElement(row, "ParentID").text = str(parent_id)
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
                                ET.SubElement(row, "BasePrice").text = str(obj["monumentPoints"])
                                ET.SubElement(row, "OwnerTimeout").text = str(obj["ownerTimeout"])
                            else:
                                obj["idX"] = row.find("ID").text
                                row.find("ParentID").text = str(parent_id)
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
                                row.find("BasePrice").text = str(obj["monumentPoints"])
                                row.find("OwnerTimeout").text = str(obj["ownerTimeout"])
                            self.logger.info("Added ObjectType: " + obj["name"])
                            self._add_object_name_translation(obj)
        # Write the updated XML to the file
        print(row.keys())

        self._pretty_save(tree, self.objects_types_xml_file_path, "objects_types.xsd")
        # tree.write(self.objects_types_xml_file_path, encoding="utf-8", xml_declaration=True)

        return
