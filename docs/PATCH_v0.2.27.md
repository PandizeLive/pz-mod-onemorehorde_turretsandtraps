# 0.2.27 — range, noise and firearm compatibility

C78, owner approved 2026-10-04. Single-player only.

## Changes

- Engagement range uses the native slider. Max follows current head/modules; numeric caps persist and never rescale accuracy.
- Low-fence and spike-barrier movement collision no longer blocks firing. Closed doors, windows, solid walls/tall opaque fences, unloaded paths and diagonal wall corners remain blocking; open doors allow shots.
- Maximum-range defaults: 60 percent ordinary, 80 percent identified precision rifles, including semi-auto-only rifles. Sandbox exposes both values. Native point-blank tuning anchors a smooth closer-is-easier curve. Accuracy modules improve it; the accuracy multiplier still lowers deliberate low-accuracy setups.
- Classification requires a two-handed, single-projectile rifle mechanism, no supported Auto/Burst modes, plus original range >=30 or manual cycling. No localized-name check, no strict >40 cutoff, no promotion from Range modules/attachments. An explicit full-type override table remains available for unusual mod metadata. The pre-existing 50-tile firearm runtime ceiling remains.
- Selected turrets show an amber full-circle zombie-hearing ring, including Suppression and potato eight-tile hearing. Local Mod Options controls visibility. It represents emitted AI sound radius, not exact audible volume or wall attenuation.
- One rotating 3ms combat work budget covers bounded aiming, searches, automated firing, feeding/configuration, pending potato hits and reaction diagnostics. Native calls can exceed a budget before returning; rendering is outside it.
- Cooldown, reload, mechanical cycling and potato flight use active real-time timing. Pause/offline time does not grant cycle progress; fast-forward does not multiply rate; long stalls contribute at most 100ms per tick and never replay accumulated shots. Saved remaining cycle time rebases when a new process resumes it.

## Verification

Existing plus new Kahlua fixtures cover classification, 60/80 endpoints, monotonic distance behavior, shared worker fairness, pause/time jumps, restored timer remainder and exact ammo conservation. Native stock 42.21 smoke covers real weapon fields, script/translation loading and world/item persistence. Isolated Firearms B42 (42-5.6.0) loaded on stock 42.21 checks 51 conventional guns and conserves 153 fired rounds; only the two cap guns are excluded. This is mechanism/classification evidence, not GPU or complete-modpack acceptance. Final counts and installation evidence are recorded in RELEASE.md.

References: installed HandWeapon getters and item scripts; current IsoGridSquare.testVisionAdjacent bytecode; vanilla RadioCom/ISUIRadio/ISSliderPanel.lua; PZAPI/ModOptions.lua; Horde Night OMH_ClientOptions.lua. Alex's PZ skills reviewed. No sibling code, recipe, loot or website changes.

## Quick combined test

The remaining checks were carried into the [single next-patch combined test](checkpoints/R1_PACKAGE_SPLIT.md#combined-owner-test-for-the-next-playable-build) on 2026-10-06. This historical checklist is not an additional requested test or evidence of acceptance.

1. Restart and confirm **0.2.27**. Use the existing supplied potato/M16/rifle turrets, or add matching ammo, required magazine, charged battery, Detection and Firing. Leave build cheat on if useful.
2. Drag Engagement range down, then to **Max**. Blue coverage and target eligibility should follow immediately. Pick up/redeploy or save/reload with a reduced cap; it should remain selected.
3. Select a turret: amber shows noise, blue shows engagement. Add Suppression and check amber shrinks; toggle **Mod Options → OMH: Turrets & Traps → Show noise radius** and verify the preference survives restart.
4. Put targets across a low fence/spike barrier, then behind a solid wall/closed door. Fences should permit shots; solid obstructions should prevent shots and ammo use. Check open doors too.
5. Compare a sustained sample at maximum range: ordinary firearms should land roughly 60 percent, precision/semi-auto rifles roughly 80 percent before Accuracy bonuses. Use Firearms B42 in an isolated test save for a rifle and automatic gun; actual random samples vary.
6. Run several mixed turrets, pause during reload, resume, then save/reload. No ammo creation, free completed reload or catch-up burst; report stutters, visual issues or errors. Finish with **Test Complete** for console review.

Do not enable Firearms B42 alongside an incompatible firearm overhaul. The normal enabled-mod selection is unchanged. Multiplayer remains disabled; future specialty heads and recipes are separate checkpoints.
