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

All required automated/native checks pass. Pending immutable test tag, local installation and hash verification. No Workshop upload or official release.
