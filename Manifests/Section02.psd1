@{
    Id    = 'disk-preparation'
    Title = 'Disk Preparation'
    Order = 2
    Ru    = @{ Title = 'Подготовка дисков' }

    Subsections = @(

        # ── 0. Partition Cleanup ──────────────────────────────────────────────
        @{
            Id    = 'partition-cleanup'
            Title = 'Partition Cleanup'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Очистка разделов' }
            Tweaks = @(
                @{
                    Id      = 'delete-install-partition'
                    Title   = 'Delete Windows installation files partition (no-USB method)'
                    Desc    = 'After installing Windows without a USB drive, a temporary partition remains. Open Disk Management to delete it.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Open Disk Management (diskmgmt.msc), locate the small partition containing installation files, right-click it and select "Delete Volume". This only applies if you installed Windows using the no-USB method.'
                    Ru = @{
                        Title       = 'Удалить раздел с установочными файлами Windows (метод без USB)'
                        Desc        = 'После установки Windows без USB-носителя остаётся временный раздел. Откройте Управление дисками и удалите его.'
                        Instruction = 'Откройте Управление дисками (diskmgmt.msc), найдите небольшой раздел с установочными файлами, щёлкните по нему правой кнопкой и выберите «Удалить том». Применимо только если Windows устанавливалась методом без USB.'
                    }
                }
                @{
                    Id      = 'minitool-partition-wizard'
                    Title   = 'MiniTool Partition Wizard — advanced partition manager'
                    Desc    = 'Free partition manager with a visual interface for more complex partition operations.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.partitionwizard.com/free-partition-manager.html'
                    Ru = @{
                        Title = 'MiniTool Partition Wizard — расширенный менеджер разделов'
                        Desc  = 'Бесплатный менеджер разделов с визуальным интерфейсом для сложных операций с разделами.'
                    }
                }
                @{
                    Id      = 'reconnect-drives'
                    Title   = 'Reconnect previously disconnected drives'
                    Desc    = 'If you disconnected additional drives during Windows installation to prevent data loss, now reconnect them.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Power off the PC, reconnect any drives you disconnected before installation, then power on.'
                    Ru = @{
                        Title       = 'Подключить ранее отсоединённые диски'
                        Desc        = 'Если при установке Windows вы отключали дополнительные диски во избежание потери данных — подключите их обратно.'
                        Instruction = 'Выключите ПК, подключите обратно все диски, которые были отсоединены перед установкой, затем включите.'
                    }
                }
            )
        }

        # ── 1. Drive Letters & Explorer ───────────────────────────────────────
        @{
            Id    = 'drive-letters'
            Title = 'Drive Letters & Explorer'
            Order = 1
            MaxMovGuide = $true
            Ru    = @{ Title = 'Буквы дисков и Проводник' }
            Tweaks = @(
                @{
                    Id      = 'verify-drives-explorer'
                    Title   = 'Verify all drives are visible in Explorer'
                    Desc    = 'Open File Explorer and confirm all connected drives appear as expected.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Open File Explorer (Win+E) and check that all installed drives are listed under "This PC".'
                    Ru = @{
                        Title       = 'Убедиться, что все диски видны в Проводнике'
                        Desc        = 'Откройте Проводник и убедитесь, что все подключённые диски отображаются корректно.'
                        Instruction = 'Откройте Проводник (Win+E) и проверьте, что все установленные диски перечислены в разделе «Этот компьютер».'
                    }
                }
                @{
                    Id      = 'assign-drive-letters'
                    Title   = 'Assign drive letters (if drives are missing or mixed up)'
                    Desc    = 'Open Disk Management to assign or change drive letters if drives are not visible or have incorrect letters.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Open Disk Management (diskmgmt.msc), right-click the volume, choose "Change Drive Letter and Paths", and assign the desired letter.'
                    Ru = @{
                        Title       = 'Назначить буквы дисков (если диски не видны или перепутаны)'
                        Desc        = 'Откройте Управление дисками для назначения или смены букв дисков, если они не отображаются или имеют неправильные буквы.'
                        Instruction = 'Откройте Управление дисками (diskmgmt.msc), щёлкните правой кнопкой по тому, выберите «Изменить букву диска или путь к диску» и назначьте нужную букву.'
                    }
                }
            )
        }

        # ── 2. User Folder Relocation ─────────────────────────────────────────
        @{
            Id    = 'user-folder-relocation'
            Title = 'User Folder Relocation'
            Order = 2
            MaxMovGuide = $true
            Ru    = @{ Title = 'Перенос пользовательских папок' }
            Tweaks = @(
                @{
                    Id      = 'copy-user-folder'
                    Title   = 'Copy User folder to a second partition or drive'
                    Desc    = 'Move personal files (Desktop, Documents, Downloads, Music, Pictures, Videos) to a secondary drive to keep the OS drive clean and protect data across reinstalls.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Copy the User template folder to your second drive (e.g. D:\User). Inside create subfolders: Desktop, Documents, Downloads, Music, Pictures, Videos.'
                    Ru = @{
                        Title       = 'Скопировать папку пользователя на второй раздел или диск'
                        Desc        = 'Перенесите личные файлы (Рабочий стол, Документы, Загрузки, Музыка, Изображения, Видео) на второй диск — это сохранит системный диск чистым и защитит данные при переустановке.'
                        Instruction = 'Скопируйте шаблон папки пользователя на второй диск (например, D:\User). Внутри создайте подпапки: Рабочий стол, Документы, Загрузки, Музыка, Изображения, Видео.'
                    }
                }
                @{
                    Id      = 'redirect-user-folders'
                    Title   = 'Redirect user shell folders to the new location'
                    Desc    = 'Open the Users folder in Explorer, then right-click each shell folder (Desktop, Documents, etc.) → Properties → Location to redirect them to the new drive.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Navigate to C:\Users\YourName\. Right-click Desktop → Properties → Location tab → Move → select D:\User\Desktop. Repeat for Documents, Downloads, Music, Pictures, Videos.'
                    Ru = @{
                        Title       = 'Перенаправить пользовательские папки на новое место'
                        Desc        = 'Откройте папку пользователя в Проводнике, щёлкните правой кнопкой по каждой системной папке (Рабочий стол, Документы и др.) → Свойства → вкладка «Расположение» — перенаправьте на новый диск.'
                        Instruction = 'Перейдите в C:\Users\ИмяПользователя\. Щёлкните правой кнопкой по «Рабочий стол» → Свойства → вкладка «Расположение» → «Переместить» → выберите D:\User\Рабочий стол. Повторите для Документов, Загрузок, Музыки, Изображений, Видео.'
                    }
                }
                @{
                    Id      = 'relocate-user-folders-to-root'
                    Title   = 'Relocate user folders to C:\<username>\ (script)'
                    Desc    = 'Creates C:\<username>\Desktop|Documents|Music|Pictures|Videos and writes legacy User Shell Folders registry keys. On Windows 11 the KnownFolders API may override these; sign out and back in to let Explorer pick up the change. Marked unofficial — test before relying on it.'
                    Kind    = 'script'
                    Source  = 'unofficial'
                    Control = 'toggle'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Apply = {
                        $base = Join-Path $env:SystemDrive $env:USERNAME
                        $map  = @{
                            Desktop    = 'Desktop'
                            Personal   = 'Documents'
                            'My Music' = 'Music'
                            'My Pictures' = 'Pictures'
                            'My Video' = 'Videos'
                        }
                        foreach ($sub in $map.Values) {
                            $target = Join-Path $base $sub
                            if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
                        }
                        $ushf = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
                        $shf  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
                        foreach ($name in $map.Keys) {
                            $target = Join-Path $base $map[$name]
                            Set-ItemProperty -Path $ushf -Name $name -Value $target -Type ExpandString
                            Set-ItemProperty -Path $shf  -Name $name -Value $target -Type String
                        }
                    }
                    Revert = {
                        $up   = $env:USERPROFILE
                        $ushf = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
                        $shf  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
                        $defaults = @{
                            Desktop       = @{ Expand = '%USERPROFILE%\Desktop';     Abs = "$up\Desktop" }
                            Personal      = @{ Expand = '%USERPROFILE%\Documents';   Abs = "$up\Documents" }
                            'My Music'    = @{ Expand = '%USERPROFILE%\Music';       Abs = "$up\Music" }
                            'My Pictures' = @{ Expand = '%USERPROFILE%\Pictures';    Abs = "$up\Pictures" }
                            'My Video'    = @{ Expand = '%USERPROFILE%\Videos';      Abs = "$up\Videos" }
                        }
                        foreach ($name in $defaults.Keys) {
                            Set-ItemProperty -Path $ushf -Name $name -Value $defaults[$name].Expand -Type ExpandString
                            Set-ItemProperty -Path $shf  -Name $name -Value $defaults[$name].Abs    -Type String
                        }
                    }
                    Detect = {
                        $base    = Join-Path $env:SystemDrive $env:USERNAME
                        $ushf    = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
                        try {
                            $desktop = (Get-ItemProperty $ushf -Name 'Desktop' -EA Stop).Desktop
                            $desktop -eq (Join-Path $base 'Desktop')
                        }
                        catch { $false }
                    }
                    Instruction = 'Click Apply to create C:\<username>\ subfolders and redirect Desktop, Documents, Music, Pictures, Videos. A sign-out or Explorer restart is needed for all apps to pick up the new paths. Click Revert to restore default %USERPROFILE%\ paths.'
                    Ru = @{
                        Title       = 'Перенести папки пользователя в C:\<имя_пользователя>\ (скрипт)'
                        Desc        = 'Создаёт C:\<имя_пользователя>\Desktop|Documents|Music|Pictures|Videos и прописывает пути в реестре (User Shell Folders). На Windows 11 KnownFolders API может их переопределить — после применения выйдите из системы и зайдите снова. Помечено как unofficial — проверьте перед использованием.'
                        Instruction = 'Нажмите «Применить» для создания подпапок в C:\<имя_пользователя>\ и перенаправления Рабочего стола, Документов, Музыки, Изображений, Видео. Для применения изменений всеми приложениями нужен выход из системы или перезапуск Проводника. Нажмите «Отменить» для восстановления путей по умолчанию %USERPROFILE%\.'
                    }
                }
            )
        }

        # ── 3. Apps & Gaming Folders ──────────────────────────────────────────
        @{
            Id    = 'apps-gaming-folders'
            Title = 'Apps & Gaming Folders'
            Order = 3
            MaxMovGuide = $true
            Ru    = @{ Title = 'Папки для программ и игр' }
            Tweaks = @(
                @{
                    Id      = 'copy-apps-folder'
                    Title   = 'Set up Apps folder for portable applications'
                    Desc    = 'Create an Apps folder on a secondary drive for portable and manually installed applications, keeping them separate from the OS drive.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Create a folder such as D:\Apps on your secondary drive. Install portable applications there to keep them safe across OS reinstalls.'
                    Ru = @{
                        Title       = 'Создать папку Apps для портативных программ'
                        Desc        = 'Создайте папку Apps на втором диске для портативных и устанавливаемых вручную программ — отдельно от системного диска.'
                        Instruction = 'Создайте папку D:\Apps на втором диске. Устанавливайте туда портативные программы — они останутся при переустановке ОС.'
                    }
                }
                @{
                    Id      = 'copy-gaming-folder'
                    Title   = 'Set up Gaming folder for games and launchers (optional)'
                    Desc    = 'Create a Gaming folder on a secondary drive and configure Steam and other launchers to install games there by default.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Instruction = 'Create D:\Gaming on your secondary drive. In Steam: Settings → Storage → Add Drive → select D:\Gaming. Configure other launchers similarly.'
                    Ru = @{
                        Title       = 'Создать папку Gaming для игр и лаунчеров (опционально)'
                        Desc        = 'Создайте папку Gaming на втором диске и настройте Steam и другие лаунчеры на установку игр туда по умолчанию.'
                        Instruction = 'Создайте D:\Gaming на втором диске. В Steam: Параметры → Хранилище → Добавить диск → выберите D:\Gaming. Аналогично настройте другие лаунчеры.'
                    }
                }
            )
        }

    )
}
