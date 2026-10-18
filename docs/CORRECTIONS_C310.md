# C310 — Controller redesign, plate feedback and module proposals

2026-10-18. Owner reports findings from installed 0.2.53.11, supplies three screenshots and asks for three Controller redesigns before choosing A–E. Follow-up adds missing **To Stockpile / To Inventory** tooltips. This checkpoint is investigation, design and planning, not approval to install a gameplay patch. No Source/Contents/version/Workshop changes.

**C311 update (2026-10-18):** owner selects **1A / 2B / 3A / 4A**. Grouped Controller layout, per-kill Leech refunds, one additional half-damage Martyrdom generation and rotary Leech support are confirmed. Owner explicitly excludes Splitter, Fragment, Martyrdom and other secondary-effect kills from Leech unless Synergy is installed. The compatibility review below identifies one remaining choice: whether to enable Synergy on rotary heads, which currently reject it. Historical options below are retained as provenance; they are no longer all open.

**C312 update (2026-10-18):** owner selects **5A**, allowing rotary Synergy for supported effects. Gameplay/layout decisions are settled. Owner asks whether **Sap Module** would describe the battery-refund effect better than Leech. Naming remains discussion: recommend **6A Siphon Module**, with **6B Sap Module** as the shorter alternative. No name selection or new gameplay patch is inferred from this question.

**C313 update (2026-10-18):** owner selects **6A Siphon Module**, explicitly replacing “the attack’s” with **“the shot’s”** in the tooltip. All presented design choices are now settled. The final wording below supersedes the historical naming proposals; the gameplay formula and rotary accounting are unchanged. This remains a planning checkpoint, not an installed patch.

## Current evidence

Inspected branch `codex/performance-barbed-audit`, starting HEAD `1c612b47cd04a27002b75dd06b0233058277c887`. Fetched `origin/dev`: no commits absent locally. Only open PR is existing draft #1. Captured console through `OMH.cmd -Action Capture`; capture SHA-256 `85b8c570249996bd71ed15e65b5c7283dc8e496aa863d74be7bb7e04bfde96c2`, local folder `diagnostics/captures/20261018-005429-2250`. Trace explicitly reports `version=0.2.53.11 side=sp`. This is owner SP feedback, not connected multiplayer acceptance.

| Finding | Confirmed evidence and proposed correction |
| --- | --- |
| Plate/player overlap | Generated custom plate tile definitions have zero properties. The installed game bytecode (`IsoWorld.LoadTileDefinitions`, `FBORenderCell.isObjectRenderLayer_Floor`) recognizes `RenderLayer=Floor` separately from `solidfloor`. Use the floor-render layer for both raised/pressed sprites; retain full-tile activation, inset geometry and pass-through/non-thumpable flags. The screenshot establishes bad rendered ordering; exact alignment still needs a rendered check, including approach from all sides and old/new plates after reload. Do not invent collision or replace the ground tile to fix drawing. |
| Plate pickup has no kneeling animation | `shared/OMHTT/ControlAction.lua` defines pickup duration but has no `start`, facing or animation setup. Installed `shared/TimedActions/ISPickUpGroundCoverItem.lua` uses `Loot` plus `LootPosition=Low`, hand-model overrides and facing. Reuse native low pickup for Plates, preserve cancellation and server `complete`; do not kneel for every one-tick control command. |
| Controller UI accessible through turret | `ControlClient.world` offers ControlManage for every device; `ControlPanel.open` accepts any nearby device. Gate both entry point and opener to actual Controllers. Remove turret/sensor routes to the Controller Menu; keep ordinary Turret Manage. Existing stockpile destination access is attached inventory, not permission to open Controller Menu from a turret. Preserve server authority and local/private/faction/public permission rules. |
| No visible incoming links | `ControlWorld.link` persists receiver IDs on source `links`, and keeps server `incoming` lookup. `ControlPanelLayout.drawDetails` renders only the selected input hint/connection state, not a list. Display all incoming sources with name, state and individual Disconnect; handle source pickup/unload, rename and relink. This does not yet prove the owner's link transaction failed. Derive/cache from published device state or publish a bounded authoritative incoming summary; no per-frame world scan. |
| Ammo right edge | `TurretManageLayout.create`: Ammunition ends at `body.width - 16`, Modules at `body.width - 8`; an eight-pixel mismatch. Use one shared right inset for frames, slots and action row, preserving equal Ammo/Void widths and current single-page layout. |
| Drop on occupied module does not replace it | `TurretSlot.onMouseUp` forwards only incoming items and kind, losing target item identity. `TurretTransferAction` only handles ordinary add/remove, so capacity can reject or another slot can receive it. Add an explicit exact-item swap transaction. Validate incoming/outgoing items, permissions, source/destination, capacity and module compatibility before commit. Preserve Void contents and loaded-ammo invariants. Return displaced item to incoming item's source (inventory/authorized Stockpile); if a safe swap is impossible, leave both unchanged and state why. Same-turret dragging must be treated as reorder, not an external transfer or duplication. |
| Mutation feedback absent | Pulse only affected slot borders briefly (proposed 0.25 seconds) after authoritative successful item transfers, including removal. Retain rarity color and empty-slot hints. One event/revision comparison on refresh; draw only while pulse active. No new permanent scan/timer, no success pulse on rejected transfers or initial opening, and no constant flashing from normal ammunition consumption. |
| Set Facing throws | Console has two cursor startup exceptions (`derive of non-table: null`, lines 544–603 and 1060–1155), then three button exceptions (`start of non-table: null`, frames 27852/28567/28738). The native dependency exists under `server/BuildingObjects/ISBuildingObject.lua`, but top-level client cursor creation runs before it is available. Existing `TurretMenu.installPreview` defers similar native setup to OnGameStart. Defer cursor class construction to supported game-ready initialization; keep imports explicit and no pcall. Rename user-facing action and tooltip to **Set Aim**, preserving saved angle and protocol compatibility. Verify initialization, start, preview, cancel, click and panel return against real native class, not just the stand-in. |
| Controller buttons/tooltips unclear | Open Manage/Assign tooltips are cleared while enabled in `ControlPanel.prerender`; Unassign shares Assign's missing explanation. Keep explanatory tooltips when enabled and specific failure reasons when disabled. Group regular actions separately from assignment and per-input links. |
| To Stockpile / To Inventory unclear | `ControlManage.create` toggles `panel.toStockpile`; it does not immediately transfer selected items. Propose **Remove To: Inventory / Stockpile**. Tooltip: “Items removed using the slot menu go to your inventory / this Controller's Stockpile. Click to change destination. Dragged items go where you drop them.” Explain read-only, disconnected Controller or unavailable Stockpile states without erasing the normal explanation. |

No blanket claim that the other console warnings are T&T failures. Native font/FluidContainer and Firearms translation warnings are separate. The identified T&T runtime failure is the aiming cursor. Read-only audit found no new shipped `pcall` changes; a full gameplay validation run is not claimed for this documentation turn.

## Controller choices

Three matching grey OMH previews use red/white branding, explicit native Stockpile area, visible backup Battery, real connection rows and explanatory action tooltips. These are design previews, not game screenshots. Preserve the native inventory implementation; its representative rows/weights are sample data.

- **A — Grouped (recommended):** device directory left, Open Manage/Set Aim together above Connections, Access & Assignment separately below; Stockpile on the right.
- **B — Device Rows:** each device has its own action row; expand its Connections & Access below. Faster overview, but long lists require more vertical scrolling.
- **C — Focused:** device picker above a single device; actions on the left and Connections on the right. Compact, but nearby devices are less visible.
- **D — Keep original:** retain overall layout, still apply accepted functional corrections/tooltips.
- **E — Another three:** no layout selected.

Portable preview: [Controller redesigns](mockups/c310/controller-redesigns.html). Inline source is a task-owned visualization; this exported standalone copy is retained for the explicitly required GitHub planning handoff. Browser review covers 1008,720,344 and304 pixel product widths, all three layouts, no horizontal overflow or page exceptions, plus disconnect/access interactions. Screenshots inspected for all three desktop designs and Grouped narrow layout. This does not establish native Lua rendering or connected-MP acceptance.

## New module — proposed Leech

Recommend **Leech Module**; “Repair” suggests durability repair, which this effect does not provide. Owner formula: first copy refunds 2x the killing shot's power cost; each additional copy adds 1x (2x,3x,4x...). At cost C, a qualifying kill with one module produces net +C; this is energy generation, not simply reduced drain. Battery charge cannot exceed 100%.

**Decision 2:**

- **2A (recommended):** one refund per paid shot/attack across its eligible damage descendants. Multiple kills from one explosive/splitter shot cannot multiply its refund further.
- **2B:** refund per kill. Eight kills with one module return 16C against one paid C (net +15C); substantially stronger in hordes.

Use actual server-committed battery debit, including selected power modules, rather than current equipment's recalculated cost. Snapshot eligibility when the shot is paid, retain exact source identity and origin through delayed effects, and deduplicate confirmed deaths on authority. No battery/generator fuel is manufactured for grid/disabled-power shots. Proposed default is battery-only; return to the original still-installed battery, not a replacement cell or a picked-up device. Check death callbacks after native/MP damage completion, not client visual events. Synergy expands secondary-hit eligibility; source and chain limits remain explicit.

Recommend loot-only, weight 0.2, **same loaded loot weight as Synergy** (pack/LootLab/Sandbox included), using the existing rarity-linked drain calculation. These are proposed defaults to confirm with the module decision, not implemented balance. At one/two/three modules, the once-per-shot break-even kill rates are 50%,33.3%,25% respectively before misses and non-shot drain.

**Decision4 — rotary support:**

- **4A (recommended):** include rotaries using actual battery energy spent over one complete swing/pass, tracked independently of update rate; one refund opportunity per attack if 2A is chosen. Define the two-arm pass from native motion travel, not per-tick contact damage.
- **4B:** limit Leech to shot-firing heads initially; explicitly mark it incompatible with rotaries until a motor-energy rule is approved.

Rotaries consume continuously in `TurretRotary`, so blindly reusing firearm shot cost or last tick's cost is incorrect and frame-rate-dependent. Motor energy needs its own attack-window ledger, not a guessed equivalent bullet cost.

## Synergy / Martyrdom

Current `TurretProc.step` calls `Damage.resolve(..., "martyrdom")` without routing successful kills back into `E.hit`; existing burst jobs are terminal by design. The new request changes that rule. Keep normal burst delay/audio, radius, player bruise behavior, consent/score handling and duplicate-death protection.

**Decision 3:**

- **3A (recommended interpretation):** one additional generation. Every zombie killed by an initial Martyrdom burst can produce a 50%-damage burst; kills from those reduced bursts cannot trigger another Martyrdom burst.
- **3B:** only one additional 50%-damage burst total per original Martyrdom burst, even if it kills several zombies. Predictable smaller cost, weaker chains.

Enable only with Synergy. Carry an explicit generation and root identity through MP completion, preserve the existing bounded scheduler and 512-job ceiling, and prevent cross-effect routes from resetting the generation. Second-generation eligibility uses reduced damage only once; no 50% cascade forever. Saturation needs explicit tested handling without unbounded queues, a whole-horde scan or arbitrary extra per-frame work. Proposal: admit follow-up work only into available bounded capacity and never delay death application waiting on an effect slot. 3A can still make a large batch even at one generation; test dense AoE plus Leech if 2B is chosen.

## Next patch gates and acceptance

Layout A and module decisions 2B/3A/4A are confirmed by C311; C312 confirms 5A rotary Synergy compatibility; C313 confirms 6A Siphon Module and final wording. All owner findings above remain in scope, including later destination-tooltips feedback. No presented design decision remains open; the corrective patch is ready for final implementation approval. Keep correction work within R4C1; next content remains R4C2 Poke Floor, then fixed dart emitter; R4C3 beam sensors are not part of this patch.

After approval, implement atomic swap/death-refund authority and bounded effects, verify current native initialization and floor rendering metadata, test multiplayer message duplication/reconnect/pickup/cancel/permissions, and run appropriate package/native checks. The prior C308 cursor double hid a real initialization defect; add a real lifecycle check. Owner GPU and connected sessions remain separate acceptance gates, not a reason to stop approved implementation.

## C311 — Confirmed selections and rotary compatibility

Owner reply: **“1A / 2B - however, it won’t count kills from splitter, fragment, martyrdom, etc.. unless Synergy Module is installed. / 3A / 4A.”** These choices settle the four presented design decisions, with the explicit secondary-kill qualification overriding any broader interpretation of per-kill refunds.

- **Controller:** Grouped design. Preserve the recorded fixes/tooltips, grey theme, native Stockpile and separate action/assignment groups.
- **Leech:** each eligible confirmed zombie death refunds `(installed Leech count + 1) × actual paid attack battery cost`: 2x, 3x, 4x, and so on. No once-per-shot refund limit. Deduplicate a death across local/remote acknowledgements and overlapping effects; multiple victims remain independently eligible.
- **Secondary kills:** Splitter, Fragment, Martyrdom and other module-created damage descendants require Synergy. Track the actual lethal damage path, not merely whether the zombie was earlier hit by a primary projectile. Preserve head-native attacks as the primary damage family; innate rotary multi-contact is not a Splitter/Piercing module effect. Do not infer that every additional victim is a secondary effect.
- **Synergy:** one extra Martyrdom generation. Each initial-burst victim may create a burst at 50% damage; deaths caused by those reduced bursts cannot restart Martyrdom. With Synergy, those confirmed deaths may still independently refund Leech; suppressing another explosion is not suppressing the kill's refund.
- **Rotary Leech:** actual battery debit accumulated over a swing/pass, independent of tick rate, qualifies per killed victim. Both arms share the paid motion window; do not synthesize firearm shot cost or reuse just one update's debit. Closing/interruption of a motion window must settle only already-paid energy, with no credit for future movement. Direct rotary kills do not require Synergy.
- **Other presented defaults:** Leech name, battery-only refunds capped at 100%, loot-only/0.2 weight and Synergy-equivalent loaded loot weight, plus existing rarity-linked drain. Extend module packs, LootLab, Sandbox, descriptions and installed benefits together during implementation. Preserve source identity/paid-cost snapshots and multiplayer/Horde Night authority from the C310 contract.

### Choice 5 — Synergy on rotary heads (5A selected in C312)

Static source review finds a real compatibility mismatch: `shared/OMHTT/TurretHeads.lua` lists `Synergy = true` in `H.excluded`, while Martyrdom and Tack are supported. `server/OMHTT/TurretRotary.lua:R.contact` already calls `TurretProc.hit` after successful damage. Thus selected 4A makes direct rotary kills eligible for Leech, but their Martyrdom/Tack kills can never meet the new Synergy condition under current compatibility rules. This is not a technical impossibility; it is an existing exclusion needing an explicit design choice.

- **5A (recommended):** allow Synergy on rotary heads for supported effects, including Martyrdom/Tack and Leech secondary-kill eligibility. Preserve Splitter, Fragment, module Piercing and other independently unsupported rotary modules as excluded; enabling Synergy does not enable every module.
- **5B:** retain rotary Synergy exclusion. Leech works on direct rotary kills only; Martyrdom/Tack damage remains unable to earn refunds or self-chain through Synergy on those heads.

No option 5 selection was inferred from 4A; the owner's explicit 5A reply in C312 resolves it. Everything else in choices 1–4 stays settled; do not reopen it or silently substitute 2A. No gameplay/version/install change or new owner/connected acceptance in these planning updates.

## C312 — Rotary Synergy approved; battery-refund naming

Owner: **“5A. Would Sap Module work better for Leech? Leech sounds like lifesteal / repair as well.”** Confirm rotary Synergy support for existing compatible effects, including Martyrdom/Tack and secondary-kill energy refunds. Splitter, Fragment and other independently excluded rotary modules remain unsupported. Preserve all selected per-kill, 2x/+1x, one-extra-generation/50% and actual-paid-energy rules.

The naming concern is reasonable: Leech commonly suggests health recovery, while this module restores battery charge. Sap avoids some of that association but can imply weakening/slowing a victim; it does not clearly communicate the energy return. Recommend Siphon as an energy-drawing name, with an explicit battery tooltip. This is a wording judgment, not a claim that either name is unambiguous without its description. Nearby Regulator reduces consumption and Conservation saves ammunition; the new name/description must preserve those distinct roles. Neither Sap nor Siphon currently appears as a module name in the checked EN translations.

- **6A — Siphon Module (recommended):** energy-drawing flavor; tooltip explicitly says battery.
- **6B — Sap Module:** shorter, more aggressive wording; tooltip must make clear it restores charge rather than applying a weakening status.

Proposed short text for either name:

> Feature: Kills restore 2x the attack's battery cost.
> Stackable: +1x refunded per module.

Battery Drain and Rarity retain the established calculated fields. Secondary-kill eligibility remains Synergy-gated. Update Synergy wording during the patch to cover supported secondary damage and the approved chain behavior, rather than retaining the current projectile-only wording on rotary heads. C313 below resolves the name and wording; item/script IDs remain part of implementation. No additional gameplay decision is introduced by naming.

## C313 — Siphon Module name and final wording

Owner: **“6A - instead of ‘the attack’s’ we’ll use ‘the shot’s’.”** The module is **Siphon Module**, replacing the planning name Leech. Use this exact player-facing text:

> Feature: Kills restore 2× the shot’s battery cost.
> Stackable: +1× refunded per module.

The requested uniform “shot’s” wording does not change rotary support: refunds still use actual paid battery energy for the complete swing/pass, with only already-paid energy settled on interruption. Preserve per-kill refunds, the Synergy requirement for module-generated secondary kills, original battery identity and charge cap, and all confirmed C311/C312 rules. Battery Drain and Rarity remain calculated fields. No health repair or weakening effect is added by the name.

All presented design choices are settled. All C310 findings and the selected Grouped Controller redesign remain queued for the corrective patch; no Source/Contents/version/install or Workshop change, new gameplay test, or owner/connected acceptance is claimed by this documentation update.
