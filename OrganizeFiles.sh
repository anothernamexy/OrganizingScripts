#!/bin/bash

scriptDirectory="$(dirname "$(realpath "$0")")"

for f in "$scriptDirectory"/*.*; do
    filename="$(basename "$f")"
    # Skip the script itself
    if [[ "$filename" == "$(basename "$0")" ]]; then
        continue
    fi

    # Extract string, integer, and extension using regex
    if [[ "$filename" =~ ^([a-zA-Z]+)([0-9]+)\.(.+)$ ]]; then
        str="${BASH_REMATCH[1]}"
        int="${BASH_REMATCH[2]}"
        ext="${BASH_REMATCH[3]}"

        # Create subfolder if it doesn't exist
        subfolderPath="$scriptDirectory/$str"
        mkdir -p "$subfolderPath"

        # Move the file
        mv "$f" "$subfolderPath/"
    fi
done

echo "Files have been organized into subfolders."