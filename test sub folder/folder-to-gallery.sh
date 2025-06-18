#!/bin/bash

# Use the directory where the script is executed as the target directory
TARGET_DIRECTORY=$(pwd)

# Get only the first-level subdirectories in the target directory and loop safely
find "$TARGET_DIRECTORY" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' SUBFOLDER; do
    zip -0 -r "${SUBFOLDER}.zip" "$SUBFOLDER"
    if [ $? -eq 0 ]; then
        echo "Zipped folder to: ${SUBFOLDER}.zip"
        rm -r -- "$SUBFOLDER"
        echo "Deleted source dir: $SUBFOLDER"
    else
        echo "Error: Failed to zip $SUBFOLDER. Skipping deletion." >&2
    fi
done

# Delete the script itself
SCRIPT_PATH=$(realpath "$0")
rm -f "$SCRIPT_PATH"
echo "Deleted script file: $SCRIPT_PATH"

# Uncomment the above lines to delete the script itself after execution
