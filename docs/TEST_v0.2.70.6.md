# 0.2.70.6 verification

Scope: [C503 patch](PATCH_v0.2.70.6.md). Owner selected C502 1A. Automated and isolated native checks pass; connected acceptance is pending.

- Kahlua suite: 37,208 assertions pass, including watched-tile bounds/dedup/removal, deferred health, Poke first/late strike, two-locale labels/custom names, heading wrap/rotary travel, popup preferences/dedup and pack observer range/cancellation/order.
- Martyrdom: production server-mode admission, tick worker, damage callback and Synergy child pass with test doubles. Native real-OnTick delivery also passes on an isolated dedicated server: Bed landing once, Wire/Tack repeats, overlapping hazards single-charged, Martyrdom root and Synergy child complete native deaths. The probe uses native actors/objects with fixture square lookup and no connected clients.
- Initial native probes exposed startup wall-time assumptions and reused fixture records. The corrected harness uses a fresh isolated cache, gates phases on observed contact and has a 30-second timeout. Its final run passes without mod callback errors. This is not connected acceptance.
- Full package validation: 453 source files, 623 packaged files, native parser/translation checks pass. Native save/write (151.2s) and fresh-process read (152.8s) pass. Traps-only (137.2s), Turrets-only (139.2s) and combined (140.0s) startup checks pass. Dependency closure confirms 266 unique Sandbox identities and 160 identical shared files.
- A stale barrier-source lookup now checks that Traps is enabled before loading its optional implementation; a missing-package regression passes. No live server, Steam upload, sibling mod or player save was changed.
- [Sanitized verification](evidence/c503-verification.json). Local installation and immutable-tag verification follow after the source commit.

## Owner checklist

After publication, update/restart the server and both clients. No new world required.

- Bed Spikes, Barbed Panels and Concertina damage
- Tack damage and overlapping hazards
- Martyrdom and Synergy bursts
- Initial Blow, Execute and Poke Floor
- Pixel Strike numbers and translated device names
- Smooth aiming and rotary movement
- Nearby pack icons, cancellation and range
