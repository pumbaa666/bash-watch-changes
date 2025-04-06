#!/bin/bash

################################################################################
# File: watch-image-in-folder.sh
# Description: A bash script to monitor changes in a specified folder and its
#              subfolders. It triggers the execution of a custom script named
#              resize-picture.sh for image files (jpg or png) created or edited,
#              excluding existing thumbnails located in paths containing "/tn/".
# Parameters :
#  - $1 rootFolder : The folder to watch
#  - $2 imageAHRefRoot : URL preceding the filename, used in the HTML output file
# Author: Pumbaa
# Date: 08.03.2024
################################################################################

rootFolder=$1
imageAHRefRoot=$2

# Check if inotifywait is installed
if ! [ -x "$(command -v inotifywait)" ]; then
  echo 'Error: inotifywait is not installed. Install it using "sudo apt-get install inotify-tools".' >&2
  exit 1
fi

# Check if resize-picture.sh script exists in the current directory
if [ ! -f "resize-picture.sh" ]; then
  echo "Error: resize-picture.sh script not found in the current directory."
  exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -el 1 ]; then
  echo "Usage: $0 <folder_to_watch> <image_reference_path:optional>"
  echo "image_reference_path can be an url, the filename will be concatenated after"
  exit 1
fi

# Check if the provided directory exists
if ! [ -d "$rootFolder" ]; then
  echo "Error: Folder '$rootFolder' does not exist."
  exit 1
fi


# Start monitoring the specified folder and its subfolders for create, modify, and delete events
inotifywait -m -r -e create -e modify -e delete "$rootFolder" --format '%w%f' |
while read -r file; do
  # Check if the file is a jpg or png image
  if [[ "$file" =~ \.jpg$ ]] || [[ "$file" =~ \.jpeg$ ]] || [[ "$file" =~ \.png$ ]]; then
  
    # Don't resize thumbnails
    if [[ "$file" != *"/tn/"* ]]; then

        # Run the resize-picture.sh script for folder containing images
        rootFolder=$(dirname "$file")
        ./resize-picture.sh "$rootFolder" $imageAHRefRoot &
    fi
  fi
done
