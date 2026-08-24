# UTF-8 without BOM
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$launcher = Join-Path $root 'Start.exe'
$iconPath = Join-Path $root 'Assets\MaxMovLauncher.ico'
$identityModule = Join-Path $root 'Engine\WindowIdentity.psm1'
$engineModule = Join-Path $root 'Engine\TweakEngine.psm1'
$xamlPath = Join-Path $root 'Engine\MainWindow.xaml'

foreach ($path in @($launcher, $iconPath, $identityModule, $engineModule, $xamlPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Launcher identity artifact is missing: $path"
    }
}

$identityText = Get-Content -LiteralPath $identityModule -Raw -Encoding UTF8
foreach ($pattern in @(
    'SetCurrentProcessExplicitAppUserModelID',
    'SHGetPropertyStoreForWindow',
    'RelaunchIconResourcePropertyId',
    'SetWindowIdentity',
    'SetWindowIcons',
    'WindowSetIconMessage',
    'store\.Commit',
    'Marshal\.StringToCoTaskMemUni',
    '\$iconResource\s*=\s*\$startPath\s*\+\s*'',-32512''',
    'EnsureHandle',
    'Add_ContentRendered',
    'Audion\.WindowsTools\.MaxMov'
)) {
    if ($identityText -notmatch $pattern) {
        throw "Taskbar identity wiring is missing: $pattern"
    }
}

$engineText = Get-Content -LiteralPath $engineModule -Raw -Encoding UTF8
foreach ($pattern in @('WindowIdentity\.psm1', 'Set-AwtWindowIdentity')) {
    if ($engineText -notmatch $pattern) {
        throw "Tweak engine does not apply the window identity: $pattern"
    }
}

$bytes = [System.IO.File]::ReadAllBytes($launcher)
if ($bytes.Length -lt 512 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    throw 'Start.exe is not a valid PE image.'
}
$peOffset = [BitConverter]::ToInt32($bytes, 0x3C)
$optionalHeader = $peOffset + 24
$subsystem = [BitConverter]::ToUInt16($bytes, $optionalHeader + 68)
if ($subsystem -ne 2) {
    throw "Start.exe must use the Windows GUI subsystem; actual subsystem: $subsystem"
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml
$iconStream = [System.IO.File]::OpenRead($iconPath)
try {
    $iconDecoder = [System.Windows.Media.Imaging.IconBitmapDecoder]::new(
        $iconStream,
        [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
        [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    )
} finally {
    $iconStream.Dispose()
}
$iconSizes = @($iconDecoder.Frames | ForEach-Object { [int]$_.PixelWidth } | Sort-Object -Unique)
foreach ($requiredSize in @(16, 24, 32, 48, 64, 128, 256)) {
    if ($requiredSize -notin $iconSizes) {
        throw "Application ICO is missing the required ${requiredSize}px frame."
    }
}

$process = Start-Process -FilePath $launcher -ArgumentList '--self-test' -PassThru -Wait
if ($process.ExitCode -ne 0) {
    throw "Start.exe self-test failed with exit code $($process.ExitCode)."
}

Import-Module $identityModule -Force -DisableNameChecking
[xml]$xaml = Get-Content -LiteralPath $xamlPath -Raw -Encoding UTF8
$reader = [System.Xml.XmlNodeReader]::new($xaml)
try {
    $window = [System.Windows.Markup.XamlReader]::Load($reader)
} finally {
    $reader.Close()
}
Set-AwtWindowIdentity -Window $window -AppRoot $root
$helper = [System.Windows.Interop.WindowInteropHelper]::new($window)
if ($helper.Handle -eq [IntPtr]::Zero) {
    throw 'The WPF window handle was not created.'
}
if ($null -eq $window.Icon) {
    throw 'The explicit WPF application icon was not assigned.'
}
$window.Close()

Write-Output 'PASS: Start.exe carries the icon and the WPF window receives its taskbar identity.'
