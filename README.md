# Raycast - Convert Google Drive path

## How the script works
If you are on the Finder and on a Google Drive folder, then convert the Mac path to a Windows path and put the converted path to the clipboard
If you are not on the finder and you have a Google Drive link in the clipboard, convert the Windows path to Mac path

## How to install
1. Install Raycast https://www.raycast.com/
2. Open Raycast, under Extensions create a new Script Command
![CleanShot 2023-04-13 at 19 13 13](https://user-images.githubusercontent.com/47465584/231834834-68c5a745-4378-4bb2-9c14-60e934d7ac71.jpg)

3. Select all field as follow and save it where you want (you'll have to edit the file):
![CleanShot 2023-05-04 at 5 17 11](https://user-images.githubusercontent.com/47465584/236252355-f94e4227-16f7-439e-81f6-57f8bba758b1.jpg)


4. Open the script and replace :

mail="my_email" with your mail address

For example : mail="jdeslandes@datawords.com"
![CleanShot 2023-05-04 at 5 14 54](https://user-images.githubusercontent.com/47465584/236251937-016bfe0c-31d2-4954-af77-1108a282260b.jpg)


5. Save the file

That's it, you can call the script using opt + space and type "path"
![CleanShot 2023-05-04 at 5 18 09](https://user-images.githubusercontent.com/47465584/236252568-86f52972-735e-44ff-92ad-824f2ed1c880.jpg)

If you're on the Finder with on the drive, it will convert the path to WINDOWS path and put it on the clipboard

If you're not on the Finder and on you have a WINDOWS path on your clipboard, it will convert the path to MAC and open it on the finder
