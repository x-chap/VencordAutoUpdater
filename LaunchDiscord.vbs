Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
strLauncherPath = strScriptDir & "\DiscordLauncher.ps1"

' Launch PowerShell completely hidden (WindowStyle 0)
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strLauncherPath & """", 0, False
