# PowerShell script to fix 'Some Settings Are Managed By Your Organization' issue on Windows 11 (Silent Mode)

# Run script as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]"Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `$PSCommandPath" -Verb RunAs
    exit
}

# Create system restore point
Checkpoint-Computer -Description "LocalGroupPolicy" -RestorePointType "MODIFY_SETTINGS"

# Reset security policies
defltbasePath = "$env:windir\inf\defltbase.inf"
secedit /configure /cfg $defltbasePath /db defltbase.sdb /verbose

# Delete Group Policy folders
Remove-Item -Path "$env:SystemRoot\System32\GroupPolicyUsers" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:SystemRoot\System32\GroupPolicy" -Recurse -Force -ErrorAction SilentlyContinue

# Delete problematic registry keys
$registryPaths = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies',
    'HKCU:\Software\Microsoft\WindowsSelfHost',
    'HKCU:\Software\Policies',
    'HKLM:\Software\Microsoft\Policies',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate',
    'HKLM:\Software\Microsoft\WindowsSelfHost',
    'HKLM:\Software\Policies',
    'HKLM:\Software\WOW6432Node\Microsoft\Policies',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate'
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Force Group Policy update
gpupdate /force

# Silent reboot
Restart-Computer -Force
