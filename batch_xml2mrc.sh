#! /bin/bash

#Convert all .xml files in a dir to .mrc and write to specified output folder

if [[ $# -eq 0 ]] ; then
    echo 'USAGE: batch_xml2mrc.sh SOURCE_DIR DESTINATION_DIR'
    exit 0
fi

SOURCE=$1
DESTINATION=$2
CONVERTER='./xml2marc.rb'

if [[ ! -d $SOURCE ]]; then
  echo "Source directory $SOURCE does not exist";
elif [[ ! -d $DESTINATION ]]; then
  echo "Destination directory $DESTINATION does not exist";
elif [[ ! -f $CONVERTER ]]; then
  echo "Helper script $CONVERTER not found"
fi

for filename in $SOURCE/*.xml; do
    bundle exec ruby $CONVERTER "$filename" > "$DESTINATION/$(basename "$filename" .xml).mrc"
done
