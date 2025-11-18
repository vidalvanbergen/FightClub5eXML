#!/bin/bash

# --- Help Function ---
print_help() {
  cat <<EOF
Usage: $0 <base_directory> [output_file]

Description:
  Combines all source-*.xml files from the specified base directory into a
  single collection XML file using XInclude references.

Arguments:
  <base_directory>   Required. Directory containing source-*.xml files.
  [output_file]      Optional. Output XML file path.
                     Default: <base_directory>/collection-<basename>.xml

Options:
  -h, --help         Show this help message and exit.

Example:
  $0 Sources_2024
  $0 Sources_2024 output/combined.xml
EOF
  exit 0
}

# --- Handle --help flag ---
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  print_help
fi

# --- Required: Base directory (e.g., Sources_2024) ---
BASE_DIR="$1"
if [[ -z "$BASE_DIR" ]]; then
  echo "Error: No base directory provided."
  echo "Use --help for usage information."
  exit 1
fi

# --- Optional: Output file ---
if [[ -n "$2" ]]; then
  OUTPUT_FILE="$2"
else
  base_name=$(basename "$BASE_DIR" | tr '[:upper:]' '[:lower:]')
  OUTPUT_FILE="${BASE_DIR%/}/collection-${base_name}.xml"
fi

# --- Temp File Handling ---
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# --- Process each source-*.xml file safely ---
find "$BASE_DIR" -type f -name 'source-*.xml' -print0 | while IFS= read -r -d '' file; do

  # Skip files whose path contains a # character
  if [[ "$file" == *'#'* ]]; then
    echo "Skipping $file: path contains '#'" >&2
    continue
  fi

  # Check if <collection> element exists in the file; skip if not
  has_collection=$(xmllint --xpath 'boolean(//collection)' "$file" 2>/dev/null)
  if [[ "$has_collection" != "true" ]]; then
    echo "Skipping $file: no <collection> element found." >&2
    continue
  fi

  pubdate=$(xmllint --xpath 'string(//source/pubdate)' "$file" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to extract pubdate from $file" >&2
  fi

  name=$(xmllint --xpath 'string(//source/name)' "$file" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to extract name from $file" >&2
  fi

  [[ -z "$name" ]] && name="UNKNOWN"
  name_escaped=$(echo "$name" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')

  href="${file#$BASE_DIR/}"

  if [[ -n "$pubdate" ]]; then
    pubdate_sort_key="$pubdate"
    xi_include_line="  <xi:include pubdate=\"$pubdate\" source=\"$name_escaped\" href=\"$href\" xpointer=\"xpointer(/source/collection/doc)\" />"
  else
    pubdate_sort_key="9999-12-31"
    xi_include_line="  <xi:include source=\"$name_escaped\" href=\"$href\" xpointer=\"xpointer(/source/collection/doc)\" />"
  fi

  printf "%s|%s\n" "$pubdate_sort_key" "$xi_include_line" >> "$TEMP_FILE"
done


# --- Write final XML output ---
{
  printf '<?xml version="1.0" encoding="utf-8" ?>\n'
  printf '<collection xmlns:xi="http://www.w3.org/2001/XInclude">\n'
  sort "$TEMP_FILE" | cut -d'|' -f2-
  printf '</collection>\n'
} > "$OUTPUT_FILE"

echo "> Done. Output saved to: $OUTPUT_FILE"
