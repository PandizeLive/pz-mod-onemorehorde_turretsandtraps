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
