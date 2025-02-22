#!/bin/bash

# Function to remove '[2024]' from the compendium
remove_2024() {
sed -i 's/ \[2024\]//g' "$1"
}

# Function to display help text
display_help() {
  echo "Usage: $0 [-2024] [-h/-?] [collection_names...]"
  echo ""
  echo "  -2024   Remove '[2024]' from the generated compendiums."
  echo "  -h/-?   Display this help message."
  echo "  collection_names  Optional list of specific collections to compile."
  echo ""
  echo "If no collection names are provided, all XML files in the 'Collections' directory will be processed."
  echo "Examples:"
  echo "  $0                Compile all collections."
  echo "  $0 -2024          Compile all collections and remove '[2024]'."
  echo "  $0 collection1.xml  Compile only 'collection1.xml'."
  echo "  $0 -2024 collection1.xml collection2.xml  Compile 'collection1.xml' and 'collection2.xml' and remove '[2024]'."
  exit 0 # Exit after displaying help
}

cd Collections

if [ $# -eq 0 ]; then
  # If no arguments are provided, process all XML files
  for i in *.xml; do
    echo "> Compiling: '$i'"
    xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
  done
else
  # Check for help flags
  if [ "$1" = "-h" ] || [ "$1" = "-?" ]; then
    display_help
  # Check for the -2024 flag
  elif [ "$1" = "-2024" ]; then
    shift # Remove the flag from the arguments
    if [ $# -eq 0 ]; then
      # If no further arguments, process all XML files with -2024
      for i in *.xml; do
        echo "> Compiling (with -2024): '$i'"
        xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
        remove_2024 "../Compendiums/$i"
      done
    else
      # Process the remaining arguments as compendium names with -2024
      for i in "$@"; do
        echo "> Compiling (with -2024): '$i'"
        xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
        remove_2024 "../Compendiums/$i"
      done
    fi
  else
    # If -2024 or help flags are not provided, process the arguments as compendium names
    for i in "$@"; do
      echo "> Compiling: '$i'"
      xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
    done
  fi
fi

echo "> Compilation completed!"