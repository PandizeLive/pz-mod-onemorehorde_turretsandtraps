# 0.2.47.3 - Pack cues and LootLab tier feedback

## Short owner test

1. Restart and confirm **0.2.47.3**. Open a Module Pack: rotation ticks slow with the reel, followed by one pickup cue.
2. Let it settle: rarity highlighting fades over **four seconds**. Collect; three rewards remain. Open another and Collect early: no continuing ticking or duplicate rewards.
3. Refresh LootLab. Move a module between Abundant and Mythic: its badge/background update to the calculated rarity. Confirm and check its normal-list rarity badge matches.
4. Give a tier a distinct weight, move a module into it, Confirm, then reopen: that module returns to the matching tier. Cancel a different move: the saved weight stays unchanged.

Report anything unexpected; console.txt will be reviewed. Custom rarity audio is pending. Native event playback does not add forced random pitch; map marker colors are component identities, separate from rarity. C183 now saves tier definitions with account settings across refreshes and devices; see LOOTLAB_TIER_PERSISTENCE.md.

## Automated verification

- Foundation: 16,101 assertions, 117 Lua/translation compilations; no shipped pcall/xpcall. Reveal audit checks one bounded native cue stream, no catch-up burst, one selection cue, early close cleanup and exactly four-second fade, with no item creation/text wrapping during render.
- Browser: real drag/drop, keyboard assignment, immediate badges/colors, custom tier reopening, Confirm/Cancel, mobile bounds and audition playback pass without page errors. Unit tests cover same-weight precision, duplicate tiers and concurrent untouched edits.
- Hosted API suite: 78 tests pass. Native write/read passed (95.0/79.6 seconds); traps/turrets/both isolation passed (83.3/72.6/65.6 seconds). Hosted deployment verified with unchanged backend and protected routes; see RELEASE.md.
- Installed native SoundManager exposes playUISound/stopUISound. Bytecode proves unsafe emitter pitch scope and absent EventSound clip-pitch usage. FMOD event-level probe returned pitch 1.0 in 20 starts; this does not prove absence of internal instrument modulation. No forced pitch claim.
- Current player console remains 0.2.47.1; no new game acceptance claimed.
