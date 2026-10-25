# 0.2.67 verification and owner checklist

Scope: C450 final approval of C445/C447/C449. Previous installed baseline: immutable test/v0.2.66 / 7d56836bc097711ee426e0fdda9bf8a3598bbf76. C450 automated evidence is retained below; C451 adds the subsequent owner playtest.

## C451 - Owner playtest (2026-10-24)

Owner: "Looks like it's good and functional now!" Record the reported general functionality as passed, without inventing individual checklist results or a measured endurance test.

Captured `console.txt`, the OMHTT trace, error context and both installed manifests through the root release tool: `diagnostics/captures/20261024-202806-4999`. The captured client/server-ready lines and package identity show **0.2.67**, both entries enabled, **game42.21**, **single player**. The reviewed capture contains no OMHTT exception stack. It does contain native asset/map warnings and another mod's Firearms SuppressorEffectiveness translation-format errors; those are not attributed to this patch and were not altered.

The trace records management/module transfers and a scheduler peak of four defense slots. It does not establish crowded-load performance. A firearm still reports **5,000** ammo capacity and the Potato baseline **100**, consistent with preserved legacy save settings. Consequently this session is not evidence for the new 4,000-round Large capacity or its calculated six-hour baseline. Existing-world opt-in, actual endurance, larger stress loads and connected multiplayer remain separate acceptance work. Multiplayer stays deferred as requested.

No gameplay files, version, installed packages, immutable tag, cumulative Workshop draft or loot tuning change. This is a documentation-only acceptance checkpoint.

## Automated evidence

Full validation passes **27,720 assertions**, compiles **341** runtime/translation files and checks **1,493** native translation keys; the manifest covers **435 source / 593 packaged files** (226 Traps / 367 Turrets). UI/world objects in the regression suite are test doubles. New coverage includes all thirty base/kit capacities, final fractional flooring, preserved saved/partial legacy settings and explicit opt-in; fixed recipient-only equipment cues; bounded reserve scans, real-charge/game-hour accounting and pause; exact legacy contents returned to inventory/floor, failed delivery retention and a bounded retry; out-of-range assignment/group/session cleanup, unauthorized rejection and unloading preservation. UI geometry verifies equal map-aligned panels and responsive controls. Native tooltip wrapping retains white purpose rows and grey statistics.

The current installed native InventoryItem.loadItem bytecode confirms that changing an existing container script to normal would skip old serialized contents. The implementation instead retains the legacy type and introduces a canonical plain item. Native write/restart verifies both legacy-container contents and the newly recovered plain item/condition/exact battery charge. Six block meshes import through the native model loader. Native write/save/shutdown passes in **99.4 seconds**. Fresh-process reload/save/shutdown passes in **116.7 seconds**. All three independent-package startups pass: **traps 83.2s, turrets 92.4s, both 89.0s**. Browser-rendered UI call traces were inspected for pane alignment; these are verification traces, not game screenshots. Native dedicated probes have zero connected clients and do not establish rendered UI, listening or connected multiplayer acceptance.

Earlier verification attempts exposed outdated test expectations for the previous ammo table and old Poke output identity. Those fixtures were corrected to assert the approved values and both compatibility paths. One package-check sequence was restarted after its preflight caught packages pending a rebuild during the final tooltip adjustment. No errors are hidden; final successful results supersede intermediate failed attempts.

## Delivery

Installed from immutable **test/v0.2.67 / 4669ba13e1dc759b2b007229ac5fd7c98ff38d69**. All **435 source and 593 package/tag/install/archive files** match their SHA-256 manifest. Both managed 0.2.66 backups verify. Backup: `C:\Users\bandi\Zomboid_Modding\OMH\Turrets & Traps\diagnostics\p1c1\install-backups\20261024-190728-6688`. Archive SHA-256: `9477f74fcb042216a3ef63a9320f600b1016313ae6ab41aa60cfe3b1ec64e61f`. Local proof: diagnostics/v0.2.67/local-release.json. Workshop and hosted LootLab remain unchanged.

## Owner checklist

- Controller settings, resizing and assignment range
- Expansion slots, tooltips and transfer sounds
- Ammo capacities and kit replacement
- Controller battery endurance tooltip
- Poke Floor recovery and retained contents
- New blocky turret heads

Existing saves retain legacy ammo tuning. Enable **Use New Ammo Rules in Existing Worlds** in Turrets > Storage to test the new capacities there; fresh worlds use them automatically. C451 accepts the reported general workflow. Itemized visual/audio checks, actual new-capacity endurance, stress FPS, active Horde Night integration and connected dedicated/listen multiplayer are not established by that broad report. **Test now** for the remaining SP checks when available; multiplayer stays deferred.
