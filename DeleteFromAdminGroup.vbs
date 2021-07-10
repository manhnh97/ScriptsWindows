'It is recommended to test the script on a local machine for its purpose and effects. 
'ManageEngine Desktop Central will not be responsible for any 
'damage/loss to the data/setup based on the behavior of the script.

'Description - Script to delete all users who belong to Administrator group except user with name Administrator
'Parameters -
'Remarks - The exceptions must be hard coded.
'Configuration Type - COMPUTER
'==============================================================
On Error Resume Next
strComputer = "."
strLocalAdminGroup = "Administrators"  
Set objGroup = GetObject("WinNT://" & strComputer & "/Administrators")

For Each objUser In objGroup.Members
    if objUser.Name <> "Administrator" And objUser.Name <> "Domain Admins" then
		'Wscript.Echo objUser.Name
		objGroup.Remove(objUser.AdsPath)
	End if
Next

wscript.quit err.number

