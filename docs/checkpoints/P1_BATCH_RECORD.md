# Phase 1 batch: obstruction, potato and persistence prototypes

Date: 2026-09-25. Package: **0.1.1-p1batch**. Owner authorization: several checkpoints back to back before testing, within roughly twenty minutes. Recommendation given: Medium reasoning with Fast. Status: implementation advances P1C2-P1C4; no Phase 1 checkpoint has player acceptance yet.

## Scope and remaining gates

| Checkpoint | Added | Still required |
| --- | --- | --- |
| P1C2 | Native IsoThumpable barrier configured to block the whole tile, reject traversal/vaulting, accept thumps and native destruction. Aggregate HP loss updates the exact device record. | In-game collision/destruction proof; exact attacker/per-thump damage route. No retaliation is implemented. |
| P1C3 | SP manual potato fire, nearest clear candidate in a bounded local search, ammo/cooldown, sixteen independent cube aim frames, native primary hit request, experimental knockdown and tiny splash with a temporary white-dot pop. | Native hit/corpse/loot and visual proof, reference tuning, multiplayer ownership/death synchronization and two observers. MP firing explicitly refuses requests. |
| P1C4 | Native serialized ammo, shots, next legal shot time and facing; bounded shared scheduler and candidate/effect caps; stale shot rejection. | Real populated save/reload/streaming proof and frame-time/network density measurements. Caps are not measured performance acceptance. |

No recipes, inventory consumption, player targeting, automatic firing, smart controls, faction XP, Horde scoring or Cure simulation were added. Use a disposable world with this mod alone. The SP operator receives native kill attribution during this diagnostic; that is not the planned faction reward system. No sibling source or public listing changed.

## Current engine findings

The installed B42.20.4/PZ Optimizer environment remains the target. Current ThumpState bytecode uses native thump animation events without a per-strike Lua callback; see [capture](../../diagnostics/p1c1/ThumpState.javap.txt). Current methods and vanilla furniture/wall placement scripts were inspected. Historical decompiled code helped locate relevant paths but is not compatibility proof.

Barrier HP deltas can aggregate several attackers and fractional damage. They cannot identify a reliable retaliatory hit. The observer therefore logs `aggregate-health-observation-not-per-thump`; no inferred attacker damage is applied. `syncIsoThumpable` synchronizes lock state rather than arbitrary health, so the manual barrier-health debug mutation is also disabled in MP.

SP primary damage calls native `hitConsequences` with an ephemeral ranged damage carrier and the operator. Native damage multipliers still apply; 0.25 is an experimental input, not a verified four-hit kill. Multiplayer damage remains disabled until the client-owned zombie/death path is proven. Nonfatal tiny splash directly changes SP health; lethal splash uses native hit consequences. Corpse/loot behavior must be observed.

## Prototype limits and tuning

- Four free test rounds; debug refill restores four without resetting cooldown. This is explicitly diagnostic supply, not an inventory feature.
- Cooldown is four in-game minutes (roughly ten real seconds at a one-hour day); fast-forward and day length affect elapsed real time.
- Six-tile range, at most 64 moving-object candidates from a bounded tile area. Nearest means nearest eligible examined candidate when density reaches the cap. Same-floor tile crossing rejects blocked/window/unloaded paths, including diagonal corners; actual occlusion is pending.
- Primary damage input 0.25; experimental 70% knockdown, ten in-game minute shared recovery protection. Splash input 0.001 to at most three neighbors within about one tile; no splash knockdown. These are prototype values, not approved final balance.
- One scheduler visits at most four tracked slots per tick; the existing ledger remains capped at 64 distinct test locations, including removed locations. World-square object density is not separately benchmarked.
- At most eight transient impacts, six dots each, expiring after 650 ms. No saved particle objects. SP viewport zero only; local split-screen effects are unproven.
- The base remains fixed across sixteen pre-rendered head facings from the same authorized white cube model. No final art, texture styling or native articulated 3D integration. No visible projectile flight yet.

## Verification

[Validation log](../../diagnostics/p1batch/validation.log): eight runtime/translation files compiled, 63 assertions passed, native save-table roundtrips passed, 23 native packet serializations passed (largest 379 bytes), 32 package files/41 translation keys checked. Seventeen transparent grayscale sprites passed format/content checks. The world, collision, hit, player, UI and network dispatch objects are doubles; these assertions do not establish native behavior.

Coverage includes original lifecycle/permissions, exact barrier identity and health observation, independent aim, one ammo spend per accepted shot, stale duplicate rejection, persisted cooldown/refill behavior, fail-closed MP fire, shared knockdown recovery, tiny splash, blocked/unloaded paths, and scheduler/candidate/effect caps. Standalone Kahlua lacks supplemental min/max/sort functions, supplied only in the test bootstrap.

The real isolated dedicated server loaded `0.1.1-p1batch` on B42.20.4, reached SERVER STARTED, saved GlobalModData and shut down cleanly. No player connected and no device was instantiated by this smoke. See the [console](../../diagnostics/p1batch/server-restart-console.log). The final marker-repair correction passed repeated automated validation and dedicated smoke. Native gameplay acceptance remains pending.

Installed to `C:/Users/bandi/Zomboid/mods/OneMoreHorde_TurretsAndTraps`; all 32 files were hash-verified and the previous managed installation backed up. [Package manifest](../../diagnostics/p1batch/manifest.json) pins the exact files. Prior P1C1 evidence and archive are retained. Source and archive contain the same package bytes.

## Combined owner test

1. Restart PZ. Enable **OMH: Turrets & Traps - Foundation Test** alone in a disposable Custom Sandbox world, with **OMH: Turrets & Traps > Foundation Test Controls** ON. Confirm the context menu says **0.1.1-p1batch**. Use debug mode if needed to arrange a few zombies safely.
2. Beside clear floor, right-click and place a blocking barrier prototype. Try walking into and vaulting it. Let one zombie, then several, thump it. Inspect native condition loss; expect no retaliation. Record any passage/vault, errors or failure to destroy at zero health.
3. On clear nearby tiles, place two potato prototypes. Inspect each, then reopen its menu to expose potato actions. Turn one head; the other must remain unchanged. Record IDs, positions and any missing/floating/overlapping cube sprites.
4. Put a zombie within six tiles and use **Fire once at nearest visible zombie (SP test)**. Expect one round consumed, head aiming, a tiny white-dot impact, damage and possible knockdown. Immediate repeat should be cooling; replay the previous change request should be stale. Wait four game minutes between accepted shots. Check death, corpse and loot.
5. Try a small cluster, then a target behind a wall/closed doorway/window. Splash should be almost negligible; blocked targets should consume no ammo. Use debug refill as needed; it must not bypass cooldown. Report any targeting through obstacles or repeated knockdown lock.
6. After a shot, record ammo/shot count/facing and quit/reload immediately. Inspect the same IDs and resource state; cooldown follows elapsed game time. Travel about 300 tiles away and return, then inspect again. Remove each device through its menu; replay removal and reload to check no resurrection or unrelated removal.
7. Report results and leave `C:/Users/bandi/Zomboid/console.txt` plus latest `Logs` available for inspection before another run overwrites them. Connected-player dedicated tests remain a separate gate; MP firing should report deferred rather than hurt a zombie.

## Rollback and next work

The installer verifies hashes, backs up the previous managed installation and leaves saves/settings alone. The previous `0.1.0-p1c1` archive is retained; use it with a separate disposable world rather than downgrading a populated batch save. Disable test controls to stop new debug actions; existing devices remain. No production save migration is promised.

Next engine work is the per-thump/attacker feasibility decision and a controlled multiplayer damage experiment. Do not mark P1C2/P1C3 complete or start a full content roster from compilation evidence. Handoff: **Test now** when ready for the combined sequence.
