#!/bin/bash
# Resize all images in this directory that have changed, and put them in the output directory

INPUT_DIR="."
OUTPUT_DIR="../images"

for image in "$INPUT_DIR"/*.jpg; do
    bname=`basename "$image"`
    output="$OUTPUT_DIR/$bname"

    # Don't update files which don't need to be touched
    if [[ -e $output ]]; then
    	if [[ $image -ot $output ]]; then
            continue
        fi
    fi
    set -v
    mogrify -resize 800x600 -path "$OUTPUT_DIR" "$image"
    set +v
done

