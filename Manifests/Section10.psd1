@{
    Id    = 'recommended-programs'
    Title = 'Recommended Programs'
    Order = 10
    Ru    = @{ Title = 'Рекомендуемые программы' }

    Subsections = @(

        # ── 0. Community Resources ────────────────────────────────────────────
        @{
            Id    = 'community-resources'
            Title = 'Community Resources'
            Order = 0
            Ru    = @{ Title = 'Ресурсы сообщества' }
            Tweaks = @(
                @{
                    Id      = 'telegram-viewer-software'
                    Title   = 'Viewer-recommended software (Telegram chat topic)'
                    Desc    = 'Telegram topic where viewers share their own recommended software picks.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://t.me/a11p1ay'
                    Ru = @{
                        Title = 'Программы от зрителей (тема в Telegram)'
                        Desc  = 'Тема в Telegram, где зрители делятся своими рекомендациями по программному обеспечению.'
                    }
                }
            )
        }

        # ── 1. Browsers ───────────────────────────────────────────────────────
        @{
            Id    = 'browsers'
            Title = 'Browsers'
            Order = 1
            Ru    = @{ Title = 'Браузеры' }
            Tweaks = @(
                @{
                    Id      = 'download-chrome'
                    Title   = 'Google Chrome'
                    Desc    = 'The most widely used browser. Best site compatibility, V8 engine, sync across devices.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.google.com/chrome/'
                    Ru = @{
                        Title = 'Google Chrome'
                        Desc  = 'Самый распространённый браузер. Максимальная совместимость, движок V8, синхронизация между устройствами.'
                    }
                }
                @{
                    Id      = 'download-brave'
                    Title   = 'Brave Browser'
                    Desc    = 'Chromium-based with built-in ad and tracker blocking. No Google telemetry. Good privacy defaults.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://brave.com/'
                    Ru = @{
                        Title = 'Brave Browser'
                        Desc  = 'На базе Chromium со встроенной блокировкой рекламы и трекеров. Без телеметрии Google. Сильные настройки конфиденциальности.'
                    }
                }
                @{
                    Id      = 'download-firefox'
                    Title   = 'Mozilla Firefox'
                    Desc    = 'Independent Gecko engine, not Chromium. Strong privacy defaults and excellent extension ecosystem.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.mozilla.org/firefox/'
                    Ru = @{
                        Title = 'Mozilla Firefox'
                        Desc  = 'Независимый движок Gecko, не Chromium. Сильные настройки конфиденциальности и отличная экосистема расширений.'
                    }
                }
                @{
                    Id      = 'download-vivaldi'
                    Title   = 'Vivaldi'
                    Desc    = 'Chromium-based. Extreme UI customisation, built-in tab groups, notes, and mail client. For power users.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://vivaldi.com/'
                    Ru = @{
                        Title = 'Vivaldi'
                        Desc  = 'На базе Chromium. Широчайшая кастомизация интерфейса, встроенные группы вкладок, заметки и почтовый клиент. Для опытных пользователей.'
                    }
                }
                @{
                    Id      = 'download-zen-browser'
                    Title   = 'Zen Browser'
                    Desc    = 'Firefox-based. Privacy-focused with a clean UI and tab workspaces. Actively developed.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://zen-browser.app/'
                    Ru = @{
                        Title = 'Zen Browser'
                        Desc  = 'На базе Firefox. Упор на конфиденциальность, чистый интерфейс и рабочие пространства вкладок. Активно разрабатывается.'
                    }
                }
            )
        }

        # ── 2. System Utilities ───────────────────────────────────────────────
        @{
            Id    = 'system-utilities'
            Title = 'System Utilities'
            Order = 2
            Ru    = @{ Title = 'Системные утилиты' }
            Tweaks = @(
                @{
                    Id      = 'download-powertoys'
                    MaxMovGuide = $true
                    Title   = 'Download Microsoft PowerToys'
                    Desc    = 'PowerToys adds useful Windows utilities: PowerToys Run, FancyZones, Keyboard Manager, Color Picker, Image Resizer, Auto Dark Mode, and more.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/microsoft/PowerToys/releases'
                    Ru = @{
                        Title = 'Скачать Microsoft PowerToys'
                        Desc  = 'PowerToys добавляет полезные утилиты Windows: PowerToys Run, FancyZones, Keyboard Manager, Color Picker, Image Resizer, Auto Dark Mode и другие.'
                    }
                }
                @{
                    Id      = 'download-everything'
                    MaxMovGuide = $true
                    Title   = 'Download Everything (fast file search)'
                    Desc    = 'Everything indexes all file names on your drives instantly. Sub-second search results across all drives.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.voidtools.com/'
                    Ru = @{
                        Title = 'Скачать Everything (быстрый поиск файлов)'
                        Desc  = 'Everything мгновенно индексирует имена файлов на всех дисках. Поиск по всем дискам быстрее секунды.'
                    }
                }
                @{
                    Id      = 'download-vivetool'
                    Title   = 'Download ViVeTool (unlock hidden Windows features)'
                    Desc    = 'ViVeTool activates hidden A/B feature flags in Windows. Useful for enabling experimental features before they roll out to your account. Feature IDs are build-specific and change over time.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/thebookisclosed/ViVe/releases'
                    Ru = @{
                        Title = 'Скачать ViVeTool (разблокировка скрытых функций Windows)'
                        Desc  = 'ViVeTool активирует скрытые A/B-флаги функций Windows. Полезен для включения экспериментальных возможностей до их официального выхода. ID функций зависят от сборки и меняются со временем.'
                    }
                }
                @{
                    Id      = 'download-pc-manager'
                    Title   = 'Microsoft PC Manager'
                    Desc    = 'Official Microsoft utility for RAM cleanup, temp file removal, and system health overview. Opens directly in the Microsoft Store.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://apps.microsoft.com/detail/9pm860492szd'
                    Ru = @{
                        Title = 'Microsoft PC Manager'
                        Desc  = 'Официальная утилита Microsoft для очистки RAM, удаления временных файлов и общей диагностики системы. Открывается прямо в Microsoft Store.'
                    }
                }
                @{
                    Id      = 'pc-manager-msix-bypass'
                    Title   = 'Microsoft PC Manager — direct .msix download (if Store unavailable)'
                    Desc    = 'Use store.rg-adguard.net to get the direct .msix package link. Paste the Store URL into the search box to obtain the download link.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://store.rg-adguard.net/'
                    Ru = @{
                        Title = 'Microsoft PC Manager — прямая загрузка .msix (если Store недоступен)'
                        Desc  = 'Используйте store.rg-adguard.net для получения прямой ссылки на пакет .msix. Вставьте URL из Store в поле поиска, чтобы получить ссылку для скачивания.'
                    }
                }
                @{
                    Id      = 'download-ventoy'
                    Title   = 'Download Ventoy (bootable USB creator)'
                    Desc    = 'Ventoy creates a multiboot USB drive — just copy ISO files onto it, no re-flashing needed.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/ventoy/Ventoy'
                    Ru = @{
                        Title = 'Скачать Ventoy (создание загрузочного USB)'
                        Desc  = 'Ventoy создаёт мультизагрузочный USB-накопитель — просто скопируйте на него ISO-файлы, перезапись не нужна.'
                    }
                }
                @{
                    Id      = 'download-pathscan'
                    Title   = 'Download PathScan (path length viewer)'
                    Desc    = 'PathScan displays folder and file path lengths, helping identify paths that exceed the Windows 260-character limit.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.softpedia.com/get/System/File-Management/Path-Scan.shtml#download'
                    Ru = @{
                        Title = 'Скачать PathScan (просмотр длины путей)'
                        Desc  = 'PathScan отображает длины путей папок и файлов — помогает найти пути, превышающие ограничение Windows в 260 символов.'
                    }
                }
            )
        }

        # ── 3. File Management ────────────────────────────────────────────────
        @{
            Id    = 'file-management'
            Title = 'File Management'
            Order = 3
            Ru    = @{ Title = 'Управление файлами' }
            Tweaks = @(
                @{
                    Id      = 'download-explorer-tab-utility'
                    MaxMovGuide = $true
                    Title   = 'Download ExplorerTabUtility (improved Explorer tabs)'
                    Desc    = 'ExplorerTabUtility forces all Explorer windows to open as tabs instead of new windows. Adds browser-like tab shortcuts (Ctrl+D, Ctrl+Shift+T). On Windows 25H2+, the built-in option "open folders in new tab" already covers most cases, but ETU still adds hotkey support.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/w4po/ExplorerTabUtility/releases'
                    Ru = @{
                        Title = 'Скачать ExplorerTabUtility (улучшенные вкладки Проводника)'
                        Desc  = 'ExplorerTabUtility принудительно открывает все окна Проводника как вкладки. Добавляет горячие клавиши в стиле браузера (Ctrl+D, Ctrl+Shift+T). В Windows 25H2+ встроенная опция «открывать папки в новой вкладке» уже покрывает большинство случаев, но ETU добавляет поддержку горячих клавиш.'
                    }
                }
                @{
                    Id      = 'download-symbolic11'
                    Title   = 'Download Symbolic11 (symlink manager)'
                    Desc    = 'GUI tool for conveniently creating and managing symbolic links on Windows.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Benisgo/Symbolic11'
                    Ru = @{
                        Title = 'Скачать Symbolic11 (менеджер символических ссылок)'
                        Desc  = 'GUI-инструмент для удобного создания и управления символическими ссылками в Windows.'
                    }
                }
                @{
                    Id      = 'download-nilesoft-shell'
                    Title   = 'Download Nilesoft Shell (custom context menu)'
                    Desc    = 'Nilesoft Shell lets you build a fully custom right-click context menu, replacing the default Windows 11 context menu.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://nilesoft.org/download'
                    Ru = @{
                        Title = 'Скачать Nilesoft Shell (настраиваемое контекстное меню)'
                        Desc  = 'Nilesoft Shell позволяет создать полностью кастомное контекстное меню правой кнопки мыши, заменяя стандартное меню Windows 11.'
                    }
                }
            )
        }

        # ── 4. Uninstallers ───────────────────────────────────────────────────
        @{
            Id    = 'uninstallers'
            Title = 'Uninstallers'
            Order = 4
            Ru    = @{ Title = 'Деинсталляторы' }
            Tweaks = @(
                @{
                    Id      = 'download-bulk-crap-uninstaller'
                    Title   = 'Download Bulk Crap Uninstaller (BCUninstaller)'
                    Desc    = 'Open-source batch uninstaller that removes apps including leftovers, supports silent uninstall, and lists Store/Chocolatey/Scoop packages.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Klocman/Bulk-Crap-Uninstaller'
                    Ru = @{
                        Title = 'Скачать Bulk Crap Uninstaller (BCUninstaller)'
                        Desc  = 'Пакетный деинсталлятор с открытым кодом: удаляет программы вместе с остатками, поддерживает тихое удаление, отображает пакеты Store/Chocolatey/Scoop.'
                    }
                }
                @{
                    Id      = 'download-revo-uninstaller'
                    MaxMovGuide = $true
                    Title   = 'Download Revo Uninstaller Free'
                    Desc    = 'Revo Uninstaller removes programs and then scans for leftover registry entries and files.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.revouninstaller.com/products/revo-uninstaller-free/'
                    Ru = @{
                        Title = 'Скачать Revo Uninstaller Free'
                        Desc  = 'Revo Uninstaller удаляет программы и затем сканирует остатки в реестре и файловой системе.'
                    }
                }
            )
        }

        # ── 5. Security & Privacy ─────────────────────────────────────────────
        @{
            Id    = 'security-privacy'
            Title = 'Security & Privacy'
            Order = 5
            Ru    = @{ Title = 'Безопасность и конфиденциальность' }
            Tweaks = @(
                @{
                    Id      = 'download-microsoft-safety-scanner'
                    Title   = 'Download Microsoft Safety Scanner (on-demand AV scan)'
                    Desc    = 'Free on-demand malware scanner from Microsoft. Does not replace a real-time antivirus — use for one-time scanning.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://learn.microsoft.com/en-us/defender-endpoint/safety-scanner-download'
                    Ru = @{
                        Title = 'Скачать Microsoft Safety Scanner (антивирусная проверка по запросу)'
                        Desc  = 'Бесплатный сканер вредоносных программ от Microsoft по запросу. Не заменяет антивирус реального времени — использовать для разовой проверки.'
                    }
                }
                @{
                    Id      = 'download-kaspersky-vrt'
                    Title   = 'Download Kaspersky Virus Removal Tool'
                    Desc    = 'Free standalone virus removal tool from Kaspersky. Useful for scanning a system you suspect is infected.'
                    Kind    = 'link'
                    Source  = 'official'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.kaspersky.ru/downloads/free-virus-removal-tool'
                    Ru = @{
                        Title = 'Скачать Kaspersky Virus Removal Tool'
                        Desc  = 'Бесплатный автономный инструмент удаления вирусов от Kaspersky. Полезен для проверки системы при подозрении на заражение.'
                    }
                }
                @{
                    Id      = 'virustotal'
                    Title   = 'VirusTotal — online file & URL scanner'
                    Desc    = 'Scan any file or URL against 70+ antivirus engines simultaneously.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.virustotal.com/gui/home/upload'
                    Ru = @{
                        Title = 'VirusTotal — онлайн-сканер файлов и URL'
                        Desc  = 'Проверка любого файла или URL сразу более чем 70 антивирусными движками.'
                    }
                }
                @{
                    Id      = 'download-keepassxc'
                    Title   = 'Download KeePassXC (password manager)'
                    Desc    = 'Open-source offline password manager. Keeps all credentials in an encrypted local database — no cloud sync required.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/keepassxreboot/keepassxc/releases/tag/2.7.10'
                    Ru = @{
                        Title = 'Скачать KeePassXC (менеджер паролей)'
                        Desc  = 'Офлайн-менеджер паролей с открытым кодом. Хранит все учётные данные в зашифрованной локальной базе — облачная синхронизация не требуется.'
                    }
                }
                @{
                    Id      = 'download-keepass2android'
                    Title   = 'Download KeePass2Android (Android companion app)'
                    Desc    = 'Android app that opens KeePass .kdbx databases. Sync the database file via cloud or LAN to use passwords on mobile.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/PhilippC/keepass2android/releases'
                    Ru = @{
                        Title = 'Скачать KeePass2Android (приложение для Android)'
                        Desc  = 'Приложение Android для открытия баз данных KeePass .kdbx. Синхронизируйте файл базы через облако или локальную сеть для использования паролей на мобильном.'
                    }
                }
                @{
                    Id      = 'download-veracrypt'
                    Title   = 'Download VeraCrypt (disk encryption)'
                    Desc    = 'Open-source full-disk and container encryption. Successor to TrueCrypt, supports AES, Twofish, and Serpent.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/veracrypt/VeraCrypt/releases'
                    Ru = @{
                        Title = 'Скачать VeraCrypt (шифрование дисков)'
                        Desc  = 'Шифрование дисков и контейнеров с открытым кодом. Преемник TrueCrypt, поддерживает AES, Twofish и Serpent.'
                    }
                }
            )
        }

        # ── 6. Media & Communication ──────────────────────────────────────────
        @{
            Id    = 'media-communication'
            Title = 'Media & Communication'
            Order = 6
            Ru    = @{ Title = 'Медиа и коммуникации' }
            Tweaks = @(
                @{
                    Id      = 'download-telegram'
                    Title   = 'Download Telegram Desktop Portable'
                    Desc    = 'Portable version of Telegram Desktop — runs without installation, easy to move between PCs.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://desktop.telegram.org/'
                    Ru = @{
                        Title = 'Скачать Telegram Desktop Portable'
                        Desc  = 'Портативная версия Telegram Desktop — запускается без установки, легко переносится между ПК.'
                    }
                }
                @{
                    Id      = 'download-obs'
                    Title   = 'Download OBS Studio (screen recording & streaming)'
                    Desc    = 'Open-source screen recorder and live streaming software. Supports replay buffers, scene switching, and many plugins.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/obsproject/obs-studio/releases'
                    Ru = @{
                        Title = 'Скачать OBS Studio (запись экрана и стриминг)'
                        Desc  = 'Программа для записи экрана и стриминга с открытым кодом. Поддерживает буфер повтора, переключение сцен и множество плагинов.'
                    }
                }
                @{
                    Id      = 'download-3d-youtube-downloader'
                    Title   = 'Download 3D YouTube Downloader'
                    Desc    = 'Convenient GUI downloader for YouTube, Vimeo, and many other video sites. Supports playlists and various quality options.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://yd.3dyd.com/download/'
                    Ru = @{
                        Title = 'Скачать 3D YouTube Downloader'
                        Desc  = 'Удобный загрузчик с графическим интерфейсом для YouTube, Vimeo и многих других видеосайтов. Поддерживает плейлисты и различные варианты качества.'
                    }
                }
                @{
                    Id      = 'download-mpc-hc'
                    MaxMovGuide = $true
                    Title   = 'Download MPC-HC (media player)'
                    Desc    = 'Lightweight open-source media player with MadVR, LAV Filters, and subtitle support. Successor to the original MPC-HC.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/clsid2/mpc-hc/releases'
                    Ru = @{
                        Title = 'Скачать MPC-HC (медиаплеер)'
                        Desc  = 'Лёгкий медиаплеер с открытым кодом: поддержка MadVR, LAV Filters и субтитров. Преемник оригинального MPC-HC.'
                    }
                }
                @{
                    Id      = 'download-lossless-cut'
                    Title   = 'Download LosslessCut (fast video trimmer)'
                    Desc    = 'FFMPEG-based video trimmer that cuts video without re-encoding. Instant lossless cuts for any format.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/mifi/lossless-cut/releases'
                    Ru = @{
                        Title = 'Скачать LosslessCut (быстрое обрезание видео)'
                        Desc  = 'Инструмент на базе FFMPEG для обрезки видео без перекодирования. Мгновенная безпотерная резка для любых форматов.'
                    }
                }
                @{
                    Id      = 'download-davinci-resolve'
                    Title   = 'Download DaVinci Resolve (free professional video editor)'
                    Desc    = 'Industry-standard professional video editing suite by Blackmagic Design. Free version has no watermarks or time limits.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.blackmagicdesign.com/products/davinciresolve'
                    Ru = @{
                        Title = 'Скачать DaVinci Resolve (бесплатный профессиональный видеоредактор)'
                        Desc  = 'Профессиональный пакет видеомонтажа отраслевого уровня от Blackmagic Design. Бесплатная версия без водяных знаков и ограничений по времени.'
                    }
                }
                @{
                    Id      = 'download-obsidian'
                    Title   = 'Download Obsidian (note-taking app)'
                    Desc    = 'Obsidian is a powerful Markdown-based note app with a local-first graph of linked notes. No account required for local use.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/obsidianmd/obsidian-releases/releases'
                    Ru = @{
                        Title = 'Скачать Obsidian (приложение для заметок)'
                        Desc  = 'Obsidian — мощное приложение для заметок на Markdown с локальным графом связанных записей. Для локального использования аккаунт не требуется.'
                    }
                }
            )
        }

        # ── 7. Overclocking & Benchmarking ────────────────────────────────────
        @{
            Id    = 'overclocking-benchmarks'
            Title = 'Overclocking & Benchmarking'
            Order = 7
            Ru    = @{ Title = 'Разгон и бенчмарки' }
            Tweaks = @(
                @{
                    Id      = 'download-msi-afterburner'
                    Title   = 'Download MSI Afterburner (GPU overclocking & monitoring)'
                    Desc    = 'GPU overclocking, fan control, and in-game overlay tool. Works with all GPU brands despite the MSI name.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.msi.com/Landing/afterburner/graphics-cards'
                    Ru = @{
                        Title = 'Скачать MSI Afterburner (разгон GPU и мониторинг)'
                        Desc  = 'Разгон GPU, управление вентиляторами и игровой оверлей. Работает с GPU любых производителей, несмотря на название MSI.'
                    }
                }
                @{
                    Id      = 'download-superposition'
                    Title   = 'Download Superposition Benchmark (GPU stress test)'
                    Desc    = 'Extreme GPU benchmark by Unigine. Tests GPU stability under heavy load with a visually impressive scene.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://benchmark.unigine.com/superposition'
                    Ru = @{
                        Title = 'Скачать Superposition Benchmark (стресс-тест GPU)'
                        Desc  = 'Экстремальный бенчмарк GPU от Unigine. Проверяет стабильность GPU под высокой нагрузкой с эффектной визуализацией.'
                    }
                }
                @{
                    Id      = 'download-testmem5'
                    Title   = 'Download TestMem5 (RAM stability tester)'
                    Desc    = 'TestMem5 is a fast RAM stress-testing tool popular for validating memory overclocks. Faster than MemTest86 for quick validation.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/CoolCmd/TestMem5/releases'
                    Ru = @{
                        Title = 'Скачать TestMem5 (тест стабильности RAM)'
                        Desc  = 'TestMem5 — быстрый инструмент стресс-тестирования RAM, популярный для проверки разгона памяти. Быстрее MemTest86 для экспресс-проверки.'
                    }
                }
                @{
                    Id      = 'download-capframex-bench'
                    MaxMovGuide = $true
                    Title   = 'Download CapFrameX (frame capture & analysis)'
                    Desc    = 'CapFrameX captures frametimes with an in-game overlay and provides detailed FPS/frametime analysis and sensor logging.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/CXWorld/CapFrameX/releases'
                    Ru = @{
                        Title = 'Скачать CapFrameX (захват и анализ кадров)'
                        Desc  = 'CapFrameX захватывает фреймтаймы с игровым оверлеем и предоставляет детальный анализ FPS/фреймтаймов и журналирование датчиков.'
                    }
                }
            )
        }

        # ── 8. Audio ──────────────────────────────────────────────────────────
        @{
            Id    = 'audio'
            Title = 'Audio'
            Order = 8
            Ru    = @{ Title = 'Звук' }
            Tweaks = @(
                @{
                    Id      = 'download-soundswitch'
                    MaxMovGuide = $true
                    Title   = 'Download SoundSwitch (hotkey audio device switcher)'
                    Desc    = 'SoundSwitch lets you switch between audio output and input devices with a configurable keyboard shortcut.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Belphemur/SoundSwitch/releases'
                    Ru = @{
                        Title = 'Скачать SoundSwitch (переключение аудиоустройств по горячей клавише)'
                        Desc  = 'SoundSwitch позволяет переключаться между аудиовыходами и микрофонами с помощью настраиваемого сочетания клавиш.'
                    }
                }
            )
        }

        # ── 9. Gaming & Account Switching ─────────────────────────────────────
        @{
            Id    = 'gaming-account-switching'
            Title = 'Gaming & Account Switching'
            Order = 9
            Ru    = @{ Title = 'Игры и переключение аккаунтов' }
            Tweaks = @(
                @{
                    Id      = 'download-tcno-account-switcher'
                    MaxMovGuide = $true
                    Title   = 'Download TcNo Account Switcher'
                    Desc    = 'Multi-account switcher for Steam, Epic Games, EA, Origin, Riot, Ubisoft, and more.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/TCNOco/TcNo-Acc-Switcher/releases'
                    Ru = @{
                        Title = 'Скачать TcNo Account Switcher'
                        Desc  = 'Переключатель аккаунтов для Steam, Epic Games, EA, Origin, Riot, Ubisoft и других платформ.'
                    }
                }
                @{
                    Id      = 'download-fan-control-recommended'
                    MaxMovGuide = $true
                    Title   = 'Download Fan Control (cooling management)'
                    Desc    = 'Fan Control provides detailed fan curve configuration for system cooling. Listed here as a general recommended program.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Rem0o/FanControl.Releases/releases'
                    Ru = @{
                        Title = 'Скачать Fan Control (управление охлаждением)'
                        Desc  = 'Fan Control обеспечивает детальную настройку кривых вентиляторов для охлаждения системы. Указан здесь как общая рекомендуемая программа.'
                    }
                }
                @{
                    Id      = 'download-qbittorrent'
                    Title   = 'Download qBittorrent (torrent client)'
                    Desc    = 'Free, open-source torrent client without bundled adware. Full-featured with search, RSS, and sequential download.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.qbittorrent.org/download'
                    Ru = @{
                        Title = 'Скачать qBittorrent (торрент-клиент)'
                        Desc  = 'Бесплатный торрент-клиент с открытым кодом без рекламного ПО. Полнофункциональный: поиск, RSS, последовательная загрузка.'
                    }
                }
            )
        }

        # ── 10. Smartphone + PC Ecosystem ────────────────────────────────────
        @{
            Id    = 'smartphone-pc'
            Title = 'Smartphone + PC Ecosystem'
            Order = 10
            Ru    = @{ Title = 'Экосистема смартфон + ПК' }
            Tweaks = @(
                @{
                    Id      = 'smartphone-pc-phone-link'
                    MaxMovGuide = $true
                    Title   = 'Phone Link — Microsoft ecosystem for Android'
                    Desc    = 'Microsoft Phone Link integrates your Android phone with Windows: shared clipboard, notifications, calls, and file transfer. See Section 4 for full setup instructions.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'For full setup instructions refer to Section 4 (Windows Settings) → Phone Link subsection.'
                    Ru = @{
                        Title       = 'Phone Link — экосистема Microsoft для Android'
                        Desc        = 'Microsoft Phone Link интегрирует Android-смартфон с Windows: общий буфер обмена, уведомления, звонки и передача файлов. Полная инструкция по настройке — в Разделе 4.'
                        Instruction = 'Полная инструкция по настройке — в Разделе 4 (Параметры Windows) → подраздел Phone Link.'
                    }
                }
                @{
                    Id      = 'download-kde-connect'
                    Title   = 'Download KDE Connect (cross-platform phone/PC integration)'
                    Desc    = 'KDE Connect provides clipboard sync, file transfer, notifications, and remote input between Windows and Android/Linux. Open-source alternative to Phone Link.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://kdeconnect.kde.org/'
                    Ru = @{
                        Title = 'Скачать KDE Connect (кросс-платформенная интеграция смартфон/ПК)'
                        Desc  = 'KDE Connect обеспечивает синхронизацию буфера обмена, передачу файлов, уведомления и удалённый ввод между Windows и Android/Linux. Открытая альтернатива Phone Link.'
                    }
                }
                @{
                    Id      = 'download-plain-app'
                    Title   = 'Download Plain App (self-hosted phone/PC bridge)'
                    Desc    = 'Plain App is an open-source Android app that exposes your phone as a local web server for file management, clipboard sync, and SMS from your PC browser. No cloud account needed.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/ismartcoding/plain-app/tags'
                    Ru = @{
                        Title = 'Скачать Plain App (собственный мост смартфон/ПК)'
                        Desc  = 'Plain App — Android-приложение с открытым кодом, которое делает смартфон локальным веб-сервером: управление файлами, синхронизация буфера обмена и SMS из браузера ПК. Облачный аккаунт не нужен.'
                    }
                }
            )
        }

    )
}
