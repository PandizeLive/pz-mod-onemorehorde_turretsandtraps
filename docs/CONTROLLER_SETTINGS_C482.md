# C482 - Tether recovery and compact settings previews

2026-10-26. Owner reports repeated tether stun/pulling creates a loop, requests a longer refire delay, and asks for clearer, more compact Device Settings and Controller Settings mockups. This approves investigation and previews. The numerical cooldown and layout are not yet selected. No gameplay edit, new build or installation in this checkpoint; 0.2.69.1 remains installed.

## Evidence and recommendation

Captured console: `diagnostics/captures/20261026-202614-9485/console.txt`, SHA-256 `13ae4650921b4f7c0dab048b0f188c0431e11322dad3148d4b472306aa320824`. It confirms both packages on 0.2.69.1 / game 42.21, launch speed 30, return speed 4, hold 0.75s, reset 0.5s and pull distance 0.75 tiles. No OMHTT exception stack found in this capture. It does not log the target's actual recovery time or prove how much of the observed loop is animation versus repeated displacement.

Production `TetherCycle.step` starts pulling after hold, returns the nail, then spends `resetTime` in reset before idle permits another shot. `TetherServer.entry` reads the existing `TetherResetSeconds` Sandbox option while idle; its current default/fallback is 0.5 and range is 0-60. `DefenseDisplacement` requests 500ms of inward movement and a 150ms blend-out, so increasing reset should leave more room for both recovery and forward travel. Native installed `actiongroups/zombie/bumped/to_idle.xml` and `to_walktoward.xml` require BumpAnimFinished, which the pull completes; a precise rendered recovery duration is not established by source alone.

Bounded installed-Kahlua replay of the production cycle at 10ms steps, with synthetic stationary first collisions (`diagnostics/c482-cycle.lua` / `.log`):

| Post-return reset | Point-blank pull interval | 1-tile collision | 6-tile collision |
| --- | --- | --- | --- |
| 0.5s, current | 1.27s | 1.54s | 2.96s |
| 2s, candidate | 2.77s | 3.04s | 4.46s |
| 3s, recommended | 3.77s | 4.04s | 5.46s |

These are simulation-normalized seconds (normal-speed duration; fast-forward advances the existing clock). They are not game-clock seconds at the displayed calendar scale, measured zombie recovery, or a guarantee against multiple traps chaining. The approximate formula is hold + reset + outward travel + return travel, with tick rounding in the replay.

- **1A, recommended:** 3 seconds after the nail returns. More opportunity to recover and move forward, at lower firing throughput.
- **1B:** 2 seconds after return. Faster trap cycle but less margin against repeat interruption.

Reuse the current reset state and Sandbox option, not a second cooldown system. Existing saves retain saved values; changing only the fresh-world default will not update this owner's 0.5-second setting. Once selected, settle the existing-save application explicitly and preserve custom tuning. The owner can already adjust this option through Sandbox settings. Verify restart/fast-forward and large elapsed-frame handling: `TetherCycle.step` currently cancels the cycle on elapsed/debt above two seconds, so a future longer-reset patch must ensure this safety cancellation does not bypass the intended reset. Do not claim a longer default alone guarantees no stun loop. No new target immunity, damage, range or pull-distance rule is proposed.

## Current layout findings

`ControlPanelLayout.refresh/drawDetails` reserves four status rows, separate Controls, Connections, and Access & Assignment sections, plus a five-line connection area regardless of actual hint length. `ControlHostDetails.arrange` reserves four status rows and two full-width controls. Both already support independent wheel scrolling. Most compactness can come from grouping and content-dependent height, without reducing legibility or rebuilding Controller data/refresh logic.

## Mockup choices

The interactive preview is `C:/Users/bandi/.codex/visualizations/2026/10/06/01a11283-2701-7630-a9bf-aac054c7bf3c/controller-settings-compact.html`. It shows the map/settings region only; equipment, stockpile and connection-graph behavior remain outside the redesign. It uses fictional sample device values, not live Controller state. Previous carousel selections from other designs are context, not approval for these alternatives.

- **2A Compact rows, recommended:** keep the equal-width panes visible together. Name, a compact state/distance/assignment line, condition/ammo, Targets and Access, then Manage/Unassign. Put connection instructions beneath an expandable connection summary; retain owner text. Controller gets state/range, condition/device limit, Targets/Access and owner. Remove redundant subheaders and permanent instruction blocks. Preserve button/permission and device-family distinctions.
- **2B Foldouts:** keep name/status and Manage/Unassign visible, with Settings and Connections/Ownership collapsed initially. Shortest side-by-side default view; adjusting policies costs an extra click and closed sections can conceal current values.
- **2C Tabbed inspector:** Device Settings and Controller Settings share the full width. Roomier controls and a shallower settings area; only one side is visible at a time. This is an explicit alternative to the previously selected simultaneous panes, not an assumed change.

All designs retain numerical management range and omit the removed circle. Map markers switch between Turret, Tether and Pressure Plate examples. Pressure Plates show trigger mode, not turret-only targeting or Open Manage. Common controls are local preview interactions, not game commands. The preview's targeting selects represent access to the existing targeting editor; implementing a layout must preserve its full custom permissions/settings rather than replace it with a reduced list. Likewise graph editing remains in Connections, not new wiring actions in these panes.

## Verification and handoff

Headless browser checks cover three designs, three device families and four widths (1000/736/540/360): 36 combinations without horizontal control overflow or JavaScript errors; tab and foldout interactions checked. Screenshots reviewed in `diagnostics/c482-rows.png`, `c482-folds.png`, `c482-tabs.png` and `c482-host-tab.png`. This verifies previews, not native game layout. Desktop preview uses product-specific styling and optional width/font/spacing design controls.

No change to Source, Contents, saved settings, loot, cumulative Workshop draft, siblings or installed packages. Owner's unrelated `docs/AMMO_UI_C446.md` edit is preserved. Read-only remote fetch succeeded; no newer origin/dev commits. Private mirror remains blocked by the prior automatic approval-review rejection requiring destination/payload authorization; no retry.

**Decision needed: 1A/1B delay and 2A/2B/2C layout.** Medium reasoning is sufficient for the selected tuning/layout patch; first verify elapsed-time reset handling and native layout with the existing test harness. No new playtest requested for unchanged 0.2.69.1 in this discussion.


## C483 - Selected cooldown/layout and Connections multi-selection (2026-10-26)

Owner selects **1A / 2C**: three seconds of reset after the nail returns, and the full-width **Tabbed inspector**. These choices supersede the pending numerical/layout choices above. Owner additionally requests drag selection, multi-selection, dragging selections into groups, and Assign/Unassign for selections. No implementation or owner acceptance is claimed by this planning checkpoint.

### Proposed interaction contract

- Drag blank Connections space to box-select visible expanded device cards; Ctrl-click toggles individual cards. Selection is temporary UI state keyed by device identity, reconciled on refresh/removal/privacy changes.
- Drag a selected card to move the selected set into a group; dragging an unselected card selects that card. Preserve input/defense columns and stable ordering. Group title bars retain their own collapse/reorder behavior; connector handles retain wiring behavior.
- Show the selection count with Assign Selected / Unassign Selected. Report successful and skipped entries with useful reasons. Preserve capacity, ownership, access, range and power checks; no silent takeover from another Controller. Unassign must remain possible for this Controller's out-of-range/offline devices.
- Use the current graph and refresh path. Replace single-target drag state with shared selection handling, rather than adding a second graph or per-card polling. Keep the tabbed inspector compact and scrollable, with existing targeting editor and family-specific controls.
- Source review corrects the C482 Pressure Plate mockup: the actual trigger filter is Both/Players/Zombies, not press/release transitions. The preview is not approval to change that behavior.

### Material choice: group drops versus Controller assignment

**1A, recommended:** grouping and Controller assignment remain separate. Assign Selected first, then drag into a group. For a mixed selection, move eligible members of this Controller and clearly report skipped unassigned/other-Controller devices. This avoids an organizational gesture unexpectedly changing management/power relationships.

**1B:** dropping into a group also assigns eligible unassigned devices to this Controller. Still refuse silent transfers from another Controller and report skipped entries. Fewer clicks, but dropping has a gameplay side effect.

This is the remaining interaction choice for the combined patch, not a request to reconfirm the selected three seconds or tabs.

### Implementation findings and verification boundary

`ControlGroupUI.request` permits one pending edit, and `ControlGroups.propose` validates one exact assigned target plus organization revision. Looping the existing request would discard later moves while pending. Extend the shared authoritative mutation path for bounded multi-target operations with current identity, access, capacity and revision checks; do not simply loop the UI handler. Existing organization is bounded by 32 inputs plus 32 defenses. Preserve loaded-object verification and C469 foreign-owner privacy throughout selection, details and commands. Native B42 timed-action serialization must be verified before choosing the batch payload.

`ControlWorld.assign` currently allows another Controller ID to be replaced when otherwise eligible; the proposed bulk action must not silently exploit this behavior. This observation does not authorize unrelated assignment redesign.

The selected reset reuses existing state/Sandbox configuration. Existing-save application must be explicit and preserve custom tuning; fresh defaults alone do not update the owner's saved 0.5. Verify the elapsed/debt cancellation path cannot bypass the cooldown. Multiple staggered traps can still pin targets; no immunity is requested.

Horde Night `OMH_DefenseSettings.lua` currently audits `TetherResetSeconds` against 0.5 (higher is hardened). A new default of 3 therefore needs a coordinated baseline decision to avoid falsely classifying fresh default settings. Propose only the matching baseline correction as part of the combined patch; sibling edits are not made in this checkpoint. Historical flags and custom tuning must not be cleared automatically.

Smallest useful checks: selection hit bounds and ports/header precedence; mixed eligibility and stale/deleted identities; one versus several selected cards; order/group persistence; permission/range/capacity rejection; offline/out-of-range release; native batch serialization and independent package startup; tab layout at minimum width; cooldown normal speed/fast-forward/large elapsed handling. Rendered and connected-player acceptance remain separate.

Medium reasoning is sufficient; estimate 35-55 minutes for the combined selection/authority/layout patch and verification, so recommend Fast. Current 0.2.69.1 remains installed. No Source, Contents, save, Workshop draft or sibling changes. Owner's unrelated AMMO_UI_C446.md edit is preserved. Planning is committed locally; the previous automatic approval-review rejection still blocks the private mirror, and no upload is retried. **Decision needed: 1A or 1B group-drop behavior.**


## C484 - 1B selected; group assignment retained (2026-10-26)

Owner: "1B (we'll still have group signing)". Implement assignment-on-drop and retain separate bulk selection controls plus direct whole-group Assign/Unassign. Three-second post-return reset and Tabbed inspector remain selected; stale preview carousel selections do not override the owner's explicit2C.

Owner subsequently answers **"Yes, include the matching baseline correction"** to the specific Horde Night audit update from0.5 to3 seconds, with saved settings and historical run flags left untouched. This authorizes only the matching rule/capability and its normal versioned local packaging, not broader Horde gameplay or publication.

[Implemented patch](PATCH_v0.2.70.md), [verification](TEST_v0.2.70.md), and sibling `docs/PATCH_v0.6.16.9.md` record behavior and evidence. No further design decision is pending. Native/package checks, immutable tags and verified local installation are complete; see the test record. Do not silently migrate saved reset tuning. Private mirror remains blocked by the earlier review; owner AMMO_UI_C446.md edit is untouched.
