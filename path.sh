#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title path
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💊

# Documentation: Converted Google Drive macOS paths into windows and vice versa
# @raycast.author Jb Deslandes

mail="jdeslandes@datawords.com"
drive_mac="Drive partagés"
drive_windows="Shared drives"

active_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

if [[ "$active_app" == "Finder" ]]; then
  path=$(osascript -e 'tell application "Finder" to get POSIX path of (target of front window as alias)')

  if [[ $path == *\/*\\* ]]; then
    echo "The path contains a backslash."
    exit 1
  fi

  if [[ $path != *"CloudStorage"* ]]; then
    echo "This is not a Google Drive path."
    exit 1
  fi

  converted_path="G:/$drive_windows/${path#/Users/kimura/Library/CloudStorage/GoogleDrive-$mail/$drive_mac/}"
  converted_path="${converted_path//\//\\}"

  echo "$converted_path" | pbcopy
  echo "The path was copied in the clipboard."

else
  clipboard=$(pbpaste)

  if [[ $clipboard == G:* ]]; then
    path_converted=$(echo $clipboard | sed -e "s/G:\/$drive_windows\//\/Users\/kimura\/Library\/CloudStorage\/GoogleDrive-$mail\/$drive_mac\//g" -e 's/\\/\//g')
    echo "$path_converted" | pbcopy
    echo "The path was converted and copied to clipboard."
  else
    echo "The clipboard does not contain a Google Drive path."
    exit 1
  fi
fi
