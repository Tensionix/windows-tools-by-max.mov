# Audion Windows Tools by Max.mov - pre-release smoke checks
# UTF-8 without BOM
#
# DEVELOPMENT TOOL. Nothing here runs when the app runs; the app never calls into Tests\.
# These are the checks that were being repeated by hand after every change - the ones that
# actually caught regressions: manifests that stopped loading under Windows PowerShell 5.1,
# a string key added to one language but not the other, a Detect block that grew slow enough
# to stall the interface.
#
#   Engine\PowerShell\pwsh.exe -NoProfile -File Tests\Smoke.ps1
#   Engine\PowerShell\pwsh.exe -NoProfile -File Tests\Smoke.ps1 -CrossHost -Full
#
#   -CrossHost  also runs every check under the other PowerShell (7 <-> 5.1)
#   -Full       additionally executes every Detect block and times it
#
# Exit code 0 = all checks passed, 1 = at least one failed.

[CmdletBinding()]
param(
    [switch]$CrossHost,
    [switch]$Full,
    [int]$DetectBudgetMs = 1000,
    [int]$ColdSubsectionBudgetMs = 2000
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$script:Failures = 0
$script:Checks   = 0

function Write-Check([string]$Name, [bool]$Ok, [string]$Detail) {
    $script:Checks++
    if ($Ok) {
        Write-Host ("  PASS  {0}" -f $Name) -ForegroundColor Green
    } else {
        $script:Failures++
        Write-Host ("  FAIL  {0}" -f $Name) -ForegroundColor Red
    }
    if ($Detail) { Write-Host ("        {0}" -f $Detail) -ForegroundColor DarkGray }
}

function Write-Head([string]$Text) {
    Write-Host ''
    Write-Host $Text -ForegroundColor Cyan
}

Write-Host ("Audion Windows Tools - smoke checks on PowerShell {0}" -f $PSVersionTable.PSVersion) -ForegroundColor White
Write-Host ("Project: {0}" -f $root) -ForegroundColor DarkGray

# -----------------------------------------------------------------------------
Write-Head '1. Engine loads'

$enginePath = Join-Path $root 'Engine\TweakEngine.psm1'
$engineOk = $false
try {
    $mod = Import-Module $enginePath -Force -DisableNameChecking -PassThru
    & $mod { param($a) $script:AppRoot = $a; $script:Lang = 'en' } $root
    $engineOk = $true
    Write-Check 'TweakEngine.psm1 imports' $true ''
} catch {
    Write-Check 'TweakEngine.psm1 imports' $false $_.Exception.Message
}
if (-not $engineOk) { Write-Host ''; Write-Host 'Engine did not load - remaining checks cannot run.' -ForegroundColor Red; exit 1 }

# -----------------------------------------------------------------------------
Write-Head '2. Files are UTF-8 without BOM'
# Windows PowerShell 5.1 decodes a BOM-less file as ANSI unless it is read explicitly as UTF-8.
# A BOM would work too, but the project standard is BOM-less, so drift in either direction is a bug.

$dataFiles = @()
$dataFiles += Get-ChildItem (Join-Path $root 'Manifests') -Filter '*.psd1' -EA SilentlyContinue
$dataFiles += Get-ChildItem (Join-Path $root 'Strings')   -Filter '*.psd1' -EA SilentlyContinue
$dataFiles += Get-Item (Join-Path $root 'Engine\Themes.psd1') -EA SilentlyContinue

$withBom = @()
foreach ($f in $dataFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $withBom += $f.Name
    }
}
Write-Check 'no data file carries a UTF-8 BOM' ($withBom.Count -eq 0) ("checked {0} files{1}" -f $dataFiles.Count, $(if ($withBom.Count) { '; offenders: ' + ($withBom -join ', ') } else { '' }))

# The same trap one level up. A BOM-less .ps1 read by 5.1 as ANSI turns a UTF-8 em dash into the
# byte sequence for a smart quote - and PowerShell accepts smart quotes as string delimiters, so a
# dash inside a double-quoted string silently ends it and the file stops parsing. Reading each file
# the way THIS host would, then parsing it, reproduces exactly that failure under -CrossHost.
$sourceParseErrors = @()
$psFiles = @()
$psFiles += Get-ChildItem $root -Filter '*.ps1'  -EA SilentlyContinue
# Everything under Engine\ except the portable PowerShell distribution, which is not ours.
foreach ($ext in @('*.ps1','*.psm1')) {
    $psFiles += Get-ChildItem (Join-Path $root 'Engine') -Filter $ext -Recurse -EA SilentlyContinue |
                Where-Object { $_.FullName -notlike '*\Engine\PowerShell\*' }
}
$psFiles += Get-ChildItem $PSScriptRoot -Filter '*.ps1' -EA SilentlyContinue
$psFiles = @($psFiles | Sort-Object FullName -Unique)
foreach ($f in $psFiles) {
    $text = Get-Content -LiteralPath $f.FullName -Raw     # deliberately host-default decoding
    $errs = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) {
        $sourceParseErrors += ("{0}: {1}" -f $f.Name, $errs[0].Message)
    }
}
Write-Check 'every PowerShell source file parses on this host' ($sourceParseErrors.Count -eq 0) `
    $(if ($sourceParseErrors.Count) { $sourceParseErrors -join ' | ' } else { "$($psFiles.Count) source files" })

# The rule the data files and the source files pull in opposite directions on, so state it plainly:
# a .psd1 is read explicitly as UTF-8 and must NOT have a BOM; a .ps1/.psm1 is decoded by whichever
# host runs it, and 5.1 falls back to ANSI. Parsing survives that - text does not. App.ps1's Russian
# elevation message and TweakEngine.psm1's Russian labels are only intact on 5.1 because both files
# carry a BOM. Anyone "normalising" them to BOM-less would corrupt that text without breaking a
# single test, so make the invariant explicit: non-ASCII inside a string literal requires a BOM.
$encodingOffenders = @()
foreach ($f in $psFiles) {
    $bytes  = [System.IO.File]::ReadAllBytes($f.FullName)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if ($hasBom) { continue }

    $utf8Text = [System.IO.File]::ReadAllText($f.FullName, (New-Object System.Text.UTF8Encoding($false)))
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($utf8Text, [ref]$null, [ref]$null)
    if (-not $ast) { continue }
    $literals = $ast.FindAll({
        param($n)
        $n -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $n -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
    }, $true)
    $bad = @($literals | Where-Object { $_.Extent.Text -cmatch '[^\x00-\x7F]' })
    if ($bad.Count -gt 0) {
        $encodingOffenders += ("{0}: {1} non-ASCII literal(s), first at line {2}" -f $f.Name, $bad.Count, $bad[0].Extent.StartLineNumber)
    }
}
Write-Check 'BOM-less sources keep their string literals ASCII-only' ($encodingOffenders.Count -eq 0) `
    $(if ($encodingOffenders.Count) { $encodingOffenders -join ' | ' } else { 'non-ASCII text is only in files that carry a BOM' })

# -----------------------------------------------------------------------------
Write-Head '3. Manifests load'

$sections = @()
$loadErrors = @()
foreach ($f in (Get-ChildItem (Join-Path $root 'Manifests') -Filter '*.psd1' | Sort-Object Name)) {
    try { $sections += Import-TweakDataFile $f.FullName }
    catch { $loadErrors += ("{0}: {1}" -f $f.Name, $_.Exception.Message) }
}
Write-Check 'every manifest parses' ($loadErrors.Count -eq 0) $(if ($loadErrors.Count) { $loadErrors -join ' | ' } else { "$($sections.Count) sections" })
if ($loadErrors.Count) { Write-Host ''; Write-Host 'Manifests did not load - remaining checks cannot run.' -ForegroundColor Red; exit 1 }

$subsections = @($sections | ForEach-Object { $_.Subsections } | Where-Object { $_ -is [hashtable] })
$tweaks      = @($subsections | ForEach-Object { $_.Tweaks } | Where-Object { $_ -is [hashtable] })
Write-Check 'manifest inventory is non-empty' ($tweaks.Count -gt 0) ("{0} sections, {1} subsections, {2} cards" -f $sections.Count, $subsections.Count, $tweaks.Count)

# -----------------------------------------------------------------------------
Write-Head '4. Card metadata is well formed'

$noId = @($tweaks | Where-Object { -not $_.Id })
Write-Check 'every card has an Id' ($noId.Count -eq 0) ("{0} card(s) without an Id" -f $noId.Count)

$dupes = @($tweaks | Group-Object { [string]$_.Id } | Where-Object { $_.Count -gt 1 })
Write-Check 'card Ids are unique' ($dupes.Count -eq 0) $(if ($dupes.Count) { ($dupes | ForEach-Object { "$($_.Name) x$($_.Count)" }) -join ', ' } else { 'no duplicates' })

$noTitle = @($tweaks | Where-Object { -not $_.Title })
Write-Check 'every card has a Title' ($noTitle.Count -eq 0) $(if ($noTitle.Count) { ($noTitle | ForEach-Object { $_.Id }) -join ', ' } else { '' })

$knownKinds = @('link','deeplink','manual','registry','script','service','feature','powerscheme','docs')
$badKind = @($tweaks | Where-Object { $knownKinds -notcontains [string]$_.Kind })
Write-Check 'every Kind is one the engine handles' ($badKind.Count -eq 0) $(if ($badKind.Count) { ($badKind | ForEach-Object { "$($_.Id)=$($_.Kind)" }) -join ', ' } else { ($knownKinds -join ', ') })

$knownControls = @('button','checklist','toggle')
$badControl = @($tweaks | Where-Object { $_.Control -and ($knownControls -notcontains [string]$_.Control) })
Write-Check 'every Control is one the card builder handles' ($badControl.Count -eq 0) $(if ($badControl.Count) { ($badControl | ForEach-Object { "$($_.Id)=$($_.Control)" }) -join ', ' } else { '' })

# RequiresAdmin is now read by Invoke-TweakApply, so a string "false" would silently gate a card.
$badFlag = @($tweaks | Where-Object {
    ($_.Contains('RequiresAdmin')  -and $_.RequiresAdmin  -isnot [bool]) -or
    ($_.Contains('RequiresReboot') -and $_.RequiresReboot -isnot [bool])
})
Write-Check 'RequiresAdmin / RequiresReboot are real booleans' ($badFlag.Count -eq 0) $(if ($badFlag.Count) { ($badFlag | ForEach-Object { $_.Id }) -join ', ' } else { '' })

# -----------------------------------------------------------------------------
Write-Head '5. Links'

$withUrl = @($tweaks | Where-Object { $_.Url })
$badUrl = @($withUrl | Where-Object {
    $u = $null
    (-not [Uri]::TryCreate([string]$_.Url, [UriKind]::Absolute, [ref]$u)) -or (@('http','https') -notcontains $u.Scheme)
})
Write-Check 'every Url is an absolute http(s) address' ($badUrl.Count -eq 0) $(if ($badUrl.Count) { ($badUrl | ForEach-Object { "$($_.Id)=$($_.Url)" }) -join ', ' } else { "$($withUrl.Count) links" })

$linkNoUrl = @($tweaks | Where-Object { [string]$_.Kind -eq 'link' -and -not $_.Url })
Write-Check 'every link card actually has a Url' ($linkNoUrl.Count -eq 0) $(if ($linkNoUrl.Count) { ($linkNoUrl | ForEach-Object { $_.Id }) -join ', ' } else { '' })

$deeplinkNoUri = @($tweaks | Where-Object { [string]$_.Kind -eq 'deeplink' -and -not $_.Uri })
Write-Check 'every deeplink card actually has a Uri' ($deeplinkNoUri.Count -eq 0) $(if ($deeplinkNoUri.Count) { ($deeplinkNoUri | ForEach-Object { $_.Id }) -join ', ' } else { '' })

# -----------------------------------------------------------------------------
Write-Head '6. Interface strings'

$ru = Import-TweakDataFile (Join-Path $root 'Strings\ru.psd1')
$en = Import-TweakDataFile (Join-Path $root 'Strings\en.psd1')

$onlyEn = @($en.Keys | Where-Object { -not $ru.ContainsKey($_) })
$onlyRu = @($ru.Keys | Where-Object { -not $en.ContainsKey($_) })
Write-Check 'ru and en declare the same keys' (($onlyEn.Count + $onlyRu.Count) -eq 0) `
    $(if ($onlyEn.Count -or $onlyRu.Count) { "en only: $($onlyEn -join ', ') | ru only: $($onlyRu -join ', ')" } else { "$($ru.Count) keys in both" })

$blankRu = @($ru.Keys | Where-Object { [string]::IsNullOrWhiteSpace([string]$ru[$_]) })
$blankEn = @($en.Keys | Where-Object { [string]::IsNullOrWhiteSpace([string]$en[$_]) })
Write-Check 'no string is empty' (($blankRu.Count + $blankEn.Count) -eq 0) $(if ($blankRu.Count -or $blankEn.Count) { "ru: $($blankRu -join ', ') | en: $($blankEn -join ', ')" } else { '' })

# Every key the code asks for by name must exist - this is what catches a verdict line that would
# otherwise silently fall back to its English default on a Russian interface.
$sourceFiles = @()
$sourceFiles += Get-ChildItem (Join-Path $root 'Engine') -Filter '*.psm1' -Recurse -EA SilentlyContinue
$sourceFiles += Get-ChildItem (Join-Path $root 'Manifests') -Filter '*.psd1' -EA SilentlyContinue
$requested = New-Object System.Collections.Generic.HashSet[string]
foreach ($f in $sourceFiles) {
    $text = [System.IO.File]::ReadAllText($f.FullName, (New-Object System.Text.UTF8Encoding($false)))
    foreach ($m in [regex]::Matches($text, "(?:Get-UiText|Write-InstallVerdict)\s+'([A-Za-z0-9_]+)'")) {
        $null = $requested.Add($m.Groups[1].Value)
    }
}
$missing = @($requested | Where-Object { -not $ru.ContainsKey($_) -or -not $en.ContainsKey($_) })
Write-Check 'every key the code asks for exists in both languages' ($missing.Count -eq 0) `
    $(if ($missing.Count) { $missing -join ', ' } else { "$($requested.Count) keys referenced by name" })

# -----------------------------------------------------------------------------
Write-Head '7. Themes'

$themes = Import-TweakDataFile (Join-Path $root 'Engine\Themes.psd1')
$themeList = @($themes.Themes | Where-Object { $_ -is [hashtable] })
Write-Check 'Themes.psd1 parses and defines themes' ($themeList.Count -gt 0) ("{0} themes: {1}" -f $themeList.Count, (($themeList | ForEach-Object { $_.Id }) -join ', '))

# The window markup is the one file whose absence shows up only at launch, as a window that never
# appears. Both the app and Engine\Launcher\Test-WindowIdentity.ps1 expect it at this exact path.
$xamlPath = Join-Path $root 'Engine\MainWindow.xaml'
if (-not (Test-Path $xamlPath)) {
    Write-Check 'Engine\MainWindow.xaml is where the app looks for it' $false $xamlPath
} else {
    $xamlOk = $false
    $xamlDetail = ''
    try {
        [xml]$doc = Get-Content $xamlPath -Encoding UTF8
        $named = @([regex]::Matches($doc.OuterXml, 'x:Name="([^"]+)"')).Count
        $xamlOk = ($doc.DocumentElement.LocalName -eq 'Window') -and ($named -gt 0)
        $xamlDetail = "root=<$($doc.DocumentElement.LocalName)>, $named named controls"
    } catch { $xamlDetail = $_.Exception.Message }
    Write-Check 'Engine\MainWindow.xaml is well-formed window markup' $xamlOk $xamlDetail
}

# Start.exe is the entry point, and its contract is fixed at compile time: it runs App.ps1 from its
# own folder. Ship it without App.ps1 beside it and the only symptom is a message box on launch.
$startExe = Join-Path $root 'Start.exe'
$startOk = $false
$startDetail = ''
if (-not (Test-Path $startExe)) {
    $startDetail = 'Start.exe not found in the project root'
} elseif (-not (Test-Path (Join-Path $root 'App.ps1'))) {
    $startDetail = 'App.ps1 is not beside Start.exe'
} else {
    $peBytes = [System.IO.File]::ReadAllBytes($startExe)
    if ($peBytes.Length -lt 512 -or $peBytes[0] -ne 0x4D -or $peBytes[1] -ne 0x5A) {
        $startDetail = 'Start.exe is not a valid PE image'
    } else {
        # Subsystem 2 = Windows GUI. A console-subsystem build would flash a window on every launch.
        $subsystem = [BitConverter]::ToUInt16($peBytes, ([BitConverter]::ToInt32($peBytes, 0x3C)) + 24 + 68)
        $startOk = ($subsystem -eq 2)
        $startDetail = "PE subsystem $subsystem (2 = Windows GUI), App.ps1 present beside it"
    }
}
Write-Check 'Start.exe is a GUI-subsystem launcher with App.ps1 beside it' $startOk $startDetail

# -----------------------------------------------------------------------------
Write-Head '8. Documentation covers what ships'
# The user guides describe every card by id. Adding a card without documenting it is easy to do and
# invisible until someone goes looking, so compare the two lists instead of trusting them.

$manifestIds = @($tweaks | ForEach-Object { [string]$_.Id } | Sort-Object -Unique)
$byId = @{}
foreach ($t in $tweaks) { $byId[[string]$t.Id] = $t }

# The parenthetical the guides print after every card title, e.g.
#   (id=`privacy-speech`; kind=`registry`; control=`toggle`; source=`official`)
# with an optional localised "administrator rights" phrase appended.
$metaRx = [regex]'\(id=`([^`]+)`; kind=`([^`]+)`; control=`([^`]+)`; source=`([^`]+)`([^)]*)\)'

foreach ($lang in @('RU','EN')) {
    $guide = Join-Path $root ("Docs\USER_GUIDE_{0}.md" -f $lang)
    if (-not (Test-Path $guide)) {
        Write-Check ("USER_GUIDE_{0}.md exists" -f $lang) $false 'file not found'
        continue
    }
    $text  = [System.IO.File]::ReadAllText($guide, (New-Object System.Text.UTF8Encoding($false)))
    $docIds = @([regex]::Matches($text, 'id=`([^`]+)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $undocumented = @($manifestIds | Where-Object { $docIds -notcontains $_ })
    $orphaned     = @($docIds | Where-Object { $manifestIds -notcontains $_ })
    $detail = if ($undocumented.Count -or $orphaned.Count) {
        "undocumented: $($undocumented -join ', ') | no longer in manifests: $($orphaned -join ', ')"
    } else {
        "$($docIds.Count) cards documented"
    }
    Write-Check ("USER_GUIDE_{0}.md documents exactly the shipped cards" -f $lang) (($undocumented.Count + $orphaned.Count) -eq 0) $detail

    # Matching ids is not enough. A card converted from 'deeplink' to 'registry' keeps its id, so the
    # guide would go on saying "opens a Settings page" for a card that now writes the value itself -
    # exactly the drift that is invisible until a reader follows instructions that no longer apply.
    # The administrator phrase is localised, so only its presence is compared, never its wording.
    # The tail after source= carries, in order: an optional tone=, then a localised "requires
    # administrator" phrase, then a localised "requires reboot" phrase, then an optional appliesTo=.
    # Smoke stays ASCII-only, so the two phrases are not spelled here - they are learned from the
    # guide itself, using cards where exactly one of the two flags is set. That also catches a guide
    # that words the same flag two different ways.
    $matches2 = @($metaRx.Matches($text))
    $flagsOf = {
        param($m)
        @($m.Groups[5].Value -split ';' | ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and $_ -notmatch '^[A-Za-z]+=' })
    }
    $learn = {
        param($wantAdmin, $wantReboot)
        $seen = @($matches2 | Where-Object {
            $t = $byId[$_.Groups[1].Value]
            $t -and ([bool]$t.RequiresAdmin -eq $wantAdmin) -and ([bool]$t.RequiresReboot -eq $wantReboot)
        } | ForEach-Object { (& $flagsOf $_) -join '|' } | Sort-Object -Unique)
        if ($seen.Count -eq 1) { $seen[0] } else { $null }
    }
    $adminPhrase  = & $learn $true  $false
    $rebootPhrase = & $learn $false $true

    $drift = @()
    foreach ($m in $matches2) {
        $id = $m.Groups[1].Value
        $t  = $byId[$id]
        if (-not $t) { continue }   # already reported above as no longer in the manifests
        $docKind = $m.Groups[2].Value; $docCtrl = $m.Groups[3].Value; $docSrc = $m.Groups[4].Value
        if     ([string]$t.Kind    -ne $docKind) { $drift += "${id}: guide kind=$docKind, manifest $($t.Kind)"; continue }
        elseif ([string]$t.Control -ne $docCtrl) { $drift += "${id}: guide control=$docCtrl, manifest $($t.Control)"; continue }
        elseif ([string]$t.Source  -ne $docSrc)  { $drift += "${id}: guide source=$docSrc, manifest $($t.Source)"; continue }

        $docFlags = @(& $flagsOf $m)
        if ($null -ne $adminPhrase -and $null -ne $rebootPhrase) {
            $want = @()
            if ([bool]$t.RequiresAdmin)  { $want += $adminPhrase }
            if ([bool]$t.RequiresReboot) { $want += $rebootPhrase }
            if (($docFlags -join '|') -ne ($want -join '|')) {
                $drift += "${id}: guide flags [$($docFlags -join ', ')], manifest admin=$([bool]$t.RequiresAdmin) reboot=$([bool]$t.RequiresReboot)"
            }
        } else {
            # Wording could not be learned - fall back to counting, which still catches a flag
            # that was added or dropped, just not one swapped for the other.
            $wantCount = [int][bool]$t.RequiresAdmin + [int][bool]$t.RequiresReboot
            if ($docFlags.Count -ne $wantCount) {
                $drift += "${id}: guide has $($docFlags.Count) flag phrase(s), manifest expects $wantCount"
            }
        }
    }
    $driftDetail = if ($drift.Count) {
        (($drift | Select-Object -First 6) -join ' | ') + $(if ($drift.Count -gt 6) { " (+$($drift.Count - 6) more)" } else { '' })
    } else { "kind/control/source/admin agree for $($docIds.Count) cards" }
    Write-Check ("USER_GUIDE_{0}.md metadata matches the manifests" -f $lang) ($drift.Count -eq 0) $driftDetail
}

# -----------------------------------------------------------------------------
Write-Head '9. Version'

$versionPath = Join-Path $root 'config\version.json'
$versionOk = $false
$versionText = ''
try {
    $v = Get-Content $versionPath -Raw | ConvertFrom-Json
    $versionText = [string]$v.version
    $versionOk = $versionText -match '^\d+\.\d+\.\d+$'
} catch { $versionText = $_.Exception.Message }
Write-Check 'config\version.json is valid JSON with a SemVer version' $versionOk $versionText

# -----------------------------------------------------------------------------
Write-Head '10. Loading a manifest cannot execute code'
# Import-TweakDataFile replaced Import-PowerShellDataFile to work under 5.1. That swap must not have
# traded away the safety property: a data file is data, not a script.

$probe = Join-Path ([System.IO.Path]::GetTempPath()) ("audion-smoke-{0}.psd1" -f ([Guid]::NewGuid().ToString('N')))
$marker = Join-Path ([System.IO.Path]::GetTempPath()) ("audion-smoke-{0}.marker" -f ([Guid]::NewGuid().ToString('N')))
$rejected = $false
try {
    [System.IO.File]::WriteAllText($probe, "New-Item -ItemType File -Path '$marker' -Force | Out-Null`r`n@{ Id = 'x' }`r`n", (New-Object System.Text.UTF8Encoding($false)))
    try { $null = Import-TweakDataFile $probe } catch { $rejected = $true }
    $executed = Test-Path $marker
    Write-Check 'a data file containing a command is rejected and does not run' ($rejected -and -not $executed) `
        ("rejected={0} sideEffect={1}" -f $rejected, $executed)
} finally {
    Remove-Item $probe  -Force -EA SilentlyContinue
    Remove-Item $marker -Force -EA SilentlyContinue
}

# -----------------------------------------------------------------------------
Write-Head '11. Skill profiles'
# Skill\Profiles\*.psd1 name cards by id for Engine\Invoke-TweakProfile.ps1. A typo there is invisible
# until a run reports the id as missing - by which point an agent may have been told the machine is
# configured. Profiles must also stay data: the runner loads them through the same reader as the
# manifests, so a script block in one would be rejected at run time rather than here.

# Kept in step with $AutomatableKinds in Engine\Invoke-TweakProfile.ps1.
$AutomatableKinds = @('registry','service','feature','powerscheme','script')

$profileDir = Join-Path $root 'Skill\Profiles'
if (-not (Test-Path $profileDir)) {
    Write-Check 'Skill\Profiles exists' $false 'folder not found'
} else {
    $profiles = @(Get-ChildItem $profileDir -Filter '*.psd1' -EA SilentlyContinue)
    Write-Check 'Skill\Profiles holds at least one profile' ($profiles.Count -gt 0) ("{0} profile(s)" -f $profiles.Count)

    $badLoad = @(); $badIds = @(); $badShape = @(); $badChain = @()
    foreach ($pf in $profiles) {
        $data = $null
        try { $data = Import-TweakDataFile $pf.FullName }
        catch { $badLoad += ("{0}: {1}" -f $pf.Name, $_.Exception.Message); continue }

        if (-not $data.Contains('Cards')) { $badShape += ("{0}: no Cards list" -f $pf.Name); continue }
        $ids = @($data['Cards'] | ForEach-Object { [string]$_ } | Where-Object { $_ })
        if ($ids.Count -eq 0) { $badShape += ("{0}: Cards is empty" -f $pf.Name); continue }

        # Follow Extends the way the runner does, so a parent that was renamed or a chain that loops
        # back on itself fails here rather than at the top of somebody's setup session.
        $chain = $data; $seenFiles = @($pf.FullName.ToLowerInvariant()); $hops = 0
        while ($chain -and $chain['Extends'] -and $hops -lt 10) {
            $hops++
            $parentPath = Join-Path $profileDir ([string]$chain['Extends'])
            if (-not (Test-Path $parentPath)) {
                $badChain += ("{0}: Extends target missing - {1}" -f $pf.Name, [string]$chain['Extends']); break
            }
            $key = (Resolve-Path $parentPath).Path.ToLowerInvariant()
            if ($seenFiles -contains $key) { $badChain += ("{0}: Extends chain loops" -f $pf.Name); break }
            $seenFiles += $key
            try { $chain = Import-TweakDataFile $parentPath }
            catch { $badChain += ("{0}: parent will not load - {1}" -f $pf.Name, $_.Exception.Message); break }
            $ids += @($chain['Cards'] | ForEach-Object { [string]$_ } | Where-Object { $_ })
        }
        if ($hops -ge 10) { $badChain += ("{0}: Extends nested more than 10 deep" -f $pf.Name) }

        foreach ($id in $ids) {
            if ($manifestIds -notcontains $id) { $badIds += ("{0}: {1}" -f $pf.Name, $id) }
            elseif ($AutomatableKinds -notcontains [string]$byId[$id].Kind) {
                $badIds += ("{0}: {1} is kind '{2}', which the runner cannot carry out" -f $pf.Name, $id, $byId[$id].Kind)
            }
        }
    }
    Write-Check 'every profile loads as a data file' ($badLoad.Count -eq 0) $(if ($badLoad.Count) { $badLoad -join ' | ' } else { 'all parsed' })
    Write-Check 'every profile declares a non-empty Cards list' ($badShape.Count -eq 0) $(if ($badShape.Count) { $badShape -join ' | ' } else { 'all well formed' })
    Write-Check 'every Extends target resolves and does not loop' ($badChain.Count -eq 0) $(if ($badChain.Count) { $badChain -join ' | ' } else { 'inheritance chains are sound' })
    Write-Check 'every card named by a profile exists and is automatable' ($badIds.Count -eq 0) $(if ($badIds.Count) { ($badIds | Select-Object -First 6) -join ' | ' } else { 'all ids resolve' })
}

# -----------------------------------------------------------------------------
if ($Full) {
    Write-Head "12. Detect timing (budget ${DetectBudgetMs} ms per card)"
    # Detect runs on every subsection switch. A slow one is felt directly as a stalled interface -
    # this is the check that caught a 5-second WMI query and a per-package winget call.

    & $mod { Initialize-NativeCommandEncoding }
    $sysProfile = Get-SystemProfile
    $withDetect = @($tweaks | Where-Object { $_.Detect })

    # Warm the shared caches first, exactly as the first status refresh of a session does. Their
    # one-off cost is a property of the session, not of any single card, and charging it to whichever
    # card happens to run first would make this check report a different culprit every run.
    $null = & $mod { Get-UninstallIndex }
    $null = & $mod { Get-WingetInventory }

    $slow = @()
    foreach ($t in $withDetect) {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        try { $null = Test-TweakState $t $sysProfile } catch {}
        $sw.Stop()
        if ($sw.ElapsedMilliseconds -gt $DetectBudgetMs) {
            $slow += ("{0} = {1} ms" -f $t.Id, $sw.ElapsedMilliseconds)
        }
    }

    # Everything above measures with the caches warm, so that a session-wide cost is not blamed on
    # whichever card happened to run first. That is fair to the cards and blind to the person using
    # the program: what they feel is the FIRST view of a subsection, with nothing cached. The
    # blindness let a twelve-second freeze ship - the browser subsection cost 11940 ms cold and 28 ms
    # warm, and only the warm number was ever looked at. So measure the cold walk too, subsection by
    # subsection, exactly as someone clicking through the pages would.
    & $mod { Clear-PackageCaches }
    $worstTitle = '(none)'; $worstMs = 0
    foreach ($sub in $subsections) {
        $subCards = @($sub.Tweaks | Where-Object { $_ -is [hashtable] -and $_.Detect })
        if ($subCards.Count -eq 0) { continue }
        $sw = [Diagnostics.Stopwatch]::StartNew()
        foreach ($t in $subCards) { try { $null = Test-TweakState $t $sysProfile } catch {} }
        $sw.Stop()
        if ($sw.ElapsedMilliseconds -gt $worstMs) {
            $worstMs = $sw.ElapsedMilliseconds; $worstTitle = [string]$sub.Title
        }
    }
    Write-Check 'the first view of a subsection stays responsive' ($worstMs -le $ColdSubsectionBudgetMs) `
        ("slowest cold subsection: {0} = {1} ms (budget {2} ms)" -f $worstTitle, $worstMs, $ColdSubsectionBudgetMs)
    Write-Check 'no Detect block exceeds the budget' ($slow.Count -eq 0) `
        $(if ($slow.Count) { $slow -join ' | ' } else { "$($withDetect.Count) Detect blocks all within ${DetectBudgetMs} ms" })
}

# -----------------------------------------------------------------------------
Write-Host ''
if ($script:Failures -eq 0) {
    Write-Host ("{0}/{0} checks passed on PowerShell {1}" -f $script:Checks, $PSVersionTable.PSVersion) -ForegroundColor Green
} else {
    Write-Host ("{0} of {1} checks FAILED on PowerShell {2}" -f $script:Failures, $script:Checks, $PSVersionTable.PSVersion) -ForegroundColor Red
}

# -----------------------------------------------------------------------------
# The whole point of the manifest loader rewrite was that both hosts behave identically. Prove it
# rather than assume it: re-run everything under the other PowerShell and combine the verdicts.
$crossExit = 0
if ($CrossHost) {
    $isPs7 = $PSVersionTable.PSVersion.Major -ge 6
    $other = $null
    if ($isPs7) {
        $candidate = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        if (Test-Path $candidate) { $other = $candidate }
    } else {
        $candidate = Join-Path $root 'Engine\PowerShell\pwsh.exe'
        if (Test-Path $candidate) { $other = $candidate }
        else {
            $sys = Get-Command 'pwsh.exe' -CommandType Application -EA SilentlyContinue | Select-Object -First 1
            if ($sys) { $other = $sys.Source }
        }
    }

    Write-Host ''
    if (-not $other) {
        Write-Host 'CrossHost: the other PowerShell was not found on this machine - skipped.' -ForegroundColor Yellow
    } else {
        Write-Host ("CrossHost: re-running every check under {0}" -f $other) -ForegroundColor Cyan
        Write-Host ('-' * 70) -ForegroundColor DarkGray
        $childArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
        if ($Full) { $childArgs += '-Full'; $childArgs += '-DetectBudgetMs'; $childArgs += "$DetectBudgetMs" }
        & $other @childArgs
        $crossExit = $LASTEXITCODE
        Write-Host ('-' * 70) -ForegroundColor DarkGray
        if ($crossExit -eq 0) {
            Write-Host 'CrossHost: the other PowerShell agrees - all checks passed there too.' -ForegroundColor Green
        } else {
            Write-Host 'CrossHost: checks FAILED under the other PowerShell (see above).' -ForegroundColor Red
        }
    }
}

if ($script:Failures -gt 0 -or $crossExit -ne 0) { exit 1 }
exit 0
