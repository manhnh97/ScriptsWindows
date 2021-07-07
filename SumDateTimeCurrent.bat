@echo off

call :main %*
goto :eof

:main
    setlocal
    set YYYY=%date:~10,4%
    set MM=%date:~4,2%
    set DD=%date:~7,2%
    call :initialize "%YYYY%-%MM%-%DD%" "1"
    call :initialize "2017-01-01" "1"

    endlocal
    goto :eof

:initialize
    setlocal
    set "previousDate=%~1"
    set /a "numberOfDays=%~2"

    ::set /p "previousDate=Enter ISO date: "
    set /p "numberOfDays=Enter number of days to add: "

    set "currentDate="
    call :addIsoDateDays "%previousDate%" "%numberOfDays%" currentDate

    echo %previousDate% + %numberOfDays% days = %currentDate%

    echo.

    call :initialize "%currentDate%" "%numberOfDays%"

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