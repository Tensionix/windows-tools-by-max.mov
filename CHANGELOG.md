# Changelog

All notable changes to Audion Windows Tools by Max.mov.

Versions follow SemVer as defined in `AGENTS.md`; `config/version.json` is the single source of
truth. Entries record *why* a version was bumped, not every file that moved.

The reader-facing account of the 1.2.4 -> 1.5.1 work, written for people rather than for
maintainers, is `Audion_Windows_Tools_что_изменилось.md`.

---

## 1.11.1

**Opening a subsection no longer freezes for twelve seconds.** Reported from use: the program felt
heavier, and the Install Browser page once simply hung.

Measured, cold, on the browser subsection: **11940 ms**, of which 11540 ms was one card - Opera. The
installed browsers were answered by the registry in 3-13 ms each. The one that is *not* installed
missed the registry and fell through to `winget list`, which costs about 12 s. So the freeze was the
cost of proving a negative the registry had already proven.

A `Detect` block may now **use** the winget listing but never **build** it. Detect runs on every
subsection switch with the user watching a half-drawn page; `Apply` is unaffected, because waiting
for winget there is the job. This is safe because all nine Detect blocks that ask about a package
already pass a registry name pattern, and the registry is both faster and able to see per-user
installs. It only changes the answer for a package whose ARP name does not match its pattern - and
any install, or Refresh, rebuilds the listing anyway.

Result: **11940 ms -> 327 ms**, with every verdict identical.

Two supporting changes:

- The listing's timeout was 120 s. Inside a status refresh that is not slowness, it is a hang with a
  timer on it. Now 30 s - four times the measured 12 s, and returning empty lets the registry's
  answer stand instead of freezing the interface behind it.
- Its cache expired after 10 minutes. Time is the weakest reason to discard it: installing, removing
  and Refresh all drop it already, and a 10-minute expiry only guarded against a package installed
  outside the program, which the registry sees first. Now 4 hours, so walking the sections twice in
  an afternoon does not pay for it twice.

### Fixed in the checks

The Detect timing check warmed every cache before measuring, so that a session-wide cost would not be
blamed on whichever card ran first. Fair to the cards, blind to the person: the browser subsection
measured 28 ms warm and 11940 ms cold, and only the warm number was ever looked at - which is how a
twelve-second freeze shipped past a check written to catch exactly that. It now also walks every
subsection with the caches cleared, the way someone clicking through the pages does, and budgets the
slowest at 2000 ms (`-ColdSubsectionBudgetMs`). Slowest today: More Personalization, 820 ms.

## 1.11.0

**Chrome installs like the other browsers now.** It was the one `link` card among five browsers -
Brave, Firefox, Vivaldi and Opera went through winget, while the browser most people actually want
only opened a download page. `Google.Chrome` is in the winget source and the card now mirrors
`install-brave` exactly: `Invoke-WingetEnsurePackage` to install, `Invoke-WingetRemovePackage` to
revert, and a `Detect` that reads the registry first and winget second, with `^Google Chrome$` as the
registry name pattern. Confirmed against a machine that already has it: the card reports `Applied`
without installing anything. Automatable cards: 62 -> 63.

The skill's interview section now carries the project owner's actual defaults instead of a neutral
list of questions:

- **Power scheme: change nothing.** Windows' Balanced scheme is right for almost everyone. The nine
  `power-scheme-*` cards are enthusiast presets - offer them only if the user raises the subject.
- **Browser: anything but Edge, in practice Chrome.** If the user has no preference, Chrome is the
  safe assumption. Installing a browser still does not make it the default; nothing can.
- **Search indexing: leave it alone.** Most people never think about it. The ones who do usually want
  Everything from voidtools, which is a `link` card - point at it rather than installing anything.
- **Personalization: always ask.** Taste does not generalise; present the list and apply what is
  picked.
- **Clipboard history: on, everywhere.** Not a preference in practice.

### Added

- Profiles can inherit. `Extends = 'privacy-baseline.psd1'` names a parent beside the file; the
  parent's cards run first, then the child's, and an id in both keeps its earliest position. Without
  it a second profile would have to copy fourteen ids and then drift from the file it copied them
  from, with nothing to notice.
- `Skill\Profiles\typical-machine.psd1` - the baseline plus Chrome and clipboard history. Silent
  about power scheme, indexing and personalization by design.
- Smoke follows the inheritance chain too: a renamed parent, a chain that loops, or one nested more
  than ten deep now fails a check instead of surfacing at the top of a setup session.

## 1.10.0

**The program can now be driven by an AI agent, without a window and without clicking anything.**

`Skill\audion-windows-tools.skill` is a contract written for *any* agent, not for one product. It
ships inside the program, so it travels with it to a fresh machine, and it resolves the program root
from its own folder rather than a hard-coded drive.

Its whole argument is the split the manifests already encode: 62 of the 308 cards are `registry`,
`service`, `feature`, `powerscheme` or `script` and the engine performs them; the other 246 open a
page or ask a person to do something, and the contract forbids automating those by driving the GUI.
Clicking blind through system dialogs has no `Detect` to verify it and no `Revert` to undo it - it is
strictly worse than the human doing it. Setting the default browser and file associations is called
out as impossible rather than hard: Windows protects `UserChoice` with a hash.

### Added

- `Engine\Invoke-TweakProfile.ps1` - the single tool the contract drives. `-Discover` lists every
  automatable card with its `admin` and `NO REVERT` flags; `-ProfilePath` reports what a profile's
  cards actually hold right now; `-Apply` changes only what is not already set, then re-reads `Detect`
  to confirm each one; `-Json` gives an agent something to parse. **Reporting is the default** - it
  changes nothing unless `-Apply` is passed. Cards with no `Revert` are skipped unless
  `-IncludeIrreversible` is given, so an unattended run cannot take a one-way step by accident.
  Exit codes: 0 nothing to do, 1 work pending, 2 a card failed, 3 could not load.
- `Skill\Profiles\privacy-baseline.psd1` - a starting profile of 14 cards that turn off what phones
  home and what runs uninvited. Every one is reversible, verifiable, and has a single sensible
  direction. Profiles are curated lists, not filters: many automatable cards are choices (which
  browser, which of nine power schemes) and several only open a folder for a human, so deciding what
  belongs is the point rather than an oversight. They load through the manifests' own reader and so
  cannot execute code.
- Smoke section 11 checks the profiles: each loads as a data file, declares a non-empty `Cards` list,
  and names only ids that exist and are automatable. A typo in a profile would otherwise surface only
  mid-run, after an agent had already reported progress.

Elevation belongs to the session, not to each card. The runner never raises a UAC prompt of its own:
a sixty-card profile driven by per-operation elevation would mean sixty prompts, which is worse than
useless. If `-Apply` is asked for in a session that lacks rights, it names the cards that need them
and stops with exit code 4 before touching anything, rather than walking the whole profile to mark
each one `skipped`. Reporting needs no rights and is unaffected, and a profile with no admin cards
still applies normally.

Verified end to end without elevation on a throwaway profile: report says `would-apply` and exits 1,
apply reports `applied` and exits 0, the next report says `already` and exits 0, revert returns the
card to `would-apply`, and no backup files are left behind. 31/31 checks pass on both PowerShell 7.6.4
and Windows PowerShell 5.1.

## 1.9.0

**First eight cards stop opening a Settings page and just do the thing.** Where a switch has exactly
one registry value behind it and only one sensible direction, opening the page and asking the user to
find the toggle was work the program could do itself.

Converted from `deeplink`/`button` to `registry`/`toggle`: Storage Sense, Clipboard History, Remote
Desktop, online speech recognition, location master switch, app diagnostics, Delivery Optimization,
Find My Device. Every target value was read off a live system first rather than taken from folklore.

They gain what a deeplink can never have: `Detect` reports the real state, so the card knows whether
it is already applied; `Revert` puts back exactly what was there, including deleting a value or a key
that did not exist before. The engine needed no change for this - `Set-RegValue` already creates a
missing key path, `Detect` already reads an absent key or value as `NotApplied` rather than as
`Unknown`, and the backup already records which of the three cases it found.

Four of them now declare `RequiresAdmin` truthfully: they write to `HKLM`, and previously said they
did not need elevation while pointing at a Settings page that did.

### Added

- `Initialize-TweakEngine` - the engine can now be driven without a window. `$script:AppRoot` was set
  only by `Start-TunerWindow` and by the two background runspaces, so a bare `Import-Module` left it
  `$null` and the first backup write died inside `Get-DataDir`. It takes an optional `-AppRoot`
  (falling back to the module's own parent, as `Start-TunerWindow` does) and an optional `-LineSink`
  for command output, which stays silent when not supplied. Verified end to end: apply, detect and
  revert round-trip on a scratch key, including the case where the key did not exist beforehand.
- Smoke check that the guides' printed metadata matches the manifests. Comparing ids alone could not
  see this change at all: a converted card keeps its id, so both guides would have gone on saying
  "opens a Settings page" for a card that now writes the value itself. `kind`, `control` and `source`
  are compared literally; the administrator and reboot phrases are localised, so their wording is
  learned from the guide itself using cards where exactly one of the two flags is set - which also
  catches a guide that words the same flag two different ways.

### Fixed

- Turning off a toggle that was already set before the program first saw it no longer looks broken.
  `Detect` reads the live system and `Invoke-TweakApply` deliberately skips an already-settled state,
  so no backup gets written — and `Invoke-TweakRevert` then had nothing to restore. It said so
  through `Write-Warning`, which reaches nowhere the user can see: the switch flipped, nothing
  happened, and the next status refresh flipped it back. It now explains itself in the output panel
  and reports the step as failed, so the checkmark stays honest. Converting cards to toggles made
  this reachable in ordinary use — an untouched machine can easily arrive with location already
  denied.

- `cleanup_project.cmd` stops calling `Data\backups` a cache. It is not one: nothing can rebuild
  those files, because each records what a setting held *before* a tweak was applied and that
  original value is already overwritten on the machine. Deleting them changes no setting - it removes
  the ability to undo. The banner now says that, and `/KEEPBACKUPS` (`--keep-backups`) skips the
  folder. Default behaviour is unchanged: a release archive should still ship with an empty backups
  folder, since nobody wants someone else's undo records.

  Worth knowing: cleanup is not something a person chooses to run. Audion Build Orchestrator invokes
  it as a pipeline stage - `release_manifest.json` records the path it calls - so every release build
  wipes the authoring copy's undo records as a side effect. That is what happened here on 2026-07-30
  at 07:33, thirteen minutes before the 1.8.0 archive was cut.

### Known

- Reverting a card whose value sat under several missing key levels removes the key it recorded but
  leaves the empty parents it created behind. Verified not to bite today: Delivery Optimization is
  the only shipped card whose key is absent on a normal system, and its parents
  (`SOFTWARE\Policies\Microsoft\Windows`) are standard Windows infrastructure that already exists.

### Verified

All eight converted cards were round-tripped on a live Windows 11 26200 system, elevated: read the
value, apply, confirm `Detect` flips to Applied and the value is what the card declares, revert, and
confirm the value is byte-identical to what it was beforehand. Delivery Optimization exercised the
key-absent path end to end - created on apply, gone again after revert, no orphaned parents. Location
was already denied on that machine, which is what surfaced the revert defect above.

## 1.8.0

**`Start.exe` is the entry point - the only one.** `Launch.bat` moved out of the root to
`Engine\Launch.bat` and is no longer presented as an alternative way in.

It is genuinely redundant: `Start.cs` resolves PowerShell in the same order the batch file did -
bundled portable 7, then system 7 on PATH, then Windows PowerShell 5.1 - with one extra fallback (the
explicit `System32\WindowsPowerShell\v1.0` path), a message box instead of a console `pause` when
nothing is found, and the GUI subsystem so no console flashes. It is also the relaunch target the
taskbar identity points at.

It was kept rather than deleted for the one case an executable cannot cover: Windows refusing to run
an unsigned local `.exe`. The guides now lead with unblocking the file in its properties and mention
`Engine\Launch.bat` only as a last resort; the READMEs name `Start.exe` and nothing else.

Its paths were rewritten for the new location and normalised with `%~fI`, so `APP_ROOT` carries no
`..` segment. PowerShell normalises `$PSScriptRoot` on its own, so this is hygiene rather than a
fixed defect - it keeps the working directory and the error text readable.

Smoke gained a check that `Start.exe` is a GUI-subsystem PE with `App.ps1` beside it - the launcher's
compile-time contract, whose breach otherwise shows up only as a message box at launch.

## 1.7.1

`Start.exe` is the launcher. Both READMEs and both user guides still offered
`ЗАПУСТИТЬ ПРОГРАММУ.cmd` as a fallback; that file no longer exists. The fallback is `Launch.bat`,
and the project tree no longer lists the removed file.

`App.ps1`'s header claimed "UTF-8 without BOM" while the file carries one - and the BOM is
load-bearing. Verified on both hosts: with it, the Russian elevation message survives; without it,
Windows PowerShell 5.1 decodes the file as ANSI and mangles the text while still parsing cleanly, so
nothing would have failed visibly. The header now says so and says why. The same applies to
`TweakEngine.psm1`, which also carries a BOM for its Russian labels.

Smoke gained the matching invariant - a BOM-less `.ps1`/`.psm1` must keep its string literals
ASCII-only - so "normalising" either file to BOM-less now fails a check instead of silently
corrupting user-visible text. The source-parse check also reaches `Engine\Launcher\` now, six files
instead of four.

## 1.7.0

**Project root cleaned up.** `MainWindow.xaml` and `Themes.psd1` now ship inside `Engine\`; the root
keeps only entry points, build scripts and folders the user actually opens.

Nothing in WPF required them to sit in the root - `XamlReader` reads a stream, and the markup carries
no `pack://` URIs, no `Source=` and no external resource dictionaries. What held them there was one
line in `Start-TunerWindow`:

    $script:AppRoot = Split-Path $XamlPath -Parent

`AppRoot` anchors `Data\`, `Manifests\`, `Strings\`, `Docs\`, `Assets\` and `Install\`, and it was
derived from whichever folder happened to hold the markup - so moving that one file would have
silently re-pointed everything else. `Start-TunerWindow` now takes an explicit `-AppRoot`, and falls
back to its own module location (`<root>\Engine`) rather than to a file path someone passed in.
`Load-Themes` resolves `Themes.psd1` from the module folder for the same reason: it no longer depends
on `AppRoot` having been set first.

Updated to match: `App.ps1`, `Engine\Launcher\Test-WindowIdentity.ps1`, `cleanup_project.cmd`,
`Tests\Smoke.ps1` and the project tree in both user guides. `release_manifest.json` was not touched -
it is generated by the build orchestrator. If that orchestrator's `build_map.json` lists files by
name rather than taking folders whole, it needs to learn the two new paths.

Smoke gained a check that `Engine\MainWindow.xaml` exists and is well-formed window markup - its
absence would otherwise surface only at launch, as a window that never appears.

Classified MINOR: the bundle's entry points are unchanged and nothing outside it references either
path. Read strictly, "package layout" in `AGENTS.md` would argue for MAJOR.

## 1.6.1

Tooltips now wait 1200 ms before appearing, up from WPF's 1000 ms default and from the 250 ms the
card help used. `BetweenShowDelay` was raised to match: at its previous value of 0 the first tooltip
unlocked the rest, so sweeping the pointer down a column of cards popped help on every one and the
delay was never actually felt.

The timing lives in one place, `$script:TooltipInitialShowDelayMs` in `Engine\TweakEngine.psm1`.
`Initialize-TooltipTiming` installs it on the `FrameworkElement` metadata before the XAML is parsed,
so it also reaches the tooltips declared directly in `MainWindow.xaml` - neither that file nor
`Themes.psd1` carries any tooltip timing. An element that sets its own value still wins.

## 1.6.0

**Reliability and speed of the status refresh, plus the first automated checks.**

### Added

- `Tests\Smoke.ps1` - development-side pre-release checks. Not shipped behaviour: the app never
  calls into `Tests\`. Covers manifest loading, card metadata, link validity, ru/en string parity,
  string keys actually referenced by code, theme and version files, the "a manifest cannot execute
  code" guarantee, and (with `-Full`) the execution time of every `Detect` block. `-CrossHost`
  re-runs everything under the other PowerShell so 7 and 5.1 are proven to agree rather than assumed
  to. These are the checks that were previously repeated by hand after every change.
- `CHANGELOG.md` - `AGENTS.md` required one and the project did not have it; 1.3.0 through 1.5.1 are
  backfilled below from the change sets themselves.
- Declining the UAC prompt now explains itself. `App.ps1` self-elevates unconditionally, and a
  declined prompt made `Start-Process -Verb RunAs` throw; with the console hidden the app died in
  complete silence. It now shows a short bilingual message saying administrator rights are required
  and nothing was changed.

### Changed

- Package detection asks the registry first and winget second. The two answers are OR-ed, so the
  order cannot change the verdict - only its cost. An ARP hit is tens of milliseconds against
  winget's seconds, and the registry also sees per-user installs that winget's source correlation
  misses.
- One `winget list` now answers every package question instead of one call per package. The full
  listing costs about the same as a single filtered query and is parsed from memory afterwards.
  Verified on winget 1.29: redirected output is not column-truncated, so matching an exact id token
  against the full listing is as reliable as `--id ... --exact`.
- The listing is cached in `Data\winget-list.cache` for 10 minutes. Each status refresh runs in a
  fresh runspace, so an in-memory cache alone was discarded on every subsection switch. Measured on
  the browser subsection: 8829 ms on first view, 209 ms on every later one, with identical results.
  Installing, upgrading or removing anything drops the cache, and so does the Refresh button - it
  means "ask the machine again", not "re-read the cache".
- Uninstall-registry entries are enumerated once per runspace instead of once per lookup.
- Brave, Firefox, Vivaldi and Opera cards gained registry name patterns for `Detect`, so they take
  the fast path. `Apply` deliberately did not get them: an "already present" short-circuit there
  would stop these browsers from ever being upgraded.

### Fixed

- A script card without its own `Detect` no longer earns a checkmark when its step failed. The
  "applied" mark used to be written unconditionally after the block ran, so it meant "the button was
  pressed", not "this succeeded". Steps can now report failure (`Set-TweakStepFailed`), and every
  winget path does.
- `RequiresAdmin` was declared throughout the manifests and read by nothing. `Invoke-TweakApply` now
  honours it. This adds no prompt and never fires in normal use, because the whole window is already
  elevated; it exists so a session that somehow lost elevation says so plainly instead of failing as
  an obscure access-denied.
- A failed service revert was silent *and* still deleted the backup, destroying the only record of
  the original startup type. It now reports the failure and keeps the backup so a retry is possible.
- The confirmation read after enabling or disabling a Windows optional feature is no longer dropped
  silently when it fails - it was the only proof the change landed.
- `Strings\ru.psd1` and `Strings\en.psd1` had picked up a UTF-8 BOM, against the project standard and
  in exactly the direction that had previously broken loading under 5.1. Found by the new checks on
  their first run.

---

## 1.5.1

Added a Visual C++ All-in-One card pointing at `abbodi1406/vcredist` releases as an alternative to
the existing TechPowerUp link - same full package, with checksums and an open version history.

## 1.5.0

Added "Download page" buttons next to Apply on install cards (Brave, Firefox, Vivaldi, Opera,
WebView2 Runtime, portable PowerShell 7), for when an install fails or the vendor's own installer is
preferred. Visual C++ and Intel DSA were left without one on purpose: separate link cards for their
official pages already sit in the same subsection.

## 1.4.0

The app now genuinely runs on Windows PowerShell 5.1. The launcher always claimed 5.1 as a fallback,
but that path failed while reading the manifests, for two independent reasons: the files are UTF-8
without a BOM, which 5.1 decodes as ANSI, and `Import-PowerShellDataFile` refuses a data file with
more than 500 key/value pairs. `Import-TweakDataFile` replaces it - reading as UTF-8 explicitly,
verifying that the file is exactly one hashtable literal, and only then evaluating it. Side benefit:
loading a manifest can no longer execute code, which the old loader allowed.

## 1.3.0

Audit and rework of every install card, prompted by the WebView2 card hanging forever on
"Installing".

Three compounding defects: winget cannot see components Windows marks `SystemComponent=1`, so
`Detect` was permanently wrong and every click re-downloaded about 170 MB to achieve nothing; the app
hides its console but ran installers through the PowerShell pipeline, so any prompt blocked on stdin
invisibly and forever; and nothing enforced a timeout, while Cancel could not interrupt a native
child process at all.

Installers now run through `Invoke-NativeProcess`, which closes stdin immediately, decodes the
console code page, enforces a 15-minute ceiling and kills the whole process tree on cancel. Install
cards check the registry as a second opinion, interpret winget's exit codes in plain language, and
always end on an explicit verdict line - including "already present" and "did not work". The USB
device power-saving card gained a real `Detect` (5265 ms -> 119 ms), honest before/after reporting, a
working Revert, and a title that admits it affects every power-manageable device, not only serial
ports.

---

## Before 1.3.0

Not recorded here. 1.2.4 is the baseline this file starts from.
