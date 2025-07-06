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

    # Find all image files in this subfolder and all subfolders (robust, explicit, correct grouping)
    IMAGE_FILES=()
    while IFS= read -r -d $'\0' file; do
        IMAGE_FILES+=("$file")
    done < <(find "$SUBFOLDER" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.tiff" -o -iname "*.svg" \) \
        -print0)

    # If there are image files, zip them as .cbz (preserve relative paths inside the zip, handle spaces)
    if [ ${#IMAGE_FILES[@]} -gt 0 ]; then
        CBZ_NAME="$TARGET_DIRECTORY/${BASENAME}.cbz"
        (cd "$SUBFOLDER" && \
            printf '%s\0' "${IMAGE_FILES[@]}" | xargs -0 -I{} realpath --relative-to="$SUBFOLDER" "{}" | zip -0 -r "$CBZ_NAME" -@
        )
        if [ $? -eq 0 ]; then
            echo "Zipped images to: $CBZ_NAME"
            # Delete the source image files
            for img in "${IMAGE_FILES[@]}"; do
                rm -f -- "$img"
            done
            echo "Deleted source images in $SUBFOLDER and subfolders."
        else
            echo "Error: Failed to zip images in $SUBFOLDER" >&2
        fi
    fi

    # Move video files in deeper subfolders to the first-level subfolder, prefixing with their relative path
    find "$SUBFOLDER" -mindepth 2 -type f \
        \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.webm" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.m4v" \) \
        -print0 | while IFS= read -r -d '' VIDEOFILE; do
        RELPATH="${VIDEOFILE#$SUBFOLDER/}"
        NEWNAME="${RELPATH//\//_}"
        DEST="$SUBFOLDER/$NEWNAME"
        mv "$VIDEOFILE" "$DEST"
        echo "Moved video $VIDEOFILE to $DEST"
    done

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

    # Recursively remove empty folders inside the subfolder (after zipping and moving files)
    while find "$SUBFOLDER" -type d -empty | grep -q .; do
        find "$SUBFOLDER" -type d -empty -delete
    done

done

echo "Done processing subfolders!"

# # Delete the script itself after execution
# echo "Deleting script: $0"
# rm -- "$0"

# Uncomment the above lines to delete the script itself after execution
