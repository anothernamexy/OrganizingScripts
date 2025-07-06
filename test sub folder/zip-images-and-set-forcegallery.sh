#!/bin/bash

# Supported image and video extensions
IMAGE_EXTENSIONS="jpg jpeg png gif bmp webp tiff svg"
VIDEO_EXTENSIONS="mp4 mov avi mkv webm flv wmv m4v"

# Use the directory where the script is executed as the target directory
TARGET_DIRECTORY=$(pwd)

# Get only the first-level subdirectories in the target directory and loop safely
find "$TARGET_DIRECTORY" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' SUBFOLDER; do
    BASENAME=$(basename "$SUBFOLDER")

    # Backup the subfolder as .tar.gz (do not overwrite existing backups)
    BACKUP_ARCHIVE="$TARGET_DIRECTORY/${BASENAME}.tar.gz"
    if [ -e "$BACKUP_ARCHIVE" ]; then
        echo "Backup already exists: $BACKUP_ARCHIVE, skipping backup."
    else
        tar -czf "$BACKUP_ARCHIVE" -C "$TARGET_DIRECTORY" "$BASENAME"
        if [ $? -eq 0 ]; then
            echo "Created backup: $BACKUP_ARCHIVE"
        else
            echo "Error: Failed to create backup for $SUBFOLDER" >&2
        fi
    fi

    # Find image files in the subfolder
    IMAGE_FILES=()
    for ext in $IMAGE_EXTENSIONS; do
        while IFS= read -r -d $'\0' file; do
            IMAGE_FILES+=("$file")
        done < <(find "$SUBFOLDER" -maxdepth 1 -type f \( -iname "*.$ext" \) -print0)
    done

    # If there are image files, zip them (name after subfolder)
    if [ ${#IMAGE_FILES[@]} -gt 0 ]; then
        ZIP_NAME="$SUBFOLDER/${BASENAME}.zip"
        zip -j -0 "$ZIP_NAME" "${IMAGE_FILES[@]}"
        if [ $? -eq 0 ]; then
            echo "Zipped images to: $ZIP_NAME"
        else
            echo "Error: Failed to zip images in $SUBFOLDER" >&2
        fi
    fi

    # Check for video files and create .forcegallery if found
    VIDEO_FOUND=0
    for ext in $VIDEO_EXTENSIONS; do
        if find "$SUBFOLDER" -maxdepth 1 -type f -iname "*.$ext" | grep -q .; then
            VIDEO_FOUND=1
            break
        fi
    done
    if [ $VIDEO_FOUND -eq 1 ]; then
        FORCEGALLERY_PATH="$SUBFOLDER/.forcegallery"
        touch "$FORCEGALLERY_PATH"
        echo "Created .forcegallery in $SUBFOLDER"
    fi

done

echo "Done processing subfolders!"
