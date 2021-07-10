:: Run as Highest Privileges
:: Enable USB with Regedit

REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 3 /f