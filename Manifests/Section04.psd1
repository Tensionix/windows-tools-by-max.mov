@{
    Id    = 'windows-settings'
    Title = 'Windows Settings'
    Order = 4
    Ru    = @{ Title = 'Настройки Windows' }

    Subsections = @(

        # ── 0. Explorer Settings ──────────────────────────────────────────────
        @{
            Id    = 'explorer'
            Title = 'Explorer Settings'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройки Проводника' }
            Tweaks = @(
                @{
                    Id      = 'explorer-remove-checkboxes'
                    Title   = 'Remove item-selection checkboxes & clear history'
                    Desc    = 'Uncheck three checkboxes in Folder Options and clear recent-files log.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'shell:::{ED7BA470-8E54-465E-825C-99712043E01C}'
                    Instruction = 'In Folder Options uncheck: Show recently used files, Show frequently used folders, Show files from Office.com. Then click Clear under Recent files.'
                    Ru = @{
                        Title       = 'Убрать чекбоксы выделения и очистить историю'
                        Desc        = 'Снимите три флажка в параметрах папок и очистите журнал последних файлов.'
                        Instruction = 'В параметрах папок снимите флажки: «Показывать недавно открытые файлы», «Показывать часто используемые папки», «Показывать файлы из Office.com». Затем нажмите «Очистить» в разделе «Последние файлы».'
                    }
                }
                @{
                    Id      = 'explorer-configure'
                    Title   = 'Configure Explorer view options'
                    Desc    = 'Open Explorer Options to set default folder, file-name extensions, hidden files, etc.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'shell:::{ED7BA470-8E54-465E-825C-99712043E01C}'
                    Instruction = 'Set view preferences and show hidden/system files as desired.'
                    Ru = @{
                        Title       = 'Настроить параметры вида Проводника'
                        Desc        = 'Откройте параметры Проводника для настройки папки по умолчанию, расширений файлов, скрытых файлов и др.'
                        Instruction = 'Задайте предпочтения отображения и настройте показ скрытых и системных файлов по желанию.'
                    }
                }
                @{
                    Id      = 'explorer-powertoys-keybindings'
                    Title   = 'PowerToys — keyboard shortcut remapping'
                    Desc    = 'Download Microsoft PowerToys for advanced keyboard shortcuts and utilities.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/microsoft/PowerToys/releases'
                    Ru = @{
                        Title = 'PowerToys — переназначение горячих клавиш'
                        Desc  = 'Скачайте Microsoft PowerToys для расширенных горячих клавиш и утилит.'
                    }
                }
                @{
                    Id      = 'explorer-autosize-columns'
                    Title   = 'Auto-size columns (CTRL + Numpad *)'
                    Desc    = 'Keyboard shortcut CTRL+(Numpad *) resizes all columns to fit content in Details view.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In any Explorer window in Details view, press CTRL + * (numpad asterisk) to auto-size all columns.'
                    Ru = @{
                        Title       = 'Авторазмер колонок (CTRL + Numpad *)'
                        Desc        = 'Сочетание клавиш CTRL+(Numpad *) подгоняет ширину всех колонок под содержимое в режиме «Подробности».'
                        Instruction = 'В любом окне Проводника в режиме «Подробности» нажмите CTRL + * (звёздочка на цифровой клавиатуре) для авторазмера всех колонок.'
                    }
                }
            )
        }

        # ── 1. System ─────────────────────────────────────────────────────────
        @{
            Id    = 'system'
            Title = 'System'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Система' }
            Tweaks = @(
                @{
                    Id      = 'system-display'
                    Title   = 'Display — resolution, scale, refresh rate'
                    Desc    = 'Set correct resolution and maximum monitor refresh rate.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:display'
                    Instruction = 'Set Resolution, Scale, and Display adapter properties → Monitor → Screen refresh rate to the maximum value your monitor supports.'
                    Ru = @{
                        Title       = 'Экран — разрешение, масштаб, частота обновления'
                        Desc        = 'Задайте корректное разрешение и максимальную частоту обновления монитора.'
                        Instruction = 'Задайте разрешение, масштаб и через Свойства видеоадаптера → Монитор → Частота обновления экрана — выберите максимальное значение, поддерживаемое вашим монитором.'
                    }
                }
                @{
                    Id      = 'system-notifications'
                    Title   = 'Notifications — configure & enable startup alerts'
                    Desc    = 'Open notification settings; enable startup app notification toggle.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:notifications'
                    Instruction = 'Enable "Notify me about startup app changes" and configure app notification preferences.'
                    Ru = @{
                        Title       = 'Уведомления — настройка и оповещения автозапуска'
                        Desc        = 'Откройте параметры уведомлений; включите переключатель уведомлений о приложениях автозапуска.'
                        Instruction = 'Включите «Уведомлять об изменениях приложений автозапуска» и настройте параметры уведомлений от приложений.'
                    }
                }
                @{
                    Id      = 'system-storage-cleanup'
                    Title   = 'Disable automatic Storage Sense'
                    Desc    = 'Turns off automatic disk cleanup to prevent unexpected file removal. Same switch as System > Storage > Storage Sense.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKCU'
                        Path  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
                        Name  = '01'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить автоматический контроль памяти'
                        Desc  = 'Выключает автоматическую очистку диска во избежание непредвиденного удаления файлов. Тот же переключатель, что «Система → Память → Контроль памяти».'
                    }
                }
                @{
                    Id      = 'system-clipboard-history'
                    Title   = 'Enable Clipboard History (Win+V)'
                    Desc    = 'Lets Windows store clipboard history accessible via Win+V. Same switch as System > Clipboard.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKCU'
                        Path  = 'SOFTWARE\Microsoft\Clipboard'
                        Name  = 'EnableClipboardHistory'
                        Value = 1
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Включить историю буфера обмена (Win+V)'
                        Desc  = 'Разрешает Windows хранить историю буфера обмена, доступную через Win+V. Тот же переключатель, что «Система → Буфер обмена».'
                    }
                }
                @{
                    Id      = 'system-remote-desktop'
                    Title   = 'Disable Remote Desktop (if not needed)'
                    Desc    = 'Turns off RDP to reduce attack surface. Same switch as System > Remote Desktop.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SYSTEM\CurrentControlSet\Control\Terminal Server'
                        Name  = 'fDenyTSConnections'
                        Value = 1
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить удалённый рабочий стол (если не нужен)'
                        Desc  = 'Выключает RDP для уменьшения поверхности атаки. Тот же переключатель, что «Система → Удалённый рабочий стол».'
                    }
                }
                @{
                    Id      = 'system-multitasking'
                    Title   = 'Multitasking — configure Snap windows'
                    Desc    = 'Expand the Snap windows menu to configure snapping behaviour.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:multitasking'
                    Instruction = 'Adjust Snap windows settings to personal preference.'
                    Ru = @{
                        Title       = 'Многозадачность — настройка прикрепления окон'
                        Desc        = 'Разверните меню «Прикрепить окна» для настройки поведения прикрепления.'
                        Instruction = 'Настройте параметры «Прикрепить окна» по своему усмотрению.'
                    }
                }
                @{
                    Id      = 'system-disable-recall'
                    Title   = 'Disable Recall AI feature (24H2+)'
                    Desc    = 'Removes the Recall optional feature via DISM. Security-conscious opt-out for 24H2+'
                    Kind    = 'feature'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    AppliesTo = @{ MinBuild = 26100 }
                    Op = @{
                        FeatureName = 'Recall'
                        Target      = 'Disabled'
                    }
                    Ru = @{
                        Title = 'Отключить функцию Recall AI (24H2+)'
                        Desc  = 'Удаляет дополнительный компонент Recall через DISM. Отказ от функции по соображениям безопасности для 24H2+.'
                    }
                }
                @{
                    Id      = 'system-optional-features'
                    Title   = 'Review optional Windows features'
                    Desc    = 'Disable Windows components not needed (Hyper-V, IE mode, Print-to-PDF, etc.).'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'ms-settings:optionalfeatures'
                    Instruction = 'Remove unused optional features. Keep only what you actively use.'
                    Ru = @{
                        Title       = 'Просмотреть дополнительные компоненты Windows'
                        Desc        = 'Отключите ненужные компоненты Windows (Hyper-V, режим IE, Печать в PDF и др.).'
                        Instruction = 'Удалите неиспользуемые дополнительные компоненты. Оставьте только те, которые используете.'
                    }
                }
            )
        }

        # ── 1.1 Maintenance ───────────────────────────────────────────────────
        @{
            Id    = 'maintenance'
            Title = 'Maintenance (Optional)'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Обслуживание (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'maintenance-disable'
                    Title   = 'Disable automatic Windows Maintenance'
                    Desc    = 'Prevents Windows from running scheduled maintenance tasks (disk defrag, updates, diagnostics) automatically. Use with caution.'
                    Kind    = 'registry'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance'
                        Name  = 'MaintenanceDisabled'
                        Type  = 'DWord'
                        Value = 1
                    }
                    Ru = @{
                        Title = 'Отключить автоматическое обслуживание Windows'
                        Desc  = 'Запрещает Windows автоматически выполнять задачи обслуживания (дефрагментация, обновления, диагностика). Используйте с осторожностью.'
                    }
                }
            )
        }

        # ── 1.2 Power Scheme ──────────────────────────────────────────────────
        @{
            Id    = 'power-scheme'
            Title = 'Power Scheme (Optional)'
            Order = 3
            Ru    = @{ Title = 'Схема питания (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'power-scheme-howto'
                    MaxMovGuide = $true
                    Title   = 'How to import a power scheme'
                    Desc    = 'Import a .pow file then activate it. Run: powercfg -import "<path.pow>" then powercfg -setactive <GUID>.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Use the power scheme cards below: click Apply to import and activate a scheme. Click Revert to restore the previous scheme. Only one scheme should be active at a time.'
                    Ru = @{
                        Title       = 'Как импортировать схему питания'
                        Desc        = 'Импортируйте .pow-файл и активируйте его. Команды: powercfg -import "<путь.pow>", затем powercfg -setactive <GUID>.'
                        Instruction = 'Используйте карточки схем питания ниже: нажмите «Применить» для импорта и активации схемы. Нажмите «Отменить» для восстановления предыдущей схемы. Одновременно должна быть активна только одна схема.'
                    }
                }
                @{
                    Id      = 'power-scheme-khorvie'
                    Title   = 'Khorvie Power Scheme'
                    Desc    = 'Gaming-optimised power scheme by Khorvie. Import and set as active. Apply captures current active scheme for revert.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\Khorvie.pow' }
                    Ru = @{
                        Title = 'Схема питания Khorvie'
                        Desc  = 'Игровая схема питания от Khorvie. Импортируется и устанавливается как активная. «Применить» сохраняет текущую схему для возможности отмены.'
                    }
                }
                @{
                    Id      = 'power-scheme-khorvie-os'
                    Title   = 'KhorvieOS Power Scheme'
                    Desc    = 'Variant of the Khorvie scheme tuned for the KhorvieOS image.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\KhorvieOS.pow' }
                    Ru = @{
                        Title = 'Схема питания KhorvieOS'
                        Desc  = 'Вариант схемы Khorvie, настроенный для образа KhorvieOS.'
                    }
                }
                @{
                    Id      = 'power-scheme-ultimate'
                    Title   = 'Ultimate Performance Scheme'
                    Desc    = 'Windows Ultimate Performance scheme unlocked. Maximum throughput, disables CPU parking.'
                    Kind    = 'powerscheme'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\ultimate.pow' }
                    Ru = @{
                        Title = 'Схема «Максимальная производительность»'
                        Desc  = 'Разблокированная схема питания Windows «Максимальная производительность». Максимальная пропускная способность, отключает парковку ядер CPU.'
                    }
                }
                @{
                    Id      = 'power-scheme-highperf'
                    Title   = 'High Performance Scheme'
                    Desc    = 'Standard Windows High Performance power plan.'
                    Kind    = 'powerscheme'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\high perf.pow' }
                    Ru = @{
                        Title = 'Схема «Высокая производительность»'
                        Desc  = 'Стандартный план питания Windows «Высокая производительность».'
                    }
                }
                @{
                    Id      = 'power-scheme-adamx'
                    Title   = 'AdamX Power Scheme'
                    Desc    = 'AdamX community power scheme.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\adamx.pow' }
                    Ru = @{
                        Title = 'Схема питания AdamX'
                        Desc  = 'Схема питания от сообщества AdamX.'
                    }
                }
                @{
                    Id      = 'power-scheme-xilly'
                    Title   = 'Xilly Power Scheme'
                    Desc    = 'Xilly community power scheme.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\Xilly.pow' }
                    Ru = @{
                        Title = 'Схема питания Xilly'
                        Desc  = 'Схема питания от сообщества Xilly.'
                    }
                }
                @{
                    Id      = 'power-scheme-tjx'
                    Title   = 'TJxTweaks Power Scheme'
                    Desc    = 'TJxTweaks community power scheme.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\TJxTweaks.pow' }
                    Ru = @{
                        Title = 'Схема питания TJxTweaks'
                        Desc  = 'Схема питания от сообщества TJxTweaks.'
                    }
                }
                @{
                    Id      = 'power-scheme-core'
                    Title   = 'Core Power Scheme'
                    Desc    = 'Core community power scheme.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\Core.pow' }
                    Ru = @{
                        Title = 'Схема питания Core'
                        Desc  = 'Схема питания от сообщества Core.'
                    }
                }
                @{
                    Id      = 'power-scheme-bitsium'
                    Title   = 'Bitsium Power Scheme'
                    Desc    = 'Bitsium community power scheme.'
                    Kind    = 'powerscheme'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{ File = 'Assets\PowerSchemes\bitsium.pow' }
                    Ru = @{
                        Title = 'Схема питания Bitsium'
                        Desc  = 'Схема питания от сообщества Bitsium.'
                    }
                }
            )
        }

        # ── 1.3 CTT Tweaker ───────────────────────────────────────────────────
        @{
            Id    = 'ctt-tweaker'
            Title = 'CTT Tweaker (Optional)'
            Order = 4
            MaxMovGuide = $true
            Ru    = @{ Title = 'CTT Tweaker (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'ctt-github'
                    Title   = 'CTT WinUtil — GitHub (source + releases)'
                    Desc    = 'Source code and releases for the Chris Titus Tech WinUtil tweaker. Run directly: irm christitus.com/win | iex'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/ChrisTitusTech/winutil'
                    Ru = @{
                        Title = 'CTT WinUtil — GitHub (исходный код и релизы)'
                        Desc  = 'Исходный код и релизы утилиты ChrisTitusTech WinUtil. Запуск напрямую: irm christitus.com/win | iex'
                    }
                }
                @{
                    Id      = 'ctt-launch'
                    Title   = 'Chris Titus Tech Win11 Tweaker'
                    Desc    = 'All-in-one tweaker by ChrisTitusTech. Run from admin PowerShell: irm christitus.com/win | iex'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Open an admin PowerShell and run: irm christitus.com/win | iex — then apply recommended tweaks for desktop PCs or laptops as appropriate.'
                    Ru = @{
                        Title       = 'Твикер Win11 от Chris Titus Tech'
                        Desc        = 'Универсальный твикер от ChrisTitusTech. Запуск из PowerShell с правами администратора: irm christitus.com/win | iex'
                        Instruction = 'Откройте PowerShell от имени администратора и выполните: irm christitus.com/win | iex — затем примените рекомендуемые твики для десктопа или ноутбука по необходимости.'
                    }
                }
                @{
                    Id      = 'ctt-channel'
                    Title   = 'Chris Titus Tech YouTube channel'
                    Desc    = 'Reference guide and explanations for the tweaker options.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.youtube.com/@ChrisTitusTech'
                    Ru = @{
                        Title = 'YouTube-канал Chris Titus Tech'
                        Desc  = 'Справочник и пояснения к параметрам твикера.'
                    }
                }
            )
        }

        # ── 2. Devices ────────────────────────────────────────────────────────
        @{
            Id    = 'devices'
            Title = 'Devices'
            Order = 5
            MaxMovGuide = $true
            Ru    = @{ Title = 'Устройства' }
            Tweaks = @(
                @{
                    Id      = 'devices-bluetooth'
                    Title   = 'Disable Bluetooth (if not needed)'
                    Desc    = 'Turn off Bluetooth to reduce background radio usage.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:bluetooth'
                    Instruction = 'Toggle Bluetooth off.'
                    Ru = @{
                        Title       = 'Отключить Bluetooth (если не нужен)'
                        Desc        = 'Выключите Bluetooth для снижения фоновой нагрузки от радиомодуля.'
                        Instruction = 'Переключите Bluetooth в положение «Выкл».'
                    }
                }
                @{
                    Id      = 'devices-pointer-precision'
                    Title   = 'Disable Enhanced Pointer Precision'
                    Desc    = 'Turn off mouse acceleration for consistent, predictable mouse movement (important for gaming).'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:mousetouchpad'
                    Instruction = 'Open Additional mouse settings → Pointer Options → uncheck "Enhance pointer precision".'
                    Ru = @{
                        Title       = 'Отключить улучшение точности указателя'
                        Desc        = 'Выключите ускорение мыши для точного и предсказуемого движения курсора (важно для игр).'
                        Instruction = 'Откройте Дополнительные параметры мыши → Параметры указателя → снимите флажок «Повышение точности указателя».'
                    }
                }
                @{
                    Id      = 'devices-cursor-color'
                    Title   = 'Cursor color & size'
                    Desc    = 'Set cursor size and color scheme in accessibility settings.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:easeofaccess-mousepointer'
                    Instruction = 'Choose cursor size and color (White, Black, or custom).'
                    Ru = @{
                        Title       = 'Цвет и размер курсора'
                        Desc        = 'Задайте размер и цветовую схему курсора в параметрах специальных возможностей.'
                        Instruction = 'Выберите размер и цвет курсора (белый, чёрный или пользовательский).'
                    }
                }
                @{
                    Id      = 'devices-sticky-keys'
                    Title   = 'Disable Sticky Keys & Filter Keys'
                    Desc    = 'Disable accidental activation of Sticky Keys and Filter Keys keyboard shortcuts.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:easeofaccess-keyboard'
                    Instruction = 'Turn off Sticky Keys, Filter Keys, and toggle keys.'
                    Ru = @{
                        Title       = 'Отключить залипание клавиш и фильтрацию ввода'
                        Desc        = 'Отключите случайную активацию сочетаний клавиш «Залипание клавиш» и «Фильтрация ввода».'
                        Instruction = 'Выключите «Залипание клавиш», «Фильтрацию ввода» и «Переключение клавиш».'
                    }
                }
                @{
                    Id      = 'devices-color-profile'
                    Title   = 'Install color profile'
                    Desc    = 'Apply an ICC color profile for accurate color reproduction on your monitor.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Download your monitor ICC profile from manufacturer or rtings.com, then open Color Management (colorcpl.exe), select your display, check "Use my settings for this device" and add the profile.'
                    Ru = @{
                        Title       = 'Установить цветовой профиль (ICC)'
                        Desc        = 'Примените ICC-профиль цвета для точного цветовоспроизведения монитора.'
                        Instruction = 'Скачайте ICC-профиль монитора с сайта производителя или rtings.com, затем откройте Управление цветом (colorcpl.exe), выберите дисплей, установите флажок «Использовать мои параметры для этого устройства» и добавьте профиль.'
                    }
                }
            )
        }

        # ── 2.1 USB Power Management ──────────────────────────────────────────
        @{
            Id    = 'usb-power'
            Title = 'USB Power Management'
            Order = 6
            MaxMovGuide = $true
            Ru    = @{ Title = 'Управление питанием USB' }
            Tweaks = @(
                @{
                    Id      = 'usb-disable-power-mgmt'
                    Title   = 'Disable power-saving on every device that allows it'
                    Desc    = 'Clears "Allow the computer to turn off this device to save power" on every device that exposes that checkbox — USB hubs and controllers, network adapters, input devices, serial/USB adapters. Fixes random disconnects, at the cost of some idle power. Revert restores only the devices this card switched off.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    # Scope note: the shipped script filters on $h.PNPDeviceID, but its own
                    # Select-Object drops that property — so the pattern collapses to "**" and it
                    # matches every power-manageable device, not just serial ports. That broad
                    # behaviour is kept deliberately (it is what actually fixes disconnects); the
                    # title and description above now say so instead of promising serial ports only.
                    #
                    # The script prints nothing, so the card used to tick itself green without ever
                    # saying what it touched. Measure the WMI flags on both sides of the run, report
                    # the real numbers, and remember exactly which devices we flipped so Revert can
                    # put back those and nothing else.
                    Apply = {
                        $ps1 = Join-Path $script:AppRoot 'Assets\Scripts\DisableUSBPowerManagement.ps1'
                        if (-not (Test-Path $ps1)) {
                            Write-OperationOutput ((Get-UiText 'InstallerScriptMissingFmt' 'Installer not found: {0}. Nothing was changed.') -f $ps1)
                            return
                        }

                        $before = Get-DevicePowerSaveState
                        if ($before.Total -eq 0) {
                            Write-OperationOutput (Get-UiText 'UsbPowerNoDevices' 'This machine exposes no power-manageable devices — there is nothing to change.')
                            return
                        }
                        Write-OperationOutput ((Get-UiText 'UsbPowerBeforeFmt' 'Power-manageable devices: {0}; power saving already off on {1}.') -f $before.Total, $before.PowerSaveOff)

                        & $ps1

                        $after = Get-DevicePowerSaveState
                        Write-OperationOutput ((Get-UiText 'UsbPowerAfterFmt' 'Power saving is now off on {0} of {1} devices.') -f $after.PowerSaveOff, $after.Total)
                        if ($after.PowerSaveOff -eq $before.PowerSaveOff) {
                            Write-OperationOutput (Get-UiText 'UsbPowerNoChange' 'Nothing changed — the devices were already in this state, or the change was refused.')
                            return
                        }

                        # The engine overwrites this tweak's own backup with @{applied=$true} right
                        # after the block returns, so the restore list lives under a sibling id.
                        $turnedOff = @($before.PowerSaveOn | Where-Object { $after.PowerSaveOffNames -contains $_ })
                        Write-TweakBackup 'usb-disable-power-mgmt.restore' @{ turnedOff = $turnedOff }
                    }
                    Revert = {
                        $backup = Read-TweakBackup 'usb-disable-power-mgmt.restore'
                        $names  = if ($backup -and $backup.turnedOff) { @($backup.turnedOff) } else { @() }
                        if ($names.Count -eq 0) {
                            Write-OperationOutput (Get-UiText 'UsbPowerNothingToRestore' 'No record of devices switched off by this card — nothing to restore.')
                            return
                        }
                        $restored = Set-DevicePowerSaveEnabled -InstanceNames $names -Enabled $true
                        Write-OperationOutput ((Get-UiText 'UsbPowerRestoredFmt' 'Power saving restored on {0} of {1} devices this card had switched off.') -f $restored, $names.Count)
                        Remove-TweakBackup 'usb-disable-power-mgmt.restore'
                    }
                    Detect = {
                        $s = Get-DevicePowerSaveState
                        $s.Total -gt 0 -and $s.PowerSaveOff -eq $s.Total
                    }
                    Ru = @{
                        Title = 'Отключить энергосбережение у всех устройств, где оно есть'
                        Desc  = 'Снимает галку «Разрешить отключение этого устройства для экономии энергии» у всех устройств, где она есть: USB-хабы и контроллеры, сетевые адаптеры, устройства ввода, последовательные/USB-переходники. Устраняет случайные отключения ценой некоторого расхода энергии в простое. Откат вернёт только те устройства, которые изменила эта карточка.'
                    }
                }
            )
        }

        # ── 2.2 SoundSwitch ───────────────────────────────────────────────────
        @{
            Id    = 'soundswitch'
            Title = 'SoundSwitch (Optional)'
            Order = 7
            MaxMovGuide = $true
            Ru    = @{ Title = 'SoundSwitch (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'soundswitch-download'
                    Title   = 'SoundSwitch — hotkey audio device switcher'
                    Desc    = 'Lightweight app for switching audio output/input devices with a keyboard shortcut.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Belphemur/SoundSwitch/releases'
                    Ru = @{
                        Title = 'SoundSwitch — переключение аудиоустройств горячей клавишей'
                        Desc  = 'Лёгкое приложение для переключения устройств вывода/ввода звука горячей клавишей.'
                    }
                }
            )
        }

        # ── 2.3 Phone Link ────────────────────────────────────────────────────
        @{
            Id    = 'phone-link'
            Title = 'Phone Link (Optional)'
            Order = 8
            MaxMovGuide = $true
            Ru    = @{ Title = 'Phone Link (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'phone-link-guide'
                    Title   = 'Connect Android phone to Windows (Link to Windows)'
                    Desc    = 'Step-by-step guide to link your Android phone via the Phone Link app and Cross Device Experience Host.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = '1. Install "Link to Windows" on your Android phone. 2. Download Phone Link and Cross Device Exp. Host via the links below (use store.rg-adguard.net if MS Store is blocked). 3. Open Mobile Devices settings and sign in with your Microsoft account. 4. Enable shared clipboard, notifications, and other desired features in Phone Link.'
                    Ru = @{
                        Title       = 'Подключить Android-телефон к Windows (Link to Windows)'
                        Desc        = 'Пошаговое руководство по подключению телефона через приложение Phone Link и Cross Device Experience Host.'
                        Instruction = '1. Установите «Link to Windows» на Android-телефон. 2. Скачайте Phone Link и Cross Device Exp. Host по ссылкам ниже (используйте store.rg-adguard.net если Microsoft Store заблокирован). 3. Откройте параметры мобильных устройств и войдите в аккаунт Microsoft. 4. Включите общий буфер обмена, уведомления и другие нужные функции в Phone Link.'
                    }
                }
                @{
                    Id      = 'phone-link-store-bypass'
                    Title   = 'MS Store package download (region bypass)'
                    Desc    = 'Alternative site for downloading Microsoft Store app packages (.msix) when the Store is blocked or slow.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://store.rg-adguard.net/'
                    Ru = @{
                        Title = 'Загрузка пакетов Microsoft Store (обход региона)'
                        Desc  = 'Альтернативный сайт для загрузки пакетов приложений Microsoft Store (.msix) когда Store заблокирован или работает медленно.'
                    }
                }
                @{
                    Id      = 'phone-link-app'
                    Title   = 'Phone Link — MS Store page'
                    Desc    = 'Official Phone Link app store page. Paste the URL into store.rg-adguard.net if the Store is unavailable.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://apps.microsoft.com/detail/9nmpj99vjbwv'
                    Ru = @{
                        Title = 'Phone Link — страница в Microsoft Store'
                        Desc  = 'Официальная страница приложения Phone Link. Вставьте URL в store.rg-adguard.net если Store недоступен.'
                    }
                }
                @{
                    Id      = 'phone-link-cross-device-host'
                    Title   = 'Cross Device Experience Host — MS Store page'
                    Desc    = 'Required companion component for cross-device features. Paste URL into store.rg-adguard.net if needed.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://apps.microsoft.com/detail/9ntxgkq8p7n0'
                    Ru = @{
                        Title = 'Cross Device Experience Host — страница в Microsoft Store'
                        Desc  = 'Обязательный компонент-дополнение для функций между устройствами. Вставьте URL в store.rg-adguard.net при необходимости.'
                    }
                }
                @{
                    Id      = 'phone-link-settings'
                    Title   = 'Mobile devices settings'
                    Desc    = 'Open Mobile devices settings to sign in and configure cross-device features.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:mobile-devices'
                    Instruction = 'Sign in with your Microsoft account and enable shared clipboard, notifications, and other Phone Link features.'
                    Ru = @{
                        Title       = 'Параметры мобильных устройств'
                        Desc        = 'Откройте параметры мобильных устройств для входа и настройки функций между устройствами.'
                        Instruction = 'Войдите в аккаунт Microsoft и включите общий буфер обмена, уведомления и другие функции Phone Link.'
                    }
                }
            )
        }

        # ── 3. Disk Indexing ──────────────────────────────────────────────────
        @{
            Id    = 'disk-indexing'
            Title = 'Disk Indexing (Optional)'
            Order = 9
            MaxMovGuide = $true
            Ru    = @{ Title = 'Индексирование дисков (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'indexing-disable-service'
                    Title   = 'Disable Windows Search indexing service'
                    Desc    = 'Stops and disables the WSearch service. Reduces disk & CPU load. Start menu search still works; building an index takes longer when enabled again.'
                    Kind    = 'service'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Name          = 'WSearch'
                        TargetStartup = 'Disabled'
                        TargetState   = 'Stopped'
                        RevertStartup = 'Automatic'
                        RevertState   = 'Running'
                    }
                    Ru = @{
                        Title = 'Отключить службу индексирования Windows Search'
                        Desc  = 'Останавливает и отключает службу WSearch. Снижает нагрузку на диск и CPU. Поиск в «Пуск» продолжает работать; при повторном включении построение индекса займёт время.'
                    }
                }
                @{
                    Id      = 'indexing-drive-properties'
                    Title   = 'Remove drive indexing flag (per-drive)'
                    Desc    = 'Uncheck "Allow files on this drive to have contents indexed" in each drive''s Properties.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Open File Explorer → right-click each drive → Properties → uncheck "Allow files on this drive to have contents indexed in addition to file properties".'
                    Ru = @{
                        Title       = 'Убрать флаг индексирования диска (для каждого диска)'
                        Desc        = 'Снимите флажок «Разрешить индексирование содержимого файлов на этом диске» в Свойствах каждого диска.'
                        Instruction = 'Откройте Проводник → щёлкните правой кнопкой по каждому диску → Свойства → снимите флажок «Разрешить индексирование содержимого файлов на этом диске в дополнение к свойствам файлов».'
                    }
                }
                @{
                    Id      = 'indexing-search-settings'
                    Title   = 'Configure Search index locations'
                    Desc    = 'Open Windows Search settings to define which folders to include in the index.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:cortana-windowssearch'
                    Instruction = 'Limit indexed locations to only the folders you actually need to search.'
                    Ru = @{
                        Title       = 'Настроить расположения индекса поиска'
                        Desc        = 'Откройте параметры поиска Windows для выбора папок, включаемых в индекс.'
                        Instruction = 'Ограничьте расположения индексирования только теми папками, в которых реально нужен поиск.'
                    }
                }
            )
        }

        # ── 4. Network & Internet ─────────────────────────────────────────────
        @{
            Id    = 'network'
            Title = 'Network & Internet'
            Order = 10
            MaxMovGuide = $true
            Ru    = @{ Title = 'Сеть и Интернет' }
            Tweaks = @(
                @{
                    Id      = 'network-metered-ethernet'
                    Title   = 'Mark Ethernet as metered connection'
                    Desc    = 'Prevents large background downloads (Windows Update delivery optimization, app updates) on Ethernet.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:network-ethernet'
                    Instruction = 'Select your Ethernet adapter → toggle "Metered connection" On.'
                    Ru = @{
                        Title       = 'Отметить Ethernet как лимитное подключение'
                        Desc        = 'Предотвращает крупные фоновые загрузки (Delivery Optimization, обновления приложений) через Ethernet.'
                        Instruction = 'Выберите адаптер Ethernet → включите «Лимитное подключение».'
                    }
                }
                @{
                    Id      = 'network-metered-wifi'
                    Title   = 'Mark Wi-Fi as metered connection'
                    Desc    = 'Prevents large background downloads over Wi-Fi.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:network-wifi'
                    Instruction = 'Select your Wi-Fi network → Properties → toggle "Metered connection" On.'
                    Ru = @{
                        Title       = 'Отметить Wi-Fi как лимитное подключение'
                        Desc        = 'Предотвращает крупные фоновые загрузки через Wi-Fi.'
                        Instruction = 'Выберите сеть Wi-Fi → Свойства → включите «Лимитное подключение».'
                    }
                }
                @{
                    Id      = 'network-adapter-properties'
                    Title   = 'Configure network adapter properties'
                    Desc    = 'Open adapter settings to configure DNS servers, IPv4, and adapter-specific power settings.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'ms-settings:network-advancedsettings'
                    Instruction = 'Set preferred DNS server to a fast provider (e.g. 1.1.1.1 / 1.0.0.1 or 8.8.8.8 / 8.8.4.4). Run DNSBench to find fastest DNS for your location.'
                    Ru = @{
                        Title       = 'Настроить свойства сетевого адаптера'
                        Desc        = 'Откройте параметры адаптера для настройки DNS-серверов, IPv4 и параметров питания адаптера.'
                        Instruction = 'Задайте предпочтительный DNS-сервер (например, 1.1.1.1 / 1.0.0.1 или 8.8.8.8 / 8.8.4.4). Запустите DNSBench для определения самого быстрого DNS для вашего местоположения.'
                    }
                }
                @{
                    Id      = 'network-dnsbench'
                    Title   = 'DNS Benchmark — find fastest DNS for your ISP'
                    Desc    = 'GRC DNSBench tests all known DNS resolvers and ranks them by speed from your location.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.grc.com/dns/benchmark.htm'
                    Ru = @{
                        Title = 'DNS Benchmark — найти самый быстрый DNS для вашего провайдера'
                        Desc  = 'GRC DNSBench тестирует все известные DNS-резолверы и ранжирует их по скорости с вашего местоположения.'
                    }
                }
                @{
                    Id      = 'network-cross-device'
                    Title   = 'Disable Cross-Device sync (if not needed)'
                    Desc    = 'Turns off phone link and cross-device experience if you do not use them.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:crossdevice'
                    Instruction = 'Toggle off Shared experiences and Phone Link if not needed.'
                    Ru = @{
                        Title       = 'Отключить синхронизацию между устройствами (если не нужна)'
                        Desc        = 'Отключает Phone Link и Cross Device Experience, если они не используются.'
                        Instruction = 'Выключите «Общий доступ к объектам» и Phone Link если не нужны.'
                    }
                }
            )
        }

        # ── 5. Personalization ────────────────────────────────────────────────
        @{
            Id    = 'personalization'
            Title = 'Personalization'
            Order = 11
            MaxMovGuide = $true
            Ru    = @{ Title = 'Персонализация' }
            Tweaks = @(
                @{
                    Id      = 'personalization-wallpaper'
                    Title   = 'Wallpaper'
                    Desc    = 'Set desktop wallpaper from Settings or browse local images.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:personalization-background'
                    Instruction = 'Choose a wallpaper image.'
                    Ru = @{
                        Title       = 'Обои рабочего стола'
                        Desc        = 'Установите обои через Параметры или выберите изображение из файлов.'
                        Instruction = 'Выберите изображение для обоев.'
                    }
                }
                @{
                    Id      = 'personalization-colors'
                    Title   = 'Colors & accent'
                    Desc    = 'Set Dark mode and accent color.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:colors'
                    Instruction = 'Choose Dark mode. Set accent color to Custom or auto from wallpaper.'
                    Ru = @{
                        Title       = 'Цвета и акцентный цвет'
                        Desc        = 'Задайте тёмный режим и акцентный цвет.'
                        Instruction = 'Выберите тёмный режим. Задайте акцентный цвет вручную или автоматически из обоев.'
                    }
                }
                @{
                    Id      = 'personalization-lockscreen'
                    Title   = 'Lock screen'
                    Desc    = 'Configure lock screen background and displayed info.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:lockscreen'
                    Instruction = 'Set lock screen image and disable unwanted lock-screen widgets.'
                    Ru = @{
                        Title       = 'Экран блокировки'
                        Desc        = 'Настройте фон экрана блокировки и отображаемую информацию.'
                        Instruction = 'Задайте изображение экрана блокировки и отключите ненужные виджеты.'
                    }
                }
                @{
                    Id      = 'personalization-start'
                    Title   = 'Start menu layout'
                    Desc    = 'Configure Start menu layout: show more pins, remove recommendations.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:personalization-start'
                    Instruction = 'Set layout to "More pins". Enable "Show recently added apps" and startup notification if desired.'
                    Ru = @{
                        Title       = 'Макет меню «Пуск»'
                        Desc        = 'Настройте макет «Пуск»: больше закреплённых элементов, убрать рекомендации.'
                        Instruction = 'Установите макет «Больше закреплённых». Включите «Показывать недавно добавленные приложения» и уведомление автозапуска при желании.'
                    }
                }
                @{
                    Id      = 'personalization-taskbar'
                    Title   = 'Taskbar configuration'
                    Desc    = 'Remove taskbar widgets, search, task view buttons; enable auto-hide if desired.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:taskbar'
                    Instruction = 'Disable Search, Task View, Widgets. Center or Left-align taskbar icons.'
                    Ru = @{
                        Title       = 'Настройка панели задач'
                        Desc        = 'Уберите виджеты, поиск, кнопку «Представление задач» с панели задач; включите автоскрытие при желании.'
                        Instruction = 'Отключите «Поиск», «Представление задач», «Виджеты». Выровняйте значки по центру или по левому краю.'
                    }
                }
                @{
                    Id      = 'personalization-device-usage'
                    Title   = 'Disable all Device Usage suggestions'
                    Desc    = 'Turn off Microsoft advertising and personalization features in Device Usage.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:deviceusage'
                    Instruction = 'Toggle off all options in Device usage.'
                    Ru = @{
                        Title       = 'Отключить все предложения Device Usage'
                        Desc        = 'Выключите функции рекламы и персонализации Microsoft в разделе «Использование устройства».'
                        Instruction = 'Выключите все параметры в разделе «Использование устройства».'
                    }
                }
            )
        }

        # ── 5.1 More Personalization ──────────────────────────────────────────
        @{
            Id    = 'personalization-more'
            Title = 'More Personalization'
            Order = 12
            Ru    = @{ Title = 'Дополнительная персонализация' }
            Tweaks = @(
                @{
                    Id      = 'personalization-classic-context-menu'
                    MaxMovGuide = $true
                    Title   = 'Classic right-click context menu (Win10 style)'
                    Desc    = 'Restores the full one-level context menu. Removes the "Show more options" extra click introduced in Win11.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $clsid  = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
                        $srv32  = "$clsid\InprocServer32"
                        if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null }
                        Set-Item -Path $clsid -Value '' -Force
                        if (-not (Test-Path $srv32))  { New-Item -Path $srv32  -Force | Out-Null }
                        Set-Item -Path $srv32  -Value '' -Force
                    }
                    Revert = {
                        $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
                        if (Test-Path $clsid) { Remove-Item -Path $clsid -Recurse -Force }
                    }
                    Detect = {
                        $srv32 = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
                        if (-not (Test-Path $srv32)) { return $false }
                        $val = (Get-Item $srv32).GetValue('')
                        $val -ne $null  # empty string means applied; absent key = not applied
                    }
                    Ru = @{
                        Title = 'Классическое контекстное меню (стиль Win10)'
                        Desc  = 'Восстанавливает полноценное одноуровневое контекстное меню. Убирает лишний клик «Показать дополнительные параметры» из Win11.'
                    }
                }
                @{
                    Id      = 'personalization-remove-gallery'
                    MaxMovGuide = $true
                    Title   = 'Remove Gallery from File Explorer navigation pane'
                    Desc    = 'Hides the Gallery entry in the Explorer left-side navigation tree.'
                    Kind    = 'registry'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKCU'
                        Path  = 'Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
                        Name  = 'System.IsPinnedToNameSpaceTree'
                        Type  = 'DWord'
                        Value = 0
                    }
                    Ru = @{
                        Title = 'Убрать «Галерею» из панели навигации Проводника'
                        Desc  = 'Скрывает элемент «Галерея» в дереве навигации слева в Проводнике.'
                    }
                }
                @{
                    Id      = 'personalization-remove-home'
                    Title   = 'Remove Home from File Explorer navigation pane'
                    Desc    = 'Hides the Home (MSGraph home) entry in the Explorer navigation tree.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $clsid = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
                        if (-not (Test-Path $clsid)) { New-Item -Path $clsid -Force | Out-Null }
                        Set-Item -Path $clsid -Value 'CLSID_MSGraphHomeFolder' -Force
                        Set-ItemProperty -Path $clsid -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord
                    }
                    Revert = {
                        $clsid = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
                        if (Test-Path $clsid) {
                            Set-ItemProperty -Path $clsid -Name 'System.IsPinnedToNameSpaceTree' -Value 1 -Type DWord
                        }
                    }
                    Detect = {
                        $clsid = 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
                        if (-not (Test-Path $clsid)) { return $false }
                        try { (Get-ItemProperty $clsid -Name 'System.IsPinnedToNameSpaceTree' -EA Stop).'System.IsPinnedToNameSpaceTree' -eq 0 }
                        catch { $false }
                    }
                    Ru = @{
                        Title = 'Убрать «Домой» из панели навигации Проводника'
                        Desc  = 'Скрывает элемент «Домой» (MSGraph home) из дерева навигации Проводника.'
                    }
                }
                @{
                    Id      = 'personalization-hide-start-recommendations'
                    MaxMovGuide = $true
                    Title   = 'Hide Start menu Recommended section (24H2)'
                    Desc    = 'Sets policy keys to hide the Recommended section in the Start menu. Requires 24H2 build 26100+. Uses PolicyManager keys (no GPO needed on Home).'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    AppliesTo = @{ MinBuild = 26100 }
                    Apply = {
                        $startPath = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start'
                        $eduPath   = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education'
                        $polPath   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
                        foreach ($p in @($startPath, $eduPath, $polPath)) {
                            if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
                        }
                        Set-ItemProperty -Path $startPath -Name 'HideRecommendedSection'   -Value 1 -Type DWord
                        Set-ItemProperty -Path $eduPath   -Name 'IsEducationEnvironment'   -Value 1 -Type DWord
                        Set-ItemProperty -Path $polPath   -Name 'HideRecommendedSection'   -Value 1 -Type DWord
                    }
                    Revert = {
                        $startPath = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start'
                        $eduPath   = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education'
                        $polPath   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
                        Remove-ItemProperty -Path $startPath -Name 'HideRecommendedSection' -EA SilentlyContinue
                        Remove-ItemProperty -Path $eduPath   -Name 'IsEducationEnvironment' -EA SilentlyContinue
                        Remove-ItemProperty -Path $polPath   -Name 'HideRecommendedSection' -EA SilentlyContinue
                    }
                    Detect = {
                        $polPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
                        if (-not (Test-Path $polPath)) { return $false }
                        try { (Get-ItemProperty $polPath -Name 'HideRecommendedSection' -EA Stop).'HideRecommendedSection' -eq 1 }
                        catch { $false }
                    }
                    Ru = @{
                        Title = 'Скрыть раздел «Рекомендуемые» в меню «Пуск» (24H2)'
                        Desc  = 'Устанавливает ключи политики для скрытия раздела «Рекомендуемые» в «Пуск». Требует сборку 24H2 26100+. Использует ключи PolicyManager (GPO не нужен в редакции Home).'
                    }
                }
                @{
                    Id      = 'personalization-photo-viewer'
                    Title   = 'Restore Windows Photo Viewer'
                    Desc    = 'Re-activates the legacy Photo Viewer (shimgvw.dll) as a registered image handler with better color accuracy than Photos app.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        # Re-register Windows Photo Viewer for image file types
                        $reg = 'HKCU:\Software\Classes'
                        foreach ($ext in @('.jpg','.jpeg','.bmp','.gif','.png','.tiff','.tif','.ico','.wdp')) {
                            $p = "$reg\$ext\OpenWithProgids"
                            if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
                            Set-ItemProperty -Path $p -Name 'PhotoViewer.FileAssoc.Tiff' -Value '' -Type String
                        }
                        # Restore the PhotoViewer.FileAssoc.Tiff association
                        $pvRoot = 'HKCU:\Software\Classes\PhotoViewer.FileAssoc.Tiff'
                        if (-not (Test-Path $pvRoot)) {
                            # Copy from HKLM if the registration exists
                            $hklmPV = 'HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'
                            if (Test-Path $hklmPV) {
                                New-Item -Path $pvRoot -Force | Out-Null
                            }
                        }
                    }
                    Detect = {
                        $p = 'HKCU:\Software\Classes\.jpg\OpenWithProgids'
                        if (-not (Test-Path $p)) { return $false }
                        try { $null -ne (Get-ItemProperty $p -Name 'PhotoViewer.FileAssoc.Tiff' -EA Stop) }
                        catch { $false }
                    }
                    Revert = {
                        foreach ($ext in @('.jpg','.jpeg','.bmp','.gif','.png','.tiff','.tif','.ico','.wdp')) {
                            $p = "HKCU:\Software\Classes\$ext\OpenWithProgids"
                            Remove-ItemProperty -Path $p -Name 'PhotoViewer.FileAssoc.Tiff' -EA SilentlyContinue
                        }
                    }
                    Ru = @{
                        Title = 'Восстановить Windows Photo Viewer'
                        Desc  = 'Повторно регистрирует устаревшую программу просмотра фотографий (shimgvw.dll) как обработчик изображений с лучшей точностью цветопередачи, чем приложение «Фотографии».'
                    }
                }
                @{
                    Id      = 'download-vivetool-personalization'
                    Title   = 'ViVeTool — download (GitHub releases)'
                    Desc    = 'Tool for enabling undocumented Windows feature flags via A/B experiment IDs. Required for unlocking 25H2 and other experimental features.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    AppliesTo = @{ MinBuild = 26200 }
                    Url     = 'https://github.com/thebookisclosed/ViVe/releases'
                    Ru = @{
                        Title = 'ViVeTool — скачать (релизы GitHub)'
                        Desc  = 'Инструмент для включения недокументированных флагов функций Windows через идентификаторы A/B-экспериментов. Нужен для разблокировки функций 25H2 и других экспериментальных возможностей.'
                    }
                }
                @{
                    Id      = 'personalization-25h2-features'
                    Title   = 'Enable 25H2 feature flags (ViVeTool)'
                    Desc    = 'Unlock experimental features for Win11 25H2 using ViVeTool. This is an unofficial tool that manipulates undocumented A/B feature flags.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $true
                    AppliesTo = @{ MinBuild = 26200 }
                    Instruction = 'Download and run ViVeTool (link above). Then run ViVeTool.exe with the feature IDs from the archive txt file. Requires a restart to take effect.'
                    Ru = @{
                        Title       = 'Включить флаги функций 25H2 (ViVeTool)'
                        Desc        = 'Разблокируйте экспериментальные функции Win11 25H2 с помощью ViVeTool. Неофициальный инструмент, манипулирующий недокументированными флагами A/B-функций.'
                        Instruction = 'Скачайте и запустите ViVeTool (ссылка выше). Затем выполните ViVeTool.exe с идентификаторами функций из текстового файла архива. Требуется перезагрузка для применения.'
                    }
                }
                @{
                    Id      = 'personalization-compact-taskbar'
                    MaxMovGuide = $true
                    Title   = 'Compact (Tablet) Taskbar mode'
                    Desc    = 'Reduces taskbar icon size and spacing via registry. Restart Explorer (or sign out) to apply.'
                    Kind    = 'registry'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKCU'
                        Path  = 'Software\Microsoft\Windows\CurrentVersion\Explorer'
                        Name  = 'TabletPostureTaskbar'
                        Type  = 'DWord'
                        Value = 1
                    }
                    Ru = @{
                        Title = 'Компактный (планшетный) режим панели задач'
                        Desc  = 'Уменьшает размер значков и отступы на панели задач через реестр. Для применения перезапустите Проводник (или выйдите из системы).'
                    }
                }
                @{
                    Id      = 'personalization-auto-dark-mode'
                    MaxMovGuide = $true
                    Title   = 'Auto Dark/Light theme switching (PowerToys)'
                    Desc    = 'PowerToys includes an Auto Dark Mode module that switches the Windows theme at sunrise/sunset automatically.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/microsoft/PowerToys/releases'
                    Ru = @{
                        Title = 'Автоматическое переключение тёмной/светлой темы (PowerToys)'
                        Desc  = 'PowerToys включает модуль Auto Dark Mode, автоматически переключающий тему Windows на рассвете/закате.'
                    }
                }
                @{
                    Id      = 'personalization-everything-search'
                    MaxMovGuide = $true
                    Title   = 'Everything — fast file search with own index'
                    Desc    = 'Everything indexes all drive filenames and delivers sub-second search results. Download the portable version.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.voidtools.com/'
                    Ru = @{
                        Title = 'Everything — быстрый поиск файлов с собственным индексом'
                        Desc  = 'Everything индексирует имена файлов на всех дисках и выдаёт результаты поиска за доли секунды. Скачайте портативную версию.'
                    }
                }
                @{
                    Id      = 'personalization-everything-powertoys-plugin'
                    MaxMovGuide = $true
                    Title   = 'Everything plugin for PowerToys Run'
                    Desc    = 'Integrates Everything search into PowerToys Run (Alt+Space) for instant file lookup.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/lin-ycv/EverythingPowerToys/releases'
                    Ru = @{
                        Title = 'Плагин Everything для PowerToys Run'
                        Desc  = 'Интегрирует поиск Everything в PowerToys Run (Alt+Space) для мгновенного поиска файлов.'
                    }
                }
                @{
                    Id      = 'personalization-display-switch'
                    Title   = 'DisplaySwitch — quick monitor mode shortcuts'
                    Desc    = 'Windows built-in DisplaySwitch.exe switches display mode: /1=PC screen only, /2=Duplicate, /3=Extend, /4=Second screen only.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Create desktop shortcuts to C:\Windows\System32\DisplaySwitch.exe with argument /1 (single monitor) or /3 (extend). Right-click Desktop → New → Shortcut, enter "DisplaySwitch.exe /3" as the location.'
                    Ru = @{
                        Title       = 'DisplaySwitch — быстрое переключение режимов монитора'
                        Desc        = 'Встроенный в Windows DisplaySwitch.exe переключает режим экрана: /1=только ПК, /2=Дублировать, /3=Расширить, /4=Только второй экран.'
                        Instruction = 'Создайте ярлыки на рабочем столе для C:\Windows\System32\DisplaySwitch.exe с аргументом /1 (один монитор) или /3 (расширить). Правая кнопка мыши на рабочем столе → Создать → Ярлык, введите «DisplaySwitch.exe /3» в качестве пути.'
                    }
                }
            )
        }

        # ── 6. Apps ───────────────────────────────────────────────────────────
        @{
            Id    = 'apps'
            Title = 'Apps'
            Order = 13
            MaxMovGuide = $true
            Ru    = @{ Title = 'Приложения' }
            Tweaks = @(
                @{
                    Id      = 'apps-background-apps'
                    Title   = 'Disable background app activity'
                    Desc    = 'Prevent apps from running and updating data in the background.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:privacy-backgroundapps'
                    Instruction = 'For each app, disable background access or set to "Power optimized".'
                    Ru = @{
                        Title       = 'Отключить фоновую активность приложений'
                        Desc        = 'Запретите приложениям работать и обновлять данные в фоновом режиме.'
                        Instruction = 'Для каждого приложения отключите фоновый доступ или установите «Оптимизировано для экономии энергии».'
                    }
                }
                @{
                    Id      = 'apps-cross-device'
                    Title   = 'Disable transfer between devices & backup'
                    Desc    = 'Turns off cross-device transfer and app backup to Microsoft account.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:crossdevice'
                    Instruction = 'Disable "Save app state" and "Transfer to new device" options.'
                    Ru = @{
                        Title       = 'Отключить перенос между устройствами и резервное копирование'
                        Desc        = 'Отключает перенос между устройствами и резервное копирование приложений в аккаунт Microsoft.'
                        Instruction = 'Отключите «Сохранять состояние приложений» и «Перенос на новое устройство».'
                    }
                }
                @{
                    Id      = 'apps-default-file-associations'
                    Title   = 'Set default apps for file extensions'
                    Desc    = 'Assign preferred apps for file types (e.g. browser for HTML, image viewer for PNG).'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:defaultapps'
                    Instruction = 'Set default application for each file extension you use regularly.'
                    Ru = @{
                        Title       = 'Задать приложения по умолчанию для типов файлов'
                        Desc        = 'Назначьте предпочтительные приложения для типов файлов (например, браузер для HTML, просмотрщик для PNG).'
                        Instruction = 'Задайте приложение по умолчанию для каждого используемого типа файлов.'
                    }
                }
                @{
                    Id      = 'apps-startup'
                    Title   = 'Disable unnecessary startup apps'
                    Desc    = 'Review and disable apps that launch at Windows startup.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:startupapps'
                    Instruction = 'Toggle off any startup apps you do not actively use.'
                    Ru = @{
                        Title       = 'Отключить ненужные приложения автозапуска'
                        Desc        = 'Просмотрите и отключите приложения, запускающиеся при старте Windows.'
                        Instruction = 'Выключите все приложения автозапуска, которыми не пользуетесь регулярно.'
                    }
                }
                @{
                    Id      = 'apps-store-update'
                    Title   = 'Install all Microsoft Store app updates'
                    Desc    = 'Ensure all Store apps are up-to-date before configuring defaults.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-windows-store://updates'
                    Instruction = 'Click "Get updates" and wait for all apps to update.'
                    Ru = @{
                        Title       = 'Установить все обновления приложений Microsoft Store'
                        Desc        = 'Убедитесь, что все приложения из Store обновлены перед настройкой программ по умолчанию.'
                        Instruction = 'Нажмите «Проверить наличие обновлений» и дождитесь обновления всех приложений.'
                    }
                }
            )
        }

        # ── 6.1 Other Startup Settings ───────────────────────────────────────
        @{
            Id    = 'startup-other'
            Title = 'Other Startup Settings (Optional)'
            Order = 14
            MaxMovGuide = $true
            Ru    = @{ Title = 'Другие параметры автозапуска (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'startup-user-folder'
                    Title   = 'Open User Startup folder'
                    Desc    = 'Opens the current-user Startup folder in Explorer. Shortcuts here launch at login for this user only.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $path = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
                        Start-Process explorer.exe $path
                    }
                    Ru = @{
                        Title = 'Открыть папку автозапуска пользователя'
                        Desc  = 'Открывает папку автозапуска текущего пользователя в Проводнике. Ярлыки здесь запускаются при входе только для этого пользователя.'
                    }
                }
                @{
                    Id      = 'startup-system-folder'
                    Title   = 'Open System Startup folder'
                    Desc    = 'Opens the system-wide Startup folder in Explorer. Shortcuts here launch at login for all users.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Apply = {
                        $path = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup'
                        Start-Process explorer.exe $path
                    }
                    Ru = @{
                        Title = 'Открыть системную папку автозапуска'
                        Desc  = 'Открывает общесистемную папку автозапуска в Проводнике. Ярлыки здесь запускаются при входе для всех пользователей.'
                    }
                }
                @{
                    Id      = 'startup-autoruns'
                    Title   = 'Sysinternals Autoruns — comprehensive startup manager'
                    Desc    = 'Shows every auto-start location: registry, drivers, scheduled tasks, services, browser extensions, and more.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns'
                    Ru = @{
                        Title = 'Sysinternals Autoruns — всесторонний менеджер автозапуска'
                        Desc  = 'Показывает все места автозапуска: реестр, драйверы, запланированные задачи, службы, расширения браузеров и другое.'
                    }
                }
            )
        }

        # ── 7. Language & Time ────────────────────────────────────────────────
        @{
            Id    = 'language'
            Title = 'Language & Time'
            Order = 15
            MaxMovGuide = $true
            Ru    = @{ Title = 'Язык и Время' }
            Tweaks = @(
                @{
                    Id      = 'language-taskbar-clock'
                    Title   = 'Clock on taskbar — format & display'
                    Desc    = 'Open taskbar settings to configure clock format and additional calendars.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:taskbar'
                    Instruction = 'Scroll to System tray → Clock — enable seconds if desired.'
                    Ru = @{
                        Title       = 'Часы на панели задач — формат и отображение'
                        Desc        = 'Откройте параметры панели задач для настройки формата часов и дополнительных календарей.'
                        Instruction = 'Прокрутите до «Системные значки» → Часы — включите секунды при желании.'
                    }
                }
                @{
                    Id      = 'language-input-settings'
                    Title   = 'Disable unnecessary input features'
                    Desc    = 'Remove hardware keyboard suggestions, autocorrect, and other input method features.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:keyboard'
                    Instruction = 'Turn off Autocorrect, Spell check, and Text predictions.'
                    Ru = @{
                        Title       = 'Отключить ненужные функции ввода'
                        Desc        = 'Уберите предложения аппаратной клавиатуры, автозамену и другие функции метода ввода.'
                        Instruction = 'Выключите «Автозамену», «Проверку правописания» и «Текстовые прогнозы».'
                    }
                }
                @{
                    Id      = 'language-keyboard-shortcut'
                    Title   = 'Language keyboard shortcut'
                    Desc    = 'Configure the hotkey for switching input languages.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:keyboard'
                    Instruction = 'Click "Advanced keyboard settings" → Input language hotkeys → set to preferred shortcut or "Not assigned".'
                    Ru = @{
                        Title       = 'Горячая клавиша переключения языка'
                        Desc        = 'Настройте горячую клавишу для переключения языка ввода.'
                        Instruction = 'Нажмите «Дополнительные параметры клавиатуры» → Горячие клавиши языка ввода → задайте нужное сочетание или «Не назначено».'
                    }
                }
                @{
                    Id      = 'language-open-hotkey-dialog'
                    Title   = 'Open Input Language Hotkeys dialog'
                    Desc    = 'Opens the classic Advanced Key Settings dialog where you can view and change the keyboard language switch shortcut.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        Start-Process 'rundll32.exe' -ArgumentList 'shell32.dll,Control_RunDLL input.dll,,{C07337D3-DB2C-4D0B-9A93-B722A6C106E2}'
                    }
                    Ru = @{
                        Title = 'Открыть диалог горячих клавиш языка ввода'
                        Desc  = 'Открывает классический диалог «Дополнительные параметры клавиши», где можно просмотреть и изменить сочетание клавиш переключения языка.'
                    }
                }
                @{
                    Id      = 'language-keyboard-toggle-ctrlshift'
                    Title   = 'Switch language hotkey: Alt+Shift → Ctrl+Shift'
                    Desc    = 'Changes the keyboard language switch shortcut from Alt+Shift (Windows default) to Ctrl+Shift. Takes effect after sign-out or Explorer restart.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $path = 'HKCU:\Keyboard Layout\Toggle'
                        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                        Set-ItemProperty -Path $path -Name 'Hotkey'          -Value '2' -Type String
                        Set-ItemProperty -Path $path -Name 'Language Hotkey' -Value '2' -Type String
                        Set-ItemProperty -Path $path -Name 'Layout Hotkey'   -Value '3' -Type String
                    }
                    Revert = {
                        $path = 'HKCU:\Keyboard Layout\Toggle'
                        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                        Set-ItemProperty -Path $path -Name 'Hotkey'          -Value '1' -Type String
                        Set-ItemProperty -Path $path -Name 'Language Hotkey' -Value '1' -Type String
                        Set-ItemProperty -Path $path -Name 'Layout Hotkey'   -Value '2' -Type String
                    }
                    Detect = {
                        $path = 'HKCU:\Keyboard Layout\Toggle'
                        if (-not (Test-Path $path)) { return $false }
                        try { (Get-ItemProperty $path -Name 'Hotkey' -EA Stop).Hotkey -eq '2' }
                        catch { $false }
                    }
                    Ru = @{
                        Title = 'Сменить горячую клавишу языка: Alt+Shift → Ctrl+Shift'
                        Desc  = 'Меняет сочетание клавиш переключения языка ввода с Alt+Shift (умолчание Windows) на Ctrl+Shift. Вступает в силу после выхода из системы или перезапуска Проводника.'
                    }
                }
            )
        }

        # ── 8. Privacy ────────────────────────────────────────────────────────
        @{
            Id    = 'privacy'
            Title = 'Privacy'
            Order = 16
            MaxMovGuide = $true
            Ru    = @{ Title = 'Конфиденциальность' }
            Tweaks = @(
                @{
                    Id      = 'privacy-general'
                    Title   = 'Disable all General privacy options'
                    Desc    = 'Turns off advertising ID, language list access, app launch tracking, suggested content, and settings page recommendations.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:privacy-general'
                    Instruction = 'Toggle off every option on this page.'
                    Ru = @{
                        Title       = 'Отключить все общие параметры конфиденциальности'
                        Desc        = 'Выключает рекламный идентификатор, доступ к списку языков, отслеживание запуска приложений, предлагаемый контент и рекомендации в Параметрах.'
                        Instruction = 'Выключите каждый параметр на этой странице.'
                    }
                }
                @{
                    Id      = 'privacy-speech'
                    Title   = 'Disable online speech recognition'
                    Desc    = 'Prevents Microsoft from collecting voice data for speech model improvement. Same switch as Privacy & security > Speech.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKCU'
                        Path  = 'SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
                        Name  = 'HasAccepted'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить онлайн-распознавание речи'
                        Desc  = 'Запрещает Microsoft собирать голосовые данные для улучшения речевых моделей. Тот же переключатель, что «Конфиденциальность и защита → Речь».'
                    }
                }
                @{
                    Id      = 'privacy-inking'
                    Title   = 'Disable inking & typing personalization'
                    Desc    = 'Stops Microsoft from collecting typed and handwritten data for custom dictionary.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:privacy-speechtyping'
                    Instruction = 'Turn off "Getting to know you" personalization.'
                    Ru = @{
                        Title       = 'Отключить персонализацию рукописного ввода и набора текста'
                        Desc        = 'Прекращает сбор Microsoft данных о печатаемом и написанном от руки тексте для пользовательского словаря.'
                        Instruction = 'Выключите персонализацию «Знакомство с вами».'
                    }
                }
                @{
                    Id      = 'privacy-diagnostics'
                    Title   = 'Set diagnostics to Required only, delete data'
                    Desc    = 'Reduce telemetry to the minimum allowed. Delete previously collected diagnostic data.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'ms-settings:privacy-feedback'
                    Instruction = 'Set "Diagnostic data" to Required only. Click "Delete diagnostic data" to remove existing data. Set feedback frequency to Never.'
                    Ru = @{
                        Title       = 'Установить диагностику «Обязательные данные», удалить данные'
                        Desc        = 'Уменьшите телеметрию до минимально допустимого уровня. Удалите ранее собранные диагностические данные.'
                        Instruction = 'Установите «Диагностические данные» в «Обязательные данные». Нажмите «Удалить диагностические данные» для удаления существующих. Установите частоту отзывов в «Никогда».'
                    }
                }
                @{
                    Id      = 'privacy-search-permissions'
                    Title   = 'Disable all Search permissions'
                    Desc    = 'Prevents Windows Search from sending search history and web suggestions to Microsoft.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:search-permissions'
                    Instruction = 'Toggle off all options: SafeSearch, Cloud content search, Search history, Better search suggestions.'
                    Ru = @{
                        Title       = 'Отключить все разрешения поиска'
                        Desc        = 'Запрещает Windows Search отправлять историю поиска и веб-предложения в Microsoft.'
                        Instruction = 'Выключите все параметры: SafeSearch, облачный поиск, историю поиска, улучшенные предложения.'
                    }
                }
                @{
                    Id      = 'privacy-location'
                    Title   = 'Disable location services'
                    Desc    = 'Turns off the system-wide location master switch. Per-app permissions stay as they are — grant them individually if something actually needs location.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
                        Name  = 'Value'
                        Value = 'Deny'
                        Type  = 'String'
                    }
                    Ru = @{
                        Title = 'Отключить службы геолокации'
                        Desc  = 'Выключает общесистемный переключатель геолокации. Разрешения отдельных приложений остаются как были — выдавайте их поштучно, если геолокация кому-то действительно нужна.'
                    }
                }
                @{
                    Id      = 'privacy-app-diagnostics'
                    Title   = 'Disable app diagnostic data access'
                    Desc    = 'Prevents apps from reading other apps diagnostic information. Same switch as Privacy & security > App diagnostics.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'
                        Name  = 'Value'
                        Value = 'Deny'
                        Type  = 'String'
                    }
                    Ru = @{
                        Title = 'Отключить доступ приложений к диагностическим данным'
                        Desc  = 'Запрещает приложениям читать диагностическую информацию других приложений. Тот же переключатель, что «Конфиденциальность и защита → Диагностика приложений».'
                    }
                }
                @{
                    Id      = 'privacy-custom-devices'
                    Title   = 'Disable custom device data sharing'
                    Desc    = 'Prevents apps from sharing data with custom devices on the network.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:privacy-customdevices'
                    Instruction = 'Toggle off "Communicate with unpaired devices".'
                    Ru = @{
                        Title       = 'Отключить передачу данных пользовательским устройствам'
                        Desc        = 'Запрещает приложениям обмениваться данными с пользовательскими устройствами в сети.'
                        Instruction = 'Выключите «Взаимодействие с непарными устройствами».'
                    }
                }
            )
        }

        # ── 9. Windows Update ─────────────────────────────────────────────────
        @{
            Id    = 'updates'
            Title = 'Windows Update'
            Order = 17
            MaxMovGuide = $true
            Ru    = @{ Title = 'Центр обновления Windows' }
            Tweaks = @(
                @{
                    Id      = 'updates-check'
                    Title   = 'Check for Windows Updates'
                    Desc    = 'Verify all Windows updates are installed before final configuration.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:windowsupdate'
                    Instruction = 'Click "Check for updates" and install all available updates. Restart if prompted.'
                    Ru = @{
                        Title       = 'Проверить обновления Windows'
                        Desc        = 'Убедитесь, что все обновления Windows установлены перед финальной настройкой.'
                        Instruction = 'Нажмите «Проверить наличие обновлений» и установите все доступные. При необходимости перезагрузитесь.'
                    }
                }
                @{
                    Id      = 'updates-optional'
                    Title   = 'Check optional & driver updates'
                    Desc    = 'Review optional updates for driver updates not delivered via main Windows Update.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:windowsupdate-optionalupdates'
                    Instruction = 'Install optional driver updates if relevant to your hardware.'
                    Ru = @{
                        Title       = 'Проверить дополнительные и драйверные обновления'
                        Desc        = 'Просмотрите дополнительные обновления для драйверов, не поставляемых через основной Центр обновления.'
                        Instruction = 'Установите дополнительные обновления драйверов, если они актуальны для вашего оборудования.'
                    }
                }
                @{
                    Id      = 'updates-delivery-optimization'
                    Title   = 'Disable Delivery Optimization (P2P updates)'
                    Desc    = 'Prevents Windows from using your internet connection to send updates to other PCs. Writes the policy value, which also greys the switch out in Settings.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
                        Name  = 'DODownloadMode'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить оптимизацию доставки (P2P-обновления)'
                        Desc  = 'Запрещает Windows использовать ваше интернет-соединение для отправки обновлений другим ПК. Пишет значение политики — переключатель в Параметрах при этом становится неактивным.'
                    }
                }
                @{
                    Id      = 'updates-find-my-device'
                    Title   = 'Disable Find My Device (if not needed)'
                    Desc    = 'Turns off device location tracking via Microsoft account. Same switch as Privacy & security > Find my device.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowFindMyDevice'
                        Name  = 'value'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить «Найти моё устройство» (если не нужно)'
                        Desc  = 'Выключает отслеживание местоположения устройства через аккаунт Microsoft. Тот же переключатель, что «Конфиденциальность и защита → Поиск устройства».'
                    }
                }
            )
        }

    )
}
