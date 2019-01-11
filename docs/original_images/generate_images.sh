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
    echo "Updating $bname"
    mogrify -resize 800x600 -path "$OUTPUT_DIR" "$image"
done

# Clean up files that don't have an original any more
for image in "$OUTPUT_DIR"/*.jpg; do
    bname=`basename "$image"`
    if [[ ! -e "$INPUT_DIR/$bname" ]]; then
        echo "removing $bname"
        rm "$image"
    fi
done

