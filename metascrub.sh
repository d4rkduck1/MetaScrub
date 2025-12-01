#!/bin/zsh

# metascrub - Recursively strip metadata from files
# Usage: ./metascrub.sh <directory>
# Removes all EXIF/metadata. PDFs are fully rebuilt with Ghostscript.
# Requires: exiftool, ghostscript

# Default: current directory
DIR="${1:-.}"

# Check dependencies
for cmd in exiftool gs; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd not installed"
        echo "Install with: brew install exiftool ghostscript (macOS)"
        exit 1
    fi
done

# Verify directory exists
if [ ! -d "$DIR" ]; then
    echo "Directory not found: $DIR"
    exit 1
fi

echo "metascrub - Recursive metadata cleaning in: $DIR"
echo

# Count total files
total=$(find "$DIR" -type f ! -name '*_original' | wc -l | tr -d ' ')
current=0

echo "Found $total files to process"
echo

# Update progress bar
update_progress() {
    local filename="$1"
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    # Clear previous lines and display current file + progress
    printf "\033[2K\r%s\n" "$filename"
    printf "\033[2K\r[%s%s] %3d%% (%d/%d)\033[1A" "$(printf '#%.0s' $(seq 1 $filled))" "$(printf ' %.0s' $(seq 1 $empty))" $percent $current $total
}

# Process all files recursively
find "$DIR" -type f ! -name '*_original' -print0 | while IFS= read -r -d '' f; do
    ((current++))
    update_progress "Processing: $f"

    # Get lowercase extension
    ext="${f##*.}"
    ext="${ext:l}"

    case "$ext" in
        pdf)
            # Remove metadata
            exiftool -all= "$f" >/dev/null 2>&1

            # Delete backup
            [ -f "${f}_original" ] && rm -f "${f}_original"

            # Rebuild PDF with Ghostscript
            tmp="${f%.pdf}_clean.pdf"
            if gs -sDEVICE=pdfwrite \
                -dCompatibilityLevel=1.4 \
                -dPDFSETTINGS=/prepress \
                -dNOPAUSE -dBATCH \
                -dQUIET \
                -sOutputFile="$tmp" \
                "$f" >/dev/null 2>&1; then
                mv "$tmp" "$f"
            else
                [ -f "$tmp" ] && rm -f "$tmp"
            fi
            ;;

        *)
            # Remove metadata in-place
            exiftool -all= -overwrite_original "$f" >/dev/null 2>&1
            ;;
    esac
done

# Final progress update
printf "\033[2K\rCompleted\n"
printf "\033[2K\r[%s] 100%% (%d/%d)\n" "$(printf '#%.0s' {1..50})" $total $total

# Cleanup remaining backups
find "$DIR" -type f -name '*_original' -delete 2>/dev/null

echo
echo "Cleanup completed."
