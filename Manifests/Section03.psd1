@{
    Id    = 'browser-setup'
    Title = 'Browser Setup'
    Order = 3
    Ru    = @{ Title = 'Настройка браузера' }

    Subsections = @(

        # ── 1. Edge Configuration ─────────────────────────────────────────────
        @{
            Id    = 'edge-config'
            Title = 'Edge Configuration'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройка Edge' }
            Tweaks = @(
                @{
                    Id      = 'configure-edge'
                    Title   = 'Configure Microsoft Edge settings'
                    Desc    = 'Open Edge settings page to disable telemetry, personalisation, shopping features, and configure startup behaviour.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'microsoft-edge:settings/privacy'
                    Instruction = 'Disable all telemetry and personalisation toggles. Under Privacy, search, and services → disable Help improve Microsoft products. Under New tab page → turn off news feed.'
                    Ru = @{
                        Title       = 'Настроить параметры Microsoft Edge'
                        Desc        = 'Откройте настройки Edge для отключения телеметрии, персонализации, торговых функций и настройки поведения при запуске.'
                        Instruction = 'Отключите все переключатели телеметрии и персонализации. В разделе «Конфиденциальность, поиск и службы» → отключите «Помочь улучшить продукты Microsoft». В разделе «Страница новой вкладки» → отключите ленту новостей.'
                    }
                }
                @{
                    Id      = 'configure-sound'
                    Title   = 'Configure sound devices & default playback'
                    Desc    = 'Open Windows Sound control panel to set default playback and recording devices.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open Sound control panel (mmsys.cpl), set your default playback device, configure levels. Disable unused playback/recording devices.'
                    Ru = @{
                        Title       = 'Настроить звуковые устройства и воспроизведение по умолчанию'
                        Desc        = 'Откройте Панель управления звуком для настройки устройств воспроизведения и записи по умолчанию.'
                        Instruction = 'Откройте Панель управления звуком (mmsys.cpl), выберите устройство воспроизведения по умолчанию, настройте уровни. Отключите неиспользуемые устройства воспроизведения и записи.'
                    }
                }
                @{
                    Id      = 'browser-setup-guide'
                    Title   = 'Browser setup guide (YouTube)'
                    Desc    = 'Video guide covering browser configuration, privacy settings, and useful extensions.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.youtube.com/watch?v=ITdecD6R0Yw'
                    Ru = @{
                        Title = 'Гайд по настройке браузера (YouTube)'
                        Desc  = 'Видеогайд по настройке браузера, параметрам конфиденциальности и полезным расширениям.'
                    }
                }
            )
        }

        # ── 1. Edge — Tame It ─────────────────────────────────────────────────
        @{
            Id    = 'edge-tame'
            Title = 'Edge — Tame It'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Edge — укрощение' }
            Tweaks = @(
                @{
                    Id      = 'edge-disable-startup-boost'
                    Title   = 'Disable startup boost & background running'
                    Desc    = 'Prevents Edge from pre-launching at login and running in the background when all windows are closed.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'StartupBoostEnabled'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить предварительный запуск и фоновую работу Edge'
                        Desc  = 'Запрещает Edge предварительно запускаться при входе в систему и работать в фоне при закрытии всех окон.'
                    }
                }
                @{
                    Id      = 'edge-disable-background'
                    Title   = 'Disable background mode when Edge is closed'
                    Desc    = 'Stops Edge from staying active in background for notifications and extensions after all windows are closed.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'BackgroundModeEnabled'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить фоновый режим Edge при закрытии браузера'
                        Desc  = 'Запрещает Edge оставаться активным в фоне для уведомлений и расширений после закрытия всех окон.'
                    }
                }
                @{
                    Id      = 'edge-disable-newstab'
                    Title   = 'Disable news feed on new tab page'
                    Desc    = 'Removes the Microsoft News / Bing content feed from Edge new tab page.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'NewTabPageContentEnabled'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить ленту новостей на новой вкладке'
                        Desc  = 'Убирает ленту новостей Microsoft News / Bing со страницы новой вкладки Edge.'
                    }
                }
                @{
                    Id      = 'edge-disable-telemetry'
                    Title   = 'Disable telemetry & diagnostic data collection'
                    Desc    = 'Sets three policy keys to stop Edge sending metrics, site info, and diagnostic data to Microsoft.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Apply = {
                        $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
                        if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
                        Set-ItemProperty $p -Name 'MetricsReportingEnabled'       -Value 0 -Type DWord
                        Set-ItemProperty $p -Name 'SendSiteInfoToImproveServices' -Value 0 -Type DWord
                        Set-ItemProperty $p -Name 'DiagnosticData'                -Value 0 -Type DWord
                    }
                    Revert = {
                        $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
                        if (Test-Path $p) {
                            Remove-ItemProperty $p -Name 'MetricsReportingEnabled'       -EA SilentlyContinue
                            Remove-ItemProperty $p -Name 'SendSiteInfoToImproveServices' -EA SilentlyContinue
                            Remove-ItemProperty $p -Name 'DiagnosticData'                -EA SilentlyContinue
                        }
                    }
                    Detect = {
                        $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
                        (Test-Path $p) -and ((Get-ItemProperty $p -EA SilentlyContinue).MetricsReportingEnabled -eq 0)
                    }
                    Ru = @{
                        Title = 'Отключить сбор телеметрии и диагностических данных'
                        Desc  = 'Устанавливает три ключа политики, запрещающие Edge отправлять метрики, информацию о сайтах и диагностические данные в Microsoft.'
                    }
                }
                @{
                    Id      = 'edge-disable-shopping'
                    Title   = 'Disable Shopping Assistant (price comparison popups)'
                    Desc    = 'Turns off the Edge Shopping Assistant that shows price comparisons and coupon suggestions on retail sites.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'EdgeShoppingAssistantEnabled'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить Shopping Assistant (всплывающие сравнения цен)'
                        Desc  = 'Отключает помощник Edge Shopping Assistant, показывающий сравнение цен и купоны на торговых сайтах.'
                    }
                }
                @{
                    Id      = 'edge-disable-rewards'
                    Title   = 'Disable Microsoft Rewards in Edge'
                    Desc    = 'Removes Microsoft Rewards points integration and prompts from Edge UI.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'ShowMicrosoftRewards'
                        Value = 0
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить Microsoft Rewards в Edge'
                        Desc  = 'Убирает интеграцию баллов Microsoft Rewards и связанные уведомления из интерфейса Edge.'
                    }
                }
                @{
                    Id      = 'edge-disable-firstrun'
                    Title   = 'Disable first-run experience & import prompts'
                    Desc    = 'Skips the Edge welcome/import wizard that appears on fresh installs or updates.'
                    Kind    = 'registry'
                    Source  = 'official'
                    Control = 'toggle'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Op = @{
                        Hive  = 'HKLM'
                        Path  = 'SOFTWARE\Policies\Microsoft\Edge'
                        Name  = 'HideFirstRunExperience'
                        Value = 1
                        Type  = 'DWord'
                    }
                    Ru = @{
                        Title = 'Отключить экран приветствия и предложения импорта'
                        Desc  = 'Пропускает мастер приветствия/импорта Edge, появляющийся при чистой установке или обновлении.'
                    }
                }
            )
        }

        # ── 2. Install Browser ────────────────────────────────────────────────
        @{
            Id    = 'install-browser'
            Title = 'Install Browser'
            Order = 0
            Ru    = @{ Title = 'Установить браузер' }
            Tweaks = @(
                @{
                    Id      = 'install-chrome'
                    MaxMovGuide = $true
                    Title   = 'Google Chrome'
                    Desc    = 'The most widely used browser. Best compatibility, V8 engine, sync across devices. Installs via winget.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.google.com/chrome/'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Google.Chrome' -DisplayName 'Google Chrome' | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Google.Chrome' -DisplayName 'Google Chrome' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Google.Chrome' -FallbackNamePattern '^Google Chrome$'
                    }
                    Ru = @{
                        Title = 'Google Chrome'
                        Desc  = 'Самый распространённый браузер. Максимальная совместимость, движок V8, синхронизация между устройствами. Устанавливается через winget.'
                    }
                }
                @{
                    Id      = 'install-brave'
                    MaxMovGuide = $true
                    Title   = 'Brave Browser'
                    Desc    = 'Chromium-based, built-in ad/tracker blocking, no Google telemetry. Good for privacy. Installs via winget.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://brave.com/download/'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Brave.Brave' -DisplayName 'Brave Browser' | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Brave.Brave' -DisplayName 'Brave Browser' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Brave.Brave' -FallbackNamePattern '^Brave( Browser)?$'
                    }
                    Ru = @{
                        Title = 'Brave Browser'
                        Desc  = 'На базе Chromium, встроенная блокировка рекламы и трекеров, без телеметрии Google. Хорош для конфиденциальности. Устанавливается через winget.'
                    }
                }
                @{
                    Id      = 'install-firefox'
                    Title   = 'Mozilla Firefox'
                    Desc    = 'Independent Gecko engine (not Chromium). Strong privacy defaults, excellent extension ecosystem. Installs via winget.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.mozilla.org/firefox/new/'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Mozilla.Firefox' -DisplayName 'Mozilla Firefox' | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Mozilla.Firefox' -DisplayName 'Mozilla Firefox' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Mozilla.Firefox' -FallbackNamePattern '^Mozilla Firefox'
                    }
                    Ru = @{
                        Title = 'Mozilla Firefox'
                        Desc  = 'Независимый движок Gecko (не Chromium). Сильные настройки конфиденциальности по умолчанию, отличная экосистема расширений. Устанавливается через winget.'
                    }
                }
                @{
                    Id      = 'install-vivaldi'
                    Title   = 'Vivaldi'
                    Desc    = 'Chromium-based, extreme UI customisation, built-in tab groups, notes, mail. Power users. Installs via winget.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://vivaldi.com/download/'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Vivaldi.Vivaldi' -DisplayName 'Vivaldi' | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Vivaldi.Vivaldi' -DisplayName 'Vivaldi' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Vivaldi.Vivaldi' -FallbackNamePattern '^Vivaldi$'
                    }
                    Ru = @{
                        Title = 'Vivaldi'
                        Desc  = 'На базе Chromium, широчайшая кастомизация интерфейса, встроенные группы вкладок, заметки, почта. Для опытных пользователей. Устанавливается через winget.'
                    }
                }
                @{
                    Id      = 'install-opera'
                    Title   = 'Opera'
                    Desc    = 'Chromium-based with built-in VPN, ad blocker, and sidebar workspace tools. Installs via winget.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.opera.com/download'
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Opera.Opera' -DisplayName 'Opera' | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Opera.Opera' -DisplayName 'Opera' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Opera.Opera' -FallbackNamePattern '^Opera( Browser)?$'
                    }
                    Ru = @{
                        Title = 'Opera'
                        Desc  = 'На базе Chromium со встроенным VPN, блокировщиком рекламы и боковой панелью рабочих пространств. Устанавливается через winget.'
                    }
                }
                @{
                    Id      = 'webview2-standalone'
                    MaxMovGuide = $true
                    Title   = 'WebView2 Runtime (standalone — required if removing Edge)'
                    Desc    = 'Microsoft WebView2 Runtime powers PWAs, Teams, new Outlook, and some Store apps. Install before removing Edge to avoid breaking them. Windows 11 usually ships it already — the card then reports it as present and installs nothing.'
                    Kind    = 'script'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://developer.microsoft.com/microsoft-edge/webview2/'
                    # Windows 11 ships WebView2 machine-wide and keeps it updated through EdgeUpdate.
                    # That install writes a SystemComponent=1 uninstall entry, which winget skips — so
                    # `winget list` reports "not installed" for a runtime that is very much installed.
                    # The EdgeUpdate client GUID below is Microsoft's documented marker for it and is
                    # what both Detect and Apply trust before winget.
                    Apply = {
                        Invoke-WingetEnsurePackage -PackageId 'Microsoft.EdgeWebView2Runtime' -DisplayName 'WebView2 Runtime' `
                            -FallbackNamePattern 'WebView2' `
                            -FallbackKeys @(
                                'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                                'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                                'HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                            ) | Out-Null
                    }
                    Revert = {
                        Invoke-WingetRemovePackage -PackageId 'Microsoft.EdgeWebView2Runtime' -DisplayName 'WebView2 Runtime' | Out-Null
                    }
                    Detect = {
                        Test-WingetPackagePresent -PackageId 'Microsoft.EdgeWebView2Runtime' `
                            -FallbackNamePattern 'WebView2' `
                            -FallbackKeys @(
                                'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                                'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                                'HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                            )
                    }
                    Ru = @{
                        Title = 'WebView2 Runtime (автономный — необходим при удалении Edge)'
                        Desc  = 'Microsoft WebView2 Runtime обеспечивает работу PWA-приложений, Teams, нового Outlook и ряда приложений Store. Установите до удаления Edge, чтобы они не сломались. В Windows 11 он обычно уже есть — тогда карточка сообщит об этом и ничего устанавливать не станет.'
                    }
                }
                @{
                    Id      = 'set-default-browser'
                    MaxMovGuide = $true
                    Title   = 'Set default browser'
                    Desc    = 'Open Default Apps settings to choose which browser handles http:// and https:// links.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:defaultapps'
                    Instruction = 'Scroll to the browser section or search for your browser. Click it and choose "Set as default". Make sure http and https both point to your chosen browser.'
                    Ru = @{
                        Title       = 'Задать браузер по умолчанию'
                        Desc        = 'Откройте Параметры приложений по умолчанию, чтобы выбрать браузер для ссылок http:// и https://.'
                        Instruction = 'Прокрутите до раздела браузера или найдите нужный браузер. Нажмите на него и выберите «Использовать по умолчанию». Убедитесь, что http и https оба указывают на выбранный браузер.'
                    }
                }
            )
        }

        # ── 3. Remove Edge (Optional) ─────────────────────────────────────────
        @{
            Id    = 'remove-edge'
            Title = 'Remove Edge (Optional)'
            Order = 3
            MaxMovGuide = $true
            SelectionMode = 'ordered'
            Ru    = @{ Title = 'Удалить Edge (опционально)' }
            Tweaks = @(
                @{
                    Id      = 'remove-edge-webview2-warning'
                    Title   = 'Read before proceeding — WebView2 dependency'
                    Desc    = 'Removing Edge without a standalone WebView2 Runtime will break: Teams, new Outlook, PWA apps, Windows Widgets. Install it first via Install Browser → WebView2 Runtime.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Make sure "WebView2 Runtime (standalone)" is already installed (Install Browser subsection → Apply). Only then continue with the steps below.'
                    Ru = @{
                        Title       = 'Прочитайте перед продолжением — зависимость от WebView2'
                        Desc        = 'Удаление Edge без автономного WebView2 Runtime нарушит работу: Teams, нового Outlook, PWA-приложений, Виджетов Windows. Сначала установите его через «Установить браузер» → WebView2 Runtime.'
                        Instruction = 'Убедитесь, что «WebView2 Runtime (автономный)» уже установлен (подраздел «Установить браузер» → Применить). Только после этого переходите к шагам ниже.'
                    }
                }
                @{
                    Id      = 'remove-edge-step1-check'
                    Title   = 'Step 1 — Check if Uninstall is already available'
                    Desc    = 'Open Apps & Features and look for Microsoft Edge. If the Uninstall button is active (not greyed out), skip to Step 6 and uninstall directly.'
                    Kind    = 'deeplink'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Uri         = 'ms-settings:appsfeatures'
                    Instruction = 'Search "Microsoft Edge". If Uninstall is clickable — use it, done. If greyed out — follow Steps 2–6.'
                    Ru = @{
                        Title       = 'Шаг 1 — Проверить, доступно ли удаление'
                        Desc        = 'Откройте «Приложения и возможности» и найдите Microsoft Edge. Если кнопка «Удалить» активна (не серая) — перейдите к шагу 6 и удалите напрямую.'
                        Instruction = 'Найдите «Microsoft Edge». Если кнопка «Удалить» доступна — нажмите её, готово. Если недоступна (серая) — выполните шаги 2–6.'
                    }
                }
                @{
                    Id      = 'remove-edge-step2-takeown'
                    Title   = 'Step 2 — Grant write access to region policy file'
                    Desc    = 'Runs takeown and icacls on IntegratedServicesRegionPolicySet.json to allow editing. Required because the file is owned by TrustedInstaller.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    # takeown/icacls used to run with their output thrown away, so a refusal looked
                    # exactly like a success. Stream both and close on an explicit verdict.
                    Apply = {
                        $f = "$env:SystemRoot\System32\IntegratedServicesRegionPolicySet.json"
                        $own = Invoke-NativeProcess -FilePath 'takeown.exe' -Encoding oem -TimeoutSeconds 120 -Arguments @('/f', $f)
                        $acl = Invoke-NativeProcess -FilePath 'icacls.exe' -Encoding oem -TimeoutSeconds 120 -Arguments @($f, '/grant', "$($env:USERNAME):(F)")
                        if ($own.ExitCode -eq 0 -and $acl.ExitCode -eq 0) {
                            Write-OperationOutput (Get-UiText 'ElevationDone' 'File permissions granted.')
                        } else {
                            $code = if ($own.ExitCode -ne 0) { $own.ExitCode } else { $acl.ExitCode }
                            Write-OperationOutput ((Get-UiText 'ElevationFailedFmt' 'Could not grant permissions (code {0}). The step did not complete.') -f $code)
                        }
                    }
                    Detect = {
                        $f = "$env:SystemRoot\System32\IntegratedServicesRegionPolicySet.json"
                        $acl = Get-Acl $f -EA SilentlyContinue
                        $acl -and ($acl.Owner -notlike '*TrustedInstaller*')
                    }
                    Ru = @{
                        Title = 'Шаг 2 — Предоставить права на запись в файл региональной политики'
                        Desc  = 'Выполняет takeown и icacls для IntegratedServicesRegionPolicySet.json, чтобы разрешить редактирование. Необходимо, так как файл принадлежит TrustedInstaller.'
                    }
                }
                @{
                    Id      = 'remove-edge-step3-open-json'
                    Title   = 'Step 3 — Open policy file in Notepad'
                    Desc    = 'Opens IntegratedServicesRegionPolicySet.json in Notepad for manual editing. Run Step 2 first.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $f = "$env:SystemRoot\System32\IntegratedServicesRegionPolicySet.json"
                        Start-Process notepad.exe -ArgumentList $f
                    }
                    Ru = @{
                        Title = 'Шаг 3 — Открыть файл политики в Блокноте'
                        Desc  = 'Открывает IntegratedServicesRegionPolicySet.json в Блокноте для ручного редактирования. Сначала выполните шаг 2.'
                    }
                }
                @{
                    Id      = 'remove-edge-step4-edit-json'
                    Title   = 'Step 4 — Find the Edge entry and enable uninstall'
                    Desc    = 'In the JSON file: find the "MicrosoftEdge" entry. In its "regions" array, add your 2-letter country code (e.g. "RU", "US", "DE"). Save the file with Ctrl+S.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'In Notepad, press Ctrl+F and search for "MicrosoftEdge". Find the nearest "regions" array (usually looks like "regions":[""] or similar). Add your 2-letter country code inside the array, e.g.: "regions":["RU"]. Save the file with Ctrl+S, then close Notepad.'
                    Ru = @{
                        Title       = 'Шаг 4 — Найти запись Edge и активировать удаление'
                        Desc        = 'В JSON-файле найдите запись «MicrosoftEdge». В массиве «regions» добавьте двухбуквенный код вашей страны (например, «RU», «US», «DE»). Сохраните файл через Ctrl+S.'
                        Instruction = 'В Блокноте нажмите Ctrl+F и найдите «MicrosoftEdge». Найдите ближайший массив «regions» (обычно выглядит как "regions":[""] или похоже). Добавьте двухбуквенный код страны внутрь массива, например: "regions":["RU"]. Сохраните файл через Ctrl+S, затем закройте Блокнот.'
                    }
                }
                @{
                    Id      = 'remove-edge-step5-repair'
                    Title   = 'Step 5 — Click Repair on Edge (reloads policy)'
                    Desc    = 'In Apps & Features, click the three-dot menu on Microsoft Edge → Modify. This forces Windows to reload the region policy and should unlock the Uninstall button.'
                    Kind    = 'deeplink'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'ms-settings:appsfeatures'
                    Instruction = 'Find Microsoft Edge → click ⋮ → Modify. Wait for the repair to complete. Close this window completely (including any Edge processes).'
                    Ru = @{
                        Title       = 'Шаг 5 — Нажать «Восстановить» для Edge (перезагрузка политики)'
                        Desc        = 'В «Приложениях и возможностях» нажмите кнопку с тремя точками у Microsoft Edge → Изменить. Это вынудит Windows перезагрузить региональную политику и должно разблокировать кнопку «Удалить».'
                        Instruction = 'Найдите Microsoft Edge → нажмите ⋮ → Изменить. Дождитесь завершения восстановления. Полностью закройте это окно (включая все процессы Edge).'
                    }
                }
                @{
                    Id      = 'remove-edge-step6-uninstall'
                    Title   = 'Step 6 — Uninstall Edge'
                    Desc    = 'Reopen Apps & Features — the Uninstall button for Edge should now be active. Click it to remove Edge.'
                    Kind    = 'deeplink'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Uri         = 'ms-settings:appsfeatures'
                    Instruction = 'Search for "Microsoft Edge". Click ⋮ → Uninstall. If still greyed out, close and reopen Settings, or restart the PC and try again.'
                    Ru = @{
                        Title       = 'Шаг 6 — Удалить Edge'
                        Desc        = 'Снова откройте «Приложения и возможности» — кнопка «Удалить» для Edge должна стать активной. Нажмите её для удаления Edge.'
                        Instruction = 'Найдите «Microsoft Edge». Нажмите ⋮ → Удалить. Если кнопка по-прежнему недоступна, закройте и снова откройте Параметры или перезагрузите ПК и повторите.'
                    }
                }
            )
        }

    )
}
