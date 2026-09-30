# Owner test review: 0.2.17, 2026-09-30

Captured diagnostics/captures/20260930-183948-1930. Console confirms loaded 0.2.17, with 21 effective-stat events and 137 fire-result/search events. Capacity 200/8, modified speed, damage 49 and range changes are observed. No OMHTT exception identified in the captured console; this is not full feature acceptance. One pickup-start event does not prove completed pickup/save/reload. User reports test complete with the issues below.

## Follow-up scope

- Owner now wants OMH: T&T - Traps / Turrets as parent pages, with individual defense headings inside. Retain stable saved keys. Logical group order: General, Traps, Turrets, Automation, Modules, Loot, Debug. Debug last within this mod, without reordering other mods. Existing script declares Debug before most turret settings; explicit ordering needs correction.
- Screenshot shows disconnected head above a shallow base. Prior FloorOverlay workaround fixed head hiding but did not prove a coherent assembled silhouette. Correct placeholder base depth/height and head pivot as a pair; do not repeatedly offset only one or create final art.
- Show eight ordinary module slots simultaneously, extras disabled until Capacity activates them. Preserve access beyond eight when Sandbox raises limits through scrolling/additional rows; remove default four-slot pagination.
- Brief neutral brightness feedback when the Manage result/reason text changes. Do not flash every refresh or make normal messages red. Horde Night OMH_DifficultyUI uses timestamp-driven change flashing; apply an inexpensive localized equivalent, without changing sibling code.
- Reported manual-fire hitch. PrototypeCombat.candidates is synchronous; manual fire performs targeting and impact work in one call. Automation has budgeted scans but its final Combat.fire still scans candidates before using its known target. Reuse incremental targeting, avoid redundant target scans, and measure scan/commit/effect time plus queue latency. Preserve one pending request, cancellation, shot-time validation and exact resource consumption. Do not split damage and resource commit into inconsistent partial transactions. Current logs lack frame-duration instrumentation; the hitch cause is not proven.
- Inventory Install is feasible as a shortcut into existing ISBuildIsoEntity placement. Native ISEntityBuildMenu.onBuildEntity constructs the cursor and calls getCell():setDrag. Bind the exact selected packed item, retain rotation, normal approach/action, collision validation, cancellation and single consumption. No need to convert to vanilla furniture or change crafting recipes. Still requires implementation/native proof.
- Remote placement: installed ISBuildingObject.tryBuild explicitly uses ISBuildMenu.cheat OR self:walkTo. ISBuildIsoEntity.walkTo uses native adjacent approach. Build cheat was recommended for the test and can bypass walking, but capture does not log that flag. Verify cheat-off behavior and add placement diagnostics for cheat mode/player distance/approach; do not label expected cheat behavior a confirmed mod bug.

## Remaining content and sequence

CONTENT_AND_BALANCE.md and ROADMAP.md retain bed spikes/punji, barbed barricades, concertina, Poke Floor, signals/sensors and later integrations. They remain scheduled rather than implemented. User approved moving a supported-firearm mount prototype ahead of multiplayer; resolve this usability/performance follow-up and held SP checks first, then prove pistol/pump-shotgun/bolt-action mechanisms on the universal base. General gun compatibility is a goal, not current coverage.

No gameplay patch in this review. Next build should combine a concise owner test rather than require repeating 0.2.17 unchanged.
