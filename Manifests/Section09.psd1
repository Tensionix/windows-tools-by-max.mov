@{
    Id    = 'fps-latency-testing'
    Title = 'FPS & Latency Testing'
    Order = 9
    Ru    = @{ Title = 'Тестирование FPS и задержки' }

    Subsections = @(

        # ── 0. Testing Notes ──────────────────────────────────────────────────
        @{
            Id    = 'testing-notes'
            Title = 'Testing Notes'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Примечания к тестированию' }
            Tweaks = @(
                @{
                    Id      = 'testing-notes-v04'
                    Title   = 'v0.4 testing notes — Intel PresentMon & PCLatency'
                    Desc    = 'Download the .msi installer for the GUI version of Intel PresentMon (as shown in the video), or the x64 .exe for the lightweight console version. PCLatency must now be downloaded manually from GitHub — if flagged by antivirus, add it to Windows Defender exclusions.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Intel PresentMon: download .msi for the overlay GUI, or x64 .exe for the console version. Console version is lighter and more accurate — display via a second monitor or PowerToys "Always on top". Note: the console version always creates .csv files; delete them when not needed. PCLatency: download from GitHub; add to Defender exclusions if flagged.'
                    Ru = @{
                        Title       = 'Примечания v0.4 — Intel PresentMon и PCLatency'
                        Desc        = 'Скачайте установщик .msi для GUI-версии Intel PresentMon (как показано в видео) или x64 .exe для лёгкой консольной версии. PCLatency теперь нужно скачивать вручную с GitHub — при срабатывании антивируса добавьте в исключения Windows Defender.'
                        Instruction = 'Intel PresentMon: скачайте .msi для оверлея GUI или x64 .exe для консольной версии. Консольная версия легче и точнее — выводите данные на второй монитор или через PowerToys «Поверх всех окон». Важно: консольная версия всегда создаёт .csv-файлы; удаляйте их когда не нужны. PCLatency: скачайте с GitHub; добавьте в исключения Defender если антивирус реагирует.'
                    }
                }
            )
        }

        # ── 1. Testing Tools ──────────────────────────────────────────────────
        @{
            Id    = 'testing-tools'
            Title = 'Testing Tools'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Инструменты тестирования' }
            Tweaks = @(
                @{
                    Id      = 'download-capframex'
                    Title   = 'Download CapFrameX'
                    Desc    = 'CapFrameX is a frame time capture and analysis tool with an in-game overlay. Records and visualises frametimes, FPS statistics, and GPU/CPU sensor data.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/CXWorld/CapFrameX/releases'
                    Ru = @{
                        Title = 'Скачать CapFrameX'
                        Desc  = 'CapFrameX — инструмент захвата и анализа фреймтаймов с игровым оверлеем. Записывает и визуализирует фреймтаймы, статистику FPS и данные датчиков GPU/CPU.'
                    }
                }
                @{
                    Id      = 'download-intel-presentmon'
                    Title   = 'Download Intel PresentMon'
                    Desc    = 'Intel PresentMon measures frame presentation latency and FPS using ETW. Available as a GUI overlay (.msi) or lightweight console tool (x64 .exe).'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/GameTechDev/PresentMon/releases'
                    Ru = @{
                        Title = 'Скачать Intel PresentMon'
                        Desc  = 'Intel PresentMon измеряет задержку вывода кадров и FPS через ETW. Доступен в виде GUI-оверлея (.msi) или лёгкой консольной утилиты (x64 .exe).'
                    }
                }
                @{
                    Id      = 'download-nvidia-frameview'
                    Title   = 'Download Nvidia FrameView'
                    Desc    = 'Nvidia FrameView captures frame times, FPS, and power data. Works with both Nvidia and AMD GPUs.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.nvidia.com/en-us/geforce/technologies/frameview/'
                    Ru = @{
                        Title = 'Скачать Nvidia FrameView'
                        Desc  = 'Nvidia FrameView захватывает фреймтаймы, FPS и данные о потреблении энергии. Работает с GPU Nvidia и AMD.'
                    }
                }
                @{
                    Id      = 'download-pclatency'
                    Title   = 'Download PCLatency'
                    Desc    = 'PCLatency measures PC system latency and visualises results from CapFrameX .csv files. May be flagged as false positive by antivirus — add to Defender exclusions if needed.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/notch4ff4/pc-latency-view/releases'
                    Ru = @{
                        Title = 'Скачать PCLatency'
                        Desc  = 'PCLatency измеряет системную задержку ПК и визуализирует результаты из .csv-файлов CapFrameX. Антивирус может ложно реагировать — добавьте в исключения Defender.'
                    }
                }
                @{
                    Id      = 'nvidia-latency-article'
                    Title   = 'Nvidia article — Understanding and measuring PC latency'
                    Desc    = 'Official Nvidia developer article explaining end-to-end PC latency, how to measure it, and what affects it.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://developer.nvidia.com/blog/understanding-and-measuring-pc-latency/'
                    Ru = @{
                        Title = 'Статья Nvidia — понимание и измерение задержки ПК'
                        Desc  = 'Официальная статья от разработчиков Nvidia о сквозной задержке ПК: как её измерять и что на неё влияет.'
                    }
                }
            )
        }

    )
}
