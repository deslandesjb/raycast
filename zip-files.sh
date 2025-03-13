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
BASE_PATH=$(osascript -e 'tell application "Finder" to get POSIX path of (target of front window as alias)') || handle_error "Unable to retrieve the current folder path. Please make sure you have a Finder window open in your project folder."
DESKTOP_PATH=$(osascript -e 'tell application "Finder" to get POSIX path of (path to desktop folder)')

echo "🚀 Starting zip creation process..."
echo "📍 Working in: $BASE_PATH"

# Check if we're in a 202X- project folder
if ! [[ "$BASE_PATH" =~ /(202[4-9]|20[3-9][0-9])-.*$ ]]; then
    handle_error "You must be in a project folder starting with 2024 or later (example: 2024-, 2025-, etc.). Current path: $BASE_PATH"
fi

# Find EMAIL or EMAILS directory
EMAIL_DIR=""
if [ -d "$BASE_PATH/EMAIL" ]; then
    EMAIL_DIR="$BASE_PATH/EMAIL"
elif [ -d "$BASE_PATH/EMAILS" ]; then
    EMAIL_DIR="$BASE_PATH/EMAILS"
else
    handle_error "Neither EMAIL nor EMAILS directory found in $BASE_PATH. Please make sure you are in the correct project folder with an EMAIL or EMAILS directory."
fi

# Check for the existence of at least one html_regular or html_specialists directory
if ! find "$EMAIL_DIR" -type d -name "html_regular" -o -name "html_specialists" | grep -q .; then
    handle_error "No html_regular or html_specialists directories found in the EMAIL(S) structure at $EMAIL_DIR. Please verify your folder structure."
fi

# Verify if project name is provided as argument
PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
    handle_error "Please provide a folder name as argument. Usage: zip-files <folder-name>"
fi

# Create delivery directory with increment if necessary
DELIVERY_DIR="$(dirname "$EMAIL_DIR")/delivery"
FINAL_DELIVERY_DIR="$DELIVERY_DIR"

if [ -d "$DELIVERY_DIR" ]; then
    counter=1
    while [ -d "${DELIVERY_DIR}-$(printf "%02d" $counter)" ]; do
        counter=$((counter + 1))
    done
    FINAL_DELIVERY_DIR="${DELIVERY_DIR}-$(printf "%02d" $counter)"
fi

mkdir -p "$FINAL_DELIVERY_DIR"

# Function to create zip files
create_zip() {
    local html_file=$1
    local type=$2
    local relative_path=$3
    
    local name=$(basename "$html_file" .html | sed 's/Zone_//')
    local zip_name="${name}-${PROJECT_NAME}-${type}.zip"
    
    echo "📦 Creating $zip_name..."
    
    local images_dir="$(dirname "$html_file")/images"
    local temp_zip="$DESKTOP_PATH/$zip_name"
    
    # Add images to zip if they exist
    if [ -d "$images_dir" ]; then
        (cd "$(dirname "$images_dir")" && zip -r "$temp_zip" "images") || handle_error "Failed to add images from $images_dir to $zip_name"
    fi
    
    # Add HTML file to zip
    (cd "$(dirname "$html_file")" && zip -j "$temp_zip" "$(basename "$html_file")") || handle_error "Failed to add HTML file $html_file to $zip_name"
    
    # Remove .db files if present
    if zipinfo -1 "$temp_zip" | grep -q '\.db$'; then
        zip -d "$temp_zip" "*.db" > /dev/null 2>&1
    fi
    
    # Create destination directory maintaining html_regular/html_specialists structure
    local html_subdir="html_regular"
    if [ "$type" = "Specialists" ]; then
        html_subdir="html_specialists"
    fi
    
    local dest_dir="$FINAL_DELIVERY_DIR/$relative_path/$html_subdir"
    mkdir -p "$dest_dir"
    mv "$temp_zip" "$dest_dir/" || handle_error "Failed to move $zip_name to $dest_dir"
    
    echo "✅ Created $zip_name in $relative_path/$html_subdir"
}

# Process all html_regular and html_specialists directories recursively
process_html_dirs() {
    local base_dir="$EMAIL_DIR"
    
    echo "🔍 Analyzing folder structure..."
    
    # Detect which case we're dealing with
    if [ -d "$base_dir/html_regular" ] || [ -d "$base_dir/html_specialists" ]; then
        echo "📂 Case 2: Direct html folders in EMAIL"
        process_case_2
    elif [ -d "$base_dir/BATCH_01" ] || [ -d "$base_dir/BATCH_02" ] || [ -d "$base_dir/BATCH_03" ]; then
        echo "📂 Case 3: BATCH structure"
        process_case_3
    else
        echo "📂 Case 1: Category structure"
        process_case_1
    fi
}

# Case 1: Simple category structure
process_case_1() {
    local base_dir="$EMAIL_DIR"
    
    # Process html_regular directories
    find "$base_dir" -mindepth 2 -maxdepth 2 -type d -name "html_regular" | while read -r dir; do
        local relative_path=${dir#$base_dir/}
        relative_path=$(dirname "$relative_path")
        echo "🔄 Processing regular emails in $relative_path"
        
        find "$dir" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
            create_zip "$html_file" "Regular" "$relative_path"
        done
    done
    
    # Process html_specialists directories
    find "$base_dir" -mindepth 2 -maxdepth 2 -type d -name "html_specialists" | while read -r dir; do
        local relative_path=${dir#$base_dir/}
        relative_path=$(dirname "$relative_path")
        echo "🔄 Processing specialists emails in $relative_path"
        
        find "$dir" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
            create_zip "$html_file" "Specialists" "$relative_path"
        done
    done
}

# Case 2: Direct html folders
process_case_2() {
    local base_dir="$EMAIL_DIR"
    
    # Process html_regular if it exists
    if [ -d "$base_dir/html_regular" ]; then
        echo "🔄 Processing regular emails"
        find "$base_dir/html_regular" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
            create_zip "$html_file" "Regular" ""
        done
    fi
    
    # Process html_specialists if it exists
    if [ -d "$base_dir/html_specialists" ]; then
        echo "🔄 Processing specialists emails"
        find "$base_dir/html_specialists" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
            create_zip "$html_file" "Specialists" ""
        done
    fi
}

# Case 3: BATCH structure
process_case_3() {
    local base_dir="$EMAIL_DIR"
    
    # Process each BATCH directory
    for batch in "$base_dir"/BATCH_*; do
        if [ -d "$batch" ]; then
            local batch_name=$(basename "$batch")
            echo "🔄 Processing $batch_name"
            
            # Process each category in the batch
            for category in "$batch"/*; do
                if [ -d "$category" ]; then
                    local category_name=$(basename "$category")
                    local relative_path="$batch_name/$category_name"
                    
                    # Process html_regular if it exists
                    if [ -d "$category/html_regular" ]; then
                        echo "📁 Processing regular emails in $relative_path"
                        find "$category/html_regular" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
                            create_zip "$html_file" "Regular" "$relative_path"
                        done
                    fi
                    
                    # Process html_specialists if it exists
                    if [ -d "$category/html_specialists" ]; then
                        echo "📁 Processing specialists emails in $relative_path"
                        find "$category/html_specialists" -name "Zone_*.html" -not -name "*Shared*" | while read -r html_file; do
                            create_zip "$html_file" "Specialists" "$relative_path"
                        done
                    fi
                fi
            done
        fi
    done
}

# Start the processing
process_html_dirs

echo "✨ All done! ZIP files have been created and moved successfully!"
