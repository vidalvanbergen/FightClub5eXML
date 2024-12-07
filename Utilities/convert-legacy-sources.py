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
                        normalized_name = normalize_text(name.text.replace(" [2024]", ""))
                        item_key = (item.tag, normalized_name)
                        master_data[item_key] = item
            except ET.ParseError as e:
                logging.error(f"XML parsing error in master file {file_path}: {e}")

# Exclusion lists
base_classes = ["Cleric","Wizard","Bard","Barbarian","Ranger","Sorcerer","Warlock","Fighter","Paladin","Druid"]
excluded_subclasses = [
    "Eldritch Knight", "Champion", "Battlemaster", "Battle Master", "Psi Warrior", "Psi-Warrior", 
    "Hunter", "Beastmaster", "Beast Master", "Gloomstalker", "Gloom Stalker", "Fey Wanderer",
    "Evoker", "Evocation", "Abjuration", "Illusion", "Illusionist", "Abjurer", "Diviner", 
    "Light Domain", "Life Domain", "Trickery Domain", "War Domain",
    "Circle of the Moon", "Circle of Moon", "Circle of the Stars", "Circle of Stars", "Circle of the Land", "Circle of Land",
    "Berserker", "Zealot", "Path of the Totem",
    "The Fiend", "Great Old One", "The Celestial", "The Archfey",
    "Aberrant Mind", "Wild Magic", "Draconic Sorcerer","Draconic Sorcery","Draconic Bloodline", "Shadow Magic", "Clockwork Soul",
    "Open Hand", "Four Elements", "Way of Shadow","Way of Mercy",
    "Thief", "Assassin", "Arcane Trickster","Soulknife",
    "College of Lore", "College of Glamour", "College of Valor",
    "Oath of Vengeance", "Oath of the Ancients", "Oath of Devotion", "Oath of Glory"
]
excluded_casters = [
    "Arcane Trickster", 
    "Eldritch Knight"
]
excluded_counters = ["Ki", 
                     "Rage", 
                     "Bardic Inspiration",
                     "Warrior Of The Gods",
                     "Channel Divinity",
                     "Divine Intervention",
                     "Wild Resurgence",
                     "Natural Recovery",
                     "Second Wind",
                     "Action Surge",
                     "Indomitable",
                     "Superiority Dice",
                     "Know Your Enemy",
                     "Psionic Energy",
                     "Sorcery Points",
                     "Wild Shape",
                     "Wholeness of Body",
                     "Lay on Hands",
                     "Undying Sentinel",
                     "Elder Champion",
                     "Spell Thief",
                     "Stroke of Luck"
                     "Tides of Chaos",
                     "Sorcery Points",
                     "Misty Escape",
                     "Dark One's Luck",
                     "Entropic Ward",
                     "Dark Delirium",
                     "Hurl Through Hell",
                     "Eldritch Master",
                     "Arcane Recovery",
                     "Arcane Ward",
                     "Portents",
                     "Third Eye",
                     "Illusory Step",
                     "Cosmic Omen",
                     "Nature's Veil",
                     "Tireless",
                     "Mantle of Majesty",
                     "Unbreakable Majesty",
                     "Searing Vengeance"
                     ]

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
                        normalized_name = normalize_text(original_name)
                        item_key = (item.tag, normalized_name)

                        if item.tag == "class":
                            class_name = normalize_text(name.text)

                            if item_key in master_data:
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

                                            # Check if feature name matches any excluded subclass
                                            if any(normalize_text(subclass) in feature_text for subclass in excluded_subclasses):
                                                features_to_remove.append(feature)
                                            elif feature.get("optional") != "YES":
                                                features_to_remove.append(feature)

                                            # Remove feature if it starts with "Starting [class]" or "Multiclass [class]"
                                            if feature_text.startswith(f"starting {class_name}") or feature_text.startswith(f"multiclass {class_name}"):
                                                features_to_remove.append(feature)

                                    for feature in features_to_remove:
                                        autolevel.remove(feature)

                                    # Remove empty autolevels
                                    if len(autolevel.findall("feature")) == 0:
                                        item.remove(autolevel)

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
                                            if "pact boon" in feature_text:
                                                if re.match(r"pact boon: pact of the (blade|tome|chain)", feature_text):
                                                    features_to_remove.append(feature)
                                            if level < 3 and "pact boon" not in feature_text:
                                                autolevel.set("level", "3")

                            if class_name == "wizard":
                                for autolevel in list(item.findall("autolevel")):
                                    level = int(autolevel.get("level", "0"))
                                    for feature in autolevel.findall("feature"):
                                        feature_name = feature.find("name")
                                        if feature_name is not None and ("arcane tradition" in normalize_text(feature_name.text) or "school of" in normalize_text(feature_name.text) or "mage of" in normalize_text(feature_name.text) or "Bladesing" in normalize_text(feature_name.text) or "order of" in normalize_text(feature_name.text)) and level < 3:
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
                                        feature_text = feature.find("text")
                                        if feature_text is not None and feature_text.text.startswith("Replaces the "):
                                            autolevel.remove(feature)

                            updated = True

                        elif item.tag == "spell":
                            text = item.find("text")
                            classes = item.find("classes")
                            legacy_spell_classes = ["Eldritch Knight", "Arcane Trickster"]
                            if classes is not None:
                                original_classes = classes.text.split(",") if classes.text else []
                                updated_classes = []
                                for cls in original_classes:
                                    cls_cleaned = cls.strip()
                                    if cls_cleaned not in legacy_spell_classes:
                                        if cls_cleaned in base_classes:
                                            updated_classes.append(f"{cls_cleaned} [2024]")
                                        else:
                                            updated_classes.append(cls_cleaned)
                                classes.text = ", ".join(updated_classes)
                            if text is None:
                                if item_key not in master_data:
                                    updated = True
                            else:
                                if item_key in master_data:
                                    compendium.remove(item)
                                else:
                                    updated = True
                                
                        else:

                            if item_key in master_data:
                                compendium.remove(item)
                            updated = True

                if updated:
                    tree.write(file_path, encoding="utf-8", xml_declaration=True)

            except ET.ParseError as e:
                logging.error(f"XML parsing error in legacy file {file_path}: {e}")
