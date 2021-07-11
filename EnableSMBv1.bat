::  It is recommended to test the script on a local machine for its purpose and effects. 
::  ManageEngine Desktop Central will not be responsible for any 
::  damage/loss to the data/setup based on the behavior of the script.

::  Description: Script to Enable SMBV1 protocol 
::  Remarks: Restart the system after script executed successfully
::  Configuration Type - COMPUTER
::  ===========================================================================================================================

DISM /Online /Enable-Feature /All /FeatureName:SMB1Protocol /norestart