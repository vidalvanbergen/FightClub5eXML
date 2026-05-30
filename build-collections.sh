#!/bin/bash

# Remove '[5.5e]' from the compendium file
remove_version_tag() {
  local infile="$1"
  local outfile="$2"

  if [ -z "$outfile" ]; then
    # In-place edit
    if sed --version >/dev/null 2>&1; then
      sed -i 's/ \[5.5e\]//g' "$infile" # GNU sed (Linux)
    else
      sed -i '' 's/ \[5.5e\]//g' "$infile" # BSD/macOS sed
    fi
  else
    # In-memory stream to output
    if sed --version >/dev/null 2>&1; then
      sed 's/ \[5.5e\]//g' "$infile" > "$outfile" # GNU sed (Linux)
    else
      sed -e 's/ \[5.5e\]//g' "$infile" > "$outfile" # BSD/macOS sed
    fi
  fi

  echo "> Created: '$(basename "$outfile")'" >&2
}

display_help() {
  cat <<EOF
Usage: $0 [-5.5e] [--validate] [-h/-?/--help] [collection_names...]

  -5.5e             Remove '[5.5e]' from the generated compendiums.
  --validate        Validate output XML against the schema (disabled by default).
  -h, -?, --help    Display this help message.
  collection_names  Optional list of specific collections to compile.

If no collection names are provided, all XML files in the 'Collections' directory will be processed.

Examples:
  $0
      Compile all collections.
  $0 -5.5e
      Compile all collections and remove '[5.5e]'.
  $0 --validate
      Compile all collections and validate them.
  $0 collection1.xml
      Compile only 'collection1.xml'.
  $0 -5.5e collection1.xml collection2.xml
      Compile specified collections and remove '[5.5e]'.
EOF
  exit 0
}

check_dependencies() {
  for cmd in xsltproc sed; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "❌ Required command '$cmd' not found. Please install it." >&2
      exit 1
    fi
  done
}

compile_file() {
  local input_file="$1"
  local base_name
  base_name="$(basename "$input_file")"
  local output_file="Compendiums/$base_name"

  # echo "> Compiling: '$base_name'"
  if ! xsltproc --xinclude -o "$output_file" Utilities/merge.xslt "$input_file"; then
    echo "❌ Error: Failed to compile '$input_file'" >&2
    return 1
  else
    echo "> Created: '$base_name'" >&2
  fi

  if [ "$REMOVE_VERSION_TAG" = true ]; then
    remove_version_tag "$output_file"
  fi

  if [ "$VALIDATE" = true ]; then
    echo "> Validating: '$base_name'"
    if ! xmllint --noout --schema Utilities/compendium.xsd "$output_file"; then
      echo "❌ Validation failed for '$output_file'" >&2
      return 1
    fi
  fi

  # If filename contains 5.5e but not 5e, create [UNTAGGED] version without [5.5e]
  if [[ "$REMOVE_VERSION_TAG" = false && "$base_name" == *_5.5e* ]]; then
    local untagged_name="${base_name%.xml}_[UNTAGGED].xml"
    local untagged_file="Compendiums/$untagged_name"

    # echo " > Creating untagged version: '$untagged_name'"
    remove_version_tag "$output_file" "$untagged_file"

    if [ "$VALIDATE" = true ]; then
      echo " > Validating: '$untagged_name'"
      if ! xmllint --noout --schema Utilities/compendium.xsd "$untagged_file"; then
        echo "❌ Validation failed for '$untagged_file'" >&2
        return 1
      fi
    fi
  fi
}

# Initialize flags
REMOVE_VERSION_TAG=false
VALIDATE=false

check_dependencies

mkdir -p Compendiums

# Parse arguments
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h|-?|--help)
      display_help
      ;;
    -5.5e)
      REMOVE_VERSION_TAG=true
      shift
      ;;
    --validate)
      VALIDATE=true
      shift
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [ "${#ARGS[@]}" -eq 0 ]; then
  # No collection names provided, process all XML files
  shopt -s nullglob
  files=(Collections/*.xml)
  if [ "${#files[@]}" -eq 0 ]; then
    echo "No XML files found in Collections directory." >&2
    exit 1
  fi
else
  # Process only provided collection names
  files=()
  for f in "${ARGS[@]}"; do
    path="Collections/$f"
    if [ ! -f "$path" ]; then
      echo "Warning: File '$path' does not exist, skipping." >&2
      continue
    fi
    files+=("$path")
  done

  if [ "${#files[@]}" -eq 0 ]; then
    echo "No valid files to process." >&2
    exit 1
  fi
fi

# Detect max number of CPUs for parallel jobs (fallback if unavailable)
MAX_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu)

echo "Starting compilation using $MAX_JOBS cores."

# Function to control parallel jobs
wait_for_jobs() {
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ]; do
    sleep 0.1
  done
}

# Compile each file in parallel with job limit
for f in "${files[@]}"; do
  wait_for_jobs
  compile_file "$f" &
done

wait # Wait for all background jobs to finish

echo "Compilation completed!"
