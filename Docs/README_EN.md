# Audion Windows Tools by Max.mov

<!-- audion:release -->
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0b6db8?style=flat-square&logo=windows&logoColor=white)](https://audion.dev/downloads/windows-tools-by-max.mov) [![Release](https://img.shields.io/github/v/release/Tensionix/audion-windows-tools-by-max.mov?style=flat-square&label=release&color=e08a63)](https://github.com/Tensionix/audion-windows-tools-by-max.mov/releases/latest) [![Downloads](https://img.shields.io/github/downloads/Tensionix/audion-windows-tools-by-max.mov/total?style=flat-square&label=downloads&color=5fd08a)](https://github.com/Tensionix/audion-windows-tools-by-max.mov/releases) [![License](https://img.shields.io/github/license/Tensionix/audion-windows-tools-by-max.mov?style=flat-square&color=5fd08a&logo=apache&logoColor=white&cacheSeconds=3600)](https://github.com/Tensionix/audion-windows-tools-by-max.mov/blob/main/LICENSE)

**Version 1.11.1** · 2026-08-24 · 131.1 MB

- [Direct download](https://audion.dev/get/windows-tools-by-max.mov/1.11.1/Audion_Windows_Tools_by_Max.mov_v1.11.1_Full.zip) — unmetered, no rate limits
- [Project page](https://audion.dev/downloads/windows-tools-by-max.mov) — every version and how to install

`SHA-256: c11aa26c59dbb4be6bc1d671a0170aec897dd3d4afece4bf66d5306874f91ba3`
<!-- /audion:release -->

Audion Windows Tools by Max.mov is an interactive companion to Max.mov's long-form Windows guide and an independent workstation setup assistant. It is not a line-by-line copy of the [seven-hour video](https://www.youtube.com/watch?v=ITdecD6R0Yw): the recognizable route is extended with state detection, rollback, automation, and original practical workflows.

## Purpose

The project does not apply every tweak automatically. It organizes trusted actions, opens the required Windows surfaces or external utilities, runs supported commands, and records what the operator should verify. A non-specialist can follow most of the route through cards without hunting for each Windows page, but must read the description before pressing a button.

## Source Priority

- Built-in Windows capabilities and Microsoft recommendations come first.
- `official` means a documented or supported route from Microsoft, the hardware vendor, or the target product's author. It does not mean that every setting is appropriate for every PC.
- `Max.mov guide` means that the specific step or recommendation is definitely present in the Max.mov guide. It does not mean that this card implementation was separately approved.
- `Max.mov approved` is reserved for a recommendation or implementation that Max.mov explicitly approved separately.
- `unofficial` preserves useful workarounds, experimental settings, and community practice while keeping them visibly separate from the official layer. For Windows tweaks it also warns that Microsoft does not document the mechanism and it may change after an update.
- Audion extensions are not presented as exact quotations from the video. See `VIDEO_COMPANION_EN.md` for a concise map of differences.

## Quick Start

1. Double-click `Start.exe` - it is the only entry point.
2. Select the required setup section.
3. Read the card description and risk note.
4. Run or open one action at a time.
5. Confirm the result before continuing to the next section.
6. Restart Windows when the selected procedure requires it.

The launcher prefers the portable PowerShell 7 inside the project, then system PowerShell 7, and falls back to the Windows PowerShell 5.1 included with Windows. PowerShell 7 is recommended for a fully self-contained toolkit, but it is not required for the first launch.

Use administrator rights only for actions that actually require elevation. Keep backups before disk, boot, registry, driver, or system-policy changes.

## Main Sections

- Windows installation preparation.
- Drivers and operating-system updates.
- Disk initialization and layout.
- Browser setup.
- Windows settings and privacy controls.
- GPU and monitor configuration.
- Cooling and fan setup.
- Steam and game launchers.
- Optional timer-resolution controls.
- FPS and latency checks.
- Recommended applications.
- Mouse and keyboard configuration.
- Max.mov tuning profiles.

## Interface

Cards may run a command, open a Windows settings page, open a folder or URL, start an external utility, or display a manual checklist. The action type and required privileges should be visible before execution. A button opening documentation is not equivalent to an automatic system modification.

## Safety

- Create a restore point or system image before broad tuning.
- Verify downloads and installers before running them.
- Do not apply registry or boot changes without understanding rollback.
- Treat disk cleanup, partitioning, firmware, and driver removal as high-risk operations.
- Avoid stacking multiple latency or timer tools without measurement.
- Keep recovery media and important data separate from the tuned workstation.

## Documentation

Detailed descriptions of every section and card are in `USER_GUIDE_EN.md` and `USER_GUIDE_RU.md`. The canonical Markdown pair is the maintained source; generated PDFs are optional release artifacts and are not stored in `Docs\PDF`.

Apply changes incrementally and keep a rollback path. The project organizes procedures; the operator remains responsible for validating hardware, Windows edition, and policy compatibility.

The interface map and declarative configuration are documentation sources for available sections, cards, actions, defaults, warnings, and command bindings. The user guide converts that catalogue into an ordered maintenance strategy with validation and rollback checkpoints.

The current version already contains a few installation paths through `winget`. Planned DevOps-derived extensions are not treated as implemented until matching cards exist in the manifests.
