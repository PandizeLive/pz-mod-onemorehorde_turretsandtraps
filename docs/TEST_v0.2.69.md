# 0.2.69 verification

## Automated evidence

Final validation passes 29,091 assertions, compilation of 350 runtime/translation files, 440 Source files, 602 packaged files and 401 explicit translation keys. The focused garage matrix runs production code against single-player and server-mode doubles, including both axes/faces, suspend/resume, unsupported double gates, delayed binding, damage retirement and independent removal. Native gameplay evidence below is distinct from these doubles.

Native installed 42.21 write/read startup/save/shutdown probes pass in 54.5/56.1 seconds with no connected player. Real actor boundary contact now passes 32/32 positions across eight coordinates/two axes/two sides; full panel lookup at coordinate 16384 now finds both opposite faces. Tile centers, wrong floors, segment endpoints and positions beyond the small allowance remain excluded in regressions. The tests cover controlled native positions, not a full rendered AI motion loop at every custom-map coordinate.

Six native garage segments cover all three segment indices in both orientations, with twelve independently attached faces. Twenty-one native segment toggle calls verify closed-only contact, restored visibility, unchanged health and object count. Native serialization and a fresh-process reload preserve three raised and three closed segments. Closing restored segments restores markers; removing one face retains the other; backing destruction retires remaining panels. The native segment toggle uses isolated squares; propagation across a player-built full three-segment group and rendered interaction remain owner checks.

Native backing thump still lowers 137 HP to 136 with two panels installed. Frames remain passable and are not thump targets. Shared health is unchanged by opening and closing. The transparent marker is a one-pixel reference into the existing BARB page; native pack decoding verifies zero alpha at that pixel. No new atlas page or duplicated bitmap was added (103 Traps entries, 38 Turrets entries, 59 pages).

Initial verification failures were fixtures: the new square double lacked native solid predicates, the actor double returned tile-center coordinates rather than its assigned position, and restored-object cleanup used single-player Lua while Java still used server packet removal against unregistered isolated squares. Native source confirms packet removal resolves the real world grid. The final restore/cleanup call temporarily aligns the native server flag with the fixture's existing single-player mode, restoring it in a finally block. Physical removal now passes; no production removal code was weakened or changed. Native fixtures and server-mode doubles do not establish connected multiplayer acceptance.

Independent package starts and installed/tag/archive verification pass as recorded below. Source/package changes require no new world; saved settings and item identities remain intact. The original owner's rendered scene is not confirmed reproduced; the coordinate-related failure mechanism is reproduced and corrected.

## Owner checklist (deferred until available)

- Opposite-side Barbed Panel contact.
- Garage panels while opening and closing.
- Garage panels after reloading.
- Backing damage and independent panel removal.

Earlier 0.2.68.3 checks remain deferred. No owner acceptance, Workshop upload or connected multiplayer result is claimed.

## Package verification

Traps-only, Turrets-only and combined native startup/save/shutdown all pass in 50.0, 50.4 and 50.8 seconds respectively. All final source/package bytes match the validation manifest. Installation evidence follows the immutable source tag.

## Local installation evidence

Installed 2026-10-26 from immutable test/v0.2.69 at 2232aa6fed541c7ca31fbc36a496caeec960cc79. Verified all 440 source files and all 602 tag/package/installed/archive files (230 Traps, 372 Turrets). Both prior 0.2.68.3 packages were backed up and verified at diagnostics/p1c1/install-backups/20261026-172932-4898. Archive artifacts/OMHTT-0.2.69.zip SHA256: a7cb201c09f0cc2e39541be2f29e2a93e58820f13c76717c2166139041652098. Evidence: diagnostics/v0.2.69/local-release.json.

The generic release recorder retains historical fresh-world wording; this patch requires no new world. Restart before testing. Earlier owner checks and rendered/connected multiplayer acceptance remain deferred. GitHub mirroring remains blocked by the prior automatic approval review requiring explicit destination/payload authorization; no retry, Workshop upload or sibling modification occurred.
