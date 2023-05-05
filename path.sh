#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title path
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💊

# Documentation: Converted Google Drive macOS paths into windows and vice versa
# @raycast.author Jb Deslandes

# ⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️
mail="my_email"
# ⬆️⬆️⬆️⬆️⬆️⬆️⬆️

mac_user=$(whoami)
lang=$(defaults read -g AppleLanguages | tr -d '(),\n" ')
lang=${lang:0:2}

if [[ $lang == "en" ]]; then
  drive_mac="Shared drives"
elif [[ $lang == *"fr"* ]]; then
  drive_mac="Drive partagés"
elif [[ $lang == *"es"* ]]; then
  drive_mac="Unidades compartidas"
elif [[ $lang == *"pt"* ]]; then
  drive_mac="Drives compartilhados"
elif [[ $lang == *"de"* ]]; then
  drive_mac="Freigegebene Laufwerke"
elif [[ $lang == *"it"* ]]; then
  drive_mac="Team drive condivisi"
fi

active_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

if [[ "$active_app" == "Finder" ]]; then
  path=$(osascript -e 'tell application "Finder" to get POSIX path of (target of front window as alias)')

  special_chars=("\\/" "(" ")" "=" "+" "¨" "^" "°" "*" "‘" "«" "»" "°" "{" "}" "[" "]" "<" ">" "|" "~" "*" "%" "$" "€" "?" ":" ";" "," "#" "\`" "'" "\"")
  for char in "${special_chars[@]}"; do
    if [[ $path == *"\\"* ]]; then
      echo "The path contains a backslash. Please remove it."
      exit 1
    elif [[ $path == *"\""* ]]; then
      echo "The path contains a double quote. Please remove it."
      exit 1
    elif [[ $path == *"‘"* ]]; then
      echo "The path contains a simple quote. Please remove it."
      exit 1
    elif [[ $path == *"'"* ]]; then
      echo "The path contains a simple quote. Please remove it."
      exit 1
    elif [[ $path == *"$char"* ]]; then
      echo "The path contains the character '$char'. Please remove it."
      exit 1
    fi
  done

  if [[ $path != *"CloudStorage"* ]]; then
    echo "This is not a Google Drive path."
    exit 1
  fi
  converted_path="G:\\Shared drives\\${path##*/$mac_user/Library/CloudStorage/GoogleDrive-$mail/$drive_mac/}"
  converted_path=$(echo "$converted_path" | sed 's|/|\\|g')
  echo -n "$converted_path" | pbcopy
  echo "The path was converted for WINDOWS and copied in the clipboard."

else
  clipboard=$(pbpaste)

  if [[ $clipboard == G:* ]]; then
    path_converted=$(echo $clipboard | sed -e 's/\\/\//g' -e "s/G:\/Shared drives\//\/Users\/$mac_user\/Library\/CloudStorage\/GoogleDrive-$mail\/$drive_mac\//g" )

    open "$path_converted"
    echo -n "$path_converted" | pbcopy
    echo "The file was opened with success."


  else
    echo "The clipboard does not contain a Google Drive path."
    exit 1
  fi
fi
