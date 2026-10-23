# 0.2.65 verification

## Owner checklist

Restart before testing.

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

The native progression probe confirms five literature items teach six known-recipe identifiers, Firearms knowledge controls mounting, Specialist costs two with six knowledge grants, no equipment and no XP boost. Native character binary serialization proves learned and trait knowledge survive loading. Native write (50.8s), read (53.5s), Traps-only (51.9s), Turrets-only (45.2s) and combined (49.7s) startups pass with clean shutdowns. Installation is being finalized.

Local LootLab weight/tier/package tests and all seven cloud-schema migration tests pass, including custom saved rarity anchors for newly added manuals. The regenerated map has 32,307 eligible containers and 98 distribution routes across 21 pools; 38 catalog entries include five manuals. Exact owner tuning is retained. These are extracted vanilla-map locations and probability-model checks, not measured survival acquisition times or hosted publication.

Audio evidence: diagnostics/v0.2.65/audio-balance.json; selected capture provenance remains art/ARC_AUDIO_SELECTED.json. Derived Arc firing is 14dB louder, with measured active shot RMS within 3dB of the reference shots and peaks below clipping. Listening with overlapping/spatial cues remains pending.

Initial verification failures identified outdated fixture expectations for the removed Automation veto, new head-specific sounds, game-time clocks, manual item family/defaults and shader lights. Native cycle testing also found a real remaining wall-clock Button pulse; production now uses the receiver's simulation clock. No errors were suppressed to pass validation. Current successful evidence supersedes those attempts; diagnostic probes remain local.

Owner rendering/listening, connected multiplayer, Horde Night integration in an active game and stress FPS acceptance remain pending. Dedicated native probes have zero connected players. No public upload, merge or hosted deployment.
