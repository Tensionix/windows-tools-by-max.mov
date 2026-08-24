@{
    Name = 'privacy-baseline'

    Description = 'Turns off what phones home and what runs uninvited. Every card here is reversible, verifiable, and has exactly one sensible direction - nothing in this profile is a matter of taste.'

    # A profile is a CURATED, ORDERED list of card ids - not a filter. That is deliberate: many
    # automatable cards are choices rather than settings (which browser, which power scheme, which
    # folders to index), and several open a folder for a human rather than changing anything. Run
    # Engine\Invoke-TweakProfile.ps1 -Discover to see all 62 automatable cards with their flags, then
    # write your own profile beside this one.
    Cards = @(
        # --- Windows privacy -------------------------------------------------
        'privacy-speech'                 # online speech recognition off
        'privacy-location'               # system-wide location master switch off  (admin)
        'privacy-app-diagnostics'        # apps cannot read other apps' diagnostics (admin)
        'system-disable-recall'          # Recall optional feature removed          (admin)

        # --- Phoning home ----------------------------------------------------
        'updates-delivery-optimization'  # no P2P upload of updates                 (admin)
        'updates-find-my-device'         # device location tracking off             (admin)

        # --- Uninvited network exposure --------------------------------------
        'system-remote-desktop'          # RDP off                                  (admin)

        # --- Edge: stop it running and reporting on its own -------------------
        'edge-disable-telemetry'         # (admin)
        'edge-disable-startup-boost'     # (admin)
        'edge-disable-background'        # (admin)
        'edge-disable-newstab'           # (admin)
        'edge-disable-shopping'          # (admin)
        'edge-disable-rewards'           # (admin)
        'edge-disable-firstrun'          # (admin)
    )
}
