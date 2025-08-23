import os
import xml.etree.ElementTree as ET
import logging
import re
import unicodedata
import html
import subprocess


# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Normalize text function to handle diacritics, spaces, and HTML entities
def normalize_text(text):
    if text is None:
        return ""
    decoded_text = html.unescape(text)
    normalized = unicodedata.normalize("NFD", decoded_text).encode("ascii", "ignore").decode("utf-8")
    return re.sub(r'\s+', ' ', normalized).strip().lower()

# Paths to directories
current_dir = os.getcwd()
master_dirs = [
    os.path.join(current_dir, "../Sources/PHB2024/WizardsOfTheCoast/01_Players_Handbook_2024"),
    os.path.join(current_dir, "../Sources/PHB2024/WizardsOfTheCoast/02_Dungeon_Masters_Guide_2024"),
    os.path.join(current_dir, "..Sources_2024/WizardsOfTheCoast/03_Monster_Manual_2024")
]




legacy_dir = os.path.join(current_dir, "..Sources_2024/Homebrew/WotC_2014_legacy/WizardsOfTheCoast_homebrew_2014_legacy")

# Read master files into memory
master_data = {}
for master_dir in master_dirs:
    logging.info(f"Processing master directory: {master_dir}")
    for root, _, files in os.walk(master_dir):
        for file in files:
            if file.endswith(".xml"):
                file_path = os.path.join(root, file)
                logging.info(f"Reading master file: {file_path}")
                try:
                    tree = ET.parse(file_path)
                    compendium = tree.getroot()
                    for item in list(compendium):
                        name = item.find("name")
                        if name is not None:
                            normalized_name = normalize_text(name.text.replace(" [2024]", ""))
                            item_key = (item.tag, normalized_name)
                            master_data[item_key] = item
                            logging.debug(f"Added master item: {item_key}")
                except ET.ParseError as e:
                    logging.error(f"XML parsing error in master file {file_path}: {e}")

base_classes = ["Cleric","Wizard","Bard","Barbarian","Ranger","Sorcerer","Warlock","Fighter","Paladin","Druid","Monk"]

# If a subclass has moved to a 2024 book, add its name here
excluded_subclasses = {
    "fighter": [], 
    "ranger": [],
    "wizard": [], 
    "cleric": [],
    "druid": [],
    "barbarian": [],
    "warlock": [],
    "sorcerer": [],
    "monk": [],
    "rogue": [],
    "bard": [],
    "paladin": []
}
# if casters have moved to a general spell list, add them to this array
excluded_casters = [

]


# Process legacy files
logging.info(f"Processing legacy directory: {legacy_dir}")
for root, _, files in os.walk(legacy_dir):
    for file in files:
        if file.endswith(".xml"):
            file_path = os.path.join(root, file)
            logging.info(f"Processing legacy file: {file_path}")
            try:
                tree = ET.parse(file_path)
                compendium = tree.getroot()
                updated = False

                for item in list(compendium):
                    name = item.find("name")

                    if name is not None:
                        original_name = name.text
                        normalized_name = normalize_text(original_name)
                        item_key = (item.tag, normalized_name)

                        if item.tag == "class":
                            class_name = normalize_text(name.text)

                            if item_key in master_data:
                                logging.debug(f"Found duplicate class in master: {original_name}")
                                updated = True
                                for child in list(item):
                                    if child.tag not in ["name", "autolevel"]:
                                        item.remove(child)

                                for autolevel in list(item.findall("autolevel")):
                                    level = int(autolevel.get("level", "0"))
                                    features_to_remove = []

                                    for feature in list(autolevel.findall("feature")):
                                        feature_name = feature.find("name")
                                        if feature_name is not None:
                                            feature_text = normalize_text(feature_name.text)

                                            # Check if feature name matches excluded subclasses for this class
                                            excluded_for_class = excluded_subclasses.get(class_name, [])
                                            if any(normalize_text(subclass) in feature_text for subclass in excluded_for_class):
                                                features_to_remove.append(feature)
                                            elif feature.get("optional") != "YES":
                                                features_to_remove.append(feature)

                                            # Remove feature if it starts with "Starting [class]" or "Multiclass [class]"
                                            if feature_text.startswith(f"starting {class_name}") or feature_text.startswith(f"multiclass {class_name}"):
                                                features_to_remove.append(feature)

                                    for feature in features_to_remove:
                                        autolevel.remove(feature)

                                    # Remove empty autolevels
                                    if len(autolevel.findall("feature")) == 0 and len(autolevel.findall("counter")) == 0:
                                        item.remove(autolevel)


                        elif item.tag == "spell":
                            text = item.find("text")
                            if text is None:
                                if item_key in master_data:
                                    logging.info(f"Found spell: {original_name} in master data")
                                    if " [2024]" not in original_name:
                                        item.find("name").text = f"{original_name} [2024]"
                                        logging.info(f"Updated spell name to include [2024]: {item.find('name').text}")
                                        updated = True
                        
                            classes = item.find("classes")
                            if classes is not None:
                                original_classes = classes.text.split(",") if classes.text else []
                                updated_classes = []
                                for cls in original_classes:
                                    cls_cleaned = cls.strip()
                                    if cls_cleaned not in excluded_casters:
                                        if cls_cleaned in base_classes:
                                            updated_classes.append(f"{cls_cleaned} [2024]")
                                        else:
                                            updated
                            updated = True

                        else:

                            if item_key in master_data:
                                compendium.remove(item)
                            updated = True

                if updated:
                    tree.write(file_path, encoding="utf-8", xml_declaration=True)
                    logging.info(f"Updated legacy file written: {file_path}")

            except ET.ParseError as e:
                logging.error(f"XML parsing error in legacy file {file_path}: {e}")


# Build compendium
result = subprocess.run("xsltproc -o ../Collections/Complete_Compendium_2014+2024.xml merge.xslt ../Collections/Complete_Compendium_2014+2024.xml", shell=True, capture_output=True, text=True)
# Print output
print("STDERR:", result.stderr)