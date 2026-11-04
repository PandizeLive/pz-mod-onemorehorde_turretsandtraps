# C537: Lobber, physical-projectile targeting and loading retest

2026-10-31. Investigation only; no gameplay, package, install, saved-setting, sibling or live-server changes.

## Owner report

Lobber does not scan visually and seems to engage at about eight tiles; Ballista and Potato fire at no visible target; Scrapshot loading is too slow and Ballista should be checked too. Owner requests quick loading with slower rates for higher DPS, the native Ballista spear, and a module audit. Splitter looks improved, not fully accepted. No evidence currently warrants a new world.

## Evidence and limits

- Current local console and read-only SFTP server capture both identify 0.2.71.4. Client reports four native `SyncItemModDataPacket.parse` null-container exceptions. No post-startup server runtime exceptions were found by the existing analyzer. The responsible item/sender is not identified by these traces; do not label them proven T&T faults or dismiss them.
- There are 74 client missing-actor combat rejections involving four distinct IDs. None appears in the captured creation-index messages. All rejections have an empty deferred creation queue; native client actor-list size is 19-27. This does NOT establish whether the missing identities exist in that list, were unloaded, or were never received. C536's late-ID repair is therefore insufficient evidence that the connected target lifecycle is correct.
- `Damage.available` permits retry one second after an owner rejection. Thus the current mechanism can spend ammunition and present another shot at the same server actor without a new positive observation from its owner. This is a confirmed repeat-attempt weakness, consistent with the reported empty-target firing; the capture lacks the shot-by-shot linkage needed to attribute every displayed projectile.
- `TurretRenderer.animate` takes the client interpolation branch before the SP idle-sweep branch. Identical no-target state rotates in SP and remains still in MP. A production-function replay reproduces both outcomes. This affects ordinary heads generally, not just Lobber. Detection itself is independent of the cosmetic sweep.
- Saved Lobber range is 18, and effective client stats also report 18. Production eligibility checks accept 6, 8, 12 and 18 tiles and reject 5 and 19 with a 360-degree profile. Default minimum is six. An eight-tile maximum was NOT reproduced. Selected engagement range, actual module loadout/cone, obstacles, actor presence and target acquisition still need correlated evidence. Do not remove the six-tile minimum or reset saves as an assumed fix.
- Turret Detailed Logging is false in captured Testing Sandbox settings. Summary counts cannot establish all module triggers or exact acquisition/shot/target relationships.
- Installed native scripts give Scrap Metal weight 1 and Crafted Spear weight 2. Production server transfer duration is 50 and 100 native action units respectively, compared with five for Makeshift Bomb. Scrap and spears are excluded from the explicit fast batch policy. Inventory weight should stay unchanged when loading speed is corrected.
- Ballista presentation currently draws a short plain line for a spear. The installed game supplies `SpearCrafted` model mesh `weapons/2handed/SpearCrafted` and the native `SpearStick` item icon. Reuse the actual native spear asset and verify orientation/contact for primary, Splitter and Fragment; do not introduce a second custom spear.
- Additional module-path finding: `TurretProc.inside` uses the owner-position-derived square for visibility but raw server X/Y for its radius check. The production replay both excludes an actor currently observed at the effect center and includes one observed outside its radius. Lobber falloff and proc-origin coordinates also still read raw actor X/Y in `TurretOrdnance.step`. Include these shared area-effect paths in the correction; exact live contribution is unmeasured.

## Verification

Current Kahlua suite plus 17 focused diagnostic assertions pass: 44,375 assertions in this invocation. Existing matrix covers ten head paths, 360 compatibility cells, 339 individual module hit cases, stacked effects and delayed contact cases. These are test-double checks with native serialization, not a connected all-module acceptance test. Initial audit attempt stopped because its standalone fixture omitted CharacterTrait; corrected fixture rerun passed. No product code changed to make the reproduction pass.

[Sanitized evidence and hashes](evidence/c537-findings.json). Captures and executable diagnostic replay remain in ignored `diagnostics/c537`; raw player/server logs are not mirrored.

## Recommended corrective scope (not yet patch-approved)

1A: Complete follow-up. Restore purely cosmetic client idle scanning from replicated state; fix actor confirmation/rejection lifecycle at targeting and commit, not by hiding projectiles or scanning all zombies per shot; diagnose Lobber acquisition with actual range/cone/owner-observation evidence; align remaining Lobber falloff/proc coordinates; check the native container errors; reuse native spear presentation; add consistent fast ammo loading.

1B: Restrict the next patch to aiming/target lifecycle and defer loading and spear presentation. Not recommended: the owner has requested the full follow-up.

For loading, recommend fixed family rates based on unmodified head DPS, rather than live module DPS. Live-DPS timing would let a player remove modules before loading and would change during an action. Proposed normal-character targets: approximately 0.5 seconds per Scrap Metal and 0.25 seconds per spear, bounded same-type batches, with native Dexterous/All Thumbs modifiers retained. These are proposed timings, not implemented or measured new behavior; validate native duration conversion and both transfer routes before choosing exact action units. Scrapshot's higher baseline DPS justifies slower loading than Ballista; this is not a strict linear DPS formula. Preserve native item weight and exact-item authority.

Required checks: owner actor absent/reappearing, unloaded/recycled identities, acquisition outside eight tiles, moving targets, fixed forward fire, observer visuals, primary/stacked Splitter/Fragment contacts, Lobber proc/falloff positions, full-stack transfer and interruption, native spear orientation, and installed-package parity. Avoid claiming connected proof from test doubles alone.

**Decision needed:** approve 1A full corrective scope or 1B narrower follow-up. Existing world retained; no new build delivered.


## C538 approval and implementation

Owner selected **1A**. The complete corrective scope is implemented in [C538](TARGETING_C538.md); see its evidence and explicit remaining limits. No native Horde Manager, sibling project or live server change.
