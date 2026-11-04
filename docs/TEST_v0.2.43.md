# 0.2.43 focused test

**Superseded test handoff:** uncompleted checks are carried into [one 0.2.44 test](TEST_v0.2.44.md). This is not a pass or waiver; do not request a separate 0.2.43 round.

## Owner test — pending

1. Restart Zomboid and confirm **0.2.43**. Use your test world and a firearm turret with Large Expansion and room for 600 matching rounds.
2. Load about **600 rounds through inventory**, unload through Manage, then reload through Manage. Both should batch quickly without freezes; interrupt once and confirm no lost/duplicated rounds.
3. Try **one Conservation** with only one ready round (or potato): it should fire twice before empty, with normal cooldown and power each time. With enough ammo, two Splitters plus one Conservation should spend three rounds across two volleys.
4. Open Manage with several module types. Check narrower 4/6/6 slots, scroll **Installed Modules**, and hover individual rows and the battery. Effects should match working copies; text should remain readable.
5. Run your usual mixed turret/Bed Spikes/barbed crowd setup for about 30 seconds. Watch for pauses, stuck reactions or changed trap contact behavior.
6. Save/reload after the first conserved shot. The remaining use and inventory should persist. Report **Test Complete** and any issue; the next review must inspect `console.txt`.

## Automated evidence

- 15,739 assertions and 101 compiled runtime/translation files: recorded in `diagnostics/v0.2.43/validation.log`; includes 0–16-copy arithmetic, Splitter costs, progress across module changes, last-round/Impact rules, grouped UI states and 600-item exact ownership/reservation checks.
- Firearms B42 integration: 51 supported guns, 153 firing transactions; handheld timing unchanged.
- Native firearm probe: pistol, shotgun and hunting rifle last-round conservation, retained cooldown and no false Impact rearm.
- Native inventory probe: 600 real rounds in 30 groups, exact identities/counts. First pass: 13 ms preparation, 11 ms peak group; subsequent fresh process: 13/10 ms. These isolated timings exclude live rendering, normal timed-action animation and dense combat; they do not certify elimination of the owner's 343–563 ms pauses.
- Native write/read confirms exact head progress and existing object/item/charge state. Independent Traps/Turrets/both startup and file manifests are recorded by the release tools.
- LootLab: 75 API/page tests, numerical model/package-default tests, unchanged-account migration, verified deployment and protected admin routes.

Initial native attempts stopped on old 170-entry/27-component fixture expectations; updated to the new 175/28 counts. The renderer experiment using `next` was rejected by runtime validation and replaced with an explicit bounded registry. These failures were corrected before the passing release checks. Stock world-generation/asset diagnostics remain in headless logs and are not reclassified as OMH errors. Owner acceptance is pending; prior 0.2.41/C138 acceptance stays closed. The 0.2.42 bulk-transfer finding carries into this focused test.

## C155 owner screenshots and console review (2026-10-11)

Owner reports UI boundaries/alignment/battery-text concerns and requests new design options. Screenshots show the compact Manage screen and noisy battery tooltip; this is evidence of those visual issues, not Test Complete. The requested targeted test outcomes, including 600-round transfer and Conservation persistence, were not individually reported.

Reviewed console.txt snapshot SHA-256 `26ab08918b441cbf59d80ba7125e262117eee3501215be631faacb459220f2af` (125738 bytes). Loaded diagnostics confirm version 0.2.43. No OMH Lua exception/stack trace was identified; native font/script/map warnings are present. Sample maxima: active update gap 676 ms, transfer batch 5 ms, transfer preparation 6 ms. Visible transfer records include battery servicing; these observations do not prove the bulk-ammunition freeze is fixed. Large wall-clock gaps at unchanged frame numbers are not reclassified as active-game freezes.

Source review confirms the old estimate excludes reload/rack and rebuilds at the 200-ms Manage refresh. C155 proposes cached hover/change-driven estimates, native progress bars and a clearer layout. Discussion only; current gameplay and acceptance status remain unchanged.
