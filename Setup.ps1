# Setup Script for Vencord Auto-Updater
# This script sets up shortcuts and configures Windows to use the launcher

param(
    [switch]$CreateShortcut,
    [switch]$All,
    [switch]$NoPrompt
)

$ErrorActionPreference = "Stop"

Write-Host "=== Vencord Auto-Updater Setup ===" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$launcherPath = Join-Path $scriptDir "DiscordLauncher.ps1"
$vbsLauncherPath = Join-Path $scriptDir "LaunchDiscord.vbs"
$discordAppId = "com.squirrel.Discord.Discord"

# Ensure taskbar grouping with Discord by setting AppUserModelID
function Set-AppUserModelId {
        param(
                [Parameter(Mandatory=$true)][string]$ShortcutPath,
                [Parameter(Mandatory=$true)][string]$AppId
        )

        if (-not (Test-Path $ShortcutPath)) { return }

        $csharp = @'
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

[ComImport, InterfaceType(ComInterfaceType.InterfaceIsIUnknown), Guid("000214F9-0000-0000-C000-000000000046")]
interface IShellLinkW {
    void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszFile, int cchMaxPath, out IntPtr pfd, int fFlags);
    void GetIDList(out IntPtr ppidl);
    void SetIDList(IntPtr pidl);
    void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszName, int cchMaxName);
    void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
    void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszDir, int cchMaxPath);
    void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
    void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszArgs, int cchMaxPath);
    void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
    void GetHotkey(out short pwHotkey);
    void SetHotkey(short wHotkey);
    void GetShowCmd(out int piShowCmd);
    void SetShowCmd(int iShowCmd);
    void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pszIconPath, int cchIconPath, out int piIcon);
    void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
    void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, int dwReserved);
    void Resolve(IntPtr hwnd, int fFlags);
    void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
}

[ComImport, Guid("0000010B-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IPersistFile {
    void GetClassID(out Guid pClassID);
    void IsDirty();
    void Load([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, uint dwMode);
    void Save([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, bool fRemember);
    void SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string pszFileName);
    void GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string ppszFileName);
}

[ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IPropertyStore {
    void GetCount(out uint cProps);
    void GetAt(uint iProp, out PROPERTYKEY pkey);
    void GetValue(ref PROPERTYKEY key, out PROPVARIANT pv);
    void SetValue(ref PROPERTYKEY key, ref PROPVARIANT pv);
    void Commit();
}

[StructLayout(LayoutKind.Sequential, Pack = 4)]
struct PROPERTYKEY {
    public Guid fmtid;
    public uint pid;
}

[StructLayout(LayoutKind.Sequential)]
struct PROPVARIANT {
    public ushort vt;
    public ushort wReserved1;
    public ushort wReserved2;
    public ushort wReserved3;
    public IntPtr p;
    public int p2;
}

static class PropVariantHelper {
    public static PROPVARIANT FromString(string value) {
        var pv = new PROPVARIANT();
        pv.vt = 31; // VT_LPWSTR
        pv.p = Marshal.StringToCoTaskMemUni(value);
        return pv;
    }
}

public static class ShortcutAppIdSetter {
    static Guid CLSID_ShellLink = new Guid("00021401-0000-0000-C000-000000000046");
    static PROPERTYKEY PKEY_AppUserModel_ID = new PROPERTYKEY { fmtid = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"), pid = 5 };

    public static void SetAppId(string shortcutPath, string appId) {
        var link = (IShellLinkW)Activator.CreateInstance(Type.GetTypeFromCLSID(CLSID_ShellLink));
        ((IPersistFile)link).Load(shortcutPath, 2); // STGM_READWRITE
        var propStore = (IPropertyStore)link;
        var key = PKEY_AppUserModel_ID;
        var pv = PropVariantHelper.FromString(appId);
        propStore.SetValue(ref key, ref pv);
        propStore.Commit();
        ((IPersistFile)link).Save(shortcutPath, true);
    }
}
'@

        try {
                Add-Type -TypeDefinition $csharp -ErrorAction Stop | Out-Null
                [ShortcutAppIdSetter]::SetAppId($ShortcutPath, $AppId)
        }
        catch {
                # If setting AppID fails, continue silently
        }
}

if (-not (Test-Path $launcherPath)) {
    Write-Host "ERROR: DiscordLauncher.ps1 not found in $scriptDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $vbsLauncherPath)) {
    Write-Host "ERROR: LaunchDiscord.vbs not found in $scriptDir" -ForegroundColor Red
    exit 1
}

# Create desktop shortcut
function New-DesktopShortcut {
    Write-Host "Creating desktop shortcut..." -ForegroundColor Yellow
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Discord.lnk"
    
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "wscript.exe"
    $shortcut.Arguments = "`"$vbsLauncherPath`""
    $shortcut.WorkingDirectory = $scriptDir
    $shortcut.IconLocation = "$env:LOCALAPPDATA\Discord\app.ico"
    $shortcut.Description = "Launch Discord with automatic Vencord reinstall on updates"
    $shortcut.Save()

    Set-AppUserModelId -ShortcutPath $shortcutPath -AppId $discordAppId
    
    Write-Host "Desktop shortcut created: $shortcutPath" -ForegroundColor Green
}

# Create Start Menu shortcut
function New-StartMenuShortcut {
    Write-Host "Creating Start Menu shortcut..." -ForegroundColor Yellow
    
    $startMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $shortcutPath = Join-Path $startMenuPath "Discord.lnk"
    
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPath`""
    $shortcut.WorkingDirectory = $scriptDir
    $shortcut.IconLocation = "$env:LOCALAPPDATA\Discord\app.ico"
    $shortcut.Description = "Launch Discord with automatic Vencord reinstall on updates"
    $shortcut.Save()

    Set-AppUserModelId -ShortcutPath $shortcutPath -AppId $discordAppId

    Write-Host "Start Menu shortcut created: $shortcutPath" -ForegroundColor Green
}

# Main setup logic
try {
    if ($All -or (-not $CreateShortcut)) {
        Write-Host "Running complete setup...`n" -ForegroundColor Cyan
        $CreateShortcut = $true
    }
    
    if ($CreateShortcut) {
        New-DesktopShortcut
        New-StartMenuShortcut
        Write-Host ""
    }
    
    Write-Host "=== Setup Complete! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use the new shortcuts to launch Discord." -ForegroundColor White
    Write-Host "Discord will automatically check for updates and reinstall Vencord when needed." -ForegroundColor White
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  - Pin the new shortcut to taskbar for easy access" -ForegroundColor Gray
    Write-Host "  - To force reinstall Vencord, run: .\DiscordLauncher.ps1 -Force" -ForegroundColor Gray
    Write-Host ""
    
    if (-not $NoPrompt) {
        # Ask if user wants to test launch
        $response = Read-Host "Do you want to test launch Discord now? (Y/N)"
        if ($response -match "^[Yy]") {
            Write-Host "`nLaunching Discord..." -ForegroundColor Cyan
            & $launcherPath
        }
    }
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
