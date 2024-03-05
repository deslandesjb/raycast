# Raycast - Convert Google Drive path

## How the script works
If you are on the Finder and on a Google Drive folder, then convert the MAC path to a WINDOWS path, and put the converted path to the clipboard

If you are not on the Finder and you have a WINDOWS Google Drive path in the clipboard, convert the WINDOWS path to MAC path and open in on the Finder

## How to install
1. Install Raycast https://www.raycast.com/
2. Open Raycast (option + space), under Extensions create a new Script Command

![CleanShot 2023-04-13 at 19 13 13](https://user-images.githubusercontent.com/47465584/231834834-68c5a745-4378-4bb2-9c14-60e934d7ac71.jpg)

3. Template is Bash, mode Silent, Title "Path" and save it where you want, for example Documents (you'll have to edit the file):

![CleanShot 2023-05-05 at 5 18 27@2x](https://user-images.githubusercontent.com/47465584/236499180-4f12d964-e374-454f-91f8-15d77d71a63f.jpg)



4. Open the script and replace :

mail="*my_email*" with your mail address

For example : mail="jdeslandes@datawords.com"

![CleanShot 2023-05-05 at 5 19 13@2x](https://user-images.githubusercontent.com/47465584/236499281-113b2c4d-b98f-4c1c-a139-6eab854f4013.jpg)



5. Save the file

That's it, you can call the script using opt + space and type "path"

![CleanShot 2023-05-04 at 5 18 09](https://user-images.githubusercontent.com/47465584/236252568-86f52972-735e-44ff-92ad-824f2ed1c880.jpg)

If you're on the Finder with on the drive, it will convert the path to WINDOWS path and put it on the clipboard

If you're not on the Finder and on you have a WINDOWS path on your clipboard, it will convert the path to MAC and open it on the finder


Many thanks Florine Bourassin for your help 😆
