#!/bin/bash

# This script recursively matches files with naming scheme {str0}loop{str1} (case-insensitive 'loop')
# to files with naming scheme {str0}{str2} (same extension, str1 and str2 do not have to match).
# Moves both files to a subfolder named after lowercase {str0}, creates .forcegallery, and skips directories with .forcegallery.

shopt -s nocaseglob
find . -type f -iname "*loop*" | while read -r loopfile; do
    dir="$(dirname "$loopfile")"
    # Skip if .forcegallery exists in the current directory
    if [[ -f "$dir/.forcegallery" ]]; then
        continue
    fi
    filename="$(basename -- "$loopfile")"
    ext="${filename##*.}"
    # Extract str0 and str1 using regex (case-insensitive 'loop')
    if [[ "$filename" =~ ^(.*)[Ll][Oo][Oo][Pp](.*)\.(.*)$ ]]; then
        str0="${BASH_REMATCH[1]}"
        str1="${BASH_REMATCH[2]}"
        ext="${BASH_REMATCH[3]}"
        foldername="$(echo "$str0" | tr '[:upper:]' '[:lower:]')"
        # Find any file in the same directory with same str0 and extension, but without 'loop' after str0
        for candidate in "$dir/${str0}"*".${ext}"; do
            candidatebase="$(basename -- "$candidate")"
            # Skip if candidate is the loopfile or contains 'loop' after str0
            if [[ "$candidate" == "$loopfile" ]]; then
                continue
            fi
            if [[ "$candidatebase" =~ ^${str0}[Ll][Oo][Oo][Pp] ]]; then
                continue
            fi
            if [[ -f "$candidate" ]]; then
                targetdir="$dir/$foldername"
                if [[ -f "$targetdir/.forcegallery" ]]; then
                    continue
                fi
                mkdir -p "$targetdir"
                mv "$loopfile" "$targetdir/"
                mv "$candidate" "$targetdir/"
                touch "$targetdir/.forcegallery"
                break
            fi
        done
    fi

done
shopt -u nocaseglob