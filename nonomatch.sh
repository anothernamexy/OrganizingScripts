#!/bin/bash

# This script matches files with naming scheme {str0}no{str1} and {str0}{str1} (str1 must match exactly, case-sensitive)
# Moves both files to a subfolder named after lowercase {str0}, creates .forcegallery, and skips directories with .forcegallery.

shopt -s nocaseglob
find . -type f -iname "*no*" | while read -r nofile; do
    dir="$(dirname "$nofile")"
    if [[ -f "$dir/.forcegallery" ]]; then
        continue
    fi
    filename="$(basename -- "$nofile")"
    ext="${filename##*.}"
    # Extract str0 and str1 using regex (case-sensitive 'no')
    if [[ "$filename" =~ ^(.*)no(.*)\.(.*)$ ]]; then
        str0="${BASH_REMATCH[1]}"
        str1="${BASH_REMATCH[2]}"
        ext="${BASH_REMATCH[3]}"
        foldername="$(echo "$str0" | tr '[:upper:]' '[:lower:]')"
        # Look for file with same str0 and str1 and extension, but without 'no' in the name
        candidate="$dir/${str0}${str1}.${ext}"
        if [[ -f "$candidate" && "$candidate" != "$nofile" ]]; then
            targetdir="$dir/$foldername"
            if [[ -f "$targetdir/.forcegallery" ]]; then
                continue
            fi
            mkdir -p "$targetdir"
            mv "$nofile" "$targetdir/"
            mv "$candidate" "$targetdir/"
            touch "$targetdir/.forcegallery"
        fi
    fi

done
shopt -u nocaseglob
