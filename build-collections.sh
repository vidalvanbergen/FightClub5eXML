cd Collections
for i in *.xml
do
  echo "> Compiling: '$i'"
  xsltproc -o ../Compendiums/$i ../Utilities/merge.xslt $i;
done
echo "> Compilation completed!"