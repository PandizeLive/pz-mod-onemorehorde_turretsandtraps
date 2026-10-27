# 0.2.70 - Connections selection and compact settings

C484, 2026-10-26. Owner selects C483 **1B**, retaining group assignment: dropping cards into a group assigns eligible unassigned devices. This follows selected C482 **1A / 2C** (three-second post-return reset and Tabbed inspector). Owner explicitly approves the matching Horde Night baseline correction through the in-turn question. No further design approval is pending.

## Changes

- Connections supports blank-space box selection, Ctrl toggling, dragging selected cards into groups, selection count, and separate bulk Assign/Unassign. Group context menus retain Select Group and direct whole-group assignment/release. Ports remain wiring handles; only group titles toggle collapse.
- One authority batch accepts up to64 IDs, resolves actual devices and checks identity, ownership/privacy, access, range, power, capacity and group revision. Eligible unassigned devices join on drop; devices assigned elsewhere are skipped. Receipts distinguish successes and rejection reasons. Capacity counting is shared per batch; group movement publishes one organization update. Offline/out-of-range release stays available.
- Selection is ephemeral; hidden/collapsed/removed/foreign entries cannot silently remain bulk targets. Incremental discovery does not discard selected identities just because their cached row has not been revisited yet. No new scan loop or per-card timers.
- Device and Controller Settings share a full-width tabbed area with compact paired controls and wheel scrolling. Existing targeting editor, trigger actor filter and ownership controls remain. The earlier preview's press/release labels were conceptual mistakes, not new trigger semantics.
- Fresh-world Tether Reset Duration becomes3 seconds after nail return. Unsafe elapsed/debt cancellation no longer immediately reopens firing. Existing saved values, damage, pull distance and other custom tuning remain unchanged. This is not immunity from multiple staggered traps.
- Horde Night/Cure Defense0.6.16.9 updates the reviewed reset baseline and capability identifier to match. No historical flags, stored scores or saved Sandbox values are cleared. Trait Shop is unchanged.

## Existing saves

No new world is required. A save with Reset Duration0.5 retains0.5. Set **Reset Duration to3** in Sandbox for the selected timing; do not silently migrate values that may be deliberate customization. After the coordinated baseline update, the old0.5 value is correctly classified easier than the new3-second baseline.

## Verification

See [test record](TEST_v0.2.70.md). Automated/native evidence is separate from rendered gameplay and connected-player acceptance. No Workshop upload or GitHub mirror is claimed. The existing mirror review block remains; Horde Night's mirror is manual-only.
