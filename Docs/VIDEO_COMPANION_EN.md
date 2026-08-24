# Companion to the Max.mov Guide

The project started from Max.mov's video “Complete Windows 11 Guide. The Truth About Optimization.” It preserves the recognizable sections and practical logic, but it is not an exact storyboard of the video.

## What Matches

- data and installation-media preparation;
- drivers, disks, browsers, and core Windows settings;
- monitor, GPU, cooling, games, peripherals, and result measurement;
- the principle of understanding an action before applying it;
- caution around universal presets and instant-optimization claims.

## What the App Adds

- one PowerShell GUI instead of navigation through many windows and folders;
- cards with descriptions, instructions, source labels, and current state;
- selective and ordered execution, a log, and a terminal;
- backups and rollback where the original state can be restored reliably;
- manual To Do items for BIOS, setup, and physical verification;
- cleanup of local marks and backups before configuring another machine;
- separate Audion workflows, including some installation paths through `winget`.

## Reading the Labels

`official` means that the action uses a documented mechanism from Microsoft, the hardware vendor, or the target product's author. The primary Windows route is built from these mechanisms. The label does not mean that an action is mandatory or equally useful on every PC.

`Max.mov guide` means that the specific step or recommendation is definitely present in the Max.mov guide. It records correspondence with the video rather than approval of the software implementation.

`Max.mov approved` means that the specific recommendation or implementation was separately and explicitly approved by Max.mov. This stronger label is never inferred merely from an appearance in the video.

Both editorial labels are independent of mechanism provenance: a card may also be `official` or `unofficial`.

`unofficial` means a practical workaround, experimental parameter, community method, or setting not established in official documentation. For a Windows tweak, it explicitly means that Microsoft does not document the method. These cards remain useful alternatives but may become obsolete after updates.

## Using It with the Video

The video provides context and explains cause and effect. The app turns the material into an operational route: the user selects a card, reads it carefully, and performs only actions relevant to the current system. The interface is therefore a companion and remix, not a replacement for the author's explanation.

The current version does not claim unimplemented DevOps extensions. They should enter the documentation only after corresponding cards exist in the manifests.
