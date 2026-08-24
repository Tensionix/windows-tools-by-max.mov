@{
    Id    = 'gpu-monitor-settings'
    Title = 'GPU & Monitor Settings'
    Order = 5
    Ru    = @{ Title = 'GPU и Монитор' }

    Subsections = @(

        # ── 0. Important Notes ────────────────────────────────────────────────
        @{
            Id    = 'gpu-notes'
            Title = 'Important Notes'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Важные примечания' }
            Tweaks = @(
                @{
                    Id      = 'gpu-notes-v04'
                    Title   = 'v0.4 update notes — VRR and Nvidia settings'
                    Desc    = 'Key corrections from v0.4: G-Sync should be enabled in fullscreen mode only (not windowed+fullscreen). Nvidia settings section now includes DLSS model/preset selection and PS-native DLSS indicator toggle.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'VRR monitors: use "Enable G-Sync for full screen mode" only — do NOT enable for windowed+fullscreen mode. See the VRR guide link below for details.'
                    Ru = @{
                        Title       = 'Примечания v0.4 — VRR и настройки Nvidia'
                        Desc        = 'Ключевые исправления v0.4: G-Sync следует включать только в полноэкранном режиме (не оконный+полноэкранный). В раздел Nvidia добавлены выбор модели/пресета DLSS и PS-native тумблер индикатора DLSS.'
                        Instruction = 'Мониторы с VRR: используйте только «Enable G-Sync for full screen mode» — НЕ включайте для режима оконный+полноэкранный. Подробности — в ссылке на гайд по VRR ниже.'
                    }
                }
            )
        }

        # ── 1. Monitor Setup ──────────────────────────────────────────────────
        @{
            Id    = 'monitor-setup'
            Title = 'Monitor Setup'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройка монитора' }
            Tweaks = @(
                @{
                    Id      = 'monitor-no-vrr-guide'
                    Title   = 'Monitor setup guide — fixed refresh rate (no VRR)'
                    Desc    = 'Online guide for configuring a monitor that does not support Variable Refresh Rate (G-Sync / FreeSync).'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://andrilaz.github.io/fixed-refresh'
                    Ru = @{
                        Title = 'Гайд по настройке монитора — фиксированная частота (без VRR)'
                        Desc  = 'Онлайн-гайд по настройке монитора без поддержки переменной частоты обновления (G-Sync / FreeSync).'
                    }
                }
                @{
                    Id      = 'monitor-vrr-guide'
                    Title   = 'Monitor setup guide — VRR (G-Sync / FreeSync)'
                    Desc    = 'Online guide for configuring a VRR monitor with G-Sync or FreeSync. Includes correct G-Sync mode selection.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://andrilaz.github.io/vrr'
                    Ru = @{
                        Title = 'Гайд по настройке монитора — VRR (G-Sync / FreeSync)'
                        Desc  = 'Онлайн-гайд по настройке VRR-монитора с G-Sync или FreeSync. Включает правильный выбор режима G-Sync.'
                    }
                }
            )
        }

        # ── 2. Nvidia Settings ────────────────────────────────────────────────
        @{
            Id    = 'nvidia-settings'
            Title = 'Nvidia Settings'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройки Nvidia' }
            Tweaks = @(
                @{
                    Id      = 'nvidia-control-panel'
                    Title   = 'Open Nvidia Control Panel'
                    Desc    = 'Open the Nvidia Control Panel from the Microsoft Store to access display, 3D settings, and G-Sync configuration.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-windows-store://pdp/?ProductId=9NF8H0H7WMLT'
                    Instruction = 'Install or open the Nvidia Control Panel from the Store, then configure 3D Settings and Display settings per the guide.'
                    Ru = @{
                        Title       = 'Открыть панель управления Nvidia'
                        Desc        = 'Откройте Панель управления Nvidia из Microsoft Store для настройки дисплея, параметров 3D и G-Sync.'
                        Instruction = 'Установите или откройте Панель управления Nvidia из Store, затем настройте параметры 3D и дисплея согласно гайду.'
                    }
                }
                @{
                    Id      = 'nvidia-settings-guide'
                    Title   = 'Configure Nvidia driver settings (3D, DLSS, display)'
                    Desc    = 'Apply recommended Nvidia Control Panel settings: power management mode, texture filtering, DLSS model/preset selection, and display configuration.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In Nvidia Control Panel: 1. Manage 3D settings → Power management mode: Prefer maximum performance. 2. Set texture filtering quality. 3. Configure G-Sync if available. 4. For DLSS: select the appropriate model and preset in supported games. Refer to the Nvidia settings guide in the archive for detailed recommendations.'
                    Ru = @{
                        Title       = 'Настройка параметров драйвера Nvidia (3D, DLSS, дисплей)'
                        Desc        = 'Применение рекомендуемых настроек Панели управления Nvidia: режим управления питанием, качество фильтрации текстур, выбор модели/пресета DLSS и конфигурация дисплея.'
                        Instruction = 'В Панели управления Nvidia: 1. Управление параметрами 3D → Режим управления питанием: предпочтительная максимальная производительность. 2. Настройте качество фильтрации текстур. 3. Настройте G-Sync если доступен. 4. Для DLSS: выберите подходящую модель и пресет в поддерживаемых играх. Подробные рекомендации — в гайде по настройкам Nvidia в архиве.'
                    }
                }
                @{
                    Id      = 'nvidia-dlss-indicator'
                    Title   = 'Show Nvidia DLSS indicator overlay'
                    Desc    = 'Enables the Nvidia NGXCore DLSS indicator overlay via the driver registry flag.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    AppliesTo = @{ GpuVendors = @('NVIDIA') }
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\NVIDIA Corporation\Global\NGXCore'
                        Name  = 'ShowDlssIndicator'
                        Type  = 'DWord'
                        Value = 1
                    }
                    Ru = @{
                        Title = 'Показать индикатор Nvidia DLSS'
                        Desc  = 'Включает оверлей-индикатор DLSS через реестровый флаг драйвера Nvidia NGXCore.'
                    }
                }
                @{
                    Id      = 'nvidia-disable-hdcp'
                    Title   = 'Disable Nvidia HDCP'
                    Desc    = 'Sets the Nvidia display driver HDCP override flag on detected Nvidia display class registry entries. Revert removes the override flag.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    AppliesTo = @{ GpuVendors = @('NVIDIA') }
                    Apply = {
                        $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
                        if (-not (Test-Path $base)) { throw 'Display adapter registry class was not found.' }

                        $keys = Get-ChildItem -Path $base -EA SilentlyContinue |
                            Where-Object { $_.PSChildName -match '^\d{4}$' } |
                            Where-Object {
                                $p = Get-ItemProperty -Path $_.PSPath -EA SilentlyContinue
                                "$($p.DriverDesc) $($p.ProviderName) $($p.MatchingDeviceId) $($p.DeviceDesc)" -match 'NVIDIA'
                            }

                        if (-not $keys) { throw 'Nvidia display adapter registry key was not found.' }

                        foreach ($key in $keys) {
                            New-ItemProperty -Path $key.PSPath -Name 'RMHdcpKeyglobZero' -PropertyType DWord -Value 1 -Force | Out-Null
                        }
                    }
                    Revert = {
                        $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
                        if (-not (Test-Path $base)) { return }

                        Get-ChildItem -Path $base -EA SilentlyContinue |
                            Where-Object { $_.PSChildName -match '^\d{4}$' } |
                            Where-Object {
                                $p = Get-ItemProperty -Path $_.PSPath -EA SilentlyContinue
                                "$($p.DriverDesc) $($p.ProviderName) $($p.MatchingDeviceId) $($p.DeviceDesc)" -match 'NVIDIA'
                            } |
                            ForEach-Object {
                                Remove-ItemProperty -Path $_.PSPath -Name 'RMHdcpKeyglobZero' -EA SilentlyContinue
                            }
                    }
                    Detect = {
                        $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
                        if (-not (Test-Path $base)) { return $false }

                        foreach ($key in (Get-ChildItem -Path $base -EA SilentlyContinue | Where-Object { $_.PSChildName -match '^\d{4}$' })) {
                            $p = Get-ItemProperty -Path $key.PSPath -EA SilentlyContinue
                            if ("$($p.DriverDesc) $($p.ProviderName) $($p.MatchingDeviceId) $($p.DeviceDesc)" -notmatch 'NVIDIA') { continue }

                            try {
                                if ((Get-ItemProperty -Path $key.PSPath -Name 'RMHdcpKeyglobZero' -EA Stop).'RMHdcpKeyglobZero' -eq 1) {
                                    return $true
                                }
                            } catch {}
                        }
                        $false
                    }
                    Ru = @{
                        Title = 'Отключить Nvidia HDCP'
                        Desc  = 'Устанавливает флаг отключения HDCP в найденных реестровых ключах display-драйвера Nvidia. Откат удаляет этот флаг.'
                    }
                }
            )
        }

        # ── 3. Official Nvidia Recommendations ───────────────────────────────
        @{
            Id    = 'nvidia-official-recommendations'
            Title = 'Official Nvidia Recommendations'
            Order = 3
            Ru    = @{ Title = 'Официальные рекомендации Nvidia' }
            Tweaks = @(
                @{
                    Id      = 'nvidia-app-download'
                    Title   = 'NVIDIA App — download'
                    Desc    = 'Official NVIDIA App download page for drivers, game optimization, DLSS Overrides, overlays, GPU tuning, and RTX video features.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.nvidia.com/en-us/software/nvidia-app/'
                    Ru = @{
                        Title = 'NVIDIA App — скачать'
                        Desc  = 'Официальная страница NVIDIA App для драйверов, оптимизации игр, DLSS Overrides, оверлеев, GPU tuning и RTX Video.'
                    }
                }
                @{
                    Id      = 'nvidia-app-optimal-settings'
                    Title   = 'Apply NVIDIA App optimal game settings'
                    Desc    = 'Use NVIDIA App recommendations for supported games and apps. Recommendations are based on GPU, CPU, resolution, RAM, OS, and the latest official game patch.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open NVIDIA App → Home or Graphics → select a detected game → Optimize. Run a game once if NVIDIA App cannot optimize it yet, update the game and driver, then use the Performance/Quality slider if needed.'
                    Ru = @{
                        Title       = 'Применить оптимальные настройки игр в NVIDIA App'
                        Desc        = 'Использует рекомендации NVIDIA App для поддерживаемых игр и приложений. Рекомендации учитывают GPU, CPU, разрешение, RAM, ОС и последний официальный патч игры.'
                        Instruction = 'Откройте NVIDIA App → Home или Graphics → выберите найденную игру → Optimize. Если игра ещё не оптимизируется, запустите её один раз, обновите игру и драйвер, затем при необходимости используйте слайдер Performance/Quality.'
                    }
                }
                @{
                    Id      = 'nvidia-app-dlss-overrides'
                    Title   = 'Configure NVIDIA App DLSS Overrides'
                    Desc    = 'Use official DLSS Overrides to apply newer DLSS models, DLSS Super Resolution presets, Frame Generation options, DLAA, and Ultra Performance modes globally or per game.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open NVIDIA App → Graphics → Global Settings or Program Settings → DLSS Override. For Super Resolution, choose Model Presets → Recommended. For Frame Generation, choose Dynamic or Fixed only for compatible RTX GPUs/games. Use Statistics → DLSS in the NVIDIA overlay to verify override status.'
                    Ru = @{
                        Title       = 'Настроить DLSS Overrides в NVIDIA App'
                        Desc        = 'Использует официальные DLSS Overrides для новых моделей DLSS, пресетов DLSS Super Resolution, Frame Generation, DLAA и Ultra Performance глобально или по играм.'
                        Instruction = 'Откройте NVIDIA App → Graphics → Global Settings или Program Settings → DLSS Override. Для Super Resolution выберите Model Presets → Recommended. Для Frame Generation выберите Dynamic или Fixed только на совместимых RTX GPU/играх. Проверяйте статус через Statistics → DLSS в оверлее NVIDIA.'
                    }
                }
                @{
                    Id      = 'nvidia-gsync-vsync-baseline'
                    MaxMovGuide = $true
                    Title   = 'Official G-SYNC / VRR and V-Sync baseline'
                    Desc    = 'Configure VRR the NVIDIA-supported way: enable display VRR, use the maximum refresh rate, enable G-SYNC for full screen mode, and avoid forcing V-Sync Off globally.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Enable Adaptive Sync / G-SYNC in the monitor OSD, set the highest supported refresh rate in Windows or NVIDIA Control Panel, then NVIDIA Control Panel → Set up G-SYNC → enable for Full screen mode. For no-tear G-SYNC use, set Manage 3D Settings → Vertical Sync → On; do not force global V-Sync Off.'
                    Ru = @{
                        Title       = 'Базовая настройка G-SYNC / VRR и V-Sync'
                        Desc        = 'Настройка VRR по поддерживаемой NVIDIA схеме: включить VRR на мониторе, выставить максимум Hz, включить G-SYNC для fullscreen и не форсить глобальный V-Sync Off.'
                        Instruction = 'Включите Adaptive Sync / G-SYNC в OSD монитора, выставьте максимальную частоту обновления в Windows или NVIDIA Control Panel, затем NVIDIA Control Panel → Set up G-SYNC → Full screen mode. Для режима G-SYNC без tearing поставьте Manage 3D Settings → Vertical Sync → On; не форсируйте глобальный V-Sync Off.'
                    }
                }
                @{
                    Id      = 'nvidia-reflex-low-latency'
                    MaxMovGuide = $true
                    Title   = 'NVIDIA Reflex and Ultra Low Latency'
                    Desc    = 'Use NVIDIA Reflex in supported games; use Ultra Low Latency Mode in the driver when Reflex is unavailable.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In supported games, enable NVIDIA Reflex Low Latency (On, or On + Boost if needed). If a game does not support Reflex, open NVIDIA Control Panel → Manage 3D Settings → Low Latency Mode → Ultra, preferably per game.'
                    Ru = @{
                        Title       = 'NVIDIA Reflex и Ultra Low Latency'
                        Desc        = 'Используйте NVIDIA Reflex в поддерживаемых играх; если Reflex недоступен, используйте Ultra Low Latency Mode в драйвере.'
                        Instruction = 'В поддерживаемых играх включите NVIDIA Reflex Low Latency (On или On + Boost при необходимости). Если игра не поддерживает Reflex, откройте NVIDIA Control Panel → Manage 3D Settings → Low Latency Mode → Ultra, лучше на уровне конкретной игры.'
                    }
                }
                @{
                    Id      = 'nvidia-max-frame-rate-power'
                    MaxMovGuide = $true
                    Title   = 'Max Frame Rate and Power Management'
                    Desc    = 'Use NVIDIA Max Frame Rate for latency, power saving, or staying inside the VRR range; use Prefer Maximum Performance only when needed.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'NVIDIA Control Panel → Manage 3D Settings → Max Frame Rate. For VRR, cap slightly below the display maximum refresh rate. For latency in GPU-bound games, use Prefer maximum performance and Low Latency Mode Ultra. For power saving, use Optimal Power.'
                    Ru = @{
                        Title       = 'Max Frame Rate и Power Management'
                        Desc        = 'Используйте NVIDIA Max Frame Rate для задержки, экономии энергии или удержания FPS внутри VRR-диапазона; Prefer Maximum Performance включайте только когда это нужно.'
                        Instruction = 'NVIDIA Control Panel → Manage 3D Settings → Max Frame Rate. Для VRR ограничьте FPS немного ниже максимальной частоты монитора. Для задержки в GPU-bound играх используйте Prefer maximum performance и Low Latency Mode Ultra. Для экономии энергии используйте Optimal Power.'
                    }
                }
                @{
                    Id      = 'nvidia-image-scaling'
                    MaxMovGuide = $true
                    Title   = 'NVIDIA Image Scaling'
                    Desc    = 'Enable driver-level spatial upscaling and sharpening for supported DirectX, Vulkan, and OpenGL games.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Instruction = 'NVIDIA Control Panel → Manage 3D Settings → Image Scaling → On. Reboot so games detect the generated scaling resolutions, then choose a lower render resolution in fullscreen mode and tune sharpening globally or per game.'
                    Ru = @{
                        Title       = 'NVIDIA Image Scaling'
                        Desc        = 'Включает драйверный spatial upscaling и sharpening для поддерживаемых DirectX, Vulkan и OpenGL игр.'
                        Instruction = 'NVIDIA Control Panel → Manage 3D Settings → Image Scaling → On. Перезагрузитесь, чтобы игры увидели созданные scaling-разрешения, затем выберите более низкое render-разрешение в fullscreen и настройте sharpening глобально или по играм.'
                    }
                }
                @{
                    Id      = 'nvidia-rtx-video'
                    Title   = 'RTX Video Super Resolution / HDR'
                    Desc    = 'Enable RTX Video enhancements through NVIDIA App or NVIDIA Control Panel for supported browsers and RTX GPUs.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Prefer NVIDIA App for RTX Video options. Alternatively open NVIDIA Control Panel → Adjust Video Image Settings → RTX Video Enhancements, then enable Super Resolution and/or HDR. Use a supported browser such as Chrome, Edge, or Firefox.'
                    Ru = @{
                        Title       = 'RTX Video Super Resolution / HDR'
                        Desc        = 'Включает RTX Video enhancements через NVIDIA App или NVIDIA Control Panel для поддерживаемых браузеров и RTX GPU.'
                        Instruction = 'Предпочтительно используйте NVIDIA App для RTX Video. Альтернатива: NVIDIA Control Panel → Adjust Video Image Settings → RTX Video Enhancements, затем включите Super Resolution и/или HDR. Используйте поддерживаемый браузер: Chrome, Edge или Firefox.'
                    }
                }
                @{
                    Id      = 'nvidia-performance-overlay'
                    Title   = 'NVIDIA performance and DLSS status overlay'
                    Desc    = 'Use the NVIDIA overlay to show FPS, GPU metrics, latency metrics, and DLSS Override status in-game.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Enable In-Game Overlay in NVIDIA App. Press Alt+Z → Statistics → choose DLSS or Custom statistics view. Toggle the overlay with Alt+R while in game.'
                    Ru = @{
                        Title       = 'Оверлей производительности и статуса DLSS NVIDIA'
                        Desc        = 'Используйте оверлей NVIDIA для FPS, метрик GPU, задержек и статуса DLSS Override в игре.'
                        Instruction = 'Включите In-Game Overlay в NVIDIA App. Нажмите Alt+Z → Statistics → выберите DLSS или Custom statistics view. В игре переключайте оверлей через Alt+R.'
                    }
                }
            )
        }

    )
}
