::  It is recommended to test the script on a local machine for its purpose and effects. 
::  ManageEngine Desktop Central will not be responsible for any 
::  damage/loss to the data/setup based on the behavior of the script.

::  Description: Script to Enable SMBV1 protocol 
::  Remarks: Restart the system after script executed successfully
::  Configuration Type - COMPUTER
::  ===========================================================================================================================

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d 1 /f
sc.exe config lanmanworkstation depend= bowser/mrxsmb10/mrxsmb20/nsi 
sc.exe config mrxsmb10 start= auto