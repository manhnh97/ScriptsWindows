:: [Important] Run as Highest Privileges

::  It is recommended to test the script on a local machine for its purpose and effects. 

::  Description - Script to Disable IPv6
::  Parameters -  By default it will disable all IPv6 components. If you want to disable particular compnent, use one of the parameter mentioned below
::                0x20 to prefer IPv4 over IPv6 by changing entries in the prefix policy table
::                0x10 to disable IPv6 on all nontunnel interfaces
::                0x01 to disable IPv6 on all tunnel interfaces
::                0x11 to disable all IPv6 interfaces except for the IPv6 loopback interface
::  Remarks -     It will be effective only after restart the system and also it won't uncheck IPv6 option in adapter properties
::  Configuration Type - COMPUTER
::
::  ===========================================================================================================================
@echo off
IF NOT "%1"=="" (set param=%1) else ( set param=0xff)
:: echo %param%
set check=false
if %param%==0xff set check=true
if %param%==0x20 set check=true
if %param%==0x10 set check=true
if %param%==0x01 set check=true
if %param%==0x11 set check=true
if "%check%"=="true" (
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /v DisabledComponents /t REG_DWORD /d %param% /f
) else ( 
exit 1
)