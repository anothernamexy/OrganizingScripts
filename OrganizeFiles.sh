#!/bin/bash

scriptDirectory="$(dirname "$(realpath "$0")")"

find "$scriptDirectory" -type f | while read -r f; do
    filename="$(basename "$f")"
    dir="$(dirname "$f")"
    # Skip the script itself
    if [[ "$filename" == "$(basename "$0")" ]]; then
        continue
    fi
    # Skip if .forcegallery exists in the current directory
    if [[ -f "$dir/.forcegallery" ]]; then
        continue
    fi
    # Extract string, integer, and extension using regex
    if [[ "$filename" =~ ^([a-zA-Z]+)([0-9]+)\.(.+)$ ]]; then
        str="${BASH_REMATCH[1]}"
        int="${BASH_REMATCH[2]}"
        ext="${BASH_REMATCH[3]}"
        # Create subfolder if it doesn't exist
        subfolderPath="$dir/$str"
        if [[ ! -d "$subfolderPath" ]]; then
            mkdir -p "$subfolderPath"
            touch "$subfolderPath/.forcegallery"
        fi
        # Move the file
        mv "$f" "$subfolderPath/"
    fi

done

echo "Files have been organized into subfolders."