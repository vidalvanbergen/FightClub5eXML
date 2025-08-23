# XML Schema and Content Management Tools

This directory contains XML schemas, XSLT transformations, and scripts used to manage, validate, and convert source content collections and compendiums for different D&D 5e rulesets.

---

## Files Overview

### Schemas

- **`collection.xsd`**  
  XML Schema Definition file that validates individual XML files inside the `collection/` directory. Ensures that each partial source XML adheres to the expected structure.

- **`compendium.xsd`**  
  XML Schema Definition file used to validate compiled compendium files. This includes the fully merged `compendium.xml` as well as partial compendium files such as `bestiary.xml`, `items.xml`, `spells.xml`, and `classes.xml`.

---

### Transformation

- **`merge.xslt`**  
  An XSLT stylesheet that merges a `collection.xml` file (which contains references to partial XML source files) into a single, comprehensive `compendium.xml`. This step consolidates all partial content into one file usable by compatible apps.

---

### Scripts

- **`source-xml-collector.sh`**  
  Bash script that recursively scans directories for `source-*.xml` files and generates a partial `collection.xml` file listing those source XML files. This helps automate the creation of collection manifests.

- **`convert-legacy-content.py`**  
  Python script that copies and converts content from the PHB2014 ruleset sources to be compatible with the PHB2024 ruleset. Useful for migrating legacy content to the latest ruleset.

- **`create_collection.py`**  
  Python script that likely creates or updates collection XML files, helping organize or generate collections based on source directories.

- **`update-legacy-content.py`**  
  Python script probably used to update or patch legacy content files to maintain compatibility or apply fixes.

---

## Usage Examples

### Validate a collection XML file

```bash
xmllint --noout --xinclude --schema collection.xsd collection/my_source.xml
```

### Validate a compiled or partial compendium XML file

```bash
xmllint --noout --schema compendium.xsd Compendiums/compendium.xml
```

or for partial files like:

```bash
xmllint --noout --schema compendium.xsd Source/bestiary.xml
```

### Merge a collection into a compendium

```bash
xsltproc --xinclude merge.xslt collection/collection.xml > Compendiums/compendium.xml
```

### Generate a collection.xml manifest from source directories

```bash
./source-xml-collector.sh Sources/phb2014 > collection/collection_phb2014.xml
```

---

## Notes

- Replace paths in the commands above according to your repository structure.
- These tools are designed to streamline managing and migrating XML source content between different ruleset versions.
- For more detailed script options, run them with `-h` or `--help` flags if available.
