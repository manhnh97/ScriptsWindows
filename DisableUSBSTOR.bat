:: Run as Highest Privileges
:: Disable USB with Regedit

REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 4 /f