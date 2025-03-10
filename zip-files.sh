#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title zip files
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🍿
# @raycast.argument1 { "type": "text", "placeholder": "Folder name" }

# Documentation:
# @raycast.author Kimura

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Get the current folder path using osascript
BASE_PATH=$(osascript -e 'tell application "Finder" to get POSIX path of (target of front window as alias)') || handle_error "Unable to retrieve the current folder path"
DESKTOP_PATH=$(osascript -e 'tell application "Finder" to get POSIX path of (path to desktop folder)')

echo "🚀 Starting zip creation process..."
echo "📍 Working in: $BASE_PATH"

# Check if we're in a path containing the project folder
if [[ "$BASE_PATH" != *"2024-"* ]]; then
    handle_error "You must be in a 2024-* project folder"
fi

# Find EMAIL or EMAILS directory
if [ -d "$BASE_PATH/EMAIL" ]; then
    EMAIL_DIR="$BASE_PATH/EMAIL"
elif [ -d "$BASE_PATH/EMAILS" ]; then
    EMAIL_DIR="$BASE_PATH/EMAILS"
else
    handle_error "Neither EMAIL nor EMAILS directory found. Please make sure you are in the correct project folder."
fi

# Project configuration
PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
    handle_error "Please provide a folder name as argument"
fi

# Check if delivery directory exists and rename it with current date and time
DELIVERY_DIR="$BASE_PATH/delivery"
if [ -d "$DELIVERY_DIR" ]; then
    # Get current date and time in the format DDMMHH
    CURRENT_DATE=$(date +"%d%m%H%M")
    OLD_DELIVERY_DIR="$DELIVERY_DIR-$CURRENT_DATE"
    echo "⚠️ Delivery directory already exists. Renaming to delivery-$CURRENT_DATE..."
    mv "$DELIVERY_DIR" "$OLD_DELIVERY_DIR" || handle_error "Failed to rename existing delivery directory"
fi

# Function to create zip
create_zip() {
    local html_file=$1
    local type=$2
    local subfolder=$3
    
    # Extract name without "Zone_" prefix
    local name=$(basename "$html_file" .html | sed 's/Zone_//')
    local zip_name="${name}-${PROJECT_NAME}-${type}.zip"
    
    echo "📦 Creating $zip_name..."
    
    local images_dir="$(dirname "$html_file")/images"
    local temp_zip="$DESKTOP_PATH/$zip_name"
    
    # Create zip with images first
    if [ -d "$images_dir" ]; then
        (cd "$(dirname "$images_dir")" && zip -r "$temp_zip" "images") || handle_error "Failed to add images folder to zip for $zip_name"
    fi
    
    # Add HTML file to zip
    (cd "$(dirname "$html_file")" && zip -j "$temp_zip" "$(basename "$html_file")") || handle_error "Failed to add HTML file to zip for $zip_name"
    
    # Remove .db files if they exist
    if zipinfo -1 "$temp_zip" | grep -q '\.db$'; then
        zip -d "$temp_zip" "*.db" > /dev/null 2>&1
    fi
    
    echo "✅ Created $zip_name"
}

# Function to process a specific email type directory
process_email_dir() {
    local base_dir=$1
    local type=$2
    local subfolder=$3
    local delivery_dir="$BASE_PATH/delivery"
    
    # Add subfolder to delivery path if it exists
    if [ ! -z "$subfolder" ]; then
        delivery_dir="$delivery_dir/$subfolder"
    fi
    
    # Create delivery directory only if the source directory exists
    if [ -d "$base_dir" ]; then
        # Create the appropriate html subdirectory based on type
        local html_subdir="html_regular"
        if [ "$type" = "Specialists" ]; then
            html_subdir="html_specialists"
        fi
        
        mkdir -p "$delivery_dir/$html_subdir"
        echo "🔄 Processing ${type} emails in ${base_dir}..."
        
        # Process each HTML file
        while IFS= read -r html_file; do
            create_zip "$html_file" "$type" "$subfolder"
        done < <(find "$base_dir" -name "Zone_*.html" -not -name "*Shared*")
        
        # Move all ZIP files for this type to the appropriate delivery directory
        echo "🚚 Moving ZIP files to delivery directory..."
        mv "$DESKTOP_PATH"/*-${type}.zip "$delivery_dir/$html_subdir/" 2>/dev/null || true
    else
        echo "⚠️ Skipping ${type} emails - directory not found: ${base_dir}"
    fi
}

# First, check if we have direct html folders or subfolders
if [ -d "$EMAIL_DIR/html_regular" ] || [ -d "$EMAIL_DIR/html_specialists" ]; then
    echo "📁 Found direct html folders structure"
    # Create base delivery directory
    mkdir -p "$BASE_PATH/delivery"
    
    [ -d "$EMAIL_DIR/html_regular" ] && process_email_dir "$EMAIL_DIR/html_regular" "Regular"
    [ -d "$EMAIL_DIR/html_specialists" ] && process_email_dir "$EMAIL_DIR/html_specialists" "Specialists"
else
    echo "📁 Found nested folders structure"
    # Process each subfolder
    for subfolder in "$EMAIL_DIR"/*/ ; do
        if [ -d "$subfolder" ]; then
            subfolder_name=$(basename "$subfolder")
            echo "📂 Processing subfolder: $subfolder_name"
            
            # Create the main delivery directory for this subfolder
            mkdir -p "$BASE_PATH/delivery/$subfolder_name"
            
            # Process regular emails if they exist
            if [ -d "$subfolder/html_regular" ]; then
                echo "  📁 Processing regular emails in $subfolder_name"
                process_email_dir "$subfolder/html_regular" "Regular" "$subfolder_name"
            fi
            
            # Process specialists emails if they exist
            if [ -d "$subfolder/html_specialists" ]; then
                echo "  📁 Processing specialists emails in $subfolder_name"
                process_email_dir "$subfolder/html_specialists" "Specialists" "$subfolder_name"
            fi
        fi
    done
fi

echo "✨ All done! ZIP files have been created and moved successfully!"