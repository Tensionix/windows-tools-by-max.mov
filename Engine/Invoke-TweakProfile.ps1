#requires -Version 5.1
<#
    Invoke-TweakProfile.ps1 - headless profile runner for Audion Windows Tools by Max.mov.

    This is the single tool the Skill\*.skill contract drives. It never opens a window and never
    touches the GUI: it imports Engine\TweakEngine.psm1, asks every card in a profile what state the
    machine is actually in, and - only when told to - applies the ones that are missing.

    Output is deliberately ASCII-only English, like Tests\Smoke.ps1: the file carries no BOM, and
    Windows PowerShell 5.1 decodes a BOM-less file as the ANSI code page, which would mangle any
    non-ASCII literal. An agent reading -Json can present it in whatever language it likes.

    Reporting is the default. Nothing changes unless -Apply is passed.

        .\Invoke-TweakProfile.ps1 -Discover
        .\Invoke-TweakProfile.ps1 -ProfilePath ..\Skill\Profiles\fresh-install.psd1
        .\Invoke-TweakProfile.ps1 -ProfilePath ..\Skill\Profiles\fresh-install.psd1 -Json
        .\Invoke-TweakProfile.ps1 -ProfilePath ..\Skill\Profiles\fresh-install.psd1 -Apply

    Exit codes: 0 nothing left to do or report-only; 1 cards still need applying; 2 a card failed;
    3 the profile or the engine could not be loaded; 4 -Apply needs an elevated session and this one
    is not. This script never raises a UAC prompt itself - elevation belongs to the session, because
    a sixty-card profile would otherwise mean sixty prompts.
#>
[CmdletBinding()]
param(
    # Profile file (.psd1) listing card ids in the order they should run. Omit to use every
    # automatable card the manifests declare, which is what -Discover prints.
    [string]$ProfilePath,

    # Restrict to these card ids, whatever the profile says.
    [string[]]$Only,

    # Actually change the machine. Without it this reports and exits.
    [switch]$Apply,

    # Also apply cards that cannot be undone - a script card with no Revert block. Off by default:
    # an agent running unattended should not take a one-way step without being told to.
    [switch]$IncludeIrreversible,

    # Machine-readable output for an agent to parse.
    [switch]$Json,

    # List every automatable card in the manifests, grouped by section, and exit. Use this to build
    # a profile in the first place.
    [switch]$Discover
)

$ErrorActionPreference = 'Stop'

# Kinds the engine can carry out on its own. Everything else - link, deeplink, manual, docs - is a
# human's job by design: it opens a page or asks the person to do something, and this runner will
# not pretend otherwise.
$AutomatableKinds = @('registry','service','feature','powerscheme','script')

$root = Split-Path $PSScriptRoot -Parent
$out  = [System.Collections.ArrayList]::new()

function Add-Row([hashtable]$Row) { [void]$out.Add([pscustomobject]$Row) }

function Write-Line([string]$Text, [string]$Colour = 'Gray') {
    if (-not $Json) { Write-Host $Text -ForegroundColor $Colour }
}

# ---------------------------------------------------------------------------- engine

try {
    Import-Module (Join-Path $PSScriptRoot 'TweakEngine.psm1') -Force -DisableNameChecking
    Initialize-TweakEngine -AppRoot $root | Out-Null
} catch {
    Write-Error "Could not load the engine: $($_.Exception.Message)"
    exit 3
}

$elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Stream what the cards print, so a long winget step is not a silent wait.
if (-not $Json) {
    Initialize-TweakEngine -AppRoot $root -LineSink { param($line) Write-Host "      $line" -ForegroundColor DarkGray } | Out-Null
}

# ---------------------------------------------------------------------------- manifests

$cards    = [ordered]@{}
$sectionOf = @{}
try {
    foreach ($file in (Get-ChildItem (Join-Path $root 'Manifests') -Filter 'Section*.psd1' | Sort-Object Name)) {
        $data = Import-TweakDataFile $file.FullName
        foreach ($sub in $data['Subsections']) {
            foreach ($card in $sub['Tweaks']) {
                $id = [string]$card['Id']
                if (-not $id) { continue }
                $cards[$id]     = $card
                $sectionOf[$id] = '{0} / {1}' -f $data['Title'], $sub['Title']
            }
        }
    }
} catch {
    Write-Error "Could not load the manifests: $($_.Exception.Message)"
    exit 3
}

$sysProfile = Get-SystemProfile

# ---------------------------------------------------------------------------- discover

if ($Discover) {
    $auto = @($cards.Keys | Where-Object { $AutomatableKinds -contains [string]$cards[$_]['Kind'] })
    if ($Json) {
        $auto | ForEach-Object {
            $c = $cards[$_]
            Add-Row @{
                id = $_; title = [string]$c['Title']; kind = [string]$c['Kind']
                section = $sectionOf[$_]; requiresAdmin = [bool]$c['RequiresAdmin']
                reversible = ([string]$c['Kind'] -ne 'script') -or [bool]$c['Revert']
            }
        }
        $out | ConvertTo-Json -Depth 4
    } else {
        Write-Line ''
        Write-Line ("{0} automatable cards out of {1} in the manifests" -f $auto.Count, $cards.Count) 'Cyan'
        Write-Line ''
        foreach ($group in ($auto | Group-Object { $sectionOf[$_] } | Sort-Object Name)) {
            Write-Line ("  {0}" -f $group.Name) 'White'
            foreach ($id in $group.Group) {
                $c = $cards[$id]
                $flags = @()
                if ([bool]$c['RequiresAdmin']) { $flags += 'admin' }
                if ([string]$c['Kind'] -eq 'script' -and -not $c['Revert']) { $flags += 'NO REVERT' }
                Write-Line ("      {0,-40} {1,-12} {2}" -f $id, [string]$c['Kind'], ($flags -join ', '))
            }
        }
        Write-Line ''
    }
    exit 0
}

# ---------------------------------------------------------------------------- profile

# A profile may name a parent with Extends, resolved beside itself. The parent's cards run first,
# then the child's; an id repeated in both keeps its earliest position. That is what lets one machine
# profile say "the privacy baseline, plus Chrome and clipboard history" without copying fourteen ids
# and then silently drifting from the file they were copied out of.
function Resolve-ProfileCards {
    param([string]$Path, [System.Collections.Generic.HashSet[string]]$Seen)

    $full = (Resolve-Path $Path).Path
    if (-not $Seen.Add($full.ToLowerInvariant())) {
        throw "Profile inheritance loops back to $([System.IO.Path]::GetFileName($full))"
    }
    $data = Import-TweakDataFile $full

    $ids = @()
    if ($data['Extends']) {
        $parent = Join-Path (Split-Path $full -Parent) ([string]$data['Extends'])
        if (-not (Test-Path $parent)) {
            throw "Extends target not found: $([string]$data['Extends']) (looked beside $([System.IO.Path]::GetFileName($full)))"
        }
        $ids += @(Resolve-ProfileCards -Path $parent -Seen $Seen)   # @() keeps a one-card parent an array
    }
    $ids += @($data['Cards'] | ForEach-Object { [string]$_ } | Where-Object { $_ })

    # Plain return, not a comma-wrapped array: every caller re-wraps with @(), and wrapping here as
    # well nests one array inside another - which reaches the run loop as a single bogus "id".
    $ids
}

$wanted = @()
if ($ProfilePath) {
    if (-not (Test-Path $ProfilePath)) { Write-Error "Profile not found: $ProfilePath"; exit 3 }
    try {
        $pf  = Import-TweakDataFile (Resolve-Path $ProfilePath).Path
        $all = @(Resolve-ProfileCards -Path $ProfilePath -Seen ([System.Collections.Generic.HashSet[string]]::new()))
    } catch {
        Write-Error "Profile could not be resolved: $($_.Exception.Message)"
        exit 3
    }
    # Keep first occurrence, drop later duplicates.
    $seenId = [System.Collections.Generic.HashSet[string]]::new()
    $wanted = @($all | Where-Object { $seenId.Add($_) })
    Write-Line ''
    Write-Line ("Profile: {0}" -f $(if ($pf['Name']) { $pf['Name'] } else { Split-Path $ProfilePath -Leaf })) 'Cyan'
    if ($pf['Description']) { Write-Line ("         {0}" -f $pf['Description']) }
} else {
    $wanted = @($cards.Keys | Where-Object { $AutomatableKinds -contains [string]$cards[$_]['Kind'] })
    Write-Line ''
    Write-Line 'Profile: (none given) - every automatable card in the manifests' 'Cyan'
}

if ($Only) { $wanted = @($wanted | Where-Object { $Only -contains $_ }) }

$unknown = @($wanted | Where-Object { -not $cards.Contains($_) })
if ($unknown.Count) {
    Write-Line ("  WARNING  {0} id(s) in the profile are not in the manifests: {1}" -f $unknown.Count, ($unknown -join ', ')) 'Yellow'
    $wanted = @($wanted | Where-Object { $cards.Contains($_) })
}

Write-Line ("Mode:    {0}{1}" -f $(if ($Apply) { 'APPLY - the machine will be changed' } else { 'report only - nothing will change' }),
                                $(if ($elevated) { '' } else { '  (not elevated)' })) $(if ($Apply) { 'Yellow' } else { 'Gray' })
Write-Line ''

# Elevation is a property of the session, not of each card: this runner never raises a UAC prompt of
# its own, because a profile of sixty cards would mean sixty prompts. So if the run cannot possibly
# succeed, say so once and stop, instead of walking the whole profile to mark every admin card
# 'skipped' and leaving the user to notice. Reporting is unaffected - reading state needs no rights.
if ($Apply -and -not $elevated) {
    $needAdmin = @($wanted | Where-Object { [bool]$cards[$_]['RequiresAdmin'] })
    if ($needAdmin.Count) {
        $msg = "{0} of {1} cards in this run need administrator rights and this session does not have them. Restart the session elevated and run again - nothing was changed." -f $needAdmin.Count, $wanted.Count
        if ($Json) {
            [pscustomobject]@{
                elevated = $false; mode = 'apply'; error = 'not-elevated'
                message = $msg; cardsNeedingAdmin = $needAdmin
            } | ConvertTo-Json -Depth 4
        } else {
            Write-Line ("  {0}" -f $msg) 'Red'
            Write-Line ("  {0}" -f ($needAdmin -join ', ')) 'DarkGray'
            Write-Line ''
        }
        exit 4
    }
}

# ---------------------------------------------------------------------------- run

$counts = @{ applied = 0; already = 0; skipped = 0; failed = 0; manual = 0 }

foreach ($id in $wanted) {
    $card   = $cards[$id]
    $kind   = [string]$card['Kind']
    $title  = [string]$card['Title']
    $admin  = [bool]$card['RequiresAdmin']
    $revertable = ($kind -ne 'script') -or [bool]$card['Revert']

    $before = try { Test-TweakState $card $sysProfile } catch { 'Unknown' }
    $action = $null
    $after  = $before
    $note   = ''

    if ($AutomatableKinds -notcontains $kind) {
        $action = 'manual'; $note = "kind '$kind' is a human step by design"; $counts.manual++
    }
    elseif ($before -eq 'NotApplicable') {
        $action = 'skipped'; $note = 'does not apply to this system'; $counts.skipped++
    }
    elseif ($before -eq 'Applied') {
        $action = 'already'; $counts.already++
    }
    elseif (-not $Apply) {
        $action = 'would-apply'
    }
    elseif ($admin -and -not $elevated) {
        $action = 'skipped'; $note = 'needs administrator rights - run this session elevated'; $counts.skipped++
    }
    elseif (-not $revertable -and -not $IncludeIrreversible) {
        $action = 'skipped'; $note = 'no Revert block - pass -IncludeIrreversible to allow it'; $counts.skipped++
    }
    else {
        try {
            Reset-TweakStepFailure
            Invoke-TweakApply $card $sysProfile
            $after = try { Test-TweakState $card $sysProfile } catch { 'Unknown' }
            if ((Test-TweakStepFailed) -or ($after -ne 'Applied')) {
                $action = 'failed'; $note = "state after apply: $after"; $counts.failed++
            } else {
                $action = 'applied'; $counts.applied++
            }
        } catch {
            $action = 'failed'; $note = $_.Exception.Message; $counts.failed++
            $after = try { Test-TweakState $card $sysProfile } catch { 'Unknown' }
        }
    }

    Add-Row @{
        id = $id; title = $title; kind = $kind; section = $sectionOf[$id]
        requiresAdmin = $admin; reversible = $revertable
        before = $before; after = $after; action = $action; note = $note
    }

    if (-not $Json) {
        $colour = switch ($action) {
            'applied'     { 'Green' }
            'already'     { 'DarkGreen' }
            'failed'      { 'Red' }
            'would-apply' { 'Yellow' }
            default       { 'DarkGray' }
        }
        Write-Line ("  {0,-12} {1,-40} {2}" -f $action, $id, $(if ($note) { $note } else { $title })) $colour
    }
}

# ---------------------------------------------------------------------------- summary

if ($Json) {
    [pscustomobject]@{
        elevated = $elevated
        mode     = $(if ($Apply) { 'apply' } else { 'report' })
        counts   = $counts
        cards    = $out
    } | ConvertTo-Json -Depth 5
} else {
    Write-Line ''
    Write-Line ("  applied {0}   already {1}   skipped {2}   manual {3}   failed {4}" -f
        $counts.applied, $counts.already, $counts.skipped, $counts.manual, $counts.failed) 'Cyan'
    if (-not $Apply) {
        $todo = @($out | Where-Object { $_.action -eq 'would-apply' }).Count
        if ($todo) { Write-Line ("  {0} card(s) would be applied. Re-run with -Apply." -f $todo) 'Yellow' }
    }
    Write-Line ''
}

if ($counts.failed) { exit 2 }
if (@($out | Where-Object { $_.action -eq 'would-apply' }).Count) { exit 1 }
exit 0
