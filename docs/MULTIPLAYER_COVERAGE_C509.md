# C509 - Whole-catalog multiplayer follow-through

2026-10-29. Owner approval: "Go ahead and finish checking every turret, trap, and module interaction with the new multiplayer system. Fix any findings and keep packaging on hold until we have proof."

This is an **unpackaged source candidate**, extending [C508](MULTIPLAYER_REPAIR_C508.md). Installed, tagged and staged 0.2.70.7 remains unchanged. This audit covers every current family and supported single-module combination; it does not claim every possible multi-module permutation, arbitrary third-party firearm, or connected acceptance.

## Reproduced findings and corrections

| Finding | Reproduction | Correction |
| --- | --- | --- |
| In-flight capacity discarded an admitted hit | Dispatch 129 different victims while 128 await acknowledgement; C508 rejects the 129th | Use the existing bounded damage queue until a transport slot opens. Per-victim serialization and short contact expiry remain enforced. No unbounded queue. |
| Linked triggers refused Arc | Powered Arc, Firing module, zero physical ammunition; `ControlCycle.request` returns false | Respect the head's `ammoFree` property. Empty Potato remains blocked. |
| Scrapshot/Piercing lost Siphon eligibility | An earlier pellet already used the victim's one-time effects; a later primary pellet kills, but its ray has advanced before the acknowledgement | Capture whether that pellet was secondary before dispatch. Preserve the existing 45% chance and single claim. |
| Piercing Potato splash shrank again in MP | The ray advances and reduces its next-hit damage before the previous hit is confirmed | Capture the current hit's splash basis before advancing the ray. |
| Client receipt history rejected valid sustained hits | 600 operations during the retention window exhaust C508's 512-history limit even with expiry processing | Replace superseded receipts for the same actor after the server authorizes a newer operation; retain its sequence guard and latest receipt across unload. Bound distinct retained receipts at 4096 and expiry work at 64 entries/tick. |

`tools/check_multiplayer_regressions.py` independently loads each affected module from frozen C508 commit `2c16cd4` into the current fixture, without modifying Source. Each old module must fail its named assertion. The complete corrected candidate must pass separately. This provides failure-and-repair evidence rather than only a passing total.

## Coverage and what it establishes

| Family | Current checks | Limits |
| --- | --- | --- |
| Potato, Ballista, Scrapshot, Arc, Lobber, Rotary Bat, Rotary Blades | Each production hit handler runs through real Lua V2 Apply/Applied with separate owner/server actor doubles, 50ms message legs and duplicate receipts | Hit-handler coverage does not independently prove each rendered launch, reload or native animation |
| Firearms | Pistol, Shotgun and Hunting Rifle represent the supported single-projectile, pellet and rifle paths; production firearm hit handler and native item adapters checked | Not every third-party gun or firearm mod combination |
| All 32 modules and four kits | 360 head/catalog compatibility-stat cells, 329 supported combinations plus 10 baseline hit cases: **339 serialized hit cases** | A passive module accompanying a hit does not prove its every separate behaviour; resource/automation suites below supply those checks |
| Combined projectile effects | Complete nine-victim Arc chains with Splitter, Piercing, Fragment and Initial Blow, with Synergy off/on; no stuck reservations; corrected delayed Scrapshot/Siphon and Potato/Piercing splash cases | Representative interacting combinations, not all subsets of 32 modules |
| Bed Spikes, reinforced Bed Spikes | Validated owner landing report through actual damage exchange and confirmed six-point wear | Native owner animation playback still needs connected rendering |
| Poke Floor | Owner report, immediate first strike, one hit per stroke, confirmed wear | Network transit still exists; no promised zero-delay visual |
| Concertina Wire, Barbed Panel | Owner report through real contact geometry, V2 damage and confirmed wear | Fixture supplies support discovery; native support/services are tested separately |
| Spike Barrier | Existing owner marker report through V2; duplicate marker does not repeat damage | Fixture supplies collider identity/front classification; geometry/authority cases remain in existing suites |
| Tether Dart | Production cycle/impact/pull callbacks through V2, separate 30/15 damage | Collision query/support are doubles in this replay; visual pull remains connected-test work |
| Tacks, Martyrdom and Synergy | Tack owner report through V2; shared contact-overlap checks; native OnTick Martyrdom root and Synergy child death | Native server has no connected owners |
| Button, Lever, Pressure Plate, Laser, Controller | Existing authoritative input, linking, target-policy, privacy, battery and transfer suites rerun; explicit Arc/empty-Potato trigger regression | Trigger-to-turret live timing and observer state remain unproven |
| Module Pack observers | Existing eight-tile visibility, miniature texture, cancellation, ordering, death/disconnect and idle-traffic checks rerun; pack audit also rerun | No new connected-player display acceptance |

The exact 339 head/module rows are retained in [the matrix](evidence/c509-hit-matrix.tsv). Native item creation independently checks all 36 catalog identities and all 360 compatibility/stat cells: 329 supported. This native catalog test explicitly reports `firing=false` and `clients=0`; it is not substituted for connected firing.

Existing focused suites cover automation variants/360/Filter, ammo and conservation/void, capacity swapping/inactive slots, reload/autoloader, battery/regulator/grid/controller reserve, Siphon source/generation/refund guards, Lure cadence, conditional health, critical/velocity/range/rate/suppression, projectile splitting/fragmentation/piercing, procs and Synergy. See `tools/tests/controls.lua`, `targeting_policy.lua`, `targeting_combat.lua`, `firearms.lua`, `content_c247.lua`, `conservation.lua`, `regulator.lua`, `corrections_c314.lua`, `conditional_modules.lua`, `offensive_modules.lua`, `synergy.lua`, `turret_arc.lua`, `corrections_c503.lua` and `corrections_c505.lua`.

## Final evidence

- Source Kahlua suite: **40,287 assertions passed**. Focused protocol fault replay: **189 assertions passed**. Native translation loading resolves 1,525 keys. No new player-facing text was introduced.
- Added transport checks: 129 simultaneous victim requests; 600 sustained hits; 600 distinct recent victims; old Apply replay after receipt replacement; duplicate receipt settlement; combined Arc reservation cleanup.
- Existing contact-report stress: 1,000 actors, 7,680 accepted reports, at most 32 frames per packet. This is reporting throughput, **not** 1,000 simultaneous damage completions or a game-FPS claim.
- Controlled comparison still measures two message legs versus four in the packaged baseline. At 50ms per leg, owner application is 50ms versus 150ms, and settlement 100ms versus 200ms. These are simulation delays, not a measured real connection.
- Isolated stock 42.21 dedicated server loads the current source: native catalog, API/corpse guards, production firing/services, native Bed/Wire/Tack contact and Martyrdom/Synergy pass. **Zero clients connected.** Vanilla startup map/property warnings remain; no mod callback exception was accepted as a pass.
- Exact source/native-cache hashes, before-fix failures and final logs are indexed in [verification evidence](evidence/c509-verification.json).

Reproduce with `tools/check_combat_path.py --full --compare --checkpoint c509`, `tools/check_multiplayer_regressions.py`, and `tools/smoke_turret_authority.py --source`. These commands write isolated diagnostic outputs; they do not build release Contents, install, stage, publish or change the live server.

## Remaining release gate

**Packaging remains on hold.** No version bump, new release tag, install, Workshop stage/upload, sibling change or live-server update. Preserve the cumulative Workshop draft and add the final candidate changes when the release gate opens.

The next proof must be a connected two-client candidate session: native ownership/animation handoff, rapid trap crossings and corpse carrying, observer aim/projectile parity, packet delay/loss, Module Pack display, and Horde/XP attribution. Current results establish the repaired Lua paths and native server compatibility, not that multiplayer now feels smooth. The prior GitHub automatic approval-review block remains; no alternate push route was attempted.

**Wait for a patch.**
