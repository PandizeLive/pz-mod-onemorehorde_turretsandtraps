# 0.2.70.2 verification

## Automated evidence

- Full foundation validation passes **36,482 assertions**, including the C490 regressions and the regular module-pack audit. World/player/network/UI fixture objects are doubles.
- Regressions cover startup coalescing; real versus simulation time; a stationary arrival; 100 early requests producing one deferred latest-position snapshot; no stationary polling; no idle player enumeration; split-screen duplicate/late-arrival handling; removal after leaving; simulation expiry; dead/disconnected request cancellation; 512 fields in 16 native-serialized batches; and one snapshot per server tick with both requesters progressing.
- 512 creations/removals with 32 connected-player doubles and one nearby recipient produce 1,024 targeted deliveries, zero global broadcasts and zero deliveries to unrelated distant players. This is not a measured game FPS/bandwidth result.
- Multiplayer status/Controller text resolves **201 translation keys**. Native JSON loading/substitution passes **1,525 keys**. Existing English fallback remains; no missing label found in reviewed paths. Rendered multiplayer acceptance is still pending.
- Source/package validation: **446 source files / 614 packaged files**, with a matching SHA-256 manifest. Banned-call, translation, asset and package-independence checks pass.
- An initial validation invocation redirected output to the validator's own `validation.log`, causing a Windows sharing violation after checks. Rerun to separate `validation-run.log` completed successfully; no gameplay change was needed.

## Native and local delivery

Native write/read pass in 65.2/53.4 seconds, with zero connected clients. Traps/Turrets/both startup checks pass in 62.3/48.2/56.7 seconds. Installed and hash-verified from immutable test/v0.2.70.2 / 42822d3a78a69f8b31ed1719db933196a23b6aa3. All446 source and614 tag/package/install/archive files plus both0.2.70.1 backups match. No connected-client acceptance is claimed.

## Owner checks when available

Restart to load this version; no new world required. Connected testing remains deferred by the owner.

- Tack discovery after movement and fast-forward.
- Tack expiry and cleanup after leaving.
- Multiplayer notifications and Controller status text.

No sibling gameplay, website deployment or Workshop upload is included. Private mirroring remains blocked by the earlier automatic approval review requiring explicit destination/payload authorization.

## Local delivery record

Backup: `C:\Users\bandi\Zomboid_Modding\OMH\Turrets & Traps\diagnostics\p1c1\install-backups\20261027-001431-9517`. Archive SHA-256: `2864510de800571dac9cb5d387be01531403d73a224f8c3f8213e06148867f0a`. Machine-readable evidence: `diagnostics/v0.2.70.2/local-release.json`. The stable installer/record tool retains generic fresh-world wording from the original split; this corrective patch requires only a restart, not a new world.

Owner `docs/AMMO_UI_C446.md` remains untouched (SHA-256 `24506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba`). No gameplay sources changed after validation/tagging. C488 remains undeployed. **Test now when available.**
