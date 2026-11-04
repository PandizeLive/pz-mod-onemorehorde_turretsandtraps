# 0.2.70.2 - Tack multiplayer delivery

## C490 approval - 2026-10-27

Owner selects **1A** from the C489 readiness audit: fix both Tack delivery findings, validate and package/install locally. Owner additionally requests confirmation that multiplayer UI uses translated text rather than raw code keys. Testing remains deferred. This does not approve C488's website deployment, sibling changes or Workshop publication.

## Final behavior

- Client area-request cooldown uses real time. Tack deployment, lifetime and expiry retain simulation time.
- Server requests coalesce into one pending entry per authenticated player. The earliest eligible request is delivered at the player's current position, at most one player snapshot per tick. Early requests wait instead of disappearing. Dead/disconnected requesters are discarded. Idle frames do not enumerate players or fields.
- Creation goes only to players within the existing 100-tile axis margin. Removal goes to connected players who previously received that field, including those who moved away. Only active field identities are remembered; the authoritative field store remains unchanged. Late arrivals receive nearby snapshots. Duplicate split-screen delivery is idempotent in the existing client view.
- Existing limits remain: 512 authoritative fields and 32 rows per packet. The maximum snapshot is 16 packets. A 32-player fixture with one nearby player delivers 1,024 targeted packets for 512 creation/removal pairs, versus the old global fan-out. This is a transport-double delivery count, not an FPS or bandwidth benchmark.

The faulty silent-drop and broadcast paths are replaced. No stationary refresh loop, duplicate field store, new balance option, save migration or world reset is added. Request queues/recipient sets are session-local; fields retain their existing persistence.

## Multiplayer text review

Reviewed turret result/cycle/transfer status producers and their Manage consumers, Foundation replies/halo text, Controller notices, remote renewal behavior and batch-result reasons. These UI paths resolve translation keys on the client; raw transport codes remain appropriate inside diagnostics only. No missing label was found in the reviewed paths, so no replacement English text or generic fallback was added to conceal errors.

Release validation now checks 201 status/Controller translation keys, including concatenated status suffixes that a literal `getText` scan misses. Native loading/substitution checks all 1,525 existing translation keys. The shipped English catalog supplies fallback text; this is not a claim of newly authored translations for other languages or proof of every rendered multiplayer interaction.

## Evidence and boundaries

See [verification](TEST_v0.2.70.2.md). The C489 fixture now tests corrected behavior and runs in the regular Kahlua suite. Existing network/UI/world doubles remain distinct from connected-client acceptance.

Source/package version is 0.2.70.2. C486's accepted 0.2.70.1 baseline remains historical acceptance, not acceptance of this patch. C488's scoring candidate is still local and undeployed. Owner `docs/AMMO_UI_C446.md` is preserved. Private GitHub mirroring remains blocked by the prior automatic approval review; this turn's read-only fetch also failed with `getaddrinfo() thread failed to start`, so newer upstream changes are unknown. Work began at local `4095a50` on `codex/performance-barbed-audit`.
