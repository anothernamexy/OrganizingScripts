#!/bin/bash

# Get the path of the directory where the script is located
script_directory=$(dirname "$0")

# Loop through all files in the directory with the naming scheme {str}{int}.{ext}
for file in "$script_directory"/*.*; do
    filename=$(basename "$file")
    if [ "$filename" != "$0" ]; then
        # Extract the string, integer, and extension from the filename
        str=$(echo "$filename" | sed -n 's/\([a-zA-Z]*\)\([0-9]\+\)\.\(.*\)/\1/p')
        int=$(echo "$filename" | sed -n 's/\([a-zA-Z]*\)\([0-9]\+\)\.\(.*\)/\2/p')
        ext=$(echo "$filename" | sed -n 's/\([a-zA-Z]*\)\([0-9]\+\)\.\(.*\)/\3/p')

        # Check if the string part is not empty and integer part is numeric
        if [ ! -z "$str" ] && [[ $int =~ ^[0-9]+$ ]]; then
            # Create the subfolder if it doesn't exist
            subfolder_path="$script_directory/$str"
            mkdir -p "$subfolder_path"

            # Move the file to the subfolder
            mv "$file" "$subfolder_path"
        fi
    fi
done

echo "Files have been organized into subfolders."