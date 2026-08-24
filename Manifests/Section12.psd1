@{
    Id    = 'maxmov-tweaks'
    Title = 'Max.mov Tweaks'
    Order = 12
    Ru    = @{ Title = 'Max.mov Tweaks' }

    Subsections = @(

        @{
            Id    = 'maxmov-hub'
            Title = 'Max.mov Hub'
            Order = 0
            SelectionMode = 'cards-only'
            Ru    = @{ Title = 'Max.mov Hub' }
            Tweaks = @(
                @{
                    Id      = 'maxmov-what-is-this'
                    Title   = 'What belongs in Max.mov Tweaks'
                    Desc    = 'A separate place for the Max.mov pack: profiles, wallpapers, cursor packs, personalization files, and community gaming notes.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Use this section as a hub for Max.mov-specific assets. Official vendor settings stay in their vendor sections; Max.mov packs, profiles, wallpapers, cursors, and gaming notes live here.'
                    Ru = @{
                        Title       = 'Что лежит в Max.mov Tweaks'
                        Desc        = 'Отдельное место для пакета Max.mov: профили, обои, курсоры, файлы персонализации и геймерские заметки сообщества.'
                        Instruction = 'Используйте этот раздел как хаб для Max.mov-специфичных ассетов. Официальные настройки вендоров остаются в разделах вендоров; пакеты Max.mov, профили, обои, курсоры и игровые заметки живут здесь.'
                    }
                }
                @{
                    Id      = 'maxmov-open-current-folder'
                    Title   = 'Open current Audion Windows Tools folder'
                    Desc    = 'Opens the current portable project folder.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens the current toolkit folder.'
                    Apply = { Start-Process explorer.exe -ArgumentList "`"$script:AppRoot`"" }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть текущую папку Audion Windows Tools'
                        Desc        = 'Открывает текущую портативную папку проекта.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает текущую папку тулкита.'
                    }
                }
                @{
                    Id      = 'maxmov-open-resources-folder'
                    Title   = 'Open local Max.mov resources'
                    Desc    = 'Opens the local Assets\MaxMov folder copied into this project.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open resources'
                    ActionNote  = 'Direct action: opens the local Max.mov resources folder.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Max.mov resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальные ресурсы Max.mov'
                        Desc        = 'Открывает локальную папку Assets\MaxMov, скопированную внутрь проекта.'
                        ButtonLabel = 'Открыть ресурсы'
                        ActionNote  = 'Прямое действие: открывает локальную папку ресурсов Max.mov.'
                    }
                }
            )
        }

        @{
            Id    = 'maxmov-profiles'
            Title = 'Profiles & Presets'
            Order = 1
            SelectionMode = 'cards-only'
            Ru    = @{ Title = 'Профили и пресеты' }
            Tweaks = @(
                @{
                    Id      = 'maxmov-open-personalization-pack'
                    Title   = 'Open local personalization pack'
                    Desc    = 'Opens the local Max.mov personalization area with cursor packs, icons, wallpapers, and visual presets.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens local copied resources. Review files manually before applying anything.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Personalization'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Personalization resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальный пакет персонализации'
                        Desc        = 'Открывает локальную область Max.mov с курсорами, иконками, обоями и визуальными пресетами.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает скопированные локальные ресурсы. Перед применением файлов проверяйте их вручную.'
                    }
                }
                @{
                    Id      = 'maxmov-open-nvidia-profile-pack'
                    Title   = 'Open local Nvidia profiles/settings'
                    Desc    = 'Opens local copied Nvidia settings materials. Use them as reference for profiles and guides, while official NVIDIA recommendations remain in GPU & Monitor.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens local Nvidia notes only. Donor URL shortcuts are not shipped.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Profiles\Nvidia'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Nvidia profile resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальные профили/настройки Nvidia'
                        Desc        = 'Открывает локально скопированные материалы Nvidia. Используйте их как справочник для профилей и гайдов; официальные рекомендации NVIDIA остаются в GPU и Монитор.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает только локальные заметки Nvidia. Донорские URL-ярлыки не поставляются.'
                    }
                }
                @{
                    Id      = 'maxmov-profiles-note'
                    Title   = 'Profiles are review-first'
                    Desc    = 'Old Max.mov profiles should be reviewed before import because driver versions, game builds, and monitor setups change.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Do not bulk-import old profiles blindly. Open the local resource folder, check the target app/driver version, then apply only the relevant profile through the official tool or the app that created it.'
                    Ru = @{
                        Title       = 'Профили сначала проверяем'
                        Desc        = 'Старые профили Max.mov стоит проверять перед импортом: версии драйверов, игр и конфигурации мониторов меняются.'
                        Instruction = 'Не импортируйте старые профили пачкой вслепую. Откройте локальную папку ресурсов, проверьте версию целевого приложения/драйвера и применяйте только нужный профиль через официальный инструмент или программу, которая его создала.'
                    }
                }
                @{
                    Id      = 'maxmov-legacy-files-removed-note'
                    Title   = 'Legacy scripts are not shipped here'
                    Desc    = 'Old .reg, .bat, .cmd, .ps1, executables, archives, URL shortcuts, and shortcut files from the donor pack are intentionally excluded from Assets\MaxMov so users cannot run or open them by accident.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'If an old Max.mov operation is useful, convert it into a manifest card with PS-native Apply/Detect/Revert logic first. Do not restore legacy scripts as clickable files inside the resources folder.'
                    Ru = @{
                        Title       = 'Legacy-скрипты здесь не поставляются'
                        Desc        = 'Старые .reg, .bat, .cmd, .ps1, исполняемые файлы, архивы, URL-ярлыки и обычные ярлыки из донорского пакета намеренно исключены из Assets\MaxMov, чтобы пользователь случайно их не запустил или не открыл.'
                        Instruction = 'Если старая операция Max.mov полезна, сначала переводим её в карточку манифеста с PS-native Apply/Detect/Revert. Не возвращаем legacy-скрипты как кликабельные файлы внутри папки ресурсов.'
                    }
                }
            )
        }

        @{
            Id    = 'maxmov-wallpapers-cursors'
            Title = 'Wallpapers, Cursors & Visuals'
            Order = 2
            SelectionMode = 'cards-only'
            Ru    = @{ Title = 'Обои, курсоры и визуал' }
            Tweaks = @(
                @{
                    Id      = 'maxmov-open-wallpapers-cursors'
                    Title   = 'Open local wallpapers/cursors'
                    Desc    = 'Opens the local Max.mov visual assets area with .cur/.ani cursors and image files.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens the local visual asset area.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Personalization'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Visual assets folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальные обои/курсоры'
                        Desc        = 'Открывает локальную область Max.mov с визуальными ассетами: .cur/.ani курсорами и изображениями.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает локальную область визуальных ассетов.'
                    }
                }
                @{
                    Id      = 'maxmov-cursor-install-note'
                    Title   = 'Install cursor packs manually'
                    Desc    = 'Cursor packs should be applied through Windows Mouse Properties or the pack installer if one is included.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open Settings -> Bluetooth & devices -> Mouse -> Additional mouse settings -> Pointers. Save your current scheme first, then browse to .cur/.ani files from the Max.mov cursor pack and save the new scheme.'
                    Ru = @{
                        Title       = 'Устанавливать курсоры вручную'
                        Desc        = 'Паки курсоров лучше применять через свойства мыши Windows или через установщик пака, если он есть.'
                        Instruction = 'Откройте Параметры -> Bluetooth и устройства -> Мышь -> Дополнительные параметры мыши -> Указатели. Сначала сохраните текущую схему, затем выберите .cur/.ani файлы из пака Max.mov и сохраните новую схему.'
                    }
                }
                @{
                    Id      = 'maxmov-wallpaper-install-note'
                    Title   = 'Apply wallpapers through Personalization'
                    Desc    = 'Wallpapers are safe visual assets; apply them from Windows Personalization or copy them into your Pictures/Wallpapers folder.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Copy the wallpapers you want to keep into your user Pictures or Wallpapers folder, then open Settings -> Personalization -> Background and select the image or slideshow folder.'
                    Ru = @{
                        Title       = 'Применять обои через Персонализацию'
                        Desc        = 'Обои - безопасные визуальные ассеты; применяйте их из персонализации Windows или копируйте в свою папку Pictures/Wallpapers.'
                        Instruction = 'Скопируйте нужные обои в папку Изображения или Wallpapers пользователя, затем откройте Параметры -> Персонализация -> Фон и выберите изображение или папку слайд-шоу.'
                    }
                }
            )
        }

        @{
            Id    = 'maxmov-gaming'
            Title = 'Gaming Pack'
            Order = 3
            SelectionMode = 'cards-only'
            Ru    = @{ Title = 'Геймерский пакет' }
            Tweaks = @(
                @{
                    Id      = 'maxmov-open-gaming-folder'
                    Title   = 'Open local Gaming resources'
                    Desc    = 'Opens the local Max.mov gaming resources folder with launcher notes, Timer Resolution notes, and FPS/latency notes.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens the local gaming resources folder.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Gaming'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Gaming resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальные игровые ресурсы'
                        Desc        = 'Открывает локальную папку Max.mov с игровыми ресурсами: заметки по лаунчерам, заметки Timer Resolution и FPS/Latency.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает локальную папку игровых ресурсов.'
                    }
                }
                @{
                    Id      = 'maxmov-open-steam-launchers-pack'
                    Title   = 'Open local Steam/Game Launchers pack'
                    Desc    = 'Opens local copied notes for Steam and other game launchers. Donor URL shortcuts are not shipped; official download buttons stay in Steam & Game Launchers.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens local launcher materials. Installers and official links still stay in Steam & Game Launchers.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Gaming\SteamGameLaunchers'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Steam/Game Launchers resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальный пакет Steam/Game Launchers'
                        Desc        = 'Открывает локально скопированные заметки для Steam и других игровых лаунчеров. Донорские URL-ярлыки не поставляются; официальные кнопки скачивания остаются в Steam и игровые лаунчеры.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает локальные материалы по лаунчерам. Установщики и официальные ссылки остаются в разделе Steam и игровые лаунчеры.'
                    }
                }
                @{
                    Id      = 'maxmov-open-latency-testing-pack'
                    Title   = 'Open local FPS/latency testing pack'
                    Desc    = 'Opens the local FPS and latency testing resources with Max.mov notes. Donor URL shortcuts are not shipped; official download buttons stay in FPS & Latency Testing.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens local measurement materials. Tool downloads still live in FPS & Latency Testing.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Gaming\FPSLatencyTesting'
                        if (-not (Test-Path -LiteralPath $target)) { throw "FPS/latency resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальный пакет FPS/Latency'
                        Desc        = 'Открывает локальные ресурсы тестирования FPS и задержки с заметками и ссылками Max.mov.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает локальные материалы измерений. Скачивания инструментов остаются в разделе FPS и задержка.'
                    }
                }
                @{
                    Id      = 'maxmov-open-timer-resolution-pack'
                    Title   = 'Open local Timer Resolution notes'
                    Desc    = 'Opens local Timer Resolution notes only. The old executable archive is intentionally not shipped here.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    Tone    = 'sand'
                    CanRevert = $false
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    ButtonLabel = 'Open'
                    ActionNote  = 'Direct action: opens local Timer Resolution notes without installing or launching anything.'
                    Apply = {
                        $target = Join-Path $script:AppRoot 'Assets\MaxMov\Gaming\TimerResolution'
                        if (-not (Test-Path -LiteralPath $target)) { throw "Timer Resolution resources folder not found: $target" }
                        Start-Process explorer.exe -ArgumentList "`"$target`""
                    }
                    Detect = { $false }
                    Ru = @{
                        Title       = 'Открыть локальные заметки Timer Resolution'
                        Desc        = 'Открывает только локальные заметки Timer Resolution. Старый исполняемый архив намеренно не поставляется здесь.'
                        ButtonLabel = 'Открыть'
                        ActionNote  = 'Прямое действие: открывает локальные заметки Timer Resolution без установки или запуска чего-либо.'
                    }
                }
            )
        }
    )
}
