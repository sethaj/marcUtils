#! /bin/bash

#Transform all .xml files in a dir using a specified stylesheet and write to specified output folder

if [[ $# -eq 0 ]] ; then
    echo 'USAGE: batch_transformXML.sh STYLESHEET SOURCE_DIR DESTINATION_DIR'
    exit 0
fi

STYLESHEET=$1
SOURCE=$2
DESTINATION=$3


if [[ ! -d $SOURCE ]]; then
  echo "Source directory $SOURCE does not exist";
elif [[ ! -d $DESTINATION ]]; then
  echo "Destination directory $DESTINATION does not exist";
elif [[ ! -f $STYLESHEET ]]; then
  echo "XSLT stylesheet $STYLESHEET not found"
fi

for filename in $SOURCE/*.xml; do
    xsltproc $STYLESHEET "$filename" > "$DESTINATION/$(basename "$filename")"
done
