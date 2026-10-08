# R3C4-R3C7: offensive modules and battery endurance

Planning record under [C81](../DECISIONS.md#c81-offensive-module-planning-and-long-battery-life-2026-10-06), synchronized 2026-10-08. Installed 0.2.34 retains SP-only combat and adds R3C8 starter components; none of this brief's offensive modules is implemented. Final recipes, art and unselected heads retain their approval gates. See [canonical roadmap status](../ROADMAP.md#current-checkpoint-status-and-next-work).

**Next module checkpoint: R3C4 contract and battery baseline.** The documented sequence remains R3C4 -> R3C5 -> R3C6 -> R3C7; it does not require a new head first. The assistant's later suggestion to prioritize Initial Blow/Execute was an unapproved reorder, not missing scope: both were already listed in R3C6. This sync records the distinction without selecting a new gameplay patch.

## Owner direction and working proposals

| Module | Owner direction / discussed role | Remaining decisions and recommendation |
| --- | --- | --- |
| Splitter | One child per stack at 50% original damage; alternate sides for odd stacks, paired sides for even stacks, increasing angles in 15-degree steps | Retain central shot; initially recommend four-stack cap. Additional round per child was recommended, not approved. Define coverage edge, range, pellet budget and persistence before implementation |
| Fragment Module | Five random radial shots from impacted zombie, 20% original damage each; preferred minimum spacing 30 or 45 degrees | Recommend 30 degrees, including wraparound. Recommend one burst at the primary shot's first successful impact per firing cycle, terminal children, exclude origin victim; stacking increases per-fragment damage with a cap rather than fragment count. Angle, range, stacking increment/cap and propagation remain unselected |
| Impact | First bullet of a magazine has a high chance to stumble | Prove actual stumble separately from knockdown. Recommend stacks improve chance, one eligible primary victim, per-victim recovery guard, entitlement stored on head and rearmed by empty reload. Partial reload, chamber, one-round head and expiry rules need concrete agreement |
| Piercing | Discussed lane damage across aligned targets; retained in broadly approved direction | Recommend stackable penetration count, damage attenuation, no wall piercing, deduplicated victims and bounded ordered path checks. Numbers and compatible heads remain proposals |
| Initial Blow | Discussed damage bonus against healthy targets; retained in broadly approved direction | Recommend current-health threshold rather than permanent first-hit history; stackable capped bonus. Threshold/max-health source and interaction order remain proposals |
| Execute | Discussed damage bonus against wounded targets; retained in broadly approved direction | Recommend stackable capped damage rather than unconditional death. Threshold and modifier order remain proposals |

Homing, Bleed and slowing turret effects are excluded. Puddle/tack-bullet damage areas are not scheduled. A spike-canister ground trap is deferred. No rule here replaces existing potato splash, Velocity knockdown or Suppression's approved no-separate-count-cap policy. Explain module incompatibility rather than installing inert items.

Splitter example, excluding unchanged central shot:

| Stacks | Child directions |
| --- | --- |
| 1 | Alternate -15 / +15 degrees |
| 2 | -15 and +15 degrees |
| 3 | Both 15-degree sides plus alternating -30 / +30 degrees |
| 4 | Both 15-degree and both 30-degree sides |

Further pairs continue in 15-degree steps if a larger cap is selected. All children retain the owner's 50% damage direction; do not compound a new 50% reduction for each additional stack. A shotgun branch must have a defined whole-shot damage budget rather than multiplying damage per pellet.

## Battery endurance is a requirement, not a surcharge afterthought

Owner requires module intensity/impact to increase usage while preserving long battery life, rather than draining a battery in a single normal day of use. Exact days/nights and workload have not been selected. Recommend multi-day ordinary operation, with idle/search draw absent or negligible unless a useful separate cost is demonstrated. Sustained maximum-rate firing must be reported separately, not presented as normal usage or guaranteed multi-day endurance.

Current source reference: `sandbox-options.txt` sets PotatoBatteryPercentPerShot to 0.1; `TurretWorld.power` resolves the per-shot fraction and the shot commit subtracts it. This gives approximately 1,000 firing cycles per full battery at that default before new effects, not a measured days-of-life figure. Existing firing consumes real active time, not game-clock-scaled cadence. Saved settings may differ.

R3C4 must measure baseline and agree representative workloads: actual head/cadence, module loadout, firing cycles per horde, idle time, game-day length and starting charge. Propose an endurance target from those figures; do not invent a universal day-to-shot conversion. Compute base drain from desired total cycles, then modest capped effect surcharges; account for increased cadence and multiplicative combinations as well as individual module counts. Do not stack surcharges on today's baseline without recalibration.

Recommend a predictable resolved per-cycle cost charged with ammunition before launch, independent of successful victims; insufficient resources reject the whole firing cycle without partial consumption or free children. Snapshot effects at launch. Validate generator/external-power behavior as well as battery fallback; it is not yet an approved new fuel balance. Preserve saved tuning and document any deliberate migration rather than changing key semantics silently. Manage should make increased cost understandable; do not display a misleading days-remaining estimate without a workload.

## Checkpoints and acceptance

The related [R3C8 starter-component/expansion checkpoint](R3C8_IMPROVISED_EXPANSION.md) is implemented and installed in 0.2.34. C104 independently settles its recipes, two-row eight-column layout, 2/4/8/12/16 fresh totals and saved-setting/item preservation. Those are no longer R3C4 decisions; offensive effect contracts and realistic endurance targets still are. Include the expanded maximum loadouts in R3C7. Empty slots add no battery cost. R3C8 owner acceptance remains in the combined 0.2.34 test.

1. **R3C4 - contract and baseline.** Settle range, compatible heads, stack/target limits, damage ordering, Fragment separation/propagation, Splitter ammunition and Impact reload eligibility. Define source IDs and one damage/death route, no global weapon overrides or mutable zombie speed. Baseline current battery use and agree endurance target before gameplay tuning.
2. **R3C5 - directional children.** Prove geometric rays/ordered candidates against installed game behavior before content. Then implement Splitter and Fragment separately on shared bounded work. Check misses, walls/windows/corners, loaded areas, coverage/collateral, origin-victim exclusion, angular minimum including 360-degree seam, exactly five Fragment rays and saved odd-stack alternation. Persist serializable state; do not let swapping a head replay an entitlement. Agree what happens to committed pending effects on save/unload.
3. **R3C6 - penetration and conditional hits.** Implement each agreed effect in a small slice. Check first-round/chamber/partial reload and single-round edge cases, recovery guard, HP thresholds and native stumble feasibility. Do not silently substitute full knockdown or alter Horde Night zombie movement. Native/custom armor and weapon-script integrations require explicit evidence; metadata admission is not proof of custom hit semantics.
4. **R3C7 - combined acceptance.** Measure no-module, representative and maximum-supported combinations, including rapid-fire firearms, pellet weapons and potato heads where compatible. Compare charge per horde and cycles per battery under defined workloads; normal use must meet the agreed long-life target. Verify refunds/rejections, save/pickup/reload, resources, actual slots, UI, loot/Sandbox, dense rendering plus combat cost, and traps-only absence. R5C1 still gates multiplayer.

Recommended propagation is deliberately finite: primary first impact may produce Fragment; later pierce hits and Splitter children do not; Fragment children cannot Fragment, Split or Pierce. Five paths each piercing three victims would otherwise permit 75 Fragment children from one cycle. Power pricing cannot replace hard work limits. Looser propagation requires a new measured scope decision.

No permanent speed/status mutation, free ammo, recursive child effects, invented sibling reward API or double-counted death. Keep targeting/authority shared with current combat, with separate presentation facts. Do not claim MP from the server-directory location. Native proofs and bounded tests precede one complete 4-8-step owner test per playable combined checkpoint; no player test is requested for these documentation changes.
