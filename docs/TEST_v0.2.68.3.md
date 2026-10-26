# 0.2.68.3 verification

## Automated evidence

Final validation passes28,899 assertions,440Source files,602packaged files and401checked translation keys. Traps-only, Turrets-only and combined startup checks pass in50.9/53.1/50.2seconds. Their server-only checks precede the last reserve-caption layout adjustment, which is covered by final Kahlua compilation and UI geometry checks. Native write/read probes passed in62.0/54.0seconds with zero connected players. Native tether actor enters stagger, has an outward hit direction and zero additional hit force; pull does not restart the reaction. Existing conditional damage and persistence regressions remain passing. These server probes precede only the final client refresh/label polish, not a subsequent combat change.

The installed native inventory implementation reproduces the old missed notification after a native view clears drawDirty. The replacement verifies both refresh orders, exact item rows, same-count replacement, removal, drag identity, unrelated-container isolation, repeated-notification coalescing, hidden/reopened panes and two embedded views. Six hundred idle updates do not rebuild lists. Inventory objects/window adapters are test doubles around real installed inventory Lua; no rendered or connected-client claim.

Filtered-tab checks preserve exact script identities, exclude hidden/obsolete/unrelated items and retain native initialization. Atlas-region test uses a nonzero origin and verifies16px dimensions without changing the source texture. Installed Texture.split bytecode confirms absolute atlas coordinates. Rendered Specialist appearance remains pending.

Map checks cover all five kit grades, three zoom scales and64 segments per ring; drawing agrees with authoritative radius. Existing native map API/resize tests pass. The owner's perceived visual mismatch remains unconfirmed rather than declared fixed.

Actual Horde integration Lua rejects owner/foreign-source damage across firearm, arc, splash, fragment and tack labels, rejects push, leaves the refused run unflagged, and permits/classifies enabled assistance. Production integration runs against controlled event/actor doubles. Connected two-player verification remains pending.

Earlier validation failures were test fixtures: an incorrectly indexed projection Y argument, a missing test player-data adapter, and a reserve assertion inserted before panel creation. A compact54px slot check caught clipped two-line text; use one line and prioritize Controller Reserve beside the icon when the combined name is too wide. Corrected fixtures; no live failures concealed. An early package isolation attempt rejected stale generated client files during ongoing editing; rebuild preceded the final run.

## Owner checklist

- Specialist manual icon.
- Stockpile updates in both inventory windows.
- T&T Item List tab.
- Controller Reserve label and resizing.
- Tether shove and pull.
- Controller range boundary.

Restart before testing the installed version. Multiplayer remains pending; no new world required by this patch, and saved tuning is preserved.
