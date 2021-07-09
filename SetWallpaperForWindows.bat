echo off

:: Commands
REM Images Name ; Image.jpg
Set "IMG=boy_night_headphones_145031_1920x1080.jpg"
REM Location Folder Picture
Set "hrefImage=http://172.18.18.24/software/Windows/Wallpaper/"

REM Directory Store Images
Set "PathImages=%SystemDrive%\Wallpaper\"
REM Regedit Wallpaper
Set "RegDesktop=HKEY_CURRENT_USER\Control Panel\Desktop"

if exist %SystemDrive%\Wallpaper rd /s /q %SystemDrive%\Wallpaper
mkdir %SystemDrive%\Wallpaper

cd %SystemDrive%\Wallpaper
curl -O %hrefImage%%IMG%

reg add "%RegDesktop%" /v Wallpaper /t REG_SZ /d %PathImages%%IMG% /f
reg add "%RegDesktop%" /v WallpaperTileWallPaper /t REG_SZ /d 0 /f
reg add "%RegDesktop%" /v WallpaperStyle /t REG_SZ /d 1 /f
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters