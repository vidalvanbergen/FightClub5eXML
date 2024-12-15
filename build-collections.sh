#!/bin/bash

cd Collections

if [ $# -eq 0 ]; then
  # If no arguments are provided, process all XML files
  for i in *.xml; do
    echo "> Compiling: '$i'"
    xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
  done
else
  # If arguments are provided, process only those files
  for i in "$@"; do
    echo "> Compiling: '$i'"
    xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt "$i"
  done
fi

echo "> Compilation completed!"