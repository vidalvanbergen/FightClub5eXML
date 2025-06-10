#!/bin/bash

# Remove '[2024]' from the compendium file (compatible with macOS/BSD sed)
remove_2024() {
  local file="$1"
  # Detect OS for sed -i compatibility
  echo "> Removing [2024] tags from: '$(basename "$1")'"
  if sed --version >/dev/null 2>&1; then
    # GNU sed (Linux)
    sed -i 's/ \[2024\]//g' "$file"
  else
    # BSD/macOS sed
    sed -i '' 's/ \[2024\]//g' "$file"
  fi
}

display_help() {
  cat <<EOF
Usage: $0 [-2024] [-h/-?] [collection_names...]

  -2024           Remove '[2024]' from the generated compendiums.
  -h, -?          Display this help message.
  collection_names  Optional list of specific collections to compile.

If no collection names are provided, all XML files in the 'Collections' directory will be processed.

Examples:
  $0
      Compile all collections.
  $0 -2024
      Compile all collections and remove '[2024]'.
  $0 collection1.xml
      Compile only 'collection1.xml'.
  $0 -2024 collection1.xml collection2.xml
      Compile specified collections and remove '[2024]'.
EOF
  exit 0
}

check_dependencies() {
  for cmd in xsltproc sed; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command '$cmd' not found. Please install it."
      exit 1
    fi
  done
}

compile_file() {
  local input_file="$1"
  local output_file="Compendiums/$(basename "$input_file")"

  echo "> Compiling: '$(basename "$input_file")'"
  if ! xsltproc --xinclude -o "$output_file" Utilities/merge.xslt "$input_file"; then
    echo "Error: Failed to compile '$input_file'" >&2
    return 1
  fi

  if [ "$REMOVE_2024" = true ]; then
    remove_2024 "$output_file"
  fi
}

# Initialize flags
REMOVE_2024=false

check_dependencies

mkdir -p Compendiums

# Parse arguments
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h|-?)
      display_help
      ;;
    -2024)
      REMOVE_2024=true
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

# Detects max number of CPUs for parallel jobs (or adjust as needed)
MAX_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu)

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

echo "> Compilation completed!"
