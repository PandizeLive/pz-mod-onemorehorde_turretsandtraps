# C518 - Child projectile identity and timing

Owner reports Splitter/Fragment timing is wrong and children should reproduce the original projectile: potatoes, spears, explosives, etc. Overall presentation and Tether are better, but Tether still feels late. This is partial improvement, not complete multiplayer acceptance. No new gameplay patch is implemented in this checkpoint.

Owner then adds that rotary turrets are very unsmooth. Include Rotary Bat and Blades in the same presentation correction.

## Confirmed findings

- `TurretVolley.ray` gives travel speed and a Launch event to Ballista children, but explicitly excludes Fragment. Potato Splitter/Fragment and Ballista Fragment therefore have no travel clock or projectile launch. `V.finish` emits their completed paths with `firearm=true`; `PrototypeEffects` renders those as bullet tracers.
- `V.fragment` starts every ordinary fragment group with a fixed 250 ms wait. Completed rays can also wait for the rest of their group before the Volley event is emitted. This combines delayed presentation with missing physical travel; correcting only the tracer color would leave the timing defect.
- Ballista Splitter already launches spear-style projectiles. Arc has its own electrical path and deliberate chain spacing. Neither should be replaced with generic potato/bullet behavior.
- Lobber has actual child flight/fuse jobs, separate from ordinary Fragment: parent/side projectiles fly, land and fuse; mini children wait 250 ms, travel, then use their 500 ms fuse. The client currently distinguishes only spear versus a generic brown rectangle for non-firearm projectiles, so grenade identity is not properly represented. This requires carrying the source ammunition identity through presentation. Existing explosive payload, radius, fuse, damage and lineage rules must remain separate from visual identity.
- Tether's active cycle now advances per tick within its budget and publishes phase changes immediately, with 100 ms active snapshots between transitions. The current local log cannot assign the remaining perceived delay to detection, transport, obstruction, rendering or recovery. Do not claim another confirmed Tether root cause from the report alone.
- Rotary snapshots are normally gated at 250 ms, while client extrapolation stops at a snapshot age of 250 ms. Network transit therefore consumes that entire safety margin; between arrivals the displayed rotation freezes, then the renderer directly applies the next predicted value without correction blending. Actual production-function replay at 180 degrees/second and 100 ms transit shows a frozen interval followed by an 18-degree jump. This is a deterministic code-level defect, not proof of the exact connection timing in the owner's session. Preserve authoritative sweeps and stroke limits while making the visual clock continuous and smoothly reconciling new snapshots; test starts/stops, cone reversal, 360-degree rotation and packet gaps.

## Evidence

The captured local console loads **0.2.70.11**. It contains no retained detailed projectile-effect events, so it cannot establish a per-child or Tether contact-to-render delay. Capture and summary are in ignored `diagnostics/c518`; sanitized summary is [here](evidence/c518-findings.json).

`tools/tests/child_presentation_c518.lua` exercises actual `TurretVolley` functions with intercepted presentation output and `TurretAimView.rotary`. Sixteen diagnostic assertions reproduce Potato Splitter/Fragment and Ballista Fragment as terminal firearm volleys without flight, verify Ballista Splitter already emits a spear Launch, verify the explicit Fragment wait, and reproduce the rotary freeze/jump. The current complete harness plus this optional audit passes **40,417 assertions** (a different optional audit from the previous 40,498 run). This is a successful reproduction of faulty behavior, not a correction or connected visual pass. The first diagnostic attempt used an unavailable `assert` global; rerunning with the harness's `check` helper passes. No shipped code or packages changed.

## Proposed patch

**1A - Complete child-projectile correction (recommended).** Use a shared projectile description derived from the firing head/ammunition for original, Splitter and Fragment paths. Preserve potatoes, spear orientation, explosive identity, Arc electricity and firearm tracers. Start Splitter children on the original launch timeline; start Fragment children from the impact location, replacing the extra fixed 250 ms fragment startup wait with actual travel time. Preserve explosive fuses, Arc chain spacing, terminal-fragment rules, damage/costs, victim exclusions and Synergy eligibility. Match sound/impact timing to the same lifecycle. Trace Tether contact, launch send/receive and first draw before changing its remaining timing.

**1B - Projectile identity only.** Correct copied visuals now and leave the confirmed scheduling defects for a later patch. Not recommended because appearance alone will not fix the reported timing.

Option 1A also includes both rotary heads' continuous visual motion and snapshot reconciliation. Before packaging, reproduce the current failures and show the replacement passes across Potato, Ballista, Lobber ammunition families, Arc, Scrapshot and firearm Splitter/Fragment paths, including mixed modules, packet delay/reordering and save/reload. Keep server damage/death/Horde/XP authority and bounded scheduling. Connected rendered acceptance remains a separate owner check.

High reasoning is appropriate for this multi-path timing correction; likely more than 25 minutes including native checks, so Fast is recommended if available. **Decision needed.**
