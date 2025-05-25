# PowerShell script to create a cloud-init ISO with user-data and meta-data files using oscdimg (Windows ADK)

# Paths
$cloudInitDir = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "..\cloud-init"
$userDataFile = Join-Path -Path $cloudInitDir -ChildPath "user-data.yaml"
$metaDataFile = Join-Path -Path $cloudInitDir -ChildPath "meta-data.yaml"
$outputIso = Join-Path -Path $cloudInitDir -ChildPath "cloud-init.iso"

# Check if oscdimg.exe is available
$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if (-not (Test-Path $oscdimgPath)) {
    Write-Error "oscdimg.exe not found at expected path: $oscdimgPath. Please install Windows ADK or provide oscdimg.exe."
    exit 1
}

# Create temporary directory for ISO contents
$tempDir = Join-Path -Path $cloudInitDir -ChildPath "iso-tmp"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy user-data and meta-data to temp directory
Copy-Item -Path $userDataFile -Destination (Join-Path $tempDir "user-data")
Copy-Item -Path $metaDataFile -Destination (Join-Path $tempDir "meta-data")

# Create ISO using oscdimg
# Create ISO using oscdimg without conflicting options
& $oscdimgPath -m -o -u2 $tempDir $outputIso
& $oscdimgPath -n -m -o -u2 $tempDir $outputIso

# Clean up
Remove-Item -Recurse -Force $tempDir

Write-Host "Cloud-init ISO created at $outputIso"