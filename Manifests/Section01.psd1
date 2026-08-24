@{
    Id    = 'driver-install-update'
    Title = 'Driver Installation & System Update'
    Order = 1
    Ru    = @{ Title = 'Установка драйверов и обновление системы' }

    Subsections = @(

        # ── 0. Setup Notes ────────────────────────────────────────────────────
        @{
            Id    = 'setup-notes'
            Title = 'Setup Notes'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Примечания по установке' }
            Tweaks = @(
                @{
                    Id      = 'setup-notes-v04'
                    Title   = 'v0.4 setup note — skip steps 2-4 if drivers installed during OOBE'
                    Desc    = 'If you used the new driver installation method via Explorer during OOBE (Section 0), skip steps 2, 3, and 4 in this section — drivers and internet are already set up.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'If you installed drivers via the Explorer trick during Windows setup (Section 0 → Step 8), you may skip steps 2, 3, and 4 in this section.'
                    Ru = @{
                        Title       = 'Примечание v0.4 — пропустите шаги 2–4 если драйверы установлены при OOBE'
                        Desc        = 'Если вы использовали новый метод установки драйверов через Проводник во время OOBE (Раздел 0), пропустите шаги 2, 3 и 4 этого раздела — драйверы и интернет уже настроены.'
                        Instruction = 'Если драйверы были установлены через трюк с Проводником при настройке Windows (Раздел 0 → Шаг 8), шаги 2, 3 и 4 этого раздела можно пропустить.'
                    }
                }
            )
        }

        # ── 1. System, Runtime & Reboot ───────────────────────────────────────
        @{
            Id    = 'system-runtime-reboot'
            Title = 'System, Runtime & Reboot'
            Order = 1
            Ru    = @{ Title = 'Система, рантаймы и перезагрузка' }
            Tweaks = @(
                @{
                    Id      = 'set-pc-name'
                    MaxMovGuide = $true
                    Title   = 'Set PC name'
                    Desc    = 'Open About settings to rename this PC. A restart is required for the name to take effect.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Uri         = 'ms-settings:about'
                    Instruction = 'Click "Rename this PC", enter your preferred name, and restart when prompted.'
                    Ru = @{
                        Title       = 'Задать имя ПК'
                        Desc        = 'Откройте Параметры → «О системе» для переименования этого ПК. После переименования требуется перезагрузка.'
                        Instruction = 'Нажмите «Переименовать этот ПК», введите желаемое имя и перезагрузитесь по запросу.'
                    }
                }
                @{
                    Id      = 'open-device-manager-drivers'
                    MaxMovGuide = $true
                    Title   = 'Open Device Manager'
                    Desc    = 'Open Device Manager to verify GPU, chipset, storage, Wi-Fi, Bluetooth, and unknown devices after installing Windows.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'devmgmt.msc'
                    Instruction = 'Check Display adapters, Network adapters, Bluetooth, Storage controllers, and Other devices. Unknown devices usually mean a missing chipset, Wi-Fi, Bluetooth, or storage driver.'
                    Ru = @{
                        Title       = 'Открыть Диспетчер устройств'
                        Desc        = 'Откройте Диспетчер устройств, чтобы проверить GPU, чипсет, накопители, Wi-Fi, Bluetooth и неизвестные устройства после установки Windows.'
                        Instruction = 'Проверьте «Видеоадаптеры», «Сетевые адаптеры», Bluetooth, «Контроллеры запоминающих устройств» и «Другие устройства». Неизвестные устройства обычно означают отсутствующий драйвер чипсета, Wi-Fi, Bluetooth или накопителя.'
                    }
                }
                @{
                    Id      = 'enable-network'
                    MaxMovGuide = $true
                    Title   = 'Enable Wi-Fi or connect Ethernet cable'
                    Desc    = 'Open advanced network settings to verify and configure your network adapter after driver installation.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:network-advancedsettings'
                    Instruction = 'Ensure your network adapter is listed and enabled. Connect via Ethernet or toggle Wi-Fi on.'
                    Ru = @{
                        Title       = 'Включить Wi-Fi или подключить кабель Ethernet'
                        Desc        = 'Откройте расширенные параметры сети для проверки и настройки сетевого адаптера после установки драйверов.'
                        Instruction = 'Убедитесь, что сетевой адаптер отображается и активен. Подключитесь через Ethernet или включите Wi-Fi.'
                    }
                }
                @{
                    Id      = 'windows-update'
                    MaxMovGuide = $true
                    Title   = 'Check for Windows Updates'
                    Desc    = 'Install all available Windows Updates before proceeding with further configuration.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:windowsupdate'
                    Instruction = 'Click "Check for updates" and install everything available. Restart when prompted.'
                    Ru = @{
                        Title       = 'Проверить обновления Windows'
                        Desc        = 'Установите все доступные обновления Windows перед дальнейшей настройкой.'
                        Instruction = 'Нажмите «Проверить наличие обновлений» и установите всё доступное. Перезагрузитесь по запросу.'
                    }
                }
                @{
                    Id      = 'windows-optional-driver-updates'
                    MaxMovGuide = $true
                    Title   = 'Check optional driver updates'
                    Desc    = 'Open Windows optional updates to review driver updates that are not delivered through the main Windows Update flow.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:windowsupdate-optionalupdates'
                    Instruction = 'Open Driver updates, review every item, and install only drivers that match your current hardware.'
                    Ru = @{
                        Title       = 'Проверить дополнительные обновления драйверов'
                        Desc        = 'Откройте дополнительные обновления Windows для проверки драйверов, которые не ставятся через основной поток Windows Update.'
                        Instruction = 'Откройте «Обновления драйверов», проверьте каждый пункт и устанавливайте только драйверы, подходящие вашему текущему железу.'
                    }
                }
                @{
                    Id      = 'install-vcr-official'
                    MaxMovGuide = $true
                    Title   = 'Install Visual C++ Redistributables (official)'
                    Desc    = 'Download the latest Visual C++ Redistributable packages from Microsoft. Required by many applications and games.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist'
                    Ru = @{
                        Title = 'Установить Visual C++ Redistributables (официально)'
                        Desc  = 'Скачайте актуальные пакеты Visual C++ Redistributable от Microsoft. Требуются многими приложениями и играми.'
                    }
                }
                @{
                    Id      = 'install-vcr-winget'
                    Title   = 'Install / Update Visual C++ 2015-2022 Redistributables via winget'
                    Desc    = 'Installs or updates the official Microsoft Visual C++ 2015-2022 Redistributable packages (x64 + x86) sequentially through winget.'
                    Kind    = 'script'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    CanRevert = $false
                    ButtonLabel = 'Install / Update'
                    ActionNote  = 'Installs or updates both x64 and x86 packages sequentially via winget.'
                    # Both architectures are reported independently: one failing must not hide the
                    # other's verdict, and the card must never end on a silent screen.
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Microsoft.VCRedist.2015+.x64' -DisplayName 'Visual C++ 2015-2022 Redistributable (x64)' `
                            -FallbackNamePattern 'Visual C\+\+ 201[5-9].*(2022)?.*\(x64\)' | Out-Null
                        Invoke-WingetEnsurePackage -PackageId 'Microsoft.VCRedist.2015+.x86' -DisplayName 'Visual C++ 2015-2022 Redistributable (x86)' `
                            -FallbackNamePattern 'Visual C\+\+ 201[5-9].*(2022)?.*\(x86\)' | Out-Null
                    }
                    Detect = {
                        (Test-WingetPackagePresent -PackageId 'Microsoft.VCRedist.2015+.x64' -FallbackNamePattern 'Visual C\+\+ 201[5-9].*(2022)?.*\(x64\)') -and
                        (Test-WingetPackagePresent -PackageId 'Microsoft.VCRedist.2015+.x86' -FallbackNamePattern 'Visual C\+\+ 201[5-9].*(2022)?.*\(x86\)')
                    }
                    Ru = @{
                        Title       = 'Установить / Обновить Visual C++ 2015–2022 Redistributables через winget'
                        Desc        = 'Устанавливает или обновляет официальные пакеты Microsoft Visual C++ 2015–2022 Redistributable (x64 + x86) последовательно через winget.'
                        ButtonLabel = 'Установить / Обновить'
                        ActionNote  = 'Устанавливает или обновляет оба пакета (x64 и x86) последовательно через winget.'
                    }
                }
                @{
                    Id      = 'install-vcr-all-in-one'
                    MaxMovGuide = $true
                    Title   = 'Install Visual C++ Redistributables 2005-2022 (all-in-one pack)'
                    Desc    = 'Alternative all-in-one pack covering VCR versions 2005 through 2022. Convenient single-installer option.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/'
                    Ru = @{
                        Title = 'Установить Visual C++ Redistributables 2005–2022 (пакет «всё в одном»)'
                        Desc  = 'Альтернативный пакет «всё в одном», включающий версии VCR с 2005 по 2022 год. Удобный вариант с единственным установщиком.'
                    }
                }
                @{
                    Id      = 'install-vcr-aio-github'
                    Title   = 'Visual C++ Redistributable AIO — GitHub releases (abbodi1406)'
                    Desc    = 'Another route to the same full package: the abbodi1406/vcredist releases page. Community-maintained, published openly on GitHub with checksums and a visible release history, so it is easy to verify what you are downloading. Use it when the TechPowerUp mirror is unavailable or you prefer the original source.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/abbodi1406/vcredist/releases'
                    Ru = @{
                        Title = 'Visual C++ Redistributable AIO — релизы на GitHub (abbodi1406)'
                        Desc  = 'Ещё один путь к тому же полному пакету: страница релизов abbodi1406/vcredist. Поддерживается сообществом, публикуется открыто на GitHub с контрольными суммами и видимой историей версий — легко проверить, что именно скачиваете. Пригодится, если зеркало TechPowerUp недоступно или вы предпочитаете первоисточник.'
                    }
                }
                @{
                    Id      = 'reboot-now-warning'
                    Title   = '⚠ Restart Windows now (60 second timer)'
                    Desc    = 'Schedules a Windows restart in 60 seconds after drivers and updates are installed. Use the cancel button if clicked by mistake.'
                    Kind    = 'script'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    CanRevert = $false
                    ButtonLabel = 'Restart'
                    ActionNote  = 'Alternative direct action: schedules an actual Windows restart, not just a checklist mark.'
                    Apply = {
                        shutdown.exe /r /t 60 /c 'Audion Windows Tools scheduled restart. Run shutdown /a or press the cancel restart button to abort.'
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = '⚠ Перезагрузить Windows сейчас (таймер 60 секунд)'
                        Desc        = 'Планирует перезагрузку Windows через 60 секунд после установки драйверов и обновлений. Если нажали случайно, используйте кнопку отмены.'
                        ButtonLabel = 'Перезагрузка'
                        ActionNote  = 'Альтернативное прямое действие: запускает реальную перезагрузку Windows, а не просто отмечает чеклист.'
                    }
                }
                @{
                    Id      = 'cancel-scheduled-restart'
                    Title   = 'Cancel scheduled restart'
                    Desc    = 'Cancels a pending shutdown.exe restart timer if one was scheduled from this tool or manually.'
                    Kind    = 'script'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    CanRevert = $false
                    ButtonLabel = 'Cancel'
                    ActionNote  = 'Alternative direct action: aborts a pending shutdown.exe restart timer.'
                    Apply = {
                        shutdown.exe /a
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Отменить запланированную перезагрузку'
                        Desc        = 'Отменяет ожидающий таймер перезагрузки shutdown.exe, если он был создан этой утилитой или вручную.'
                        ButtonLabel = 'Отменить'
                        ActionNote  = 'Альтернативное прямое действие: отменяет ожидающий таймер перезагрузки shutdown.exe.'
                    }
                }
                @{
                    Id      = 'reboot-after-updates'
                    MaxMovGuide = $true
                    Title   = 'Restart after all updates are installed'
                    Desc    = 'Perform a clean restart after all drivers and Windows Updates have been applied.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Instruction = 'Once all updates and drivers are installed, restart the PC: Start → Power → Restart. The sand restart button above is an optional direct shortcut.'
                    Ru = @{
                        Title       = 'Перезагрузить ПК после установки всех обновлений'
                        Desc        = 'Выполните чистую перезагрузку после применения всех драйверов и обновлений Windows.'
                        Instruction = 'После установки всех обновлений и драйверов перезагрузите ПК: «Пуск» → Питание → Перезагрузка. Песочная кнопка перезагрузки выше — это дополнительный прямой shortcut.'
                    }
                }
            )
        }

        # ── 2. NVIDIA Drivers ────────────────────────────────────────────────
        @{
            Id    = 'nvidia-drivers'
            Title = 'NVIDIA Drivers'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Драйверы NVIDIA' }
            Tweaks = @(
                @{
                    Id      = 'download-nvidia-driver'
                    Title   = 'Download official NVIDIA GPU driver'
                    Desc    = 'Official NVIDIA driver download page. Download the latest Game Ready Driver, Studio Driver, or workstation driver for your exact GPU model.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.nvidia.com/en-us/drivers/'
                    Ru = @{
                        Title = 'Скачать официальный драйвер GPU NVIDIA'
                        Desc  = 'Официальная страница загрузки драйверов NVIDIA. Скачайте актуальный Game Ready Driver, Studio Driver или workstation-драйвер для вашей модели GPU.'
                    }
                }
                @{
                    Id      = 'download-nvidia-app-drivers'
                    Title   = 'NVIDIA App — driver updates and game optimization'
                    Desc    = 'Official NVIDIA App page. Use it for driver updates, game optimization, overlays, DLSS Overrides, and GPU tuning.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.nvidia.com/en-us/software/nvidia-app/'
                    Ru = @{
                        Title = 'NVIDIA App — обновления драйверов и оптимизация игр'
                        Desc  = 'Официальная страница NVIDIA App. Используйте приложение для обновления драйверов, оптимизации игр, оверлеев, DLSS Overrides и GPU tuning.'
                    }
                }
                @{
                    Id      = 'download-nvcleanstall'
                    Title   = 'NVCleanstall — minimal NVIDIA driver installer'
                    Desc    = 'GUI wrapper that lets you install only the Display Driver component and optional PhysX/Audio. Cleaner than the official custom install. NVIDIA only.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.techpowerup.com/download/techpowerup-nvcleanstall/'
                    Ru = @{
                        Title = 'NVCleanstall — минималистичный установщик драйвера NVIDIA'
                        Desc  = 'GUI-обёртка для установки только компонента Display Driver и опционально PhysX/Audio. Чище официальной выборочной установки. Только для NVIDIA.'
                    }
                }
                @{
                    Id      = 'install-nvidia-driver'
                    Title   = 'Install NVIDIA GPU driver (clean, no bloatware)'
                    Desc    = 'Run the NVIDIA driver installer selecting only the Display Driver component. Use NVCleanstall for the easiest clean install experience.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Instruction = 'Option A (recommended): open NVCleanstall, it auto-detects your GPU and the latest driver, tick only "Display Driver", click Next → Install. Option B (manual): download from nvidia.com/drivers, run installer → Custom → uncheck everything except Display Driver. Restart when complete.'
                    Ru = @{
                        Title       = 'Установить драйвер GPU NVIDIA (чисто, без лишнего ПО)'
                        Desc        = 'Запустите установщик драйвера NVIDIA, выбрав только компонент Display Driver. Используйте NVCleanstall для наиболее удобной чистой установки.'
                        Instruction = 'Вариант А (рекомендуется): откройте NVCleanstall — он автоматически определит ваш GPU и последний драйвер, отметьте только «Display Driver», нажмите «Далее» → «Установить». Вариант Б (вручную): скачайте с nvidia.com/drivers, запустите установщик → «Выборочная» → снимите все галочки кроме Display Driver. После завершения перезагрузите ПК.'
                    }
                }
                @{
                    Id      = 'download-ddu'
                    Title   = 'DDU — Display Driver Uninstaller'
                    Desc    = 'Completely removes NVIDIA/AMD/Intel GPU drivers and leftover registry entries. Use before switching GPU vendors or when a driver is corrupted. Run in Safe Mode.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.wagnardsoft.com/'
                    Ru = @{
                        Title = 'DDU — полное удаление драйвера дисплея'
                        Desc  = 'Полностью удаляет драйверы GPU NVIDIA/AMD/Intel и остатки в реестре. Используйте при смене производителя GPU или повреждении драйвера. Запускать в безопасном режиме.'
                    }
                }
                @{
                    Id      = 'remove-old-gpu-driver'
                    Title   = 'Remove old GPU driver with DDU'
                    Desc    = 'Only needed when switching GPU vendor, fixing a corrupted driver, or cleaning persistent issues after an update. Not required on a clean Windows install.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Instruction = '1. Download DDU. 2. Boot into Safe Mode (hold Shift → Restart → Troubleshoot → Advanced → Startup Settings → Safe Mode with Networking). 3. Run DDU, select GPU type (NVIDIA/AMD/Intel), click "Clean and restart". 4. After reboot install the new driver from the vendor section.'
                    Ru = @{
                        Title       = 'Удалить старый драйвер GPU через DDU'
                        Desc        = 'Нужно только при смене производителя GPU, повреждении драйвера или стойких проблемах после обновления. После чистой установки Windows обычно не требуется.'
                        Instruction = '1. Скачайте DDU. 2. Загрузитесь в безопасном режиме (Shift → Перезагрузка → Диагностика → Дополнительные параметры → Параметры запуска → Безопасный режим с сетевыми драйверами). 3. Запустите DDU, выберите тип GPU (NVIDIA/AMD/Intel), нажмите «Clean and restart». 4. После перезагрузки установите новый драйвер из раздела нужного вендора.'
                    }
                }
            )
        }

        # ── 3. AMD Drivers ───────────────────────────────────────────────────
        @{
            Id    = 'amd-drivers'
            Title = 'AMD Drivers'
            Order = 3
            MaxMovGuide = $true
            Ru    = @{ Title = 'Драйверы AMD' }
            Tweaks = @(
                @{
                    Id      = 'download-amd-driver'
                    Title   = 'Download official AMD graphics driver'
                    Desc    = 'Official AMD Drivers and Support page. Use it for Radeon graphics, Ryzen processors with graphics, and the AMD auto-detect tool.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.amd.com/en/support/download/drivers.html'
                    Ru = @{
                        Title = 'Скачать официальный графический драйвер AMD'
                        Desc  = 'Официальная страница AMD Drivers and Support. Используйте её для Radeon, Ryzen с графикой и AMD auto-detect tool.'
                    }
                }
                @{
                    Id      = 'download-amd-chipset-driver'
                    Title   = 'Download official AMD chipset driver'
                    Desc    = 'Official AMD Drivers and Support page. Chipset drivers for AMD desktop and laptop platforms are available here.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.amd.com/en/support/download/drivers.html'
                    Ru = @{
                        Title = 'Скачать официальный чипсетный драйвер AMD'
                        Desc  = 'Официальная страница AMD Drivers and Support. Здесь доступны чипсетные драйверы для desktop и laptop платформ AMD.'
                    }
                }
                @{
                    Id      = 'install-amd-drivers'
                    Title   = 'Install AMD graphics/chipset drivers'
                    Desc    = 'Install AMD graphics and chipset packages from the official AMD page or from your motherboard/laptop support page.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Instruction = 'For Radeon graphics: use AMD Drivers and Support or AMD Auto-Detect. For AMD chipset: select Chipsets on the AMD page or use the motherboard/laptop support page. Reboot after installation.'
                    Ru = @{
                        Title       = 'Установить графический и чипсетный драйверы AMD'
                        Desc        = 'Установите графические и чипсетные пакеты AMD с официальной страницы AMD или со страницы поддержки материнской платы/ноутбука.'
                        Instruction = 'Для Radeon используйте AMD Drivers and Support или AMD Auto-Detect. Для чипсета AMD выберите Chipsets на странице AMD или используйте страницу поддержки платы/ноутбука. После установки перезагрузитесь.'
                    }
                }
            )
        }

        # ── 4. Intel Drivers ─────────────────────────────────────────────────
        @{
            Id    = 'intel-drivers'
            Title = 'Intel Drivers'
            Order = 4
            MaxMovGuide = $true
            Ru    = @{ Title = 'Драйверы Intel' }
            Tweaks = @(
                @{
                    Id      = 'install-intel-dsa-winget'
                    MaxMovGuide = $false
                    Title   = 'Install Intel Driver & Support Assistant via winget'
                    Desc    = 'Installs Intel Driver & Support Assistant through winget to detect Intel graphics, Wi-Fi, Bluetooth, chipset, and storage updates.'
                    Kind    = 'script'
                    Source  = 'official'
                    Tone    = 'sand'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    CanRevert = $false
                    ButtonLabel = 'Install / Update'
                    ActionNote  = 'Installs or updates Intel DSA via winget.'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Intel.IntelDriverAndSupportAssistant' -DisplayName 'Intel Driver & Support Assistant' `
                            -FallbackNamePattern 'Driver (&|and) Support Assistant' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Intel.IntelDriverAndSupportAssistant' `
                            -FallbackNamePattern 'Driver (&|and) Support Assistant'
                    }
                    Ru = @{
                        Title       = 'Установить Intel Driver & Support Assistant через winget'
                        Desc        = 'Устанавливает Intel Driver & Support Assistant через winget для поиска обновлений Intel graphics, Wi-Fi, Bluetooth, chipset и storage.'
                        ButtonLabel = 'Установить / Обновить'
                        ActionNote  = 'Устанавливает или обновляет Intel DSA через winget.'
                    }
                }
                @{
                    Id      = 'download-intel-dsa'
                    Title   = 'Intel Driver & Support Assistant — official page'
                    Desc    = 'Official Intel auto-detect utility. It provides a curated list of available updates for identified Intel products.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/support/detect.html'
                    Ru = @{
                        Title = 'Intel Driver & Support Assistant — официальная страница'
                        Desc  = 'Официальная утилита Intel auto-detect. Показывает список доступных обновлений для найденных продуктов Intel.'
                    }
                }
                @{
                    Id      = 'download-intel-graphics-driver'
                    Title   = 'Download Intel Arc / integrated graphics driver'
                    Desc    = 'Official Intel Arc and Intel integrated graphics driver page for Windows.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download/785597/intel-arc-graphics-windows.html'
                    Ru = @{
                        Title = 'Скачать драйвер Intel Arc / встроенной графики'
                        Desc  = 'Официальная страница драйвера Intel Arc и встроенной графики Intel для Windows.'
                    }
                }
                @{
                    Id      = 'download-intel-chipset-inf-driver'
                    Title   = 'Download Intel chipset INF driver (older chipsets only)'
                    Desc    = 'Intel chipset INF utility for older Intel platforms. Modern Intel chipsets usually receive updates via Windows Update and Intel DSA.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download/19347/chipset-inf-utility.html'
                    Ru = @{
                        Title = 'Скачать Intel chipset INF driver (только старые чипсеты)'
                        Desc  = 'Утилита Intel chipset INF для старых платформ Intel. Современные чипсеты обычно получают обновления через Windows Update и Intel DSA.'
                    }
                }
                @{
                    Id      = 'download-intel-rst-driver'
                    Title   = 'Download Intel RST driver'
                    Desc    = 'Intel Rapid Storage Technology driver. Required only if your SSD is not detected during Windows setup or your system uses VMD/RST.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download/15667/intel-rapid-storage-technology-intel-rst-driver-installation-software-with-intel-optane-memory.html'
                    Ru = @{
                        Title = 'Скачать Intel RST driver'
                        Desc  = 'Драйвер Intel Rapid Storage Technology. Нужен только если SSD не определяется при установке Windows или система использует VMD/RST.'
                    }
                }
            )
        }

        # ── 5. Wi-Fi & Network Drivers ───────────────────────────────────────
        @{
            Id    = 'wifi-network-drivers'
            Title = 'Wi-Fi & Network Drivers'
            Order = 5
            MaxMovGuide = $true
            Ru    = @{ Title = 'Wi-Fi и сетевые драйверы' }
            Tweaks = @(
                @{
                    Id      = 'motherboard-laptop-support-page'
                    Title   = 'Open motherboard / laptop support page'
                    Desc    = 'Download chipset, LAN, Wi-Fi, Bluetooth, and storage drivers from the exact motherboard or laptop manufacturer support page.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Search your exact motherboard or laptop model on ASUS/MSI/Gigabyte/ASRock/Lenovo/HP/Dell support. Download chipset, LAN/Wi-Fi, Bluetooth, audio, and storage drivers matching your Windows version.'
                    Ru = @{
                        Title       = 'Открыть страницу поддержки материнской платы / ноутбука'
                        Desc        = 'Скачайте чипсетные, LAN, Wi-Fi, Bluetooth и storage-драйверы со страницы поддержки точной модели платы или ноутбука.'
                        Instruction = 'Найдите точную модель платы или ноутбука на сайте ASUS/MSI/Gigabyte/ASRock/Lenovo/HP/Dell. Скачайте chipset, LAN/Wi-Fi, Bluetooth, audio и storage драйверы под вашу версию Windows.'
                    }
                }
                @{
                    Id      = 'install-chipset-network-driver'
                    Title   = 'Install chipset and network drivers'
                    Desc    = 'Download and install the motherboard chipset driver and any remaining network/LAN drivers from the motherboard manufacturer website.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    Instruction = 'Visit your motherboard manufacturer website (e.g. ASUS, MSI, Gigabyte, ASRock), locate your board model, download the chipset and network drivers, install them in order. Vendor links below are additional shortcuts for common Wi-Fi adapter makers.'
                    Ru = @{
                        Title       = 'Установить чипсетный и сетевой драйверы'
                        Desc        = 'Скачайте и установите чипсетный драйвер материнской платы и оставшиеся сетевые/LAN драйверы с сайта производителя платы.'
                        Instruction = 'Зайдите на сайт производителя вашей материнской платы (ASUS, MSI, Gigabyte, ASRock), найдите свою модель, скачайте чипсетный и сетевой драйверы, установите их по порядку. Ссылки ниже — дополнительные shortcuts для популярных производителей Wi-Fi адаптеров.'
                    }
                }
                @{
                    Id      = 'download-realtek-wifi-drivers'
                    Title   = 'Realtek Wi-Fi adapter drivers'
                    Desc    = 'Official Realtek Wireless LAN IC downloads page. Use it when the adapter model is Realtek and Windows Update/OEM support page did not provide a newer driver.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.realtek.com/Download/Index?cate_id=203&menu_id=297'
                    Ru = @{
                        Title = 'Драйверы Wi-Fi адаптеров Realtek'
                        Desc  = 'Официальная страница загрузок Realtek Wireless LAN IC. Используйте её, если адаптер Realtek, а Windows Update/страница OEM не дали более новый драйвер.'
                    }
                }
                @{
                    Id      = 'download-intel-wifi-drivers'
                    Title   = 'Intel Wireless Wi-Fi drivers'
                    Desc    = 'Official Intel Wi-Fi driver package for Windows 10 and Windows 11 wireless adapters.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.intel.com/content/www/us/en/download/19351/intel-wireless-wi-fi-drivers-for-windows-10-and-windows-11.html'
                    Ru = @{
                        Title = 'Драйверы Intel Wireless Wi-Fi'
                        Desc  = 'Официальный пакет драйверов Intel Wi-Fi для беспроводных адаптеров Windows 10 и Windows 11.'
                    }
                }
                @{
                    Id      = 'download-mediatek-wifi-info'
                    Title   = 'MediaTek / MTK Wi-Fi driver guidance'
                    Desc    = 'Official MediaTek networking page. For most modern laptop Wi-Fi adapters, MediaTek directs end users to the device manufacturer support page or Windows Update.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.mediatek.com/products/networking-and-connectivity'
                    Ru = @{
                        Title = 'MediaTek / MTK Wi-Fi — где искать драйвер'
                        Desc  = 'Официальная страница MediaTek networking. Для большинства современных Wi-Fi адаптеров ноутбуков MediaTek направляет пользователей на сайт производителя устройства или в Windows Update.'
                    }
                }
                @{
                    Id      = 'download-mediatek-wifi-catalog'
                    Title   = 'MediaTek Wi-Fi drivers — Microsoft Update Catalog'
                    Desc    = 'Microsoft Update Catalog search for MediaTek MT7921/MT7922 Wi-Fi drivers. Useful when the OEM page is outdated or unavailable.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.catalog.update.microsoft.com/Search.aspx?q=MediaTek%20Wi-Fi%206%20MT7921%20Wireless%20LAN%20Card'
                    Ru = @{
                        Title = 'MediaTek Wi-Fi драйверы — Microsoft Update Catalog'
                        Desc  = 'Поиск драйверов MediaTek MT7921/MT7922 Wi-Fi в Microsoft Update Catalog. Полезно, если страница OEM устарела или недоступна.'
                    }
                }
            )
        }

    )
}
