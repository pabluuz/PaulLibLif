import xml.etree.ElementTree as ET
import os


class LegacyConverter:
    def __init__(self):
        self.start_marker = ["-- START RECIPE REQUIREMENT", "-- START RECIPE", "-- START OBJECT TYPES"]
        self.stop_marker = ["-- STOP RECIPE REQUIREMENT", "-- STOP RECIPE", "-- STOP OBJECT TYPES"]

        self.fields = [
            ["ID", "RecipeID", "MaterialObjectTypeID", "Quality", "Influence", "Quantity", "IsRegionItemRequired"],
            [
                "ID",
                "Name",
                "Description",
                "StartingToolsID",
                "SkillTypeID",
                "SkillLvl",
                "ResultObjectTypeID",
                "SkillDepends",
                "Quantity",
                "Autorepeat",
                "IsBlueprint",
                "ImagePath",
            ],
            [
                "ID",
                "ParentID",
                "Name",
                "IsContainer",
                "IsMovableObject",
                "IsUnmovableobject",
                "IsTool",
                "IsDevice",
                "IsDoor",
                "IsPremium",
                "MaxContSize",
                "Length",
                "MaxStackSize",
                "UnitWeight",
                "BackgndImage",
                "WorkAreaTop",
                "WorkAreaLeft",
                "WorkAreaWidth",
                "WorkAreaHeight",
                "BtnCloseTop",
                "BtnCloseLeft",
                "FaceImage",
                "Description",
                "BasePrice",
                "OwnerTimeout",
                "AllowExportFromRed",
                "AllowExportFromGreen",
            ],
        ]

        self.table_fields = [
            "(`ID`, `RecipeID`, `MaterialObjectTypeID`, `Quality`, `Influence`, `Quantity`, `IsRegionItemRequired`)",
            "(`ID`, `Name`, `Description`, `StartingToolsID`, `SkillTypeID`, `SkillLvl`, `ResultObjectTypeID`, `SkillDepends`, `Quantity`, `Autorepeat`, `IsBlueprint`, `ImagePath`)",
            "(`ID`, `ParentID`, `Name`, `IsContainer`, `IsMovableObject`, `IsUnmovableobject`, `IsTool`, `IsDevice`, `IsDoor`, `IsPremium`, `MaxContSize`, `Length`, `MaxStackSize`, `UnitWeight`, `BackgndImage`, `WorkAreaTop`, `WorkAreaLeft`, `WorkAreaWidth`, `WorkAreaHeight`, `BtnCloseTop`, `BtnCloseLeft`, `FaceImage`, `Description`, `BasePrice`, `OwnerTimeout`, `AllowExportFromRed`, `AllowExportFromGreen`)",
        ]

        self.xml_file_paths = [
            "../update/data/recipe_requirement.xml",
            "../update/data/recipe.xml",
            "../data/objects_types.xml",
        ]

        self.table_names = ["recipe_requirement", "recipe", "objects_types"]

        with open("../dict/basePriceDict.txt", "r") as file:
            # Read lines and split by tab ('\t')
            lines = file.readlines()
            # Create a dictionary from the lines
            self.dictionary = {line.split("\t")[0]: line.split("\t")[1].strip() for line in lines}

        with open("../dict/owner_timeout.txt", "r") as file:
            # Read lines and split by tab ('\t')
            lines = file.readlines()
            # Create a dictionary from the lines
            self.dictionaryTimeout = {line.split("\t")[0]: line.split("\t")[1].strip() for line in lines}

        self.file_path = "../sql/dump.sql"

    def is_castable_as_int(variable):
        try:
            int(variable)
            return True
        except ValueError:
            return False

    def convert(self):
        for start, end, field, table_field, xml_file_path, table_name in zip(
            self.start_marker, self.stop_marker, self.fields, self.table_fields, self.xml_file_paths, self.table_names
        ):
            with open(xml_file_path, "r") as file:
                xml_data = file.read()

            root = ET.fromstring(xml_data)
            values_all = ""
            known_ids = []
            last_known_id = "0"
            for row in root.findall("row"):
                values = []
                for field_single in field:
                    value = row.find(field_single)
                    if field_single == "ID":
                        last_known_id = value.text
                    if field_single == "BasePrice":
                        if not (value is None or value.text is None):
                            if str(value.text) != "0":
                                values.append(value.text)
                        elif last_known_id in self.dictionary:
                            values.append(int(self.dictionary[last_known_id]))
                        else:
                            values.append("NULL")
                    elif field_single == "OwnerTimeout":
                        if not (value is None or value.text is None):
                            if str(value.text) != "0":
                                values.append(value.text)
                        elif last_known_id in self.dictionaryTimeout:
                            values.append(int(self.dictionaryTimeout[last_known_id]))
                        else:
                            values.append("NULL")
                    elif value is None or value.text is None:
                        if (
                            field_single == "AllowExportFromRed"
                            or field_single == "AllowExportFromGreen"
                            or field_single == "IsPremium"
                        ):
                            values.append("0")
                        else:
                            values.append("NULL")
                    elif field_single == "ParentID" and int(value.text) == 0:
                        values.append("NULL")
                    elif field_single == "StartingToolsID" and int(value.text) == 0:
                        values.append("NULL")
                    elif field_single == "BackgndImage" or field_single == "FaceImage" or field_single == "ImagePath":
                        values.append("'" + str(value.text).replace("'", "''").replace("\\", "\\\\") + "'")
                    else:
                        if self.is_castable_as_int(value.text):
                            if field_single == "ID":
                                known_ids.append(int(value.text))
                            values.append(value.text)
                        else:
                            values.append("'" + str(value.text).replace("'", "''") + "'")
                rowString = "(" + ",".join(map(str, values)) + ")"
                values_all = values_all + rowString + ", \n"

            values_all = values_all[:-3] + ";"
            insert_statement = f"INSERT INTO `{table_name}` {table_field} VALUES \n{values_all}"

            with open(self.file_path, "r") as file:
                file_content = file.read()

            # Find the indices of the start and stop markers
            start_index = file_content.find(start)
            stop_index = file_content.find(end)

            # Replace the portion between the markers with your string
            if start_index != -1 and stop_index != -1:
                new_file_content = (
                    file_content[: start_index + len(start)]
                    + "\n"
                    + insert_statement
                    + "\n"
                    + file_content[stop_index:]
                )
            else:
                new_file_content = file_content

            # Write the modified content back to the file
            with open(self.file_path, "w") as file:
                file.write(new_file_content)
