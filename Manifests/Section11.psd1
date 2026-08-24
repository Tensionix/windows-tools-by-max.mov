@{
    Id    = 'mouse-keyboard-settings'
    Title = 'Mouse & Keyboard Settings'
    Order = 11
    Ru    = @{ Title = 'Мышь и Клавиатура' }

    Subsections = @(

        # ── 0. Mouse Settings ─────────────────────────────────────────────────
        @{
            Id    = 'mouse-settings'
            Title = 'Mouse Settings'
            Order = 0
            Ru    = @{ Title = 'Настройки мыши' }
            Tweaks = @(
                @{
                    Id      = 'mouse-myths-guide'
                    Title   = 'Gaming mouse myths — 8000 Hz polling, high DPI, mouse acceleration (YouTube)'
                    Desc    = 'Video guide debunking common gaming mouse myths: ultra-high polling rates, high DPI advantages, and mouse acceleration effects. Helps understand what settings actually matter for gaming.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.youtube.com/watch?v=2leo5S5RzRw'
                    Ru = @{
                        Title = 'Мифы об игровых мышах — 8000 Гц, высокий DPI, ускорение мыши (YouTube)'
                        Desc  = 'Видеогайд о распространённых заблуждениях: сверхвысокая частота опроса, преимущества высокого DPI и влияние ускорения мыши. Помогает разобраться, какие настройки реально важны для игр.'
                    }
                }
                @{
                    Id      = 'mouse-settings-guide'
                    Title   = 'Mouse settings guide — DPI, Angle Snap, Ripple Control, polling rate, etc. (Telegram)'
                    Desc    = 'Detailed guide covering optimal mouse DPI, Angle Snap, Ripple Control, polling rate selection, and other mouse-specific settings for gaming.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://t.me/allp1ay/1211'
                    Ru = @{
                        Title = 'Гайд по настройке мыши — DPI, Angle Snap, Ripple Control, частота опроса и др. (Telegram)'
                        Desc  = 'Подробный гайд по оптимальным настройкам мыши: DPI, Angle Snap, Ripple Control, выбор частоты опроса и другие параметры для игр.'
                    }
                }
            )
        }

        # ── 1. Keyboard Settings ──────────────────────────────────────────────
        @{
            Id    = 'keyboard-settings'
            Title = 'Keyboard Settings'
            Order = 1
            Ru    = @{ Title = 'Настройки клавиатуры' }
            Tweaks = @(
                @{
                    Id      = 'magnetic-keyboard-guide'
                    Title   = 'Magnetic keyboard setup guide — Rapid Trigger, actuation point, Snap Tap, etc. (YouTube)'
                    Desc    = 'Video guide for configuring Hall-effect / magnetic keyboards: Rapid Trigger, actuation height, Snap Tap (simultaneous opposite directions), and other advanced features.'
                    Kind    = 'link'
                    Source  = 'unofficial'
                    MaxMovGuide    = $true
                    Control = 'button'
                    RequiresAdmin  = $false
                    RequiresReboot = $false
                    Url     = 'https://www.youtube.com/@MAXiM0V/videos'
                    Ru = @{
                        Title = 'Гайд по настройке магнитной клавиатуры — Rapid Trigger, точка срабатывания, Snap Tap и др. (YouTube)'
                        Desc  = 'Видеогайд по настройке Hall-effect / магнитных клавиатур: Rapid Trigger, высота срабатывания, Snap Tap (одновременные противоположные направления) и другие продвинутые функции.'
                    }
                }
            )
        }

    )
}
