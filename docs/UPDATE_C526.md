# C526 - Consolidated update implementation

Owner approval, 2026-10-30: "Approved. Go ahead and implement the full update, including all the multiplayer fixes. Take your time and verify everything before packaging."

This authorizes the entire [C525 scope](UPDATE_SCOPE_C525.md), including the C518 multiplayer/loading repairs and C523/C524 trap changes. It does not authorize a Workshop upload, live-server deployment or sibling-project edit. The prior GitHub automatic approval-review rejection remains in force.

## Implemented source changes

- Physical Splitter/Fragment children carry original ammunition identity and actual travel time. Arc remains electrical; firearm children retain tracers. Fragment starts at impact with no artificial 250ms wait. Piercing resumes at impact, accounting for distance already travelled. Explosive flight and landing fuses remain distinct.
- Rotary rendering advances a bounded motor clock between snapshots, correcting packet updates continuously. Tether presentation predicts through delayed snapshots up to750ms and respects the server-known obstruction endpoint. Neither changes server hit authority. Phase receipt and first-render diagnostics expose transit and draw wait separately from server cycle time.
- Makeshift Bomb loading uses light-ammo duration and bounded20-item batches in SP/MP. Inventory weight, ammo capacity, exact-item checks and replay protection remain intact.
- New Poke deployments reserve center plus four adjacent cardinal tiles and render one low stabilizer assembly. Arms are traversable, non-damaging and exclusive of other floor hazards. Preview shows all five tiles; server completion checks all five, including safehouses. Existing placements retain their old footprint until redeployed. No added trigger delay or corpse maintenance.
- Both Poke recipes require5 bars/10 screws. New Barrier default is80, reinforced160; saved sandbox tuning remains unchanged.

## Verification status

The complete Kahlua suite and focused C526 replay pass41,863 assertions. Five frozen old production paths fail their named regression checks, then the corrected suite passes. Native write and fresh-process read pass. The final independently selectable package starts and delivery checks are being completed. Controlled tests cover physical projectile time, source families, piercing continuation, Arc exclusion, rotary transit0/100/200/350ms, bounded tether prediction, full-weight bomb server batches/replay and footprint reservation/persistence/removal. Native table and packet serialization run in the stock game runtime. World/network/UI actors in these replays are test doubles; connected smoothness and rendered stabilizers require owner acceptance.

## Integration boundary

Owner explicitly approved the prepared matching Horde Night baseline edit during implementation. Horde Night0.6.16.10 changes `SpikeBarrierHealth` default100 to80;610 installed-Kahlua assertions pass, including actual generated Traps-only, Turrets-only and combined default parity. No saved run history or player tuning is changed. The earlier proposed diff is retained in diagnostics/c526.

Confirmed T&T0.2.70.11 content upload to3828638252 at2026-10-31T00:58:46Z is the new changelog baseline. The upload receipt and SteamCMD success line agree; [sanitized receipt](evidence/c526-upload-baseline.json). The0.2.71 draft therefore lists only this update. Horde Night's unrelated pending cumulative notes remain intact.

T&T packaging/install are pending final delivery checks. Horde Night0.6.16.10 is committed at942789d, tagged and installed into local mods and the existing Workshop stage, with verified backups. Its installer passed preflight and verified copied files against the tag. No publication or live-server changes performed.
