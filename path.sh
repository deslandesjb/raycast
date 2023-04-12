#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title path
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💊

# Documentation: Converts Google Drive macOS paths into windows and vice versa
# @raycast.author Jb Deslandes

mail="mail@mail.com"
drive_mac="Shared drives"
mac_user="user"

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

  converted_path="G:/Shared drives/${path#/Users/$mac_user/Library/CloudStorage/GoogleDrive-$mail/$drive_mac/}"
  converted_path="${converted_path//\//\\}"

  echo "$converted_path" | pbcopy
  echo "The path was copied in the clipboard."

else
  clipboard=$(pbpaste)

  if [[ $clipboard == G:* ]]; then
    path_converted=$(echo $clipboard | sed -e 's/\\/\//g' -e "s/G:\/$drive_windows\//\/Users\/$mac_user\/Library\/CloudStorage\/GoogleDrive-$mail\/$drive_mac\//g" )

    echo "$path_converted" | pbcopy
    echo "The path was converted and copied to clipboard."
  else
    echo "The clipboard does not contain a Google Drive path."
    exit 1
  fi
fi


