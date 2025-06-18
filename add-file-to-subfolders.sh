#!/bin/bash

# Define the source file name
SOURCE_FILE_NAME=".forcegallery"

# Use the directory where the script is executed as the target directory
TARGET_DIRECTORY=$(pwd)

# Define the full path to the source file
SOURCE_FILE="$TARGET_DIRECTORY/$SOURCE_FILE_NAME"

# Check if the source file exists; if not, create it
if [[ ! -f "$SOURCE_FILE" ]]; then
    touch "$SOURCE_FILE"
    echo "Created source file: $SOURCE_FILE"
fi

# Get only the first-level subdirectories in the target directory and loop safely
find "$TARGET_DIRECTORY" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' SUBFOLDER; do
    DESTINATION_PATH="$SUBFOLDER/$SOURCE_FILE_NAME"
    cp -f "$SOURCE_FILE" "$DESTINATION_PATH"
    echo "Copied file to: $DESTINATION_PATH"
done

echo "File added to first-level subfolders only!"

# Delete the top-level source file
rm -f "$SOURCE_FILE"
echo "Deleted source file: $SOURCE_FILE"

# Delete the script itself
SCRIPT_PATH=$(realpath "$0")
rm -f "$SCRIPT_PATH"
echo "Deleted script file: $SCRIPT_PATH"
