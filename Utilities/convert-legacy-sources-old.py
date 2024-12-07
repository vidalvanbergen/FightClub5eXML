import os
import xml.etree.ElementTree as ET
import logging
import re
import unicodedata
import html

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
master_dir = os.path.join(current_dir, "Sources/WizardsOfTheCoast2024/01_Players_Handbook_2024")
legacy_dir = os.path.join(current_dir, "Sources/WizardsOfTheCoast2024/Homebrew_2014_to_2024_conversion")

# Read master files into memory
master_data = {}
for root, _, files in os.walk(master_dir):
    for file in files:
        if file.endswith(".xml"):
            file_path = os.path.join(root, file)
            try:
                tree = ET.parse(file_path)
                compendium = tree.getroot()
                for item in list(compendium):
                    name = item.find("name")
                    if name is not None:
                        normalized_name = normalize_text(name.text)
                        item_key = (item.tag, normalized_name)
                        master_data[item_key] = item
            except ET.ParseError as e:
                logging.error(f"XML parsing error in master file {file_path}: {e}")

# Exclusion lists
excluded_subclasses = [
    "Eldritch Knight", "Champion", "Battlemaster", "Battle Master", "Psi Warrior", "Psi-Warrior", 
    "Hunter", "Beastmaster", "Beast Master", "Gloomstalker", "Gloom Stalker", "Fey Wanderer",
    "Evoker", "Evocation", "Abjuration", "Illusion", "Illusionist", "Abjurer", "Diviner", 
    "Light Domain", "Life Domain", "Trickery Domain", "War Domain",
    "Circle of the Moon", "Circle of Moon", "Circle of the Stars", "Circle of Stars", "Circle of the Land", "Circle of Land",
    "Berserker", "Zealot", "Path of the Totem",
    "The Fiend", "Great Old One", "The Celestial", "The Archfey",
    "Aberrant Mind", "Wild Magic Sorcery", "Draconic Sorcerer","Draconic Sorcery","Draconic Bloodline", "Shadow Magic", "Clockwork Soul",
    "Open Hand", "Four Elements", "Way of Shadow","Way of Mercy",
    "Thief", "Assassin", "Arcane Trickster","Soulknife",
    "College of Lore", "College of Glamour", "College of Valor",
    "Oath of Vengeance", "Oath of the Ancients", "Oath of Devotion", "Oath of Glory"
]
excluded_casters = [
    "Arcane Trickster", 
    "Eldritch Knight"
]
excluded_counters = ["Ki", "Rage", "Bardic Inspiration"]

def process_class_element(item, class_name, updated):
    """Processes class elements."""
    for autolevel in list(item.findall("autolevel")):
        features_to_remove = []
        for feature in list(autolevel.findall("feature")):
            feature_name = feature.find("name")
            if feature_name is not None:
                feature_text = normalize_text(feature_name.text)
                
                # Remove feature if it starts with "Starting [class]" or "Multiclass [class]"
                if feature_text.startswith(f"starting {class_name}") or feature_text.startswith(f"multiclass {class_name}"):
                    features_to_remove.append(feature)
                    autolevel.remove(feature)

                # Check if feature name matches any excluded subclass
                if any(normalize_text(subclass) in feature_text for subclass in excluded_subclasses):
                    features_to_remove.append(feature)
                    autolevel.remove(feature)
                    continue

                # Add suffix if required
               # if not feature_name.text.endswith(" [2014]"):
               #     feature_name.text += " [2014]"
                
                # Check for starting and multiclass clauses
                if feature_text.startswith(f"starting {class_name}") or feature_text.startswith(f"multiclass {class_name}"):
                    features_to_remove.append(feature)
                    autolevel.remove(feature)

            # Remove counters if they match excluded counters
            for counter in list(autolevel.findall("counter")):
                counter_name = counter.find("name")
                if counter_name is not None and normalize_text(counter_name.text) in excluded_counters:
                    autolevel.remove(counter)


        # Special class handling rules for autolevels
        if class_name == "cleric":
            for autolevel in list(item.findall("autolevel")):
                level = int(autolevel.get("level", "0"))
                for feature in autolevel.findall("feature"):
                    feature_name = feature.find("name")
                    if feature_name is not None and "domain" in normalize_text(feature_name.text) and level < 3:
                        autolevel.set("level", "3")

        if class_name == "warlock":
            for autolevel in list(item.findall("autolevel")):
                level = int(autolevel.get("level", "0"))
                for feature in autolevel.findall("feature"):
                    feature_name = feature.find("name")
                    if feature_name is not None:
                        feature_text = normalize_text(feature_name.text)
                        if "pact boon" in feature_text and not feature_text.endswith(" [2014]"):
                            if re.match(r"pact boon: pact of the (blade|tome|chain)", feature_text):
                                features_to_remove.append(feature)
                        if level < 3 and "pact boon" not in feature_text:
                            autolevel.set("level", "3")

        if class_name == "wizard":
            for autolevel in list(item.findall("autolevel")):
                level = int(autolevel.get("level", "0"))
                for feature in autolevel.findall("feature"):
                    feature_name = feature.find("name")
                    if feature_name is not None and (("arcane tradition" in normalize_text(feature_name.text)) or ("school of" in normalize_text(feature_name.text)) or ("mage of" in normalize_text(feature_name.text)) or ("Bladesing" in normalize_text(feature_name.text)) or ("order of" in normalize_text(feature_name.text))) and level < 3:
                        autolevel.set("level", "3")

        if class_name == "paladin":
            for autolevel in list(item.findall("autolevel")):
                level = int(autolevel.get("level", "0"))
                for feature in autolevel.findall("feature"):
                    feature_name = feature.find("name")
                    if feature_name is not None and "oath" in normalize_text(feature_name.text) and level < 3:
                        autolevel.set("level", "3")

        if file == "class-ranger-tce.xml":
            for autolevel in list(item.findall("autolevel")):
                for feature in list(autolevel.findall("feature")):
                    feature_name = feature.find("name")
                    feature_text = feature.find("text")

                if feature_name is not None and "deft explorer" in normalize_text(feature_name.text):
                    features_to_remove.append(feature)
                if feature_text is not None and feature_text.text.startswith("Replaces the "):
                    features_to_remove.append(feature)
                    autolevel.remove(feature)
                    

        updated = True

        # Remove the features identified for removal
        for feature in features_to_remove:
            if feature in autolevel:
                autolevel.remove(feature)
            else:
                print(f"Warning: Feature not found. Skipping removal: {feature_name.text}")


        # Remove empty autolevels
        if len(autolevel.findall("feature")) == 0:
            item.remove(autolevel)

    return updated

def process_spell_element(item, updated):
    """Processes spell elements."""
    classes = item.find("classes")
    if classes is not None:
        original_classes = classes.text.split(",") if classes.text else []
        updated_classes = [cls.strip() for cls in original_classes if normalize_text(cls) not in excluded_casters]
        if updated_classes:
            classes.text = ", ".join(updated_classes)
        # else:
            # classes.text = "Legacy [2014]"

    text = item.find("text")
    if text is None:
        if (item.tag, normalize_text(item.find("name").text)) not in master_data:
            if not item.find("name").text.endswith(" [2014]"):
                item.find("name").text += " [2014]"
            updated = True
    else:
        if (item.tag, normalize_text(item.find("name").text)) in master_data:
            compendium.remove(item)
            updated = True
        else:
           if not item.find("name").text.endswith(" [2014]"):
                item.find("name").text += " [2014]"
        updated = True

    return updated

# Process legacy files
for root, _, files in os.walk(legacy_dir):
    for file in files:
        if file.endswith(".xml"):
            file_path = os.path.join(root, file)
            try:
                tree = ET.parse(file_path)
                compendium = tree.getroot()
                updated = False

                for item in list(compendium):
                    name = item.find("name")
                    if name is not None:
                        original_name = name.text
                        normalized_name = normalize_text(original_name.replace(" [2014]", ""))
                        item_key = (item.tag, normalized_name)

                        # Process classes
                        if item.tag == "class":
                            class_name = normalize_text(name.text)
                            if item_key in master_data:
                                updated = process_class_element(item, class_name, updated)
                            else:
                                if not name.text.endswith(" [2014]"):
                                    name.text += " [2014]"
                                updated = True

                        # Process spells
                        elif item.tag == "spell":
                            updated = process_spell_element(item, updated)

                        # Other cases
                        else:
                            if item_key in master_data:
                                compendium.remove(item)
                            elif not original_name.endswith(" [2014]"):
                                name.text = original_name + " [2014]"
                                updated = True
                    
                if updated:
                    tree.write(file_path, encoding="utf-8", xml_declaration=True)
                

            except ET.ParseError as e:
                logging.error(f"XML parsing error in legacy file {file_path}: {e}")
