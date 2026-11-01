# C542: light ownership and multiplayer contact corrections

The owner selected C541 **1A** on 2026-11-01, then explicitly required replacing defective mechanisms, keeping the code understandable and preserving the ability to add custom heads. This authorizes the T&T correction, not modification of Multiplayer Fast Forwarding, native game behavior or sibling projects.

## Final implementation

- `TurretStateView` owns nearby world lights from loaded turret state. Drawing a model no longer creates, refreshes or expires its light. The existing renderer registers its shared presentation entry; a bounded cursor processes at most64 entries or1ms every50ms. Unload, disabled preferences, distance and power state release native lights. Empty warnings share their existing fade phase with the marker.
- `TurretRenderer` draws base indicators using native geometry visibility (`isCouldSee`), independent of facing (`isCanSee`). Head visibility and normal wall/floor occlusion remain native. A stable pause holds client aiming; resume waits for a fresh motor snapshot and resets interpolation timing rather than extrapolating through the paused interval.
- `TurretRotary` validates owner observation freshness independently of scan creation time. Native/unowned contacts retain the short scan-age guard. One pending contact per victim prevents duplicates; success commits its pass and triggers module effects, while rejection restores the previous pass/observation within the existing freshness limit. There is no new retry queue. Contact sounds occur after positive damage, not after failed admission. Summary counters distinguish applied and rejected rotary contacts.
- Rotary lane distance, scan footprint, angular sector and sound now consume the resolved profile/definition. The current two-tile Bat/Blades defaults are unchanged. Configured cones are respected rather than being clipped to a fixed45-degree half-sector.
- `TetherServer` tests whether a reported position intersects the dart lane before consuming the existing contact-scan allowance. An off-lane actor in the same packet can no longer suppress the arriving in-lane actor. Reset, obstruction, permissions, server ownership and damage protocol remain intact. Direct signals honor stable pause. Attachment snapshots use the shared position reader. Bounded detection diagnostics distinguish clear/blocked/filtered/ready transitions.
- `TetherLane` uses the existing owner-aware stance reader for zombies. Stale server floor flags no longer hide a standing owner-controlled zombie; landed/recovering zombies do not obstruct the lane. Unknown moving-object types are still ignored.

No new network command, persistent schema, dependency or head-specific workaround was introduced. Five existing gameplay files own these changes; Foundation and mod.info only carry the version.

## Custom-head boundary

The current shared head catalog is `TurretHeads.definitions`, resolved into `TurretStats` and `TurretModules.profile`. A new head using an existing supported behavior should supply its definition, item/model and compatibility data; it should not copy light lifecycle, owner reports or transaction bookkeeping. Use a unique definition key because the existing catalog cache is keyed by that value.

This patch verifies a custom three-tile rotary scan and90/180/270-degree contact cones. It does not claim that arbitrary new weapon behaviors are already plug-and-play: projectile-family dispatch, player injury behavior, renderer geometry and catalog/module compatibility still need explicit integration for a genuinely new behavior. A general plugin framework is outside this corrective patch.

## Proof and limits

Production-function regression tests cover owner observations aged0/75/150/225/250ms with a300ms-old scan, pending/rejected/applied damage, no duplicate module effects, expired/prone exclusions, configured rotary reach/cones, same-packet Tether approaches, owner/native stance disagreement, reset and stable pause. Visual tests cover turning away versus wall occlusion, no light expiry without drawing, unload/preference cleanup,160 tracked lights with64-entry slices, and pause/resume interpolation. Existing rotary tests cover delayed snapshots, cone reversal, missing packets, stops and restarts.

Four frozen old-code controls fail their named assertions: fresh rotary contact, same-packet Tether activation, standing owner state, and marker visibility. They are kept locally under diagnostics; sanitized results are in the verification evidence. These controls prevent a passing test that never exercised the old defect.

World, player, network and UI objects in Kahlua are test doubles. Native startup/persistence/package probes have no connected clients and do not render GPU output. They do not establish live smoothness or prove every historical Tether miss had the reproduced cause. The shared position gate still rejects implausible native/owner disagreement; it was not loosened to mask missing reports.

The C541 server-wide pause oscillation remains unresolved outside this patch. T&T now freezes the tested animation and direct Tether paths when given a stable pause signal; it cannot guarantee that other mods or native simulation stop while the server clock oscillates. No MPFF edits were made.

## Release baseline

The owner publisher confirmed0.2.71.6 on Workshop item3828638252. The exact published changelog matches the prior working draft, so0.2.71.7 starts the next cumulative draft. [Receipt evidence](evidence/c542-upload-baseline.json). Existing owner edits in AGENTS.md, README.md, AMMO_UI_C446.md and RELEASE.md are preserved and excluded from this patch's commits.

Verification and delivery status: [test record](TEST_v0.2.71.7.md).
