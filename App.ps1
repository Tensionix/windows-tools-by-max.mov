# Audion Windows Tools by Max.mov — Entry Point
#
# UTF-8 WITH BOM — deliberately, unlike the .psd1 data files. Windows PowerShell 5.1 decodes a
# BOM-less script as ANSI, which would turn the Russian elevation message below into mojibake on
# the 5.1 fallback path. Verified on both hosts: with the BOM the text survives, without it 5.1
# mangles it. Do not "normalise" this file to BOM-less.
#
# Start.exe in the project root is the entry point — the only one. It resolves PowerShell (bundled
# portable 7, then system 7, then Windows PowerShell 5.1) and gives the window its own taskbar
# identity. Engine\Launch.bat does the same resolution without the executable, for the single case
# Start.exe cannot cover: Windows refusing to run an unsigned local .exe. It is a fallback, not a
# second way in.
# Directly, for development:  pwsh -STA -ExecutionPolicy Bypass -File App.ps1

param()
$ErrorActionPreference = 'Stop'

try {
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding  = $utf8
    [Console]::OutputEncoding = $utf8
    Set-Variable -Name OutputEncoding -Scope Global -Value $utf8
} catch {}

# Detect the exact pwsh.exe running this script so self-elevation uses the same binary
# (works correctly with both system pwsh and the portable installation under Engine\PowerShell\)
$thisPwsh = (Get-Process -Id $PID).MainModule.FileName

# Hide this process's console window — the app IS the WPF window, not the console.
# Launch.bat starts hidden, but the elevation relaunch (RunAs) would otherwise pop a
# visible console; hide it here so every incarnation is windowless. Safe no-op if absent.
try {
    Add-Type -Namespace Native -Name ConsoleWin -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow();
[System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
'@
    $__con = [Native.ConsoleWin]::GetConsoleWindow()
    if ($__con -ne [System.IntPtr]::Zero) { [Native.ConsoleWin]::ShowWindow($__con, 0) | Out-Null }  # 0 = SW_HIDE
} catch {}

# Declining the UAC prompt makes Start-Process throw. With the console hidden that used to kill the
# app in complete silence — click, nothing happens, no reason given. Say why instead.
function Start-Elevated([string]$Exe, [string[]]$ArgList) {
    try {
        Start-Process $Exe -ArgumentList $ArgList -Verb RunAs
        return $true
    } catch {
        try {
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show(
                "Программа настраивает Windows и поэтому запускается только с правами администратора. Запрос прав был отклонён, ничего не изменено." + [Environment]::NewLine + [Environment]::NewLine +
                "This app configures Windows and therefore only runs with administrator rights. The elevation request was declined; nothing was changed.",
                'Audion Windows Tools by Max.mov', 'OK', 'Information') | Out-Null
        } catch {}
        return $false
    }
}

# ── STA check (WPF requires single-threaded apartment) ────────────────────────
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $argList = @('-STA', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', "`"$PSCommandPath`"")
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Start-Process $thisPwsh -ArgumentList $argList
    } else {
        Start-Elevated $thisPwsh $argList | Out-Null
    }
    exit
}

# ── Elevation check ────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $argList = @('-STA', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', "`"$PSCommandPath`"")
    Start-Elevated $thisPwsh $argList | Out-Null
    exit
}

# ── Load engine ────────────────────────────────────────────────────────────────
$enginePath = Join-Path $PSScriptRoot 'Engine\TweakEngine.psm1'
if (-not (Test-Path $enginePath)) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Engine not found: $enginePath", 'Audion Windows Tools by Max.mov', 'OK', 'Error') | Out-Null
    exit 1
}
Import-Module $enginePath -Force -DisableNameChecking

# ── Load manifests (all .psd1 in Manifests\, sorted by Order) ─────────────────
$manifestDir = Join-Path $PSScriptRoot 'Manifests'
$sections = Get-ChildItem $manifestDir -Filter '*.psd1' | Sort-Object Name | ForEach-Object {
    Import-TweakDataFile $_.FullName
}

# ── Query system profile ───────────────────────────────────────────────────────
$sysProfile = Get-SystemProfile
$gpuVendors = @($sysProfile.GpuVendors) -join '/'
$gpuNames = @($sysProfile.GpuNames) -join ', '
if ([string]::IsNullOrWhiteSpace($gpuNames)) { $gpuNames = $sysProfile.GpuVendor }
Write-Host "System: $($sysProfile.OSCaption) Build $($sysProfile.Build) · Edition: $($sysProfile.Edition) · GPU: $gpuVendors ($gpuNames)"

# ── Launch WPF window ──────────────────────────────────────────────────────────
# The markup ships inside Engine\ with the rest of the engine; the project root stays for content
# the user actually opens. AppRoot is passed explicitly rather than inferred from the markup's path.
$xamlPath = Join-Path $PSScriptRoot 'Engine\MainWindow.xaml'
Start-TunerWindow -XamlPath $xamlPath -Sections $sections -SystemProfile $sysProfile -AppRoot $PSScriptRoot
