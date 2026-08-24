# Audion Windows Tools by Max.mov

WPF interface for configuring Windows 11 after a clean install. It is an interactive companion-remix of [Max.mov's guide](https://www.youtube.com/watch?v=ITdecD6R0Yw), not a line-by-line visualizer. The app builds 13 sections from `Manifests\Section##.psd1`, renders action cards, and uses the shared `Engine\TweakEngine.psm1` engine.

Microsoft recommendations and built-in Windows mechanisms have priority. `official` cards use documented sources from Microsoft, the hardware vendor, or the product author; `Max.mov guide` marks steps that definitely appear in the Max.mov guide; `Max.mov approved` is used only for a recommendation or implementation that was separately and explicitly approved; `unofficial` preserves alternative and experimental solutions without presenting them as the official path. See `VIDEO_COMPANION_EN.md` for the exact positioning relative to the video.

## Quick Start

Double-click `Start.exe` in the project root. It is the single entry point: it resolves PowerShell itself and gives the window its own taskbar icon.

If Windows refuses to run the unsigned local executable, clear the block in the file's properties (right-click - Properties - Unblock). As a last resort the bundle carries `Engine\Launch.bat`, which resolves PowerShell the same way without the executable. It is a fallback, not a second way in.

PowerShell lookup order:
1. `Engine\PowerShell\pwsh.exe` — bundled portable PowerShell 7.
2. System `pwsh.exe` from `PATH` — fallback.
3. Windows `powershell.exe` 5.1 — offline fallback for the first launch.
4. For a fully portable toolkit, run `Install\Install-Portable-PowerShell.cmd` or use the in-app installation button.

App.ps1 relaunches itself in STA mode and elevated mode, imports the engine, loads all manifests, and opens the WPF window.

`Engine\WindowIdentity.psm1` assigns the explicit WPF icon, small and large Win32 window icons, an `AppUserModelID`, and relaunch properties that point to `Start.exe`. This makes the taskbar show the application icon instead of the PowerShell process icon.

## Interface Buttons

- Apply - runs Apply for the current subsection. If right-side selection checkboxes are set, only selected tweaks run; if nothing is selected, the whole subsection runs.
- Revert - runs Revert for the current subsection or selected tweaks.
- Refresh - reruns Detect for visible cards and redraws status.
- Clear data - deletes JSON backups from `Data\backups\` next to the app, clears the log, and resets local done marks. Application state is portable and is never written to %LOCALAPPDATA%.
- DOCS - opens the complete `Docs` directory: user guides, technical README files, video companion notes, and the remaining project documentation. The application does not choose a specific file for the user.
- Install PowerShell - runs Install\Install-Portable-PowerShell.cmd in a separate elevated cmd.exe; the installer downloads the latest x64 PowerShell ZIP from GitHub and places it in Engine\PowerShell\.
- EN/RU - switches UI language, including section and card labels.
- Log - shows or hides the right-side log panel.
- Terminal - shows or hides the embedded PowerShell terminal; typed commands execute locally in a separate runspace.

## Card And Action Types

- link - opens an external URL in the default browser.
- deeplink - opens an ms-settings:, microsoft-edge:, or shell: URI.
- manual - manual checklist without automatic system changes.
- registry - writes a registry value and stores the previous state in a JSON backup.
- script - runs a PowerShell scriptblock from the manifest; may define Apply, Revert, and Detect.
- service - changes a Windows service through Set-Service, Start-Service, Stop-Service.
- feature - enables or disables an optional feature through Enable/Disable-WindowsOptionalFeature.
- powerscheme - imports a .pow file through powercfg -import, activates it through powercfg -setactive.

Manifest statistics: 13 sections, 69 subsections, 308 cards. Kinds: deeplink=64, docs=1, feature=1, link=118, manual=71, powerscheme=9, registry=10, script=33, service=1. Controls: button=217, checklist=71, toggle=20.

## Project Layout

```text
Audion Windows Tools by Max.mov/
├── Start.exe
├── App.ps1
├── CHANGELOG.md                    # version history
├── Assets/
│   ├── MaxMovLauncher.png / .ico  # source and multi-size launcher icon
│   ├── PowerSchemes/               # .pow files used by Section04
│   └── Scripts/                    # local PowerShell scripts
├── Engine/
│   ├── Launcher/                   # source and repeatable Start.exe build
│   ├── WindowIdentity.psm1         # window/taskbar icon and AppUserModelID
│   ├── TweakEngine.psm1
│   ├── MainWindow.xaml             # window markup
│   ├── Themes.psd1                 # interface themes
│   ├── Launch.bat                  # fallback start, if Windows blocks Start.exe
│   ├── Invoke-TweakProfile.ps1     # profile runner: the engine without a window, for agents
│   └── PowerShell/                 # portable PowerShell, created by installer
├── Skill/
│   ├── audion-windows-tools.skill  # AI-agent contract: what to do, what to ask about
│   └── Profiles/                   # curated card lists for the runner
├── Install/
│   └── Install-Portable-PowerShell.cmd
├── Manifests/
│   └── Section##.psd1
├── Strings/
│   ├── en.psd1
│   └── ru.psd1
├── Docs/
│   ├── README_RU.md / README_EN.md
│   ├── USER_GUIDE_RU.md / USER_GUIDE_EN.md
│   └── VIDEO_COMPANION_RU.md / VIDEO_COMPANION_EN.md
├── Tests/
│   └── Smoke.ps1                   # pre-release checks; the app never calls into this folder
├── Data/                           # portable state: backups, language, theme, panel layout
└── config/version.json
```

## Complete Section And Function Map

Every section, subsection, and card is listed below. Each card includes id, action kind, control type, source, requirements, description, and the concrete action: URL/page opening, registry write, command/script call, power scheme import, service control, or manual checklist.

### 0. Windows Installation

10 subsections, 45 cards. Source: `Manifests\Section00.psd1`.

#### 0.0 Data & Passwords

- **Install portable PowerShell 7 for this toolkit** (id=`install-portable-powershell7`; kind=`script`; control=`button`; source=`official`; tone=`sand`; requires admin)
  - Description: Downloads and installs portable PowerShell 7 into Engine\PowerShell. This keeps the toolkit stable and self-contained while configuring Windows, even on a fresh system without system pwsh.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: yes. Key command: `Install\Install-Portable-PowerShell.cmd /NOPAUSE`.
  - Note: Runs the installer and writes its log to the Terminal panel.
- **Project documentation** (id=`program-guide-readme-pdf`; kind=`docs`; control=`button`; source=`official`; tone=`sand`)
  - Description: The folder contains the user guides, technical README files, video companion notes, and the remaining maintained project documents.
  - Action: Opens the `Docs` folder without choosing a specific file for the user.
- **Rename disks to their drive letters** (id=`rename-drives`; kind=`deeplink`; control=`button`; source=`official`; requires admin)
  - Description: Open Disk Management to verify and rename your partitions before reinstalling. Helps identify disks correctly after the fresh install.
  - Action: Opens a Windows Settings, Edge, or shell URI: `diskmgmt.msc`
  - Instruction: Open Disk Management. Right-click each volume and rename it to match its drive letter (e.g. "C", "D"). This makes it easier to identify partitions during installation.
- **Back up your data** (id=`check-data-backup`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open File Explorer and verify that all important files are backed up to an external drive or cloud storage before reinstalling Windows.
  - Action: Opens a Windows Settings, Edge, or shell URI: `shell:ThisPCFolder`
  - Instruction: Check all drives for documents, downloads, desktop files, and any other data you want to keep. Copy them to an external drive or cloud storage.
- **Export browser passwords** (id=`check-browser-passwords`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Export your saved passwords from Chrome before reinstalling. Navigate to chrome://settings/passwords and use the export option.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open Chrome and go to chrome://settings/passwords. Click the three-dot menu next to "Saved passwords" and choose "Export passwords". Save the file to a backup location.
- **Verify account access (Microsoft, Steam, etc.)** (id=`check-account-access`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Make sure you can log in to all important accounts — Microsoft, Steam, Epic Games, etc. — before reinstalling. Note down passwords or recovery options.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Test logins for: Microsoft/Xbox account, Steam, Epic Games, EA App, and any other services you use. If 2FA is involved, confirm your authenticator app works. Write down recovery codes if needed.

#### 0.1 GPU Driver Preparation

- **Laptop note: download drivers for BOTH GPU and iGPU** (id=`laptop-igpu-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: On most laptops the display is wired to the integrated GPU (iGPU), not the discrete GPU. Do NOT disable the iGPU. Download drivers for both the integrated and discrete graphics adapters.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: On a laptop with dual GPUs (e.g. Intel UHD + RTX 3050): download the driver for Intel UHD (iGPU) AND the Nvidia/AMD driver for the discrete GPU. Never disable the iGPU on a laptop — the built-in display is connected through it.
- **Find your GPU model** (id=`find-gpu-model`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Device Manager to check the exact model of your graphics card before downloading the driver.
  - Action: Opens a Windows Settings, Edge, or shell URI: `devmgmt.msc`
  - Instruction: Expand "Display adapters" in Device Manager to find your GPU model name.
- **Download Nvidia GPU driver** (id=`download-nvidia-driver-prep`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Nvidia driver download page. Download the latest Game Ready Driver for your GPU model.
  - Action: Opens an external URL in the default browser: `https://www.nvidia.com/en-us/drivers/`
- **Download AMD GPU driver** (id=`download-amd-driver-prep`; kind=`link`; control=`button`; source=`official`)
  - Description: Official AMD driver download page. Download the latest Adrenalin driver for your GPU.
  - Action: Opens an external URL in the default browser: `https://www.amd.com/en/support/download/drivers.html`
- **Download Intel GPU / Arc driver (unavailable from Russian IPs)** (id=`download-intel-gpu-driver-prep`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Intel driver download center. Download the Intel graphics driver for your iGPU or Arc GPU.
  - Action: Opens an external URL in the default browser: `https://www.intel.com/content/www/us/en/download-center/home.html`
- **Move driver installers to a USB drive or separate partition** (id=`move-drivers-to-usb`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: After downloading GPU drivers, copy the installer files to a USB drive or a non-system partition so they are accessible immediately after Windows reinstall, before connecting to the internet.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Copy the downloaded driver installer (.exe) files to a USB flash drive or a secondary drive/partition (e.g. D:). This ensures you can install drivers before going online on the fresh Windows installation.

#### 0.2 Chipset & Network Drivers

- **Intel VMD / RST note: disks may not appear during install** (id=`intel-vmd-rst-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: If your SSD does not appear in the Windows installer disk selection screen, disable the Intel VMD controller in BIOS before installing. Alternatively, load the Intel RST driver during setup. See instruction for details.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: If disks are missing during Windows setup: Option A — Disable Intel VMD in BIOS (NVMe RAID / Intel RST setting) before installing. Option B — Extract RST driver from SetupRST.exe using: ./SetupRST.exe -extractdrivers SetupRST_extracted, then copy the extracted folder to a USB drive and load it via "Load Driver" during setup. Intel chipset drivers for modern Intel platforms are delivered via Windows Update automatically after first internet connection.
- **Download AMD chipset driver** (id=`download-amd-chipset`; kind=`link`; control=`button`; source=`official`)
  - Description: Official AMD driver page. Chipset drivers for AMD platforms are available here.
  - Action: Opens an external URL in the default browser: `https://www.amd.com/en/support/download/drivers.html`
- **Download Intel chipset INF driver (older chipsets only, unavailable from Russian IPs)** (id=`download-intel-chipset-old`; kind=`link`; control=`button`; source=`official`)
  - Description: Intel chipset INF utility for older Intel platforms. Modern Intel chipsets receive updates exclusively via Windows Update.
  - Action: Opens an external URL in the default browser: `https://www.intel.com/content/www/us/en/download/19347/chipset-inf-utility.html`
- **Download Intel RST driver (unavailable from Russian IPs)** (id=`download-intel-rst`; kind=`link`; control=`button`; source=`official`)
  - Description: Intel Rapid Storage Technology driver. Required only if your SSD is not detected during Windows setup and you need VMD/RST support.
  - Action: Opens an external URL in the default browser: `https://www.intel.com/content/www/us/en/search.html?ws=text#sort=relevancy&layout=table&f:downloadtype=[Drivers]&f:@operatingsystem_en=[Windows%2011%20Family*]&f:@tabfilter=[Downloads]&f:@stm_10385_en=[Memory%20and%20Storage]`
- **Download drivers from motherboard manufacturer website** (id=`motherboard-support-page`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Visit your motherboard manufacturer support page (ASUS, MSI, Gigabyte, ASRock) to download the latest chipset and LAN drivers for your specific board model.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Search for your motherboard model on the manufacturer website (e.g. asus.com/support, msi.com/support). Download: (1) chipset driver, (2) LAN/Wi-Fi driver. Copy them to your USB drive along with GPU drivers.
- **Broadcom / Realtek / Intel Killer network drivers (other manufacturers)** (id=`network-other-manufacturers`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: If your network adapter is from Broadcom, Realtek, or Intel Killer and is not recognized after install, search for the driver on the manufacturer website or use the motherboard support page.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: If Windows Update does not install your LAN/Wi-Fi driver automatically, download it from: Realtek — realtek.com, Broadcom — broadcom.com, Intel Killer — killer.intel.com. Or search for it by adapter model in Device Manager.

#### 0.3 Create Installation Media

- **Download Windows 11 Installation Media (Media Creation Tool, unavailable from Russian IPs)** (id=`download-win11-mct`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Microsoft page to download the Windows 11 Media Creation Tool, which creates a bootable USB installation drive automatically.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/en-us/software-download/windows11`
- **Download official Windows 11 ISO image (unavailable from Russian IPs)** (id=`download-win11-iso-official`; kind=`link`; control=`button`; source=`official`)
  - Description: Direct ISO download from Microsoft for use with Rufus or manual installation without a USB drive. May be unavailable from Russian IP addresses.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/en-us/software-download/windows11`
- **Download Windows 11 images via UUP Dump (available from Russia)** (id=`download-win11-uup-dump`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Alternative source for Windows 11 ISO images including those built via UUP Dump. Available from Russian IP addresses.
  - Action: Opens an external URL in the default browser: `https://www.comss.ru/list.php?c=windows10_update`
- **Download Rufus (bootable USB creator)** (id=`download-rufus`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Rufus creates bootable USB installation drives from ISO images. Use it to write the Windows 11 ISO onto a USB flash drive (8GB+ recommended).
  - Action: Opens an external URL in the default browser: `https://github.com/pbatard/rufus/releases`
- **Create bootable USB installation drive** (id=`create-usb-drive`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use Rufus to write the Windows 11 ISO to a USB flash drive. In Rufus, select the ISO file, choose the target USB drive, and click Start. Use GPT partition scheme for UEFI systems.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: 1. Open Rufus. 2. Select your USB drive (8GB+). 3. Click "SELECT" and choose the Windows 11 ISO. 4. Partition scheme: GPT. Target system: UEFI (non-CSM). 5. File system: NTFS. 6. Click START. Wait for completion. The USB drive is now bootable.

#### 0.4 Install Without USB (Optional)

- **Note: not recommended if switching from Legacy to UEFI** (id=`no-usb-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Installing without a USB drive by creating a temporary 12GB partition works on most systems, but may not be suitable if you are also switching from Legacy BIOS to UEFI boot mode.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: If you are switching from Legacy/MBR to UEFI/GPT, use a USB drive instead. This method is best for a clean reinstall on an already-UEFI system.
- **Open Disk Management to create the install partition** (id=`open-disk-management-partition`; kind=`deeplink`; control=`button`; source=`official`; requires admin)
  - Description: Open Disk Management to shrink the system drive by 12288 MB and create a new simple volume for the Windows installation files.
  - Action: Opens a Windows Settings, Edge, or shell URI: `diskmgmt.msc`
  - Instruction: 1. Right-click the system drive (C:) → Shrink Volume. 2. Enter 12288 MB to shrink. 3. After shrink, right-click the new unallocated space → New Simple Volume. 4. Format as NTFS, label it "Win11". 5. If the shrink fails, see the troubleshooting note below.
- **Troubleshoot: cannot shrink volume (USN journal / pagefile)** (id=`no-usb-shrink-errors`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: If Disk Management cannot shrink the volume, the USN journal or pagefile may be blocking it. Common errors: $Extend\$UsnJrnl (delete journal), pagefile.sys (disable pagefile), $Mft::$BITMAP (use a different drive or method).
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: To delete USN journal, open an elevated CMD and run: fsutil usn deletejournal /D C: — then recreate with: fsutil usn createjournal m=0 a=0 C:. To disable pagefile: System Properties → Advanced → Performance Settings → Advanced → Virtual Memory → No paging file. To disable System Protection: System Properties → System Protection → select C: → Configure → Disable. If $Mft::$BITMAP appears, use a different disk or installation method.
- **Check Event Viewer if shrink fails** (id=`open-event-viewer-shrink`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: If Disk Management refuses to shrink the volume and gives no clear reason, Event Viewer may show which file is blocking the operation.
  - Action: Opens a Windows Settings, Edge, or shell URI: `eventvwr.msc`
  - Instruction: In Event Viewer → Windows Logs → Application, look for events from source "defrag" around the time of the failed shrink attempt. The event text will show the file that is preventing the shrink.
- **No-USB install: CMD method (copy ISO files to Win11 partition)** (id=`no-usb-cmd-method`; kind=`manual`; control=`checklist`; source=`official`; requires reboot)
  - Description: Download the Windows 11 ISO, mount it in File Explorer (double-click), and copy all files to the 12GB Win11 partition. Then boot into it via Restart / Advanced Startup.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: 1. Download the Windows 11 ISO. 2. Double-click the ISO to mount it as a drive letter. 3. Copy ALL files from the mounted ISO to the Win11 partition (12GB). 4. To boot into it: open Restart advanced startup options. Alternatively reboot — most motherboards will detect and boot the Win11 partition automatically.
- **Download EasyBCD (no-USB method 2)** (id=`download-easybcd`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: EasyBCD adds a boot entry pointing to the Windows 11 installer WIM file on the Win11 partition, so the PC boots into the installer at next restart without a USB drive.
  - Action: Opens an external URL in the default browser: `https://neosmart.net/EasyBCD/`
- **No-USB install: EasyBCD method** (id=`no-usb-easybcd-method`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin; requires reboot)
  - Description: Use EasyBCD to add a WinPE boot entry pointing to boot.wim in the Win11 partition. On next reboot, select the NST entry to launch the Windows 11 installer.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: 1. Download the ISO, mount it, copy all files to the Win11 partition. 2. In the Win11 partition, navigate to sources\ and copy the path to boot.wim. 3. Open EasyBCD → Add New Entry → WinPE tab. 4. Paste the path to boot.wim in the Path field. Click the + button. 5. Save and reboot. Select the NST entry in the boot menu to start the installer.

#### 0.5 Move Max.mov Archive to USB / Other Drive

- **Move the Audion Windows Tools by Max.mov archive and drivers to a USB or separate drive** (id=`move-archive-reminder`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Before reinstalling Windows, ensure the Audion Windows Tools by Max.mov folder and all downloaded driver installers are saved on a USB drive or a non-system partition (e.g. D:). They will be wiped if left on C:.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Copy the entire "Audion Windows Tools by Max.mov" folder and all driver installers to a USB flash drive or a secondary disk partition (NOT C:). Confirm they are accessible before proceeding with the Windows installation.

#### 0.6 BIOS Settings

- **AMD note: virtualization may be called SVM or AMD-V** (id=`bios-amd-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: On AMD systems, the virtualization setting is typically labeled SVM, SVM Mode, or AMD-V instead of Intel VT-x. Disable it to disable VBS / Defender Core Isolation if desired.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS, search for: SVM Mode, SVM, or AMD-V. This is the AMD equivalent of Intel VT-x virtualization. Disable it only if you do not use virtual machines, to allow disabling Windows VBS security features.
- **Disable manufacturer preinstalled software (MSI Center, ASUS Armoury Crate, etc.)** (id=`bios-disable-preinstalled-software`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Some motherboard manufacturers pre-install bloatware via BIOS (MSI Center, ASUS Armoury Crate). Disable this in BIOS before installing Windows to avoid unwanted software being installed automatically.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS, look for settings related to "APP Center Download & Install", "Armoury Crate", "MSI Center", or similar. Disable them to prevent automatic installation of manufacturer software on the fresh Windows install.
- **Disable CSM Support and enable Secure Boot** (id=`bios-csm-secureboot`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Windows 11 requires UEFI with Secure Boot enabled. Disable CSM (Compatibility Support Module) fully and set Secure Boot to Enabled. Required for proper UEFI installation.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS: (1) Find CSM (Compatibility Support Module) and set it to Disabled. (2) Find Secure Boot and set it to Enabled. If Secure Boot cannot be enabled while CSM is on, disable CSM first, then enable Secure Boot. Save and reboot to confirm UEFI mode is active.
- **Enable TPM 2.0 (Intel PTT, AMD fTPM, or physical TPM module)** (id=`bios-tpm`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Windows 11 requires TPM 2.0. Enable it in BIOS — Intel calls it "Intel PTT", AMD calls it "AMD fTPM". Physical TPM modules also work.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS, find: Intel Platform Trust Technology (PTT) — set to Enabled, or AMD fTPM — set to Enabled. If you have a physical TPM module installed, enable "Discrete TPM" instead. Confirm TPM 2.0 is active in Windows via Win+R → tpm.msc after install.
- **Disable unused devices (audio, iGPU if not needed) — desktop only** (id=`bios-disable-unused-devices`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: On desktop PCs, you can disable unused integrated devices (onboard audio, iGPU) in BIOS to reduce system load and potential driver conflicts. Not recommended for laptops.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS (desktop only): consider disabling Onboard Audio if you use a dedicated sound card, and disabling iGPU if you exclusively use a dedicated GPU and the display is not connected to integrated outputs. Do NOT disable iGPU on a laptop — the display depends on it.
- **Disable virtualization (if not needed) — disables VBS** (id=`bios-disable-virtualization`; kind=`manual`; control=`checklist`; source=`unofficial`)
  - Description: Disabling CPU virtualization (Intel VT-x / AMD SVM) in BIOS prevents Windows from enabling Virtualization Based Security (VBS), which has a minor performance impact on games. Only disable if you do not use VMs or WSL2.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS, find: Intel Virtualization Technology (VT-x) or AMD SVM Mode. Set to Disabled. This prevents Windows Defender Credential Guard and Core Isolation from using VBS, which can slightly improve game performance. Note: disabling this makes WSL2 and Hyper-V unavailable.
- **Disable unused drives in BIOS (if supported)** (id=`bios-disable-extra-drives`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: If your BIOS supports disabling individual storage devices programmatically, disable drives you will not use during installation to simplify the disk selection screen.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS → Storage configuration, disable any drives that are not involved in the Windows installation (e.g. secondary data drives). This prevents accidentally selecting the wrong disk during setup. Re-enable them after installation is complete.
- **Enable PWM mode for 4-pin fans** (id=`bios-pwm-fans`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Set 4-pin fan headers to PWM mode (not DC/Voltage) in BIOS to allow proper RPM control by the cooling system. Required for accurate fan curve control.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In BIOS → Hardware Monitor / Fan Control, set each 4-pin fan connector to PWM mode. In DC mode, fan speed is controlled by voltage and is less precise. PWM mode allows exact RPM control via duty cycle.

#### 0.7 Important Notes Before Installation

- **If PC reboots back to setup instead of OOBE — read this** (id=`oobe-loop-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: After installation completes and reboots, some motherboards (especially MSI) fail to switch boot priority to the new Windows partition and loop back to the installer. Windows IS already installed — follow the instruction to resolve this without reinstalling.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: INSTALL FROM USB: Simply unplug the USB drive and restart. The PC will boot into the newly installed Windows and continue to OOBE. Reconnect the USB after reaching the desktop. INSTALL WITHOUT USB (no-USB method): If you return to the install screen, try entering BIOS and changing the UEFI Hard Drive BBS Priorities to put the correct Windows partition first (e.g. MSI BIOS → Settings → Boot → UEFI Hard Drive BBS Priorities). If BIOS does not allow changing partition priority (common on MSI laptops): press Shift+F10 at the install screen to open CMD. Run: diskpart → list vol → select vol N (where N is the ~12GB Win11 partition) → delete vol. Reboot. Windows will then boot from the installed partition. Note: this deletes the install partition — download any needed files from another PC or phone before reconnecting to the internet.

#### 0.8 New Driver Install Method & MS Account Bypass

- **Watch video guide: new driver installation method during OOBE** (id=`new-method-video`; kind=`link`; control=`button`; source=`official`)
  - Description: Video fragment demonstrating the new method of installing drivers during OOBE (out-of-box experience) before connecting to the internet, then bypassing the Microsoft account requirement.
  - Action: Opens an external URL in the default browser: `https://youtu.be/Itk_7yTI4PY?t=191`
- **Install drivers during OOBE (before internet, without MS account)** (id=`new-driver-method-steps`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: During the Windows 11 initial setup screen (OOBE), press Shift+F10, type explorer.exe to open File Explorer, install chipset and GPU drivers from USB, then reboot back into OOBE. Connect to the internet when asked, but skip the Microsoft account using one of the methods below.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: 1. At the OOBE screen, press Shift+F10. 2. Type: explorer.exe and press Enter. 3. File Explorer opens — install chipset driver and GPU driver from your USB drive. 4. In CMD, type: shutdown.exe /r /t 00 to reboot back into OOBE. 5. Continue setup and connect to the internet when prompted. 6. To skip Microsoft account: — Method IV (Pro only): choose "work/school" → "Join domain" instead. — Method V+: enter aaa@gmail.com with a wrong password — after repeated failures, Windows offers a local account. — Method V: log into MS account, then go to Settings → Accounts → Your info → "Sign in with a local account instead".

#### 0.9 Start Installation

- **Reboot and boot from USB installation drive** (id=`boot-from-usb`; kind=`deeplink`; control=`button`; source=`official`; requires reboot)
  - Description: Restart the PC and enter the boot menu (usually F8, F11, F12, or Del depending on motherboard) to select the USB drive as the boot device. The Windows 11 installer will start.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:recovery`
  - Instruction: Option A: Hold Shift and click Restart → Troubleshoot → Advanced options → UEFI Firmware Settings to enter BIOS, then change boot order to USB. Option B: Restart normally and press F11/F12 (varies by board) at the manufacturer splash screen to open the one-time boot menu.
- **Boot into installation: no-USB CMD method (reboot into recovery mode)** (id=`boot-no-usb-cmd`; kind=`deeplink`; control=`button`; source=`official`; requires reboot)
  - Description: If using the no-USB CMD method: restart into Windows Recovery mode to access the Win11 install partition. See instruction.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:recovery`
  - Instruction: Go to Settings → System → Recovery → Advanced startup → Restart now. From the recovery menu, choose "Use a device" and select the Win11 partition. Alternatively, hold Shift while clicking Restart.
- **Boot into installation: no-USB EasyBCD method (select NST entry on reboot)** (id=`boot-no-usb-easybcd`; kind=`deeplink`; control=`button`; source=`official`; requires reboot)
  - Description: If you used EasyBCD to add a WinPE boot entry, simply restart the PC and select the "NST" entry in the Windows Boot Manager to launch the installer.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:recovery`
  - Instruction: Restart the PC. At the Windows Boot Manager screen, select the NST (NeoSmart Technologies) entry. This boots into the WinPE installer you configured with EasyBCD. Proceed with the normal Windows 11 installation from there.

### 1. Driver Installation & System Update

6 subsections, 32 cards. Source: `Manifests\Section01.psd1`.

#### 1.0 Setup Notes

- **v0.4 setup note — skip steps 2-4 if drivers installed during OOBE** (id=`setup-notes-v04`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: If you used the new driver installation method via Explorer during OOBE (Section 0), skip steps 2, 3, and 4 in this section — drivers and internet are already set up.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.

#### 1.1 System, Runtime & Reboot

- **Set PC name** (id=`set-pc-name`; kind=`deeplink`; control=`button`; source=`official`; requires admin; requires reboot)
  - Action: Opens `ms-settings:about`.
- **Open Device Manager** (id=`open-device-manager-drivers`; kind=`deeplink`; control=`button`; source=`official`)
  - Action: Opens `devmgmt.msc` to verify GPU, network, Bluetooth, storage, and unknown devices.
- **Enable Wi-Fi or connect Ethernet cable** (id=`enable-network`; kind=`deeplink`; control=`button`; source=`official`)
  - Action: Opens `ms-settings:network-advancedsettings`.
- **Check for Windows Updates** (id=`windows-update`; kind=`deeplink`; control=`button`; source=`official`)
  - Action: Opens `ms-settings:windowsupdate`.
- **Check optional driver updates** (id=`windows-optional-driver-updates`; kind=`deeplink`; control=`button`; source=`official`)
  - Action: Opens `ms-settings:windowsupdate-optionalupdates`.
- **Install Visual C++ Redistributables (official)** (id=`install-vcr-official`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens the Microsoft page: `https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist`.
- **Install Visual C++ 2015-2022 Redistributables via winget** (id=`install-vcr-winget`; kind=`script`; control=`button`; source=`official`; tone=`sand`; requires admin)
  - Action: Sand alternative action button `Install`; installs `Microsoft.VCRedist.2015+.x64` and `Microsoft.VCRedist.2015+.x86` through `Invoke-WingetEnsurePackage`. Presence is checked in the registry first ("Microsoft Visual C++ 2015-2022" entries) and only then via winget, so an already installed package is not downloaded again.
- **Install Visual C++ Redistributables 2005-2022 (all-in-one pack)** (id=`install-vcr-all-in-one`; kind=`link`; control=`button`; source=`unofficial`)
  - Action: Opens TechPowerUp all-in-one pack: `https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/`.
- **Visual C++ Redistributables all-in-one - GitHub releases** (id=`install-vcr-aio-github`; kind=`link`; control=`button`; source=`unofficial`)
  - Action: Opens `https://github.com/abbodi1406/vcredist/releases` - the same full package, with checksums and an open version history.
- **⚠ Restart Windows now (60 second timer)** (id=`reboot-now-warning`; kind=`script`; control=`button`; source=`official`; tone=`sand`; requires reboot)
  - Action: Sand alternative action button `Restart`; runs `shutdown.exe /r /t 60 /c ...`.
- **Cancel scheduled restart** (id=`cancel-scheduled-restart`; kind=`script`; control=`button`; source=`official`; tone=`sand`)
  - Action: Sand action button `Cancel`; runs `shutdown.exe /a`.
- **Restart after all updates are installed** (id=`reboot-after-updates`; kind=`manual`; control=`checklist`; source=`official`; requires reboot)
  - Action: Existing manual checklist preserved; the sand restart button above is only an optional shortcut.

#### 1.2 NVIDIA Drivers

- **Download official NVIDIA GPU driver** (id=`download-nvidia-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.nvidia.com/en-us/drivers/`.
- **NVIDIA App — driver updates and game optimization** (id=`download-nvidia-app-drivers`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.nvidia.com/en-us/software/nvidia-app/`.
- **NVCleanstall — minimal NVIDIA driver installer** (id=`download-nvcleanstall`; kind=`link`; control=`button`; source=`unofficial`)
  - Action: Opens `https://www.techpowerup.com/download/techpowerup-nvcleanstall/`.
- **Install NVIDIA GPU driver (clean, no bloatware)** (id=`install-nvidia-driver`; kind=`manual`; control=`checklist`; source=`official`; requires admin; requires reboot)
  - Action: Existing manual install path preserved.
- **DDU — Display Driver Uninstaller** (id=`download-ddu`; kind=`link`; control=`button`; source=`unofficial`)
  - Action: Opens `https://www.wagnardsoft.com/`.
- **Remove old GPU driver with DDU** (id=`remove-old-gpu-driver`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin; requires reboot)
  - Action: Manual Safe Mode + DDU checklist.

#### 1.3 AMD Drivers

- **Download official AMD graphics driver** (id=`download-amd-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.amd.com/en/support/download/drivers.html`.
- **Download official AMD chipset driver** (id=`download-amd-chipset-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.amd.com/en/support/download/drivers.html`.
- **Install AMD graphics/chipset drivers** (id=`install-amd-drivers`; kind=`manual`; control=`checklist`; source=`official`; requires admin; requires reboot)
  - Action: Manual AMD/OEM install checklist.

#### 1.4 Intel Drivers

- **Install Intel Driver & Support Assistant via winget** (id=`install-intel-dsa-winget`; kind=`script`; control=`button`; source=`official`; tone=`sand`; requires admin)
  - Action: Sand alternative action button `Install`; installs `Intel.IntelDriverAndSupportAssistant` through `Invoke-WingetEnsurePackage`. Presence is checked in the registry first and only then via winget.
- **Intel Driver & Support Assistant — official page** (id=`download-intel-dsa`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.intel.com/content/www/us/en/support/detect.html`.
- **Download Intel Arc / integrated graphics driver** (id=`download-intel-graphics-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.intel.com/content/www/us/en/download/785597/intel-arc-graphics-windows.html`.
- **Download Intel chipset INF driver (older chipsets only)** (id=`download-intel-chipset-inf-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.intel.com/content/www/us/en/download/19347/chipset-inf-utility.html`.
- **Download Intel RST driver** (id=`download-intel-rst-driver`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.intel.com/content/www/us/en/download/15667/intel-rapid-storage-technology-intel-rst-driver-installation-software-with-intel-optane-memory.html`.

#### 1.5 Wi-Fi & Network Drivers

- **Open motherboard / laptop support page** (id=`motherboard-laptop-support-page`; kind=`manual`; control=`checklist`; source=`official`)
  - Action: Manual exact-OEM-model support page checklist.
- **Install chipset and network drivers** (id=`install-chipset-network-driver`; kind=`manual`; control=`checklist`; source=`official`; requires admin; requires reboot)
  - Action: Existing manual checklist preserved; links below are additional vendor shortcuts.
- **Realtek Wi-Fi adapter drivers** (id=`download-realtek-wifi-drivers`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.realtek.com/Download/Index?cate_id=203&menu_id=297`.
- **Intel Wireless Wi-Fi drivers** (id=`download-intel-wifi-drivers`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.intel.com/content/www/us/en/download/19351/intel-wireless-wi-fi-drivers-for-windows-10-and-windows-11.html`.
- **MediaTek / MTK Wi-Fi driver guidance** (id=`download-mediatek-wifi-info`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.mediatek.com/products/networking-and-connectivity`.
- **MediaTek Wi-Fi drivers — Microsoft Update Catalog** (id=`download-mediatek-wifi-catalog`; kind=`link`; control=`button`; source=`official`)
  - Action: Opens `https://www.catalog.update.microsoft.com/Search.aspx?q=MediaTek%20Wi-Fi%206%20MT7921%20Wireless%20LAN%20Card`.

### 2. Disk Preparation

4 subsections, 10 cards. Source: `Manifests\Section02.psd1`.

#### 2.0 Partition Cleanup

- **Delete Windows installation files partition (no-USB method)** (id=`delete-install-partition`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: After installing Windows without a USB drive, a temporary partition remains. Open Disk Management to delete it.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open Disk Management (diskmgmt.msc), locate the small partition containing installation files, right-click it and select "Delete Volume". This only applies if you installed Windows using the no-USB method.
- **MiniTool Partition Wizard — advanced partition manager** (id=`minitool-partition-wizard`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Free partition manager with a visual interface for more complex partition operations.
  - Action: Opens an external URL in the default browser: `https://www.partitionwizard.com/free-partition-manager.html`
- **Reconnect previously disconnected drives** (id=`reconnect-drives`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: If you disconnected additional drives during Windows installation to prevent data loss, now reconnect them.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Power off the PC, reconnect any drives you disconnected before installation, then power on.

#### 2.1 Drive Letters & Explorer

- **Verify all drives are visible in Explorer** (id=`verify-drives-explorer`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Open File Explorer and confirm all connected drives appear as expected.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open File Explorer (Win+E) and check that all installed drives are listed under "This PC".
- **Assign drive letters (if drives are missing or mixed up)** (id=`assign-drive-letters`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: Open Disk Management to assign or change drive letters if drives are not visible or have incorrect letters.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open Disk Management (diskmgmt.msc), right-click the volume, choose "Change Drive Letter and Paths", and assign the desired letter.

#### 2.2 User Folder Relocation

- **Copy User folder to a second partition or drive** (id=`copy-user-folder`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Move personal files (Desktop, Documents, Downloads, Music, Pictures, Videos) to a secondary drive to keep the OS drive clean and protect data across reinstalls.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Copy the User template folder to your second drive (e.g. D:\User). Inside create subfolders: Desktop, Documents, Downloads, Music, Pictures, Videos.
- **Redirect user shell folders to the new location** (id=`redirect-user-folders`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Open the Users folder in Explorer, then right-click each shell folder (Desktop, Documents, etc.) → Properties → Location to redirect them to the new drive.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Navigate to C:\Users\YourName\. Right-click Desktop → Properties → Location tab → Move → select D:\User\Desktop. Repeat for Documents, Downloads, Music, Pictures, Videos.
- **Relocate user folders to C:\<username>\ (script)** (id=`relocate-user-folders-to-root`; kind=`script`; control=`toggle`; source=`unofficial`)
  - Description: Creates C:\<username>\Desktop|Documents|Music|Pictures|Videos and writes legacy User Shell Folders registry keys. On Windows 11 the KnownFolders API may override these; sign out and back in to let Explorer pick up the change. Marked unofficial — test before relying on it.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: $base = Join-Path $env:SystemDrive $env:USERNAME ; $target = Join-Path $base $sub ; if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null } ; $target = Join-Path $base $map[$name] ; Set-ItemProperty -Path $ushf -Name $name -Value $target -Type ExpandString ; Set-ItemProperty -Path $shf -Name $name -Value $target -Type String`; `Revert: Set-ItemProperty -Path $ushf -Name $name -Value $defaults[$name].Expand -Type ExpandString ; Set-ItemProperty -Path $shf -Name $name -Value $defaults[$name].Abs -Type String`; `Detect: $base = Join-Path $env:SystemDrive $env:USERNAME ; $desktop -eq (Join-Path $base 'Desktop')`
  - Instruction: Click Apply to create C:\<username>\ subfolders and redirect Desktop, Documents, Music, Pictures, Videos. A sign-out or Explorer restart is needed for all apps to pick up the new paths. Click Revert to restore default %USERPROFILE%\ paths.

#### 2.3 Apps & Gaming Folders

- **Set up Apps folder for portable applications** (id=`copy-apps-folder`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Create an Apps folder on a secondary drive for portable and manually installed applications, keeping them separate from the OS drive.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Create a folder such as D:\Apps on your secondary drive. Install portable applications there to keep them safe across OS reinstalls.
- **Set up Gaming folder for games and launchers (optional)** (id=`copy-gaming-folder`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Create a Gaming folder on a secondary drive and configure Steam and other launchers to install games there by default.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Create D:\Gaming on your secondary drive. In Steam: Settings → Storage → Add Drive → select D:\Gaming. Configure other launchers similarly.

### 3. Browser Setup

4 subsections, 24 cards. Source: `Manifests\Section03.psd1`.

#### 3.0 Install Browser

- **Google Chrome** (id=`install-chrome`; kind=`script`; control=`button`; source=`official`)
  - Description: The most widely used browser. Best compatibility, V8 engine, sync across devices. Installs via winget.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Google.Chrome`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget.
- **Brave Browser** (id=`install-brave`; kind=`script`; control=`button`; source=`official`)
  - Description: Chromium-based, built-in ad/tracker blocking, no Google telemetry. Good for privacy. Installs via winget.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Brave.Brave`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget.
- **Mozilla Firefox** (id=`install-firefox`; kind=`script`; control=`button`; source=`official`)
  - Description: Independent Gecko engine (not Chromium). Strong privacy defaults, excellent extension ecosystem. Installs via winget.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Mozilla.Firefox`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget.
- **Vivaldi** (id=`install-vivaldi`; kind=`script`; control=`button`; source=`official`)
  - Description: Chromium-based, extreme UI customisation, built-in tab groups, notes, mail. Power users. Installs via winget.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Vivaldi.Vivaldi`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget.
- **Opera** (id=`install-opera`; kind=`script`; control=`button`; source=`unofficial`)
  - Description: Chromium-based with built-in VPN, ad blocker, and sidebar workspace tools. Installs via winget.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Opera.Opera`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget.
- **WebView2 Runtime (standalone — required if removing Edge)** (id=`webview2-standalone`; kind=`script`; control=`button`; source=`official`)
  - Description: Microsoft WebView2 Runtime powers PWAs, Teams, new Outlook, and some Store apps. Install before removing Edge to avoid breaking them.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Install and removal go through `Invoke-WingetEnsurePackage` / `Invoke-WingetRemovePackage` (package `Microsoft.EdgeWebView2Runtime`): the installer runs with its input channel closed and under a time limit, and every outcome ends on a plain-language line in the Terminal panel. State detection reads the registry first, then winget. For WebView2 the registry is decisive: Windows marks this component as a system component, so winget does not list it, and detection uses the EdgeUpdate key `{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}`.
- **Set default browser** (id=`set-default-browser`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Default Apps settings to choose which browser handles http:// and https:// links.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:defaultapps`
  - Instruction: Scroll to the browser section or search for your browser. Click it and choose "Set as default". Make sure http and https both point to your chosen browser.

#### 3.1 Edge Configuration

- **Configure Microsoft Edge settings** (id=`configure-edge`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Edge settings page to disable telemetry, personalisation, shopping features, and configure startup behaviour.
  - Action: Opens a Windows Settings, Edge, or shell URI: `microsoft-edge:settings/privacy`
  - Instruction: Disable all telemetry and personalisation toggles. Under Privacy, search, and services → disable Help improve Microsoft products. Under New tab page → turn off news feed.
- **Configure sound devices & default playback** (id=`configure-sound`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Open Windows Sound control panel to set default playback and recording devices.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open Sound control panel (mmsys.cpl), set your default playback device, configure levels. Disable unused playback/recording devices.
- **Browser setup guide (YouTube)** (id=`browser-setup-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Video guide covering browser configuration, privacy settings, and useful extensions.
  - Action: Opens an external URL in the default browser: `https://www.youtube.com/watch?v=ITdecD6R0Yw`

#### 3.2 Edge — Tame It

- **Disable startup boost & background running** (id=`edge-disable-startup-boost`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Prevents Edge from pre-launching at login and running in the background when all windows are closed.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `StartupBoostEnabled` = `0` (DWord); Revert restores from JSON backup.
- **Disable background mode when Edge is closed** (id=`edge-disable-background`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Stops Edge from staying active in background for notifications and extensions after all windows are closed.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `BackgroundModeEnabled` = `0` (DWord); Revert restores from JSON backup.
- **Disable news feed on new tab page** (id=`edge-disable-newstab`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Removes the Microsoft News / Bing content feed from Edge new tab page.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `NewTabPageContentEnabled` = `0` (DWord); Revert restores from JSON backup.
- **Disable telemetry & diagnostic data collection** (id=`edge-disable-telemetry`; kind=`script`; control=`toggle`; source=`official`; requires admin)
  - Description: Sets three policy keys to stop Edge sending metrics, site info, and diagnostic data to Microsoft.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null } ; Set-ItemProperty $p -Name 'MetricsReportingEnabled' -Value 0 -Type DWord ; Set-ItemProperty $p -Name 'SendSiteInfoToImproveServices' -Value 0 -Type DWord ; Set-ItemProperty $p -Name 'DiagnosticData' -Value 0 -Type DWord`; `Revert: Remove-ItemProperty $p -Name 'MetricsReportingEnabled' -EA SilentlyContinue ; Remove-ItemProperty $p -Name 'SendSiteInfoToImproveServices' -EA SilentlyContinue ; Remove-ItemProperty $p -Name 'DiagnosticData' -EA SilentlyContinue`; `Detect: { $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' (Test-Path $p) -and ((Get-ItemProperty $p -EA SilentlyContinue).MetricsReportingEnabled -eq 0) }`
- **Disable Shopping Assistant (price comparison popups)** (id=`edge-disable-shopping`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Turns off the Edge Shopping Assistant that shows price comparisons and coupon suggestions on retail sites.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `EdgeShoppingAssistantEnabled` = `0` (DWord); Revert restores from JSON backup.
- **Disable Microsoft Rewards in Edge** (id=`edge-disable-rewards`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Removes Microsoft Rewards points integration and prompts from Edge UI.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `ShowMicrosoftRewards` = `0` (DWord); Revert restores from JSON backup.
- **Disable first-run experience & import prompts** (id=`edge-disable-firstrun`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Skips the Edge welcome/import wizard that appears on fresh installs or updates.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` / `HideFirstRunExperience` = `1` (DWord); Revert restores from JSON backup.

#### 3.3 Remove Edge (Optional)

Ordered workflow: bulk selection checkboxes are hidden so the step order cannot be broken. The footer button applies the next pending step from top to bottom; mark manual steps done only after completing the actual action.

- **Read before proceeding — WebView2 dependency** (id=`remove-edge-webview2-warning`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Removing Edge without a standalone WebView2 Runtime will break: Teams, new Outlook, PWA apps, Windows Widgets. Install it first via Install Browser → WebView2 Runtime.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Make sure "WebView2 Runtime (standalone)" is already installed (Install Browser subsection → Apply). Only then continue with the steps below.
- **Step 1 — Check if Uninstall is already available** (id=`remove-edge-step1-check`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Apps & Features and look for Microsoft Edge. If the Uninstall button is active (not greyed out), skip to Step 6 and uninstall directly.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:appsfeatures`
  - Instruction: Search "Microsoft Edge". If Uninstall is clickable — use it, done. If greyed out — follow Steps 2–6.
- **Step 2 — Grant write access to region policy file** (id=`remove-edge-step2-takeown`; kind=`script`; control=`button`; source=`unofficial`; requires admin)
  - Description: Runs takeown and icacls on IntegratedServicesRegionPolicySet.json to allow editing. Required because the file is owned by TrustedInstaller.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: yes. Key commands: `Apply: { $f = "$env:SystemRoot\System32\IntegratedServicesRegionPolicySet.json" & takeown.exe /f $f 2>&1 | Out-Null & icacls.exe $f /grant "${env:USERNAME}:(F)" 2>&1 | Out-Null }`; `Detect: { $f = "$env:SystemRoot\System32\IntegratedServicesRegionPolicySet.json" $acl = Get-Acl $f -EA SilentlyContinue $acl -and ($acl.Owner -notlike '*TrustedInstaller*') }`
- **Step 3 — Open policy file in Notepad** (id=`remove-edge-step3-open-json`; kind=`script`; control=`button`; source=`unofficial`)
  - Description: Opens IntegratedServicesRegionPolicySet.json in Notepad for manual editing. Run Step 2 first.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: no. Key commands: `Apply: Start-Process notepad.exe -ArgumentList $f`
- **Step 4 — Find the Edge entry and enable uninstall** (id=`remove-edge-step4-edit-json`; kind=`manual`; control=`checklist`; source=`unofficial`)
  - Description: In the JSON file: find the "MicrosoftEdge" entry. In its "regions" array, add your 2-letter country code (e.g. "RU", "US", "DE"). Save the file with Ctrl+S.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In Notepad, press Ctrl+F and search for "MicrosoftEdge". Find the nearest "regions" array (usually looks like "regions":[""] or similar). Add your 2-letter country code inside the array, e.g.: "regions":["RU"]. Save the file with Ctrl+S, then close Notepad.
- **Step 5 — Click Repair on Edge (reloads policy)** (id=`remove-edge-step5-repair`; kind=`deeplink`; control=`button`; source=`unofficial`; requires admin)
  - Description: In Apps & Features, click the three-dot menu on Microsoft Edge → Modify. This forces Windows to reload the region policy and should unlock the Uninstall button.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:appsfeatures`
  - Instruction: Find Microsoft Edge → click ⋮ → Modify. Wait for the repair to complete. Close this window completely (including any Edge processes).
- **Step 6 — Uninstall Edge** (id=`remove-edge-step6-uninstall`; kind=`deeplink`; control=`button`; source=`unofficial`; requires admin)
  - Description: Reopen Apps & Features — the Uninstall button for Edge should now be active. Click it to remove Edge.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:appsfeatures`
  - Instruction: Search for "Microsoft Edge". Click ⋮ → Uninstall. If still greyed out, close and reopen Settings, or restart the PC and try again.

### 4. Windows Settings

18 subsections, 89 cards. Source: `Manifests\Section04.psd1`.

#### 4.0 Explorer Settings

- **Remove item-selection checkboxes & clear history** (id=`explorer-remove-checkboxes`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Uncheck three checkboxes in Folder Options and clear recent-files log.
  - Action: Opens a Windows Settings, Edge, or shell URI: `shell:::{ED7BA470-8E54-465E-825C-99712043E01C}`
  - Instruction: In Folder Options uncheck: Show recently used files, Show frequently used folders, Show files from Office.com. Then click Clear under Recent files.
- **Configure Explorer view options** (id=`explorer-configure`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Explorer Options to set default folder, file-name extensions, hidden files, etc.
  - Action: Opens a Windows Settings, Edge, or shell URI: `shell:::{ED7BA470-8E54-465E-825C-99712043E01C}`
  - Instruction: Set view preferences and show hidden/system files as desired.
- **PowerToys — keyboard shortcut remapping** (id=`explorer-powertoys-keybindings`; kind=`link`; control=`button`; source=`official`)
  - Description: Download Microsoft PowerToys for advanced keyboard shortcuts and utilities.
  - Action: Opens an external URL in the default browser: `https://github.com/microsoft/PowerToys/releases`
- **Auto-size columns (CTRL + Numpad *)** (id=`explorer-autosize-columns`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Keyboard shortcut CTRL+(Numpad *) resizes all columns to fit content in Details view.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In any Explorer window in Details view, press CTRL + * (numpad asterisk) to auto-size all columns.

#### 4.1 System

- **Display — resolution, scale, refresh rate** (id=`system-display`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Set correct resolution and maximum monitor refresh rate.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:display`
  - Instruction: Set Resolution, Scale, and Display adapter properties → Monitor → Screen refresh rate to the maximum value your monitor supports.
- **Notifications — configure & enable startup alerts** (id=`system-notifications`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open notification settings; enable startup app notification toggle.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:notifications`
  - Instruction: Enable "Notify me about startup app changes" and configure app notification preferences.
- **Disable automatic Storage Sense** (id=`system-storage-cleanup`; kind=`registry`; control=`toggle`; source=`official`)
  - Description: Turns off automatic disk cleanup to prevent unexpected file removal. Same switch as System > Storage > Storage Sense.
  - Action: Apply writes registry: `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy` / `01` = `0` (DWord); Revert restores from JSON backup.
- **Enable Clipboard History (Win+V)** (id=`system-clipboard-history`; kind=`registry`; control=`toggle`; source=`official`)
  - Description: Lets Windows store clipboard history accessible via Win+V. Same switch as System > Clipboard.
  - Action: Apply writes registry: `HKCU:\SOFTWARE\Microsoft\Clipboard` / `EnableClipboardHistory` = `1` (DWord); Revert restores from JSON backup.
- **Disable Remote Desktop (if not needed)** (id=`system-remote-desktop`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Turns off RDP to reduce attack surface. Same switch as System > Remote Desktop.
  - Action: Apply writes registry: `HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server` / `fDenyTSConnections` = `1` (DWord); Revert restores from JSON backup.
- **Multitasking — configure Snap windows** (id=`system-multitasking`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Expand the Snap windows menu to configure snapping behaviour.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:multitasking`
  - Instruction: Adjust Snap windows settings to personal preference.
- **Disable Recall AI feature (24H2+)** (id=`system-disable-recall`; kind=`feature`; control=`toggle`; source=`official`; requires admin; requires reboot; appliesTo=`{"MinBuild":26100}`)
  - Description: Removes the Recall optional feature via DISM. Security-conscious opt-out for 24H2+
  - Action: Controls an optional feature through DISM/WindowsOptionalFeature: `Recall` -> `Disabled`
- **Review optional Windows features** (id=`system-optional-features`; kind=`deeplink`; control=`button`; source=`official`; requires admin)
  - Description: Disable Windows components not needed (Hyper-V, IE mode, Print-to-PDF, etc.).
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:optionalfeatures`
  - Instruction: Remove unused optional features. Keep only what you actively use.

#### 4.2 Maintenance (Optional)

- **Disable automatic Windows Maintenance** (id=`maintenance-disable`; kind=`registry`; control=`toggle`; source=`unofficial`; requires admin)
  - Description: Prevents Windows from running scheduled maintenance tasks (disk defrag, updates, diagnostics) automatically. Use with caution.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance` / `MaintenanceDisabled` = `1` (DWord); Revert restores from JSON backup.

#### 4.3 Power Scheme (Optional)

- **How to import a power scheme** (id=`power-scheme-howto`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: Import a .pow file then activate it. Run: powercfg -import "<path.pow>" then powercfg -setactive <GUID>.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Use the power scheme cards below: click Apply to import and activate a scheme. Click Revert to restore the previous scheme. Only one scheme should be active at a time.
- **Khorvie Power Scheme** (id=`power-scheme-khorvie`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: Gaming-optimised power scheme by Khorvie. Import and set as active. Apply captures current active scheme for revert.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\Khorvie.pow` (file found).
- **KhorvieOS Power Scheme** (id=`power-scheme-khorvie-os`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: Variant of the Khorvie scheme tuned for the KhorvieOS image.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\KhorvieOS.pow` (file found).
- **Ultimate Performance Scheme** (id=`power-scheme-ultimate`; kind=`powerscheme`; control=`button`; source=`official`; requires admin)
  - Description: Windows Ultimate Performance scheme unlocked. Maximum throughput, disables CPU parking.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\ultimate.pow` (file found).
- **High Performance Scheme** (id=`power-scheme-highperf`; kind=`powerscheme`; control=`button`; source=`official`; requires admin)
  - Description: Standard Windows High Performance power plan.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\high perf.pow` (file found).
- **AdamX Power Scheme** (id=`power-scheme-adamx`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: AdamX community power scheme.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\adamx.pow` (file found).
- **Xilly Power Scheme** (id=`power-scheme-xilly`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: Xilly community power scheme.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\Xilly.pow` (file found).
- **TJxTweaks Power Scheme** (id=`power-scheme-tjx`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: TJxTweaks community power scheme.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\TJxTweaks.pow` (file found).
- **Core Power Scheme** (id=`power-scheme-core`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: Core community power scheme.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\Core.pow` (file found).
- **Bitsium Power Scheme** (id=`power-scheme-bitsium`; kind=`powerscheme`; control=`button`; source=`unofficial`; requires admin)
  - Description: Bitsium community power scheme.
  - Action: Imports and activates a plan through powercfg -import and powercfg -setactive. Local file: `Assets\PowerSchemes\bitsium.pow` (file found).

#### 4.4 CTT Tweaker (Optional)

- **CTT WinUtil — GitHub (source + releases)** (id=`ctt-github`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Source code and releases for the Chris Titus Tech WinUtil tweaker. Run directly: irm christitus.com/win | iex
  - Action: Opens an external URL in the default browser: `https://github.com/ChrisTitusTech/winutil`
- **Chris Titus Tech Win11 Tweaker** (id=`ctt-launch`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin)
  - Description: All-in-one tweaker by ChrisTitusTech. Run from admin PowerShell: irm christitus.com/win | iex
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open an admin PowerShell and run: irm christitus.com/win | iex — then apply recommended tweaks for desktop PCs or laptops as appropriate.
- **Chris Titus Tech YouTube channel** (id=`ctt-channel`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Reference guide and explanations for the tweaker options.
  - Action: Opens an external URL in the default browser: `https://www.youtube.com/@ChrisTitusTech`

#### 4.5 Devices

- **Disable Bluetooth (if not needed)** (id=`devices-bluetooth`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turn off Bluetooth to reduce background radio usage.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:bluetooth`
  - Instruction: Toggle Bluetooth off.
- **Disable Enhanced Pointer Precision** (id=`devices-pointer-precision`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turn off mouse acceleration for consistent, predictable mouse movement (important for gaming).
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:mousetouchpad`
  - Instruction: Open Additional mouse settings → Pointer Options → uncheck "Enhance pointer precision".
- **Cursor color & size** (id=`devices-cursor-color`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Set cursor size and color scheme in accessibility settings.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:easeofaccess-mousepointer`
  - Instruction: Choose cursor size and color (White, Black, or custom).
- **Disable Sticky Keys & Filter Keys** (id=`devices-sticky-keys`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Disable accidental activation of Sticky Keys and Filter Keys keyboard shortcuts.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:easeofaccess-keyboard`
  - Instruction: Turn off Sticky Keys, Filter Keys, and toggle keys.
- **Install color profile** (id=`devices-color-profile`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Apply an ICC color profile for accurate color reproduction on your monitor.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Download your monitor ICC profile from manufacturer or rtings.com, then open Color Management (colorcpl.exe), select your display, check "Use my settings for this device" and add the profile.

#### 4.6 USB Power Management

- **Disable power-saving on every device that allows it** (id=`usb-disable-power-mgmt`; kind=`script`; control=`button`; source=`unofficial`; requires admin)
  - Description: Clears "Allow the computer to turn off this device to save power" on every device that exposes that checkbox - USB hubs and controllers, network adapters, input devices, serial/USB adapters. Fixes random disconnects, at the cost of some idle power. Revert restores only the devices this card switched off.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Works through the `MSPower_DeviceEnable` WMI class: the card reports how many power-manageable devices the machine has and on how many power saving was already off, before and after. The list of devices it changed is stored in the `usb-disable-power-mgmt.restore` backup, so Revert restores only those and leaves anything you configured by hand alone.
  - Scope note: the bundled signed script `Assets\Scripts\DisableUSBPowerManagement.ps1` was meant to filter for serial ports, but a dropped `PNPDeviceID` property collapses its condition so that it matches every power-manageable device. That breadth is kept deliberately - it is what actually fixes the disconnects - and the title and description above were brought in line with it.

#### 4.7 SoundSwitch (Optional)

- **SoundSwitch — hotkey audio device switcher** (id=`soundswitch-download`; kind=`link`; control=`button`; source=`official`)
  - Description: Lightweight app for switching audio output/input devices with a keyboard shortcut.
  - Action: Opens an external URL in the default browser: `https://github.com/Belphemur/SoundSwitch/releases`

#### 4.8 Phone Link (Optional)

- **Connect Android phone to Windows (Link to Windows)** (id=`phone-link-guide`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Step-by-step guide to link your Android phone via the Phone Link app and Cross Device Experience Host.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: 1. Install "Link to Windows" on your Android phone. 2. Download Phone Link and Cross Device Exp. Host via the links below (use store.rg-adguard.net if MS Store is blocked). 3. Open Mobile Devices settings and sign in with your Microsoft account. 4. Enable shared clipboard, notifications, and other desired features in Phone Link.
- **MS Store package download (region bypass)** (id=`phone-link-store-bypass`; kind=`link`; control=`button`; source=`official`)
  - Description: Alternative site for downloading Microsoft Store app packages (.msix) when the Store is blocked or slow.
  - Action: Opens an external URL in the default browser: `https://store.rg-adguard.net/`
- **Phone Link — MS Store page** (id=`phone-link-app`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Phone Link app store page. Paste the URL into store.rg-adguard.net if the Store is unavailable.
  - Action: Opens an external URL in the default browser: `https://apps.microsoft.com/detail/9nmpj99vjbwv`
- **Cross Device Experience Host — MS Store page** (id=`phone-link-cross-device-host`; kind=`link`; control=`button`; source=`official`)
  - Description: Required companion component for cross-device features. Paste URL into store.rg-adguard.net if needed.
  - Action: Opens an external URL in the default browser: `https://apps.microsoft.com/detail/9ntxgkq8p7n0`
- **Mobile devices settings** (id=`phone-link-settings`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Mobile devices settings to sign in and configure cross-device features.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:mobile-devices`
  - Instruction: Sign in with your Microsoft account and enable shared clipboard, notifications, and other Phone Link features.

#### 4.9 Disk Indexing (Optional)

- **Disable Windows Search indexing service** (id=`indexing-disable-service`; kind=`service`; control=`toggle`; source=`official`; requires admin)
  - Description: Stops and disables the WSearch service. Reduces disk & CPU load. Start menu search still works; building an index takes longer when enabled again.
  - Action: Apply changes service `WSearch`: Startup=`Disabled`, State=`Stopped`; Revert is intended as Startup=`Automatic`, State=`Running`.
- **Remove drive indexing flag (per-drive)** (id=`indexing-drive-properties`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: Uncheck "Allow files on this drive to have contents indexed" in each drive's Properties.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open File Explorer → right-click each drive → Properties → uncheck "Allow files on this drive to have contents indexed in addition to file properties".
- **Configure Search index locations** (id=`indexing-search-settings`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open Windows Search settings to define which folders to include in the index.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:cortana-windowssearch`
  - Instruction: Limit indexed locations to only the folders you actually need to search.

#### 4.10 Network & Internet

- **Mark Ethernet as metered connection** (id=`network-metered-ethernet`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Prevents large background downloads (Windows Update delivery optimization, app updates) on Ethernet.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:network-ethernet`
  - Instruction: Select your Ethernet adapter → toggle "Metered connection" On.
- **Mark Wi-Fi as metered connection** (id=`network-metered-wifi`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Prevents large background downloads over Wi-Fi.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:network-wifi`
  - Instruction: Select your Wi-Fi network → Properties → toggle "Metered connection" On.
- **Configure network adapter properties** (id=`network-adapter-properties`; kind=`deeplink`; control=`button`; source=`official`; requires admin)
  - Description: Open adapter settings to configure DNS servers, IPv4, and adapter-specific power settings.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:network-advancedsettings`
  - Instruction: Set preferred DNS server to a fast provider (e.g. 1.1.1.1 / 1.0.0.1 or 8.8.8.8 / 8.8.4.4). Run DNSBench to find fastest DNS for your location.
- **DNS Benchmark — find fastest DNS for your ISP** (id=`network-dnsbench`; kind=`link`; control=`button`; source=`official`)
  - Description: GRC DNSBench tests all known DNS resolvers and ranks them by speed from your location.
  - Action: Opens an external URL in the default browser: `https://www.grc.com/dns/benchmark.htm`
- **Disable Cross-Device sync (if not needed)** (id=`network-cross-device`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turns off phone link and cross-device experience if you do not use them.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:crossdevice`
  - Instruction: Toggle off Shared experiences and Phone Link if not needed.

#### 4.11 Personalization

- **Wallpaper** (id=`personalization-wallpaper`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Set desktop wallpaper from Settings or browse local images.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:personalization-background`
  - Instruction: Choose a wallpaper image.
- **Colors & accent** (id=`personalization-colors`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Set Dark mode and accent color.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:colors`
  - Instruction: Choose Dark mode. Set accent color to Custom or auto from wallpaper.
- **Lock screen** (id=`personalization-lockscreen`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Configure lock screen background and displayed info.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:lockscreen`
  - Instruction: Set lock screen image and disable unwanted lock-screen widgets.
- **Start menu layout** (id=`personalization-start`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Configure Start menu layout: show more pins, remove recommendations.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:personalization-start`
  - Instruction: Set layout to "More pins". Enable "Show recently added apps" and startup notification if desired.
- **Taskbar configuration** (id=`personalization-taskbar`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Remove taskbar widgets, search, task view buttons; enable auto-hide if desired.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:taskbar`
  - Instruction: Disable Search, Task View, Widgets. Center or Left-align taskbar icons.
- **Disable all Device Usage suggestions** (id=`personalization-device-usage`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turn off Microsoft advertising and personalization features in Device Usage.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:deviceusage`
  - Instruction: Toggle off all options in Device usage.

#### 4.12 More Personalization

- **Classic right-click context menu (Win10 style)** (id=`personalization-classic-context-menu`; kind=`script`; control=`toggle`; source=`unofficial`)
  - Description: Restores the full one-level context menu. Removes the "Show more options" extra click introduced in Win11.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null } ; if (-not (Test-Path $srv32)) { New-Item -Path $srv32 -Force | Out-Null }`; `Revert: if (Test-Path $clsid) { Remove-Item -Path $clsid -Recurse -Force }`; `Detect: { $srv32 = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' if (-not (Test-Path $srv32)) { return $false } $val = (Get-Item $srv32).GetValue('') $val -ne $null # empty string means app...`
- **Remove Gallery from File Explorer navigation pane** (id=`personalization-remove-gallery`; kind=`registry`; control=`toggle`; source=`unofficial`)
  - Description: Hides the Gallery entry in the Explorer left-side navigation tree.
  - Action: Apply writes registry: `HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}` / `System.IsPinnedToNameSpaceTree` = `0` (DWord); Revert restores from JSON backup.
- **Remove Home from File Explorer navigation pane** (id=`personalization-remove-home`; kind=`script`; control=`toggle`; source=`unofficial`)
  - Description: Hides the Home (MSGraph home) entry in the Explorer navigation tree.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null } ; Set-ItemProperty -Path $clsid -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord`; `Revert: Set-ItemProperty -Path $clsid -Name 'System.IsPinnedToNameSpaceTree' -Value 1 -Type DWord`; `Detect: { $clsid = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' if (-not (Test-Path $clsid)) { return $false } try { (Get-ItemProperty $clsid -Name 'System.IsPinnedToNameSpaceTree' -EA Stop).'System.IsPi...`
- **Hide Start menu Recommended section (24H2)** (id=`personalization-hide-start-recommendations`; kind=`script`; control=`toggle`; source=`official`; requires admin; appliesTo=`{"MinBuild":26100}`)
  - Description: Sets policy keys to hide the Recommended section in the Start menu. Requires 24H2 build 26100+. Uses PolicyManager keys (no GPO needed on Home).
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null } ; Set-ItemProperty -Path $startPath -Name 'HideRecommendedSection' -Value 1 -Type DWord ; Set-ItemProperty -Path $eduPath -Name 'IsEducationEnvironment' -Value 1 -Type DWord ; Set-ItemProperty -Path $polPath -Name 'HideRecommendedSection' -Value 1 -Type DWord`; `Revert: Remove-ItemProperty -Path $startPath -Name 'HideRecommendedSection' -EA SilentlyContinue ; Remove-ItemProperty -Path $eduPath -Name 'IsEducationEnvironment' -EA SilentlyContinue ; Remove-ItemProperty -Path $polPath -Name 'HideRecommendedSection' -EA SilentlyContinue`; `Detect: { $polPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' if (-not (Test-Path $polPath)) { return $false } try { (Get-ItemProperty $polPath -Name 'HideRecommendedSection' -EA Stop).'HideRecommendedSection' -eq 1 ...`
- **Restore Windows Photo Viewer** (id=`personalization-photo-viewer`; kind=`script`; control=`toggle`; source=`unofficial`)
  - Description: Re-activates the legacy Photo Viewer (shimgvw.dll) as a registered image handler with better color accuracy than Photos app.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null } ; Set-ItemProperty -Path $p -Name 'PhotoViewer.FileAssoc.Tiff' -Value '' -Type String ; New-Item -Path $pvRoot -Force | Out-Null`; `Revert: Remove-ItemProperty -Path $p -Name 'PhotoViewer.FileAssoc.Tiff' -EA SilentlyContinue`; `Detect: { $p = 'HKCU:\Software\Classes\.jpg\OpenWithProgids' if (-not (Test-Path $p)) { return $false } try { $null -ne (Get-ItemProperty $p -Name 'PhotoViewer.FileAssoc.Tiff' -EA Stop) } catch { $false } }`
- **ViVeTool — download (GitHub releases)** (id=`download-vivetool-personalization`; kind=`link`; control=`button`; source=`unofficial`; appliesTo=`{"MinBuild":26200}`)
  - Description: Tool for enabling undocumented Windows feature flags via A/B experiment IDs. Required for unlocking 25H2 and other experimental features.
  - Action: Opens an external URL in the default browser: `https://github.com/thebookisclosed/ViVe/releases`
- **Enable 25H2 feature flags (ViVeTool)** (id=`personalization-25h2-features`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin; requires reboot; appliesTo=`{"MinBuild":26200}`)
  - Description: Unlock experimental features for Win11 25H2 using ViVeTool. This is an unofficial tool that manipulates undocumented A/B feature flags.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Download and run ViVeTool (link above). Then run ViVeTool.exe with the feature IDs from the archive txt file. Requires a restart to take effect.
- **Compact (Tablet) Taskbar mode** (id=`personalization-compact-taskbar`; kind=`registry`; control=`toggle`; source=`unofficial`)
  - Description: Reduces taskbar icon size and spacing via registry. Restart Explorer (or sign out) to apply.
  - Action: Apply writes registry: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer` / `TabletPostureTaskbar` = `1` (DWord); Revert restores from JSON backup.
- **Auto Dark/Light theme switching (PowerToys)** (id=`personalization-auto-dark-mode`; kind=`link`; control=`button`; source=`official`)
  - Description: PowerToys includes an Auto Dark Mode module that switches the Windows theme at sunrise/sunset automatically.
  - Action: Opens an external URL in the default browser: `https://github.com/microsoft/PowerToys/releases`
- **Everything — fast file search with own index** (id=`personalization-everything-search`; kind=`link`; control=`button`; source=`official`)
  - Description: Everything indexes all drive filenames and delivers sub-second search results. Download the portable version.
  - Action: Opens an external URL in the default browser: `https://www.voidtools.com/`
- **Everything plugin for PowerToys Run** (id=`personalization-everything-powertoys-plugin`; kind=`link`; control=`button`; source=`official`)
  - Description: Integrates Everything search into PowerToys Run (Alt+Space) for instant file lookup.
  - Action: Opens an external URL in the default browser: `https://github.com/lin-ycv/EverythingPowerToys/releases`
- **DisplaySwitch — quick monitor mode shortcuts** (id=`personalization-display-switch`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Windows built-in DisplaySwitch.exe switches display mode: /1=PC screen only, /2=Duplicate, /3=Extend, /4=Second screen only.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Create desktop shortcuts to C:\Windows\System32\DisplaySwitch.exe with argument /1 (single monitor) or /3 (extend). Right-click Desktop → New → Shortcut, enter "DisplaySwitch.exe /3" as the location.

#### 4.13 Apps

- **Disable background app activity** (id=`apps-background-apps`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Prevent apps from running and updating data in the background.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:privacy-backgroundapps`
  - Instruction: For each app, disable background access or set to "Power optimized".
- **Disable transfer between devices & backup** (id=`apps-cross-device`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turns off cross-device transfer and app backup to Microsoft account.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:crossdevice`
  - Instruction: Disable "Save app state" and "Transfer to new device" options.
- **Set default apps for file extensions** (id=`apps-default-file-associations`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Assign preferred apps for file types (e.g. browser for HTML, image viewer for PNG).
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:defaultapps`
  - Instruction: Set default application for each file extension you use regularly.
- **Disable unnecessary startup apps** (id=`apps-startup`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Review and disable apps that launch at Windows startup.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:startupapps`
  - Instruction: Toggle off any startup apps you do not actively use.
- **Install all Microsoft Store app updates** (id=`apps-store-update`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Ensure all Store apps are up-to-date before configuring defaults.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-windows-store://updates`
  - Instruction: Click "Get updates" and wait for all apps to update.

#### 4.14 Other Startup Settings (Optional)

- **Open User Startup folder** (id=`startup-user-folder`; kind=`script`; control=`button`; source=`official`)
  - Description: Opens the current-user Startup folder in Explorer. Shortcuts here launch at login for this user only.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: no. Key commands: `Apply: $path = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup' ; Start-Process explorer.exe $path`
- **Open System Startup folder** (id=`startup-system-folder`; kind=`script`; control=`button`; source=`official`; requires admin)
  - Description: Opens the system-wide Startup folder in Explorer. Shortcuts here launch at login for all users.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: no. Key commands: `Apply: $path = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup' ; Start-Process explorer.exe $path`
- **Sysinternals Autoruns — comprehensive startup manager** (id=`startup-autoruns`; kind=`link`; control=`button`; source=`official`)
  - Description: Shows every auto-start location: registry, drivers, scheduled tasks, services, browser extensions, and more.
  - Action: Opens an external URL in the default browser: `https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns`

#### 4.15 Language & Time

- **Clock on taskbar — format & display** (id=`language-taskbar-clock`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open taskbar settings to configure clock format and additional calendars.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:taskbar`
  - Instruction: Scroll to System tray → Clock — enable seconds if desired.
- **Disable unnecessary input features** (id=`language-input-settings`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Remove hardware keyboard suggestions, autocorrect, and other input method features.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:keyboard`
  - Instruction: Turn off Autocorrect, Spell check, and Text predictions.
- **Language keyboard shortcut** (id=`language-keyboard-shortcut`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Configure the hotkey for switching input languages.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:keyboard`
  - Instruction: Click "Advanced keyboard settings" → Input language hotkeys → set to preferred shortcut or "Not assigned".
- **Open Input Language Hotkeys dialog** (id=`language-open-hotkey-dialog`; kind=`script`; control=`button`; source=`official`)
  - Description: Opens the classic Advanced Key Settings dialog where you can view and change the keyboard language switch shortcut.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: no; Detect: no. Key commands: `Apply: Start-Process 'rundll32.exe' -ArgumentList 'shell32.dll,Control_RunDLL input.dll,,{C07337D3-DB2C-4D0B-9A93-B722A6C106E2}'`
- **Switch language hotkey: Alt+Shift → Ctrl+Shift** (id=`language-keyboard-toggle-ctrlshift`; kind=`script`; control=`toggle`; source=`unofficial`)
  - Description: Changes the keyboard language switch shortcut from Alt+Shift (Windows default) to Ctrl+Shift. Takes effect after sign-out or Explorer restart.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Key commands: `Apply: if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null } ; Set-ItemProperty -Path $path -Name 'Hotkey' -Value '2' -Type String ; Set-ItemProperty -Path $path -Name 'Language Hotkey' -Value '2' -Type String ; Set-ItemProperty -Path $path -Name 'Layout Hotkey' -Value '3' -Type String`; `Revert: if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null } ; Set-ItemProperty -Path $path -Name 'Hotkey' -Value '1' -Type String ; Set-ItemProperty -Path $path -Name 'Language Hotkey' -Value '1' -Type String ; Set-ItemProperty -Path $path -Name 'Layout Hotkey' -Value '2' -Type String`; `Detect: { $path = 'HKCU:\Keyboard Layout\Toggle' if (-not (Test-Path $path)) { return $false } try { (Get-ItemProperty $path -Name 'Hotkey' -EA Stop).Hotkey -eq '2' } catch { $false } }`

#### 4.16 Privacy

- **Disable all General privacy options** (id=`privacy-general`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Turns off advertising ID, language list access, app launch tracking, suggested content, and settings page recommendations.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:privacy-general`
  - Instruction: Toggle off every option on this page.
- **Disable online speech recognition** (id=`privacy-speech`; kind=`registry`; control=`toggle`; source=`official`)
  - Description: Prevents Microsoft from collecting voice data for speech model improvement. Same switch as Privacy & security > Speech.
  - Action: Apply writes registry: `HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy` / `HasAccepted` = `0` (DWord); Revert restores from JSON backup.
- **Disable inking & typing personalization** (id=`privacy-inking`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Stops Microsoft from collecting typed and handwritten data for custom dictionary.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:privacy-speechtyping`
  - Instruction: Turn off "Getting to know you" personalization.
- **Set diagnostics to Required only, delete data** (id=`privacy-diagnostics`; kind=`deeplink`; control=`button`; source=`official`; requires admin)
  - Description: Reduce telemetry to the minimum allowed. Delete previously collected diagnostic data.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:privacy-feedback`
  - Instruction: Set "Diagnostic data" to Required only. Click "Delete diagnostic data" to remove existing data. Set feedback frequency to Never.
- **Disable all Search permissions** (id=`privacy-search-permissions`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Prevents Windows Search from sending search history and web suggestions to Microsoft.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:search-permissions`
  - Instruction: Toggle off all options: SafeSearch, Cloud content search, Search history, Better search suggestions.
- **Disable location services** (id=`privacy-location`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Turns off the system-wide location master switch. Per-app permissions stay as they are — grant them individually if something actually needs location.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location` / `Value` = `Deny` (String); Revert restores from JSON backup.
- **Disable app diagnostic data access** (id=`privacy-app-diagnostics`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Prevents apps from reading other apps diagnostic information. Same switch as Privacy & security > App diagnostics.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics` / `Value` = `Deny` (String); Revert restores from JSON backup.
- **Disable custom device data sharing** (id=`privacy-custom-devices`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Prevents apps from sharing data with custom devices on the network.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:privacy-customdevices`
  - Instruction: Toggle off "Communicate with unpaired devices".

#### 4.17 Windows Update

- **Check for Windows Updates** (id=`updates-check`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Verify all Windows updates are installed before final configuration.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:windowsupdate`
  - Instruction: Click "Check for updates" and install all available updates. Restart if prompted.
- **Check optional & driver updates** (id=`updates-optional`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Review optional updates for driver updates not delivered via main Windows Update.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-settings:windowsupdate-optionalupdates`
  - Instruction: Install optional driver updates if relevant to your hardware.
- **Disable Delivery Optimization (P2P updates)** (id=`updates-delivery-optimization`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Prevents Windows from using your internet connection to send updates to other PCs. Writes the policy value, which also greys the switch out in Settings.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization` / `DODownloadMode` = `0` (DWord); Revert restores from JSON backup.
- **Disable Find My Device (if not needed)** (id=`updates-find-my-device`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Turns off device location tracking via Microsoft account. Same switch as Privacy & security > Find my device.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowFindMyDevice` / `value` = `0` (DWord); Revert restores from JSON backup.

### 5. GPU & Monitor Settings

4 subsections, 16 cards. Source: `Manifests\Section05.psd1`.

#### 5.0 Important Notes

- **v0.4 update notes — VRR and Nvidia settings** (id=`gpu-notes-v04`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Key corrections from v0.4: G-Sync should be enabled in fullscreen mode only (not windowed+fullscreen). Nvidia settings section now includes DLSS model/preset selection and PS-native DLSS indicator toggle.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: VRR monitors: use "Enable G-Sync for full screen mode" only — do NOT enable for windowed+fullscreen mode. See the VRR guide link below for details.

#### 5.1 Monitor Setup

- **Monitor setup guide — fixed refresh rate (no VRR)** (id=`monitor-no-vrr-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Online guide for configuring a monitor that does not support Variable Refresh Rate (G-Sync / FreeSync).
  - Action: Opens an external URL in the default browser: `https://andrilaz.github.io/fixed-refresh`
- **Monitor setup guide — VRR (G-Sync / FreeSync)** (id=`monitor-vrr-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Online guide for configuring a VRR monitor with G-Sync or FreeSync. Includes correct G-Sync mode selection.
  - Action: Opens an external URL in the default browser: `https://andrilaz.github.io/vrr`

#### 5.2 Nvidia Settings

- **Open Nvidia Control Panel** (id=`nvidia-control-panel`; kind=`deeplink`; control=`button`; source=`official`)
  - Description: Open the Nvidia Control Panel from the Microsoft Store to access display, 3D settings, and G-Sync configuration.
  - Action: Opens a Windows Settings, Edge, or shell URI: `ms-windows-store://pdp/?ProductId=9NF8H0H7WMLT`
  - Instruction: Install or open the Nvidia Control Panel from the Store, then configure 3D Settings and Display settings per the guide.
- **Configure Nvidia driver settings (3D, DLSS, display)** (id=`nvidia-settings-guide`; kind=`manual`; control=`checklist`; source=`unofficial`)
  - Description: Apply recommended Nvidia Control Panel settings: power management mode, texture filtering, DLSS model/preset selection, and display configuration.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In Nvidia Control Panel: 1. Manage 3D settings → Power management mode: Prefer maximum performance. 2. Set texture filtering quality. 3. Configure G-Sync if available. 4. For DLSS: select the appropriate model and preset in supported games. Refer to the Nvidia settings guide in the archive for detailed recommendations.
- **Show Nvidia DLSS indicator overlay** (id=`nvidia-dlss-indicator`; kind=`registry`; control=`toggle`; source=`official`; requires admin)
  - Description: Enables the Nvidia NGXCore DLSS indicator overlay via the driver registry flag.
  - Action: Apply writes registry: `HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore` / `ShowDlssIndicator` = `1` (DWord); Revert restores from JSON backup.
- **Disable Nvidia HDCP** (id=`nvidia-disable-hdcp`; kind=`script`; control=`toggle`; source=`unofficial`; requires admin; requires reboot)
  - Description: Sets the Nvidia display driver HDCP override flag on detected Nvidia display class registry entries. Revert removes the override flag.
  - Action: Runs a PowerShell scriptblock from the manifest. Apply: yes; Revert: yes; Detect: yes. Apply finds Nvidia display class keys and writes `RMHdcpKeyglobZero=1`; Revert removes `RMHdcpKeyglobZero`.

#### 5.3 Official Nvidia Recommendations

- **NVIDIA App — download** (id=`nvidia-app-download`; kind=`link`; control=`button`; source=`official`)
  - Description: Official NVIDIA App download page for drivers, game optimization, DLSS Overrides, overlays, GPU tuning, and RTX video features.
  - Action: Opens an external URL in the default browser: `https://www.nvidia.com/en-us/software/nvidia-app/`
- **Apply NVIDIA App optimal game settings** (id=`nvidia-app-optimal-settings`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use NVIDIA App recommendations for supported games and apps. Recommendations are based on GPU, CPU, resolution, RAM, OS, and the latest official game patch.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open NVIDIA App → Home or Graphics → select a detected game → Optimize. Run a game once if NVIDIA App cannot optimize it yet, update the game and driver, then use the Performance/Quality slider if needed.
- **Configure NVIDIA App DLSS Overrides** (id=`nvidia-app-dlss-overrides`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use official DLSS Overrides to apply newer DLSS models, DLSS Super Resolution presets, Frame Generation options, DLAA, and Ultra Performance modes globally or per game.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Open NVIDIA App → Graphics → Global Settings or Program Settings → DLSS Override. For Super Resolution, choose Model Presets → Recommended. For Frame Generation, choose Dynamic or Fixed only for compatible RTX GPUs/games. Use Statistics → DLSS in the NVIDIA overlay to verify override status.
- **Official G-SYNC / VRR and V-Sync baseline** (id=`nvidia-gsync-vsync-baseline`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Configure VRR the NVIDIA-supported way: enable display VRR, use the maximum refresh rate, enable G-SYNC for full screen mode, and avoid forcing V-Sync Off globally.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Enable Adaptive Sync / G-SYNC in the monitor OSD, set the highest supported refresh rate in Windows or NVIDIA Control Panel, then NVIDIA Control Panel → Set up G-SYNC → enable for Full screen mode. For no-tear G-SYNC use, set Manage 3D Settings → Vertical Sync → On; do not force global V-Sync Off.
- **NVIDIA Reflex and Ultra Low Latency** (id=`nvidia-reflex-low-latency`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use NVIDIA Reflex in supported games; use Ultra Low Latency Mode in the driver when Reflex is unavailable.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: In supported games, enable NVIDIA Reflex Low Latency (On, or On + Boost if needed). If a game does not support Reflex, open NVIDIA Control Panel → Manage 3D Settings → Low Latency Mode → Ultra, preferably per game.
- **Max Frame Rate and Power Management** (id=`nvidia-max-frame-rate-power`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use NVIDIA Max Frame Rate for latency, power saving, or staying inside the VRR range; use Prefer Maximum Performance only when needed.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: NVIDIA Control Panel → Manage 3D Settings → Max Frame Rate. For VRR, cap slightly below the display maximum refresh rate. For latency in GPU-bound games, use Prefer maximum performance and Low Latency Mode Ultra. For power saving, use Optimal Power.
- **NVIDIA Image Scaling** (id=`nvidia-image-scaling`; kind=`manual`; control=`checklist`; source=`official`; requires reboot)
  - Description: Enable driver-level spatial upscaling and sharpening for supported DirectX, Vulkan, and OpenGL games.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: NVIDIA Control Panel → Manage 3D Settings → Image Scaling → On. Reboot so games detect the generated scaling resolutions, then choose a lower render resolution in fullscreen mode and tune sharpening globally or per game.
- **RTX Video Super Resolution / HDR** (id=`nvidia-rtx-video`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Enable RTX Video enhancements through NVIDIA App or NVIDIA Control Panel for supported browsers and RTX GPUs.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Prefer NVIDIA App for RTX Video options. Alternatively open NVIDIA Control Panel → Adjust Video Image Settings → RTX Video Enhancements, then enable Super Resolution and/or HDR. Use a supported browser such as Chrome, Edge, or Firefox.
- **NVIDIA performance and DLSS status overlay** (id=`nvidia-performance-overlay`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Use the NVIDIA overlay to show FPS, GPU metrics, latency metrics, and DLSS Override status in-game.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Enable In-Game Overlay in NVIDIA App. Press Alt+Z → Statistics → choose DLSS or Custom statistics view. Toggle the overlay with Alt+R while in game.

### 6. Cooling Setup

1 subsections, 2 cards. Source: `Manifests\Section06.psd1`.

#### 6.0 Cooling Setup

- **Enable PWM (Smart) fan mode in BIOS** (id=`enable-pwm-bios`; kind=`manual`; control=`checklist`; source=`official`; requires reboot)
  - Description: Set fan headers to PWM (Smart) mode in BIOS/UEFI so software like Fan Control can regulate fan speeds. Only applicable if your motherboard and fans support PWM.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Restart into BIOS/UEFI (usually Del or F2 on boot). Navigate to the fan/hardware monitoring section. Set each fan header connected to a PWM fan to "PWM" or "Smart" mode. Save and exit.
- **Download Fan Control** (id=`download-fan-control`; kind=`link`; control=`button`; source=`official`)
  - Description: Fan Control is a free open-source app for detailed fan curve configuration, temperature monitoring, and mixing sensor inputs.
  - Action: Opens an external URL in the default browser: `https://github.com/Rem0o/FanControl.Releases/releases`

### 7. Steam & Game Launchers

2 subsections, 22 cards. Source: `Manifests\Section07.psd1`.

#### 7.0 Game Launchers

- **Download Steam** (id=`download-steam`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Steam client download page.
  - Action: Opens an external URL in the default browser: `https://store.steampowered.com/about/`
- **Download Epic Games Store** (id=`download-epic-games`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Epic Games Store launcher download page.
  - Action: Opens an external URL in the default browser: `https://store.epicgames.com/download`
- **Download EA App** (id=`download-ea-app`; kind=`link`; control=`button`; source=`official`)
  - Description: Official EA App launcher download page (replaces Origin).
  - Action: Opens an external URL in the default browser: `https://www.ea.com/ea-app`
- **Install EA App to a custom drive** (id=`ea-install-other-drive`; kind=`manual`; control=`checklist`; source=`official`; requires admin)
  - Description: The EA installer supports a command-line argument to set the default install folder. Use this to install games on a secondary drive.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Run the EA installer from the command line with: EAappInstaller.exe /i DefaultInstallFolder="D:\Gaming\EA Games" — replace D:\Gaming\EA Games with your preferred path.
- **Download Blizzard Battle.net** (id=`download-blizzard`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Battle.net desktop app download page.
  - Action: Opens an external URL in the default browser: `https://download.battle.net/desktop`
- **Download Rockstar Games Launcher** (id=`download-rockstar`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Rockstar Games Launcher download page (required for GTA V, RDR2, etc.).
  - Action: Opens an external URL in the default browser: `https://socialclub.rockstargames.com/rockstar-games-launcher`
- **Download Xbox app** (id=`download-xbox`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Xbox app for PC from the Microsoft Store. Provides access to Game Pass and Xbox games.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/store/productId/9MV0B5HZVK9Z`
- **Download Valorant / League of Legends** (id=`download-valorant-lol`; kind=`link`; control=`button`; source=`official`)
  - Description: Riot Games download page for Valorant and League of Legends (includes the Riot Client).
  - Action: Opens an external URL in the default browser: `https://playvalorant.com/download/`
- **Download TcNo Account Switcher** (id=`download-account-switcher`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Convenient multi-account switcher for Steam, Epic Games, EA, and other gaming platforms.
  - Action: Opens an external URL in the default browser: `https://github.com/TCNOco/TcNo-Acc-Switcher/releases`

#### 7.1 Minecraft

- **Minecraft launcher notes (v0.4)** (id=`minecraft-notes`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Correction from v0.4: Prism Launcher does NOT support playing without a license. Use Freesm Launcher (fork of Prism) for playing without a license.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Use Freesm Launcher (link 3.1) if you want to play without a license. Prism Launcher requires a valid Minecraft license.
- **Download Minecraft (Bedrock Edition — official, requires license)** (id=`minecraft-bedrock`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Minecraft Bedrock Edition from the Microsoft Store.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/store/productId/9NBLGGH2JHXJ`
- **Download Minecraft Preview (Bedrock early access — official, requires license)** (id=`minecraft-bedrock-preview`; kind=`link`; control=`button`; source=`official`)
  - Description: Early access builds of Minecraft Bedrock Edition from the Microsoft Store.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/store/productId/9P5X4QVLC2XR`
- **Download Minecraft Launcher (Bedrock + Java — official, requires license)** (id=`minecraft-launcher-unified`; kind=`link`; control=`button`; source=`official`)
  - Description: Unified Minecraft Launcher supporting both Bedrock and Java editions, from the Microsoft Store.
  - Action: Opens an external URL in the default browser: `https://www.microsoft.com/store/productId/9PGW18NPBZV5`
- **Download Minecraft Launcher without Microsoft Store (Java Edition — official)** (id=`minecraft-launcher-no-store`; kind=`link`; control=`button`; source=`official`)
  - Description: Direct download for the Minecraft Java Edition launcher without using the Microsoft Store.
  - Action: Opens an external URL in the default browser: `https://www.minecraft.net/download`
- **Download Prism Launcher (unofficial, requires license)** (id=`minecraft-prism-launcher`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Open-source Minecraft launcher with modpack management. Requires a valid Minecraft license.
  - Action: Opens an external URL in the default browser: `https://github.com/PrismLauncher/PrismLauncher/releases`
- **Download Freesm Launcher (unofficial, no license required)** (id=`minecraft-freesm-launcher`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Fork of Prism Launcher that supports playing without a Minecraft license.
  - Action: Opens an external URL in the default browser: `https://github.com/FreesmTeam/FreesmLauncher/releases`
- **Download MultiMC Launcher (outdated, unofficial, requires license)** (id=`minecraft-multimc`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Legacy MultiMC launcher — outdated, superseded by Prism. Requires a valid Minecraft license.
  - Action: Opens an external URL in the default browser: `https://github.com/MultiMC/Launcher/releases`
- **Browse Java Edition mods on Modrinth** (id=`minecraft-mods-modrinth`; kind=`link`; control=`button`; source=`official`)
  - Description: Modrinth mod repository for Minecraft Java Edition mods and modpacks.
  - Action: Opens an external URL in the default browser: `https://modrinth.com/mods`
- **Browse Java Edition mods on CurseForge** (id=`minecraft-mods-curseforge`; kind=`link`; control=`button`; source=`official`)
  - Description: CurseForge mod repository for Minecraft Java Edition mods and modpacks.
  - Action: Opens an external URL in the default browser: `https://www.curseforge.com/minecraft`
- **Download Modrinth app (mod manager)** (id=`minecraft-modrinth-app`; kind=`link`; control=`button`; source=`official`)
  - Description: Modrinth desktop app for convenient mod and modpack installation. Requires a Minecraft license.
  - Action: Opens an external URL in the default browser: `https://modrinth.com/app`
- **Download CurseForge app (mod manager)** (id=`minecraft-curseforge-app`; kind=`link`; control=`button`; source=`official`)
  - Description: CurseForge desktop app for convenient mod and modpack installation.
  - Action: Opens an external URL in the default browser: `https://www.curseforge.com/download/app`
- **Download Minecraft server (Java or Bedrock — official)** (id=`minecraft-server`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Minecraft server software download page for both Java and Bedrock editions.
  - Action: Opens an external URL in the default browser: `https://www.minecraft.net/download`

### 8. Global Timer Resolution (Optional)

1 subsections, 2 cards. Source: `Manifests\Section08.psd1`.

#### 8.0 Global Timer Resolution

- **Timer Resolution — important notes (v0.3)** (id=`timer-resolution-notes`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin)
  - Description: The old Timer Resolution executable archive is intentionally not shipped in this project. Treat donor material as reference only; source and review any tools separately if you deliberately want to test them.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: There is no local Timer Resolution archive to extract or run. If you obtain timer-resolution tools separately, verify the source/signature, scan the files, and test only if you understand the power, latency, and stability trade-offs. Most users will not need this tweak.
- **What is Global Timer Resolution?** (id=`timer-resolution-what-it-does`; kind=`manual`; control=`checklist`; source=`unofficial`; requires admin)
  - Description: Windows uses a system-wide timer interrupt that defaults to 15.625 ms. Setting a higher resolution (e.g. 0.5 ms) can reduce micro-stutter in games, but it increases CPU power consumption and may destabilise some workloads. Not recommended for most users.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Use this card as background context only. This project does not install or launch Timer Resolution. Only apply a separately sourced utility if you understand the trade-offs; revert by stopping the utility or uninstalling it.

### 9. FPS & Latency Testing

2 subsections, 6 cards. Source: `Manifests\Section09.psd1`.

#### 9.0 Testing Notes

- **v0.4 testing notes — Intel PresentMon & PCLatency** (id=`testing-notes-v04`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Download the .msi installer for the GUI version of Intel PresentMon (as shown in the video), or the x64 .exe for the lightweight console version. PCLatency must now be downloaded manually from GitHub — if flagged by antivirus, add it to Windows Defender exclusions.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: Intel PresentMon: download .msi for the overlay GUI, or x64 .exe for the console version. Console version is lighter and more accurate — display via a second monitor or PowerToys "Always on top". Note: the console version always creates .csv files; delete them when not needed. PCLatency: download from GitHub; add to Defender exclusions if flagged.

#### 9.1 Testing Tools

- **Download CapFrameX** (id=`download-capframex`; kind=`link`; control=`button`; source=`official`)
  - Description: CapFrameX is a frame time capture and analysis tool with an in-game overlay. Records and visualises frametimes, FPS statistics, and GPU/CPU sensor data.
  - Action: Opens an external URL in the default browser: `https://github.com/CXWorld/CapFrameX/releases`
- **Download Intel PresentMon** (id=`download-intel-presentmon`; kind=`link`; control=`button`; source=`official`)
  - Description: Intel PresentMon measures frame presentation latency and FPS using ETW. Available as a GUI overlay (.msi) or lightweight console tool (x64 .exe).
  - Action: Opens an external URL in the default browser: `https://github.com/GameTechDev/PresentMon/releases`
- **Download Nvidia FrameView** (id=`download-nvidia-frameview`; kind=`link`; control=`button`; source=`official`)
  - Description: Nvidia FrameView captures frame times, FPS, and power data. Works with both Nvidia and AMD GPUs.
  - Action: Opens an external URL in the default browser: `https://www.nvidia.com/en-us/geforce/technologies/frameview/`
- **Download PCLatency** (id=`download-pclatency`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: PCLatency measures PC system latency and visualises results from CapFrameX .csv files. May be flagged as false positive by antivirus — add to Defender exclusions if needed.
  - Action: Opens an external URL in the default browser: `https://github.com/notch4ff4/pc-latency-view/releases`
- **Nvidia article — Understanding and measuring PC latency** (id=`nvidia-latency-article`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Nvidia developer article explaining end-to-end PC latency, how to measure it, and what affects it.
  - Action: Opens an external URL in the default browser: `https://developer.nvidia.com/blog/understanding-and-measuring-pc-latency/`

### 10. Recommended Programs

11 subsections, 42 cards. Source: `Manifests\Section10.psd1`.

#### 10.0 Community Resources

- **Viewer-recommended software (Telegram chat topic)** (id=`telegram-viewer-software`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Telegram topic where viewers share their own recommended software picks.
  - Action: Opens an external URL in the default browser: `https://t.me/a11p1ay`

#### 10.1 Browsers

- **Google Chrome** (id=`download-chrome`; kind=`link`; control=`button`; source=`official`)
  - Description: The most widely used browser. Best site compatibility, V8 engine, sync across devices.
  - Action: Opens an external URL in the default browser: `https://www.google.com/chrome/`
- **Brave Browser** (id=`download-brave`; kind=`link`; control=`button`; source=`official`)
  - Description: Chromium-based with built-in ad and tracker blocking. No Google telemetry. Good privacy defaults.
  - Action: Opens an external URL in the default browser: `https://brave.com/`
- **Mozilla Firefox** (id=`download-firefox`; kind=`link`; control=`button`; source=`official`)
  - Description: Independent Gecko engine, not Chromium. Strong privacy defaults and excellent extension ecosystem.
  - Action: Opens an external URL in the default browser: `https://www.mozilla.org/firefox/`
- **Vivaldi** (id=`download-vivaldi`; kind=`link`; control=`button`; source=`official`)
  - Description: Chromium-based. Extreme UI customisation, built-in tab groups, notes, and mail client. For power users.
  - Action: Opens an external URL in the default browser: `https://vivaldi.com/`
- **Zen Browser** (id=`download-zen-browser`; kind=`link`; control=`button`; source=`official`)
  - Description: Firefox-based. Privacy-focused with a clean UI and tab workspaces. Actively developed.
  - Action: Opens an external URL in the default browser: `https://zen-browser.app/`

#### 10.2 System Utilities

- **Download Microsoft PowerToys** (id=`download-powertoys`; kind=`link`; control=`button`; source=`official`)
  - Description: PowerToys adds useful Windows utilities: PowerToys Run, FancyZones, Keyboard Manager, Color Picker, Image Resizer, Auto Dark Mode, and more.
  - Action: Opens an external URL in the default browser: `https://github.com/microsoft/PowerToys/releases`
- **Download Everything (fast file search)** (id=`download-everything`; kind=`link`; control=`button`; source=`official`)
  - Description: Everything indexes all file names on your drives instantly. Sub-second search results across all drives.
  - Action: Opens an external URL in the default browser: `https://www.voidtools.com/`
- **Download ViVeTool (unlock hidden Windows features)** (id=`download-vivetool`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: ViVeTool activates hidden A/B feature flags in Windows. Useful for enabling experimental features before they roll out to your account. Feature IDs are build-specific and change over time.
  - Action: Opens an external URL in the default browser: `https://github.com/thebookisclosed/ViVe/releases`
- **Microsoft PC Manager** (id=`download-pc-manager`; kind=`link`; control=`button`; source=`official`)
  - Description: Official Microsoft utility for RAM cleanup, temp file removal, and system health overview. Opens directly in the Microsoft Store.
  - Action: Opens an external URL in the default browser: `https://apps.microsoft.com/detail/9pm860492szd`
- **Microsoft PC Manager — direct .msix download (if Store unavailable)** (id=`pc-manager-msix-bypass`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Use store.rg-adguard.net to get the direct .msix package link. Paste the Store URL into the search box to obtain the download link.
  - Action: Opens an external URL in the default browser: `https://store.rg-adguard.net/`
- **Download Ventoy (bootable USB creator)** (id=`download-ventoy`; kind=`link`; control=`button`; source=`official`)
  - Description: Ventoy creates a multiboot USB drive — just copy ISO files onto it, no re-flashing needed.
  - Action: Opens an external URL in the default browser: `https://github.com/ventoy/Ventoy`
- **Download PathScan (path length viewer)** (id=`download-pathscan`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: PathScan displays folder and file path lengths, helping identify paths that exceed the Windows 260-character limit.
  - Action: Opens an external URL in the default browser: `https://www.softpedia.com/get/System/File-Management/Path-Scan.shtml#download`

#### 10.3 File Management

- **Download ExplorerTabUtility (improved Explorer tabs)** (id=`download-explorer-tab-utility`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: ExplorerTabUtility forces all Explorer windows to open as tabs instead of new windows. Adds browser-like tab shortcuts (Ctrl+D, Ctrl+Shift+T). On Windows 25H2+, the built-in option "open folders in new tab" already covers most cases, but ETU still adds hotkey support.
  - Action: Opens an external URL in the default browser: `https://github.com/w4po/ExplorerTabUtility/releases`
- **Download Symbolic11 (symlink manager)** (id=`download-symbolic11`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: GUI tool for conveniently creating and managing symbolic links on Windows.
  - Action: Opens an external URL in the default browser: `https://github.com/Benisgo/Symbolic11`
- **Download Nilesoft Shell (custom context menu)** (id=`download-nilesoft-shell`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Nilesoft Shell lets you build a fully custom right-click context menu, replacing the default Windows 11 context menu.
  - Action: Opens an external URL in the default browser: `https://nilesoft.org/download`

#### 10.4 Uninstallers

- **Download Bulk Crap Uninstaller (BCUninstaller)** (id=`download-bulk-crap-uninstaller`; kind=`link`; control=`button`; source=`official`)
  - Description: Open-source batch uninstaller that removes apps including leftovers, supports silent uninstall, and lists Store/Chocolatey/Scoop packages.
  - Action: Opens an external URL in the default browser: `https://github.com/Klocman/Bulk-Crap-Uninstaller`
- **Download Revo Uninstaller Free** (id=`download-revo-uninstaller`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Revo Uninstaller removes programs and then scans for leftover registry entries and files.
  - Action: Opens an external URL in the default browser: `https://www.revouninstaller.com/products/revo-uninstaller-free/`

#### 10.5 Security & Privacy

- **Download Microsoft Safety Scanner (on-demand AV scan)** (id=`download-microsoft-safety-scanner`; kind=`link`; control=`button`; source=`official`)
  - Description: Free on-demand malware scanner from Microsoft. Does not replace a real-time antivirus — use for one-time scanning.
  - Action: Opens an external URL in the default browser: `https://learn.microsoft.com/en-us/defender-endpoint/safety-scanner-download`
- **Download Kaspersky Virus Removal Tool** (id=`download-kaspersky-vrt`; kind=`link`; control=`button`; source=`official`)
  - Description: Free standalone virus removal tool from Kaspersky. Useful for scanning a system you suspect is infected.
  - Action: Opens an external URL in the default browser: `https://www.kaspersky.ru/downloads/free-virus-removal-tool`
- **VirusTotal — online file & URL scanner** (id=`virustotal`; kind=`link`; control=`button`; source=`official`)
  - Description: Scan any file or URL against 70+ antivirus engines simultaneously.
  - Action: Opens an external URL in the default browser: `https://www.virustotal.com/gui/home/upload`
- **Download KeePassXC (password manager)** (id=`download-keepassxc`; kind=`link`; control=`button`; source=`official`)
  - Description: Open-source offline password manager. Keeps all credentials in an encrypted local database — no cloud sync required.
  - Action: Opens an external URL in the default browser: `https://github.com/keepassxreboot/keepassxc/releases/tag/2.7.10`
- **Download KeePass2Android (Android companion app)** (id=`download-keepass2android`; kind=`link`; control=`button`; source=`official`)
  - Description: Android app that opens KeePass .kdbx databases. Sync the database file via cloud or LAN to use passwords on mobile.
  - Action: Opens an external URL in the default browser: `https://github.com/PhilippC/keepass2android/releases`
- **Download VeraCrypt (disk encryption)** (id=`download-veracrypt`; kind=`link`; control=`button`; source=`official`)
  - Description: Open-source full-disk and container encryption. Successor to TrueCrypt, supports AES, Twofish, and Serpent.
  - Action: Opens an external URL in the default browser: `https://github.com/veracrypt/VeraCrypt/releases`

#### 10.6 Media & Communication

- **Download Telegram Desktop Portable** (id=`download-telegram`; kind=`link`; control=`button`; source=`official`)
  - Description: Portable version of Telegram Desktop — runs without installation, easy to move between PCs.
  - Action: Opens an external URL in the default browser: `https://desktop.telegram.org/`
- **Download OBS Studio (screen recording & streaming)** (id=`download-obs`; kind=`link`; control=`button`; source=`official`)
  - Description: Open-source screen recorder and live streaming software. Supports replay buffers, scene switching, and many plugins.
  - Action: Opens an external URL in the default browser: `https://github.com/obsproject/obs-studio/releases`
- **Download 3D YouTube Downloader** (id=`download-3d-youtube-downloader`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Convenient GUI downloader for YouTube, Vimeo, and many other video sites. Supports playlists and various quality options.
  - Action: Opens an external URL in the default browser: `https://yd.3dyd.com/download/`
- **Download MPC-HC (media player)** (id=`download-mpc-hc`; kind=`link`; control=`button`; source=`official`)
  - Description: Lightweight open-source media player with MadVR, LAV Filters, and subtitle support. Successor to the original MPC-HC.
  - Action: Opens an external URL in the default browser: `https://github.com/clsid2/mpc-hc/releases`
- **Download LosslessCut (fast video trimmer)** (id=`download-lossless-cut`; kind=`link`; control=`button`; source=`official`)
  - Description: FFMPEG-based video trimmer that cuts video without re-encoding. Instant lossless cuts for any format.
  - Action: Opens an external URL in the default browser: `https://github.com/mifi/lossless-cut/releases`
- **Download DaVinci Resolve (free professional video editor)** (id=`download-davinci-resolve`; kind=`link`; control=`button`; source=`official`)
  - Description: Industry-standard professional video editing suite by Blackmagic Design. Free version has no watermarks or time limits.
  - Action: Opens an external URL in the default browser: `https://www.blackmagicdesign.com/products/davinciresolve`
- **Download Obsidian (note-taking app)** (id=`download-obsidian`; kind=`link`; control=`button`; source=`official`)
  - Description: Obsidian is a powerful Markdown-based note app with a local-first graph of linked notes. No account required for local use.
  - Action: Opens an external URL in the default browser: `https://github.com/obsidianmd/obsidian-releases/releases`

#### 10.7 Overclocking & Benchmarking

- **Download MSI Afterburner (GPU overclocking & monitoring)** (id=`download-msi-afterburner`; kind=`link`; control=`button`; source=`official`)
  - Description: GPU overclocking, fan control, and in-game overlay tool. Works with all GPU brands despite the MSI name.
  - Action: Opens an external URL in the default browser: `https://www.msi.com/Landing/afterburner/graphics-cards`
- **Download Superposition Benchmark (GPU stress test)** (id=`download-superposition`; kind=`link`; control=`button`; source=`official`)
  - Description: Extreme GPU benchmark by Unigine. Tests GPU stability under heavy load with a visually impressive scene.
  - Action: Opens an external URL in the default browser: `https://benchmark.unigine.com/superposition`
- **Download TestMem5 (RAM stability tester)** (id=`download-testmem5`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: TestMem5 is a fast RAM stress-testing tool popular for validating memory overclocks. Faster than MemTest86 for quick validation.
  - Action: Opens an external URL in the default browser: `https://github.com/CoolCmd/TestMem5/releases`
- **Download CapFrameX (frame capture & analysis)** (id=`download-capframex-bench`; kind=`link`; control=`button`; source=`official`)
  - Description: CapFrameX captures frametimes with an in-game overlay and provides detailed FPS/frametime analysis and sensor logging.
  - Action: Opens an external URL in the default browser: `https://github.com/CXWorld/CapFrameX/releases`

#### 10.8 Audio

- **Download SoundSwitch (hotkey audio device switcher)** (id=`download-soundswitch`; kind=`link`; control=`button`; source=`official`)
  - Description: SoundSwitch lets you switch between audio output and input devices with a configurable keyboard shortcut.
  - Action: Opens an external URL in the default browser: `https://github.com/Belphemur/SoundSwitch/releases`

#### 10.9 Gaming & Account Switching

- **Download TcNo Account Switcher** (id=`download-tcno-account-switcher`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Multi-account switcher for Steam, Epic Games, EA, Origin, Riot, Ubisoft, and more.
  - Action: Opens an external URL in the default browser: `https://github.com/TCNOco/TcNo-Acc-Switcher/releases`
- **Download Fan Control (cooling management)** (id=`download-fan-control-recommended`; kind=`link`; control=`button`; source=`official`)
  - Description: Fan Control provides detailed fan curve configuration for system cooling. Listed here as a general recommended program.
  - Action: Opens an external URL in the default browser: `https://github.com/Rem0o/FanControl.Releases/releases`
- **Download qBittorrent (torrent client)** (id=`download-qbittorrent`; kind=`link`; control=`button`; source=`official`)
  - Description: Free, open-source torrent client without bundled adware. Full-featured with search, RSS, and sequential download.
  - Action: Opens an external URL in the default browser: `https://www.qbittorrent.org/download`

#### 10.10 Smartphone + PC Ecosystem

- **Phone Link — Microsoft ecosystem for Android** (id=`smartphone-pc-phone-link`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Microsoft Phone Link integrates your Android phone with Windows: shared clipboard, notifications, calls, and file transfer. See Section 4 for full setup instructions.
  - Action: Manual checklist. No automatic system change; clicking the pill only marks the item as done.
  - Instruction: For full setup instructions refer to Section 4 (Windows Settings) → Phone Link subsection.
- **Download KDE Connect (cross-platform phone/PC integration)** (id=`download-kde-connect`; kind=`link`; control=`button`; source=`official`)
  - Description: KDE Connect provides clipboard sync, file transfer, notifications, and remote input between Windows and Android/Linux. Open-source alternative to Phone Link.
  - Action: Opens an external URL in the default browser: `https://kdeconnect.kde.org/`
- **Download Plain App (self-hosted phone/PC bridge)** (id=`download-plain-app`; kind=`link`; control=`button`; source=`official`)
  - Description: Plain App is an open-source Android app that exposes your phone as a local web server for file management, clipboard sync, and SMS from your PC browser. No cloud account needed.
  - Action: Opens an external URL in the default browser: `https://github.com/ismartcoding/plain-app/tags`

### 11. Mouse & Keyboard Settings

2 subsections, 3 cards. Source: `Manifests\Section11.psd1`.

#### 11.0 Mouse Settings

- **Gaming mouse myths — 8000 Hz polling, high DPI, mouse acceleration (YouTube)** (id=`mouse-myths-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Video guide debunking common gaming mouse myths: ultra-high polling rates, high DPI advantages, and mouse acceleration effects. Helps understand what settings actually matter for gaming.
  - Action: Opens an external URL in the default browser: `https://www.youtube.com/watch?v=2leo5S5RzRw`
- **Mouse settings guide — DPI, Angle Snap, Ripple Control, polling rate, etc. (Telegram)** (id=`mouse-settings-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Detailed guide covering optimal mouse DPI, Angle Snap, Ripple Control, polling rate selection, and other mouse-specific settings for gaming.
  - Action: Opens an external URL in the default browser: `https://t.me/allp1ay/1211`

#### 11.1 Keyboard Settings

- **Magnetic keyboard setup guide — Rapid Trigger, actuation point, Snap Tap, etc. (YouTube)** (id=`magnetic-keyboard-guide`; kind=`link`; control=`button`; source=`unofficial`)
  - Description: Video guide for configuring Hall-effect / magnetic keyboards: Rapid Trigger, actuation height, Snap Tap (simultaneous opposite directions), and other advanced features.
  - Action: Opens an external URL in the default browser: `https://www.youtube.com/@MAXiM0V/videos`

### 12. Max.mov Tweaks

4 subsections, 14 cards. Source: `Manifests\Section12.psd1`.

Local resources are stored in `Assets\MaxMov`. Old `.reg`, `.bat`, `.cmd`, `.ps1`, `.exe`, `.lnk`, `.url`, and executable archives from the donor pack are removed from resources so users cannot run or open them by accident.

#### 12.0 Max.mov Hub

- **What belongs in Max.mov Tweaks** (id=`maxmov-what-is-this`; kind=`manual`; control=`checklist`; source=`unofficial`)
  - Description: Separate place for the Max.mov pack: profiles, wallpapers, cursors, personalization files, and community gaming notes.
- **Open current Audion Windows Tools folder** (id=`maxmov-open-current-folder`; kind=`script`; control=`button`; source=`official`)
  - Action: Opens the current project folder.
- **Open local Max.mov resources** (id=`maxmov-open-resources-folder`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov`.

#### 12.1 Profiles & Presets

- **Open local personalization pack** (id=`maxmov-open-personalization-pack`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Personalization`.
- **Open local Nvidia profiles/settings** (id=`maxmov-open-nvidia-profile-pack`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Profiles\Nvidia`.
- **Profiles are review-first** (id=`maxmov-profiles-note`; kind=`manual`; control=`checklist`; source=`unofficial`)
  - Description: Old Max.mov profiles should be reviewed before importing through the target app's official tool.
- **Legacy scripts are not shipped here** (id=`maxmov-legacy-files-removed-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Description: Clickable legacy scripts, shortcuts, URL shortcuts, and executable archives are intentionally excluded from `Assets\MaxMov`.

#### 12.2 Wallpapers, Cursors & Visuals

- **Open local wallpapers/cursors** (id=`maxmov-open-wallpapers-cursors`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens local Max.mov visual resources.
- **Install cursor packs manually** (id=`maxmov-cursor-install-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Instruction: Install `.cur`/`.ani` files through Windows Mouse Properties.
- **Apply wallpapers through Personalization** (id=`maxmov-wallpaper-install-note`; kind=`manual`; control=`checklist`; source=`official`)
  - Instruction: Copy wanted images to a user folder and choose them through Windows Personalization.

#### 12.3 Gaming Pack

- **Open local Gaming resources** (id=`maxmov-open-gaming-folder`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Gaming`.
- **Open local Steam/Game Launchers pack** (id=`maxmov-open-steam-launchers-pack`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Gaming\SteamGameLaunchers`.
- **Open local FPS/latency testing pack** (id=`maxmov-open-latency-testing-pack`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Gaming\FPSLatencyTesting`.
- **Open local Timer Resolution notes** (id=`maxmov-open-timer-resolution-pack`; kind=`script`; control=`button`; source=`unofficial`)
  - Action: Opens `Assets\MaxMov\Gaming\TimerResolution` without installing or launching anything; the old executable archive is not shipped.

## Operational Safety Reference

Treat every card according to its action type. An `open` action only navigates to a Windows page, folder, URL, or external utility. A `script` action may change system state. A manual checklist requires the operator to complete and verify the steps. Do not assume that opening a tool applies its recommended configuration.

Before disk, boot, registry, firmware, driver-removal, privacy, or security-policy changes, create a tested rollback path. Depending on the operation this may be a restore point, exported registry branch, driver package, BitLocker recovery key, system image, BIOS profile, or separate backup.

## Recommended Order

Use the sections as a dependency-aware sequence: establish Windows and recovery first, update chipset/network/storage/display drivers, verify disks, configure core Windows behavior, then tune browsers, GPU, monitor, cooling, games, input devices, and optional latency features. Benchmark before and after optional tweaks.

Do not apply several performance changes at once. A one-change-at-a-time approach makes instability, latency regression, or power/thermal problems reversible and measurable.

## Driver And Update Review

Confirm hardware IDs and system model before installing a driver. Prefer the device or OEM source when it provides platform-specific packages. Create a recovery path before firmware or storage-controller updates. After installation, review Device Manager, Event Viewer, reboot requirements, and the actual driver version.

Avoid generic driver-removal or cleanup operations when the current package is needed for recovery, display output, network access, or storage boot.

## Disk And Storage Review

Verify disk identity by model, serial, capacity, and existing partitions, not drive letter alone. Drive letters and removable-disk order may change. Back up data and recovery keys before initialization, conversion, partitioning, formatting, encryption, or destructive cleanup.

After storage changes, verify boot, BitLocker state, filesystem health, expected partitions, free space, and backup accessibility.

## Display, GPU, And Cooling

Record the baseline resolution, refresh rate, color mode, GPU driver, temperatures, fan behavior, and stability. Apply display and performance changes separately. Confirm that the monitor is using the intended connection and refresh rate and that cooling remains safe under sustained load.

Overclocking, undervolting, fan curves, and power limits require measurement and a known reset path. A profile stable in a short benchmark may fail during long gaming or compute workloads.

## FPS And Latency

Use consistent test scenes, background processes, power plans, and measurement tools. Compare averages, lows, frame-time consistency, input latency, temperature, clocks, and power rather than one peak FPS value.

Timer-resolution and latency tools are optional. Do not stack several tools or leave an undocumented background utility running. Confirm that changes are removed after reboot or Exit when that is the intended behavior.

## Network, Browser, And Privacy

Review account, synchronization, proxy, DNS, certificate, extension, telemetry, and policy implications before applying a preset. Enterprise-managed devices may restore settings or reject local changes. Do not weaken browser or Windows security merely to remove a warning.

## Recovery After A Problem

Stop applying new cards. Record the last change, symptoms, reboot state, and relevant logs. Use the narrowest rollback: restore the previous setting or driver before using a broad system restore. For boot or storage failures, use prepared recovery media and keys rather than improvised destructive commands.

## Completion Checklist

- Windows Update and Device Manager show no unexplained failures.
- Storage, encryption, backup, and recovery paths are verified.
- Display mode, refresh rate, color, and scaling are correct.
- Cooling is stable under load.
- Optional performance changes have before/after measurements.
- Startup, tray, timer, and background utilities are known.
- Important configuration and rollback notes are recorded.

## Interface Map Maintenance

Treat the GUI map or manifest as the structured source for section order, card titles, controls, defaults, warnings, and action commands. This guide remains the human-readable layer: it explains prerequisites, risk, expected effect, verification, and rollback. When a card is added or renamed, update both layers so the interface, presentations, and operator training stay aligned.

A release review should verify that every visible action has a meaningful description and that dangerous operations identify elevation, reboot, service, driver, registry, disk, privacy, or network impact before execution. `MaxMovGuide = $true` records exact presence in the guide; add `MaxMovApproved = $true` only after separate explicit approval by Max.mov. Both fields affect card labels only, never execution.
