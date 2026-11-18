# 0.2.31 owner findings and next patch scope

2026-10-07. Owner ran the shortened combined test and reported the findings below. This is partial acceptance with failures, not a passed test. Installed/source gameplay remains 0.2.31; no patch was installed during the live stress run.

## Requested changes

- Put Bed Spikes and Barbed Panel options inside the existing Traps Sandbox page, with readable groups instead of separate pages.
- Use the player-facing name **Barbed Panel** consistently. Unify construction, item and context-menu names; remove visible internal OMHTT identifiers. Proposed convention: OMH: Traps / OMH: Turrets category labels, plain device names in lists, Craft/Place action verbs, Install reserved for turret components. Preserve internal identity keys.
- Allow Bed Spikes beside a fence carrying a Barbed Panel when their floor footprint is genuinely clear. Do not allow a bed to straddle a blocking fence or occupy furniture/other defenses.
- Make player traversal behave like foliage instead of only forcing its animation. Walking remains safe; sprinting may trip, and an actual fall onto spikes causes an appropriate body-part injury. Exact player trip/injury tuning is not yet agreed.
- Fix zombies remaining down after falling on beds. Preserve one damage hit per new fall and the five-second recovery guard; do not substitute repeated damage or repeatedly force stand-up states.
- Increase zombie bed-trip chance to **40%** instead of 20%, approved by the owner's subsequent **2B** answer for both tiers. Potato knockdown **40%** is separately requested, reducing the current 70% default. Preserve the distinction between base chance and module bonuses/saved Sandbox overrides. Player sprint-trip behavior/injury tuning remains under discussion.
- Reuse one bed tile texture across its 1x2 footprint and two panel textures for the two axes, while retaining four-way logical placement. Artwork count does not require eliminating engine sprite identities, health/part metadata or exposed-side selection. Final art remains owner-provided.

## Placement-flow discussion

Owner asks whether all devices should leave Building and use crafting plus inventory installation. Recommendation: retain native Building placement and normalize its labels first. It already handles rotation, footprint and material placement; moving everything to crafting adds an inventory step and requires an inventory placement entry point while retaining the same world validation. Craft-only is a valid deliberate UX choice, not a performance fix. This choice is pending, and changing recipes/flow is not inferred from asking about it.

Follow-up, 2026-10-07: revise that blanket recommendation after checking the current vanilla files. `generated/recipes/recipes_trapping.txt` crafts portable trap items; `ISInventoryPaneContextMenu.lua` offers Place Trap through `ISTrapMenu.onPlaceTrap`. In contrast, `generated/entities/walls/entity_logwall.txt` defines a construction recipe directly on the world entity. Recommended native-style distinction: craft-and-place portable beds/barriers/turret bases; build/attach backed Barbed Panels on site. Removing a Building entry changes recipe discovery and material-to-item-to-world steps, not collision, rotation capability or combat cost automatically. Placement flow remains undecided.

## Code and installed-game findings

- `BedSpikes.lua:B.clear` rejects every square with any special object. This includes barb frames and constructed edge supports, even when they do not occupy the bed's floor area. This is a concrete overbroad check and a likely cause of the reported fence-side placement failure. Retain actual obstruction, two-tile and between-tile collision validation when correcting it.
- Live startup warns that both `BarbServiceAction.lua` and `BarbMenu.lua` cannot require `OMHTT/BarbService`. Later the menu throws `attempted index: tools of non-table: null` at `BarbMenu.lua:53` (frames 4947 and 5458). The client stores a failed require of a server-folder service module. Correct module availability/loading and add a client startup/menu test; the isolated service tests did not cover this load order.
- `BedPlayer.lua` only sets `OMHTTBedBrush` and applies a per-entry scratch roll. Its animation uses a fixed speed; there is no actual sprint trip or foliage slowdown integration.
- Current installed `IsoPlayer` bytecode confirms the foliage branch reduces sprinting to running, but the forced-trip branch additionally requires `isInTreesNoBush()` or a collapsed fence. Thus native bush movement and spike-specific sprint-trip risk must be distinguished.
- Zombie recovery is not yet diagnosed. Current installed `sprinterTripping.xml` requires `canRagdoll=false` and signals `SprinterTripped` plus `BumpAnimFinished`; the get-up transition and `getUpFromScramble` depend on those flags. The mod currently sets only the bump type. Inspect the full current state/animation path before selecting a correction; these files do not prove which state the owner's stuck zombies occupy.

## Live stress capture

Local evidence: `diagnostics/v0.2.31/owner-stress-20261007/console-start.txt`, `console-end.txt`, `live-window.json`, `sample-analysis.json`, and current installed-game `javap` output. These raw captures remain local diagnostics.

The captured appended window contains 29 diagnostic summaries (sequence 359–387), spanning approximately 142 seconds between first/last summary, 230 launched shots, 58 bed-trip requests and 61 bed-fall hits. No new ERROR/Exception line occurs in that window. Measured firing/effects stages peak at 3 ms, audio at 2 ms, and other recorded component stages at 0–2 ms. The earlier full-session scan also peaks at 3 ms for measured firing/audio operations. This does not measure all frame work, prove absent freezes or turn requested knockdown events into successful knockdowns. No 300–700 ms operation outlier was observed in these stage samples.

The appended log also contains 560 `Set pitch for ToStart` lines; source/cost attribution remains unproven. Do not change native audio behavior based only on this count. Existing earlier barb-menu errors remain real despite the clean live window. No complete client acceptance or performance fix is claimed.

## Next verification

Before a new handoff, reproduce and cover client menu initialization, edge-plus-floor co-placement, complete zombie fall-to-get-up behavior, reversible foliage movement and injury-on-actual-fall. Verify naming/settings and atlas reuse statically. Run the focused affected tests, then package/install only after the active owner run ends. Keep the next owner check short and focused on repaired failures; do not repeat the full old test.

C101 update: owner approved crafting-only placement and the corrective scope. Implemented in [0.2.32](PATCH_v0.2.32.md); [four-step follow-up](TEST_v0.2.32.md) replaces this outstanding checklist. The native knockdown lifecycle and controlled get-up exit are verified, while naturally rendered recovery remains owner acceptance.
