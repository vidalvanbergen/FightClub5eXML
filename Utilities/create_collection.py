import os
import xml.etree.ElementTree as ET

# Configuration variables
SOURCE_DIR = "../Sources/WizardsOfTheCoast2024"  # Relative to the script's location
DEST_FILE_NAME = "WOTC_only_2024+Legacy.xml"  # Name of the destination collection file
DEST_FOLDER = "../Collections"  # Relative to the script's location

def create_single_collection_file(source_dir, dest_file_path):
    """
    Creates a single collection XML file containing all files in the source directory.
    :param source_dir: The root directory to scan for files.
    :param dest_file_path: The destination file path for the collection XML.
    """
    root = ET.Element("collection")
    
    for folder_path, _, files in os.walk(source_dir):
        # Get the folder's path relative to the source directory
        relative_folder_path = os.path.relpath(folder_path, start=source_dir)
        # Add a comment for the folder
        comment = ET.Comment(f"Files from {relative_folder_path}")
        root.append(comment)
        
        for file_name in files:
            file_path = os.path.join(folder_path, file_name)
            relative_file_path = os.path.relpath(file_path, start=source_dir)
            doc_element = ET.SubElement(root, "doc")
            doc_element.set("href", relative_file_path)
    
    # Write the collection file
    os.makedirs(os.path.dirname(dest_file_path), exist_ok=True)
    tree = ET.ElementTree(root)
    with open(dest_file_path, "wb") as f:
        tree.write(f, encoding="utf-8", xml_declaration=True)
    print(f"Collection file created: {dest_file_path}")

if __name__ == "__main__":
    # Resolve relative paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    source_dir = os.path.join(script_dir, SOURCE_DIR)
    dest_folder = os.path.join(script_dir, DEST_FOLDER)
    dest_file_path = os.path.join(dest_folder, DEST_FILE_NAME)
    
    print(f"Parsing source directory: {source_dir}")
    print(f"Saving collection file to: {dest_file_path}")
    create_single_collection_file(source_dir, dest_file_path)
    print("Collection file creation completed.")
