# Completed 0.1.4 owner test review

Reviewed 2026-09-26. Owner requested console.txt review after completing the test. This turn records evidence and confirmed design direction; it changes no runtime files or installed package. Status: **Wait for a patch** for the requested shove-style reaction and barrier retaliation.

Evidence: [captured console](../../diagnostics/captures/20260926-010650-8729/console.txt), [OMHTT trace](../../diagnostics/captures/20260926-010650-8729/omhtt.log), [capture hash](../../diagnostics/captures/20260926-010650-8729/capture.json), [extracted metrics](../../diagnostics/captures/20260926-010650-8729/review-metrics.json).

## Observed outcomes

| Check | Evidence | Limit |
| --- | --- | --- |
| Loaded build | One SP session loads `0.1.4-p1combat`; translation audit checks 14 keys, missing 0 | No connected multiplayer evidence |
| Firing | 26 successful shots across four turrets; 30 attempts include two NoTarget and two Empty results | No shot-caused death recorded |
| Knockdown | Eight native knockdown requests; all eight have a subsequent observed on-floor state; three chance misses; fifteen already-down exclusions | This build requests physics where available; the newly preferred shove-style-only reaction is not installed |
| Actual reactions | Logged StaggerBackState, ZombieRagdollOnGroundState, ZombieFallDownState and ZombieOnGroundState; 78 delayed samples | Samples from already-down victims cannot establish that this shot caused their prior fall; no displacement measurement |
| Heading / texture repair | Ten distinct shot headings, including 9/12/13/14/15; no negative headings or missing device textures in emitted diagnostics | Not all sixteen headings exercised by this player run; old-save migration not exercised |
| Texture readiness | All 62 queued marker checks report ready after 100-119 ms; 15 immediate object snapshots initially pending | This proves ready textures and redraw requests, not every final screen pixel |
| Impact presentation | All 26 shots queue an impact and receive a first-render callback | Callback evidence is not an owner screenshot |
| Cadence | Fastest consecutive successful shots from one turret: 1,449 ms | No Cooling rejection or attempt at the one-second boundary; exact boundary remains harness evidence |
| Barrier destruction | `test-7` reaches native HP 0 and is retired through native removal; `test-9` ends at HP 11 | Retaliation is still absent; destruction is not a disappearing turret |
| Damage | Every direct hit reduces health by approximately 0.0375 native units; tiny splash affects at most three secondary targets | Damage remains below the 3-5 reference-hit target; zombie toughness varies |
| Errors / shutdown | No OMHTT exception or stack trace; no suppressed diagnostics; GlobalModData save and GameThread exit recorded | Existing vanilla startup warnings and PZ Optimizer access warning remain; no subsequent reload in this capture |

Do not mark Phase 1 complete: death/loot, reload/unload persistence, per-thump retaliation, exact live cadence boundary, connected MP and density performance remain unresolved.

## Pixel Strike Indicator scale

Read-only inspection located Workshop item `3793657917`, mod ID `PixelStrikeIndicator`, installed mod version `42.20.99`. Source is under `C:/Program Files (x86)/Steam/steamapps/workshop/content/108600/3793657917/mods/PixelStrikeIndicator/42/media/lua/client/PixelStrikeIndicator/`.

- `PSI_Popups.lua`, `onWeaponHitCharacter`: default damage popup uses the supplied weapon-hit damage multiplied by `cfg.scale`. Actual-health mode queues a before/after measurement through `noteHit` / `settleHits`.
- `PSI_HealthBars.lua`: health bars use current HP divided by recorded full HP; numeric readout rounds that ratio multiplied by 100. It is a percentage, not the same unit as floating damage.
- `PSI_Options.lua`, `resolve`: applies player scale capped by server scale, and the actual-health option. Saved `C:/Users/bandi/Zomboid/Lua/ModOptions.ini` has Scale=100 and TrueDamage=false. These are saved settings, not a live inspection of the effective Lua configuration.
- With scale 100 and actual-health mode, this run's 0.0375 native loss corresponds to 3.75 before display rounding. A desired actual loss of 20 on that scale would be 0.20 native HP, not necessarily 20% of a zombie's health bar.
- Current OMHTT direct `hitConsequences` does not emit the `OnWeaponHitCharacter` event consumed by PSI's hit popups. Health bars can still reflect HP changes, but potato/barrier floating damage numbers are not yet proven compatible. A supported presentation integration must not forge a broad weapon-hit event that triggers unrelated XP/combat listeners.

Recommendation for future balancing: use actual health lost with scale 100 and log before/after native HP. Keep this an optional display aid; do not make Pixel Strike Indicator a dependency or change its files/settings. The owner-confirmed 20-per-thump value still needs its implementation to state damage units explicitly.

## Confirmed direction since this build

The owner wants a modest backward impact and prefers the native shove-style stumble-then-fall for potato knockdowns over ragdolls. Preserve target recovery protection and the global ragdoll option; this is a per-hit behavior change still to implement. Barrier test damage is 20 per actual thump, so the offered once-per-second contact approximation is not the selected behavior. Reliable individual-strike detection remains the blocker. Final artwork remains owner-sourced without AI.
