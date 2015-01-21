#/usr/bin/env zsh

# Organize photos/movies into folders based on the date they were taken

# usage: exiftools_sort_by_date $source_directory $target_directory
#
# this will find all photos within the $source_directory and create a folder
# 'dates' inside $target_directory. Each photo will be moved into a folder
# inside the 'dates' folder which will be named 'yyyymmdd', based on the
# CreateDate set in the EXIF data of the photo/movie file

echo "Running $(basename $0)"

# requires perl
if [[ ! $(command -v perl) ]]; then
  echo "perl is required but it's not installed. Aborting."
  exit 1
fi

# requires exiftool
if [[ ! $(command -v exiftool) ]]; then
  echo "exiftool is required but not installed. Aborting."
  exit 1
fi

if [[ $# -ne 2 ]]; then
  exit 1
fi

source_directory=$(readlink -ev $1)
target_directory=$(readlink -ev $2)

for file in $source_directory/*; do
  if [[ -f $file ]]; then

    echo "Processing $file"
    create_date=$(exiftool -CreateDate "$file")
    regex="([0-9]{4})\:([0-9]{2})\:([0-9]{2})"

    ## If create_date matches regex
    if [[ $create_date =~ $regex ]]; then

      create_date=$(echo $create_date | perl -ne 'print "$1$2$3" if /(\d{4}):(\d{2}):(\d{2})/')
      date_directory="$target_directory/$create_date"
      mkdir -p $date_directory
      mv $file $date_directory

    else
      echo "CreateDate doesn't match %YYYY:%MM:%DD: skipping $file"
    fi

  fi
done
