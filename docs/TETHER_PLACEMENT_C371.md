# C371 — 0.2.59 owner test and battery-spectrum proposal

2026-10-20. Owner reports failed Tether Dart placement, a panel preview that is not flush with walls, and requests the whole OMH battery-consumption color spectrum. This is a test report/discussion, not approval of a new gameplay patch. Installed 0.2.59 and immutable test/v0.2.59 remain unchanged.

## Confirmed placement failure

Captured evidence: `diagnostics/captures/20261020-221550-2583` (local full console, errors, OMHTT trace and installed manifests). Console confirms `packages-ready version=0.2.59 traps=true turrets=true game=42.21` and matching client-ready. Two construction completions at frames 1609 and 2568 reach `PlacementAction.lua:112`, then vanilla `ISBuildIsoEntity.create:588` / `setInfo:641,645`. Errors are the missing Integer argument to getSpecificPlayer and subsequent `getPerkLevel of non-table: null`. BuildCheat was active for both attempts. The later F_ALICE_PackODD skeleton error is separate; this audit does not attribute it to OMHTT.

`PlacementAction.prepare` creates a fresh native cursor without its `player` field. Current installed 42.21 `ISBuildIsoEntity.setInfo` uses `self.character` on the server, but `getSpecificPlayer(self.player)` locally. Current projectzomboid.jar `javap -c zombie.iso.IsoCell` proves native `setDrag` writes the cursor's `player` field (bytecode 89–102). Our completion cursor bypasses that binding. This explains the reported single-player failure; all fourteen shared portable routes need regression coverage, not only Tether. Other routes were not reported failed in this test.

Earlier 26,119 assertions/native checks did not execute the full single-player mapped-world create lifecycle. Timing, serialization and native recipe consumption passing did not cover this missing field. This is a verification gap, not an owner-settings issue.

Proposed correction: initialize the native cursor's player identity from the actual builder, retaining server authority and exact-item selection. Exercise complete construction in SP and the server path, not just the constructor/recipe. Cover BuildCheat on/off, cancellation, invalid placement, exact item consumption and carried condition; failures must not consume an item or leave an orphan object. Current vanilla create skips performCurrentRecipe under BuildCheat, so its interaction with OMHTT recovery callbacks also needs explicit verification before declaring the one-field correction sufficient. No additional cheat-mode failure is claimed as reproduced yet.

## Wall alignment

Owner GIF establishes the visible defect. TetherMount resolves the backing wall and outward launch position separately from the generated panel artwork. The tile builder currently uses per-facing texture offsets `(63,32),(-63,32),(0,0),(0,0)`. Geometry fixtures establish wall support/firing directions, not sprite placement or preview alignment.

Proposed correction: derive/check the preview and placed panel against the same canonical wall edge, preserving the four outward directions and white developer-art restriction. Verify all four faces, native and player-built walls, and the cable launch point. Exact replacement texture offsets require projection/render verification; do not present guessed offsets as proven. No damage, recipe, timing or trigger behavior changes are proposed.

## Battery spectrum proposal

Current head rating already uses loaded Sandbox values through TurretStats.resolve with no installed modules. It estimates continuous firing/reload consumption in percentage points of a full battery per real, unpaused hour. Existing cutoffs are Low below 5, Medium from 5 to below 15, High from 15. Preserve that head-only comparison and those two existing boundaries; do not silently include installed modules or Siphon.

Proposed seven absolute bands reuse the exact ordered TurretRarity OMH palette, without using loot-rarity names as consumption labels:

| Label | OMH color (RGB) | Full battery percentage points / real hour |
| --- | --- | --- |
| Minimal | Blue (130,174,255) | More than 0, below 1 |
| Very Low | Cyan (115,204,255) | 1 to below 2.5 |
| Low | Green (89,230,102) | 2.5 to below 5 |
| Medium | Yellow (255,250,77) | 5 to below 15 |
| High | Orange (255,148,51) | 15 to below 30 |
| Very High | Red (255,46,46) | 30 to below 60 |
| Extreme | Purple (66,13,130) | 60 or more |

Zero drain displays neutral `None`. Fixed thresholds allow applied Sandbox consumption changes to move ratings up/down; unused bands at default settings are fine. Do not rebalance heads, rarity, loot weights or module surcharges to populate bands. Purple-on-dark readability needs rendered verification. These labels/thresholds are proposals, not selected balance.

## Choices / next checkpoint

- **1A (recommended):** next corrective patch includes shared placement correction, four-face wall alignment and the seven fixed battery bands above.
- **1B:** correct placement/alignment first; defer the battery-spectrum expansion.

Neither option selected yet. No gameplay edits, version bump, installed-package changes, new validation-pass claim or Workshop upload this audit. Update the failed owner-test record and mirror documentation under C108/C119. Decision needed.


## C373 - approved corrective build (2026-10-20)

**0.2.59.1 / C373 installed (2026-10-20).** Approved placement/wall corrections, Rotary Blades x2 / Lobber x1.5, seven consumption bands, owner Performance icons and five native module categories are installed. **26,133 assertions**, 84 native construction cases, write/restart and all three package startup checks pass. Immutable `test/v0.2.59.1` / `810c5768f09c93edb696435a91e78f290f881fb5`; all **322 source and 422 tagged/package/install/archive files** match, with both 0.2.59 backups verified. [Patch](PATCH_v0.2.59.1.md) / [Owner test](TEST_v0.2.59.1.md) / [Release evidence](../diagnostics/v0.2.59.1/local-release.json). SP/server Lua branches use native objects with synthetic square lookup; rendered/connected acceptance remains pending. C108 development mirror uses the existing branch/draft PR; no merge, LootLab deployment or Workshop upload. **Test now** after restart.
