'Description - Enables User Account Control (UAC)
'Parameters -
'Remarks -
'Configuration Type - COMPUTER
'==============================================================

Set WshShell = CreateObject("WScript.Shell")
myKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA"
WshShell.RegWrite myKey,1,"REG_DWORD"
Set WshShell = Nothing