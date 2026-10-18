# 0.2.53.11 — Verification and short test

C309, 2026-10-18. Owner rendering and connected multiplayer acceptance remain pending.

## Verification

Full validation passes 21,600 assertions, 218 compiled Lua/translation inputs, 1,008 translation keys and independent package closure; 290 source files and 370 package files. The shipped-Lua banned-call gate passes. Focused checks cover press/release sprite transitions, private location-index replacement and no repeated sprite transmissions while held. Generated sprite preview inspected: a visible margin remains around both states, and only the plate top changes height. Full-tile activation remains intentional.

Initial native startup rejected reuse of one sprite identity for all four placement directions. Each direction now has a distinct identity that shares the same raised image; the pressed state shares one additional identity. This does not create additional image states or a runtime animation loop. A second native check exposed the old placement-component identity during migration. The old entity remains loadable, while new placement and converted plates use a separate definition that also recognizes the pressed state. Native write/read both pass after this correction. They verify old-plate migration, actual occupied/released state transitions, native texture-pack decoding (85 Traps / 30 Turrets sprite identities), pressed-state save/reload with a valid SpriteConfig, and retained non-thumpability. Dedicated probes use zero connected clients. Traps-only, Turrets-only and combined native startup all pass, including conversion of an old plate and selection of the correct package-local pressed sprite. No failed build was installed. Rendered and connected multiplayer acceptance remain pending.

## Short owner test

1. Restart and confirm **0.2.53.11**. Check an existing plate and a new placement preview: both leave a small visible margin around the tile.
2. Step onto a plate, stand still, then step off: it lowers, stays down without flicker, then rises.
3. Let an eligible zombie cross a linked plate: it lowers, still powers the turret, then releases; zombies should not thump it.
4. Save/reload and check its appearance, links and activation again. Report issues; Codex will inspect console.txt. Connected testing stays separate.

## Delivery

Installed from immutable `test/v0.2.53.11` / `0f54e646c94a9e244214afc08821397c19b264fe` through `OMH.cmd -Action Install`. All 290 source and 370 package/tag/install/archive files match; both 0.2.53.10 backups verify. [Release evidence](../diagnostics/v0.2.53.11/local-release.json) records hashes and the managed backup. Initial automatic installation review timed out before execution; the permitted retry installed and verified successfully. Development delivery uses the existing branch/draft PR under C108. No Workshop upload or official release; rendered and connected acceptance remain pending.


## C310 — Owner findings and read-only audit (2026-10-18)

Owner supplies three screenshots and reports plate/player drawing order, absent low pickup animation, Controller entry from turrets, missing incoming connection list, module replacement/feedback gaps, Ammunition's right inset, Set Facing exceptions and unexplained Controller/destination buttons. These remain open; this report does not accept rendering or multiplayer. [Complete diagnosis and proposed fixes](CORRECTIONS_C310.md). New Leech/Synergy proposals and Controller A–E choices are separate from test findings.

Captured console SHA-256: `85b8c570249996bd71ed15e65b5c7283dc8e496aa863d74be7bb7e04bfde96c2`; explicit diagnostic version 0.2.53.11, side SP. Two cursor load exceptions report missing native ISBuildingObject at client startup; three Set Facing clicks fail on the resulting missing module. The dependency is present under the native server Lua tree, so this is lifecycle initialization, not a missing game installation. Prior native dedicated checks had no client UI; `facing_cursor_setup.lua` supplied a stand-in parent. Those checks did not cover this failing startup path. No claim that their previous passes validate the live cursor.

Static review confirms eight-pixel frame mismatch, no ControlAction pickup animation, ControlPanel opener without Controller-kind restriction, selected-input-only UI, and no enabled Open Manage/Unassign or destination tooltips. Current installed bytecode supports RenderLayer=Floor independently of solidfloor; floor-render correction still requires owner pixel acceptance. No game code/package/install/version change or new full gameplay test run. Desktop/mobile HTML layout checks and inspected mockups are planning evidence only.
