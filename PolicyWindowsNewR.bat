@echo off
REM =============== Start Tutorials ===============

REM =============== Description ===============
    rem Configure Policy for New WindowsOS

REM =============== Can do it =============== 
    REM + Set User Account Administrator gồm Password, Password Unlimited Date Time
    REM + Set User Account Admin gồm Password (Default Password: Input password in Variable => PW_Admin), add User Account Admin to Localgroup Administrators
    REM + Schedule Disable Admin middle for employee
    REM + Schedule Shutdown PC at 10:00 PM
    REM + Open Website * on Logon
    REM + Date and Time Synchronization (UTC+07:00)
    REM + Lock Screen after 5 minutes
    REM + Disabling IPv6 Using Command Prompt
    REM + Turn On Samba SMBv1.0
    REM + Turn On Firewall on System
    REM + Turn On Firewall on System
    REM + Disable Toggle Real Time Defender
    REM + Disable User Guest
    REM + Etc... I'm Try hihi =))

REM =============== Make it active ===============
    REM + Run as Administrator *PolicyWindowsNewR.bat* file 

    REM + Enter UserAccount Password in variable PW_Admin
    REM + Enter an input Administrator Password 
    
REM =============== End Tutorials ===============

rem =============== Input Password Administrator hide STAR ===============
setlocal enableextensions disabledelayedexpansion

    rem Call the subroutine to get the password    
        call :getPassword PW_Administrator

    rem Echo what the function returns
        :: if defined password (
        ::    echo You have typed [%password%]
        :: ) else (
        ::    echo You have typed nothing
        :: )
    rem End of the process
        call :SetPassword
endlocal
exit /b

rem =============== Subroutine to get the password =============== 
:getPassword returnVar
    setlocal enableextensions disabledelayedexpansion
    set "_password="

    rem We need a backspace to handle character removal
    for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do set "BS=%%a"

    rem Prompt the user 
    set /p "=Input Password Administrator: " <nul 

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
endlocal & set "%~1=%_password%" & exit /b %exitCode%

rem =============== Set Password Default ===============  
:SetPassword
    setlocal
    REM =============== Input Password to Variable here ===============
    set "PW_Admin="
    REM =============== Variable here ===============

    REM Set link go to Website 
    set "ChromeWebsite="
    call :CUSTOMIZE_USERS
    call :GPO_AllinOne

    echo =============== Done! ===============
    pause
    endlocal
    goto :eof

:CUSTOMIZE_USERS
    setlocal
        echo echo "=============== START - USER CUSTOMIZE - ==============="
        rem Set UserAccount Administrator Password Expires
        WMIC USERACCOUNT WHERE Name='Administrator' SET PasswordExpires=FALSE
        rem Set Administrator Password
        NET USER Administrator %PW_Administrator% /active:yes

        rem Create UserAccount Admin & Password & Add UserAccount Admin to localgroup Administrators
        NET USER Admin /add
        NET USER Admin %PW_Admin%
        WMIC UserAccount Where Name='Admin' Set PasswordExpires=TRUE
        NET USER Admin /logonpasswordchg:yes
        NET LOCALGROUP Administrators Admin /add

        rem Schedule Disable Admin middle for employee
        SCHTASKS /CREATE /SC ONCE /ST 17:00 /TN "Disable-Admin" /TR "NET USER Admin /active:no" /RU ADMINISTRATOR /RP %PW_Administrator% /f

        rem Open Website * on Logon
        REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ChromeOpenWebsite /t REG_SZ /d "chrome.exe "%ChromeWebsite% /f
        schtasks /CREATE /TN "Disable-ChromeOpenWebsite" /RU "administrator" /RP %PW_Administrator% /TR "REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ChromeOpenWebsite /f" /SC ONCE /ST 15:00 /RL HIGHEST /f

        rem Schedule shutdown computer after 10:00 PM
        SCHTASKS /CREATE /SC Daily /ST 22:00 /TN "Shutdown-Daily_10Min" /TR "shutdown.exe -s -t 600" /RU ADMINISTRATOR /RP %PW_Administrator% /f

        rem Date and Time Synchronization (UTC+07:00)
        tzutil /s "SE Asia Standard Time"
        w32tm /resync

        rem Lock Screen after 5 minutes
        reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d %windir%\system32\scrnsave.scr /f
        reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 300 /f
        REG ADD "HKCU\Control Panel\Desktop" /V ScreenSaverIsSecure /T REG_SZ /D 1 /f
        REG ADD "HKCU\System\Power" /V PromptPasswordOnResume /T REG_SZ /D 1 /f

        rem Disabling IPv6 Using Command Prompt
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f

        rem Turn On Samba SMBv1.0
        DISM /Online /Enable-Feature /All /FeatureName:SMB1Protocol /norestart

        rem Turn On Firewall on System
        schtasks /create /tn "TurnOn_Firewall" /sc onstart /ru system /tr "netsh advfirewall set allprofiles state on"

        rem Disable Toggle Real Time Defender
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f
        echo echo "=============== END - USER CUSTOMIZE - ==============="
        echo .
    endlocal
    goto :eof

:GPO_AllinOne
    setlocal
        MKDIR %SystemDrive%\Logs
        rem =============== VARIABLE REGEDIT ===============
        set "HKLM_S_P_M_W_Logs=HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\EventLog"
        set "HKLM_S_Policies=HKEY_LOCAL_MACHINE\Software\Policies"
        set "HKLM_S_M_W_C_Policies=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies"
        set "HKLM_S_C_C=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control"

        rem =============== CUSTOMIZE USERS GPO ===============
        echo "=============== START - USER CUSTOMIZE GPO - ==============="
            rem Computer Configuration\Policies\Administrative Templates\Windows Components\OneDrive
            rem (Prevent the usage of OneDrive for file storage)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options
            rem (Non-Active User Guest)
            net user Guest /active:no

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Search

            rem (the system will need to be unlocked for the user to interact with Cortana using speech)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Windows Search" /v AllowCortanaAboveLock /t REG_DWORD /d 0 /f

            rem (Cortana will be turned off)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f

            rem (Queries won't be performed on the web and web results won't be displayed when a user performs a query in Search)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f

            rem (Turn on Number Lock on Startup)
            REG ADD "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f
        echo "=============== END - USER CUSTOMIZE GPO - ==============="
        echo .
        echo "=============== START - REMOTE DESKTOP CONNECTION - ==============="
            netsh firewall set service type=remotedesktop mode=enable
            netsh advfirewall firewall add rule name="Open Remote Desktop" protocol=TCP dir=in localport=3389 action=allow
            netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
            reg add %HKLM_S_C_C%"\Terminal Server" /v AllowTSConnections  /t REG_DWORD /d 0 /f
            reg add %HKLM_S_C_C%"\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
            reg add %HKLM_S_C_C%"\Terminal Server" /v fAllowToGetHelp  /t REG_DWORD /d 1 /f
        echo "=============== END - REMOTE DESKTOP CONNECTION - ==============="
        echo .
        echo "=============== START - DISABLE PROXY - ==============="
            REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxySettingsPerUser /t REG_DWORD /d 1 /f
        echo "=============== END - DISABLE PROXY - ==============="
        echo .
        echo "=============== START - ACCOUNT & PASSWORD - ==============="
            rem Configure Account
            net accounts /uniquepw:3
            net accounts /MAXPWAGE:90
            net accounts /MINPWAGE:0
            net accounts /MINPWLEN:8

            rem Configure Password
            :: net accounts /lockoutduration:3
            :: net accounts /lockoutthreshold:3
            :: net accounts /lockoutwindow:3

            rem Notify Password Expiry
            REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v PasswordExpiryWarning /t REG_DWORD /d 14 /f
        echo "=============== END - ACCOUNT & PASSWORD - ==============="
        echo .
        echo "=============== START - AUTOPLAY - ==============="
            rem Computer Configuration\Policies\Administrative Templates\Windows Components\AutoPlay Policies
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Explorer" /v NoAutorun /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
        echo "=============== END - AUTOPLAY - ==============="
        echo.
        echo "=============== START - LOCALTION - ==============="
            rem Computer Configuration\Policies\Administrative Templates\System\Remote Assistance
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows NT\Terminal Services" /v fAllowUnsolicited /t REG_DWORD /d 0 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows NT\Terminal Services" /v fAllowToGetHelp /t REG_DWORD /d 0 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Location and Sensors
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\LocationAndSensors" /v DisableWindowsLocationProvider /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\LocationAndSensors" /v DisableLocationScripting /t REG_DWORD /d 1 /f
        echo "=============== END - LOCALTION - ==============="
        echo .

        echo "=============== START - WINDOWS DEFENDER ANTIVIRUS - ==============="
            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Windows Defender Antivirus

            rem (Runs and computers are scanned for malware and other potentially unwanted software)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 0 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\MAPS
            rem (Group Policy will take priority over the local preference setting.)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Spynet" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f

            rem (This feature ensures the device checks in real time with the Microsoft Active Protection Service (MAPS) before allowing certain content to be run or accessed - Enabled)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Spynet" /v DisableBlockAtFirstSeen /t REG_DWORD /d 0 /f


            rem (Join Microsoft MAPS)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 2 /f


            rem (Send file samples when further analysis is required)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\MAPS

            rem (Configure extended cloud check)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\MpEngine" /v MpBafsExtendedTimeout /t REG_DWORD /d 50 /f

            rem (Select cloud protection level)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\MpEngine" /v MpCloudBlockLevel /t REG_DWORD /d 2 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\Quarantine

            rem (Configure removal of items from Quarantine folder)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Quarantine" /v PurgeItemsAfterDelay /t REG_DWORD /d 0 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\Real-time Protection

            rem (Scanning for all downloaded files and attachments will be enabled)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Real-Time Protection" /v DisableIOAVProtection /t REG_DWORD /d 0 /f

            rem (Microsoft Defender Antivirus will prompt users to take actions on malware detections)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f

            rem (behavior monitoring will be enabled)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 0 /f

            rem (A process scan will be initiated when real-time protection is turned on)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 0 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\Scan

            rem (A new context menu will be added to the task tray icon to allow the user to pause a scan)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v AllowPause /t REG_DWORD /d 1 /f

            rem (Archive files will not be scanned)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v DisableArchiveScanning /t REG_DWORD /d 1 /f

            rem (Packed executables will be scanned)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v DisablePackedExeScanning /t REG_DWORD /d 0 /f

            rem (Removable drives will be scanned during any type of scan)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v DisableRemovableDriveScanning /t REG_DWORD /d 0 /f

            rem (E-mail scanning will be enabled)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v DisableEmailScanning /t REG_DWORD /d 0 /f

            rem (Euristics will be enabled)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Scan" /v DisableHeuristics /t REG_DWORD /d 0 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\Microsoft Defender Exploit Guard\Network Protection

            rem ( Specify the mode in the Options section:
            rem 	-Block: Users and applications will not be able to access dangerous domains
            rem -Audit Mode: Users and applications can connect to dangerous domains, however if this feature would have blocked access if it were set to Block, then a record of the event will be in the event logs)
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v EnableNetworkProtection /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Application Guard
            REG ADD %HKLM_S_Policies%"\Microsoft\AppHVSI" /v AllowAppHVSI_ProviderSet /t REG_DWORD /d 1 /f
        echo "=============== END - MICROSOFT DEFENDER ANTIVIRUS - ==============="
        echo .
        echo "=============== START - SECURITY OPTIONS - ==============="
            rem Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options

            rem (Enforce cryptographic signatures on any interactive application that requests elevation of privilege)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v ValidateAdminCodeSignatures /t REG_DWORD /d 0  /f

            rem (This check verifies whether User Interface Accessibility programs can automatically disable the secure desktop for elevation prompts for a standard user)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableUIADesktopToggle /t REG_DWORD /d 0 /f

            rem (A value of 1 requires the admin to enter username and password when operations require elevated privileges on a secure desktop)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 1 /f

            rem (The default value of 3 prompts for credentials on a secure desktop)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v ConsentPromptBehaviorUser /t REG_DWORD /d 3 /f

            rem (User Account Control (UAC) is a security mechanism for limiting the elevation of privileges, including administrative accounts, unless authorized. This setting requires Windows to respond to application installation requests by prompting for credentials)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableInstallerDetection /t REG_DWORD /d 1 /f

            rem (User Account Control (UAC) is a security mechanism for limiting the elevation of privileges, including administrative accounts, unless authorized. This setting configures Windows to only allow applications installed in a secure location on the file system, such as the Program Files or the Windows\System32 folders, to run with elevated privileges)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableSecureUIAPaths /t REG_DWORD /d 1 /f

            rem Enable UAC
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableLUA /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableLUAConsentPromptBehaviorAdmin /t REG_DWORD /d 4 /f
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableLUAConsentPromptBehaviorUser /t REG_DWORD /d 1 /f

            rem (This policy enables the redirection of legacy application File and Registry writes that would normally fail as standard user to a user-writable data location. This setting mitigates problems with applications that historically ran as administrator and wrote run-time application data back to locations writable only by an administrator)
            REG ADD %HKLM_S_M_W_C_Policies%"\System" /v EnableVirtualization /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options

            rem (Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks. Audit logs are necessary to provide a trail of evidence in case the system or network is compromised. Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior. This setting allows administrators to enable more precise auditing capabilities.)
            REG ADD %HKLM_S_C_C%"\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f
        echo "=============== END - SECURITY OPTIONS - ==============="
        echo .
        echo "=============== START - MICROSOFT EDGE - ==============="
            rem Computer Configuration\Policies\Administrative Templates\Microsoft Edge

            rem (Block dangerous downloads)
            REG ADD %HKLM_S_Policies%"\Microsoft\Edge" /v DownloadRestrictions /t REG_DWORD /d 1 /f

            rem ( Do Not Tracker requests are always sent to websites asking for tracking info)
            REG ADD %HKLM_S_Policies%"\Microsoft\Edge" /v ConfigureDoNotTrack /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Administrative Templates\Microsoft Edge\Content settings

            rem (Do not allow any site to show popups)
            REG ADD %HKLM_S_Policies%"\Microsoft\Edge" /v DefaultPopupsSetting /t REG_DWORD /d 2 /f

            rem Computer Configuration\Policies\Administrative Templates\Microsoft Edge\SmartScreen settings
            rem (Microsoft Defender SmartScreen is turned on.)
            REG ADD %HKLM_S_Policies%"\Microsoft\Edge" /v SmartScreenEnabled /t REG_DWORD /d 1 /f
        echo "=============== END - MICROSOFT EDGE - ==============="
        echo .
        echo "=============== START - WINDOWS UPDATE - ==============="
            rem Computer Configuration\Policies\Administrative Templates\Windows Components\Windows Update
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v AutoInstallMinorUpdates /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallDay /t REG_DWORD /d 4 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallTime /t REG_DWORD /d 12 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallFirstWeek /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 0 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate" /v AUPowerManagement /t REG_DWORD /d 1 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 0 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate" /v SetDisableUXWUAccess /t REG_DWORD /d 0 /f
            REG ADD %HKLM_S_Policies%"\Microsoft\Windows\WindowsUpdate" /v IncludeRecommendedUpdates /t REG_DWORD /d 1 /f

            rem The PC will not automatically restart after updates during active hours. The PC will attempt to restart outside of active hours
            set "REG_Parent=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
            REG ADD %REG_Parent% /v SetActiveHours /t REG_DWORD /d 1 /f
            REG ADD %REG_Parent% /v ActiveHoursStart /t REG_DWORD /d 8 /f
            REG ADD %REG_Parent% /v ActiveHoursEnd /t REG_DWORD /d 18 /f
        echo "=============== END - WINDOWS UPDATE - ==============="
        echo .
        echo "=============== START - AUDIT POLICIES - ==============="
            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\Detailed Tracking
            REG ADD %HKLM_S_M_W_C_Policies%"\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\Detailed Tracking
            auditpol.exe /set /subcategory:"Process Creation" /success:enable
            auditpol.exe /set /subcategory:"Process Termination" /success:enable

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\Logon/Logoff
            auditpol.exe /set /subcategory:"Account Lockout" /success:disable /failure:enable
            auditpol.exe /set /subcategory:"Group Membership" /success:enable /failure:disable
            auditpol.exe /set /subcategory:"Logoff" /success:enable /failure:disable
            auditpol.exe /set /subcategory:"Logon" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Special Logon" /success:enable /failure:enable

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\Object Access
            auditpol.exe /set /subcategory:"File Share" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"File System" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Kernel Object" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Other Object Access Events" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Registry" /success:enable /failure:enable

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\Policy Change
            auditpol.exe /set /subcategory:"Audit Policy Change" /success:enable /failure:enable
            auditpol.exe /set /subcategory:"Other Policy Change Events" /success:enable /failure:enable

            rem Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configuration\Audit Policies\System
            auditpol.exe /set /subcategory:"System Integrity" /success:enable /failure:enable
        echo "=============== END - AUDIT POLICIES - ==============="
        echo.
        echo "=============== START - AUDIT LOGS - ==============="
            rem Write logs Logon System
            auditpol /set /subcategory:Logon /success:enable /failure:enable

            rem Write logs Accounts
            auditpol /set /subcategory:"Application Group Management" /success:enable
            auditpol /set /subcategory:"Computer Account Management" /success:enable
            auditpol /set /subcategory:"User Account Management" /success:enable

            rem Write logs “Security State Change” & “System Integrity” on change
            auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable
            auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable
            
            rem Logs Application
            REG ADD %HKLM_S_P_M_W_Logs%"\Application" /v MaxSize /t REG_DWORD /d 1024000 /f
            REG ADD %HKLM_S_P_M_W_Logs%"\Application" /v File /t REG_SZ /d "%SystemDrive%\Logs" /f
            REG ADD %HKLM_S_P_M_W_Logs%"\Application" /v AutoBackupLogFiles /t REG_SZ /d 1 /f
            rem Logs Security
            REG ADD %HKLM_S_P_M_W_Logs%"\Security" /v MaxSize /t REG_DWORD /d 1024000 /f
            REG ADD %HKLM_S_P_M_W_Logs%"\Security" /v File /t REG_SZ /d "%SystemDrive%\Logs" /f
            REG ADD %HKLM_S_P_M_W_Logs%"\Security" /v AutoBackupLogFiles /t REG_SZ /d 1 /f
            rem Logs System
            REG ADD %HKLM_S_P_M_W_Logs%"\System" /v MaxSize /t REG_DWORD /d 1024000 /f
            REG ADD %HKLM_S_P_M_W_Logs%"\System" /v File /t REG_SZ /d "%SystemDrive%\Logs" /f
            REG ADD %HKLM_S_P_M_W_Logs%"\System" /v AutoBackupLogFiles /t REG_SZ /d 1 /f
        echo "=============== END - AUDIT LOGS - ==============="
        echo .
    endlocal
    goto :eof
