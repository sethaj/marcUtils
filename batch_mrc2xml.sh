#! /bin/bash

#Convert all .mrc files in dir a to .xml and write to specified output folder

if [[ $# -eq 0 ]] ; then
    echo 'USAGE: batch_mrc2xml.sh SOURCE_DIR DESTINATION_DIR'
    exit 0
fi

SOURCE=$1
DESTINATION=$2
CONVERTER='./marc2xml.pl'

if [[ ! -d $SOURCE ]]; then
  echo "Source directory $SOURCE does not exist";
elif [[ ! -d $DESTINATION ]]; then
  echo "Destination directory $DESTINATION does not exist";
elif [[ ! -f $CONVERTER ]]; then
  echo "Helper script $CONVERTER not found"
fi

for filename in $SOURCE/*.mrc; do
    perl $CONVERTER "$filename" > "$DESTINATION/$(basename "$filename" .mrc).xml"
done
