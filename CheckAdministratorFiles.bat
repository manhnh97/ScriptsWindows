@echo off

goto Check_Permissions

:Check_Permissions
	net session nul >2 >&1
	if %errorlevel% == 0
	(
		echo Success: Administrator
	)
	else 
	(
		echo Failure: Not Administrator
	)

	goto anykey

:anykey
	PAUSE