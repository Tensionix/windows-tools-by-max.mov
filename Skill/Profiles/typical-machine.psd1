@{
    Name = 'typical-machine'

    Description = 'What the project owner sets on essentially every machine: the privacy baseline, a browser that is not Edge, and clipboard history. Deliberately silent about power scheme, search indexing and personalization - those are asked about, never assumed.'

    # Inherits every card from privacy-baseline.psd1, then adds the ones below. Resolved beside this
    # file, so profiles can be layered without copying ids and drifting from the original.
    Extends = 'privacy-baseline.psd1'

    Cards = @(
        'install-chrome'            # any browser but Edge; Chrome is the safe assumption
        'system-clipboard-history'  # Win+V - always on, on every machine
    )
}
