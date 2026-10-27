# 0.2.70.2 verification

## Automated evidence

- Full foundation validation passes **36,482 assertions**, including the C490 regressions and the regular module-pack audit. World/player/network/UI fixture objects are doubles.
- Regressions cover startup coalescing; real versus simulation time; a stationary arrival; 100 early requests producing one deferred latest-position snapshot; no stationary polling; no idle player enumeration; split-screen duplicate/late-arrival handling; removal after leaving; simulation expiry; dead/disconnected request cancellation; 512 fields in 16 native-serialized batches; and one snapshot per server tick with both requesters progressing.
- 512 creations/removals with 32 connected-player doubles and one nearby recipient produce 1,024 targeted deliveries, zero global broadcasts and zero deliveries to unrelated distant players. This is not a measured game FPS/bandwidth result.
- Multiplayer status/Controller text resolves **201 translation keys**. Native JSON loading/substitution passes **1,525 keys**. Existing English fallback remains; no missing label found in reviewed paths. Rendered multiplayer acceptance is still pending.
- Source/package validation: **446 source files / 614 packaged files**, with a matching SHA-256 manifest. Banned-call, translation, asset and package-independence checks pass.
- An initial validation invocation redirected output to the validator's own `validation.log`, causing a Windows sharing violation after checks. Rerun to separate `validation-run.log` completed successfully; no gameplay change was needed.

## Native and local delivery

Native write/read pass in 65.2/53.4 seconds, with zero connected clients. Traps/Turrets/both startup checks pass in 62.3/48.2/56.7 seconds. Tagged local installation is next. No connected-client acceptance is claimed.

## Owner checks when available

Restart to load this version; no new world required. Connected testing remains deferred by the owner.

- Tack discovery after movement and fast-forward.
- Tack expiry and cleanup after leaving.
- Multiplayer notifications and Controller status text.

No sibling gameplay, website deployment or Workshop upload is included. Private mirroring remains blocked by the earlier automatic approval review requiring explicit destination/payload authorization.
