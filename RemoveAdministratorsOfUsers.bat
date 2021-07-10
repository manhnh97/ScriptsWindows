:: [NOTES]
::      - Remove All Users in Localgroup Administrators
::      - Schedule Remove after 1 month per times
::      - Need Run As Highest Privileges

:: ==================================
set HOST=%COMPUTERNAME%
set "FolderStoreM=%PUBLIC%\Documents\Mazekaz"
REM Password of Administrator or Users have to Highest Privileges
set "PWA="

cd /d %FolderStoreM%
if not exist %FolderStoreM% (mkdir %FolderStoreM%) 

echo for /F %i in ('net localgroup Administrators') do net localgroup Administrators %i /delete > RemoveAdministratorsOfUsers.bat
echo net localgroup Administrators Administrator /add >> RemoveAdministratorsOfUsers.bat
echo net localgroup Administrators Admin /add >> RemoveAdministratorsOfUsers.bat

Schtasks /CREATE /SC monthly /TN "RemoveAdministratorsOfUsersInMonthly" /TR "%FolderStoreM%\RemoveAdministratorsOfUsers.bat" /RU "%HOST%\Administrator" /RP %PWA% /f
