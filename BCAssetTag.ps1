# Enable verbose output
$VerbosePreference = "Continue"

# Get all USB drives
$usbDrives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }

if ($usbDrives.Count -eq 0) {
    Write-Error "No USB drives detected."
    exit
}

$usbDrive = $usbDrives[0].DeviceID
$WinAIA_Executable = Join-Path -Path $usbDrive -ChildPath "giaw03ww.exe"

# Verify if the executable exists
if (-not (Test-Path -Path $WinAIA_Executable)) {
    Write-Error "Executable file 'giaw03ww.exe' not found on USB drive."
    exit
}

# Run the installer and wait for it to complete
Write-Host "Running installer: $WinAIA_Executable"
Start-Process -FilePath $WinAIA_Executable -Wait

# Define installation path
$WinAIA_InstallPath = "C:\DRIVERS\WINAIA" 

# Verify if installation directory exists
if (-not (Test-Path -Path $WinAIA_InstallPath)) {
    Write-Error "Installation directory not found: $WinAIA_InstallPath"
    exit
}

# Navigate to the installation directory
Set-Location -Path $WinAIA_InstallPath 

# Prompt user for Asset Tag
$AssetTag = Read-Host -Prompt "Enter the Asset Tag"

# Run the command to set the Asset Tag in BIOS
$WinAIA_Command = ".\WinAIA.exe -set USERASSETDATA.ASSET_NUMBER=$AssetTag"
Write-Host "Running command: $WinAIA_Command" 
Invoke-Expression $WinAIA_Command

# Confirm command execution
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to execute WinAIA command."
    exit
}

Set-Location -Path C:\

Write-Host "Deleting installation directory: $WinAIA_InstallPath"
Remove-Item -Path C:\DRIVERS -Recurse -Force

# Reboot the machine
Restart-Computer -Force


