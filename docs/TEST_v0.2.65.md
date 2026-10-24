# 0.2.65 verification

## Owner checklist

Restart before testing; use a fresh progression test world.

- Manuals and Turret Specialist
- Firearm installation knowledge
- Sandbox sections and rarity dropdowns
- Existing loot tuning
- Mod Options volume and visibility
- Arc glow, light, fade and audio
- Fragment audio by head
- Laser obstruction
- Fast-forward combat and Tack lifetime

## Automated evidence

27,553 assertions pass, including game-time acceleration/pause, bounded tether debt, inherited manual tiers/custom overrides, pack exclusion, exact numeric selector round-trips and rotary coverage. All 325 runtime/translation files compile. Native model import and current shader/render bytecode checks retain the GPU limitation. Source/package manifest: 419 source files, 570 packaged files (219 Traps / 351 Turrets). Package dependency checks confirm 141 identical shared files and independent trait registration.

The native progression probe confirms five literature items teach six known-recipe identifiers, Firearms knowledge controls mounting, Specialist costs two with six knowledge grants, no equipment and no XP boost. Native character binary serialization proves learned and trait knowledge survive loading. Native write (50.8s), read (53.5s), Traps-only (51.9s), Turrets-only (45.2s) and combined (49.7s) startups pass with clean shutdowns. Installed from immutable test/v0.2.65 / 8a977bc60ea4845646f8bfb20a8eb7d7cd4b5f19. All 419 source and 570 package/tag/install/archive files match; both 0.2.64.4 backups verify. Local release evidence: diagnostics/v0.2.65/local-release.json. **Test now** after restart when available.

Local LootLab weight/tier/package tests and all seven cloud-schema migration tests pass, including custom saved rarity anchors for newly added manuals. The regenerated map has 32,307 eligible containers and 98 distribution routes across 21 pools; 38 catalog entries include five manuals. Exact owner tuning is retained. These are extracted vanilla-map locations and probability-model checks, not measured survival acquisition times or hosted publication.

Audio evidence: diagnostics/v0.2.65/audio-balance.json; selected capture provenance remains art/ARC_AUDIO_SELECTED.json. Derived Arc firing is 14dB louder, with measured active shot RMS within 3dB of the reference shots and peaks below clipping. Listening with overlapping/spatial cues remains pending.

Initial verification failures identified outdated fixture expectations for the removed Automation veto, new head-specific sounds, game-time clocks, manual item family/defaults and shader lights. Native cycle testing also found a real remaining wall-clock Button pulse; production now uses the receiver's simulation clock. No errors were suppressed to pass validation. Current successful evidence supersedes those attempts; diagnostic probes remain local.

Owner rendering/listening, connected multiplayer, Horde Night integration in an active game and stress FPS acceptance remain pending. Dedicated native probes have zero connected players. No public upload, merge or hosted deployment.


## C438 owner feedback (2026-10-24)

Owner reports missing trigger consumption colors, inconsistent grey/wrapped Feature descriptions and expansion text, unsorted module slots, and rejected kit replacements. Requests inactive module storage, ammunition overflow during kit downgrade and explicit unsupported-head feedback. These presentation/transfer behaviors are **failed or missing**, not accepted by the previous automated checks. [Source diagnosis and proposed corrective contract](FEEDBACK_C438.md).

Captured current console: 0.2.65 SP, 2,463,426 bytes, source modified 2026-10-24 00:42:20 local; local copy and hash in diagnostics/c438/evidence.json. TransferFull admission messages and M4/M9 effective stats are present. No OMHTT-attributed exception stack found; vanilla/map and Firearms translation/model warnings remain. This is not a complete no-errors claim.

A separate stock-Kahlua calculation executes current Stats/Estimate with source defaults and firearm fixtures, includes reload/rack, and confirms the eight-copy Rapid rate cap and five-copy Velocity damage cap. The source probe exits 0; results are theoretical raw DPS, not a live timing or balance acceptance test. Existing compiled harness prints 27,458 assertions for that optional run; it does not replace or extend the packaged 27,553-assertion release result. See diagnostics/c438/balance.lua and balance.log.

No gameplay/source/package/install changes. Manuals/progression, audio/rendering, live Horde Night, stress FPS and connected multiplayer acceptance remain pending unless separately confirmed; this feedback does not implicitly pass those features.
