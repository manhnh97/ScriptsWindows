@echo off
    REM =======================================
    REM TITLE: 
        REM Setup computer for new staff
    REM =======================================
    REM DESCRIPTION:
        REM Script can make:
            REM Create an user
            REM Add user to localgroup "Remote Desktop Users"
            REM Add asset code to description computer
            REM Schedule Expire User Admin to use localgroup Administrators
            REM Schedule turn off website default of company
                REM Website setting in Regedit [HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
            REM Start Disk Management to Extend Disk
        REM And... When complete will restart after 3 seconds
    REM =======================================
    REM HOW TO USE IT:
        REM Input 4 variable:
            REM UserName
            REM Department
            REM AssetCode 
            REM NumberOfDay
        REM Example
            REM ManhNH   <> [Manh Nguyen Huu]
            REM IT       <> [Information Technology] 
            REM CA 218   <> [Computer Asset 218]
            REM 9        <> [numberofDay]

    ::
REM =============== Start - Run as Administrator File Current =============== `
if _%1_==_payload_  goto :payload

:getadmin
    echo %~nx0: elevating self
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
goto :eof

:payload
REM =============== End - Run as Administrator File Current =============== `
    ::ENTER YOUR CODE BELOW::  

REM =============== Start - Enter an input Password Administrator & Password Admin
    setlocal enableextensions disabledelayedexpansion
    rem Call the subroutine to get the password    
        call :getPassword  password
        set "PW_Administrator=%password%"
        Set "PW_Users="

        call :main %*
    rem End of the process
    endlocal
    exit /b

    rem Subroutine to get the password
    :getPassword returnVar
        setlocal enableextensions disabledelayedexpansion
        set "_password="

        rem We need a backspace to handle character removal
        for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do set "BS=%%a"

        rem Prompt the user 
        set /p "=Enter an Input Password Administrator: " <nul 

    :keyLoop
        rem retrieve a keypress
        set "key="
        for /f "delims=" %%a in ('xcopy /l /w "%~f0" "%~f0" 2^>nul') do if not defined key set "key=%%a"
        set "key=%key:~-1%"

        rem handle the keypress 
        rem     if No keypress (enter), then exit
        rem     if backspace, remove character from password and console
        rem     else add character to password and go ask for next one
        if defined key (
            if "%key%"=="%BS%" (
                if defined _password (
                    set "_password=%_password:~0,-1%"
                    setlocal enabledelayedexpansion & set /p "=!BS! !BS!"<nul & endlocal
                )
            ) else (
                set "_password=%_password%%key%"
                set /p "=*"<nul
            )
            goto :keyLoop
        )
        echo(
        rem return password to caller
        if defined _password ( set "exitCode=0" ) else ( set "exitCode=1" )
    endlocal & set "%~1=%_password%" & exit /b %exitCode
REM =============== End - Enter an input Password Administrator & Password Admin

    REM =============== Start - Run Code Here ===============
    :main
        setlocal
            set YYYY=%date:~10,4%
            set MM=%date:~4,2%
            set DD=%date:~7,2%
            call :initialize "%YYYY%-%MM%-%DD%" "1"
        endlocal
    goto :eof

    :initialize
        setlocal
            set "previousDate=%~1"
            set /a "numberOfDays=%~2"
            
            color a
            title "Configure Computer for New Users"

            REM Add Variable New User
            set /p "UserName=Enter a New User: "
            REM Add Variable Department of Member
            set /p "Department=Enter a Department of Member: "
            REM Add Variable to Computer Description
            set /p "AssetCode=Enter a Asset Code: "
            REM Variable Expire Date of Admin
            set /p "numberOfDays=Countdown Expire of Admin: "
            
            set "currentDate="
            call :addIsoDateDays "%previousDate%" "%numberOfDays%" currentDate

            :: echo %previousDate% + %numberOfDays% days = %currentDate%
            
            for /f "tokens=1-3 delims=-" %%a in ("%currentDate%") do (
                set "y=%%a"
                set "m=%%b"
                set "d=%%c"
            )

            REM Get Computer Name and Set File
            WMIC computersystem get name /value > "ComputerName"
            REM Change Name Computer
            WMIC COMPUTERSYSTEM WHERE caption='%ComputerName%' rename "%UserName%-%Department%"
            REM Create a New User and Password
            NET Users "%UserName%" "%PW_Users%" /add /logonpasswordchg:yes
            REM Add User to Localgroup "Remote Desktop Users"
            NET Localgroup "Remote Desktop Users" "%UserName%" /add
            REM Set Asset Code to Computer Description
            net config server /srvcomment:"CA %AssetCode%"
            REM Schedule Calendar Countdown DateTime Disable Admin User
            schtasks /CHANGE /TN "Disable-Admin" /RU "administrator" /RP %PW_Administrator% /SD %M%/%D%/%Y% /ENABLE /IT
            REM Schedule DEL Website *
            schtasks /CHANGE /TN "Disable-ChromeOpenWebsite" /RU "administrator" /RP %PW_Administrator% /SD %M%/%D%/%Y% /ENABLE /IT
            
            REM Open disk management
            Start /wait "Disk Management" diskmgmt.msc
            
            REM Restart after 3 second
            shutdown /r /t 3

            REM Delete current file
            del "%~f0"
        endlocal
        goto :eof
        
    :stripLeadingZero
        setlocal
            set "number=%~1"
            if %number:~0,1% equ 0 (
                set "number=%number:~1%"
                )
                (
        endlocal
        set "%~2=%number%"
        )
        goto :eof

    :addLeadingZero
        setlocal
            set "number=%~1"
            if %number% lss 10 (
                set "number=0%number%"
            )
            (
                endlocal
                set "%~2=%number%"
            )
        goto :eof

    :gregorianToJulianDate
        setlocal
        set "gregorianYear=%~1"
        set "gregorianMonth=%~2"
        set "gregorianDay=%~3"

        call :stripLeadingZero "%gregorianMonth%" gregorianMonth
        call :stripLeadingZero "%gregorianDay%" gregorianDay

        set /a "julianYear=(%gregorianYear% + 4800)"
        set /a "julianMonth=((%gregorianMonth% - 14) / 12)"
        set /a "julianDate=((1461 * (%julianYear% + %julianMonth%) / 4) + (367 * (%gregorianMonth% - 2 - (12 * %julianMonth%)) / 12) - ((3 * ((%julianYear% + %julianMonth% + 100) / 100)) / 4) + (%gregorianDay% - 32075))"

        (
            endlocal
            set "%~4=%julianDate%"
        )
        goto :eof

    :isoToJulianDate
        setlocal
        set "date=%~1"
        set "year="
        set "month="
        set "day="

        for /f "tokens=1-3 delims=-" %%a in ("%date%") do (
            set "year=%%a"
            set "month=%%b"
            set "day=%%c"
        )

        set /a "julianDate=0"
        call :gregorianToJulianDate "%year%" "%month%" "%day%" julianDate

        (
            endlocal
            set "%~2=%julianDate%"
        )
        goto :eof

    :julianToGregorianDate
        setlocal
        set /a "julianDate=%~1"

        set /a "p=(%julianDate% + 68569)"
        set /a "q=(4 * %p% / 146097)"
        set /a "r=(%p% - ((146097 * %q%) + 3) / 4)"
        set /a "s=(4000 * (%r% + 1) / 1461001)"
        set /a "t=(%r% - ((1461 * %s%) / 4) + 31)"
        set /a "u=(80 * %t% / 2447)"
        set /a "v=(%u% / 11)"

        set /a "gregorianYear=((100 * (%q% - 49)) + %s% + %v%)"
        set /a "gregorianMonth=(%u% + 2 - (12 * %v%))"
        set /a "gregorianDay=(%t% - (2447 * %u% / 80))"

        call :addLeadingZero "%gregorianMonth%" gregorianMonth
        call :addLeadingZero "%gregorianDay%" gregorianDay

        (
            endlocal
            set "%~2=%gregorianYear%"
            set "%~3=%gregorianMonth%"
            set "%~4=%gregorianDay%"
        )
        goto :eof

    :julianToIsoDate
        setlocal
        set /a "julianDate=%~1"

        set "year="
        set "month="
        set "day="

        call :julianToGregorianDate "%julianDate%" year month day

        set "isoDate=%year%-%month%-%day%"

        (
            endlocal
            set "%~2=%isoDate%"
        )
        goto :eof

    :addIsoDateDays
        setlocal
        set "previousIsoDate=%~1"
        set /a "numberOfDays=%~2"

        set /a "previousJulianDate=0"
        call :isoToJulianDate "%previousIsoDate%" previousJulianDate

        set /a "currentJulianDate=(%previousJulianDate% + %numberOfDays%)"

        set "currentIsoDate="
        call :julianToIsoDate "%currentJulianDate%" currentIsoDate

        (
            endlocal
            set "%~3=%currentIsoDate%"
        )
        goto :eof
        
    ::END OF YOUR CODE::
