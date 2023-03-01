#!/usr/bin/env node

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title path
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 💊
// @raycast.argument1 { "type": "text", "placeholder": "Path" }

// Documentation: Converted Google Drive macOS paths into windows and vice versa
// @raycast.author Jb Deslandes

const path = process.argv.slice(2)[0];
function convertPath(path) {
  if (path.charAt(0) === "G") {
    // Windows
    return String.raw`${path}`.replace(/\\/g, "/").replace("G:/Shared drives/", "/Users/user-name/Library/CloudStorage/GoogleDrive-mail@mail.com/Shared drives/");
  } else if (path.charAt(0) === "/") {
    // MacOS
    return path.replace("/Users/user-name/Library/CloudStorage/GoogleDrive-mail@mail.com/Shared drives/", "G:/Shared drives/").replaceAll("/", "\\");
  } else {
    return "Wrong path.";
  }
}

const result = convertPath(path);
if (result !== "Wrong path.") {
  const {execSync} = require("child_process");
  execSync(`echo '${result.trim()}' | pbcopy`);
  console.log(`Converted path: ${result}`);
} else {
  console.error(result);
}
