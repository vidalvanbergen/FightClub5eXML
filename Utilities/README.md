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

- **`generate-partial-collection.sh`**  
  Bash script that recursively scans directories for `source-*.xml` files and generates a partial `collection.xml` file listing those source XML files. Main collection files reference these partial collections so sources can be updated in one place without duplication.

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

### Generate a collection xml for source directories

```bash
./generate-partial-collection.sh Sources/PHB2014/Homebrew/
```

---

## Notes

- Replace paths in the commands above according to your repository structure.
- These tools are designed to streamline managing and migrating XML source content between different ruleset versions.
- For more detailed script options, run them with `-h` or `--help` flags if available.
