@{
    Id    = 'global-timer-resolution'
    Title = 'Global Timer Resolution (Optional)'
    Order = 8
    Ru    = @{ Title = 'Разрешение таймера (опционально)' }

    Subsections = @(

        # ── 0. Timer Resolution ───────────────────────────────────────────────
        @{
            Id    = 'timer-resolution'
            Title = 'Global Timer Resolution'
            Order = 0
            MaxMovGuide = $true
            Ru    = @{ Title = 'Глобальное разрешение таймера' }
            Tweaks = @(
                @{
                    Id      = 'timer-resolution-notes'
                    Title   = 'Timer Resolution — important notes (v0.3)'
                    Desc    = 'The old Timer Resolution executable archive is intentionally not shipped in this project. Treat donor material as reference only; source and review any tools separately if you deliberately want to test them.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'There is no local Timer Resolution archive to extract or run. If you obtain timer-resolution tools separately, verify the source/signature, scan the files, and test only if you understand the power, latency, and stability trade-offs. Most users will not need this tweak.'
                    Ru = @{
                        Title       = 'Timer Resolution — важные примечания (v0.3)'
                        Desc        = 'Старый исполняемый архив Timer Resolution намеренно не поставляется в этом проекте. Донорские материалы используем только как справку; любые инструменты нужно искать и проверять отдельно, если вы осознанно хотите их тестировать.'
                        Instruction = 'Локального архива Timer Resolution для распаковки или запуска здесь нет. Если вы отдельно получили инструменты разрешения таймера, проверьте источник/подпись, просканируйте файлы и тестируйте только если понимаете компромиссы по питанию, задержке и стабильности. Большинству пользователей этот твик не нужен.'
                    }
                }
                @{
                    Id      = 'timer-resolution-what-it-does'
                    Title   = 'What is Global Timer Resolution?'
                    Desc    = 'Windows uses a system-wide timer interrupt that defaults to 15.625 ms. Setting a higher resolution (e.g. 0.5 ms) can reduce micro-stutter in games, but it increases CPU power consumption and may destabilise some workloads. Not recommended for most users.'
                    Kind    = 'manual'
                    Source  = 'unofficial'
                    Control = 'checklist'
                    RequiresAdmin  = $true
                    RequiresReboot = $false
                    Instruction = 'Use this card as background context only. This project does not install or launch Timer Resolution. Only apply a separately sourced utility if you understand the trade-offs; revert by stopping the utility or uninstalling it.'
                    Ru = @{
                        Title       = 'Что такое глобальное разрешение таймера?'
                        Desc        = 'Windows использует системное прерывание таймера с шагом по умолчанию 15,625 мс. Повышение разрешения (например, до 0,5 мс) может снизить микрофризы в играх, но увеличивает энергопотребление CPU и может дестабилизировать некоторые нагрузки. Большинству пользователей не рекомендуется.'
                        Instruction = 'Используйте эту карточку только как справку. Проект не устанавливает и не запускает Timer Resolution. Применяйте отдельно полученную утилиту только если понимаете компромиссы; для отмены остановите утилиту или удалите её.'
                    }
                }
            )
        }

    )
}
