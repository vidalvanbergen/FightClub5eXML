import os
import xml.etree.ElementTree as ET
from xml.dom import minidom

SOURCE_DIR = "../../Sources/PHB2014/WizardsOfTheCoast2024"
DEST_FILE_NAME = "WotC_only_2024+Legacy.xml"
DEST_FOLDER = "../../Collections"

def prettify_xml(elem):
    """Return a pretty-printed XML string for the Element."""
    rough_string = ET.tostring(elem, encoding="utf-8")
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")

def create_single_collection_file(source_dir, dest_file_path):
    root = ET.Element("collection")
    
    for folder_path, _, files in os.walk(source_dir):
        relative_folder_path = os.path.relpath(folder_path, start=os.path.dirname(source_dir))
        comment = ET.Comment(f"Files from /{relative_folder_path}")
        root.append(comment)

        for file_name in files:
            file_path = os.path.join(folder_path, file_name)
            relative_file_path = os.path.relpath(file_path, start=os.path.dirname(source_dir))
            doc_element = ET.SubElement(root, "doc")
            doc_element.set("href", f"../../Sources/PHB2014/{relative_file_path}")

    pretty_xml = prettify_xml(root)
    os.makedirs(os.path.dirname(dest_file_path), exist_ok=True)
    with open(dest_file_path, "w", encoding="UTF-8") as f:
        f.write(pretty_xml)
    print(f"Collection file created: {dest_file_path}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    source_dir = os.path.abspath(os.path.join(script_dir, SOURCE_DIR))
    dest_folder = os.path.abspath(os.path.join(script_dir, DEST_FOLDER))
    dest_file_path = os.path.join(dest_folder, DEST_FILE_NAME)

    create_single_collection_file(source_dir, dest_file_path)
