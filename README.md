# VencordAutoUpdater

Tired of having to reinstall Vencord every time discord decides to update itself? 

Instead, detect Discord updates and reinstall Vencord before launching Discord, so you never have to manually reinstall it again!

## Contents

- `DiscordLauncher.ps1`: PowerShell script to launch Discord with custom parameters or automation.
- `LaunchDiscord.vbs`: VBScript to launch Discord, can be used for shortcut integration or silent launching.
- `Setup.ps1`: PowerShell setup script for initial configuration or environment setup.


## Usage

### Option 1: Download and Run the Installer

Simply download the EXE file from the [releases page](https://github.com/x-chap/VencordAutoUpdater/releases/latest) and run it to install VencordAutoUpdater.

**MAKE SURE YOU UNPIN YOUR OLD DISCORD SHORTCUT ON YOUR TASKBAR.**

The EXE places all files into `AppData\Roaming\Vencord\AutoUpdater`.

### Option 2: Use the VBScript (Silent PowerShell)
*This is what the Installer does, but feel free to do it manually.*

- `LaunchDiscord.vbs`: This VBScript launches `DiscordLauncher.ps1` using PowerShell with the window hidden. It is useful for creating shortcuts or launching Discord silently, without showing a console window.

**How to use:**

1. Place `LaunchDiscord.vbs` and `DiscordLauncher.ps1` in the same directory.

    It is recommended to place them in `AppData\Roaming\Vencord\AutoUpdater\` for creating a shortcut.
2. Double-click `LaunchDiscord.vbs` to launch Discord silently.
3. You can also create a shortcut to `LaunchDiscord.vbs` for easy access.

    Shortcut target: `C:\WINDOWS\system32\wscript.exe "C:\Users\<User>\AppData\Roaming\Vencord\AutoUpdater\LaunchDiscord.vbs"`.

    Make sure you unpin your old discord shortcut.



## Requirements

- Windows 10 or later
- [WinGet](https://www.powershellgallery.com/packages/Microsoft.WinGet.Client/1.11.460)
- PowerShell 5.1 or later

## License

Feel free to use/modify it. Vencord, if you would like to incorporate this into the mod lmk! 

## Credits

Created by Xander.

## Disclaimer.

This tool is not affiliated with Discord Inc. or Vencord. Use at your own risk. Always keep backups of important data.
