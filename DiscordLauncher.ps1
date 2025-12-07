# Discord Auto-Updater for Vencord
# This script detects when Discord has been updated (which removes Vencord) and automatically reinstalls Vencord

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$configPath = Join-Path $PSScriptRoot "discord-version.json"
$logPath = Join-Path $PSScriptRoot "update-log.txt"

# Start fresh log each run to avoid unbounded growth
Set-Content -Path $logPath -Value "" -ErrorAction SilentlyContinue

# Find Discord installation
function Get-DiscordPath {
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Discord\app-*\resources\app.asar",
        "$env:LOCALAPPDATA\DiscordPTB\app-*\resources\app.asar",
        "$env:LOCALAPPDATA\DiscordCanary\app-*\resources\app.asar"
    )
    
    foreach ($pattern in $possiblePaths) {
        $paths = Get-Item $pattern -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if ($paths) {
            return $paths[0].FullName
        }
    }
    
    return $null
}

# Get the Discord executable path
function Get-DiscordExePath {
    $possibleExes = @(
        "$env:LOCALAPPDATA\Discord\Update.exe",
        "$env:LOCALAPPDATA\DiscordPTB\Update.exe",
        "$env:LOCALAPPDATA\DiscordCanary\Update.exe"
    )
    
    foreach ($exe in $possibleExes) {
        if (Test-Path $exe) {
            return $exe
        }
    }
    
    return $null
}

# Calculate file hash for version detection
function Get-FileHashString {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        return $null
    }
    
    $hash = Get-FileHash -Path $Path -Algorithm SHA256
    return $hash.Hash
}

# Log message
function Write-Log {
    param([string]$Message)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logMessage
    Write-Host $logMessage
}

# Check if Vencord is installed
function Test-VencordInstalled {
    $appAsarPath = Get-DiscordPath
    if (-not $appAsarPath) {
        return $false
    }
    
    $resourcesPath = Split-Path $appAsarPath -Parent
    $vencordPath = Join-Path $resourcesPath "_app.asar"
    
    return (Test-Path $vencordPath)
}

# Main logic
try {
    Write-Log "=== Discord Launcher Started ==="
    
    $appAsarPath = Get-DiscordPath
    if (-not $appAsarPath) {
        Write-Log "ERROR: Discord installation not found!"
        Write-Host "Discord installation not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Would you like to install Discord now?" -ForegroundColor Yellow
        Write-Host "1. Install Discord via winget (Recommended)" -ForegroundColor Cyan
        Write-Host "2. Open Discord download page in browser" -ForegroundColor Cyan
        Write-Host "3. Exit" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter your choice (1-3)"
        
        if ($choice -eq "1") {
            Write-Log "Installing Discord via winget..."
            Write-Host "`nInstalling Discord..." -ForegroundColor Cyan
            $installProcess = Start-Process -FilePath "winget" -ArgumentList "install", "Discord.Discord", "--silent", "--accept-source-agreements", "--accept-package-agreements" -Wait -PassThru -NoNewWindow
            
            if ($installProcess.ExitCode -eq 0) {
                Write-Host "Discord installed successfully!" -ForegroundColor Green
                Write-Log "Discord installation succeeded."
                Write-Host "`nPlease run this launcher again to set up Vencord and launch Discord." -ForegroundColor Yellow
            }
            else {
                Write-Host "Failed to install Discord (Exit code: $($installProcess.ExitCode))" -ForegroundColor Red
                Write-Log "ERROR: Discord installation failed with exit code $($installProcess.ExitCode)"
            }
        }
        elseif ($choice -eq "2") {
            Write-Log "Opening Discord download page..."
            Start-Process "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64"
            Write-Host "Opening Discord download page in browser..." -ForegroundColor Cyan
            Write-Host "After installing Discord, run this launcher again." -ForegroundColor Yellow
        }
        
        pause
        exit 1
    }
    
    Write-Log "Discord found at: $appAsarPath"
    
    # Get current version info
    $currentHash = Get-FileHashString -Path $appAsarPath
    $currentModified = (Get-Item $appAsarPath).LastWriteTime.ToString("o")
    
    # Load previous version info
    $previousHash = $null
    $needsReinstall = $Force
    
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        $previousHash = $config.hash
        
        if ($currentHash -ne $previousHash) {
            Write-Log "Discord version change detected!"
            Write-Log "Previous hash: $previousHash"
            Write-Log "Current hash:  $currentHash"
            $needsReinstall = $true
        }
        else {
            Write-Log "No Discord update detected."
        }
    }
    else {
        Write-Log "No previous version info found. Creating baseline."
        $needsReinstall = $true
    }
    
    # Check if Vencord is installed
    $vencordInstalled = Test-VencordInstalled
    Write-Log "Vencord installed: $vencordInstalled"
    
    if (-not $vencordInstalled) {
        Write-Log "Vencord is not installed."
        $needsReinstall = $true
    }
    
    # Reinstall Vencord if needed
    if ($needsReinstall) {
        Write-Host "`nDiscord has been updated or Vencord is not installed." -ForegroundColor Yellow
        Write-Host "Reinstalling Vencord..." -ForegroundColor Cyan
        Write-Log "Installing Vencord via winget..."
        
        # Run winget install
        $installProcess = Start-Process -FilePath "winget" -ArgumentList "install", "Vendicated.Vencord", "--silent", "--accept-source-agreements", "--accept-package-agreements" -Wait -PassThru -NoNewWindow
        
        if ($installProcess.ExitCode -eq 0) {
            Write-Host "Vencord installed successfully!" -ForegroundColor Green
            Write-Log "Vencord installation succeeded."
            
            # Save current version info
            $versionInfo = @{
                hash = $currentHash
                lastModified = $currentModified
                lastChecked = (Get-Date).ToString("o")
            }
            $versionInfo | ConvertTo-Json | Set-Content $configPath
            Write-Log "Version info saved."
        }
        else {
            Write-Host "Failed to install Vencord (Exit code: $($installProcess.ExitCode))" -ForegroundColor Red
            Write-Log "ERROR: Vencord installation failed with exit code $($installProcess.ExitCode)"
            Write-Host "`nPress any key to continue launching Discord anyway..."
            pause
        }
    }
    else {
        Write-Log "Vencord is up to date. No reinstall needed."
    }
    
    # Launch Discord
    Write-Host "`nLaunching Discord..." -ForegroundColor Green
    Write-Log "Launching Discord..."
    
    $discordExe = Get-DiscordExePath
    if ($discordExe) {
        # Use Update.exe with --processStart to launch Discord properly
        Start-Process -FilePath $discordExe -ArgumentList "--processStart", "Discord.exe"
        Write-Log "Discord launched successfully."
    }
    else {
        Write-Log "ERROR: Discord executable not found!"
        Write-Host "Could not find Discord executable." -ForegroundColor Red
        pause
        exit 1
    }
    
    Write-Log "=== Discord Launcher Finished ===`n"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    pause
    exit 1
}
