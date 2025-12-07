# Vencord Auto-Updater

Automatically detect Discord updates and reinstall Vencord before launching Discord, so you never have to manually reinstall it again!

## 🎯 Problem Solved

Discord frequently updates itself, which removes the Vencord patch. This tool automatically:
- Detects when Discord has been updated
- Reinstalls Vencord using `winget install Vendicated.Vencord`
- Launches Discord with Vencord already patched

## 📋 Prerequisites

- Windows 10/11
- [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (Windows Package Manager) installed
- Discord installed
- PowerShell 5.1 or higher

## 🚀 Quick Start

### Option 1: Using the Installer (Easiest)

1. **Download** `VencordAutoUpdaterInstaller.exe` from the releases
2. **Run the installer** and click "Install"
3. **Done!** Use the new shortcuts to launch Discord

The installer provides a GUI with options to:
- ✅ Install to `AppData\Roaming\Vencord\AutoUpdater`
- ✅ Create/manage desktop and Start Menu shortcuts
- ✅ Uninstall completely

Notes:
- Shortcuts are named `Discord.lnk` (desktop + Start Menu) and use Discord's `app.ico`.
- For correct taskbar grouping, unpin any old Discord icon and pin the new shortcut.

### Option 2: Manual PowerShell Setup

1. **Clone or download this repository** to a permanent location
   
   Recommended: `C:\Users\<User>\AppData\Roaming\Vencord\AutoUpdater`
   
   Alternative locations:
   - `C:\Users\<User>\Documents\VencordAutoUpdater`
   - Any location you prefer (just don't move it after setup)

2. **Run the setup script** in PowerShell:
   ```powershell
   cd "C:\Users\<User>\AppData\Roaming\Vencord\AutoUpdater"
   .\Setup.ps1 -All
   ```

3. **Done!** The setup will:
   - Create new shortcuts on Desktop and Start Menu
   - Leave your existing Discord shortcuts untouched (pin the new ones manually if you like)

### Option 3: Manual Usage

Simply run the launcher script whenever you want to start Discord:

```powershell
.\DiscordLauncher.ps1
```

## 🔨 Building the Installer

If you want to compile the installer yourself:

```powershell
cd ./Installer
./Build-Installer.ps1
```

See [`Installer/BUILD.md`](Installer/BUILD.md) for detailed build instructions.

**Requirements:**
- .NET 6.0 SDK or higher
- Windows 10/11

## 📁 Files

- **`DiscordLauncher.ps1`** - Main script that checks for updates and launches Discord
- **`Setup.ps1`** - Setup utility to create shortcuts and configure your system
- **`discord-version.json`** - Stores Discord version info (auto-generated)
- **`update-log.txt`** - Log file tracking all updates and launches

## 🔧 How It Works

1. **Version Detection**: The launcher calculates a SHA256 hash of Discord's `app.asar` file
2. **Comparison**: Compares the current hash with the previously stored hash
3. **Update Detection**: If hashes differ, Discord has been updated
4. **Auto-Reinstall**: Automatically runs `winget install Vendicated.Vencord --silent`
5. **Launch**: Starts Discord with Vencord freshly installed

## 📖 Usage Examples

### Basic Launch
```powershell
.\DiscordLauncher.ps1
```

### Force Reinstall Vencord
```powershell
.\DiscordLauncher.ps1 -Force
```

### Setup Options

```powershell
# Create desktop and start menu shortcuts only
.\Setup.ps1 -CreateShortcut

# Replace existing Discord shortcuts
.\Setup.ps1 -ReplaceStartMenu

# Do everything
.\Setup.ps1 -All
```

## 🎨 Customization

### Pin to Taskbar

1. Right-click the new "Discord (Auto-Update Vencord)" shortcut
2. Select "Pin to taskbar"
3. Unpin the old Discord icon if desired

### Restore Original Shortcuts

If you want to go back to the original Discord shortcuts:

1. Find the `.original.lnk` backup files
2. Remove the `.original` from the filename
3. Delete the auto-updater shortcuts

## 🐛 Troubleshooting

### "Discord installation not found"
- Make sure Discord is installed in the default location (`%LOCALAPPDATA%\Discord`)
- The script supports Discord Stable, PTB, and Canary

### "Vencord installation failed"
- Ensure winget is installed: `winget --version`
- Try running manually: `winget install Vendicated.Vencord`
- Check you have internet connection

### PowerShell Execution Policy Error
Run this command in an elevated PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Shortcut doesn't work
- Make sure you didn't move the script files after running Setup.ps1
- Right-click the shortcut → Properties → check the "Target" path is correct
- Re-run Setup.ps1 if needed

## 📝 Logs

All operations are logged to `update-log.txt` in the script directory. Check this file if you need to troubleshoot issues or see when Discord was updated.

Example log entry:
```
[2025-12-06 10:30:15] === Discord Launcher Started ===
[2025-12-06 10:30:15] Discord found at: C:\Users\...\Discord\app-1.0.9046\resources\app.asar
[2025-12-06 10:30:15] Discord version change detected!
[2025-12-06 10:30:15] Installing Vencord via winget...
[2025-12-06 10:30:25] Vencord installation succeeded.
[2025-12-06 10:30:25] Launching Discord...
```

## ⚙️ Advanced Configuration

### Supported Discord Variants

The launcher automatically detects:
- Discord Stable (`%LOCALAPPDATA%\Discord`)
- Discord PTB (`%LOCALAPPDATA%\DiscordPTB`)
- Discord Canary (`%LOCALAPPDATA%\DiscordCanary`)

### Silent Mode

The launcher runs in a hidden window by default when launched via shortcuts. To see output, run directly in PowerShell.

## 🤝 Contributing

Feel free to submit issues or pull requests if you have improvements!

## 📄 License

This project is free to use and modify as needed.

## 📦 What's Included

- **VencordAutoUpdaterInstaller.exe** - GUI installer with Install/Manage/Uninstall options
- **DiscordLauncher.ps1** - Core launcher that detects updates and reinstalls Vencord
- **Setup.ps1** - PowerShell setup utility for manual installation
- **Installer/Build-Installer.ps1** - Build script to compile the installer
- Full documentation and quick start guides

## 🌟 Features

✅ Automatic Discord update detection via SHA256 hash comparison  
✅ Silent Vencord reinstallation using winget  
✅ GUI installer for easy setup  
✅ Desktop and Start Menu shortcuts with Discord icon  
✅ Leaves existing Discord shortcuts untouched; pin the new shortcut if desired  
✅ Complete uninstall with restoration of original shortcuts  
✅ Detailed logging for troubleshooting  
✅ Supports Discord Stable, PTB, and Canary  
✅ No manual intervention needed - set it and forget it!  

## ⚠️ Disclaimer

This tool is not affiliated with Discord Inc. or Vencord. Use at your own risk. Always keep backups of important data.

---

**Enjoy Discord with Vencord, always up to date! 🎉**
