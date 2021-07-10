On Error Resume Next
Const HKEY_LOCAL_MACHINE = &H80000002
SET fso = createobject("Scripting.FilesystemObject")
Set WshShell = CreateObject("WScript.Shell")
strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")        
Set colOperatingSystems = objWMIService.ExecQuery _
        ("Select * from Win32_OperatingSystem")
For Each objOperatingSystem in colOperatingSystems
Osname = objOperatingSystem.Caption
Next
If InStr(Osname, "Windows XP") <> 0 Then
  profpath = "\Local Settings\Temp"
  recyclerpath = "\recycler\"
  cookiespath = "%USERPROFILE%\Cookies"
else
  profpath = "\AppData\Local\Temp"
  recyclerPath = "\$recycle.bin\"
  cookiespath = "%APPDATA%\Microsoft\Windows\Cookies"
End if

 'For cleaning Appdata for every user profile
Set objRegistry=GetObject("winmgmts:\\" & _ 
    strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
objRegistry.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubkeys
 
For Each objSubkey In arrSubkeys
    strValueName = "ProfileImagePath"
    strSubPath = strKeyPath & "\" & objSubkey
    objRegistry.GetExpandedStringValue HKEY_LOCAL_MACHINE,strSubPath,strValueName,strValue
	set fld = fso.GetFolder(strValue)
	if fso.FolderExists( strValue & profpath) then
         set objTempFolder = fso.GetFolder(strValue & profpath)
		 If InStr(objTempFolder.Path, "systemprofile") = 0 And InStr(objTempFolder.Path, "LocalService") = 0 And InStr(objTempFolder.Path, "NetworkService") = 0 Then
			For Each oFile In objTempFolder.files
				fso.DeleteFile oFile
			Next
			For Each oSubFolder In objTempFolder.SubFolders
				Call KillSubFolders (oSubFolder)
			Next
		End If
	End if
Next

'For cleaning Windows Temp folder
Set oFolder = fso.GetFolder(WshShell.ExpandEnvironmentStrings("%TEMP%"))
For Each oFile In oFolder.files
		fso.DeleteFile oFile
Next
For Each oSubFolder In oFolder.SubFolders
		Call KillSubFolders (oSubFolder)
Next

'For cleaning Windows prefetch folder
Set oFolder = fso.GetFolder(WshShell.ExpandEnvironmentStrings("%systemroot%\prefetch"))
For Each oFile In oFolder.files
		fso.DeleteFile oFile
Next
For Each oSubFolder In oFolder.SubFolders
		Call KillSubFolders (oSubFolder)
Next

'For cleaning cookies folder
Set oFolder = fso.GetFolder(WshShell.ExpandEnvironmentStrings(cookiespath))
For Each oFile In oFolder.files
		fso.DeleteFile oFile
Next
For Each oSubFolder In oFolder.SubFolders
		Call KillSubFolders (oSubFolder)
Next

'For cleaning Recycle Bin	
Set objSWbemServices = GetObject _
    ("WinMgmts:Root\Cimv2")
Set colDisks = objSWbemServices.ExecQuery _
        ("Select * From Win32_LogicalDisk " & _
        "Where DriveType = 3")
 For Each objDisk In colDisks
	folderpath = objDisk.DeviceId&recyclerpath
	For Each oFile In oFolder.files
		fso.DeleteFile oFile
	Next
	Set oFolder = fso.GetFolder(folderpath)
	For Each oSubFolder In oFolder.SubFolders
		Call KillSubFolders (oSubFolder)
	Next
Next
	
'Wscript.echo Err.number
	
Sub KillSubFolders (SubPath)
    fso.DeleteFolder SubPath
End Sub 