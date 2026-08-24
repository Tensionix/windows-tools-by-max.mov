# UTF-8 without BOM
[CmdletBinding()]
param(
    [string]$AppRoot = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($AppRoot)) {
    $AppRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$AppRoot = [System.IO.Path]::GetFullPath($AppRoot)

$sourcePath = Join-Path $PSScriptRoot 'Start.cs'
$iconSourcePath = Join-Path $AppRoot 'Assets\MaxMovLauncher.png'
$iconPath = Join-Path $AppRoot 'Assets\MaxMovLauncher.ico'
$appScript = Join-Path $AppRoot 'App.ps1'
$outputPath = Join-Path $AppRoot 'Start.exe'

foreach ($requiredPath in @($sourcePath, $iconSourcePath, $iconPath, $appScript)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required launcher file not found: $requiredPath"
    }
}

$compilerCandidates = @(
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
)
$compiler = $compilerCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $compiler) {
    throw 'The Windows .NET Framework C# compiler was not found.'
}

$compilerArguments = @(
    '/nologo',
    '/target:winexe',
    '/optimize+',
    '/platform:anycpu',
    '/codepage:65001',
    "/win32icon:$iconPath",
    '/reference:System.dll',
    '/reference:System.Core.dll',
    '/reference:System.Windows.Forms.dll',
    "/out:$outputPath",
    $sourcePath
)
& $compiler @compilerArguments
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
    throw "Start.exe build failed with exit code $LASTEXITCODE."
}

& $outputPath '--self-test'
if ($LASTEXITCODE -ne 0) {
    throw "Start.exe self-test failed with exit code $LASTEXITCODE."
}

Write-Output "Built: $outputPath"
Write-Output "Icon:  $iconPath (source: $iconSourcePath)"
