On Error Resume Next
strComputer = "."
strLocalAdminGroup = "Administrators"  
Set objGroup = GetObject("WinNT://" & strComputer & "/Administrators")

For Each objUser In objGroup.Members
    if objUser.Name <> "Administrator" And objUser.Name <> "Admin" then
		'Wscript.Echo objUser.Name
		objGroup.Remove(objUser.AdsPath)
	End if
Next

wscript.quit err.number

