@{
    Id    = 'cooling-setup'
    Title = 'Cooling Setup'
    Order = 6
    Ru    = @{ Title = 'Настройка Охлаждения' }

    Subsections = @(

        # ── 0. Cooling Setup ──────────────────────────────────────────────────
        @{
            Id    = 'cooling'
            Title = 'Cooling Setup'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Настройка охлаждения' }
            Tweaks = @(
                @{
                    Id      = 'enable-pwm-bios'
                    Title   = 'Enable PWM (Smart) fan mode in BIOS'
                    Desc    = 'Set fan headers to PWM (Smart) mode in BIOS/UEFI so software like Fan Control can regulate fan speeds. Only applicable if your motherboard and fans support PWM.'
                    Kind    = 'manual'
                    Source  = 'official'
                    Control = 'checklist'
                    RequiresAdmin  = $false
                    RequiresReboot = $true
                    Instruction = 'Restart into BIOS/UEFI (usually Del or F2 on boot). Navigate to the fan/hardware monitoring section. Set each fan header connected to a PWM fan to "PWM" or "Smart" mode. Save and exit.'
                    Ru = @{
                        Title       = 'Включить режим PWM (Smart) для вентиляторов в BIOS'
                        Desc        = 'Переключите разъёмы вентиляторов в режим PWM (Smart) в BIOS/UEFI, чтобы программы вроде Fan Control могли регулировать обороты. Актуально только если ваша плата и вентиляторы поддерживают PWM.'
                        Instruction = 'Перезагрузитесь в BIOS/UEFI (обычно Del или F2 при загрузке). Перейдите в раздел вентиляторов/мониторинга оборудования. Для каждого разъёма с PWM-вентилятором установите режим «PWM» или «Smart». Сохраните и выйдите.'
                    }
                }
                @{
                    Id      = 'download-fan-control'
                    Title   = 'Download Fan Control'
                    Desc    = 'Fan Control is a free open-source app for detailed fan curve configuration, temperature monitoring, and mixing sensor inputs.'
                    Kind    = 'link'
                    Source  = 'official'
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://github.com/Rem0o/FanControl.Releases/releases'
                    Ru = @{
                        Title = 'Скачать Fan Control'
                        Desc  = 'Fan Control — бесплатное приложение с открытым кодом для детальной настройки кривых вентиляторов, мониторинга температур и смешивания показаний датчиков.'
                    }
                }
            )
        }

    )
}