@{
    Id    = 'windows-installation'
    Title = 'Windows Installation'
    Order = 0
    Ru    = @{ Title = 'Установка Windows' }

    Subsections = @(

        # ── 0. Data & Passwords ───────────────────────────────────────────────
        @{
            Id    = 'data-passwords'
            Title = 'Data & Passwords'
            Order = 0
            Ru    = @{ Title = 'Данные и пароли' }
            Tweaks = @(
                @{
                    Id      = 'install-portable-powershell7'
                    Title   = 'Install portable PowerShell 7 for this toolkit'
                    Desc    = 'Downloads and installs portable PowerShell 7 into Engine\PowerShell. This keeps the toolkit stable and self-contained while configuring Windows, even on a fresh system without system pwsh.'
                    Kind    = 'script'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    CanRevert = $false
                    ButtonLabel = 'Install portable PowerShell 7'
                    ActionNote  = 'Runs Install\Install-Portable-PowerShell.cmd /NOPAUSE and writes the installer output to the Terminal panel.'
                    Url     = 'https://github.com/PowerShell/PowerShell/releases'
                    # Run through Invoke-NativeProcess, not the pipeline: the app hides its console, so a
                    # .cmd that ever waits for a keypress would block invisibly and forever. The runner
                    # closes stdin, decodes the console code page, and enforces a timeout instead.
                    Apply = {
                        $root = $script:AppRoot
                        if ([string]::IsNullOrWhiteSpace($root)) { throw 'App root is not available.' }

                        $installer = Join-Path $root 'Install\Install-Portable-PowerShell.cmd'
                        if (-not (Test-Path $installer)) {
                            Write-OperationOutput ((Get-UiText 'InstallerScriptMissingFmt' 'Installer not found: {0}. Nothing was changed.') -f $installer)
                            Set-TweakStepFailed
                            return
                        }

                        $r = Invoke-NativeProcess -FilePath $env:ComSpec -Encoding oem -TimeoutSeconds 900 -Arguments @('/c', $installer, '/NOPAUSE')
                        if ($r.Cancelled) {
                            Write-OperationOutput (Get-UiText 'InstallCancelledByUser' 'Cancelled — the installer was stopped. Nothing is left running in the background.')
                            Set-TweakStepFailed
                        } elseif ($r.TimedOut) {
                            Write-OperationOutput ((Get-UiText 'InstallerScriptTimedOutFmt' 'The installer did not respond for {0} minutes and was stopped so the app does not stay stuck. Nothing is running in the background.') -f 15)
                            Set-TweakStepFailed
                        } elseif ($r.ExitCode -eq 0) {
                            Write-OperationOutput (Get-UiText 'InstallerScriptDone' 'The installer finished successfully.')
                        } else {
                            Write-OperationOutput ((Get-UiText 'InstallerScriptFailedFmt' 'The installer exited with code {0}. The step did not complete — see the output above. Nothing is running in the background.') -f $r.ExitCode)
                            Set-TweakStepFailed
                        }
                    }
                    Detect = {
                        $root = $script:AppRoot
                        if ([string]::IsNullOrWhiteSpace($root)) { return $false }
                        Test-Path (Join-Path $root 'Engine\PowerShell\pwsh.exe')
                    }
                    Ru = @{
                        Title       = 'Установить portable PowerShell 7 для пакета'
                        Desc        = 'Скачивает и устанавливает портативный PowerShell 7 в Engine\PowerShell. Это повышает стабильность работы пакета во время настройки Windows и позволяет запускаться автономно даже на свежей системе без системного pwsh.'
                        ButtonLabel = 'Установить portable PowerShell 7'
                        ActionNote  = 'Запускает Install\Install-Portable-PowerShell.cmd /NOPAUSE и выводит лог установщика в панель Terminal.'
                    }
                }
                @{
                    Id      = 'program-guide-readme-pdf'
                    Title   = 'Project documentation'
                    Desc    = 'Opens the complete documentation folder: user guides, technical README files, video companion notes, and other maintained project materials.'
                    Kind    = 'docs'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ActionNote = 'Opens the Docs folder without choosing a specific file for the user.'
                    Ru = @{
                        Title      = 'Документация проекта'
                        Desc       = 'Открывает весь каталог документации: руководства пользователя, технические README, материалы к ролику и другие поддерживаемые документы проекта.'
                        ActionNote = 'Открывает папку Docs, не выбирая за пользователя конкретный файл.'
                    }
                }
                @{
                    Id      = 'rename-drives'
                    MaxMovGuide = $true
                    Title   = 'Rename disks to their drive letters'
                    Desc    = 'Open Disk Management to verify and rename your partitions before reinstalling. Helps identify disks correctly after the fresh install.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'diskmgmt.msc'
                    Instruction = 'Open Disk Management. Right-click each volume and rename it to match its drive letter (e.g. "C", "D"). This makes it easier to identify partitions during installation.'
                    Ru = @{
                        Title       = 'Переименовать диски по их буквам'
                        Desc        = 'Откройте Управление дисками и переименуйте разделы перед переустановкой. Поможет правильно идентифицировать диски после чистой установки.'
                        Instruction = 'Откройте Управление дисками. Щёлкните правой кнопкой по каждому тому и переименуйте его по букве диска (например, «C», «D»). Это упростит определение разделов при установке.'
                    }
                }
                @{
                    Id      = 'check-data-backup'
                    MaxMovGuide = $true
                    Title   = 'Back up your data'
                    Desc    = 'Open File Explorer and verify that all important files are backed up to an external drive or cloud storage before reinstalling Windows.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'shell:ThisPCFolder'
                    Instruction = 'Check all drives for documents, downloads, desktop files, and any other data you want to keep. Copy them to an external drive or cloud storage.'
                    Ru = @{
                        Title       = 'Сделать резервную копию данных'
                        Desc        = 'Откройте Проводник и убедитесь, что все важные файлы скопированы на внешний диск или в облако перед переустановкой Windows.'
                        Instruction = 'Проверьте все диски: документы, загрузки, файлы рабочего стола и любые другие данные, которые хотите сохранить. Скопируйте их на внешний диск или в облако.'
                    }
                }
                @{
                    Id      = 'check-browser-passwords'
                    MaxMovGuide = $true
                    Title   = 'Export browser passwords'
                    Desc    = 'Export your saved passwords from Chrome before reinstalling. Navigate to chrome://settings/passwords and use the export option.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open Chrome and go to chrome://settings/passwords. Click the three-dot menu next to "Saved passwords" and choose "Export passwords". Save the file to a backup location.'
                    Ru = @{
                        Title       = 'Экспортировать пароли из браузера'
                        Desc        = 'Экспортируйте сохранённые пароли из Chrome перед переустановкой. Перейдите на chrome://settings/passwords и воспользуйтесь функцией экспорта.'
                        Instruction = 'Откройте Chrome и перейдите на chrome://settings/passwords. Нажмите меню с тремя точками рядом с «Сохранённые пароли» и выберите «Экспортировать пароли». Сохраните файл в надёжное место.'
                    }
                }
                @{
                    Id      = 'check-account-access'
                    MaxMovGuide = $true
                    Title   = 'Verify account access (Microsoft, Steam, etc.)'
                    Desc    = 'Make sure you can log in to all important accounts — Microsoft, Steam, Epic Games, etc. — before reinstalling. Note down passwords or recovery options.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Test logins for: Microsoft/Xbox account, Steam, Epic Games, EA App, and any other services you use. If 2FA is involved, confirm your authenticator app works. Write down recovery codes if needed.'
                    Ru = @{
                        Title       = 'Проверить доступ к аккаунтам (Microsoft, Steam и др.)'
                        Desc        = 'Убедитесь, что можете войти во все важные аккаунты — Microsoft, Steam, Epic Games и др. — перед переустановкой. Запишите пароли или варианты восстановления.'
                        Instruction = 'Проверьте вход в: аккаунт Microsoft/Xbox, Steam, Epic Games, EA App и другие сервисы. Если используется двухфакторная аутентификация — убедитесь, что приложение-аутентификатор работает. При необходимости запишите коды восстановления.'
                    }
                }
            )
        }

        # ── 1. GPU Driver Preparation ─────────────────────────────────────────
        @{
            Id    = 'gpu-driver-prep'
            Title = 'GPU Driver Preparation'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Подготовка драйвера GPU' }
            Tweaks = @(
                @{
                    Id      = 'laptop-igpu-note'
                    Title   = 'Laptop note: download drivers for BOTH GPU and iGPU'
                    Desc    = 'On most laptops the display is wired to the integrated GPU (iGPU), not the discrete GPU. Do NOT disable the iGPU. Download drivers for both the integrated and discrete graphics adapters.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'On a laptop with dual GPUs (e.g. Intel UHD + RTX 3050): download the driver for Intel UHD (iGPU) AND the Nvidia/AMD driver for the discrete GPU. Never disable the iGPU on a laptop — the built-in display is connected through it.'
                    Ru = @{
                        Title       = 'Ноутбук: скачайте драйверы для ОБОИХ видеоадаптеров — GPU и iGPU'
                        Desc        = 'На большинстве ноутбуков экран подключён к встроенному GPU (iGPU), а не к дискретному. НЕ отключайте iGPU. Скачайте драйверы для обоих адаптеров.'
                        Instruction = 'На ноутбуке с двумя GPU (например, Intel UHD + RTX 3050): скачайте драйвер Intel UHD (iGPU) И драйвер Nvidia/AMD для дискретного GPU. Никогда не отключайте iGPU на ноутбуке — встроенный экран подключён через него.'
                    }
                }
                @{
                    Id      = 'find-gpu-model'
                    Title   = 'Find your GPU model'
                    Desc    = 'Open Device Manager to check the exact model of your graphics card before downloading the driver.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'devmgmt.msc'
                    Instruction = 'Expand "Display adapters" in Device Manager to find your GPU model name.'
                    Ru = @{
                        Title       = 'Узнать модель GPU'
                        Desc        = 'Откройте Диспетчер устройств, чтобы проверить точную модель видеокарты перед загрузкой драйвера.'
                        Instruction = 'Разверните раздел «Видеоадаптеры» в Диспетчере устройств и найдите название модели GPU.'
                    }
                }
                @{
                    Id      = 'download-nvidia-driver-prep'
                    Title   = 'Download Nvidia GPU driver'
                    Desc    = 'Official Nvidia driver download page. Download the latest Game Ready Driver for your GPU model.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.nvidia.com/en-us/drivers/'
                    Ru = @{
                        Title = 'Скачать драйвер GPU Nvidia'
                        Desc  = 'Официальная страница загрузки драйверов Nvidia. Скачайте последний Game Ready Driver для своей модели GPU.'
                    }
                }
                @{
                    Id      = 'download-amd-driver-prep'
                    Title   = 'Download AMD GPU driver'
                    Desc    = 'Official AMD driver download page. Download the latest Adrenalin driver for your GPU.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.amd.com/en/support/download/drivers.html'
                    Ru = @{
                        Title = 'Скачать драйвер GPU AMD'
                        Desc  = 'Официальная страница загрузки драйверов AMD. Скачайте последний драйвер Adrenalin для своего GPU.'
                    }
                }
                @{
                    Id      = 'download-intel-gpu-driver-prep'
                    Title   = 'Download Intel GPU / Arc driver (unavailable from Russian IPs)'
                    Desc    = 'Official Intel driver download center. Download the Intel graphics driver for your iGPU or Arc GPU.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download-center/home.html'
                    Ru = @{
                        Title = 'Скачать драйвер GPU / Arc от Intel (недоступно с российских IP)'
                        Desc  = 'Официальный центр загрузки драйверов Intel. Скачайте графический драйвер Intel для вашего iGPU или Arc GPU.'
                    }
                }
                @{
                    Id      = 'move-drivers-to-usb'
                    Title   = 'Move driver installers to a USB drive or separate partition'
                    Desc    = 'After downloading GPU drivers, copy the installer files to a USB drive or a non-system partition so they are accessible immediately after Windows reinstall, before connecting to the internet.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Copy the downloaded driver installer (.exe) files to a USB flash drive or a secondary drive/partition (e.g. D:). This ensures you can install drivers before going online on the fresh Windows installation.'
                    Ru = @{
                        Title       = 'Скопировать установщики драйверов на USB или отдельный раздел'
                        Desc        = 'После загрузки драйверов GPU скопируйте файлы установщиков на USB-накопитель или несистемный раздел — они будут доступны сразу после переустановки Windows, до подключения к интернету.'
                        Instruction = 'Скопируйте скачанные файлы установщиков драйверов (.exe) на USB-флешку или второй диск/раздел (например, D:). Это позволит установить драйверы до выхода в интернет на новой установке Windows.'
                    }
                }
            )
        }

        # ── 2. Chipset & Network Drivers ──────────────────────────────────────
        @{
            Id    = 'chipset-network-drivers'
            Title = 'Chipset & Network Drivers'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Чипсетный и сетевой драйверы' }
            Tweaks = @(
                @{
                    Id      = 'intel-vmd-rst-note'
                    Title   = 'Intel VMD / RST note: disks may not appear during install'
                    Desc    = 'If your SSD does not appear in the Windows installer disk selection screen, disable the Intel VMD controller in BIOS before installing. Alternatively, load the Intel RST driver during setup. See instruction for details.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'If disks are missing during Windows setup: Option A — Disable Intel VMD in BIOS (NVMe RAID / Intel RST setting) before installing. Option B — Extract RST driver from SetupRST.exe using: ./SetupRST.exe -extractdrivers SetupRST_extracted, then copy the extracted folder to a USB drive and load it via "Load Driver" during setup. Intel chipset drivers for modern Intel platforms are delivered via Windows Update automatically after first internet connection.'
                    Ru = @{
                        Title       = 'Примечание Intel VMD / RST: диски могут не отображаться при установке'
                        Desc        = 'Если SSD не отображается на экране выбора диска при установке Windows, отключите контроллер Intel VMD в BIOS перед установкой. Либо загрузите драйвер Intel RST в процессе установки. Подробности — в инструкции.'
                        Instruction = 'Если диски не отображаются при установке Windows: Вариант А — Отключите Intel VMD в BIOS (настройка NVMe RAID / Intel RST) до начала установки. Вариант Б — Извлеките драйвер RST из SetupRST.exe командой: ./SetupRST.exe -extractdrivers SetupRST_extracted, скопируйте извлечённую папку на USB и загрузите его через «Загрузить драйвер» при установке. Чипсетные драйверы Intel для современных платформ поставляются через Центр обновления Windows автоматически после первого подключения к интернету.'
                    }
                }
                @{
                    Id      = 'download-amd-chipset'
                    Title   = 'Download AMD chipset driver'
                    Desc    = 'Official AMD driver page. Chipset drivers for AMD platforms are available here.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.amd.com/en/support/download/drivers.html'
                    Ru = @{
                        Title = 'Скачать чипсетный драйвер AMD'
                        Desc  = 'Официальная страница драйверов AMD. Здесь доступны чипсетные драйверы для платформ AMD.'
                    }
                }
                @{
                    Id      = 'download-intel-chipset-old'
                    Title   = 'Download Intel chipset INF driver (older chipsets only, unavailable from Russian IPs)'
                    Desc    = 'Intel chipset INF utility for older Intel platforms. Modern Intel chipsets receive updates exclusively via Windows Update.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download/19347/chipset-inf-utility.html'
                    Ru = @{
                        Title = 'Скачать Intel chipset INF driver (только для старых чипсетов, недоступно с российских IP)'
                        Desc  = 'Утилита Intel chipset INF для старых платформ Intel. Современные чипсеты Intel получают обновления исключительно через Центр обновления Windows.'
                    }
                }
                @{
                    Id      = 'download-intel-rst'
                    Title   = 'Download Intel RST driver (unavailable from Russian IPs)'
                    Desc    = 'Intel Rapid Storage Technology driver. Required only if your SSD is not detected during Windows setup and you need VMD/RST support.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/search.html?ws=text#sort=relevancy&layout=table&f:downloadtype=[Drivers]&f:@operatingsystem_en=[Windows%2011%20Family*]&f:@tabfilter=[Downloads]&f:@stm_10385_en=[Memory%20and%20Storage]'
                    Ru = @{
                        Title = 'Скачать Intel RST driver (недоступно с российских IP)'
                        Desc  = 'Драйвер Intel Rapid Storage Technology. Нужен только если SSD не определяется при установке Windows и требуется поддержка VMD/RST.'
                    }
                }
                @{
                    Id      = 'motherboard-support-page'
                    Title   = 'Download drivers from motherboard manufacturer website'
                    Desc    = 'Visit your motherboard manufacturer support page (ASUS, MSI, Gigabyte, ASRock) to download the latest chipset and LAN drivers for your specific board model.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Search for your motherboard model on the manufacturer website (e.g. asus.com/support, msi.com/support). Download: (1) chipset driver, (2) LAN/Wi-Fi driver. Copy them to your USB drive along with GPU drivers.'
                    Ru = @{
                        Title       = 'Скачать драйверы с сайта производителя материнской платы'
                        Desc        = 'Зайдите на страницу поддержки производителя материнской платы (ASUS, MSI, Gigabyte, ASRock) и скачайте последние чипсетный и LAN-драйверы для вашей конкретной модели.'
                        Instruction = 'Найдите свою модель материнской платы на сайте производителя (например, asus.com/support, msi.com/support). Скачайте: (1) чипсетный драйвер, (2) LAN/Wi-Fi драйвер. Скопируйте их на USB-флешку вместе с драйверами GPU.'
                    }
                }
                @{
                    Id      = 'network-other-manufacturers'
                    Title   = 'Broadcom / Realtek / Intel Killer network drivers (other manufacturers)'
                    Desc    = 'If your network adapter is from Broadcom, Realtek, or Intel Killer and is not recognized after install, search for the driver on the manufacturer website or use the motherboard support page.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'If Windows Update does not install your LAN/Wi-Fi driver automatically, download it from: Realtek — realtek.com, Broadcom — broadcom.com, Intel Killer — killer.intel.com. Or search for it by adapter model in Device Manager.'
                    Ru = @{
                        Title       = 'Сетевые драйверы Broadcom / Realtek / Intel Killer (другие производители)'
                        Desc        = 'Если ваш сетевой адаптер от Broadcom, Realtek или Intel Killer и не определяется после установки, ищите драйвер на сайте производителя или воспользуйтесь страницей поддержки материнской платы.'
                        Instruction = 'Если Центр обновления Windows не установил LAN/Wi-Fi драйвер автоматически, скачайте его с: Realtek — realtek.com, Broadcom — broadcom.com, Intel Killer — killer.intel.com. Или найдите по модели адаптера в Диспетчере устройств.'
                    }
                }
            )
        }

        # ── 3. Create Installation Media ──────────────────────────────────────
        @{
            Id    = 'create-install-media'
            Title = 'Create Installation Media'
            Order = 3
            Ru    = @{ Title = 'Создание установочного носителя' }
            Tweaks = @(
                @{
                    Id      = 'download-win11-mct'
                    Title   = 'Download Windows 11 Installation Media (Media Creation Tool, unavailable from Russian IPs)'
                    Desc    = 'Official Microsoft page to download the Windows 11 Media Creation Tool, which creates a bootable USB installation drive automatically.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/en-us/software-download/windows11'
                    Ru = @{
                        Title = 'Скачать установочный носитель Windows 11 (Media Creation Tool, недоступно с российских IP)'
                        Desc  = 'Официальная страница Microsoft для загрузки Media Creation Tool — автоматически создаёт загрузочный USB-носитель для установки Windows 11.'
                    }
                }
                @{
                    Id      = 'download-win11-iso-official'
                    Title   = 'Download official Windows 11 ISO image (unavailable from Russian IPs)'
                    Desc    = 'Direct ISO download from Microsoft for use with Rufus or manual installation without a USB drive. May be unavailable from Russian IP addresses.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/en-us/software-download/windows11'
                    Ru = @{
                        Title = 'Скачать официальный ISO-образ Windows 11 (недоступно с российских IP)'
                        Desc  = 'Прямая загрузка ISO с серверов Microsoft для использования с Rufus или установки без USB. Может быть недоступно с российских IP-адресов.'
                    }
                }
                @{
                    Id      = 'download-win11-uup-dump'
                    Title   = 'Download Windows 11 images via UUP Dump (available from Russia)'
                    Desc    = 'Alternative source for Windows 11 ISO images including those built via UUP Dump. Available from Russian IP addresses.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.comss.ru/list.php?c=windows10_update'
                    Ru = @{
                        Title = 'Скачать Windows 11 через UUP Dump (доступно из России)'
                        Desc  = 'Альтернативный источник ISO-образов Windows 11, включая сборки через UUP Dump. Доступно с российских IP-адресов.'
                    }
                }
                @{
                    Id      = 'download-rufus'
                    MaxMovGuide = $true
                    Title   = 'Download Rufus (bootable USB creator)'
                    Desc    = 'Rufus creates bootable USB installation drives from ISO images. Use it to write the Windows 11 ISO onto a USB flash drive (8GB+ recommended).'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/pbatard/rufus/releases'
                    Ru = @{
                        Title = 'Скачать Rufus (создание загрузочного USB)'
                        Desc  = 'Rufus создаёт загрузочные USB-носители из ISO-образов. Используйте для записи ISO Windows 11 на USB-флешку (рекомендуется 8 ГБ+).'
                    }
                }
                @{
                    Id      = 'create-usb-drive'
                    Title   = 'Create bootable USB installation drive'
                    Desc    = 'Use Rufus to write the Windows 11 ISO to a USB flash drive. In Rufus, select the ISO file, choose the target USB drive, and click Start. Use GPT partition scheme for UEFI systems.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = '1. Open Rufus. 2. Select your USB drive (8GB+). 3. Click "SELECT" and choose the Windows 11 ISO. 4. Partition scheme: GPT. Target system: UEFI (non-CSM). 5. File system: NTFS. 6. Click START. Wait for completion. The USB drive is now bootable.'
                    Ru = @{
                        Title       = 'Создать загрузочный USB-носитель для установки'
                        Desc        = 'Используйте Rufus для записи ISO Windows 11 на USB-флешку. В Rufus выберите ISO-файл, целевой USB-накопитель и нажмите «Старт». Для UEFI-систем используйте схему разделов GPT.'
                        Instruction = '1. Откройте Rufus. 2. Выберите USB-накопитель (8 ГБ+). 3. Нажмите «ВЫБРАТЬ» и укажите ISO-образ Windows 11. 4. Схема раздела: GPT. Целевая система: UEFI (не CSM). 5. Файловая система: NTFS. 6. Нажмите «СТАРТ». Дождитесь завершения. USB-накопитель готов к загрузке.'
                    }
                }
            )
        }

        # ── 4. Install Without USB (Optional) ────────────────────────────────
        @{
            Id    = 'install-without-usb'
            Title = 'Install Without USB (Optional)'
            Order = 4
            MaxMovGuide = $true
            Ru    = @{ Title = 'Установка без USB (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'no-usb-note'
                    Title   = 'Note: not recommended if switching from Legacy to UEFI'
                    Desc    = 'Installing without a USB drive by creating a temporary 12GB partition works on most systems, but may not be suitable if you are also switching from Legacy BIOS to UEFI boot mode.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'If you are switching from Legacy/MBR to UEFI/GPT, use a USB drive instead. This method is best for a clean reinstall on an already-UEFI system.'
                    Ru = @{
                        Title       = 'Примечание: не рекомендуется при переходе с Legacy на UEFI'
                        Desc        = 'Установка без USB-носителя через создание временного раздела на 12 ГБ работает на большинстве систем, но не подходит при переходе с Legacy BIOS на режим загрузки UEFI.'
                        Instruction = 'Если вы переходите с Legacy/MBR на UEFI/GPT — используйте USB-накопитель. Этот метод лучше всего подходит для чистой переустановки на системе, уже работающей в режиме UEFI.'
                    }
                }
                @{
                    Id      = 'open-disk-management-partition'
                    Title   = 'Open Disk Management to create the install partition'
                    Desc    = 'Open Disk Management to shrink the system drive by 12288 MB and create a new simple volume for the Windows installation files.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'diskmgmt.msc'
                    Instruction = '1. Right-click the system drive (C:) → Shrink Volume. 2. Enter 12288 MB to shrink. 3. After shrink, right-click the new unallocated space → New Simple Volume. 4. Format as NTFS, label it "Win11". 5. If the shrink fails, see the troubleshooting note below.'
                    Ru = @{
                        Title       = 'Открыть Управление дисками для создания установочного раздела'
                        Desc        = 'Откройте Управление дисками, чтобы сжать системный диск на 12288 МБ и создать новый простой том для установочных файлов Windows.'
                        Instruction = '1. Щёлкните правой кнопкой по системному диску (C:) → Сжать том. 2. Введите 12288 МБ для сжатия. 3. После сжатия щёлкните правой кнопкой по появившейся нераспределённой области → Создать простой том. 4. Отформатируйте как NTFS, назовите «Win11». 5. Если сжатие не удаётся — см. примечание по устранению проблем ниже.'
                    }
                }
                @{
                    Id      = 'no-usb-shrink-errors'
                    Title   = 'Troubleshoot: cannot shrink volume (USN journal / pagefile)'
                    Desc    = 'If Disk Management cannot shrink the volume, the USN journal or pagefile may be blocking it. Common errors: $Extend\$UsnJrnl (delete journal), pagefile.sys (disable pagefile), $Mft::$BITMAP (use a different drive or method).'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'To delete USN journal, open an elevated CMD and run: fsutil usn deletejournal /D C: — then recreate with: fsutil usn createjournal m=0 a=0 C:. To disable pagefile: System Properties → Advanced → Performance Settings → Advanced → Virtual Memory → No paging file. To disable System Protection: System Properties → System Protection → select C: → Configure → Disable. If $Mft::$BITMAP appears, use a different disk or installation method.'
                    Ru = @{
                        Title       = 'Устранение проблем: невозможно сжать том (журнал USN / файл подкачки)'
                        Desc        = 'Если Управление дисками не может сжать том, это может блокировать журнал USN или файл подкачки. Частые ошибки: $Extend\$UsnJrnl (удалить журнал), pagefile.sys (отключить файл подкачки), $Mft::$BITMAP (использовать другой диск или метод).'
                        Instruction = 'Для удаления журнала USN откройте командную строку от имени администратора и выполните: fsutil usn deletejournal /D C: — затем пересоздайте: fsutil usn createjournal m=0 a=0 C:. Для отключения файла подкачки: Свойства системы → Дополнительно → Параметры быстродействия → Дополнительно → Виртуальная память → Без файла подкачки. Для отключения защиты системы: Свойства системы → Защита системы → выберите C: → Настроить → Отключить. При ошибке $Mft::$BITMAP используйте другой диск или метод установки.'
                    }
                }
                @{
                    Id      = 'open-event-viewer-shrink'
                    Title   = 'Check Event Viewer if shrink fails'
                    Desc    = 'If Disk Management refuses to shrink the volume and gives no clear reason, Event Viewer may show which file is blocking the operation.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'eventvwr.msc'
                    Instruction = 'In Event Viewer → Windows Logs → Application, look for events from source "defrag" around the time of the failed shrink attempt. The event text will show the file that is preventing the shrink.'
                    Ru = @{
                        Title       = 'Проверить Просмотр событий если сжатие не удаётся'
                        Desc        = 'Если Управление дисками отказывается сжимать том без явного объяснения, Просмотр событий может показать, какой файл блокирует операцию.'
                        Instruction = 'В Просмотре событий → Журналы Windows → Приложение ищите события с источником «defrag» в момент неудачной попытки сжатия. В тексте события будет указан файл, препятствующий сжатию.'
                    }
                }
                @{
                    Id      = 'no-usb-cmd-method'
                    Title   = 'No-USB install: CMD method (copy ISO files to Win11 partition)'
                    Desc    = 'Download the Windows 11 ISO, mount it in File Explorer (double-click), and copy all files to the 12GB Win11 partition. Then boot into it via Restart / Advanced Startup.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Instruction = '1. Download the Windows 11 ISO. 2. Double-click the ISO to mount it as a drive letter. 3. Copy ALL files from the mounted ISO to the Win11 partition (12GB). 4. To boot into it: open Restart advanced startup options. Alternatively reboot — most motherboards will detect and boot the Win11 partition automatically.'
                    Ru = @{
                        Title       = 'Установка без USB: метод CMD (копирование файлов ISO на раздел Win11)'
                        Desc        = 'Скачайте ISO Windows 11, смонтируйте его в Проводнике (двойной щелчок) и скопируйте все файлы на 12-гигабайтный раздел Win11. Затем загрузитесь с него через Перезагрузка / Дополнительные параметры запуска.'
                        Instruction = '1. Скачайте ISO Windows 11. 2. Дважды щёлкните по ISO для монтирования как буква диска. 3. Скопируйте ВСЕ файлы с смонтированного ISO на раздел Win11 (12 ГБ). 4. Для загрузки с него: откройте дополнительные параметры запуска при перезагрузке. Либо просто перезагрузитесь — большинство материнских плат автоматически определят раздел Win11 и загрузятся с него.'
                    }
                }
                @{
                    Id      = 'download-easybcd'
                    Title   = 'Download EasyBCD (no-USB method 2)'
                    Desc    = 'EasyBCD adds a boot entry pointing to the Windows 11 installer WIM file on the Win11 partition, so the PC boots into the installer at next restart without a USB drive.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://neosmart.net/EasyBCD/'
                    Ru = @{
                        Title = 'Скачать EasyBCD (метод без USB 2)'
                        Desc  = 'EasyBCD добавляет запись загрузки, указывающую на WIM-файл установщика Windows 11 на разделе Win11 — ПК загружается в установщик при следующей перезагрузке без USB-накопителя.'
                    }
                }
                @{
                    Id      = 'no-usb-easybcd-method'
                    Title   = 'No-USB install: EasyBCD method'
                    Desc    = 'Use EasyBCD to add a WinPE boot entry pointing to boot.wim in the Win11 partition. On next reboot, select the NST entry to launch the Windows 11 installer.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Instruction = '1. Download the ISO, mount it, copy all files to the Win11 partition. 2. In the Win11 partition, navigate to sources\ and copy the path to boot.wim. 3. Open EasyBCD → Add New Entry → WinPE tab. 4. Paste the path to boot.wim in the Path field. Click the + button. 5. Save and reboot. Select the NST entry in the boot menu to start the installer.'
                    Ru = @{
                        Title       = 'Установка без USB: метод EasyBCD'
                        Desc        = 'Используйте EasyBCD для добавления записи загрузки WinPE, указывающей на boot.wim в разделе Win11. При следующей перезагрузке выберите запись NST для запуска установщика Windows 11.'
                        Instruction = '1. Скачайте ISO, смонтируйте, скопируйте все файлы на раздел Win11. 2. В разделе Win11 перейдите в папку sources\ и скопируйте путь к boot.wim. 3. Откройте EasyBCD → Добавить новую запись → вкладка WinPE. 4. Вставьте путь к boot.wim в поле Path. Нажмите кнопку +. 5. Сохраните и перезагрузите ПК. В меню загрузки выберите запись NST для запуска установщика.'
                    }
                }
            )
        }

        # ── 5. Move Files to USB / Other Drive ───────────────────────────────
        @{
            Id    = 'move-files-to-usb'
            Title = 'Move Max.mov Archive to USB / Other Drive'
            Order = 5
            Ru    = @{ Title = 'Перенести архив Max.mov на USB / другой диск' }
            Tweaks = @(
                @{
                    Id      = 'move-archive-reminder'
                    Title   = 'Move the Audion Windows Tools by Max.mov archive and drivers to a USB or separate drive'
                    Desc    = 'Before reinstalling Windows, ensure the Audion Windows Tools by Max.mov folder and all downloaded driver installers are saved on a USB drive or a non-system partition (e.g. D:). They will be wiped if left on C:.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Copy the entire "Audion Windows Tools by Max.mov" folder and all driver installers to a USB flash drive or a secondary disk partition (NOT C:). Confirm they are accessible before proceeding with the Windows installation.'
                    Ru = @{
                        Title       = 'Перенести архив Audion Windows Tools by Max.mov и драйверы на USB или отдельный диск'
                        Desc        = 'Перед переустановкой Windows убедитесь, что папка «Audion Windows Tools by Max.mov» и все скачанные установщики драйверов сохранены на USB-накопитель или несистемный раздел (например, D:). При нахождении на диске C: они будут уничтожены.'
                        Instruction = 'Скопируйте всю папку «Audion Windows Tools by Max.mov» и все установщики драйверов на USB-флешку или раздел второго диска (НЕ C:). Убедитесь, что они доступны перед началом установки Windows.'
                    }
                }
            )
        }

        # ── 6. BIOS Settings ──────────────────────────────────────────────────
        @{
            Id    = 'bios-settings'
            Title = 'BIOS Settings'
            Order = 6
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройки BIOS' }
            Tweaks = @(
                @{
                    Id      = 'bios-amd-note'
                    Title   = 'AMD note: virtualization may be called SVM or AMD-V'
                    Desc    = 'On AMD systems, the virtualization setting is typically labeled SVM, SVM Mode, or AMD-V instead of Intel VT-x. Disable it to disable VBS / Defender Core Isolation if desired.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS, search for: SVM Mode, SVM, or AMD-V. This is the AMD equivalent of Intel VT-x virtualization. Disable it only if you do not use virtual machines, to allow disabling Windows VBS security features.'
                    Ru = @{
                        Title       = 'Примечание AMD: виртуализация может называться SVM или AMD-V'
                        Desc        = 'На системах AMD параметр виртуализации обычно называется SVM, SVM Mode или AMD-V вместо Intel VT-x. Отключите его для возможности отключения VBS / Core Isolation в Defender.'
                        Instruction = 'В BIOS найдите: SVM Mode, SVM или AMD-V. Это аналог Intel VT-x на платформе AMD. Отключайте только если не используете виртуальные машины — это позволяет отключить функции безопасности Windows VBS.'
                    }
                }
                @{
                    Id      = 'bios-disable-preinstalled-software'
                    Title   = 'Disable manufacturer preinstalled software (MSI Center, ASUS Armoury Crate, etc.)'
                    Desc    = 'Some motherboard manufacturers pre-install bloatware via BIOS (MSI Center, ASUS Armoury Crate). Disable this in BIOS before installing Windows to avoid unwanted software being installed automatically.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS, look for settings related to "APP Center Download & Install", "Armoury Crate", "MSI Center", or similar. Disable them to prevent automatic installation of manufacturer software on the fresh Windows install.'
                    Ru = @{
                        Title       = 'Отключить предустановленное ПО производителя (MSI Center, ASUS Armoury Crate и др.)'
                        Desc        = 'Некоторые производители материнских плат предустанавливают bloatware через BIOS (MSI Center, ASUS Armoury Crate). Отключите это в BIOS до установки Windows, чтобы нежелательное ПО не установилось автоматически.'
                        Instruction = 'В BIOS найдите настройки, связанные с «APP Center Download & Install», «Armoury Crate», «MSI Center» или аналогичными. Отключите их, чтобы предотвратить автоматическую установку ПО производителя на новую Windows.'
                    }
                }
                @{
                    Id      = 'bios-csm-secureboot'
                    Title   = 'Disable CSM Support and enable Secure Boot'
                    Desc    = 'Windows 11 requires UEFI with Secure Boot enabled. Disable CSM (Compatibility Support Module) fully and set Secure Boot to Enabled. Required for proper UEFI installation.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS: (1) Find CSM (Compatibility Support Module) and set it to Disabled. (2) Find Secure Boot and set it to Enabled. If Secure Boot cannot be enabled while CSM is on, disable CSM first, then enable Secure Boot. Save and reboot to confirm UEFI mode is active.'
                    Ru = @{
                        Title       = 'Отключить поддержку CSM и включить Secure Boot'
                        Desc        = 'Windows 11 требует UEFI с включённым Secure Boot. Полностью отключите CSM (Compatibility Support Module) и установите Secure Boot в значение «Включено». Необходимо для корректной UEFI-установки.'
                        Instruction = 'В BIOS: (1) Найдите CSM (Compatibility Support Module) и установите «Выключено». (2) Найдите Secure Boot и установите «Включено». Если Secure Boot не включается при активном CSM, сначала отключите CSM, затем включите Secure Boot. Сохраните и перезагрузитесь для подтверждения режима UEFI.'
                    }
                }
                @{
                    Id      = 'bios-tpm'
                    Title   = 'Enable TPM 2.0 (Intel PTT, AMD fTPM, or physical TPM module)'
                    Desc    = 'Windows 11 requires TPM 2.0. Enable it in BIOS — Intel calls it "Intel PTT", AMD calls it "AMD fTPM". Physical TPM modules also work.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS, find: Intel Platform Trust Technology (PTT) — set to Enabled, or AMD fTPM — set to Enabled. If you have a physical TPM module installed, enable "Discrete TPM" instead. Confirm TPM 2.0 is active in Windows via Win+R → tpm.msc after install.'
                    Ru = @{
                        Title       = 'Включить TPM 2.0 (Intel PTT, AMD fTPM или физический модуль TPM)'
                        Desc        = 'Windows 11 требует TPM 2.0. Включите его в BIOS — у Intel это «Intel PTT», у AMD — «AMD fTPM». Физические модули TPM также поддерживаются.'
                        Instruction = 'В BIOS найдите: Intel Platform Trust Technology (PTT) — установите «Включено», или AMD fTPM — установите «Включено». При наличии физического модуля TPM включите «Discrete TPM». После установки Windows подтвердите активацию TPM 2.0: Win+R → tpm.msc.'
                    }
                }
                @{
                    Id      = 'bios-disable-unused-devices'
                    Title   = 'Disable unused devices (audio, iGPU if not needed) — desktop only'
                    Desc    = 'On desktop PCs, you can disable unused integrated devices (onboard audio, iGPU) in BIOS to reduce system load and potential driver conflicts. Not recommended for laptops.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS (desktop only): consider disabling Onboard Audio if you use a dedicated sound card, and disabling iGPU if you exclusively use a dedicated GPU and the display is not connected to integrated outputs. Do NOT disable iGPU on a laptop — the display depends on it.'
                    Ru = @{
                        Title       = 'Отключить неиспользуемые устройства (аудио, iGPU если не нужен) — только для десктопа'
                        Desc        = 'На десктопных ПК можно отключить неиспользуемые интегрированные устройства (встроенный звук, iGPU) в BIOS для снижения нагрузки и потенциальных конфликтов драйверов. Не рекомендуется для ноутбуков.'
                        Instruction = 'В BIOS (только для десктопа): рассмотрите отключение встроенного звука при использовании дискретной звуковой карты и отключение iGPU при использовании исключительно дискретного GPU без подключения монитора к интегрированным видеовыходам. НЕ отключайте iGPU на ноутбуке — экран зависит от него.'
                    }
                }
                @{
                    Id      = 'bios-disable-virtualization'
                    Title   = 'Disable virtualization (if not needed) — disables VBS'
                    Desc    = 'Disabling CPU virtualization (Intel VT-x / AMD SVM) in BIOS prevents Windows from enabling Virtualization Based Security (VBS), which has a minor performance impact on games. Only disable if you do not use VMs or WSL2.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS, find: Intel Virtualization Technology (VT-x) or AMD SVM Mode. Set to Disabled. This prevents Windows Defender Credential Guard and Core Isolation from using VBS, which can slightly improve game performance. Note: disabling this makes WSL2 and Hyper-V unavailable.'
                    Ru = @{
                        Title       = 'Отключить виртуализацию (если не нужна) — отключает VBS'
                        Desc        = 'Отключение виртуализации CPU (Intel VT-x / AMD SVM) в BIOS не позволяет Windows включить Virtualization Based Security (VBS), незначительно снижающую производительность в играх. Отключайте только если не используете ВМ или WSL2.'
                        Instruction = 'В BIOS найдите: Intel Virtualization Technology (VT-x) или AMD SVM Mode. Установите «Выключено». Это не позволит Credential Guard и Core Isolation в Windows Defender использовать VBS, что может незначительно улучшить производительность в играх. Внимание: после отключения WSL2 и Hyper-V будут недоступны.'
                    }
                }
                @{
                    Id      = 'bios-disable-extra-drives'
                    Title   = 'Disable unused drives in BIOS (if supported)'
                    Desc    = 'If your BIOS supports disabling individual storage devices programmatically, disable drives you will not use during installation to simplify the disk selection screen.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS → Storage configuration, disable any drives that are not involved in the Windows installation (e.g. secondary data drives). This prevents accidentally selecting the wrong disk during setup. Re-enable them after installation is complete.'
                    Ru = @{
                        Title       = 'Отключить неиспользуемые диски в BIOS (если поддерживается)'
                        Desc        = 'Если BIOS поддерживает программное отключение отдельных накопителей, отключите диски, не участвующие в установке — это упростит экран выбора диска.'
                        Instruction = 'В BIOS → конфигурация накопителей отключите все диски, не задействованные в установке Windows (например, дополнительные диски с данными). Это исключит случайный выбор не того диска. После завершения установки включите их обратно.'
                    }
                }
                @{
                    Id      = 'bios-pwm-fans'
                    Title   = 'Enable PWM mode for 4-pin fans'
                    Desc    = 'Set 4-pin fan headers to PWM mode (not DC/Voltage) in BIOS to allow proper RPM control by the cooling system. Required for accurate fan curve control.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In BIOS → Hardware Monitor / Fan Control, set each 4-pin fan connector to PWM mode. In DC mode, fan speed is controlled by voltage and is less precise. PWM mode allows exact RPM control via duty cycle.'
                    Ru = @{
                        Title       = 'Включить режим PWM для 4-контактных вентиляторов'
                        Desc        = 'Переведите 4-контактные разъёмы вентиляторов в режим PWM (не DC/Voltage) в BIOS для корректного управления оборотами системой охлаждения. Необходимо для точного контроля кривой вентиляторов.'
                        Instruction = 'В BIOS → Мониторинг оборудования / управление вентиляторами установите для каждого 4-контактного разъёма режим PWM. В режиме DC скорость вентилятора регулируется напряжением и менее точна. Режим PWM обеспечивает точное управление оборотами через рабочий цикл.'
                    }
                }
            )
        }

        # ── 7. Important Notes Before Installation ────────────────────────────
        @{
            Id    = 'important-before-install'
            Title = 'Important Notes Before Installation'
            Order = 7
            MaxMovGuide = $true
            Ru    = @{ Title = 'Важные примечания перед установкой' }
            Tweaks = @(
                @{
                    Id      = 'oobe-loop-note'
                    Title   = 'If PC reboots back to setup instead of OOBE — read this'
                    Desc    = 'After installation completes and reboots, some motherboards (especially MSI) fail to switch boot priority to the new Windows partition and loop back to the installer. Windows IS already installed — follow the instruction to resolve this without reinstalling.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'INSTALL FROM USB: Simply unplug the USB drive and restart. The PC will boot into the newly installed Windows and continue to OOBE. Reconnect the USB after reaching the desktop.

INSTALL WITHOUT USB (no-USB method): If you return to the install screen, try entering BIOS and changing the UEFI Hard Drive BBS Priorities to put the correct Windows partition first (e.g. MSI BIOS → Settings → Boot → UEFI Hard Drive BBS Priorities).

If BIOS does not allow changing partition priority (common on MSI laptops): press Shift+F10 at the install screen to open CMD. Run: diskpart → list vol → select vol N (where N is the ~12GB Win11 partition) → delete vol. Reboot. Windows will then boot from the installed partition. Note: this deletes the install partition — download any needed files from another PC or phone before reconnecting to the internet.'
                    Ru = @{
                        Title       = 'ПК снова запускает установщик вместо OOBE — прочитайте это'
                        Desc        = 'После завершения установки и перезагрузки некоторые материнские платы (особенно MSI) не переключают приоритет загрузки на новый раздел Windows и снова запускают установщик. Windows УЖЕ установлена — следуйте инструкции для решения без переустановки.'
                        Instruction = 'УСТАНОВКА С USB: просто извлеките USB-накопитель и перезагрузите ПК. Система загрузится в только что установленную Windows и продолжит начальную настройку (OOBE). Подключите USB снова после выхода на рабочий стол.

УСТАНОВКА БЕЗ USB: если снова появляется экран установки, войдите в BIOS и измените приоритеты UEFI Hard Drive BBS, поставив нужный раздел Windows первым (например, в BIOS MSI → Settings → Boot → UEFI Hard Drive BBS Priorities).

Если BIOS не позволяет изменить приоритет раздела (часто встречается на ноутбуках MSI): нажмите Shift+F10 на экране установки для открытия командной строки. Выполните: diskpart → list vol → select vol N (где N — раздел Win11 ~12 ГБ) → delete vol. Перезагрузите ПК. Система загрузится с установленного раздела. Важно: это удалит установочный раздел — скачайте нужные файлы с другого ПК или телефона до подключения к интернету.'
                    }
                }
            )
        }

        # ── 8. New Driver Install & MS Account Bypass ─────────────────────────
        @{
            Id    = 'new-driver-method'
            Title = 'New Driver Install Method & MS Account Bypass'
            Order = 8
            MaxMovGuide = $true
            Ru    = @{ Title = 'Новый метод установки драйверов и обход аккаунта Microsoft' }
            Tweaks = @(
                @{
                    Id      = 'new-method-video'
                    Title   = 'Watch video guide: new driver installation method during OOBE'
                    Desc    = 'Video fragment demonstrating the new method of installing drivers during OOBE (out-of-box experience) before connecting to the internet, then bypassing the Microsoft account requirement.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://youtu.be/Itk_7yTI4PY?t=191'
                    Ru = @{
                        Title = 'Посмотреть видеогайд: новый метод установки драйверов во время OOBE'
                        Desc  = 'Фрагмент видео, демонстрирующий новый метод установки драйверов во время начальной настройки Windows (OOBE) до подключения к интернету, а затем обход требования аккаунта Microsoft.'
                    }
                }
                @{
                    Id      = 'new-driver-method-steps'
                    Title   = 'Install drivers during OOBE (before internet, without MS account)'
                    Desc    = 'During the Windows 11 initial setup screen (OOBE), press Shift+F10, type explorer.exe to open File Explorer, install chipset and GPU drivers from USB, then reboot back into OOBE. Connect to the internet when asked, but skip the Microsoft account using one of the methods below.'
                    Kind    = 'manual'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = '1. At the OOBE screen, press Shift+F10. 2. Type: explorer.exe and press Enter. 3. File Explorer opens — install chipset driver and GPU driver from your USB drive. 4. In CMD, type: shutdown.exe /r /t 00 to reboot back into OOBE. 5. Continue setup and connect to the internet when prompted. 6. To skip Microsoft account:
   — Method IV (Pro only): choose "work/school" → "Join domain" instead.
   — Method V+: enter aaa@gmail.com with a wrong password — after repeated failures, Windows offers a local account.
   — Method V: log into MS account, then go to Settings → Accounts → Your info → "Sign in with a local account instead".'
                    Ru = @{
                        Title       = 'Установить драйверы во время OOBE (до интернета, без аккаунта Microsoft)'
                        Desc        = 'На экране начальной настройки Windows 11 (OOBE) нажмите Shift+F10, введите explorer.exe для открытия Проводника, установите чипсетный драйвер и драйвер GPU с USB, затем перезагрузитесь обратно в OOBE. Подключитесь к интернету по запросу, но пропустите аккаунт Microsoft одним из методов ниже.'
                        Instruction = '1. На экране OOBE нажмите Shift+F10. 2. Введите: explorer.exe и нажмите Enter. 3. Откроется Проводник — установите чипсетный драйвер и драйвер GPU с USB-накопителя. 4. В командной строке введите: shutdown.exe /r /t 00 для перезагрузки обратно в OOBE. 5. Продолжите настройку и подключитесь к интернету по запросу. 6. Для пропуска аккаунта Microsoft:
   — Метод IV (только Pro): выберите «рабочая/учебная» → «Присоединиться к домену».
   — Метод V+: введите aaa@gmail.com с неверным паролем — после нескольких ошибок Windows предложит локальный аккаунт.
   — Метод V: войдите в аккаунт Microsoft, затем Параметры → Учётные записи → Ваши данные → «Войти вместо этого с локальной учётной записью».'
                    }
                }
            )
        }

        # ── 9. Start Installation ─────────────────────────────────────────────
        @{
            Id    = 'start-installation'
            Title = 'Start Installation'
            Order = 9
            MaxMovGuide = $true
            Ru    = @{ Title = 'Начать установку' }
            Tweaks = @(
                @{
                    Id      = 'boot-from-usb'
                    Title   = 'Reboot and boot from USB installation drive'
                    Desc    = 'Restart the PC and enter the boot menu (usually F8, F11, F12, or Del depending on motherboard) to select the USB drive as the boot device. The Windows 11 installer will start.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Uri         = 'ms-settings:recovery'
                    Instruction = 'Option A: Hold Shift and click Restart → Troubleshoot → Advanced options → UEFI Firmware Settings to enter BIOS, then change boot order to USB. Option B: Restart normally and press F11/F12 (varies by board) at the manufacturer splash screen to open the one-time boot menu.'
                    Ru = @{
                        Title       = 'Перезагрузить ПК и загрузиться с USB-носителя'
                        Desc        = 'Перезагрузите ПК и войдите в меню загрузки (обычно F8, F11, F12 или Del в зависимости от материнской платы) для выбора USB-накопителя. Запустится установщик Windows 11.'
                        Instruction = 'Вариант А: удерживайте Shift и нажмите «Перезагрузить» → Диагностика → Дополнительные параметры → Параметры встроенного ПО UEFI для входа в BIOS, затем измените порядок загрузки на USB. Вариант Б: перезагрузите обычным способом и нажмите F11/F12 (зависит от платы) на заставке производителя для открытия однократного меню загрузки.'
                    }
                }
                @{
                    Id      = 'boot-no-usb-cmd'
                    Title   = 'Boot into installation: no-USB CMD method (reboot into recovery mode)'
                    Desc    = 'If using the no-USB CMD method: restart into Windows Recovery mode to access the Win11 install partition. See instruction.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Uri         = 'ms-settings:recovery'
                    Instruction = 'Go to Settings → System → Recovery → Advanced startup → Restart now. From the recovery menu, choose "Use a device" and select the Win11 partition. Alternatively, hold Shift while clicking Restart.'
                    Ru = @{
                        Title       = 'Загрузиться в установщик: метод CMD без USB (перезагрузка в режим восстановления)'
                        Desc        = 'При использовании метода без USB через CMD: перезагрузитесь в режим восстановления Windows для доступа к установочному разделу Win11. Подробности — в инструкции.'
                        Instruction = 'Перейдите в Параметры → Система → Восстановление → Особые варианты загрузки → Перезагрузить сейчас. В меню восстановления выберите «Использовать устройство» и укажите раздел Win11. Либо удерживайте Shift при нажатии «Перезагрузить».'
                    }
                }
                @{
                    Id      = 'boot-no-usb-easybcd'
                    Title   = 'Boot into installation: no-USB EasyBCD method (select NST entry on reboot)'
                    Desc    = 'If you used EasyBCD to add a WinPE boot entry, simply restart the PC and select the "NST" entry in the Windows Boot Manager to launch the installer.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Uri         = 'ms-settings:recovery'
                    Instruction = 'Restart the PC. At the Windows Boot Manager screen, select the NST (NeoSmart Technologies) entry. This boots into the WinPE installer you configured with EasyBCD. Proceed with the normal Windows 11 installation from there.'
                    Ru = @{
                        Title       = 'Загрузиться в установщик: метод EasyBCD без USB (выбрать запись NST при перезагрузке)'
                        Desc        = 'Если вы добавили запись загрузки WinPE через EasyBCD — просто перезагрузите ПК и выберите запись «NST» в диспетчере загрузки Windows для запуска установщика.'
                        Instruction = 'Перезагрузите ПК. На экране диспетчера загрузки Windows выберите запись NST (NeoSmart Technologies). Это загрузит установщик WinPE, настроенный через EasyBCD. Далее выполните обычную установку Windows 11.'
                    }
                }
            )
        }

    )
}
