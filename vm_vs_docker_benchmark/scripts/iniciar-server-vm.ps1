# PowerShell script to create and start a Minecraft server VM using VirtualBox and Ubuntu Server ISO with cloud-init

# Ensure script is run with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# Variables
$vmName = "MinecraftServerVM"
$vmMemoryMB = 12288 # 12 GB
$vmCpuCount = 2
$vmDiskSizeMB = 40960 # 40 GB
$isoRelativePath = "..\..\ISOs\ubuntu-server.iso"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$isoFullPath = Join-Path -Path $scriptDir -ChildPath $isoRelativePath
$vboxManage = "VBoxManage.exe"

# Resolve full ISO path
try {
    $isoPath = (Resolve-Path -Path $isoFullPath).Path
} catch {
    Write-Error "Ubuntu Server ISO not found at path: $isoFullPath"
    exit 1
}

# Check if VBoxManage is available
if (-not (Get-Command $vboxManage -ErrorAction SilentlyContinue)) {
    $commonVBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
    if (Test-Path $commonVBoxPath) {
        Write-Host "VBoxManage.exe found at $commonVBoxPath, adding to PATH for this session."
        $env:Path = $env:Path + ";" + "C:\Program Files\Oracle\VirtualBox"
    } else {
        Write-Error "VBoxManage.exe not found in PATH or common install location. Please ensure VirtualBox is installed correctly."
        exit 1
    }
}

# Check for running VirtualBox or VBoxManage processes that may lock the VM
$lockingProcesses = Get-Process -Name "VirtualBox" -ErrorAction SilentlyContinue
$lockingProcesses += Get-Process -Name "VBoxManage" -ErrorAction SilentlyContinue
if ($lockingProcesses) {
    Write-Warning "There are running VirtualBox or VBoxManage processes that may lock the VM. Please close all VirtualBox windows and terminate VBoxManage processes before running this script."
    exit 1
}

# Function to wait for VM lock release
function Wait-ForVMLockRelease {
    param (
        [string]$vmName,
        [int]$timeoutSeconds = 30
    )
    $startTime = Get-Date
    while ($true) {
        $locked = $false
        try {
            & $vboxManage showvminfo $vmName | Out-Null
        } catch {
            $locked = $true
        }
        if (-not $locked) {
            break
        }
        if ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeoutSeconds)) {
            Write-Error "Timeout waiting for VM '$vmName' lock to be released."
            exit 1
        }
        Start-Sleep -Seconds 2
    }
}

# Check if VM is running and stop it
$runningVMs = & $vboxManage list runningvms | Select-String $vmName
if ($runningVMs) {
    Write-Host "VM '$vmName' is running. Stopping it..."
    & $vboxManage controlvm $vmName poweroff
    Start-Sleep -Seconds 5
}

# Check if VM exists and unregister/delete it safely
$existingVMs = & $vboxManage list vms | Select-String $vmName
if ($existingVMs) {
    Write-Host "VM '$vmName' already exists. Waiting for lock release..."
    Wait-ForVMLockRelease -vmName $vmName
    Write-Host "Unregistering and deleting VM '$vmName'..."
    & $vboxManage unregistervm $vmName --delete
}

# Define VM disk path and delete if exists
$vmDiskPath = Join-Path -Path $env:USERPROFILE -ChildPath "VirtualBox VMs\$vmName\$vmName.vdi"
if (Test-Path $vmDiskPath) {
    Write-Host "Deleting existing disk at $vmDiskPath"
    Remove-Item -Force $vmDiskPath
}

# Create cloud-init ISO
$cloudInitScript = Join-Path -Path $scriptDir -ChildPath "create-cloud-init-iso.ps1"
Write-Host "Creating cloud-init ISO..."
powershell -ExecutionPolicy Bypass -File $cloudInitScript

$cloudInitIsoPath = Join-Path -Path $scriptDir -ChildPath "..\cloud-init\cloud-init.iso"
try {
    $cloudInitIsoPath = (Resolve-Path -Path $cloudInitIsoPath).Path
} catch {
    Write-Error "Cloud-init ISO not found at expected path: $cloudInitIsoPath"
    exit 1
}

# Create VM
Write-Host "Creating VM '$vmName'..."
& $vboxManage createvm --name $vmName --ostype Ubuntu_64 --register

# Set memory and CPU
& $vboxManage modifyvm $vmName --memory $vmMemoryMB --cpus $vmCpuCount --nic1 nat

# Create virtual disk
Write-Host "Creating virtual disk..."
& $vboxManage createmedium disk --filename $vmDiskPath --size $vmDiskSizeMB --format VDI

# Attach storage controllers
& $vboxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
& $vboxManage storagectl $vmName --name "IDE Controller" --add ide

# Attach disk to SATA controller
& $vboxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vmDiskPath

# Attach Ubuntu Server ISO to IDE controller port 0
& $vboxManage storageattach $vmName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $isoPath

# Attach cloud-init ISO to IDE controller port 1
& $vboxManage storageattach $vmName --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $cloudInitIsoPath

# Set boot order to boot from DVD first
& $vboxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Start the VM
Write-Host "Starting VM '$vmName'..."
& $vboxManage startvm $vmName --type gui

Write-Host "VM '$vmName' created and started. Connect to the VM console to install Ubuntu Server and configure the Minecraft server."