:: Description - Enables User Account Control (UAC)
:: Configuration Type - COMPUTER

Set "RegeditPath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

REG ADD %RegeditPath% /v EnableLUA /t REG_DWORD /d 1 /f
REG ADD %RegeditPath% /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
REG ADD %RegeditPath% /v EnableLUAConsentPromptBehaviorAdmin /t REG_DWORD /d 4 /f
REG ADD %RegeditPath% /v EnableLUAConsentPromptBehaviorUser /t REG_DWORD /d 1 /f