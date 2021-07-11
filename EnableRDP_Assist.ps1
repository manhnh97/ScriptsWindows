<#
    - Run as Highest Privileges <> Configuration Type - COMPUTER
    - Description: 
                    + Enable Remote Desktop & Allow Firewall
                    + Add Localgroup "Remote Desktop Users" for All Users
#>

<# Add User to Localgroup "Remote Desktop Users" #>
$UserName = $env:COMPUTERNAME.Split("-")[0]
# $COMPUTERNAME[0]
$GroupName = "Remote Desktop Users"
try {
    Add-LocalGroupMember -Group $GroupName -Member $UserName -ErrorAction Stop
} catch [Microsoft.PowerShell.Commands.MemberExistsException] {
    Write-Warning "$UserName already in $GroupName"
}

<# Enable Firewall Remote Desktop Connection #>
Set-NetFirewallProfile -All -Enabled True
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

<# Enable Remote Desktop in Regedit #>
$RegeditPath="HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
Set-Location -Path $RegeditPath
$key = try {
    Get-Item -Path $RegeditPath -ErrorAction Stop
}
catch {
    New-Item -Path $RegeditPath -Force
}
New-ItemProperty -Path $key.PSPath -Name AllowTSConnections -Value 0 -Force
New-ItemProperty -Path $key.PSPath -Name fDenyTSConnections -Value 0 -Force
New-ItemProperty -Path $key.PSPath -Name fAllowToGetHelp -Value 1 -Force