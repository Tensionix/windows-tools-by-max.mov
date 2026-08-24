# Audion Windows Tools by Max.mov — Tweak Engine
# UTF-8 without BOM
# Engine is tweak-agnostic: it dispatches on Kind, never on specific tweak IDs.

Set-StrictMode -Off
$ErrorActionPreference = 'Stop'

# Module-level: set by Start-TunerWindow so script-block tweaks can reference it
$script:AppRoot         = $null
$script:Lang            = 'en'
$script:S               = $null   # active strings hashtable
$script:SidebarLangItems  = [System.Collections.Generic.List[object]]::new()   # sidebar TextBlock refs for lang refresh
$script:ToggleSuppressed  = $false  # guard: prevents recursive Checked/Unchecked events during programmatic IsChecked flip
$script:SelectedTweakIds  = [System.Collections.Generic.List[string]]::new()   # tweaks checked for selective Apply/Revert
$script:CurrentOpPowerShell = $null   # running [PowerShell] of the active footer Apply/Revert, so Cancel can stop it
$script:CurrentOpCancelSource = $null # CancellationTokenSource for that op — the only way to stop a native installer
$script:OpCancelled         = $false  # set by the Cancel button so the completion handler logs a cancel, not success
$script:OpStartTime         = $null   # when the active footer op began — drives the elapsed-time indicator (no deadline)
$script:LineSink            = $null   # set inside the background runspace to stream command output lines to the UI
$script:OutputQueue         = $null   # ConcurrentQueue for LineSink in background runspace
$script:TweakStateCache     = @{}     # short-lived Detect cache keyed by tweak id; keeps subsection switches snappy
$script:StatusRefreshVersion = 0      # monotonically increasing token; stale async Detect results are ignored
$script:StatusCacheTtlSeconds = 20
$script:TerminalMaxBlocks   = 500
$script:TerminalMaximized   = $false
$script:TerminalRestoreHeight = $null
$script:LogPanelAutoOpened  = $false
$script:TerminalPanelAutoOpened = $false

function Initialize-NativeCommandEncoding {
    try {
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        [Console]::InputEncoding  = $utf8
        [Console]::OutputEncoding = $utf8
        Set-Variable -Name OutputEncoding -Scope Global -Value $utf8
    } catch {}
}

Initialize-NativeCommandEncoding

function Write-OperationOutput([string]$Line) {
    if ($null -eq $script:LineSink) { return }
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    try { & $script:LineSink $Line } catch {}
}

function Write-FeatureCommandOutput([object]$Item) {
    if ($null -eq $Item) { return }
    $featureName = $Item.PSObject.Properties['FeatureName']
    $state       = $Item.PSObject.Properties['State']
    if ($featureName -or $state) {
        $nameText  = if ($featureName) { "$($featureName.Value)" } else { 'feature' }
        $stateText = if ($state) { "$($state.Value)" } else { 'updated' }
        Write-OperationOutput "Feature result: $nameText -> $stateText"
        return
    }
    Write-OperationOutput "$Item"
}

#region ════════════════ MANIFEST LOADING ════════════════

# Manifests and Themes.psd1 must load identically on PowerShell 7 and on Windows PowerShell 5.1,
# which both launchers still fall back to. Import-PowerShellDataFile cannot be that single path:
#
#   * these files are UTF-8 without a BOM, and 5.1 decodes BOM-less files as the ANSI code page —
#     every Cyrillic string becomes mojibake and the box-drawing characters in the comments turn
#     into hard parse errors (13 of them in Section11.psd1 alone);
#   * its SafeGetValue() also refuses any data file past 500 key/value pairs, and every manifest
#     here is far beyond that.
#
# So read the bytes as UTF-8 ourselves, prove the file is exactly one hashtable literal — loading a
# manifest still cannot execute anything on its own — and then evaluate only that literal. The
# Apply/Detect/Revert blocks inside stay inert until the engine invokes them, exactly as before.
function Import-TweakDataFile {
    [OutputType([hashtable])]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path)) { throw "Data file not found: $Path" }

    # detectEncodingFromByteOrderMarks still honours a BOM when one is present.
    $text = [System.IO.File]::ReadAllText($Path, (New-Object System.Text.UTF8Encoding($false)))

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref]$tokens, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) {
        throw "Data file '$Path' has syntax errors: $($errors[0].Message)"
    }
    if (-not $ast.EndBlock) { throw "Data file '$Path' is empty." }

    $statements = @($ast.EndBlock.Statements)
    if ($statements.Count -ne 1) {
        throw "Data file '$Path' must contain exactly one hashtable literal."
    }
    $pipeline   = $statements[0] -as [System.Management.Automation.Language.PipelineAst]
    $expression = if ($pipeline) { $pipeline.GetPureExpression() } else { $null }
    if ($expression -isnot [System.Management.Automation.Language.HashtableAst]) {
        throw "Data file '$Path' must contain exactly one hashtable literal."
    }

    # Invoked from inside this module, so the script blocks the literal creates inherit the module's
    # session state and can see the engine's helpers — the same scope they already ran in.
    & ([scriptblock]::Create($expression.Extent.Text))
}

#endregion

#region ════════════════ NATIVE PROCESS RUNNER ════════════════

# Installers are launched here, never through the PowerShell pipeline.
#
# App.ps1 hides the app's own console, so a native tool that decides to prompt — winget's source
# agreements, an installer-hash confirmation, a stray `pause` in a .cmd — used to block on stdin with
# nothing on screen. The card sat on "Installing…" forever and Cancel could not free it, because
# [PowerShell]::Stop() cannot interrupt a native child blocked inside a pipeline.
#
# Invoke-NativeProcess closes all three holes:
#   * stdin is redirected and closed immediately, so any prompt reads EOF and the tool exits itself;
#   * stdout/stderr are pumped asynchronously into the Terminal panel while the tool still runs;
#   * a wall-clock timeout and the operation's cancel token kill the process tree and return a verdict.
# It never throws on a non-zero exit — callers get a result hashtable and decide what to report.

$script:NativeProcessTimeoutSeconds = 900   # ceiling for one installer invocation
$script:CancelToken                 = $null # seeded per background op; polled by the wait loop

function Test-OperationCancelled {
    $token = $script:CancelToken
    if (-not $token) { return $false }
    try { [bool]$token.IsCancellationRequested } catch { $false }
}

function Stop-NativeProcessTree([int]$ProcessId) {
    if ($ProcessId -le 0) { return }
    # /T so the installer's own children (msiexec, setup.exe) die with it — killing only the
    # launcher would leave the real installer running invisibly.
    try { & taskkill.exe /PID $ProcessId /T /F 2>&1 | Out-Null } catch {}
}

# .NET Framework has no ProcessStartInfo.ArgumentList, and the app still runs under Windows
# PowerShell 5.1 as a fallback — quote by hand so both runtimes behave the same.
function ConvertTo-NativeArgumentString([string[]]$Arguments) {
    if (-not $Arguments -or $Arguments.Count -eq 0) { return '' }
    $parts = foreach ($a in $Arguments) {
        $text = [string]$a
        if ($text -match '[\s"]') {
            '"' + ($text -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
        } else {
            $text
        }
    }
    $parts -join ' '
}

function Invoke-NativeProcess {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$Arguments = @(),
        [int]$TimeoutSeconds = 0,
        [ValidateSet('utf8', 'oem')][string]$Encoding = 'utf8',   # cmd.exe and legacy setup tools speak OEM
        [switch]$Quiet          # collect output but keep it out of the Terminal panel
    )

    if ($TimeoutSeconds -le 0) { $TimeoutSeconds = $script:NativeProcessTimeoutSeconds }

    $result = @{
        ExitCode  = -1
        Output    = [System.Collections.Generic.List[string]]::new()
        TimedOut  = $false
        Cancelled = $false
        Started   = $false
        Error     = $null
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = $FilePath
    $psi.Arguments              = ConvertTo-NativeArgumentString $Arguments
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true
    $psi.RedirectStandardInput  = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    try {
        $enc = New-Object System.Text.UTF8Encoding($false)
        if ($Encoding -eq 'oem') {
            # cmd.exe scripts and older vendor installers write in the console OEM code page —
            # decoding those as UTF-8 turns every localized line into mojibake.
            try {
                $oemPage = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage
                if ($oemPage -gt 0) { $enc = [System.Text.Encoding]::GetEncoding($oemPage) }
            } catch {}
        }
        $psi.StandardOutputEncoding = $enc
        $psi.StandardErrorEncoding  = $enc
    } catch {}

    $proc = $null
    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
    } catch {
        $result.Error = "$($_.Exception.Message)"
        return $result
    }
    if (-not $proc) {
        $result.Error = 'Process did not start.'
        return $result
    }
    $result.Started = $true

    # The anti-hang guarantee: no stdin means no prompt can ever wait for a keypress we cannot send.
    try { $proc.StandardInput.Close() } catch {}

    $emit = {
        param($line)
        if ($null -eq $line) { return }
        $result.Output.Add([string]$line) | Out-Null
        if (-not $Quiet) { Write-OperationOutput ([string]$line) }
    }

    $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds)
    $outTask  = $proc.StandardOutput.ReadLineAsync()
    $errTask  = $proc.StandardError.ReadLineAsync()
    $outDone  = $false
    $errDone  = $false
    $killed   = $false

    while (-not ($outDone -and $errDone)) {
        try {
            if (-not $outDone -and $outTask.Wait(60)) {
                $line = $outTask.Result
                if ($null -eq $line) { $outDone = $true } else { & $emit $line; $outTask = $proc.StandardOutput.ReadLineAsync() }
            }
        } catch { $outDone = $true }
        try {
            if (-not $errDone -and $errTask.Wait(60)) {
                $line = $errTask.Result
                if ($null -eq $line) { $errDone = $true } else { & $emit $line; $errTask = $proc.StandardError.ReadLineAsync() }
            }
        } catch { $errDone = $true }

        if (Test-OperationCancelled) {
            $result.Cancelled = $true
            $killed = $true
            break
        }
        if ([datetime]::UtcNow -gt $deadline) {
            $result.TimedOut = $true
            $killed = $true
            break
        }
    }

    if ($killed) {
        try { Stop-NativeProcessTree $proc.Id } catch {}
        try { $proc.WaitForExit(5000) | Out-Null } catch {}
        try { $result.ExitCode = $proc.ExitCode } catch { $result.ExitCode = -1 }
        try { $proc.Dispose() } catch {}
        return $result
    }

    try { $proc.WaitForExit(30000) | Out-Null } catch {}
    try { $result.ExitCode = $proc.ExitCode } catch { $result.ExitCode = -1 }
    try { $proc.Dispose() } catch {}
    $result
}

#endregion

#region ════════════════ PACKAGE / INSTALLER HELPERS ════════════════

# Verified against winget 1.29 on Windows 11 — the three codes an install button actually hits are
# NO_APPLICATIONS_FOUND, UPDATE_NOT_APPLICABLE and PACKAGE_ALREADY_INSTALLED. The rest are the
# documented APPINSTALLER_CLI_ERROR_* values; anything unlisted is reported as raw hex next to
# winget's own message, so the Terminal panel never claims more than it knows.
$script:WingetExitMeaning = @{
    0x8A150001 = 'InternalError'
    0x8A150002 = 'InvalidArguments'
    0x8A150003 = 'CommandFailed'
    0x8A150008 = 'DownloadFailed'
    0x8A150010 = 'NoApplicableInstaller'
    0x8A150011 = 'InstallerHashMismatch'
    0x8A150014 = 'NoPackageFound'
    0x8A150015 = 'NoSourcesDefined'
    0x8A150016 = 'MultiplePackagesFound'
    0x8A150019 = 'RequiresAdmin'
    0x8A15002B = 'NoApplicableUpdate'
    0x8A150044 = 'SystemNotSupported'
    0x8A150061 = 'AlreadyInstalled'
}

function Get-WingetExitMeaning([int]$ExitCode) {
    if ($ExitCode -eq 0) { return 'Ok' }
    if ($script:WingetExitMeaning.ContainsKey($ExitCode)) { return $script:WingetExitMeaning[$ExitCode] }
    'Unknown'
}

function Format-ExitCode([int]$ExitCode) {
    '{0} (0x{0:X8})' -f $ExitCode
}

$script:WingetPathResolved = $false   # winget.exe is resolved once per runspace, then cached
$script:WingetPathValue    = $null

function Get-WingetPath {
    if ($script:WingetPathResolved) { return $script:WingetPathValue }
    $script:WingetPathResolved = $true
    $script:WingetPathValue    = $null

    $cmd = Get-Command 'winget.exe' -CommandType Application -EA SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.Source) { $script:WingetPathValue = $cmd.Source; return $script:WingetPathValue }

    # The App Execution Alias is not always on PATH in an elevated session — fall back to the
    # installed App Installer package.
    $alias = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
    if (Test-Path $alias) { $script:WingetPathValue = $alias; return $script:WingetPathValue }

    $pkgRoot = Join-Path $env:ProgramW6432 'WindowsApps'
    if (-not (Test-Path $pkgRoot)) { $pkgRoot = Join-Path $env:ProgramFiles 'WindowsApps' }
    $pkg = Get-ChildItem $pkgRoot -Filter 'Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe' -Directory -EA SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($pkg) {
        $exe = Join-Path $pkg.FullName 'winget.exe'
        if (Test-Path $exe) { $script:WingetPathValue = $exe }
    }
    $script:WingetPathValue
}

# winget only reports packages it can correlate with its own source. Machine-wide runtimes that
# Windows ships or that self-update write SystemComponent=1 uninstall entries, which winget skips —
# so `winget list` answers "not installed" for software that is very much installed. WebView2 is the
# case that bit us: the card stayed "not installed" forever and every click re-ran a 170 MB download.
# Every install card therefore gets this registry-backed second opinion.
$script:UninstallIndex = $null   # ARP entries are enumerated once per runspace, then reused

# Walking the three uninstall hives costs roughly as much as one registry read per installed product,
# so a subsection with five install cards used to pay for the same walk five times. Build the list
# once and answer every later question from memory.
function Get-UninstallIndex {
    if ($null -ne $script:UninstallIndex) { return $script:UninstallIndex }

    $index = [System.Collections.Generic.List[object]]::new()
    foreach ($root in @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    )) {
        try {
            foreach ($entry in (Get-ChildItem $root -EA SilentlyContinue)) {
                $item = Get-ItemProperty $entry.PSPath -EA SilentlyContinue
                if (-not $item -or -not $item.PSObject.Properties['DisplayName']) { continue }
                $display = [string]$item.DisplayName
                if ([string]::IsNullOrWhiteSpace($display)) { continue }
                $index.Add([pscustomobject]@{
                    Name    = $display
                    Version = if ($item.PSObject.Properties['DisplayVersion']) { [string]$item.DisplayVersion } else { '' }
                    Source  = [string]$entry.PSPath
                }) | Out-Null
            }
        } catch {}
    }
    $script:UninstallIndex = $index
    $index
}

function Get-InstalledProductInfo {
    param(
        [Parameter(Mandatory)][string]$NamePattern,
        [string[]]$ExplicitKeys = @()
    )

    foreach ($key in $ExplicitKeys) {
        try {
            $item = Get-ItemProperty -Path $key -EA SilentlyContinue
            if ($item) {
                $version = if ($item.PSObject.Properties['pv']) { [string]$item.pv } elseif ($item.PSObject.Properties['DisplayVersion']) { [string]$item.DisplayVersion } else { '' }
                $name    = if ($item.PSObject.Properties['name']) { [string]$item.name } elseif ($item.PSObject.Properties['DisplayName']) { [string]$item.DisplayName } else { $NamePattern }
                if (-not [string]::IsNullOrWhiteSpace($version) -or -not [string]::IsNullOrWhiteSpace($name)) {
                    return @{ Name = $name; Version = $version; Source = $key }
                }
            }
        } catch {}
    }

    foreach ($entry in (Get-UninstallIndex)) {
        if ($entry.Name -match $NamePattern) {
            return @{ Name = $entry.Name; Version = $entry.Version; Source = $entry.Source }
        }
    }
    $null
}

# WebView2's authoritative marker is the EdgeUpdate client GUID Microsoft documents for it — the
# only place a machine-wide install reliably shows up.
function Get-WebView2RuntimeInfo {
    Get-InstalledProductInfo -NamePattern 'WebView2' -ExplicitKeys @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
        'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
        'HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
    )
}

$script:WingetInventory        = $null   # cached `winget list` output lines
$script:WingetInventoryTried   = $false  # remembers a failed attempt so N cards do not retry N times

# Set while a manifest Detect block runs. Detect happens on every subsection switch, with the user
# watching a half-drawn page, so it may USE the winget listing but must never BUILD it: that costs
# ~12 s and reads as a freeze. Apply leaves this false — there, waiting for winget is the job.
# Every Detect block that asks about a package also passes a registry name pattern, and the registry
# is both faster and able to see per-user installs, so skipping the second opinion costs almost
# nothing: it only matters for a package whose ARP name does not match its pattern, and Refresh or
# any install rebuilds the listing anyway.
$script:PackageQueryNonBlocking = $false
# 4 hours, not the 10 minutes this started at. The listing costs about 12 s to rebuild, and time is
# the weakest reason to throw it away: the events that genuinely invalidate it — installing, removing,
# or pressing Refresh — all call Clear-PackageCaches already. A 10-minute expiry only guarded against
# a package installed OUTSIDE this program, which the registry check answers first anyway, and it
# charged that 12 s again to anyone who walked the sections twice in an afternoon.
$script:WingetInventoryTtlMins = 240

# Each status refresh runs in a fresh runspace, so an in-memory cache alone would be thrown away
# every time the user switches subsection — and winget would be paid again. The listing therefore
# also lands in a short-lived file under Data\, next to the app's other portable state.
function Get-WingetInventoryCachePath {
    try {
        $dir = Get-DataDir
        if ([string]::IsNullOrWhiteSpace($dir)) { return $null }
        return (Join-Path $dir 'winget-list.cache')
    } catch { return $null }
}

# One `winget list` answers every package question in a refresh. Asking per package cost ~1.5 s each
# and a browser subsection asks five times; the full listing costs the same as a single query and is
# parsed from memory afterwards. Verified on winget 1.29: redirected output is not column-truncated,
# so an exact id token match on the full listing is as reliable as `--id ... --exact`.
# 30 s, not the 120 s this used to allow. This runs inside a status refresh, where the user is looking
# at a subsection that has not finished drawing — and `winget list` measured 12 s on a normal machine,
# so anything approaching two minutes is not slowness, it is a hang with a timer on it. If winget
# cannot answer in 30 s it will not answer usefully, and returning $null lets the registry answer
# stand instead of freezing the interface behind it.
function Get-WingetInventory {
    param([int]$TimeoutSeconds = 30)

    if ($script:WingetInventoryTried) { return $script:WingetInventory }
    $script:WingetInventoryTried = $true

    $cachePath = Get-WingetInventoryCachePath
    if ($cachePath -and (Test-Path $cachePath)) {
        try {
            $age = (Get-Date) - (Get-Item $cachePath).LastWriteTime
            if ($age.TotalMinutes -lt $script:WingetInventoryTtlMins) {
                $script:WingetInventory = @([System.IO.File]::ReadAllLines($cachePath, (New-Object System.Text.UTF8Encoding($false))))
                return $script:WingetInventory
            }
        } catch {}
    }

    # Nothing cached and we are inside a Detect: answer "unknown" instead of spending 12 s building
    # it while the interface waits. Do not latch WingetInventoryTried — the next Apply must still be
    # allowed to build it.
    if ($script:PackageQueryNonBlocking) {
        $script:WingetInventoryTried = $false
        return $null
    }

    $winget = Get-WingetPath
    if (-not $winget) { return $null }

    # No --source filter: a source-restricted list is both slower and blind to packages whose local
    # entry winget cannot correlate back to the remote source.
    $r = Invoke-NativeProcess -FilePath $winget -TimeoutSeconds $TimeoutSeconds -Quiet -Arguments @(
        'list', '--disable-interactivity', '--accept-source-agreements'
    )
    if ($r.TimedOut -or $r.Cancelled -or $r.ExitCode -ne 0) { return $null }

    $script:WingetInventory = @($r.Output)
    if ($cachePath) {
        try { [System.IO.File]::WriteAllLines($cachePath, $script:WingetInventory, (New-Object System.Text.UTF8Encoding($false))) } catch {}
    }
    $script:WingetInventory
}

# Installing or removing anything makes the caches stale — drop them, including the file, so the
# next question re-reads the machine instead of reporting the state it had before the click.
# Also called by the Refresh button, which must mean "ask again", not "show me the cache".
function Clear-PackageCaches {
    $script:UninstallIndex       = $null
    $script:WingetInventory      = $null
    $script:WingetInventoryTried = $false
    $cachePath = Get-WingetInventoryCachePath
    if ($cachePath -and (Test-Path $cachePath)) {
        try { Remove-Item $cachePath -Force -EA SilentlyContinue } catch {}
    }
}

# When stdout is redirected winget drops its column padding to a single space, so the fixed-width
# layout cannot be sliced — locate the id token instead and read the version that follows it.
function Get-WingetVersionFromListing([string[]]$Lines, [string]$PackageId) {
    foreach ($line in $Lines) {
        if ($line -notmatch [regex]::Escape($PackageId)) { continue }
        $tokens = @(($line -split '\s+') | Where-Object { $_ -and $_.Trim().Length -gt 0 })
        for ($i = 0; $i -lt $tokens.Count; $i++) {
            if ($tokens[$i] -eq $PackageId) {
                if ($i + 1 -lt $tokens.Count) { return ([string]$tokens[$i + 1]).Trim() }
                return 'installed'
            }
        }
    }
    $null
}

# Read-only winget query used by Detect. Served from the cached inventory; the per-package query
# survives only as the fallback for when the full listing could not be obtained at all.
function Get-WingetInstalledVersion {
    param([Parameter(Mandatory)][string]$PackageId, [int]$TimeoutSeconds = 60)

    $inventory = Get-WingetInventory
    if ($null -ne $inventory) { return Get-WingetVersionFromListing $inventory $PackageId }

    # Same rule as the full listing: a Detect block never starts a winget process of its own.
    if ($script:PackageQueryNonBlocking) { return $null }

    $winget = Get-WingetPath
    if (-not $winget) { return $null }
    $r = Invoke-NativeProcess -FilePath $winget -TimeoutSeconds $TimeoutSeconds -Quiet -Arguments @(
        'list', '--id', $PackageId, '--exact',
        '--disable-interactivity', '--accept-source-agreements'
    )
    if ($r.TimedOut -or $r.Cancelled -or $r.ExitCode -ne 0) { return $null }
    Get-WingetVersionFromListing @($r.Output) $PackageId
}

# Registry first, winget second. Both answers are OR-ed, so the order cannot change the verdict —
# only its cost: an ARP hit is tens of milliseconds against winget's seconds. The registry also
# catches per-user installs that winget's source correlation misses.
function Test-WingetPackagePresent {
    param(
        [Parameter(Mandatory)][string]$PackageId,
        [string]$FallbackNamePattern,
        [string[]]$FallbackKeys = @()
    )

    if ($FallbackNamePattern -or ($FallbackKeys -and $FallbackKeys.Count -gt 0)) {
        $pattern = if ($FallbackNamePattern) { $FallbackNamePattern } else { [regex]::Escape($PackageId) }
        if (Get-InstalledProductInfo -NamePattern $pattern -ExplicitKeys $FallbackKeys) { return $true }
    }
    if (Get-WingetInstalledVersion -PackageId $PackageId) { return $true }
    $false
}

function Write-InstallVerdict([string]$Key, [string]$Fallback) {
    Write-OperationOutput (Get-UiText $Key $Fallback)
}

# A script card without its own Detect falls back to "did this ever run?" — which used to be written
# unconditionally, so a failed install still earned a checkmark. These three let a step say it did
# not succeed; Invoke-TweakApply then leaves the card unmarked instead of claiming it is done.
$script:TweakStepFailed = $false
function Reset-TweakStepFailure { $script:TweakStepFailed = $false }
function Set-TweakStepFailed    { $script:TweakStepFailed = $true }
function Test-TweakStepFailed   { [OutputType([bool])] param() ; [bool]$script:TweakStepFailed }

# The single entry point every install card uses. Reports what it found, what it did, and — this is
# the part that was missing — always ends on an explicit verdict line, including for "nothing to do"
# and for failures, so the Terminal panel never leaves the user staring at a silent card.
function Invoke-WingetEnsurePackage {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$PackageId,
        [string]$DisplayName,
        [string]$FallbackNamePattern,
        [string[]]$FallbackKeys = @(),
        [switch]$Interactive,                 # installer must show its own UI (vendor wizards)
        [int]$TimeoutSeconds = 0
    )

    $label = if ([string]::IsNullOrWhiteSpace($DisplayName)) { $PackageId } else { $DisplayName }
    Write-OperationOutput "--- $label ($PackageId) ---"

    $winget = Get-WingetPath
    if (-not $winget) {
        Write-InstallVerdict 'InstallWingetMissing' 'winget (App Installer) was not found — install "App Installer" from the Microsoft Store, then use this button again. Nothing was changed.'
        Set-TweakStepFailed
        return $false
    }

    # Step 1 — registry first. If the product is already on the machine but winget cannot see it,
    # a winget install would download the full package to achieve nothing.
    if ($FallbackNamePattern -or ($FallbackKeys -and $FallbackKeys.Count -gt 0)) {
        $pattern = if ($FallbackNamePattern) { $FallbackNamePattern } else { [regex]::Escape($PackageId) }
        $local   = Get-InstalledProductInfo -NamePattern $pattern -ExplicitKeys $FallbackKeys
        if ($local) {
            $ver = if ([string]::IsNullOrWhiteSpace($local.Version)) { '?' } else { $local.Version }
            Write-OperationOutput ((Get-UiText 'InstallFoundOutsideWingetFmt' 'Already present on this system: {0} {1}. Windows manages this component itself, so winget does not list it.') -f $local.Name, $ver)
            Write-InstallVerdict 'InstallSkippedAlreadyPresent' 'Nothing to install — the component is already in place. This step is done; move on to the next one.'
            return $true
        }
    }
    $wingetVersion = Get-WingetInstalledVersion -PackageId $PackageId

    $common = @('-e', '--source', 'winget', '--disable-interactivity', '--accept-source-agreements', '--accept-package-agreements')
    if (-not $Interactive) { $common += '--silent' }

    # Step 2 — upgrade an existing install, otherwise install fresh.
    if ($wingetVersion) {
        Write-OperationOutput ((Get-UiText 'InstallCurrentVersionFmt' 'Installed version: {0}. Checking for an update…') -f $wingetVersion)
        $up = Invoke-NativeProcess -FilePath $winget -TimeoutSeconds $TimeoutSeconds -Arguments (@('upgrade', '--id', $PackageId) + $common)
        Clear-PackageCaches
        if (Write-WingetOutcome -Result $up -Label $label -Operation 'upgrade') { return $true }
        if ((Get-WingetExitMeaning $up.ExitCode) -ne 'NoPackageFound') { Set-TweakStepFailed; return $false }
        Write-InstallVerdict 'InstallUpgradeFellBack' 'winget could not upgrade the existing entry — trying a fresh install.'
    } else {
        Write-InstallVerdict 'InstallNotPresentYet' 'Not installed yet — starting the installation.'
    }

    $inst = Invoke-NativeProcess -FilePath $winget -TimeoutSeconds $TimeoutSeconds -Arguments (@('install', '--id', $PackageId) + $common)
    Clear-PackageCaches
    $ok = Write-WingetOutcome -Result $inst -Label $label -Operation 'install'
    if (-not $ok) { Set-TweakStepFailed }
    $ok
}

function Invoke-WingetRemovePackage {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$PackageId,
        [string]$DisplayName,
        [int]$TimeoutSeconds = 0
    )

    $label = if ([string]::IsNullOrWhiteSpace($DisplayName)) { $PackageId } else { $DisplayName }
    Write-OperationOutput "--- $label ($PackageId) ---"

    $winget = Get-WingetPath
    if (-not $winget) {
        Write-InstallVerdict 'InstallWingetMissing' 'winget (App Installer) was not found — install "App Installer" from the Microsoft Store, then use this button again. Nothing was changed.'
        Set-TweakStepFailed
        return $false
    }
    if (-not (Get-WingetInstalledVersion -PackageId $PackageId)) {
        Write-InstallVerdict 'UninstallNotInstalled' 'winget does not list this package as installed — there is nothing to remove.'
        return $true
    }

    $r = Invoke-NativeProcess -FilePath $winget -TimeoutSeconds $TimeoutSeconds -Arguments @(
        'uninstall', '--id', $PackageId, '-e', '--silent', '--disable-interactivity', '--accept-source-agreements'
    )
    Clear-PackageCaches
    $ok = Write-WingetOutcome -Result $r -Label $label -Operation 'uninstall'
    if (-not $ok) { Set-TweakStepFailed }
    $ok
}

# Turns a winget run into one plain-language line. Returns $true when the machine ended up in the
# state the user asked for — including "it was already there", which is a success, not a failure.
function Write-WingetOutcome {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][hashtable]$Result,
        [string]$Label,
        [string]$Operation = 'install'
    )

    if (-not $Result.Started) {
        $detail = if ($Result.Error) { $Result.Error } else { 'unknown reason' }
        Write-OperationOutput ((Get-UiText 'InstallCouldNotStartFmt' 'Could not start winget: {0}. Nothing was changed — you can continue with the other steps.') -f $detail)
        return $false
    }
    if ($Result.Cancelled) {
        Write-InstallVerdict 'InstallCancelledByUser' 'Cancelled — the installer was stopped. Nothing is left running in the background.'
        return $false
    }
    if ($Result.TimedOut) {
        Write-OperationOutput ((Get-UiText 'InstallTimedOutFmt' 'No response for {0} minutes — winget was stopped so the app does not stay stuck. Nothing is running in the background; you can retry or continue with the other steps.') -f [math]::Round($script:NativeProcessTimeoutSeconds / 60))
        return $false
    }

    $meaning = Get-WingetExitMeaning $Result.ExitCode
    switch ($meaning) {
        'Ok' {
            $key = switch ($Operation) {
                'uninstall' { 'UninstallDone' }
                'upgrade'   { 'InstallUpdated' }
                default     { 'InstallDone' }
            }
            $fallback = switch ($Operation) {
                'uninstall' { 'Removed successfully.' }
                'upgrade'   { 'Updated to the latest version.' }
                default     { 'Installed successfully.' }
            }
            Write-InstallVerdict $key $fallback
            return $true
        }
        'NoApplicableUpdate' {
            Write-InstallVerdict 'InstallAlreadyLatest' 'The latest version is already installed — no update is needed. This step is done.'
            return $true
        }
        'AlreadyInstalled' {
            Write-InstallVerdict 'InstallAlreadyInstalled' 'This version is already installed — the installer stopped on its own. This step is done.'
            return $true
        }
        'NoPackageFound' {
            Write-InstallVerdict 'InstallNoPackageFound' 'winget found no matching package for this operation.'
            return $false
        }
        'MultiplePackagesFound' {
            Write-InstallVerdict 'InstallMultipleFound' 'winget found several matching packages and did not pick one. Nothing was changed.'
            return $false
        }
        'InstallerHashMismatch' {
            Write-InstallVerdict 'InstallHashMismatch' 'The downloaded installer did not match its published checksum, so winget refused to run it. Nothing was changed — try again later or install from the vendor page.'
            return $false
        }
        'DownloadFailed' {
            Write-InstallVerdict 'InstallDownloadFailed' 'The download failed — check the network connection. Nothing was changed.'
            return $false
        }
        'RequiresAdmin' {
            Write-InstallVerdict 'InstallRequiresAdmin' 'This package needs administrator rights. Restart the app as administrator and try again.'
            return $false
        }
        'NoApplicableInstaller' {
            Write-InstallVerdict 'InstallNoApplicableInstaller' 'This package has no installer for this edition of Windows or this architecture. Nothing was changed.'
            return $false
        }
        'SystemNotSupported' {
            Write-InstallVerdict 'InstallSystemNotSupported' 'This package does not support this system. Nothing was changed.'
            return $false
        }
        'NoSourcesDefined' {
            Write-InstallVerdict 'InstallNoSources' 'No winget sources are configured. Run "winget source reset --force" in a terminal, then try again.'
            return $false
        }
        default {
            Write-OperationOutput ((Get-UiText 'InstallFailedCodeFmt' 'winget exited with code {0}. The step did not complete — see the winget message above. Nothing is running in the background; you can continue with the other steps.') -f (Format-ExitCode $Result.ExitCode))
            return $false
        }
    }
}

#endregion

#region ════════════════ SYSTEM PROFILE ════════════════

function Get-GpuVendorFromText([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }

    if ($Text -match '(?i)\bNVIDIA\b|VEN_10DE') { return 'NVIDIA' }
    if ($Text -match '(?i)\bAMD\b|Advanced Micro Devices|Radeon|VEN_1002') { return 'AMD' }
    if ($Text -match '(?i)\bIntel\b|VEN_8086') { return 'Intel' }
    $null
}

function Add-GpuInventoryItem {
    param(
        [System.Collections.Generic.List[object]]$Items,
        [string]$Name,
        [string]$Source,
        [string]$VendorText = '',
        [string]$DeviceId = ''
    )

    $probe = @($Name, $VendorText, $DeviceId) -join ' '
    $vendor = Get-GpuVendorFromText $probe
    if (-not $vendor) { $vendor = 'Unknown' }

    $displayName = $Name
    if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $VendorText }
    if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $DeviceId }
    if ([string]::IsNullOrWhiteSpace($displayName)) { return }

    $key = "$vendor|$displayName|$DeviceId"
    foreach ($item in $Items) {
        if ($item.Key -eq $key) { return }
    }

    $Items.Add([pscustomobject]@{
        Key      = $key
        Vendor   = $vendor
        Name     = $displayName
        Source   = $Source
        DeviceId = $DeviceId
    }) | Out-Null
}

function Get-GpuInventory {
    $items = [System.Collections.Generic.List[object]]::new()

    try {
        Get-CimInstance Win32_VideoController -EA Stop | ForEach-Object {
            Add-GpuInventoryItem $items $_.Name 'Win32_VideoController' $_.AdapterCompatibility $_.PNPDeviceID
        }
    } catch {}

    try {
        Get-CimInstance Win32_PnPEntity -Filter "PNPClass='Display'" -EA Stop | ForEach-Object {
            Add-GpuInventoryItem $items $_.Name 'Win32_PnPEntity' $_.Manufacturer $_.PNPDeviceID
        }
    } catch {}

    try {
        $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
        if (Test-Path $base) {
            Get-ChildItem -Path $base -EA SilentlyContinue |
                Where-Object { $_.PSChildName -match '^\d{4}$' } |
                ForEach-Object {
                    $p = Get-ItemProperty -Path $_.PSPath -EA SilentlyContinue
                    $name = if ($p.DriverDesc) { $p.DriverDesc } elseif ($p.DeviceDesc) { $p.DeviceDesc } else { $p.'HardwareInformation.AdapterString' }
                    $vendorText = "$($p.ProviderName) $($p.DeviceDesc) $($p.'HardwareInformation.AdapterString')"
                    Add-GpuInventoryItem $items $name 'DisplayClassRegistry' $vendorText $p.MatchingDeviceId
                }
        }
    } catch {}

    $hasKnownVendor = @($items | Where-Object { $_.Vendor -and $_.Vendor -ne 'Unknown' }).Count -gt 0
    if (-not $hasKnownVendor) {
        try {
            Get-CimInstance Win32_PnPSignedDriver -Filter "DeviceClass='DISPLAY'" -EA Stop | ForEach-Object {
                $vendorText = "$($_.Manufacturer) $($_.DriverProviderName)"
                Add-GpuInventoryItem $items $_.DeviceName 'Win32_PnPSignedDriver' $vendorText $_.DeviceID
            }
        } catch {}
    }

    @($items)
}

function Get-SystemProfile {
    $os   = Get-CimInstance Win32_OperatingSystem
    $gpuInventory = @(Get-GpuInventory)
    $gpus = @($gpuInventory | ForEach-Object { $_.Name } | Where-Object { $_ } | Select-Object -Unique)

    $build   = [int]($os.BuildNumber)
    $edition = $os.Caption -replace '^.+Windows \d+ ',''

    $gpuVendors = @($gpuInventory | ForEach-Object { $_.Vendor } | Where-Object { $_ } | Select-Object -Unique)
    if ($gpuVendors.Count -eq 0) { $gpuVendors = @('Unknown') }

    $gpuVendor = if ($gpuVendors -contains 'NVIDIA') {
        'NVIDIA'
    } elseif ($gpuVendors -contains 'AMD') {
        'AMD'
    } elseif ($gpuVendors -contains 'Intel') {
        'Intel'
    } else {
        $gpuVendors[0]
    }

    # Disk type of system drive
    $sysDrive = $env:SystemDrive.TrimEnd(':')
    $diskType = 'Unknown'
    try {
        $physDisk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq 0 } | Select-Object -First 1
        if (-not $physDisk) { $physDisk = Get-PhysicalDisk | Select-Object -First 1 }
        $diskType = $physDisk.MediaType   # HDD, SSD, Unspecified
    } catch {}

    @{
        Build     = $build
        Edition   = $edition.Trim()
        GpuVendor = $gpuVendor
        GpuVendors = @($gpuVendors)
        GpuNames   = @($gpus)
        GpuInventory = @($gpuInventory)
        DiskType  = $diskType
        OSCaption = $os.Caption
    }
}

#endregion

# Device power-saving state, for the "disable USB device power-saving" card. WMI exposes one
# MSPower_DeviceEnable instance per device carrying an "Allow the computer to turn off this device"
# checkbox; Enable=$false means the checkbox is cleared. This is the exact population the card's
# script writes to, so it is also the right thing to count before and after it runs.
#
# Deliberately does NOT touch Win32_SerialPort: that class costs ~5 s to enumerate here against
# ~0.1 s for this one, and Detect runs on every subsection switch.
function Get-DevicePowerSaveState {
    $state = @{ Total = 0; PowerSaveOff = 0; PowerSaveOn = @(); PowerSaveOffNames = @() }
    try {
        $power = @(Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -EA Stop)
    } catch {
        return $state
    }
    $on  = [System.Collections.Generic.List[string]]::new()
    $off = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $power) {
        $state.Total++
        $name = [string]$p.InstanceName
        if ($p.Enable) { $on.Add($name) | Out-Null } else { $off.Add($name) | Out-Null; $state.PowerSaveOff++ }
    }
    $state.PowerSaveOn       = $on.ToArray()
    $state.PowerSaveOffNames = $off.ToArray()
    $state
}

# Flips the "allow the computer to turn off this device" checkbox back on for a known list of
# instances. Used by Revert, which only ever restores devices this tool itself switched off.
function Set-DevicePowerSaveEnabled {
    [OutputType([int])]
    param([string[]]$InstanceNames, [bool]$Enabled)

    if (-not $InstanceNames -or $InstanceNames.Count -eq 0) { return 0 }
    $changed = 0
    try {
        $power = @(Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -EA Stop)
    } catch {
        return 0
    }
    foreach ($p in $power) {
        $name = [string]$p.InstanceName
        if ($InstanceNames -notcontains $name) { continue }
        if ([bool]$p.Enable -eq $Enabled) { continue }
        try {
            Set-CimInstance -InputObject $p -Property @{ Enable = $Enabled } -EA Stop
            $changed++
        } catch {}
    }
    $changed
}

#region ════════════════ BACKUP STORE ════════════════

# Prepares the engine to run without a window. $script:AppRoot is otherwise set only by
# Start-TunerWindow and by the two background runspaces, so a bare Import-Module leaves it $null and
# the first backup write dies inside Get-DataDir. Anything driving the engine head-on — the smoke
# checks, a profile runner, a skill — calls this first. The AppRoot fallback matches
# Start-TunerWindow's: the module's own parent folder, not a path someone passed in.
# LineSink is where command output goes; leaving it unset keeps the engine silent, as it is today.
function Initialize-TweakEngine {
    [OutputType([string])]
    param(
        [string]$AppRoot,
        [scriptblock]$LineSink
    )
    $script:AppRoot = if ($AppRoot) { $AppRoot } else { Split-Path $PSScriptRoot -Parent }
    if ($PSBoundParameters.ContainsKey('LineSink')) { $script:LineSink = $LineSink }
    $script:AppRoot
}

# Portable local state lives next to the app in <AppRoot>\Data — never in %LOCALAPPDATA%.
# $script:AppRoot is set on the UI thread (Start-TunerWindow), in the background runspace, and by
# Initialize-TweakEngine for headless callers, so this resolves correctly in all three.
function Get-DataDir {
    $dir = Join-Path $script:AppRoot 'Data'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $dir
}

function Get-BackupDir {
    $dir = Join-Path (Get-DataDir) 'backups'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $dir
}

function Read-TweakBackup([string]$TweakId) {
    $path = Join-Path (Get-BackupDir) "$TweakId.json"
    if (Test-Path $path) {
        try { Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { $null }
    }
}

function Write-TweakBackup([string]$TweakId, [hashtable]$Data) {
    $path = Join-Path (Get-BackupDir) "$TweakId.json"
    $Data | ConvertTo-Json -Depth 5 | Set-Content -Path $path -Encoding UTF8 -NoNewline
}

function Remove-TweakBackup([string]$TweakId) {
    $path = Join-Path (Get-BackupDir) "$TweakId.json"
    if (Test-Path $path) { Remove-Item $path -Force }
}

function Get-PanelLayoutPath {
    Join-Path (Get-DataDir) 'layout.json'
}

function Read-PanelLayout {
    $path = Get-PanelLayoutPath
    if (Test-Path $path) {
        try { Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $null }
    }
}

function Write-PanelLayout([hashtable]$Layout) {
    try {
        $Layout | ConvertTo-Json -Depth 4 | Set-Content -Path (Get-PanelLayoutPath) -Encoding UTF8 -NoNewline
    } catch {}
}

#endregion

#region ════════════════ APPLICABILITY ════════════════

$script:IsElevatedValue = $null

function Test-IsElevated {
    [OutputType([bool])]
    param()
    if ($null -eq $script:IsElevatedValue) {
        $script:IsElevatedValue = try {
            ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator)
        } catch { $false }
    }
    [bool]$script:IsElevatedValue
}

function Test-TweakApplicable([hashtable]$Tweak, [hashtable]$Profile) {
    $at = $Tweak['AppliesTo']
    if (-not $at) { return $true }
    if ($at['MinBuild'] -and $Profile['Build'] -lt $at['MinBuild']) { return $false }
    if ($at['MaxBuild'] -and $Profile['Build'] -gt $at['MaxBuild']) { return $false }
    if ($at['Editions'] -and $at['Editions'] -notcontains $Profile['Edition']) { return $false }
    if ($at['GpuVendors']) {
        $profileVendors = @($Profile['GpuVendors'])
        if ($profileVendors.Count -eq 0 -and $Profile['GpuVendor']) { $profileVendors = @($Profile['GpuVendor']) }
        $allowedVendors = @($at['GpuVendors'] | ForEach-Object { "$_".ToUpperInvariant() })
        $hasMatchingGpu = @($profileVendors | Where-Object { $allowedVendors -contains "$_".ToUpperInvariant() }).Count -gt 0
        if (-not $hasMatchingGpu) { return $false }
    }
    $true
}

#endregion

#region ════════════════ REGISTRY HELPERS ════════════════

function ConvertTo-RegDrivePath([string]$Hive, [string]$Path) {
    $prefix = switch ($Hive.ToUpper()) {
        'HKCU' { 'HKCU:\' }
        'HKLM' { 'HKLM:\' }
        'HKCR' { 'HKCR:\' }
        'HKU'  { 'HKU:\' }
        default { throw "Unknown registry hive: $Hive" }
    }
    Join-Path $prefix $Path
}

function Get-RegValue([string]$RegPath, [string]$Name) {
    if (-not (Test-Path $RegPath)) { return $null }
    $effectiveName = if ($Name -eq '(default)' -or $Name -eq '') { '' } else { $Name }
    try {
        if ($effectiveName -eq '') {
            (Get-Item $RegPath -EA Stop).GetValue($null)
        } else {
            (Get-ItemProperty $RegPath -Name $Name -EA Stop).$Name
        }
    } catch { $null }
}

# NOTE: revert round-trips the previous value through JSON (Write-TweakBackup / Read-TweakBackup).
# That is lossless for DWord/QWord/String/ExpandString (all current manifests use DWord), but
# Binary (byte[]) and MultiString (string[]) would come back as Object[] and fail to restore.
# If a Binary/MultiString registry tweak is ever added, store the backup as base64/array explicitly.
function Set-RegValue([string]$RegPath, [string]$Name, $Value, [string]$Type) {
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    $effectiveName = if ($Name -eq '(default)' -or $Name -eq '') { '(default)' } else { $Name }
    Set-ItemProperty -Path $RegPath -Name $effectiveName -Value $Value -Type $Type
}

#endregion

#region ════════════════ TEST-TWEAKSTATE ════════════════

function Invoke-ManifestScriptBlock([object]$Block) {
    Initialize-NativeCommandEncoding

    $current = $Block
    for ($i = 0; $i -lt 4; $i++) {
        if (-not ($current -is [scriptblock])) { return $current }

        $result = & $current
        if ($result -is [scriptblock]) {
            $current = $result
            continue
        }

        $resultArray = @($result)
        if ($resultArray.Count -eq 1 -and $resultArray[0] -is [scriptblock]) {
            $current = $resultArray[0]
            continue
        }

        return $result
    }

    throw 'Manifest scriptblock nesting is deeper than expected.'
}

# Like Invoke-ManifestScriptBlock, but for Apply/Revert: streams the worker's stdout+stderr
# line-by-line to $script:LineSink AS the command produces them (winget/powercfg/etc. are
# captured live through the PowerShell pipeline). Return value is discarded. When LineSink is
# $null (no UI thread to stream to) output is simply dropped, matching the old `| Out-Null`.
function Invoke-ManifestScriptBlockStreamed([object]$Block) {
    Initialize-NativeCommandEncoding

    $current = $Block
    for ($i = 0; $i -lt 4; $i++) {
        if (-not ($current -is [scriptblock])) { return }
        $producedSb = $null
        & $current 2>&1 | ForEach-Object {
            if ($_ -is [scriptblock]) {
                $producedSb = $_                      # psd1 import wrapper returned the real block
            } elseif ($null -ne $script:LineSink) {
                $line = if ($_ -is [System.Management.Automation.ErrorRecord]) { "$($_.Exception.Message)" } else { "$_" }
                if ($line.Trim().Length -gt 0) { try { & $script:LineSink $line } catch {} }
            }
        }
        if ($producedSb) { $current = $producedSb; continue }   # unwrap once, then run the real block
        return
    }
}

function Test-TweakState {
    [OutputType([string])]
    param(
        [hashtable]$Tweak,
        [hashtable]$Profile = $null
    )

    if ($Profile -and -not (Test-TweakApplicable $Tweak $Profile)) {
        return 'NotApplicable'
    }

    $kind = $Tweak['Kind']

    switch ($kind) {
        'registry' {
            try {
                $op  = $Tweak['Op']
                $rp  = ConvertTo-RegDrivePath $op['Hive'] $op['Path']
                if (-not (Test-Path $rp)) { return 'NotApplied' }
                $cur = Get-RegValue $rp $op['Name']
                if ($null -eq $cur) { return 'NotApplied' }
                # Compare as same type — cast registry numeric to int for DWord/QWord
                $target = $op['Value']
                if ($cur -eq $target -or "$cur" -eq "$target") { 'Applied' } else { 'NotApplied' }
            } catch { 'Unknown' }
        }

        'service' {
            try {
                $svc = Get-Service -Name $Tweak['Op']['Name'] -EA Stop
                if ($svc.StartType.ToString() -eq $Tweak['Op']['TargetStartup']) { 'Applied' } else { 'NotApplied' }
            } catch { 'Unknown' }
        }

        'feature' {
            try {
                $feat = Get-WindowsOptionalFeature -Online -FeatureName $Tweak['Op']['FeatureName'] -EA Stop
                if ($feat.State -eq $Tweak['Op']['Target']) { 'Applied' } else { 'NotApplied' }
            } catch { 'Unknown' }
        }

        'powerscheme' {
            $backup = Read-TweakBackup $Tweak['Id']
            if ($backup -and $backup.importedGuid) {
                $activeOut = & powercfg -getactivescheme 2>&1
                if ($activeOut -match [regex]::Escape($backup.importedGuid)) { return 'Applied' }
            }
            'NotApplied'
        }

        'script' {
            $detectBlock = $Tweak['Detect']
            if ($detectBlock) {
                try {
                    $script:PackageQueryNonBlocking = $true
                    $result = Invoke-ManifestScriptBlock $detectBlock
                    return $(if ($result) { 'Applied' } else { 'NotApplied' })
                } catch { return 'Unknown' }
                finally { $script:PackageQueryNonBlocking = $false }
            }
            $backup = Read-TweakBackup $Tweak['Id']
            if ($backup -and $backup.applied) { 'Applied' } else { 'Unknown' }
        }

        'deeplink' {
            $detectBlock = $Tweak['Detect']
            if ($detectBlock) {
                try {
                    $script:PackageQueryNonBlocking = $true
                    $result = Invoke-ManifestScriptBlock $detectBlock
                    return $(if ($result) { 'Applied' } else { 'NotApplied' })
                } catch {}
                finally { $script:PackageQueryNonBlocking = $false }
            }
            $backup = Read-TweakBackup $Tweak['Id']
            if ($backup -and $backup.done) { 'Applied' } else { 'NotApplied' }
        }

        'manual' {
            $backup = Read-TweakBackup $Tweak['Id']
            if ($backup -and $backup.done) { 'Applied' } else { 'NotApplied' }
        }

        'link' { 'NotApplied' }
        'docs' { 'NotApplied' }

        default { 'Unknown' }
    }
}

function Test-SubsectionState {
    param([hashtable]$Subsection, [hashtable]$Profile = $null)
    $results = [ordered]@{}
    foreach ($tweak in $Subsection['Tweaks']) {
        $results[$tweak['Id']] = Test-TweakState $tweak $Profile
    }
    $results
}

function Get-CachedTweakState {
    param([hashtable]$Tweak)

    if (-not $Tweak) { return 'Unknown' }
    if ((Test-TweakApplicable $Tweak $script:SysProfile) -eq $false) { return 'NotApplicable' }

    $id = [string]$Tweak['Id']
    if ([string]::IsNullOrWhiteSpace($id)) { return 'Unknown' }

    if ($script:TweakStateCache.ContainsKey($id)) {
        $entry = $script:TweakStateCache[$id]
        if ($entry -and $entry.Stamp) {
            $age = ([datetime]::UtcNow - [datetime]$entry.Stamp).TotalSeconds
            if ($age -le $script:StatusCacheTtlSeconds) {
                return [string]$entry.State
            }
        }
    }

    'Unknown'
}

function Test-CachedTweakStateFresh {
    param([hashtable]$Tweak)

    if (-not $Tweak) { return $true }
    if ((Test-TweakApplicable $Tweak $script:SysProfile) -eq $false) { return $true }

    $id = [string]$Tweak['Id']
    if ([string]::IsNullOrWhiteSpace($id)) { return $false }
    if (-not $script:TweakStateCache.ContainsKey($id)) { return $false }

    $entry = $script:TweakStateCache[$id]
    if (-not $entry -or -not $entry.Stamp) { return $false }

    (([datetime]::UtcNow - [datetime]$entry.Stamp).TotalSeconds -le $script:StatusCacheTtlSeconds)
}

function Set-CachedTweakState {
    param([string]$Id, [string]$State)
    if ([string]::IsNullOrWhiteSpace($Id)) { return }
    if ([string]::IsNullOrWhiteSpace($State)) { $State = 'Unknown' }
    $script:TweakStateCache[$Id] = [pscustomobject]@{
        State = $State
        Stamp = [datetime]::UtcNow
    }
}

function Clear-CachedTweakState {
    param([string[]]$Ids = $null)
    if (-not $Ids -or $Ids.Count -eq 0) {
        $script:TweakStateCache.Clear()
        return
    }
    foreach ($id in $Ids) {
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            $script:TweakStateCache.Remove($id)
        }
    }
}

function Get-SubsectionCachedStates {
    param([hashtable]$Subsection)
    $results = [ordered]@{}
    if (-not $Subsection) { return $results }
    foreach ($tweak in @($Subsection['Tweaks'] | Where-Object { $_ -is [hashtable] })) {
        $results[$tweak['Id']] = Get-CachedTweakState $tweak
    }
    $results
}

function Test-SubsectionStateCacheFresh {
    param([hashtable]$Subsection)
    if (-not $Subsection) { return $true }
    foreach ($tweak in @($Subsection['Tweaks'] | Where-Object { $_ -is [hashtable] })) {
        if (-not (Test-CachedTweakStateFresh $tweak)) { return $false }
    }
    $true
}

#endregion

#region ════════════════ INVOKE-TWEAKAPPLY ════════════════

function Invoke-TweakApply {
    param([hashtable]$Tweak, [hashtable]$Profile = $null)

    if ($Profile -and -not (Test-TweakApplicable $Tweak $Profile)) {
        throw "Tweak '$($Tweak['Id'])' is not applicable to this system."
    }

    # RequiresAdmin was declared throughout the manifests but read by nothing. App.ps1 elevates the
    # whole window, so this never fires in normal use and adds no prompt — it only makes sure that a
    # session which somehow lost elevation says so plainly instead of failing as "access denied".
    if ($Tweak['RequiresAdmin'] -and -not (Test-IsElevated)) {
        Write-OperationOutput (Get-UiText 'StepNeedsAdmin' 'This step changes system-wide settings and needs administrator rights. Restart the app as administrator. Nothing was changed.')
        Set-TweakStepFailed
        return
    }

    $kind = $Tweak['Kind']

    # Idempotency: skip re-applying a settled state — but NOT for one-shot actions the user
    # explicitly clicked. link/deeplink always re-open; script BUTTONS (installs, etc.) always
    # run so the tool actually executes and streams its output even when already in place — e.g.
    # `winget install` then reports "already installed / no upgrade". Toggles, registry, service,
    # feature and powerscheme keep the skip (avoids redundant work and duplicate scheme imports).
    $alwaysRun = ($kind -eq 'link') -or ($kind -eq 'deeplink') -or
                 ($kind -eq 'script' -and [string]$Tweak['Control'] -eq 'button')
    if (-not $alwaysRun) {
        $state = Test-TweakState $Tweak $Profile
        if ($state -eq 'Applied') { return }
    }

    switch ($kind) {
        'registry'    { Invoke-Apply-Registry    $Tweak }
        'service'     { Invoke-Apply-Service     $Tweak }
        'feature'     { Invoke-Apply-Feature     $Tweak }
        'powerscheme' { Invoke-Apply-PowerScheme $Tweak }
        'script' {
            $applyBlock = $Tweak['Apply']
            Reset-TweakStepFailure
            if ($applyBlock) { Invoke-ManifestScriptBlockStreamed $applyBlock }
            # Only cards without their own Detect rely on this mark, and for them it must mean
            # "this succeeded" — not merely "the button was pressed".
            if (-not (Test-TweakStepFailed)) { Write-TweakBackup $Tweak['Id'] @{ applied = $true } }
        }
        'deeplink' {
            Open-ExternalTarget $Tweak['Uri']
            Write-TweakBackup $Tweak['Id'] @{ done = $true }
        }
        'link' {
            Open-ExternalTarget $Tweak['Url']
        }
        'manual' {
            Write-TweakBackup $Tweak['Id'] @{ done = $true }
        }
        'docs' { }
    }
}

# Hands a URL, shell: folder or ms-settings: page to the shell, so the user's own default browser
# and handler settings decide what opens. Shared by link/deeplink cards and by the "download page"
# button that install cards can carry next to Apply.
function Open-ExternalTarget([string]$Target) {
    if ([string]::IsNullOrWhiteSpace($Target)) { return }
    if ($Target -like 'shell:*') {
        Start-Process 'explorer.exe' -ArgumentList $Target
        return
    }
    $si = New-Object System.Diagnostics.ProcessStartInfo $Target
    $si.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si) | Out-Null
}

function Invoke-Apply-Registry([hashtable]$Tweak) {
    $op  = $Tweak['Op']
    $rp  = ConvertTo-RegDrivePath $op['Hive'] $op['Path']

    # Capture previous state for revert
    $backup = @{ kind = 'registry'; hive = $op['Hive']; path = $op['Path']; name = $op['Name']; type = $op['Type'] }
    if (Test-Path $rp) {
        $cur = Get-RegValue $rp $op['Name']
        if ($null -ne $cur) {
            $backup['previousState'] = 'present'
            $backup['previousValue'] = $cur
        } else {
            $backup['previousState'] = 'value-absent'
        }
    } else {
        $backup['previousState'] = 'key-absent'
    }
    Write-TweakBackup $Tweak['Id'] $backup

    Set-RegValue $rp $op['Name'] $op['Value'] $op['Type']
}

function Invoke-Apply-Service([hashtable]$Tweak) {
    $op  = $Tweak['Op']
    $svc = Get-Service -Name $op['Name'] -EA Stop

    Write-TweakBackup $Tweak['Id'] @{
        kind              = 'service'
        name              = $op['Name']
        previousStartType = $svc.StartType.ToString()
        previousStatus    = $svc.Status.ToString()
    }

    Set-Service -Name $op['Name'] -StartupType $op['TargetStartup']

    $targetState = $op['TargetState']
    if ($targetState -eq 'Stopped' -and $svc.Status -ne 'Stopped') {
        Stop-Service -Name $op['Name'] -Force -EA SilentlyContinue
    } elseif ($targetState -eq 'Running' -and $svc.Status -ne 'Running') {
        Start-Service -Name $op['Name'] -EA SilentlyContinue
    }
}

function Invoke-Apply-Feature([hashtable]$Tweak) {
    $op   = $Tweak['Op']
    $feat = Get-WindowsOptionalFeature -Online -FeatureName $op['FeatureName'] -EA Stop

    Write-TweakBackup $Tweak['Id'] @{
        kind          = 'feature'
        featureName   = $op['FeatureName']
        previousState = $feat.State.ToString()
    }

    if ($op['Target'] -eq 'Disabled') {
        Write-OperationOutput "Disabling Windows optional feature: $($op['FeatureName'])"
        Disable-WindowsOptionalFeature -Online -FeatureName $op['FeatureName'] -NoRestart 2>&1 | ForEach-Object {
            Write-FeatureCommandOutput $_
        }
    } else {
        Write-OperationOutput "Enabling Windows optional feature: $($op['FeatureName'])"
        Enable-WindowsOptionalFeature -Online -FeatureName $op['FeatureName'] -NoRestart 2>&1 | ForEach-Object {
            Write-FeatureCommandOutput $_
        }
    }

    try {
        $newState = (Get-WindowsOptionalFeature -Online -FeatureName $op['FeatureName'] -EA Stop).State
        Write-OperationOutput "Feature state: $newState"
    } catch {
        # The confirmation read is the only proof the change landed — do not drop it silently.
        Write-OperationOutput (Get-UiText 'FeatureStateUnreadable' 'The feature state could not be read back after the change — see the output above for what Windows reported.')
    }
}

function Invoke-Apply-PowerScheme([hashtable]$Tweak) {
    $op = $Tweak['Op']

    # Capture currently active scheme GUID
    $activeOut   = & powercfg -getactivescheme 2>&1
    $previousGuid = if ($activeOut -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})') { $matches[1] } else { $null }

    # Resolve file path relative to app root
    $file = $op['File']
    if (-not [IO.Path]::IsPathRooted($file)) {
        $file = Join-Path $script:AppRoot $file
    }
    if (-not (Test-Path $file)) { throw "Power scheme file not found: $file" }

    # Import — powercfg outputs the new GUID
    $importOut   = & powercfg -import $file 2>&1
    $importedGuid = if ($importOut -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})') { $matches[1] } else { $null }

    if (-not $importedGuid) { throw "powercfg -import did not return a GUID. Output: $importOut" }

    & powercfg -setactive $importedGuid | Out-Null

    Write-TweakBackup $Tweak['Id'] @{
        kind         = 'powerscheme'
        previousGuid = $previousGuid
        importedGuid = $importedGuid
    }
}

#endregion

#region ════════════════ INVOKE-TWEAKREVERT ════════════════

function Invoke-TweakRevert {
    param([hashtable]$Tweak)

    $backup = Read-TweakBackup $Tweak['Id']
    $kind   = $Tweak['Kind']

    # A card can be reported as applied without this program ever having touched it: Detect reads the
    # live system, and Invoke-TweakApply deliberately skips a state that is already settled, so no
    # backup is written. Turning such a toggle off then has nothing to restore. Say that out loud —
    # Write-Warning goes nowhere the user can see, which made the toggle look broken: it flipped,
    # nothing happened, and the next status refresh flipped it back.
    $noBackup = {
        Write-OperationOutput (Get-UiText 'RevertNoBackup' 'This was already set before the program first saw it, so there is no recorded previous value to put back. Change it in Windows Settings if you want it off.')
        Set-TweakStepFailed
    }

    switch ($kind) {
        'registry' {
            if (-not $backup) { & $noBackup; return }
            Invoke-Revert-Registry $Tweak $backup
        }
        'service' {
            if (-not $backup) { & $noBackup; return }
            Invoke-Revert-Service $Tweak $backup
        }
        'feature' {
            if (-not $backup) { & $noBackup; return }
            Invoke-Revert-Feature $Tweak $backup
        }
        'powerscheme' {
            if (-not $backup) { & $noBackup; return }
            Invoke-Revert-PowerScheme $Tweak $backup
        }
        'script' {
            $revertBlock = $Tweak['Revert']
            if ($revertBlock) { Invoke-ManifestScriptBlockStreamed $revertBlock }
            Remove-TweakBackup $Tweak['Id']
        }
        'deeplink' { Remove-TweakBackup $Tweak['Id'] }
        'manual'   { Remove-TweakBackup $Tweak['Id'] }
    }
}

function Invoke-Revert-Registry([hashtable]$Tweak, $Backup) {
    $rp   = ConvertTo-RegDrivePath $Backup.hive $Backup.path
    $name = $Backup.name
    $type = $Backup.type

    switch ($Backup.previousState) {
        'present' {
            Set-RegValue $rp $name $Backup.previousValue $type
        }
        'value-absent' {
            $effectiveName = if ($name -eq '(default)' -or $name -eq '') { '(default)' } else { $name }
            Remove-ItemProperty -Path $rp -Name $effectiveName -EA SilentlyContinue
        }
        'key-absent' {
            if (Test-Path $rp) { Remove-Item -Path $rp -Recurse -Force -EA SilentlyContinue }
        }
    }
    Remove-TweakBackup $Tweak['Id']
}

function Invoke-Revert-Service([hashtable]$Tweak, $Backup) {
    # A failed restore used to be silent AND still deleted the backup, destroying the only record of
    # the service's original startup type. Say what went wrong and keep the record so a second
    # attempt is possible.
    try {
        Set-Service -Name $Backup.name -StartupType $Backup.previousStartType -EA Stop
    } catch {
        Write-OperationOutput ((Get-UiText 'RevertServiceFailedFmt' 'Could not restore service {0}: {1}. The backup was kept, so you can try again.') -f $Backup.name, $_.Exception.Message)
        Set-TweakStepFailed
        return
    }
    # Restore the previous running/stopped state — Set-Service only changes the startup type,
    # so without this a disabled+stopped service stays stopped until the next reboot.
    try {
        $prevStatus = "$($Backup.previousStatus)"
        if ($prevStatus -eq 'Running') {
            Start-Service -Name $Backup.name -EA Stop
        } elseif ($prevStatus -eq 'Stopped') {
            Stop-Service -Name $Backup.name -Force -EA Stop
        }
    } catch {
        Write-OperationOutput ((Get-UiText 'RevertServiceStateFailedFmt' 'Service {0} was set back to its previous startup type, but its running state could not be restored: {1}. A reboot will settle it.') -f $Backup.name, $_.Exception.Message)
    }
    Remove-TweakBackup $Tweak['Id']
}

function Invoke-Revert-Feature([hashtable]$Tweak, $Backup) {
    if ($Backup.previousState -eq 'Disabled') {
        Write-OperationOutput "Reverting Windows optional feature to Disabled: $($Backup.featureName)"
        Disable-WindowsOptionalFeature -Online -FeatureName $Backup.featureName -NoRestart 2>&1 | ForEach-Object {
            Write-FeatureCommandOutput $_
        }
    } else {
        Write-OperationOutput "Reverting Windows optional feature to $($Backup.previousState): $($Backup.featureName)"
        Enable-WindowsOptionalFeature  -Online -FeatureName $Backup.featureName -NoRestart 2>&1 | ForEach-Object {
            Write-FeatureCommandOutput $_
        }
    }

    try {
        $newState = (Get-WindowsOptionalFeature -Online -FeatureName $Backup.featureName -EA Stop).State
        Write-OperationOutput "Feature state: $newState"
    } catch {
        # The confirmation read is the only proof the change landed — do not drop it silently.
        Write-OperationOutput (Get-UiText 'FeatureStateUnreadable' 'The feature state could not be read back after the change — see the output above for what Windows reported.')
    }
    Remove-TweakBackup $Tweak['Id']
}

function Invoke-Revert-PowerScheme([hashtable]$Tweak, $Backup) {
    if ($Backup.previousGuid) {
        & powercfg -setactive $Backup.previousGuid | Out-Null
    }
    if ($Backup.importedGuid) {
        & powercfg -delete $Backup.importedGuid 2>&1 | Out-Null
    }
    Remove-TweakBackup $Tweak['Id']
}

#endregion

#region ════════════════ DISPLAY VALUE CONVERSION ════════════════

function Get-TweakDisplayValue {
    param([hashtable]$Tweak, $RawValue)
    $display = $Tweak['Display']
    if ($display -and $display['FromRegistry']) { return & $display['FromRegistry'] $RawValue }
    $RawValue
}

function Set-TweakDisplayValue {
    param([hashtable]$Tweak, $HumanValue)
    $display = $Tweak['Display']
    if ($display -and $display['ToRegistry']) { return & $display['ToRegistry'] $HumanValue }
    $HumanValue
}

#endregion

#region ════════════════ LANGUAGE ════════════════

function Get-L10n([hashtable]$ht, [string]$key) {
    if ($script:Lang -ne 'en' -and $ht[$script:Lang] -is [hashtable]) {
        $v = $ht[$script:Lang][$key]
        if ($v) { return $v }
    }
    $ht[$key]
}

function Load-Strings([string]$LangCode) {
    $path = Join-Path $script:AppRoot "Strings\$LangCode.psd1"
    if (Test-Path $path) {
        $script:S    = Import-TweakDataFile $path
        $script:Lang = $LangCode
    }
}

function Get-LangPrefPath {
    Join-Path (Get-DataDir) 'lang.txt'
}

function Read-LangPref {
    $p = Get-LangPrefPath
    if (Test-Path $p) { try { (Get-Content $p -Raw -EA Stop).Trim() } catch { $null } }
}

function Write-LangPref([string]$LangCode) {
    try { Set-Content -Path (Get-LangPrefPath) -Value $LangCode -Encoding UTF8 -NoNewline } catch {}
}

function Set-Language([string]$LangCode) {
    Load-Strings $LangCode
    Write-LangPref $LangCode   # remember the choice for next launch
    Refresh-LangUI
}

function Get-PowerShellRuntimeStatus {
    $portablePath = Join-Path $script:AppRoot 'Engine\PowerShell\pwsh.exe'
    $portableOk   = Test-Path $portablePath
    $currentOk    = $false
    try {
        $currentOk = ($PSVersionTable.PSEdition -eq 'Core' -and $PSVersionTable.PSVersion.Major -ge 7)
    } catch {}

    $systemOk = $false
    try {
        $commands = @(Get-Command 'pwsh.exe' -CommandType Application -ErrorAction Stop)
        foreach ($cmd in $commands) {
            $source = [string]$cmd.Source
            if ([string]::IsNullOrWhiteSpace($source)) { continue }
            if ($portableOk -and $source -ieq $portablePath) { continue }
            $systemOk = $true
            break
        }
    } catch {}

    [pscustomobject]@{
        CurrentIsPowerShell7 = $currentOk
        PortableExists       = $portableOk
        SystemExists         = $systemOk
    }
}

function Update-PwshBadge {
    if (-not $script:PwshBadge -or -not $script:PwshBadgeText) { return }

    $status = Get-PowerShellRuntimeStatus
    $label = $null
    $tip   = $null

    if (-not $status.CurrentIsPowerShell7) {
        $label = Get-UiText 'PwshMissingBadge' 'PowerShell 7 missing'
        $tip   = Get-UiText 'PwshMissingTooltip' 'PowerShell 7 was not found for this launch. Install portable PowerShell with the bottom button, then restart the app.'
    } elseif (-not $status.PortableExists) {
        $label = Get-UiText 'PwshPortableMissingBadge' 'portable PowerShell 7 missing'
        $tip   = Get-UiText 'PwshPortableMissingTooltip' 'Portable PowerShell 7 is not installed in Engine\PowerShell\. Install it with the bottom button for self-contained launches.'
    }

    if ($label) {
        $script:PwshBadge.Visibility = [System.Windows.Visibility]::Visible
        $script:PwshBadgeText.Text = $label
        $script:PwshBadge.ToolTip = $tip
    } else {
        $script:PwshBadge.Visibility = [System.Windows.Visibility]::Collapsed
        $script:PwshBadge.ToolTip = $null
    }
}

function Update-FooterTooltips {
    if ($script:BtnDocs) {
        $script:BtnDocs.ToolTip = Get-UiText 'TooltipDocsButton' 'Open all documentation'
    }
    if ($script:BtnInstallPwsh) {
        $script:BtnInstallPwsh.ToolTip = Get-UiText 'TooltipInstallPwshButton' 'Install portable PowerShell 7'
    }
    if ($script:BtnToggleLog) {
        $script:BtnToggleLog.ToolTip = Get-UiText 'TooltipLogButton' 'Show or hide the log'
    }
    if ($script:BtnToggleTerminal) {
        $script:BtnToggleTerminal.ToolTip = Get-UiText 'TooltipTerminalButton' 'Show or hide the terminal'
    }
    if ($script:BtnMaximizeTerminal) {
        $script:BtnMaximizeTerminal.ToolTip = Get-UiText 'TooltipTerminalMaxButton' 'Expand or restore the terminal'
    }
}

function Get-ActiveReadmePath {
    $lang = if ($script:Lang) { $script:Lang.ToUpper() } else { 'EN' }
    $docsPath = Join-Path $script:AppRoot "Docs\README_$lang.md"
    if (Test-Path -LiteralPath $docsPath) { return $docsPath }
    Join-Path $script:AppRoot "README_$lang.md"
}

function Get-ActiveUserGuidePath {
    $lang = if ($script:Lang) { $script:Lang.ToUpper() } else { 'EN' }
    $docsPath = Join-Path $script:AppRoot "Docs\USER_GUIDE_$lang.md"
    if (Test-Path -LiteralPath $docsPath) { return $docsPath }
    Join-Path $script:AppRoot "USER_GUIDE_$lang.md"
}

function Get-ActivePdfPath {
    $lang = if ($script:Lang) { $script:Lang.ToUpper() } else { 'EN' }
    $lightTheme = try {
        (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
            -Name AppsUseLightTheme -EA Stop).AppsUseLightTheme
    } catch { 0 }
    $theme = if ($lightTheme -eq 1) { 'light' } else { 'dark' }
    $candidates = @(
        (Join-Path $script:AppRoot "Docs\USER_GUIDE_$lang.$theme.pdf"),
        (Join-Path $script:AppRoot "USER_GUIDE_$lang.$theme.pdf"),
        (Join-Path $script:AppRoot "Docs\README_$lang.$theme.pdf"),
        (Join-Path $script:AppRoot "README_$lang.$theme.pdf")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    $candidates[0]
}

function Open-DocsFolder {
    $folder = Join-Path $script:AppRoot 'Docs'
    Show-LogPanelForOperation
    if (Test-Path -LiteralPath $folder -PathType Container) {
        Write-LogLine "Opening documentation: $folder" 'info'
        Start-Process -FilePath $folder
    }
    else { Write-LogLine "Documentation folder not found: $folder" 'error' }
}

function Open-UserGuideDoc {
    $file = Get-ActiveUserGuidePath
    Show-LogPanelForOperation
    if (Test-Path -LiteralPath $file -PathType Leaf) {
        Write-LogLine "Opening user guide: $file" 'info'
        Start-Process -FilePath $file
    }
    else { Write-LogLine "User guide not found: $file" 'error' }
}

function Open-ReadmeDoc {
    $file = Get-ActiveReadmePath
    Show-LogPanelForOperation
    if (Test-Path $file) {
        Write-LogLine "Opening README: $file" 'info'
        Start-Process $file
    }
    else { Write-LogLine "README not found: $file" 'error' }
}

function Open-PdfDoc {
    $file = Get-ActivePdfPath
    Show-LogPanelForOperation
    if (Test-Path $file) {
        Write-LogLine "Opening PDF: $file" 'info'
        Start-Process $file
    }
    else { Write-LogLine "PDF not found: $file" 'error' }
}

function New-PortablePowerShellInstallTweak {
    @{
        Id      = 'install-portable-powershell7'
        Title   = 'Install portable PowerShell 7 for this toolkit'
        Kind    = 'script'
        Source  = 'official'
        Tone    = 'sand'
        Control = 'button'
        RequiresAdmin  = $true
        RequiresReboot = $false
        CanRevert = $false
        Apply = {
            $root = $script:AppRoot
            if ([string]::IsNullOrWhiteSpace($root)) { throw 'App root is not available.' }

            $installer = Join-Path $root 'Install\Install-Portable-PowerShell.cmd'
            if (-not (Test-Path $installer)) { throw "Installer not found: $installer" }

            & cmd.exe /c "`"$installer`" /NOPAUSE" 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Portable PowerShell installer exited with code $LASTEXITCODE."
            }
        }
        Detect = {
            $root = $script:AppRoot
            if ([string]::IsNullOrWhiteSpace($root)) { return $false }
            Test-Path (Join-Path $root 'Engine\PowerShell\pwsh.exe')
        }
        Ru = @{
            Title = 'Установить portable PowerShell 7 для пакета'
        }
    }
}

function Invoke-PortablePowerShellInstallAsync {
    $tweak = New-PortablePowerShellInstallTweak
    Start-AsyncTweakRun @($tweak) 'apply' $script:CurrentSubsection (Get-L10n $tweak 'Title')
}

function Refresh-LangUI {
    $s = $script:S
    if (-not $s) { return }

    if ($script:SectionsLabel) { $script:SectionsLabel.Text = $s.Sections }

    if ($script:BtnApplyLabel)      { $script:BtnApplyLabel.Text      = $s.BtnApply      }
    if ($script:BtnRevertLabel)     { $script:BtnRevertLabel.Text     = $s.BtnRevert     }
    if ($script:BtnRefreshLabel)    { $script:BtnRefreshLabel.Text    = $s.BtnRefresh    }
    if ($script:BtnCleanAppLabel)   { $script:BtnCleanAppLabel.Text   = $s.BtnCleanApp   }
    if ($script:BtnDocsLabel)       { $script:BtnDocsLabel.Text      = $s.BtnDocsShort }
    if ($script:BtnInstallPwshLabel){ $script:BtnInstallPwshLabel.Text= $s.BtnInstallPwsh}
    if ($script:BtnCancelOp -and $s.BtnCancel) { $script:BtnCancelOp.Content = $s.BtnCancel }

    if ($script:LangBtnText) { $script:LangBtnText.Text = $s.LangSwitchTo }

    if (-not $script:CurrentSubsection -and $script:PanelTitle) {
        $script:PanelTitle.Text = $s.SelectSection
    }

    # Update sidebar section/subsection text blocks
    foreach ($item in $script:SidebarLangItems) {
        $item.Tb.Text = "$($item.Prefix)$(Get-L10n $item.Ht $item.Key)"
    }

    Update-RebootBanner
    Update-PwshBadge
    Update-FooterTooltips

    if ($script:CurrentSubsection) { Show-Subsection $script:CurrentSubsection }
}

#endregion

#region ════════════════ THEMES ════════════════

$script:Themes     = @()   # ordered theme list from Themes.psd1; first entry is the default
$script:ThemeId    = $null
$script:ThemePopup = $null  # dropdown popup listing all themes (built lazily on first open)

function Load-Themes {
    # Ships beside the engine, not in the project root — resolved from the module's own folder so it
    # does not depend on AppRoot being set yet.
    $path = Join-Path $PSScriptRoot 'Themes.psd1'
    if (Test-Path $path) {
        # Themes.psd1 is UTF-8 without a BOM and carries Cyrillic theme names — same reason as the
        # manifests for not going through Import-PowerShellDataFile.
        try { $script:Themes = @((Import-TweakDataFile $path).Themes) } catch { $script:Themes = @() }
    }
}

function Get-ThemePrefPath {
    Join-Path (Get-DataDir) 'theme.txt'
}

function Read-ThemePref {
    $p = Get-ThemePrefPath
    if (Test-Path $p) { try { (Get-Content $p -Raw -EA Stop).Trim() } catch { $null } }
}

function Write-ThemePref([string]$Id) {
    try { Set-Content -Path (Get-ThemePrefPath) -Value $Id -Encoding UTF8 -NoNewline } catch {}
}

function Get-ThemeById([string]$Id) {
    foreach ($t in $script:Themes) { if ($t['Id'] -eq $Id) { return $t } }
    $null
}

# Mutate the live SolidColorBrush.Color of every themed resource. Because XAML
# StaticResource and code-captured references all point at the SAME brush instance,
# this repaints the whole UI without rebuilding the visual tree (selection is kept).
function Apply-ThemeColors([hashtable]$Theme) {
    if (-not $script:Win -or -not $Theme) { return }
    $colors = $Theme['Colors']
    foreach ($key in $colors.Keys) {
        $brush = $script:Win.Resources[$key]
        if ($brush -is [System.Windows.Media.SolidColorBrush]) {
            try { $brush.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($colors[$key]) } catch {}
        }
    }
    # The window background is a literal in XAML (not a resource), so set it directly.
    if ($colors['AppBg']) {
        try { $script:Win.Background = [System.Windows.Media.SolidColorBrush]::new(
                [System.Windows.Media.ColorConverter]::ConvertFromString($colors['AppBg'])) } catch {}
    }
}

function Set-Theme([string]$Id) {
    $theme = Get-ThemeById $Id
    if (-not $theme) { return }
    $script:ThemeId = $Id
    Apply-ThemeColors $theme
    Write-ThemePref $Id
    if ($script:ThemeBtnText) { $script:ThemeBtnText.Text = $theme['Name'] }
}

function New-ThemeMenuRow([hashtable]$Theme) {
    $res       = $script:Win.Resources
    $isCurrent = ($Theme['Id'] -eq $script:ThemeId)

    $row = New-Object System.Windows.Controls.Border
    $row.CornerRadius = [System.Windows.CornerRadius]::new(5)
    $row.Padding      = [System.Windows.Thickness]::new(8,5,12,5)
    $row.Cursor       = [System.Windows.Input.Cursors]::Hand
    $row.Tag          = $Theme['Id']
    if ($isCurrent) { $row.Background = $res['CyanFill'] }

    $h = New-Object System.Windows.Controls.StackPanel
    $h.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $row.Child = $h

    # Swatch = the theme's own background, ringed with its green accent
    $sw = New-Object System.Windows.Controls.Border
    $sw.Width  = 16; $sw.Height = 16
    $sw.CornerRadius     = [System.Windows.CornerRadius]::new(4)
    $sw.Margin           = [System.Windows.Thickness]::new(0,0,9,0)
    $sw.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $sw.BorderThickness  = [System.Windows.Thickness]::new(1.5)
    try { $sw.Background  = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($Theme['Colors']['AppBg'])) } catch {}
    try { $sw.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($Theme['Colors']['GreenAccent'])) } catch {}
    $h.Children.Add($sw) | Out-Null

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text       = $Theme['Name']
    $tb.Foreground = if ($isCurrent) { $res['TitleOnCyan'] } else { $res['TitleText'] }
    $tb.FontSize   = 12
    $tb.MinWidth   = 96
    $tb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $h.Children.Add($tb) | Out-Null

    if ($isCurrent) {
        $chk = New-Object System.Windows.Controls.TextBlock
        $chk.Text       = [char]0x2713
        $chk.Foreground = $res['GreenAccent']
        $chk.FontSize   = 12
        $chk.Margin     = [System.Windows.Thickness]::new(8,0,0,0)
        $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $h.Children.Add($chk) | Out-Null
    }

    $row.Add_MouseEnter({ param($s,$e) if ($s.Tag -ne $script:ThemeId) { $s.Background = $script:Win.Resources['CyanFill'] } })
    $row.Add_MouseLeave({ param($s,$e) if ($s.Tag -ne $script:ThemeId) { $s.Background = [System.Windows.Media.Brushes]::Transparent } })
    $row.Add_MouseLeftButtonUp({
        param($s,$e)
        $id = $s.Tag
        if ($script:ThemePopup) { $script:ThemePopup.IsOpen = $false }
        if ($id) { Set-Theme $id }
    })
    $row
}

function New-ThemeMenuContent {
    $res = $script:Win.Resources
    $outer = New-Object System.Windows.Controls.Border
    $outer.Background      = $res['WindowSurface']
    $outer.BorderBrush     = $res['CyanBorder']
    $outer.BorderThickness = [System.Windows.Thickness]::new(1)
    $outer.CornerRadius    = [System.Windows.CornerRadius]::new(8)
    $outer.Padding         = [System.Windows.Thickness]::new(4)
    $outer.Margin          = [System.Windows.Thickness]::new(0,4,0,0)
    $sp = New-Object System.Windows.Controls.StackPanel
    $outer.Child = $sp
    foreach ($t in $script:Themes) { $sp.Children.Add((New-ThemeMenuRow $t)) | Out-Null }
    $outer
}

function Toggle-ThemeMenu {
    if (-not $script:ThemePopup) { return }
    if ($script:ThemePopup.IsOpen) { $script:ThemePopup.IsOpen = $false; return }
    $script:ThemePopup.Child  = New-ThemeMenuContent   # rebuild so the active check is current
    $script:ThemePopup.IsOpen = $true
}

function Close-ThemeMenuIfOpen {
    if ($script:ThemePopup -and $script:ThemePopup.IsOpen) {
        $script:ThemePopup.IsOpen = $false
    }
}

function Test-IsInsideElement($Source, $Element) {
    if (-not $Source -or -not $Element) { return $false }
    $current = $Source
    while ($current) {
        if ($current -eq $Element) { return $true }
        $parent = $null
        try {
            if ($current -is [System.Windows.DependencyObject]) {
                $parent = [System.Windows.Media.VisualTreeHelper]::GetParent($current)
            }
        } catch {}
        if (-not $parent) {
            try { $parent = [System.Windows.LogicalTreeHelper]::GetParent($current) } catch {}
        }
        $current = $parent
    }
    $false
}

#endregion

#region ════════════════ WPF WINDOW ════════════════

# How long the pointer must rest on something before its tooltip appears. Single source of truth for
# the whole interface: card help, footer buttons and the tooltips declared straight in MainWindow.xaml
# all read from here. WPF's own default is 1000 ms.
$script:TooltipInitialShowDelayMs = 1200

# Applying the delay to the FrameworkElement metadata reaches every element in the window, including
# the ones whose ToolTip is written in the XAML and never touched by this module — so the timing does
# not have to be repeated per control, and MainWindow.xaml stays free of behaviour settings.
# An element that sets its own value still wins, and the override can only be installed once per
# process: a second attempt (a module reload during development) throws and is safely ignored,
# because the value it would install is the same one already in place.
function Initialize-TooltipTiming {
    try {
        [System.Windows.Controls.ToolTipService]::InitialShowDelayProperty.OverrideMetadata(
            [System.Windows.FrameworkElement],
            (New-Object System.Windows.FrameworkPropertyMetadata([int]$script:TooltipInitialShowDelayMs)))
        [System.Windows.Controls.ToolTipService]::BetweenShowDelayProperty.OverrideMetadata(
            [System.Windows.FrameworkElement],
            (New-Object System.Windows.FrameworkPropertyMetadata([int]$script:TooltipInitialShowDelayMs)))
    } catch {}
}

function Start-TunerWindow {
    param(
        [string]$XamlPath,
        $Sections,              # [hashtable] or [hashtable[]] — one or many manifests
        [hashtable]$SystemProfile,
        [string]$AppRoot
    )

    if ($Sections -is [hashtable]) { $Sections = @($Sections) }

    # AppRoot anchors Data\, Manifests\, Strings\, Docs\, Assets\ and Install\. It used to be derived
    # from the folder holding MainWindow.xaml, which quietly tied the app's layout to where that one
    # file sat — moving the markup would have re-pointed everything else without any error. The
    # module knows its own location instead: this file lives in <root>\Engine.
    if (-not $XamlPath) { $XamlPath = Join-Path $PSScriptRoot 'MainWindow.xaml' }
    $script:AppRoot      = if ($AppRoot) { $AppRoot } else { Split-Path $PSScriptRoot -Parent }
    $script:SysProfile   = $SystemProfile
    $script:Sections     = $Sections
    $script:RebootNeeded = [System.Collections.Generic.List[string]]::new()

    # Load strings — saved choice wins; otherwise default to RU (Russian-first audience)
    $savedLang = Read-LangPref
    $startLang = if ($savedLang -eq 'ru' -or $savedLang -eq 'en') { $savedLang } else { 'ru' }
    Load-Strings $startLang

    # Load WPF
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml
    Import-Module (Join-Path $PSScriptRoot 'WindowIdentity.psm1') -Force -DisableNameChecking

    # Must run before the XAML is parsed, so the tooltips declared there pick up the timing too.
    Initialize-TooltipTiming

    # Load XAML (strip x:Class if present — XamlReader cannot resolve code-behind)
    [xml]$xaml = Get-Content $XamlPath -Encoding UTF8
    $ns = $xaml.DocumentElement.NamespaceURI
    $reader  = [System.Xml.XmlNodeReader]::new($xaml)
    $window  = [System.Windows.Markup.XamlReader]::Load($reader)
    Set-AwtWindowIdentity -Window $window -AppRoot $script:AppRoot

    # Bind named controls
    $script:Win          = $window
    $script:SectionTree  = $window.FindName('SectionTree')
    $script:CardStack    = $window.FindName('CardStack')
    $script:PanelTitle   = $window.FindName('PanelTitle')
    $script:PanelStats   = $window.FindName('PanelStats')
    $script:AdminBadge   = $window.FindName('AdminBadge')
    $script:PwshBadge    = $window.FindName('PwshBadge')
    $script:PwshBadgeText = $window.FindName('PwshBadgeText')
    $script:RebootBanner = $window.FindName('RebootBanner')
    $script:RebootText   = $window.FindName('RebootText')
    $script:BtnApply     = $window.FindName('BtnApply')
    $script:BtnRevert    = $window.FindName('BtnRevert')
    $script:BtnRefresh   = $window.FindName('BtnRefresh')
    $script:LangBtn      = $window.FindName('LangBtn')
    $script:LangBtnText  = $window.FindName('LangBtnText')
    $script:ThemeBtn     = $window.FindName('ThemeBtn')
    $script:ThemeBtnText = $window.FindName('ThemeBtnText')

    $script:BtnApplyLabel   = $window.FindName('BtnApplyLabel')
    $script:BtnRevertLabel  = $window.FindName('BtnRevertLabel')
    $script:BtnRefreshLabel = $window.FindName('BtnRefreshLabel')

    $script:BtnCleanApp         = $window.FindName('BtnCleanApp')
    $script:BtnCleanAppLabel    = $window.FindName('BtnCleanAppLabel')
    $script:BtnDocs             = $window.FindName('BtnDocs')
    $script:BtnDocsLabel        = $window.FindName('BtnDocsLabel')
    $script:BtnInstallPwsh      = $window.FindName('BtnInstallPwsh')
    $script:BtnInstallPwshLabel = $window.FindName('BtnInstallPwshLabel')

    # Progress strip controls
    $script:ProgressStrip       = $window.FindName('ProgressStrip')
    $script:OpProgressBar       = $window.FindName('OpProgressBar')
    $script:ProgressStatusText  = $window.FindName('ProgressStatusText')
    $script:ProgressCountText   = $window.FindName('ProgressCountText')
    $script:ProgressElapsedText = $window.FindName('ProgressElapsedText')
    $script:BtnCancelOp         = $window.FindName('BtnCancelOp')

    # Log / Terminal panel controls
    $script:LogBox              = $window.FindName('LogBox')
    $script:LogPanel            = $window.FindName('LogPanel')
    $script:LogSplitter         = $window.FindName('LogSplitter')
    $script:LogCol              = $window.FindName('LogCol')
    $script:LogSplitterCol      = $window.FindName('LogSplitterCol')
    $script:BtnToggleLog        = $window.FindName('BtnToggleLog')
    $script:BtnToggleLogLabel   = $window.FindName('BtnToggleLogLabel')
    $script:BtnCollapseLog      = $window.FindName('BtnCollapseLog')

    $script:TerminalBox            = $window.FindName('TerminalBox')
    $script:TerminalInput          = $window.FindName('TerminalInput')
    $script:TerminalPanel          = $window.FindName('TerminalPanel')
    $script:TerminalSplitter       = $window.FindName('TerminalSplitter')
    $script:TerminalRow            = $window.FindName('TerminalRow')
    $script:TerminalSplitterRow    = $window.FindName('TerminalSplitterRow')
    $script:BtnToggleTerminal      = $window.FindName('BtnToggleTerminal')
    $script:BtnToggleTerminalLabel = $window.FindName('BtnToggleTerminalLabel')
    $script:BtnMaximizeTerminal    = $window.FindName('BtnMaximizeTerminal')
    $script:BtnMaximizeTerminalLabel = $window.FindName('BtnMaximizeTerminalLabel')
    $script:BtnCollapseTerminal    = $window.FindName('BtnCollapseTerminal')

    # Admin indicator
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin -and $script:AdminBadge) {
        $script:AdminBadge.BorderBrush = $window.Resources['AmberAccent']
        $tb = $script:AdminBadge.Child
        if ($tb) { $tb.Text = $script:S.NotAdmin; $tb.Foreground = $window.Resources['AmberBright'] }
    }

    # Load themes and apply the saved choice (default = first theme in Themes.psd1)
    Load-Themes
    $savedTheme   = Read-ThemePref
    $initialTheme = if ($savedTheme -and (Get-ThemeById $savedTheme)) {
        $savedTheme
    } elseif ($script:Themes.Count -gt 0) {
        $script:Themes[0]['Id']
    } else { $null }
    if ($initialTheme) { Set-Theme $initialTheme }

    # Build the section tree
    Build-SectionTree $window $Sections $SystemProfile

    # Apply initial string values to dynamic controls
    if ($script:BtnApplyLabel)      { $script:BtnApplyLabel.Text      = $script:S.BtnApply      }
    if ($script:BtnRevertLabel)     { $script:BtnRevertLabel.Text     = $script:S.BtnRevert     }
    if ($script:BtnRefreshLabel)    { $script:BtnRefreshLabel.Text    = $script:S.BtnRefresh    }
    if ($script:BtnCleanAppLabel)   { $script:BtnCleanAppLabel.Text   = $script:S.BtnCleanApp   }
    if ($script:BtnDocsLabel)       { $script:BtnDocsLabel.Text      = $script:S.BtnDocsShort }
    if ($script:BtnInstallPwshLabel){ $script:BtnInstallPwshLabel.Text= $script:S.BtnInstallPwsh}
    if ($script:BtnCancelOp -and $script:S.BtnCancel) { $script:BtnCancelOp.Content = $script:S.BtnCancel }
    if ($script:LangBtnText)        { $script:LangBtnText.Text        = $script:S.LangSwitchTo  }
    Update-PwshBadge
    Update-FooterTooltips

    # Wire footer buttons (operate on currently displayed subsection)
    if ($script:BtnApply) {
        $script:BtnApply.Add_Click({
            if ($script:CurrentSubsection) { Invoke-SubsectionOpAsync $script:CurrentSubsection 'apply' }
        })
    }
    if ($script:BtnRevert) {
        $script:BtnRevert.Add_Click({
            if ($script:CurrentSubsection) { Invoke-SubsectionOpAsync $script:CurrentSubsection 'revert' }
        })
    }
    if ($script:BtnRefresh) {
        $script:BtnRefresh.Add_Click({
            if ($script:CurrentSubsection) {
                $ids = @($script:CurrentSubsection['Tweaks'] | Where-Object { $_ -is [hashtable] } | ForEach-Object { [string]$_['Id'] })
                Clear-CachedTweakState $ids
                Clear-PackageCaches      # Refresh means "ask the machine again", not "re-read the cache"
                Show-Subsection $script:CurrentSubsection
            }
        })
    }
    if ($script:BtnCancelOp) {
        $script:BtnCancelOp.Add_Click({ Stop-CurrentOp })
    }

    if ($script:BtnCleanApp) {
        $script:BtnCleanApp.Add_Click({ Invoke-CleanApp })
    }
    if ($script:BtnDocs) {
        $script:BtnDocs.Add_Click({ Open-DocsFolder })
    }
    if ($script:BtnInstallPwsh) {
        $script:BtnInstallPwsh.Add_Click({
            Invoke-PortablePowerShellInstallAsync
        })
    }

    # Wire language toggle via PreviewMouseLeftButtonDown (Click is unreliable under computer-use)
    if ($script:LangBtn) {
        $script:LangBtn.Add_PreviewMouseLeftButtonDown({
            param($s,$e)
            $e.Handled = $true
            $newLang = if ($script:Lang -eq 'en') { 'ru' } else { 'en' }
            Set-Language $newLang
        })
    }

    # Wire theme dropdown — button opens a popup listing every theme
    if ($script:ThemeBtn) {
        $script:ThemePopup = New-Object System.Windows.Controls.Primitives.Popup
        $script:ThemePopup.PlacementTarget    = $script:ThemeBtn
        $script:ThemePopup.Placement          = [System.Windows.Controls.Primitives.PlacementMode]::Bottom
        $script:ThemePopup.StaysOpen          = $true
        $script:ThemePopup.AllowsTransparency = $true
        $script:ThemeBtn.Add_Click({
            param($s,$e)
            $e.Handled = $true
            Toggle-ThemeMenu
        })
    }
    $window.Add_PreviewMouseLeftButtonDown({
        param($s,$e)
        if (Test-IsInsideElement $e.OriginalSource $script:ThemeBtn) { return }
        Close-ThemeMenuIfOpen
    })
    $window.Add_Deactivated({
        Close-ThemeMenuIfOpen
    })

    # Wire Log panel toggle / collapse
    if ($script:BtnToggleLog) {
        $script:BtnToggleLog.Add_Click({ Toggle-LogPanel })
    }
    if ($script:BtnCollapseLog) {
        $script:BtnCollapseLog.Add_Click({ Close-LogPanel })
    }
    if ($script:LogSplitter) {
        $script:LogSplitter.Add_DragCompleted({
            $script:LogPanelAutoOpened = $false
            Save-PanelLayout
        })
    }

    # Wire Terminal panel toggle / collapse
    if ($script:BtnToggleTerminal) {
        $script:BtnToggleTerminal.Add_Click({ Toggle-TerminalPanel })
    }
    if ($script:BtnMaximizeTerminal) {
        $script:BtnMaximizeTerminal.Add_Click({ Toggle-TerminalMaximized })
    }
    if ($script:BtnCollapseTerminal) {
        $script:BtnCollapseTerminal.Add_Click({ Close-TerminalPanel })
    }
    if ($script:TerminalSplitter) {
        $script:TerminalSplitter.Add_DragCompleted({
            $script:TerminalPanelAutoOpened = $false
            if ($script:TerminalRow -and $script:TerminalRow.Height.Value -gt 0) {
                $script:TerminalMaximized = $false
                $script:TerminalRestoreHeight = [double]$script:TerminalRow.Height.Value
                Update-TerminalMaximizeButton
            }
            Save-PanelLayout
        })
    }

    # Wire terminal input — Enter runs command, Up recalls last command
    if ($script:TerminalInput) {
        $script:TerminalInput.Add_KeyDown({
            param($s,$e)
            if ($e.Key -eq [System.Windows.Input.Key]::Return) {
                $e.Handled = $true
                $cmd = $script:TerminalInput.Text.Trim()
                $script:TerminalInput.Text = ''
                if ($cmd) { Invoke-TerminalCommand $cmd }
            }
        })
    }

    # Show first subsection of first section by default
    $firstSection = $Sections | Sort-Object { $_['Order'] } | Select-Object -First 1
    $firstSub = $firstSection['Subsections'] | Where-Object { $_ -is [hashtable] } |
                Sort-Object { $_['Order'] } | Select-Object -First 1
    if ($firstSub) { Show-Subsection $firstSub }

    $window.Add_Loaded({
        Apply-PanelLayout
        Save-PanelLayout
    })
    $window.Add_Closing({
        Save-PanelLayout
    })

    $window.ShowDialog() | Out-Null
}

# Track current selection
$script:CurrentSubsection   = $null
$script:SelectedTreeItem    = $null

function Build-SectionTree([System.Windows.Window]$Window, $Sections, [hashtable]$Profile) {
    # $Sections: single hashtable or array of hashtables
    if ($Sections -is [hashtable]) { $Sections = @($Sections) }

    $script:SidebarLangItems.Clear()

    $tree = $script:SectionTree
    $tree.Children.Clear()

    $label = New-Object System.Windows.Controls.TextBlock
    $label.Text       = if ($script:S) { $script:S.Sections } else { 'SECTIONS' }
    $label.Foreground = $Window.Resources['HeaderHint']
    $label.FontSize   = 10
    $label.Margin     = [System.Windows.Thickness]::new(12,8,12,4)
    $script:SectionsLabel = $label
    $tree.Children.Add($label) | Out-Null

    foreach ($section in ($Sections | Sort-Object { $_['Order'] })) {
        $tree.Children.Add((New-SectionGroup $Window $section)) | Out-Null
    }
}

# Builds a collapsible section group: header row + nested subsection rows
function New-SectionGroup([System.Windows.Window]$Window, [hashtable]$Section) {
    $wrapper = New-Object System.Windows.Controls.StackPanel

    # ── Section header (collapsible) ──────────────────────────────────
    $headerBorder = New-Object System.Windows.Controls.Border
    $headerBorder.Cursor = [System.Windows.Input.Cursors]::Hand
    $headerBorder.Padding = [System.Windows.Thickness]::new(10,6,10,6)

    $headerRow = New-Object System.Windows.Controls.StackPanel
    $headerRow.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    $arrow = New-Object System.Windows.Controls.TextBlock
    $arrow.Text      = [char]0x25BC   # ▼ expanded by default
    $arrow.FontSize  = 8
    $arrow.Foreground = $Window.Resources['HeaderHint']
    $arrow.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $arrow.Margin    = [System.Windows.Thickness]::new(0,0,6,0)

    $secTb = New-Object System.Windows.Controls.TextBlock
    $secTb.Text       = "$($Section['Order']). $(Get-L10n $Section 'Title')"
    $secTb.Foreground = $Window.Resources['SidebarText']
    $secTb.FontSize   = 12
    $secTb.FontWeight = [System.Windows.FontWeights]::SemiBold
    $secTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $secTb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:SidebarLangItems.Add([pscustomobject]@{Tb=$secTb; Ht=$Section; Key='Title'; Prefix="$($Section['Order']). "})

    $headerRow.Children.Add($arrow)  | Out-Null
    $headerRow.Children.Add($secTb)  | Out-Null
    $headerBorder.Child = $headerRow

    # ── Subsection children panel (collapsible) ───────────────────────
    $childPanel = New-Object System.Windows.Controls.StackPanel
    $childPanel.Margin = [System.Windows.Thickness]::new(0,0,0,4)

    $subs = @($Section['Subsections'] | Where-Object { $_ -is [hashtable] } | Sort-Object { $_['Order'] })
    foreach ($sub in $subs) {
        $childPanel.Children.Add((New-TreeRow $Window $sub)) | Out-Null
    }

    # Toggle expand/collapse on header click
    $headerBorder.Tag = $childPanel
    $headerBorder.Add_MouseEnter({
        param($s,$e)
        $s.Background = $script:Win.Resources['CyanFill']
    })
    $headerBorder.Add_MouseLeave({
        param($s,$e)
        $s.Background = [System.Windows.Media.Brushes]::Transparent
    })
    $headerBorder.Add_MouseLeftButtonUp({
        param($s,$e)
        $panel = $s.Tag
        $arrowTb = ($s.Child).Children[0]
        if ($panel.Visibility -eq [System.Windows.Visibility]::Visible) {
            $panel.Visibility = [System.Windows.Visibility]::Collapsed
            $arrowTb.Text = [char]0x25BA   # ▶ collapsed
        } else {
            $panel.Visibility = [System.Windows.Visibility]::Visible
            $arrowTb.Text = [char]0x25BC   # ▼ expanded
        }
    })

    $wrapper.Children.Add($headerBorder) | Out-Null
    $wrapper.Children.Add($childPanel)   | Out-Null
    $wrapper
}

function New-TreeRow([System.Windows.Window]$Window, [hashtable]$Sub) {
    $outer = New-Object System.Windows.Controls.Border
    $outer.Tag    = $Sub
    $outer.Cursor = [System.Windows.Input.Cursors]::Hand

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text        = Get-L10n $Sub 'Title'
    $tb.Padding     = [System.Windows.Thickness]::new(32,4,12,4)
    $tb.Foreground  = $Window.Resources['SidebarMuted']
    $tb.FontWeight  = [System.Windows.FontWeights]::Medium
    $tb.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $outer.Child    = $tb
    $script:SidebarLangItems.Add([pscustomobject]@{Tb=$tb; Ht=$Sub; Key='Title'; Prefix=''})

    $outer.Add_MouseEnter({
        param($s,$e)
        if ($s -ne $script:SelectedTreeItem) {
            $s.Background = $script:Win.Resources['CyanFill']
        }
    })
    $outer.Add_MouseLeave({
        param($s,$e)
        if ($s -ne $script:SelectedTreeItem) {
            $s.Background = [System.Windows.Media.Brushes]::Transparent
        }
    })
    $outer.Add_MouseLeftButtonUp({
        param($s,$e)
        $clickedSub = $s.Tag -as [hashtable]
        if (-not $clickedSub) { return }

        if ($script:SelectedTreeItem -and $script:SelectedTreeItem -ne $s) {
            $script:SelectedTreeItem.Background     = [System.Windows.Media.Brushes]::Transparent
            $script:SelectedTreeItem.BorderThickness = [System.Windows.Thickness]::new(0)
            ($script:SelectedTreeItem.Child).Foreground = $script:Win.Resources['SidebarMuted']
        }
        $s.Background      = $script:Win.Resources['CyanFill']
        $s.BorderBrush     = $script:Win.Resources['GreenDeep']
        $s.BorderThickness = [System.Windows.Thickness]::new(3,0,0,0)
        ($s.Child).Foreground = $script:Win.Resources['TitleOnCyan']

        $script:SelectedTreeItem = $s
        Show-Subsection $clickedSub
    })

    $outer
}

function Invoke-CleanApp {
    $msg = if ($script:S -and $script:S.BtnCleanConfirm) { $script:S.BtnCleanConfirm } else {
        "Clear all backups and the session log?`nApp state resets to fresh — cannot be undone." }
    $ans = [System.Windows.MessageBox]::Show($msg, 'Audion Windows Tools by Max.mov', 'YesNo', 'Warning')
    if ($ans -ne 'Yes') { return }

    $backupDir = Get-BackupDir
    if (Test-Path $backupDir) {
        Get-ChildItem $backupDir -Filter '*.json' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    # Reset appearance to the baseline: Graphite theme + English UI (overwrites theme.txt / lang.txt)
    Set-Theme 'graphite'
    Set-Language 'en'
    if ($script:LogBox) { $script:LogBox.Document.Blocks.Clear() }
    if ($script:RebootNeeded) { $script:RebootNeeded.Clear() }
    Clear-CachedTweakState
    Reset-PanelLayout
    Update-RebootBanner
    $script:SelectedTweakIds.Clear()
    if ($script:CurrentSubsection) { Show-Subsection $script:CurrentSubsection }
    Write-LogLine 'Audion Windows Tools by Max.mov — ready' 'info'
}

function Get-UiText([string]$Key, [string]$Fallback) {
    if ($script:S -and $script:S.ContainsKey($Key) -and $script:S[$Key]) { return $script:S[$Key] }
    $Fallback
}

function Test-OrderedSubsection([hashtable]$Sub) {
    if (-not $Sub) { return $false }
    $selectionMode = [string]$Sub['SelectionMode']
    $flow          = [string]$Sub['Flow']
    ($selectionMode -eq 'ordered' -or $flow -eq 'ordered')
}

function Test-CardsOnlySubsection([hashtable]$Sub) {
    if (-not $Sub) { return $false }
    $selectionMode = [string]$Sub['SelectionMode']
    if ($selectionMode -eq 'cards-only' -or $selectionMode -eq 'buttons-only') { return $true }
    if ($selectionMode) { return $false }   # any other explicit mode (e.g. 'ordered') wins as-is

    # Auto: a subsection with NO toggle controls has nothing to batch — the footer Apply would
    # only fire one-shot actions (links, installs, reboots) all at once, which is useless and
    # dangerous. Treat it as card-buttons-only so the footer is disabled and per-card buttons rule.
    $tweaks = @($Sub['Tweaks'] | Where-Object { $_ -is [hashtable] })
    if ($tweaks.Count -eq 0) { return $false }
    foreach ($t in $tweaks) { if ([string]$t['Control'] -eq 'toggle') { return $false } }
    $true
}

function Update-FooterModeDisplay {
    $isOrdered = Test-OrderedSubsection $script:CurrentSubsection
    $isCardsOnly = Test-CardsOnlySubsection $script:CurrentSubsection
    if ($script:BtnApplyLabel) {
        $script:BtnApplyLabel.Text = if ($isCardsOnly) {
            Get-UiText 'BtnCardButtonsOnly' 'Use card buttons'
        } elseif ($isOrdered) {
            Get-UiText 'BtnNextStep' 'Next step'
        } else {
            Get-UiText 'BtnApply' 'Apply section'
        }
    }
    if ($script:BtnRevertLabel) {
        $script:BtnRevertLabel.Text = if ($isCardsOnly) {
            Get-UiText 'BtnCardButtonsOnly' 'Use card buttons'
        } elseif ($isOrdered) {
            Get-UiText 'BtnRevertStep' 'Revert step'
        } else {
            Get-UiText 'BtnRevert' 'Revert'
        }
    }
    if ($script:BtnApply)  { $script:BtnApply.IsEnabled  = -not $isCardsOnly }
    if ($script:BtnRevert) { $script:BtnRevert.IsEnabled = -not $isCardsOnly }
}

function Get-OrderedTweakForOperation([hashtable]$Sub, [string]$OpMode) {
    $tweaks = @($Sub['Tweaks'] | Where-Object { $_ -is [hashtable] })

    if ($OpMode -eq 'apply') {
        foreach ($tweak in $tweaks) {
            if ((Test-TweakApplicable $tweak $script:SysProfile) -eq $false) { continue }
            $state = Test-TweakState $tweak $script:SysProfile
            if ($state -ne 'Applied' -and $state -ne 'NotApplicable') { return @($tweak) }
        }
        return @()
    }

    $lastApplied = $null
    foreach ($tweak in $tweaks) {
        if ((Test-TweakApplicable $tweak $script:SysProfile) -eq $false) { continue }
        if ((Test-TweakState $tweak $script:SysProfile) -eq 'Applied') { $lastApplied = $tweak }
    }
    if ($lastApplied) { return @($lastApplied) }
    @()
}

function Start-AsyncStatusRefresh([hashtable]$Sub) {
    if (-not $Sub) { return }

    $script:StatusRefreshVersion++
    $version    = $script:StatusRefreshVersion
    $moduleSelf = $MyInvocation.MyCommand.Module
    $modulePath = Join-Path $script:AppRoot 'Engine\TweakEngine.psm1'
    $appRoot    = $script:AppRoot
    $sysProfile = $script:SysProfile
    $lang       = $script:Lang

    $ps = [System.Management.Automation.PowerShell]::Create()
    $null = $ps.AddScript({
        param($Subsection, $SysProfile, $AppRoot, $ModulePath, $Lang, $Version)

        $mod = Import-Module $ModulePath -DisableNameChecking -Force -PassThru
        & $mod {
            param($a, $s, $l)
            $script:AppRoot    = $a
            $script:SysProfile = $s
            $script:Lang       = $l
            Initialize-NativeCommandEncoding
        } $AppRoot $SysProfile $Lang

        $rows = [System.Collections.Generic.List[object]]::new()
        foreach ($tweak in @($Subsection['Tweaks'] | Where-Object { $_ -is [hashtable] })) {
            $state = 'Unknown'
            try { $state = Test-TweakState $tweak $SysProfile } catch {}
            $rows.Add([pscustomobject]@{
                Id    = [string]$tweak['Id']
                State = [string]$state
            }) | Out-Null
        }

        [pscustomobject]@{
            Version = $Version
            SubId   = [string]$Subsection['Id']
            Rows    = @($rows)
        }
    }).AddArgument($Sub).AddArgument($sysProfile).AddArgument($appRoot).AddArgument($modulePath).AddArgument($lang).AddArgument($version)

    $asyncResult = $ps.BeginInvoke()
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(120)
    $timer.Add_Tick({
        if (-not $asyncResult.IsCompleted) { return }
        $timer.Stop()

        $result = $null
        try { $result = $ps.EndInvoke($asyncResult) | Select-Object -Last 1 } catch {}
        $ps.Dispose()

        & $moduleSelf {
            param($res)
            if (-not $res) { return }
            if ([int]$res.Version -ne [int]$script:StatusRefreshVersion) { return }
            if (-not $script:CurrentSubsection) { return }
            if ([string]$script:CurrentSubsection['Id'] -ne [string]$res.SubId) { return }

            foreach ($row in @($res.Rows)) {
                Set-CachedTweakState ([string]$row.Id) ([string]$row.State)
            }
            Show-Subsection $script:CurrentSubsection -SkipAsyncRefresh
        } $result
    }.GetNewClosure())
    $timer.Start()
}

function Update-SelectionDisplay {
    if (-not $script:PanelStats -or -not $script:CurrentSubsection) { return }
    if ((Test-OrderedSubsection $script:CurrentSubsection) -or (Test-CardsOnlySubsection $script:CurrentSubsection)) { $script:SelectedTweakIds.Clear() }
    $tweaks   = @($script:CurrentSubsection['Tweaks'] | Where-Object { $_ -is [hashtable] })
    $states   = Get-SubsectionCachedStates $script:CurrentSubsection
    $applied  = ($states.Values | Where-Object { $_ -eq 'Applied' }).Count
    $fmt      = if ($script:S) { $script:S.StatsFmt } else { '{0} settings · {1} applied' }
    $base     = $fmt -f $tweaks.Count, $applied
    if (Test-OrderedSubsection $script:CurrentSubsection) {
        $base += Get-UiText 'OrderedFlowSuffix' '  ·  ordered'
    } elseif (Test-CardsOnlySubsection $script:CurrentSubsection) {
        $base += Get-UiText 'CardsOnlySuffix' '  ·  card buttons only'
    }
    $selCount = $script:SelectedTweakIds.Count
    if ($selCount -gt 0) {
        $selFmt = if ($script:S -and $script:S.SelFmt) { $script:S.SelFmt } else { '  ·  {0} selected' }
        $script:PanelStats.Text = $base + ($selFmt -f $selCount)
    } else {
        $script:PanelStats.Text = $base
    }
}

function Show-Subsection([hashtable]$Sub, [switch]$SkipAsyncRefresh) {
    if ($script:CurrentSubsection -ne $Sub) { $script:SelectedTweakIds.Clear() }
    $script:CurrentSubsection = $Sub
    if ((Test-OrderedSubsection $Sub) -or (Test-CardsOnlySubsection $Sub)) { $script:SelectedTweakIds.Clear() }
    $tweaks  = @($Sub['Tweaks'] | Where-Object { $_ -is [hashtable] })

    # Fast path: render immediately from the short-lived cache, then refresh Detect in the background.
    $states = Get-SubsectionCachedStates $Sub

    $appliedCount = ($states.Values | Where-Object { $_ -eq 'Applied' }).Count
    $totalCount   = $tweaks.Count

    # Update header
    if ($script:PanelTitle) { $script:PanelTitle.Text = Get-L10n $Sub 'Title' }
    if ($script:PanelStats) {
        $fmt      = if ($script:S) { $script:S.StatsFmt } else { '{0} settings · {1} applied' }
        $base     = $fmt -f $totalCount, $appliedCount
        if (Test-OrderedSubsection $Sub) {
            $base += Get-UiText 'OrderedFlowSuffix' '  ·  ordered'
        } elseif (Test-CardsOnlySubsection $Sub) {
            $base += Get-UiText 'CardsOnlySuffix' '  ·  card buttons only'
        }
        $selCount = $script:SelectedTweakIds.Count
        if ($selCount -gt 0) {
            $selFmt = if ($script:S -and $script:S.SelFmt) { $script:S.SelFmt } else { '  ·  {0} selected' }
            $script:PanelStats.Text = $base + ($selFmt -f $selCount)
        } else {
            $script:PanelStats.Text = $base
        }
    }

    Update-FooterModeDisplay

    # Rebuild cards
    $stack = $script:CardStack
    $stack.Children.Clear()

    foreach ($tweak in $tweaks) {
        $state = if ($states.Contains($tweak['Id'])) { $states[$tweak['Id']] } else { 'Unknown' }
        $card  = New-TweakCard $tweak $state
        $stack.Children.Add($card) | Out-Null
    }

    if (-not $SkipAsyncRefresh -and -not (Test-SubsectionStateCacheFresh $Sub)) {
        Start-AsyncStatusRefresh $Sub
    }
}

function Update-RebootBanner {
    if (-not $script:RebootBanner) { return }
    if ($script:RebootNeeded.Count -gt 0) {
        $script:RebootBanner.Visibility = [System.Windows.Visibility]::Visible
        if ($script:RebootText) {
            $fmt = if ($script:S) { $script:S.RebootFmt } else { 'Restart required after: {0}' }
            $script:RebootText.Text = ($fmt -f ($script:RebootNeeded -join ', '))
        }
    } else {
        $script:RebootBanner.Visibility = [System.Windows.Visibility]::Collapsed
    }
}

function Set-Progress([int]$Current, [int]$Total, [string]$Title) {
    if ($script:OpProgressBar) {
        $script:OpProgressBar.IsIndeterminate = $false
        $script:OpProgressBar.Maximum         = $Total
        $script:OpProgressBar.Value           = $Current
    }
    if ($script:ProgressStatusText -and $Title) {
        $script:ProgressStatusText.Text = $Title
    }
    if ($script:ProgressCountText) {
        $fmt = if ($script:S -and $script:S.ProgressFmt) { $script:S.ProgressFmt } else { '{0} / {1}' }
        $script:ProgressCountText.Text = $fmt -f $Current, $Total
    }
}

function Format-Elapsed([TimeSpan]$Span) {
    # Locale-neutral: H:MM:SS once past an hour, else M:SS. Pure indicator — never a deadline.
    if ($Span.TotalHours -ge 1) {
        '{0}:{1:00}:{2:00}' -f [int][math]::Floor($Span.TotalHours), $Span.Minutes, $Span.Seconds
    } else {
        '{0}:{1:00}' -f $Span.Minutes, $Span.Seconds
    }
}

function Update-ProgressElapsed {
    if (-not $script:ProgressElapsedText -or -not $script:OpStartTime) { return }
    $script:ProgressElapsedText.Text = Format-Elapsed ([datetime]::Now - $script:OpStartTime)
}

function Set-FooterBusy([bool]$Busy, [string]$OpMode = 'apply') {
    $script:BtnApply.IsEnabled   = -not $Busy
    $script:BtnRevert.IsEnabled  = -not $Busy
    $script:BtnRefresh.IsEnabled = -not $Busy
    if ($Busy) {
        if ($OpMode -eq 'apply' -and $script:BtnApplyLabel) {
            $script:BtnApplyLabel.Text = Get-UiText 'BtnApplyBusy' 'Applying...'
        } elseif ($OpMode -eq 'revert' -and $script:BtnRevertLabel) {
            $script:BtnRevertLabel.Text = Get-UiText 'BtnRevertBusy' 'Reverting...'
        }
    } else {
        Update-FooterModeDisplay
    }
    if ($script:ProgressStrip) {
        $script:ProgressStrip.Visibility = if ($Busy) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    }
    if ($Busy) {
        if ($script:OpProgressBar) {
            $script:OpProgressBar.IsIndeterminate = $true
            $script:OpProgressBar.Value           = 0
        }
        if ($script:ProgressStatusText) {
            $script:ProgressStatusText.Text = if ($OpMode -eq 'apply') {
                if ($script:S -and $script:S.BtnApplyBusy) { $script:S.BtnApplyBusy } else { 'Applying…' }
            } else {
                if ($script:S -and $script:S.BtnRevertBusy) { $script:S.BtnRevertBusy } else { 'Reverting…' }
            }
        }
        if ($script:ProgressCountText) { $script:ProgressCountText.Text = '' }
        if ($script:ProgressElapsedText) { $script:ProgressElapsedText.Text = '0:00' }
    }
}

# Shared async runner for one or many tweaks. Runs them in a background runspace (UI never
# freezes), streams progress to the strip and command output live to the Terminal panel, and
# on completion updates the reboot banner, log, and re-renders $Sub. Used by both the footer
# batch Apply/Revert and the per-card action buttons.
function Start-AsyncTweakRun([object[]]$Tweaks, [string]$OpMode, [hashtable]$Sub, [string]$LogTitle) {
    if (-not $Tweaks -or $Tweaks.Count -eq 0) { return }
    $needsTerminal = Test-OperationNeedsTerminal $Tweaks

    if ($script:CurrentOpPowerShell) {
        $busyText = Get-UiText 'OpBusy' 'An operation is already running — please wait.'
        Show-LogPanelForOperation
        Write-LogLine $busyText 'warn'
        $attempt = if ($LogTitle) {
            (Get-UiText 'OpBusyNotStartedFmt' 'An operation is already running — "{0}" was not started.') -f $LogTitle
        } else {
            $busyText
        }
        if ($needsTerminal) {
            Show-TerminalPanelForOperation
            Write-TerminalLine $attempt 'warn'
        }
        return
    }

    Set-FooterBusy $true $OpMode
    $logVerb = if ($OpMode -eq 'apply') { 'Applying' } else { 'Reverting' }
    Show-LogPanelForOperation
    Write-LogLine "${logVerb}: $LogTitle" 'info'
    if ($needsTerminal) {
        Show-TerminalPanelForOperation
        Write-TerminalLine ""
        Write-TerminalLine "--- ${logVerb}: $LogTitle ---" 'cmd'
    }

    $moduleSelf    = $MyInvocation.MyCommand.Module
    $modulePath    = Join-Path $script:AppRoot 'Engine\TweakEngine.psm1'
    $appRoot       = $script:AppRoot
    $sysProfile    = $script:SysProfile
    $opMode        = $OpMode
    $lang          = $script:Lang
    $progressQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
    $outputQueue   = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
    # Cancel has to reach the native installer, not just the pipeline: [PowerShell]::Stop() cannot
    # interrupt a child process, so the token is what Invoke-NativeProcess actually watches.
    $cancelSource  = New-Object System.Threading.CancellationTokenSource

    $ps = [System.Management.Automation.PowerShell]::Create()
    $null = $ps.AddScript({
        param($Tweaks, $OpMode, $SysProfile, $AppRoot, $ModulePath, $ProgressQueue, $OutputQueue, $Lang, $CancelSource)
        $mod = Import-Module $ModulePath -DisableNameChecking -Force -PassThru
        & $mod { Initialize-NativeCommandEncoding }
        # Seed the MODULE's script scope — top-level runspace assignment is NOT visible to module
        # functions (they read $script: from their own session state). This also fixes Get-DataDir
        # (backups) and Get-L10n (localized titles) in the background runspace.
        & $mod {
            param($a, $s, $l, $q, $c)
            $script:AppRoot      = $a
            $script:SysProfile   = $s
            $script:Lang         = $l
            $script:OutputQueue  = $q
            $script:LineSink     = { param($line) $script:OutputQueue.Enqueue($line) }
            $script:CancelToken  = $c.Token
            # Installer verdicts are localized through Get-UiText, so the background runspace needs
            # the strings table too — without it every verdict would fall back to English.
            Load-Strings $l
        } $AppRoot $SysProfile $Lang $OutputQueue $CancelSource

        $errors       = [System.Collections.Generic.List[string]]::new()
        $rebootTitles = [System.Collections.Generic.List[string]]::new()
        $i     = 0
        $total = $Tweaks.Count

        foreach ($tweak in $Tweaks) {
            $i++
            $ProgressQueue.Enqueue([PSCustomObject]@{ Current = $i; Total = $total; Tweak = $tweak })
            if ((Test-TweakApplicable $tweak $SysProfile) -eq $false) { continue }
            try {
                if ($OpMode -eq 'apply') {
                    Invoke-TweakApply $tweak $SysProfile
                    if ($tweak['RequiresReboot']) { $rebootTitles.Add((Get-L10n $tweak 'Title')) }
                } else {
                    Invoke-TweakRevert $tweak
                }
            } catch {
                $errors.Add("$(Get-L10n $tweak 'Title'): $_")
            }
        }
        [pscustomobject]@{ Errors = $errors; RebootTitles = $rebootTitles }
    }).AddArgument($Tweaks).AddArgument($opMode).AddArgument($sysProfile).AddArgument($appRoot).AddArgument($modulePath).AddArgument($progressQueue).AddArgument($outputQueue).AddArgument($lang).AddArgument($cancelSource)

    $script:CurrentOpPowerShell   = $ps
    $script:CurrentOpCancelSource = $cancelSource
    $script:OpCancelled           = $false
    $script:OpStartTime         = [datetime]::Now
    $asyncResult = $ps.BeginInvoke()
    $subCapture  = $Sub
    $opCapture   = $OpMode
    $idsCapture  = @($Tweaks | Where-Object { $_ -is [hashtable] } | ForEach-Object { [string]$_['Id'] })
    $completed   = $false
    $termOpened  = $needsTerminal
    $terminalStatus = @{
        LastOutputAt = [datetime]::Now
        LastNoticeAt = $null
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(60)
    $timer.Add_Tick({
        $item = [object]$null
        while ($progressQueue.TryDequeue([ref]$item)) {
            $p = $item
            & $moduleSelf { param($x) Set-Progress $x.Current $x.Total (Get-L10n $x.Tweak 'Title') } $p
        }
        # Stream command output to the Terminal panel, opening it on the first line
        $line = [object]$null
        $lines = [System.Collections.Generic.List[string]]::new()
        while ($outputQueue.TryDequeue([ref]$line)) {
            $lines.Add("$line") | Out-Null
        }
        if ($lines.Count -gt 0) {
            $terminalStatus['LastOutputAt'] = [datetime]::Now
            $terminalStatus['LastNoticeAt'] = $null
            if (-not $termOpened) { $termOpened = $true; & $moduleSelf { Show-TerminalPanelForOperation } }
            & $moduleSelf { param($ls) Write-TerminalLines $ls 'output' } $lines.ToArray()
        }
        & $moduleSelf { Update-ProgressElapsed }

        # winget prints nothing at all while it downloads a package with its stdout redirected, so a
        # multi-minute install used to look identical to a frozen app. Keep saying "still working,
        # this long without output" until something arrives — a one-shot notice was not enough.
        if ($termOpened -and -not $completed -and -not $asyncResult.IsCompleted) {
            $quietFor = ([datetime]::Now - [datetime]$terminalStatus['LastOutputAt']).TotalSeconds
            $lastNotice = $terminalStatus['LastNoticeAt']
            $dueForNotice = if ($null -eq $lastNotice) { $quietFor -ge 3 } else { (([datetime]::Now - [datetime]$lastNotice).TotalSeconds -ge 20) }
            if ($quietFor -ge 3 -and $dueForNotice) {
                $terminalStatus['LastNoticeAt'] = [datetime]::Now
                if ($null -eq $lastNotice) {
                    & $moduleSelf { Write-TerminalLine (Get-UiText 'TerminalWaitingOutput' 'Command is still running; output may arrive in bursts...') 'cmd' }
                } else {
                    & $moduleSelf {
                        param($secs)
                        Write-TerminalLine ((Get-UiText 'TerminalStillWorkingFmt' 'Still working — {0} without output. This is normal while a package downloads; Cancel stops the step.') -f (Format-Elapsed ([TimeSpan]::FromSeconds($secs)))) 'cmd'
                    } ([int]$quietFor)
                }
            }
        }
        if ($completed -or -not $asyncResult.IsCompleted) { return }
        $completed = $true
        $timer.Stop()

        $result = $null
        try { $result = $ps.EndInvoke($asyncResult) | Select-Object -Last 1 } catch {}
        $ps.Dispose()

        & $moduleSelf {
            param($res, $op, $sub, $ids)
            try {
                $script:CurrentOpPowerShell = $null
                Clear-CurrentOpCancelSource
                $script:OpStartTime = $null
                Clear-CachedTweakState $ids
                if ($res -and $res.RebootTitles) {
                    foreach ($t in $res.RebootTitles) {
                        if (-not ($script:RebootNeeded -contains $t)) { $script:RebootNeeded.Add($t) }
                    }
                }
                if ($op -eq 'revert') { $script:RebootNeeded.Clear() }
                if ($res -and $res.Errors.Count -gt 0) {
                    foreach ($err in $res.Errors) { Write-LogLine $err 'error' }
                    [System.Windows.MessageBox]::Show(($res.Errors -join "`n"), 'Audion Windows Tools by Max.mov', 'OK', 'Error') | Out-Null
                } elseif ($script:OpCancelled) {
                    $script:OpCancelled = $false
                    Write-LogLine (Get-UiText 'OpCancelled' 'Cancelled') 'warn'
                } else {
                    $verb = if ($op -eq 'apply') { 'Applied' } else { 'Reverted' }
                    Write-LogLine "$($verb): $(Get-L10n $sub 'Title')" 'ok'
                }
                Update-RebootBanner
                Set-FooterBusy $false $op
                Show-Subsection $sub
            } catch {
                try {
                    $script:CurrentOpPowerShell = $null
                    Clear-CurrentOpCancelSource
                    $script:OpStartTime = $null
                    Set-FooterBusy $false $op
                } catch {}
            }
        } $result $opCapture $subCapture $idsCapture
    }.GetNewClosure())
    $timer.Start()
}

function Invoke-SubsectionOpAsync([hashtable]$Sub, [string]$OpMode) {
    if (Test-CardsOnlySubsection $Sub) {
        $script:SelectedTweakIds.Clear()
        Write-LogLine (Get-UiText 'CardsOnlyLog' 'This subsection uses individual card buttons only.') 'info'
        Update-SelectionDisplay
        Update-FooterModeDisplay
        return
    }

    $isOrdered = Test-OrderedSubsection $Sub
    $tweaks    = @($Sub['Tweaks'] | Where-Object { $_ -is [hashtable] })
    if ($isOrdered) {
        $script:SelectedTweakIds.Clear()
        $tweaks = @(Get-OrderedTweakForOperation $Sub $OpMode)
        if ($tweaks.Count -eq 0) {
            $msgKey = if ($OpMode -eq 'apply') { 'OrderedNoPending' } else { 'OrderedNoApplied' }
            $msgFallback = if ($OpMode -eq 'apply') {
                'No pending steps in this ordered workflow.'
            } else {
                'No applied steps to revert in this ordered workflow.'
            }
            Write-LogLine (Get-UiText $msgKey $msgFallback) 'info'
            Update-SelectionDisplay
            Update-FooterModeDisplay
            return
        }
    } elseif ($script:SelectedTweakIds.Count -gt 0) {
        $selectedIds = @($script:SelectedTweakIds)
        $tweaks = @($tweaks | Where-Object { $selectedIds -contains $_['Id'] })
    }

    $logTitle = if ($isOrdered -and $tweaks.Count -eq 1) { Get-L10n $tweaks[0] 'Title' } else { Get-L10n $Sub 'Title' }
    Start-AsyncTweakRun $tweaks $OpMode $Sub $logTitle
}

# Cancel the in-flight Apply/Revert. Stops the background pipeline; the completion
# tick then runs as usual (EndInvoke throws PipelineStopped, which is already swallowed) and
# resets the footer. Tweaks already finished stay applied — only pending ones are skipped.
function Clear-CurrentOpCancelSource {
    $src = $script:CurrentOpCancelSource
    $script:CurrentOpCancelSource = $null
    if ($src) { try { $src.Dispose() } catch {} }
}

function Stop-CurrentOp {
    $ps = $script:CurrentOpPowerShell
    if (-not $ps) { return }
    $script:OpCancelled = $true
    # Signal first: the token is the only thing that can break a native installer out of its wait.
    # ps.Stop() alone would block on the child process and leave the footer stuck on "Applying…".
    if ($script:CurrentOpCancelSource) { try { $script:CurrentOpCancelSource.Cancel() } catch {} }
    try { $ps.Stop() } catch {}
    Write-LogLine (Get-UiText 'OpCancelling' 'Cancelling — finishing the current step…') 'warn'
}

#endregion

#region ════════════════ LOG / TERMINAL PANELS ════════════════

# ── Log helpers ────────────────────────────────────────────────────────────────

function Get-WindowActualWidth {
    if ($script:Win -and $script:Win.ActualWidth -gt 0) { return [double]$script:Win.ActualWidth }
    if ($script:Win -and $script:Win.Width -gt 0) { return [double]$script:Win.Width }
    1600.0
}

function Get-WindowActualHeight {
    if ($script:Win -and $script:Win.ActualHeight -gt 0) { return [double]$script:Win.ActualHeight }
    if ($script:Win -and $script:Win.Height -gt 0) { return [double]$script:Win.Height }
    900.0
}

function Get-DefaultLogWidth {
    [math]::Round([math]::Max(180.0, (Get-WindowActualWidth) * 0.15))
}

function Get-DefaultTerminalHeight {
    [math]::Round([math]::Max(100.0, (Get-WindowActualHeight) * 0.15))
}

function Get-MaxTerminalHeight {
    [math]::Round([math]::Max(260.0, (Get-WindowActualHeight) * 0.78))
}

function Get-PreferredLogWidth {
    $layout = Read-PanelLayout
    if ($layout -and $layout.LogWidth -and [double]$layout.LogWidth -gt 0) { return [double]$layout.LogWidth }
    Get-DefaultLogWidth
}

function Get-PreferredTerminalHeight {
    $layout = Read-PanelLayout
    if ($layout -and $layout.TerminalHeight -and [double]$layout.TerminalHeight -gt 0) { return [double]$layout.TerminalHeight }
    Get-DefaultTerminalHeight
}

function Test-OperationNeedsTerminal {
    param([object[]]$Tweaks)

    foreach ($tweak in $Tweaks) {
        if ($tweak -isnot [hashtable]) { continue }
        $kind = [string]$tweak['Kind']
        if ($kind -in @('script', 'feature')) { return $true }
    }
    $false
}

function Show-LogPanelForOperation {
    if (-not $script:LogPanel -or -not $script:LogCol) { return }
    if ($script:LogPanel.Visibility -eq [System.Windows.Visibility]::Visible) { return }
    Open-LogPanel -Width (Get-DefaultLogWidth) -NoSave
    $script:LogPanelAutoOpened = $true
}

function Show-TerminalPanelForOperation {
    if (-not $script:TerminalPanel -or -not $script:TerminalRow) { return }
    if ($script:TerminalPanel.Visibility -eq [System.Windows.Visibility]::Visible) { return }
    Open-TerminalPanel -Height (Get-DefaultTerminalHeight) -NoSave -NoFocus
    $script:TerminalPanelAutoOpened = $true
}

function Save-PanelLayout {
    if (-not $script:LogCol -or -not $script:TerminalRow) { return }

    $existing = Read-PanelLayout
    $currentLogVisible = ($script:LogPanel -and $script:LogPanel.Visibility -eq [System.Windows.Visibility]::Visible)
    $currentTermVisible = ($script:TerminalPanel -and $script:TerminalPanel.Visibility -eq [System.Windows.Visibility]::Visible)
    $logVisible = if ($script:LogPanelAutoOpened -and $existing -and $null -ne $existing.LogVisible) {
        [bool]$existing.LogVisible
    } else {
        $currentLogVisible
    }
    $termVisible = if ($script:TerminalPanelAutoOpened -and $existing -and $null -ne $existing.TerminalVisible) {
        [bool]$existing.TerminalVisible
    } else {
        $currentTermVisible
    }

    $logWidth = if ($currentLogVisible -and -not $script:LogPanelAutoOpened -and $script:LogCol.Width.Value -gt 0) {
        [double]$script:LogCol.Width.Value
    } elseif ($existing -and $existing.LogWidth -and [double]$existing.LogWidth -gt 0) {
        [double]$existing.LogWidth
    } else {
        Get-DefaultLogWidth
    }

    $termHeight = if ($currentTermVisible -and -not $script:TerminalPanelAutoOpened -and $script:TerminalRow.Height.Value -gt 0) {
        [double]$script:TerminalRow.Height.Value
    } elseif ($existing -and $existing.TerminalHeight -and [double]$existing.TerminalHeight -gt 0) {
        [double]$existing.TerminalHeight
    } else {
        Get-DefaultTerminalHeight
    }

    $restoreHeight = if ($script:TerminalRestoreHeight -and [double]$script:TerminalRestoreHeight -gt 0) {
        [double]$script:TerminalRestoreHeight
    } else {
        Get-DefaultTerminalHeight
    }

    Write-PanelLayout @{
        LogVisible     = $logVisible
        LogWidth       = [math]::Round($logWidth, 0)
        TerminalVisible = $termVisible
        TerminalHeight = [math]::Round($termHeight, 0)
        TerminalMaximized = [bool]$script:TerminalMaximized
        TerminalRestoreHeight = [math]::Round($restoreHeight, 0)
    }
}

function Apply-PanelLayout {
    if (-not $script:LogCol -or -not $script:TerminalRow) { return }

    $script:LogPanelAutoOpened = $false
    $script:TerminalPanelAutoOpened = $false

    $layout = Read-PanelLayout
    $logVisible = if ($layout -and $null -ne $layout.LogVisible) { [bool]$layout.LogVisible } else { $true }
    $termVisible = if ($layout -and $null -ne $layout.TerminalVisible) { [bool]$layout.TerminalVisible } else { $true }

    $logWidth = if ($layout -and $layout.LogWidth -and [double]$layout.LogWidth -gt 0) { [double]$layout.LogWidth } else { Get-DefaultLogWidth }
    $termHeight = if ($layout -and $layout.TerminalHeight -and [double]$layout.TerminalHeight -gt 0) { [double]$layout.TerminalHeight } else { Get-DefaultTerminalHeight }
    $script:TerminalMaximized = if ($layout -and $null -ne $layout.TerminalMaximized) { [bool]$layout.TerminalMaximized } else { $false }
    $script:TerminalRestoreHeight = if ($layout -and $layout.TerminalRestoreHeight -and [double]$layout.TerminalRestoreHeight -gt 0) {
        [double]$layout.TerminalRestoreHeight
    } else {
        Get-DefaultTerminalHeight
    }

    if ($logVisible) { Open-LogPanel -Width $logWidth -NoSave } else { Close-LogPanel -NoSave }
    if ($termVisible) { Open-TerminalPanel -Height $termHeight -NoSave -NoFocus } else { Close-TerminalPanel -NoSave }
    Update-TerminalMaximizeButton
}

function Reset-PanelLayout {
    $path = Get-PanelLayoutPath
    if (Test-Path $path) { try { Remove-Item $path -Force } catch {} }
    $script:LogPanelAutoOpened = $false
    $script:TerminalPanelAutoOpened = $false
    Open-LogPanel -Width (Get-DefaultLogWidth) -NoSave
    $script:TerminalMaximized = $false
    $script:TerminalRestoreHeight = Get-DefaultTerminalHeight
    Open-TerminalPanel -Height (Get-DefaultTerminalHeight) -NoSave -NoFocus
    Update-TerminalMaximizeButton
    Save-PanelLayout
}

function Update-TerminalMaximizeButton {
    if (-not $script:BtnMaximizeTerminalLabel) { return }
    $script:BtnMaximizeTerminalLabel.Text = if ($script:TerminalMaximized) { '↧' } else { '↕' }
}

function Toggle-TerminalMaximized {
    if (-not $script:TerminalRow) { return }
    $script:TerminalPanelAutoOpened = $false
    if ($script:TerminalPanel -and $script:TerminalPanel.Visibility -ne [System.Windows.Visibility]::Visible) {
        Open-TerminalPanel
    }

    if ($script:TerminalMaximized) {
        $height = if ($script:TerminalRestoreHeight -and [double]$script:TerminalRestoreHeight -gt 0) {
            [double]$script:TerminalRestoreHeight
        } else {
            Get-DefaultTerminalHeight
        }
        $script:TerminalMaximized = $false
        Open-TerminalPanel -Height $height -NoFocus -NoSave
    } else {
        $current = if ($script:TerminalRow.Height.Value -gt 0) { [double]$script:TerminalRow.Height.Value } else { Get-DefaultTerminalHeight }
        $script:TerminalRestoreHeight = $current
        $script:TerminalMaximized = $true
        Open-TerminalPanel -Height (Get-MaxTerminalHeight) -NoFocus -NoSave
    }

    Update-TerminalMaximizeButton
    Save-PanelLayout
}

function Open-LogPanel {
    param([double]$Width = 0, [switch]$NoSave)
    if (-not $script:LogCol) { return }
    if (-not $NoSave) { $script:LogPanelAutoOpened = $false }
    if ($Width -le 0) { $Width = Get-PreferredLogWidth }
    $script:LogCol.Width         = [System.Windows.GridLength]::new($Width, [System.Windows.GridUnitType]::Pixel)
    $script:LogSplitterCol.Width = [System.Windows.GridLength]::new(5,   [System.Windows.GridUnitType]::Pixel)
    $script:LogPanel.Visibility  = [System.Windows.Visibility]::Visible
    $script:LogSplitter.Visibility = [System.Windows.Visibility]::Visible
    if ($script:BtnToggleLogLabel) { $script:BtnToggleLogLabel.Text = 'Log ◀' }
    if ($script:LogBox -and $script:LogBox.Document.Blocks.Count -le 1) {
        Write-LogLine 'Audion Windows Tools by Max.mov — log ready' 'info'
    }
    if (-not $NoSave) { Save-PanelLayout }
}

function Close-LogPanel {
    param([switch]$NoSave)
    if (-not $script:LogCol) { return }
    if (-not $NoSave) { $script:LogPanelAutoOpened = $false }
    $script:LogCol.Width           = [System.Windows.GridLength]::new(0, [System.Windows.GridUnitType]::Pixel)
    $script:LogSplitterCol.Width   = [System.Windows.GridLength]::new(0, [System.Windows.GridUnitType]::Pixel)
    $script:LogPanel.Visibility    = [System.Windows.Visibility]::Collapsed
    $script:LogSplitter.Visibility = [System.Windows.Visibility]::Collapsed
    if ($script:BtnToggleLogLabel) { $script:BtnToggleLogLabel.Text = 'Log ▶' }
    if (-not $NoSave) { Save-PanelLayout }
}

function Toggle-LogPanel {
    if ($script:LogPanel -and $script:LogPanel.Visibility -eq [System.Windows.Visibility]::Visible) {
        Close-LogPanel
    } else {
        Open-LogPanel
    }
}

function Get-ThemeBrush([string]$Key, [string]$Fallback) {
    if ($script:Win -and $script:Win.Resources[$Key] -is [System.Windows.Media.SolidColorBrush]) {
        return $script:Win.Resources[$Key]
    }
    try {
        return [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString($Fallback))
    } catch {
        return [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Colors]::White)
    }
}

function Write-LogLine([string]$Text, [string]$Color = 'info') {
    if (-not $script:LogBox) { return }
    $brush = switch ($Color) {
        'ok'    { Get-ThemeBrush 'TerminalOkText' '#46c084' }
        'warn'  { Get-ThemeBrush 'TerminalWarnText' '#d49a30' }
        'error' { Get-ThemeBrush 'TerminalErrorText' '#cc5656' }
        default { Get-ThemeBrush 'LogText' '#6868a0' }
    }
    $ts = [datetime]::Now.ToString('HH:mm:ss')
    $para = [System.Windows.Documents.Paragraph]::new()
    $para.Margin = [System.Windows.Thickness]::new(0, 0, 0, 1)

    $tsRun = [System.Windows.Documents.Run]::new("[$ts] ")
    $tsRun.Foreground = Get-ThemeBrush 'LogTimestampText' '#383852'
    $para.Inlines.Add($tsRun)

    $msgRun = [System.Windows.Documents.Run]::new($Text)
    $msgRun.Foreground = $brush
    $para.Inlines.Add($msgRun)

    $script:LogBox.Document.Blocks.Add($para)
    $script:LogBox.ScrollToEnd()
}

# ── Terminal helpers ────────────────────────────────────────────────────────────

function Open-TerminalPanel {
    param([double]$Height = 0, [switch]$NoSave, [switch]$NoFocus)
    if (-not $script:TerminalRow) { return }
    if (-not $NoSave) { $script:TerminalPanelAutoOpened = $false }
    if ($Height -le 0) { $Height = Get-PreferredTerminalHeight }
    $script:TerminalRow.Height         = [System.Windows.GridLength]::new($Height, [System.Windows.GridUnitType]::Pixel)
    $script:TerminalRow.MinHeight      = 80
    $script:TerminalSplitterRow.Height = [System.Windows.GridLength]::new(5, [System.Windows.GridUnitType]::Pixel)
    $script:TerminalPanel.Visibility   = [System.Windows.Visibility]::Visible
    $script:TerminalSplitter.Visibility = [System.Windows.Visibility]::Visible
    if ($script:BtnToggleTerminalLabel) { $script:BtnToggleTerminalLabel.Text = 'Terminal ▲' }
    Update-TerminalMaximizeButton
    if (-not $NoFocus) { $script:TerminalInput.Focus() | Out-Null }
    if (-not $NoSave) { Save-PanelLayout }
}

function Close-TerminalPanel {
    param([switch]$NoSave)
    if (-not $script:TerminalRow) { return }
    if (-not $NoSave) { $script:TerminalPanelAutoOpened = $false }
    $script:TerminalRow.Height          = [System.Windows.GridLength]::new(0, [System.Windows.GridUnitType]::Pixel)
    $script:TerminalRow.MinHeight       = 0
    $script:TerminalSplitterRow.Height  = [System.Windows.GridLength]::new(0, [System.Windows.GridUnitType]::Pixel)
    $script:TerminalPanel.Visibility    = [System.Windows.Visibility]::Collapsed
    $script:TerminalSplitter.Visibility = [System.Windows.Visibility]::Collapsed
    if ($script:BtnToggleTerminalLabel) { $script:BtnToggleTerminalLabel.Text = 'Terminal ▼' }
    Update-TerminalMaximizeButton
    if (-not $NoSave) { Save-PanelLayout }
}

function Toggle-TerminalPanel {
    if ($script:TerminalPanel -and $script:TerminalPanel.Visibility -eq [System.Windows.Visibility]::Visible) {
        Close-TerminalPanel
    } else {
        Open-TerminalPanel
    }
}

function Write-TerminalLines([string[]]$Lines, [string]$Color = 'output') {
    if (-not $script:TerminalBox) { return }

    $brush = switch ($Color) {
        'cmd'   { Get-ThemeBrush 'TerminalCommandText' '#5ab0d0' }
        'ok'    { Get-ThemeBrush 'TerminalOkText' '#46c084' }
        'warn'  { Get-ThemeBrush 'TerminalWarnText' '#d49a30' }
        'error' { Get-ThemeBrush 'TerminalErrorText' '#cc5656' }
        default { Get-ThemeBrush 'TerminalText' '#c0c0d4' }
    }
    foreach ($text in @($Lines)) {
        if ($Color -eq 'output' -and [string]::IsNullOrWhiteSpace($text)) { continue }
        if ($Color -eq 'output' -and $text -match '^\s*[-\\|/]\s*$') { continue }

        $para = [System.Windows.Documents.Paragraph]::new()
        $para.Margin = [System.Windows.Thickness]::new(0)
        $run = [System.Windows.Documents.Run]::new($text)
        $run.Foreground = $brush
        $para.Inlines.Add($run)
        $script:TerminalBox.Document.Blocks.Add($para)
    }
    while ($script:TerminalBox.Document.Blocks.Count -gt $script:TerminalMaxBlocks) {
        $script:TerminalBox.Document.Blocks.Remove($script:TerminalBox.Document.Blocks.FirstBlock)
    }
    $script:TerminalBox.ScrollToEnd()
}

function Write-TerminalLine([string]$Text, [string]$Color = 'output') {
    Write-TerminalLines @($Text) $Color
}

function Invoke-TerminalCommand([string]$Command) {
    Write-TerminalLine "PS ❯ $Command" 'cmd'
    $modRef = $MyInvocation.MyCommand.Module
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.AddScript({
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        try {
            [Console]::InputEncoding  = $utf8
            [Console]::OutputEncoding = $utf8
            Set-Variable -Name OutputEncoding -Scope Global -Value $utf8
        } catch {}
    }) | Out-Null
    $ps.AddScript($Command) | Out-Null
    $asyncResult = $ps.BeginInvoke()
    $done = $false
    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(150)
    $timer.Add_Tick({
        if ($done -or -not $asyncResult.IsCompleted) { return }
        $done = $true
        $timer.Stop()
        try {
            $results = $ps.EndInvoke($asyncResult)
            foreach ($r in $results) {
                if ($null -ne $r) {
                    & $modRef { param($t) Write-TerminalLine $t 'output' } $r.ToString()
                }
            }
            foreach ($e in $ps.Streams.Error) {
                & $modRef { param($t) Write-TerminalLine $t 'error' } $e.ToString()
            }
        } catch {
            & $modRef { param($t) Write-TerminalLine $t 'error' } $_.Exception.Message
        } finally {
            $ps.Dispose()
        }
    }.GetNewClosure())
    $timer.Start()
}

#endregion

#region ════════════════ CARD BUILDER ════════════════

$script:GuidToTweakMap = @{}   # tweakId → tweak hashtable, for event closures

function Test-TweakHasHelp([hashtable]$Tweak) {
    if (-not $Tweak) { return $false }
    [bool](Get-L10n $Tweak 'Instruction') -or
    [bool](Get-L10n $Tweak 'ActionNote') -or
    ([string]$Tweak['Kind'] -eq 'manual')
}

function Add-TooltipTextBlock {
    param(
        [System.Windows.Controls.Panel]$Panel,
        [string]$Text,
        [System.Windows.Media.Brush]$Brush,
        [double]$FontSize = 12,
        [bool]$Bold = $false,
        [bool]$Italic = $false,
        [System.Windows.Thickness]$Margin = ([System.Windows.Thickness]::new(0))
    )
    if (-not $Text) { return }

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text         = $Text
    $tb.Foreground   = $Brush
    $tb.FontSize     = $FontSize
    $tb.Margin       = $Margin
    $tb.MaxWidth     = 520
    $tb.TextWrapping = [System.Windows.TextWrapping]::Wrap
    if ($Bold)   { $tb.FontWeight = [System.Windows.FontWeights]::SemiBold }
    if ($Italic) { $tb.FontStyle  = [System.Windows.FontStyles]::Italic }
    $Panel.Children.Add($tb) | Out-Null
}

function New-TweakToolTip([hashtable]$Tweak) {
    if (-not (Test-TweakHasHelp $Tweak)) { return $null }

    $res         = $script:Win.Resources
    $kind        = [string]$Tweak['Kind']
    $isAmber     = $Tweak['Source'] -eq 'unofficial'
    $isSand      = $Tweak['Tone'] -eq 'sand'
    $accentBrush = if ($isSand) { $res['SandAccent'] } elseif ($isAmber) { $res['AmberAccent'] } else { $res['GreenAccent'] }

    $title       = Get-L10n $Tweak 'Title'
    $desc        = Get-L10n $Tweak 'Desc'
    $instruction = Get-L10n $Tweak 'Instruction'
    $actionNote  = Get-L10n $Tweak 'ActionNote'
    if (-not $instruction -and $kind -eq 'manual') {
        $instruction = Get-UiText 'TooltipManualFallback' 'Complete this step manually, then mark the card as done.'
    }

    $tip = New-Object System.Windows.Controls.ToolTip
    $tip.Placement      = [System.Windows.Controls.Primitives.PlacementMode]::Mouse
    $tip.HasDropShadow  = $true
    $tip.Background     = [System.Windows.Media.Brushes]::Transparent
    $tip.BorderThickness = [System.Windows.Thickness]::new(0)
    $tip.Padding        = [System.Windows.Thickness]::new(0)

    $border = New-Object System.Windows.Controls.Border
    $border.Background      = $res['TitlebarBg']
    $border.BorderBrush     = $accentBrush
    $border.BorderThickness = [System.Windows.Thickness]::new(1)
    $border.CornerRadius    = [System.Windows.CornerRadius]::new(8)
    $border.Padding         = [System.Windows.Thickness]::new(14)
    $border.MaxWidth        = 560

    $stack = New-Object System.Windows.Controls.StackPanel
    $border.Child = $stack

    Add-TooltipTextBlock $stack $title $res['TitleText'] 14 $true $false
    if ($desc) {
        Add-TooltipTextBlock $stack (Get-UiText 'TooltipWhat' 'What it does') $accentBrush 11 $true $false ([System.Windows.Thickness]::new(0,10,0,0))
        Add-TooltipTextBlock $stack $desc $res['DescText'] 12 $false $false ([System.Windows.Thickness]::new(0,3,0,0))
    }
    if ($instruction) {
        Add-TooltipTextBlock $stack (Get-UiText 'TooltipHow' 'How to do it') $accentBrush 11 $true $false ([System.Windows.Thickness]::new(0,12,0,0))
        Add-TooltipTextBlock $stack $instruction $res['TitleText'] 12 $false $false ([System.Windows.Thickness]::new(0,3,0,0))
    }
    if ($actionNote) {
        Add-TooltipTextBlock $stack (Get-UiText 'TooltipNote' 'Note') $accentBrush 11 $true $false ([System.Windows.Thickness]::new(0,12,0,0))
        Add-TooltipTextBlock $stack $actionNote $res['DescText'] 12 $false $true ([System.Windows.Thickness]::new(0,3,0,0))
    }

    $tip.Content = $border
    $tip
}

function Set-TweakToolTip($Element, [hashtable]$Tweak) {
    if (-not $Element -or -not (Test-TweakHasHelp $Tweak)) { return }
    $Element.ToolTip = New-TweakToolTip $Tweak
    # BetweenShowDelay matches the initial delay on purpose: at 0 the first tooltip "unlocks" the
    # rest, and sweeping the mouse across a column of cards would pop help instantly on every one,
    # which is exactly what the delay is meant to prevent.
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($Element, $script:TooltipInitialShowDelayMs)
    [System.Windows.Controls.ToolTipService]::SetBetweenShowDelay($Element, $script:TooltipInitialShowDelayMs)
    [System.Windows.Controls.ToolTipService]::SetShowDuration($Element, 60000)
    [System.Windows.Controls.ToolTipService]::SetShowOnDisabled($Element, $true)
}

function New-TweakCard([hashtable]$Tweak, [string]$State) {
    $kind    = $Tweak['Kind']
    $source  = $Tweak['Source']
    $control = $Tweak['Control']
    $isAmber = $source -eq 'unofficial'
    $tone    = $Tweak['Tone']
    $isSand  = $tone -eq 'sand'
    $isNA    = $State -eq 'NotApplicable'

    $script:GuidToTweakMap[$Tweak['Id']] = $Tweak

    $res = $script:Win.Resources
    $riskColor = $res['AmberAccent'].Color

    # Card border
    $card = New-Object System.Windows.Controls.Border
    $card.CornerRadius   = [System.Windows.CornerRadius]::new(8)
    $card.BorderThickness = [System.Windows.Thickness]::new(0.5)
    $card.Padding        = [System.Windows.Thickness]::new(10,8,10,8)
    $card.Margin         = [System.Windows.Thickness]::new(0,0,0,5)

    if ($isNA) {
        $card.Opacity = 0.45
        $card.Background  = $res['CardNeutral']
        $card.BorderBrush = [System.Windows.Media.Brushes]::Transparent
    } elseif ($State -eq 'Applied' -and -not $isAmber -and -not $isSand) {
        $card.Background  = $res['CyanFill']
        $card.BorderBrush = $res['CyanBorder']
    } elseif ($isSand) {
        $card.Background  = $res['SandCardBg']
        $card.BorderBrush = $res['SandBorder']
    } elseif ($isAmber) {
        $card.Background  = $res['AmberCardBg']
        $card.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromArgb(0x70, $riskColor.R, $riskColor.G, $riskColor.B))
    } else {
        $card.Background  = $res['CardNeutral']
        $card.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromArgb(0x14, 0xFF, 0xFF, 0xFF))
    }

    # Root grid (accent bar | content)
    $grid = New-Object System.Windows.Controls.Grid
    $card.Child = $grid

    # Accent bar (3px left strip)
    $accentBar = New-Object System.Windows.Controls.Border
    $accentBar.Width               = 4
    $accentBar.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $accentBar.Margin              = [System.Windows.Thickness]::new(-10,-8,0,-8)
    $accentBar.Background          = if ($isSand) { $res['SandDeep'] } elseif ($isAmber) { $res['AmberDeep'] } else { $res['GreenDeep'] }
    $grid.Children.Add($accentBar) | Out-Null

    # Content panel (offset from bar)
    $content = New-Object System.Windows.Controls.StackPanel
    $content.Margin = [System.Windows.Thickness]::new(8,0,0,0)
    $grid.Children.Add($content) | Out-Null

    # ── Row 1: status icon + title + badge + control ──────────────────────
    $topGrid = New-Object System.Windows.Controls.Grid
    $topGrid.Margin = [System.Windows.Thickness]::new(0)
    $content.Children.Add($topGrid) | Out-Null

    # Left info panel
    $leftPanel = New-Object System.Windows.Controls.StackPanel
    $leftPanel.Orientation        = [System.Windows.Controls.Orientation]::Horizontal
    $leftPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $leftPanel.VerticalAlignment   = [System.Windows.VerticalAlignment]::Center
    $topGrid.Children.Add($leftPanel) | Out-Null

    # Status icon
    $statusIcon = New-Object System.Windows.Controls.TextBlock
    $statusIcon.Margin = [System.Windows.Thickness]::new(0,0,6,0)
    $statusIcon.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $statusIcon.FontSize = 13
    switch ($State) {
        'Applied'       { $statusIcon.Text = [char]0x2713; $statusIcon.Foreground = if ($isSand) { $res['SandAccent'] } elseif ($isAmber) { $res['AmberAccent'] } else { $res['GreenAccent'] } }
        'NotApplicable' { $statusIcon.Text = '—';         $statusIcon.Foreground = $res['DescMuted'] }
        'Unknown'       { $statusIcon.Text = '?';          $statusIcon.Foreground = $res['DescMuted'] }
        default         { $statusIcon.Text = [char]0x25CB; $statusIcon.Foreground = $res['HeaderHint'] }
    }
    $leftPanel.Children.Add($statusIcon) | Out-Null

    # Title
    $titleTb = New-Object System.Windows.Controls.TextBlock
    $titleTb.Text             = Get-L10n $Tweak 'Title'
    $titleTb.Foreground       = if ($isNA) { $res['DescText'] } else { $res['TitleText'] }
    $titleTb.FontSize         = 13
    $titleTb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $leftPanel.Children.Add($titleTb) | Out-Null

    # Source badge
    $badge = New-Object System.Windows.Controls.Border
    $badge.CornerRadius   = [System.Windows.CornerRadius]::new(4)
    $badge.BorderThickness = [System.Windows.Thickness]::new(0.5)
    $badge.Padding        = [System.Windows.Thickness]::new(6,1,6,1)
    $badge.Margin         = [System.Windows.Thickness]::new(6,0,0,0)
    $badge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $badge.Background     = $res['BadgeBg']
    $badge.BorderBrush    = $res['BadgeBorder']
    $badgeTb = New-Object System.Windows.Controls.TextBlock
    $badgeTb.Text       = $source
    $badgeTb.FontSize   = 10
    $badgeTb.Foreground = $res['BadgeText']
    $badge.Child = $badgeTb
    $leftPanel.Children.Add($badge) | Out-Null

    # Editorial relation to Max.mov materials is independent from the technical
    # source label. Both fields affect presentation only; execution, detection,
    # and rollback are untouched. A card-level value overrides subsection-level
    # inheritance, including an explicit $false exception.
    $editorialBadges = @()
    $maxGuide = if ($Tweak.ContainsKey('MaxMovGuide')) {
        [bool]$Tweak['MaxMovGuide']
    } elseif ($script:CurrentSubsection -and $script:CurrentSubsection.ContainsKey('MaxMovGuide')) {
        [bool]$script:CurrentSubsection['MaxMovGuide']
    } else {
        $false
    }
    $maxApproved = if ($Tweak.ContainsKey('MaxMovApproved')) {
        [bool]$Tweak['MaxMovApproved']
    } elseif ($script:CurrentSubsection -and $script:CurrentSubsection.ContainsKey('MaxMovApproved')) {
        [bool]$script:CurrentSubsection['MaxMovApproved']
    } else {
        $false
    }

    if ($maxGuide) {
        $editorialBadges += @{
            Text       = 'Max.mov guide'
            Border     = [System.Windows.Media.Color]::FromRgb(0xb5,0x7e,0xdc)
            Background = [System.Windows.Media.Color]::FromArgb(0x24,0xb5,0x7e,0xdc)
            Foreground = [System.Windows.Media.Color]::FromRgb(0xe6,0xc8,0xf5)
            ToolTipRu  = 'Шаг или рекомендация точно присутствует в гайде Max.mov. Это не означает отдельного одобрения реализации этой карточки.'
            ToolTipEn  = 'The step or recommendation is present in the Max.mov guide. This does not mean that this card implementation was separately approved.'
        }
    }
    if ($maxApproved) {
        $editorialBadges += @{
            Text       = 'Max.mov approved'
            Border     = [System.Windows.Media.Color]::FromRgb(0xb5,0x7e,0xdc)
            Background = [System.Windows.Media.Color]::FromArgb(0x3c,0xb5,0x7e,0xdc)
            Foreground = [System.Windows.Media.Color]::FromRgb(0xf0,0xd8,0xff)
            ToolTipRu  = 'Конкретная рекомендация или реализация отдельно одобрена Max.mov.'
            ToolTipEn  = 'The specific recommendation or implementation was separately approved by Max.mov.'
        }
    }

    foreach ($editorial in $editorialBadges) {
        $maxBadge = New-Object System.Windows.Controls.Border
        $maxBadge.CornerRadius      = [System.Windows.CornerRadius]::new(4)
        $maxBadge.BorderThickness   = [System.Windows.Thickness]::new(0.5)
        $maxBadge.Padding           = [System.Windows.Thickness]::new(5,1,5,1)
        $maxBadge.Margin            = [System.Windows.Thickness]::new(5,0,0,0)
        $maxBadge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $maxBadge.BorderBrush       = [System.Windows.Media.SolidColorBrush]::new($editorial.Border)
        $maxBadge.Background        = [System.Windows.Media.SolidColorBrush]::new($editorial.Background)
        $maxBadge.ToolTip           = if ($script:Lang -eq 'ru') { $editorial.ToolTipRu } else { $editorial.ToolTipEn }
        $maxBadgeTb = New-Object System.Windows.Controls.TextBlock
        $maxBadgeTb.Text       = $editorial.Text
        $maxBadgeTb.FontSize   = 9
        $maxBadgeTb.Foreground = [System.Windows.Media.SolidColorBrush]::new($editorial.Foreground)
        $maxBadge.Child = $maxBadgeTb
        $leftPanel.Children.Add($maxBadge) | Out-Null
    }

    if ($isSand) {
        $toneBadge = New-Object System.Windows.Controls.Border
        $toneBadge.CornerRadius   = [System.Windows.CornerRadius]::new(4)
        $toneBadge.BorderThickness = [System.Windows.Thickness]::new(0.5)
        $toneBadge.Padding        = [System.Windows.Thickness]::new(6,1,6,1)
        $toneBadge.Margin         = [System.Windows.Thickness]::new(6,0,0,0)
        $toneBadge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $toneBadge.Background     = $res['BadgeBg']
        $toneBadge.BorderBrush    = $res['BadgeBorder']
        $toneBadgeTb = New-Object System.Windows.Controls.TextBlock
        $toneBadgeTb.Text       = if ($script:Lang -eq 'ru') { 'действие' } else { 'action' }
        $toneBadgeTb.FontSize   = 10
        $toneBadgeTb.Foreground = $res['BadgeText']
        $toneBadge.Child = $toneBadgeTb
        $leftPanel.Children.Add($toneBadge) | Out-Null
    }

    if (Test-TweakHasHelp $Tweak) {
        $helpBadge = New-Object System.Windows.Controls.Border
        $helpBadge.Width           = 18
        $helpBadge.Height          = 18
        $helpBadge.CornerRadius    = [System.Windows.CornerRadius]::new(9)
        $helpBadge.BorderThickness = [System.Windows.Thickness]::new(0.75)
        $helpBadge.BorderBrush     = $res['DescMuted']
        $helpBadge.Margin          = [System.Windows.Thickness]::new(6,0,0,0)
        $helpBadge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $helpBadge.Cursor          = [System.Windows.Input.Cursors]::Help
        $helpTb = New-Object System.Windows.Controls.TextBlock
        $helpTb.Text                = '?'
        $helpTb.FontSize            = 11
        $helpTb.FontWeight          = [System.Windows.FontWeights]::SemiBold
        $helpTb.Foreground          = $res['DescMuted']
        $helpTb.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        $helpTb.VerticalAlignment   = [System.Windows.VerticalAlignment]::Center
        $helpBadge.Child = $helpTb
        Set-TweakToolTip $helpBadge $Tweak
        $leftPanel.Children.Add($helpBadge) | Out-Null
    }

    # ── Right control (wrapped with selection checkbox) ───────────────────────
    $rightCtrl = New-CardControl $Tweak $State $statusIcon $card

    $rightWrap = New-Object System.Windows.Controls.StackPanel
    $rightWrap.Orientation         = [System.Windows.Controls.Orientation]::Horizontal
    $rightWrap.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $rightWrap.VerticalAlignment   = [System.Windows.VerticalAlignment]::Center

    $isOrderedSubsection = Test-OrderedSubsection $script:CurrentSubsection
    $isCardsOnlySubsection = Test-CardsOnlySubsection $script:CurrentSubsection
    if (-not $isOrderedSubsection -and -not $isCardsOnlySubsection -and $kind -notin @('link','deeplink')) {
        $selCb = New-Object System.Windows.Controls.CheckBox
        $selCb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $selCb.Margin    = [System.Windows.Thickness]::new(0,0,6,0)
        $selCb.IsChecked = [bool]($script:SelectedTweakIds -contains $Tweak['Id'])
        $selCb.Tag       = $Tweak['Id']
        $selCb.Add_Checked({
            param($s,$e)
            $id = $s.Tag
            if (-not ($script:SelectedTweakIds -contains $id)) { $script:SelectedTweakIds.Add($id) }
            Update-SelectionDisplay
        })
        $selCb.Add_Unchecked({
            param($s,$e)
            $script:SelectedTweakIds.Remove($s.Tag) | Out-Null
            Update-SelectionDisplay
        })
        $rightWrap.Children.Add($selCb) | Out-Null
    }

    if ($rightCtrl) { $rightWrap.Children.Add($rightCtrl) | Out-Null }
    $topGrid.Children.Add($rightWrap) | Out-Null

    # ── Row 2: description ────────────────────────────────────────────────
    $desc = Get-L10n $Tweak 'Desc'
    if ($desc) {
        $descTb = New-Object System.Windows.Controls.TextBlock
        $descTb.Text        = $desc
        $descTb.Foreground  = $res['DescText']
        $descTb.FontSize    = 11
        $descTb.Margin      = [System.Windows.Thickness]::new(0,3,0,0)
        $descTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $content.Children.Add($descTb) | Out-Null
    }

    $actionNote = Get-L10n $Tweak 'ActionNote'
    if ($actionNote) {
        $actionTb = New-Object System.Windows.Controls.TextBlock
        $actionTb.Text         = $actionNote
        $actionTb.Foreground   = if ($isSand) { $res['SandBright'] } else { $res['DescMuted'] }
        $actionTb.FontSize     = 10
        $actionTb.Margin       = [System.Windows.Thickness]::new(0,2,0,0)
        $actionTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $content.Children.Add($actionTb) | Out-Null
    }

    # ── Row 3: instruction (for deeplink/manual) ──────────────────────────
    $instruction = Get-L10n $Tweak 'Instruction'
    if ($instruction -and ($kind -eq 'deeplink' -or $kind -eq 'manual')) {
        $instrTb = New-Object System.Windows.Controls.TextBlock
        $instrTb.Text         = $instruction
        $instrTb.Foreground   = $res['DescMuted']
        $instrTb.FontSize     = 10
        $instrTb.Margin       = [System.Windows.Thickness]::new(0,2,0,0)
        $instrTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $instrTb.FontStyle    = [System.Windows.FontStyles]::Italic
        $content.Children.Add($instrTb) | Out-Null
    }

    Set-TweakToolTip $card $Tweak

    # Disable interaction if not applicable
    if ($isNA) { $card.IsEnabled = $false }

    $card
}

function New-CardControl([hashtable]$Tweak, [string]$State, $StatusIcon, $Card) {
    $kind    = $Tweak['Kind']
    $control = $Tweak['Control']
    $res     = $script:Win.Resources
    $isAmber = $Tweak['Source'] -eq 'unofficial'
    $isSand  = $Tweak['Tone'] -eq 'sand'
    $tweakId = $Tweak['Id']

    # ── TOGGLE ───────────────────────────────────────────────────────────
    if ($control -eq 'toggle') {
        $btn = New-Object System.Windows.Controls.Primitives.ToggleButton
        $btn.Width  = 38
        $btn.Height = 20
        $btn.IsChecked = ($State -eq 'Applied')
        $btn.IsEnabled = ($State -ne 'NotApplicable')
        $btn.Tag    = $tweakId

        $btn.Add_Checked({
            param($s,$e)
            if ($script:ToggleSuppressed) { $script:ToggleSuppressed = $false; return }
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            if ($script:CurrentOpPowerShell) {
                $script:ToggleSuppressed = $true
                $s.IsChecked = $false
                Start-AsyncTweakRun @($tweak) 'apply' $script:CurrentSubsection (Get-L10n $tweak 'Title')
                return
            }
            $s.IsEnabled = $false
            Start-AsyncTweakRun @($tweak) 'apply' $script:CurrentSubsection (Get-L10n $tweak 'Title')
        })
        $btn.Add_Unchecked({
            param($s,$e)
            if ($script:ToggleSuppressed) { $script:ToggleSuppressed = $false; return }
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            if ($script:CurrentOpPowerShell) {
                $script:ToggleSuppressed = $true
                $s.IsChecked = $true
                Start-AsyncTweakRun @($tweak) 'revert' $script:CurrentSubsection (Get-L10n $tweak 'Title')
                return
            }
            $s.IsEnabled = $false
            Start-AsyncTweakRun @($tweak) 'revert' $script:CurrentSubsection (Get-L10n $tweak 'Title')
        })

        return $btn
    }

    # ── DOCS → complete documentation folder ────────────────────────────
    if ($kind -eq 'docs') {
        $panel = New-Object System.Windows.Controls.StackPanel
        $panel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $docsLabel   = if ($script:S -and $script:S.BtnDocs) { $script:S.BtnDocs } else { 'Documents' }

        $docsBtn   = if ($isSand) { New-SandButton $docsLabel } else { New-SecondaryButton $docsLabel }

        $docsBtn.ToolTip   = Get-UiText 'TooltipDocsButton' 'Open all documentation'

        $docsBtn.Add_Click({ Open-DocsFolder })

        $panel.Children.Add($docsBtn)   | Out-Null
        return $panel
    }

    # ── DEEPLINK / LINK → single button ───────────────────────────────────
    if ($kind -eq 'deeplink' -or $kind -eq 'link') {
        $label = if ($kind -eq 'link') {
            if ($script:S) { $script:S.Open } else { 'Open' }
        } else {
            if ($script:S) { $script:S.OpenSettings } else { 'Open Settings' }
        }
        $btn   = if ($isSand) { New-SandButton $label } else { New-SecondaryButton $label }
        $btn.Tag = $tweakId
        $btn.Add_Click({
            param($s,$e)
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            Show-LogPanelForOperation
            $urlToLog = if ($tweak['Url']) { $tweak['Url'] } elseif ($tweak['Uri']) { $tweak['Uri'] } else { $null }
            if ($urlToLog) { Write-LogLine $urlToLog 'info' }
            try { Invoke-TweakApply $tweak } catch { Write-LogLine $_.Exception.Message 'error' }
        })
        return $btn
    }

    # ── MANUAL → "Mark done" checkbox ─────────────────────────────────────
    if ($kind -eq 'manual') {
        $pill = New-Object System.Windows.Controls.Border
        $pill.CornerRadius   = [System.Windows.CornerRadius]::new(6)
        $pill.Background     = $res['AmberPillBg']
        $pill.Padding        = [System.Windows.Thickness]::new(10,3,10,3)
        $pill.Cursor         = [System.Windows.Input.Cursors]::Hand
        $pillTb = New-Object System.Windows.Controls.TextBlock
        $pillTb.Text     = if ($State -eq 'Applied') {
            if ($script:S) { $script:S.Done } else { 'done ✓' }
        } else {
            if ($script:S) { $script:S.ManualOnly } else { 'manual only' }
        }
        $pillTb.FontSize = 11
        $pillTb.Foreground = $res['AmberBright']
        $pill.Child = $pillTb
        $pill.Tag   = $tweakId

        $pill.Add_MouseLeftButtonUp({
            param($s,$e)
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            Show-LogPanelForOperation
            $title = Get-L10n $tweak 'Title'
            $currentState = Test-TweakState $tweak
            if ($currentState -eq 'Applied') {
                Invoke-TweakRevert $tweak
                Set-CachedTweakState ([string]$tweak['Id']) 'NotApplied'
                ($s.Child).Text = if ($script:S) { $script:S.ManualOnly } else { 'manual only' }
                Write-LogLine "Manual step reset: $title" 'warn'
            } else {
                Invoke-TweakApply $tweak
                Set-CachedTweakState ([string]$tweak['Id']) 'Applied'
                ($s.Child).Text = if ($script:S) { $script:S.Done } else { 'done ✓' }
                Write-LogLine "Manual step marked done: $title" 'ok'
            }
            Update-SelectionDisplay
        })
        return $pill
    }

    # ── POWERSCHEME / SCRIPT → Apply + Revert buttons ─────────────────────
    if ($kind -eq 'powerscheme' -or ($kind -eq 'script' -and $control -eq 'button')) {
        $panel = New-Object System.Windows.Controls.StackPanel
        $panel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $customApplyLabel = Get-L10n $Tweak 'ButtonLabel'
        $applyLabel = if ($customApplyLabel) { $customApplyLabel } elseif ($script:S) { $script:S.Apply } else { 'Apply' }
        $applyBtn  = if ($isSand) { New-SandButton $applyLabel } else { New-ApplyButton $applyLabel }
        $revertBtn = New-SecondaryButton $(if ($script:S) { $script:S.Revert } else { 'Revert' })
        $applyBtn.Tag  = $tweakId
        $revertBtn.Tag = $tweakId

        $applyBtn.Add_Click({
            param($s,$e)
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            Start-AsyncTweakRun @($tweak) 'apply' $script:CurrentSubsection (Get-L10n $tweak 'Title')
        })
        $revertBtn.Add_Click({
            param($s,$e)
            $id    = $s.Tag
            $tweak = $script:GuidToTweakMap[$id]
            if (-not $tweak) { return }
            Start-AsyncTweakRun @($tweak) 'revert' $script:CurrentSubsection (Get-L10n $tweak 'Title')
        })

        $panel.Children.Add($applyBtn)  | Out-Null
        if ($Tweak['CanRevert'] -ne $false) {
            $panel.Children.Add($revertBtn) | Out-Null
        }

        # An install card may also carry the vendor's download page. It matters when winget has no
        # package, when the install fails and the user needs the vendor installer, or when they
        # simply want to see what is being installed before clicking Apply.
        $downloadUrl = [string]$Tweak['Url']
        if (-not [string]::IsNullOrWhiteSpace($downloadUrl)) {
            $dlBtn = New-SecondaryButton (Get-UiText 'BtnDownloadPage' 'Download page')
            $dlBtn.Margin  = [System.Windows.Thickness]::new(4,0,0,0)
            $dlBtn.ToolTip = Get-UiText 'TooltipDownloadPage' 'Open the official download page in your browser'
            $dlBtn.Tag     = $tweakId
            $dlBtn.Add_Click({
                param($s,$e)
                $tweak = $script:GuidToTweakMap[$s.Tag]
                if (-not $tweak) { return }
                $url = [string]$tweak['Url']
                if ([string]::IsNullOrWhiteSpace($url)) { return }
                Show-LogPanelForOperation
                Write-LogLine $url 'info'
                try { Open-ExternalTarget $url } catch { Write-LogLine $_.Exception.Message 'error' }
            })
            $panel.Children.Add($dlBtn) | Out-Null
        }
        return $panel
    }

    $null
}

function Update-StatusIcon($control, [string]$State, [bool]$IsAmber) {
    Update-SelectionDisplay
}

function New-ApplyButton([string]$Label) {
    $res = $script:Win.Resources
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content         = $Label
    $btn.Foreground      = $res['ApplyBtnText']
    $btn.Background      = $res['ApplyBtnBg']
    $btn.BorderBrush     = $res['ApplyBtnBorder']
    $btn.BorderThickness = [System.Windows.Thickness]::new(0.5)
    $btn.Padding         = [System.Windows.Thickness]::new(10,4,10,4)
    $btn.Margin          = [System.Windows.Thickness]::new(0,0,4,0)
    $btn.FontSize        = 12
    $btn.Cursor          = [System.Windows.Input.Cursors]::Hand
    $btn
}

function New-SecondaryButton([string]$Label) {
    $res = $script:Win.Resources
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content         = $Label
    $btn.Foreground      = $res['SecBtnText']
    $btn.Background      = $res['SecBtnBg']
    $btn.BorderBrush     = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromArgb(0x14,0xFF,0xFF,0xFF))
    $btn.BorderThickness = [System.Windows.Thickness]::new(0.5)
    $btn.Padding         = [System.Windows.Thickness]::new(10,4,10,4)
    $btn.Margin          = [System.Windows.Thickness]::new(0,0,0,0)
    $btn.FontSize        = 12
    $btn.Cursor          = [System.Windows.Input.Cursors]::Hand
    $btn
}

function New-SandButton([string]$Label) {
    $res = $script:Win.Resources
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content         = $Label
    $btn.Foreground      = $res['SandBtnText']
    $btn.Background      = $res['SandBtnBg']
    $btn.BorderBrush     = $res['SandBorder']
    $btn.BorderThickness = [System.Windows.Thickness]::new(0.5)
    $btn.Padding         = [System.Windows.Thickness]::new(10,4,10,4)
    $btn.Margin          = [System.Windows.Thickness]::new(0,0,4,0)
    $btn.FontSize        = 12
    $btn.Cursor          = [System.Windows.Input.Cursors]::Hand
    $btn
}

#endregion

Export-ModuleMember -Function @(
    'Initialize-TweakEngine'
    'Get-SystemProfile'
    'Test-TweakState'
    'Invoke-TweakApply'
    'Invoke-TweakRevert'
    'Get-TweakDisplayValue'
    'Set-TweakDisplayValue'
    'Test-SubsectionState'
    'Start-TunerWindow'
    'Set-Language'
    'Set-Progress'
    'Write-LogLine'
    'Write-TerminalLine'
    'Open-LogPanel'
    'Close-LogPanel'
    'Toggle-LogPanel'
    'Open-TerminalPanel'
    'Close-TerminalPanel'
    'Toggle-TerminalPanel'
    'Invoke-TerminalCommand'
    'Initialize-NativeCommandEncoding'
    'Import-TweakDataFile'
    # Installer plumbing — manifest Apply/Detect blocks run inside this module's session state and
    # would see these anyway; exported so they can also be exercised from a plain console.
    'Invoke-NativeProcess'
    'Get-WingetPath'
    'Get-WingetInstalledVersion'
    'Get-WingetInventory'
    'Clear-PackageCaches'
    'Test-WingetPackagePresent'
    'Get-InstalledProductInfo'
    'Get-UninstallIndex'
    'Get-WebView2RuntimeInfo'
    'Invoke-WingetEnsurePackage'
    'Invoke-WingetRemovePackage'
    'Get-DevicePowerSaveState'
    'Set-DevicePowerSaveEnabled'
    'Set-TweakStepFailed'
    'Test-TweakStepFailed'
    'Reset-TweakStepFailure'
    'Test-IsElevated'
    'Initialize-TooltipTiming'
)
