:: Run as Users Privileges <> Configuration Type - USER
:: Turn On Screen Save Lock Save Battery and Secure PCs
:: Default Screen Save after 5 minute and Black Screen
::      Activate timeout after restart

REG ADD "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "%SystemRoot%\System32\scrnsave.scr" /f
REG ADD "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 300 /f
REG ADD "HKCU\Control Panel\Desktop" /V ScreenSaverIsSecure /T REG_SZ /d 1 /f
REG ADD "HKCU\System\Power" /V PromptPasswordOnResume /T REG_SZ /d 1 /f