import xml.etree.ElementTree as ET
import os
import sys


# refactor this legacy pls Paul
def read_int_from_file(filename, default_value):
    try:
        with open(filename, "r") as file:
            # Read the integer from the file
            number = int(file.read().strip())
            return number
    except FileNotFoundError:
        # print("File not found. Using default value.")
        pass
    except ValueError:
        # print("File contains invalid data. Using default value.")
        pass

    # Return the default value if there was an error reading the file or if the file doesn't contain a valid integer
    return default_value


def find_ordered_ints(list1, list2, X):
    matching_ints = []
    count = 0
    i = 0
    j = 0

    while i < len(list1) and j < len(list2) and count < X:
        if list1[i] == list2[j]:
            matching_ints.append(list1[i])
            count += 1
            i += 1
            j += 1
        else:
            if list1[i] < list2[j]:
                i += 1
            else:
                j += 1

    if count == X:
        return matching_ints
    else:
        return None


def find_ordered_ints_in_list(lst, X):
    matching_ints = []
    count = 0

    for i in range(len(lst) - 1):
        if lst[i] + 1 == lst[i + 1]:
            matching_ints.append(lst[i])
            count += 1
            if count == X:
                matching_ints.append(lst[i + 1])
                break
        else:
            matching_ints = []
            count = 0

    if count == X:
        return matching_ints
    else:
        return None


def find_free_ids(argument):
    """Returns in order
    Objects types and recipes (common free ids), recipe requirements
    """
    xml_obje_path = "../data/objects_types.xml"
    xml_reci_path = "../update/data/recipe.xml"
    xml_requ_path = "../update/data/recipe_requirement.xml"

    # liczby od 1000 do 10000
    number_list = [i for i in range(3000, 10001)]

    list1 = [xml_obje_path, xml_reci_path, xml_requ_path]
    list2 = [[] for _ in range(len(list1))]
    i = 0
    for item1, item2 in zip(list1, list2):
        with open(item1, "r") as file:
            root = ET.fromstring(file.read())
            for row in root.findall("row"):
                item2.append(int(row.find("ID").text))
        not_in_list1 = [num for num in number_list if num not in item2]
        list2[i] = not_in_list1
        i += 1

    return [find_ordered_ints(list2[0], list2[1], int(argument)), find_ordered_ints_in_list(list2[2], int(argument))]
