# 0.2.48 - Focused pack audio and defaults test

## Automated evidence

- 16,166 Kahlua assertions; 117 Lua/translation files compile; 216 source / 264 packaged files validate.
- Seven native non-spatial UI sound definitions parse; seven PCM files return native FMOD handles and stop successfully (muted probe). Pack fixtures cover all seven highest actual reward choices, exactly one reveal cue, replacement/Collect cleanup, early collection and no catch-up bursts.
- Pack render probe: 300 frames, zero new items/text wraps; existing bounded tick scheduling is unchanged. No new protected calls, events or per-tick allocations in changed shipped Lua.
- 83 API/page tests pass, including old-tab baseline compatibility, preservation of weights/anchors and rejection of malformed/missing fields. Model/default/tier tests pass.
- Edge verifies real drag/drop, exact seven-tier colors, custom weights, confirmation/reload persistence, exported Sandbox settings, saved tuning, reset, desktop/mobile bounds and zero page errors.
- Traps-only, Turrets-only and combined package startup all pass on native 42.21.0. Native write/read persistence passes in fresh processes; defaults, rarity-linked battery costs, all seven sound bindings and real pack reward/loot handling verify.
- LootLab deployed as Worker 1007244f-ad66-4416-bede-2f2f64063abe. Production bundle, protected routes and public endpoints verified. No account data writes.
- Installed from immutable test/v0.2.48 / 303ee3da684de23b695cb270a3919039c6a86d9c. All 216 source and 264 tagged/packaged/installed/archived files match; both 0.2.47.4 backups verify. [Evidence](../diagnostics/v0.2.48/local-release.json). Owner audible/rendered acceptance pending.

The full-retention model estimates 15.1% five-plus-component hauls among successful containers with the approved weights. This is a conditional simulator result, not an in-game spawn guarantee. Existing saves are not silently retuned.

Initial test runs caught stale expectations for the previous loot/power defaults and the standalone audio harness's missing UI emitter initialization. Those fixture issues were corrected; final native write/read and Lua runs pass. Native engine startup warnings are not treated as owner-client acceptance.

## Short owner test

1. Restart and confirm **0.2.48**. Use a fresh test world's default settings for the new weights.
2. Check Autoloader, Enhanced Firing, Enhanced Detection and Synergy show **Mythic**. LootLab's same weights should match.
3. Open a few Module Packs: ticking, selection and one rarity sound at the stop; the sound should match the rarest reward. Report volume/timing issues.
4. Collect during a sound, then open another pack. No old sound should linger; all three rewards should remain. Early Collect should also keep all three.

Report completion/issues and I will inspect console.txt. No grinding for every rarity or repeat turret stress test is requested; deterministic native tests cover all seven sound bindings.
