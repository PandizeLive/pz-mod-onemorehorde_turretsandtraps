# C171 - Direct LootLab weights and 0.2.46 test findings

2026-10-12. Owner asks to change component loot weight directly instead of a multiplier. This authorizes the hosted tool change, implemented and deployed. The annotated battery finding says minutes are not adjusted to hours. No gameplay code/version/install changes in this turn. Packed-weight reduction remains abandoned.

## Implemented LootLab change

Component inputs show/edit baseline weight times the saved per-item multiplier. For example, Regulator defaults to 5.5; entering 11 stores the equivalent 2x Sandbox setting. Zero disables the component. Global loot, Material and rolls controls remain separate. This is loot chance weighting, not inventory encumbrance or a normalized percentage distribution.

Persisted browser/account/scenario fields retain the existing multiplier schema, so loading old values, cross-device sync and Sandbox exports preserve effective tuning without a database rewrite. Inputs accept fractional values; invalid/over-limit values do not overwrite the previous value. The existing per-item 0-20 game limit is expressed in weight units. Display rounding does not rewrite stored values. Native model probabilities are unchanged. Help text and stale 0.2.44 method label are corrected.

Model/conversion and 29-module appearance checks pass. Browser checks cover saved values unchanged on load, weight edits, zero/invalid input, imported scenarios, reset, correct Sandbox export, Show/Hide and desktop/mobile bounds with no page errors. All 77 API/page tests pass; the DOM fixture was updated to model input validity and assert weight-to-multiplier conversion. Production Worker bundle is unchanged; only static assets differ. Protected routes and both public API checks retain their previous responses. No account tuning/database writes. [Release evidence](../diagnostics/loot-weights/release.json).

## Game findings: not a completed test pass

The current console confirms 0.2.46. Its captured 1,047,756 bytes contain 2,922 turret capacity-warning matches and 12 FormatFlagsConversionMismatchException matches (log occurrences, not counts of independent defects). The exception stack runs through Translator.reportMissingArgumentsFromPastAbuse / InventoryItem.DoTooltipEmbedded, called by TurretMenu.lua:20. This is a different confirmed tooltip failure from the former padding-field error; the repeated rendered-text translation/percent handling is a hypothesis to verify. Do not mark tooltips accepted based on headless tests. Capacity clamping and repeated configuration need investigation; warning count alone does not establish lag. [Snapshot summary/hash](../diagnostics/loot-weights/console-findings.json).

TurretBenefits.battery lines 37-39 convert duration to in-game minutes and always choose BatteryMinutes. Thus a long duration still displays hundreds of minutes; this does not alone demonstrate that drain is too high. Proposed next game correction: minutes below 60, hours from 60 upward, same duration calculation and cached refresh path. Do not change power balance based only on the unit label. The formatting correction and the two console issues are recorded for the next corrective game patch; no engine fix is claimed here.

**Test now - LootLab:** refresh the page and edit a component's weight; previous tuning should still be present. Game acceptance remains incomplete; no full replay of the previous five-step test is required by this tool update.
