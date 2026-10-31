# C425: 0.2.64.3 owner feedback and proposed correction

2026-10-22. Owner reports quiet/thin/abrupt Arc effects, Lever wall misalignment, elevated Tether nail/cable, Controller equipment layout waste, missing installed-module battery total and bare repair requirement names. Requests new Automation artwork and higher rarity drain. This is the pre-patch discussion required by AGENTS.md; no gameplay or installed build change is made in this checkpoint.

## Evidence

- Captured the owner console and installed manifests with `OMH.cmd -Action Capture`: `diagnostics/captures/20261022-213548-2693`. Console confirms 0.2.64.3 SP. Targeted search found no OMHTT exception/stack entries; unrelated font/translation warnings remain. This does not establish rendered acceptance.
- `TurretArcView.lua` reuses the thin Tether cable model, scales all dimensions with segment length, and deletes bursts at 160 ms without fading. `TurretArcAudio.lua` applies .65 firing gain and .12 impact gain. Listening balance remains owner-reported, not a measured in-game loudness result.
- `TetherView.lua` adds `.72 / 2.44949` to both nail and cable height in addition to their .3 mount height. This is a candidate contributor, not a proven sole cause. Compare current native projection/model transforms against the panel sprite anchor before changing it. Lever uses wall-edge mount resolution and separate sprite rendering; validate the preview, placed sprite and active marker on all four faces, including player-built walls. Do not claim another successful alignment fix from geometry tests alone.
- Current 42.21 `Render3DItem` delegates to `WorldItemModelDrawer`; `ItemModelRenderer` contains tint/alpha fields, but the Lua helper exposes no direct alpha argument. A depth-correct blue glow/fade needs native-path verification. Do not silently substitute an always-on-top screen overlay or add dynamic lights per segment.
- `ControlPanelLayout.lua` already allocates approximate halves, but deliberately draws Online/range on a lower row and reserves that height. C426 supersedes the original status-inside-slots proposal: restore Online/range to their original right-side location, as in test/v0.2.62. Split the former battery area into equal battery and expansion-kit widths; do not split the entire Equipment section into two slots. Keep the original status area and stockpile access alongside them, with no added lower status row.
- `TurretBenefits.battery` already computes costs/endurance from effective stats but omits `modulePower`. Add the installed module total and, where applicable, the effective total after Regulator; no probabilistic Siphon discount. Retain the distinction from head base cost and Controller supply.
- `ControlRepairTooltip.lua` emits bare colored material/tool names. Installed English translations include `Tooltip_craft_Needs = Needs` and `Tooltip_NeedWrench = %1 required.`; no exact universal `Required Tool` translation was found. Recommend localized `Required material: Scrap Metal (1)` and `Required tool: Wrench`, existing green/red availability and time, with no added repair costs or inventory-item repair paragraphs.
- Eight Automation PNGs are RGBA **28x29**, unlike the earlier 32x32 sets. Preserve owner pixels/aspect ratio, center in the existing icon area and use the existing effective-rarity cache/hooks. Include neutral fallback and all eight Automation-category item definitions, deriving the mapping from scripts. No loot weight changes or world-wide inventory scans.

## Proposed patch

Make Arc visibly thicker with a bright pale core, blue outer falloff and about 250 ms decay after its initial flash. Keep bounded, world-depth-aware rendering; verify actual native blending before promising the final glow. Start firing audio around twice its present gain, checking headroom, overlap, master volume and Suppression. Retain the approved sample/pitch variation and quieter impacts. Correct shared mount/render anchoring rather than guessing a new isolated offset. Include Controller layout, Automation artwork, battery totals and labelled repair requirements in the same correction.

High reasoning is appropriate for native rendering/placement; Medium is sufficient for the isolated artwork/UI/balance changes. A complete native-verified combined build may exceed 25 minutes; Fast is recommended for that implementation if available.

## Battery decision

Existing costs are additive surcharges: `modulePower = 1 + sum(surcharges) * ModulePowerBonus / 5`, with Regulator reduction afterward. Capacity kits and Regulator remain exempt; broken/incompatible modules remain excluded. At the default Sandbox multiplier, one Mythic **+2.00x** means **3.00x total** base drain. Preserve this existing meaning, rather than treating Epic 1.00x as no cost or Rare .75x as a discount.

| Rarity | Current added drain | Proposed added drain |
| --- | ---: | ---: |
| Abundant | .10x | .15x |
| Common | .15x | .25x |
| Uncommon | .25x | .50x |
| Rare | .50x | .75x |
| Epic | .75x | 1.00x |
| Legendary | 1.00x | 1.50x |
| Mythic | 1.50x | 2.00x |

Owner supplied Rare through Mythic. Lower three are proposals, not selections. **1A (recommended): approve the combined correction with .15/.25/.50 lower tiers. 1B: approve the same correction but retain .10/.15/.25 lower tiers.** Show additive values with `+` to remove ambiguity; total tooltip uses the final multiplier. Existing Sandbox scaling and LootLab effective rarity continue to apply; do not change loot weights. No patch approval inferred from the test report.

Installed version/tag stays 0.2.64.3. Rendered alignment, Arc sound/glow and connected-player tests remain pending. No Workshop/LootLab publication. **Decision needed.**


## C426: 1A approved, layout corrected, Regulator confirmed (2026-10-22)

Owner selects **1A** and asks for confirmation. The combined C425 correction and .15/.25/.50/.75/1/1.5/2 additive tier schedule are approved; no further patch permission is needed. Owner explicitly rejects moving status inside the slots: shrink the previous battery area to 50% for the battery, fill its remaining 50% with expansion, and return Online/range to the original adjacent location. `test/v0.2.62:ControlPanelLayout.lua` confirms the original battery-left/status-right layout.

Current Regulator has **zero added drain**, not its rarity surcharge plus a discount. `Turret.lua` excludes it from powerLoad; `TurretStats.lua` divides cost by `1 + .25 * active.Regulator`. One gives 20% less consumption; two give about 33.3% less, relative to the same loadout without Regulators. The inventory tooltip currently shows `Battery Drain: +0x` plus a battery-life benefit; Manage details show the calculated negative percentage as a reduction. It never creates negative consumption or recharges power. Preserve this behavior and include the reduction in the requested effective battery total.

This confirmation records the selected scope, not implementation or installation. Installed 0.2.64.3 remains unchanged. **Wait for a patch.**


## C427 - implemented after approval (2026-10-22)

Owner reaffirms approval. [0.2.64.4 patch](PATCH_v0.2.64.4.md) implements this contract. Native camera inspection confirms the obsolete Tether height compensation; native item world alpha supports bounded Arc fading. Lever load-time sprite replacement used incompatible native offsets and is removed. [Verification](TEST_v0.2.64.4.md) records tests and remaining rendered/listening acceptance. The C426 half-battery-area layout and surcharge-free Regulator behavior are preserved.
