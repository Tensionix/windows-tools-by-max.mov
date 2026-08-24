@{
    Id    = 'steam-game-launchers'
    Title = 'Steam & Game Launchers'
    Order = 7
    Ru    = @{ Title = 'Steam и игровые лаунчеры' }

    Subsections = @(

        # ── 0. Game Launchers ─────────────────────────────────────────────────
        @{
            Id    = 'game-launchers'
            Title = 'Game Launchers'
            Order = 0
            Ru    = @{ Title = 'Игровые лаунчеры' }
            Tweaks = @(
                @{
                    Id      = 'download-steam'
                    MaxMovGuide = $true
                    Title   = 'Download Steam'
                    Desc    = 'Official Steam client download page.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://store.steampowered.com/about/'
                    Ru = @{
                        Title = 'Скачать Steam'
                        Desc  = 'Официальная страница загрузки клиента Steam.'
                    }
                }
                @{
                    Id      = 'download-epic-games'
                    Title   = 'Download Epic Games Store'
                    Desc    = 'Official Epic Games Store launcher download page.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://store.epicgames.com/download'
                    Ru = @{
                        Title = 'Скачать Epic Games Store'
                        Desc  = 'Официальная страница загрузки лаунчера Epic Games Store.'
                    }
                }
                @{
                    Id      = 'download-ea-app'
                    MaxMovGuide = $true
                    Title   = 'Download EA App'
                    Desc    = 'Official EA App launcher download page (replaces Origin).'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.ea.com/ea-app'
                    Ru = @{
                        Title = 'Скачать EA App'
                        Desc  = 'Официальная страница загрузки лаунчера EA App (заменяет Origin).'
                    }
                }
                @{
                    Id      = 'ea-install-other-drive'
                    MaxMovGuide = $true
                    Title   = 'Install EA App to a custom drive'
                    Desc    = 'The EA installer supports a command-line argument to set the default install folder. Use this to install games on a secondary drive.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Run the EA installer from the command line with: EAappInstaller.exe /i DefaultInstallFolder="D:\Gaming\EA Games" — replace D:\Gaming\EA Games with your preferred path.'
                    Ru = @{
                        Title       = 'Установить EA App на другой диск'
                        Desc        = 'Установщик EA App поддерживает аргумент командной строки для задания папки установки по умолчанию. Используйте это для установки игр на второй диск.'
                        Instruction = 'Запустите установщик EA App из командной строки: EAappInstaller.exe /i DefaultInstallFolder="D:\Gaming\EA Games" — замените D:\Gaming\EA Games на нужный путь.'
                    }
                }
                @{
                    Id      = 'download-blizzard'
                    Title   = 'Download Blizzard Battle.net'
                    Desc    = 'Official Battle.net desktop app download page.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://download.battle.net/desktop'
                    Ru = @{
                        Title = 'Скачать Blizzard Battle.net'
                        Desc  = 'Официальная страница загрузки приложения Battle.net.'
                    }
                }
                @{
                    Id      = 'download-rockstar'
                    Title   = 'Download Rockstar Games Launcher'
                    Desc    = 'Official Rockstar Games Launcher download page (required for GTA V, RDR2, etc.).'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://socialclub.rockstargames.com/rockstar-games-launcher'
                    Ru = @{
                        Title = 'Скачать Rockstar Games Launcher'
                        Desc  = 'Официальная страница загрузки лаунчера Rockstar Games (необходим для GTA V, RDR2 и др.).'
                    }
                }
                @{
                    Id      = 'download-xbox'
                    Title   = 'Download Xbox app'
                    Desc    = 'Official Xbox app for PC from the Microsoft Store. Provides access to Game Pass and Xbox games.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/store/productId/9MV0B5HZVK9Z'
                    Ru = @{
                        Title = 'Скачать приложение Xbox'
                        Desc  = 'Официальное приложение Xbox для ПК из Microsoft Store. Открывает доступ к Game Pass и играм Xbox.'
                    }
                }
                @{
                    Id      = 'download-valorant-lol'
                    Title   = 'Download Valorant / League of Legends'
                    Desc    = 'Riot Games download page for Valorant and League of Legends (includes the Riot Client).'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://playvalorant.com/download/'
                    Ru = @{
                        Title = 'Скачать Valorant / League of Legends'
                        Desc  = 'Страница загрузки игр Riot Games: Valorant и League of Legends (включает Riot Client).'
                    }
                }
                @{
                    Id      = 'download-account-switcher'
                    MaxMovGuide = $true
                    Title   = 'Download TcNo Account Switcher'
                    Desc    = 'Convenient multi-account switcher for Steam, Epic Games, EA, and other gaming platforms.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/TCNOco/TcNo-Acc-Switcher/releases'
                    Ru = @{
                        Title = 'Скачать TcNo Account Switcher'
                        Desc  = 'Удобный переключатель аккаунтов для Steam, Epic Games, EA и других игровых платформ.'
                    }
                }
            )
        }

        # ── 1. Minecraft ──────────────────────────────────────────────────────
        @{
            Id    = 'minecraft'
            Title = 'Minecraft'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Minecraft' }
            Tweaks = @(
                @{
                    Id      = 'minecraft-notes'
                    Title   = 'Minecraft launcher notes (v0.4)'
                    Desc    = 'Correction from v0.4: Prism Launcher does NOT support playing without a license. Use Freesm Launcher (fork of Prism) for playing without a license.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Use Freesm Launcher (link 3.1) if you want to play without a license. Prism Launcher requires a valid Minecraft license.'
                    Ru = @{
                        Title       = 'Примечания о лаунчерах Minecraft (v0.4)'
                        Desc        = 'Исправление из v0.4: Prism Launcher НЕ поддерживает игру без лицензии. Для игры без лицензии используйте Freesm Launcher (форк Prism).'
                        Instruction = 'Используйте Freesm Launcher (ссылка 3.1) для игры без лицензии. Prism Launcher требует действующей лицензии Minecraft.'
                    }
                }
                @{
                    Id      = 'minecraft-bedrock'
                    Title   = 'Download Minecraft (Bedrock Edition — official, requires license)'
                    Desc    = 'Official Minecraft Bedrock Edition from the Microsoft Store.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/store/productId/9NBLGGH2JHXJ'
                    Ru = @{
                        Title = 'Скачать Minecraft (Bedrock Edition — официально, требуется лицензия)'
                        Desc  = 'Официальная Bedrock Edition Minecraft из Microsoft Store.'
                    }
                }
                @{
                    Id      = 'minecraft-bedrock-preview'
                    Title   = 'Download Minecraft Preview (Bedrock early access — official, requires license)'
                    Desc    = 'Early access builds of Minecraft Bedrock Edition from the Microsoft Store.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/store/productId/9P5X4QVLC2XR'
                    Ru = @{
                        Title = 'Скачать Minecraft Preview (ранний доступ Bedrock — официально, требуется лицензия)'
                        Desc  = 'Сборки раннего доступа Minecraft Bedrock Edition из Microsoft Store.'
                    }
                }
                @{
                    Id      = 'minecraft-launcher-unified'
                    Title   = 'Download Minecraft Launcher (Bedrock + Java — official, requires license)'
                    Desc    = 'Unified Minecraft Launcher supporting both Bedrock and Java editions, from the Microsoft Store.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.microsoft.com/store/productId/9PGW18NPBZV5'
                    Ru = @{
                        Title = 'Скачать Minecraft Launcher (Bedrock + Java — официально, требуется лицензия)'
                        Desc  = 'Единый лаунчер Minecraft с поддержкой Bedrock и Java Edition из Microsoft Store.'
                    }
                }
                @{
                    Id      = 'minecraft-launcher-no-store'
                    Title   = 'Download Minecraft Launcher without Microsoft Store (Java Edition — official)'
                    Desc    = 'Direct download for the Minecraft Java Edition launcher without using the Microsoft Store.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.minecraft.net/download'
                    Ru = @{
                        Title = 'Скачать Minecraft Launcher без Microsoft Store (Java Edition — официально)'
                        Desc  = 'Прямая загрузка лаунчера Minecraft Java Edition без использования Microsoft Store.'
                    }
                }
                @{
                    Id      = 'minecraft-prism-launcher'
                    Title   = 'Download Prism Launcher (unofficial, requires license)'
                    Desc    = 'Open-source Minecraft launcher with modpack management. Requires a valid Minecraft license.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/PrismLauncher/PrismLauncher/releases'
                    Ru = @{
                        Title = 'Скачать Prism Launcher (неофициально, требуется лицензия)'
                        Desc  = 'Лаунчер Minecraft с открытым кодом и управлением сборками модов. Требует действующей лицензии Minecraft.'
                    }
                }
                @{
                    Id      = 'minecraft-freesm-launcher'
                    Title   = 'Download Freesm Launcher (unofficial, no license required)'
                    Desc    = 'Fork of Prism Launcher that supports playing without a Minecraft license.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/FreesmTeam/FreesmLauncher/releases'
                    Ru = @{
                        Title = 'Скачать Freesm Launcher (неофициально, лицензия не требуется)'
                        Desc  = 'Форк Prism Launcher с поддержкой игры без лицензии Minecraft.'
                    }
                }
                @{
                    Id      = 'minecraft-multimc'
                    Title   = 'Download MultiMC Launcher (outdated, unofficial, requires license)'
                    Desc    = 'Legacy MultiMC launcher — outdated, superseded by Prism. Requires a valid Minecraft license.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/MultiMC/Launcher/releases'
                    Ru = @{
                        Title = 'Скачать MultiMC Launcher (устарел, неофициально, требуется лицензия)'
                        Desc  = 'Устаревший лаунчер MultiMC — заменён Prism. Требует действующей лицензии Minecraft.'
                    }
                }
                @{
                    Id      = 'minecraft-mods-modrinth'
                    Title   = 'Browse Java Edition mods on Modrinth'
                    Desc    = 'Modrinth mod repository for Minecraft Java Edition mods and modpacks.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://modrinth.com/mods'
                    Ru = @{
                        Title = 'Моды для Java Edition на Modrinth'
                        Desc  = 'Репозиторий модов Modrinth для Minecraft Java Edition.'
                    }
                }
                @{
                    Id      = 'minecraft-mods-curseforge'
                    Title   = 'Browse Java Edition mods on CurseForge'
                    Desc    = 'CurseForge mod repository for Minecraft Java Edition mods and modpacks.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.curseforge.com/minecraft'
                    Ru = @{
                        Title = 'Моды для Java Edition на CurseForge'
                        Desc  = 'Репозиторий модов CurseForge для Minecraft Java Edition.'
                    }
                }
                @{
                    Id      = 'minecraft-modrinth-app'
                    Title   = 'Download Modrinth app (mod manager)'
                    Desc    = 'Modrinth desktop app for convenient mod and modpack installation. Requires a Minecraft license.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://modrinth.com/app'
                    Ru = @{
                        Title = 'Скачать приложение Modrinth (менеджер модов)'
                        Desc  = 'Десктопное приложение Modrinth для удобной установки модов и сборок. Требует лицензии Minecraft.'
                    }
                }
                @{
                    Id      = 'minecraft-curseforge-app'
                    Title   = 'Download CurseForge app (mod manager)'
                    Desc    = 'CurseForge desktop app for convenient mod and modpack installation.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.curseforge.com/download/app'
                    Ru = @{
                        Title = 'Скачать приложение CurseForge (менеджер модов)'
                        Desc  = 'Десктопное приложение CurseForge для удобной установки модов и сборок.'
                    }
                }
                @{
                    Id      = 'minecraft-server'
                    Title   = 'Download Minecraft server (Java or Bedrock — official)'
                    Desc    = 'Official Minecraft server software download page for both Java and Bedrock editions.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.minecraft.net/download'
                    Ru = @{
                        Title = 'Скачать сервер Minecraft (Java или Bedrock — официально)'
                        Desc  = 'Официальная страница загрузки серверного ПО Minecraft для Java и Bedrock Edition.'
                    }
                }
            )
        }

    )
}
