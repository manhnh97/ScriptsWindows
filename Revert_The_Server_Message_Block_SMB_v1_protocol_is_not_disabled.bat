echo on
REM Script to revert "The Server Message Block (SMB) v1 protocol is not disabled" misconfiguration
ECHO reverting..
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol /NoRestart
ECHO Done