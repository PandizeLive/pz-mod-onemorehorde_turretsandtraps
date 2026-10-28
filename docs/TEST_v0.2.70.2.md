# 0.2.70.2 verification

## C493 connected owner test: failed (2026-10-28)

[Client/SFTP evidence and proposed correction](MULTIPLAYER_FEEDBACK_C493.md). Both sides loaded T&T 0.2.70.2 on PZ 42.21.0. Server Horde 0.6.16.5 / Trait Shop 0.9.0.1 lagged client 0.6.16.9 / 0.9.1.1. Confirmed 23 client combat API exceptions and Private inspection bypass; production-function reproduction identifies transfer invalidation after the server moves the first potato. Observer effects remain unresolved. Earlier automated passes remain valid within their recorded fixture/ownerless scope and do not establish connected acceptance. No gameplay patch installed; owner approval pending.

## C492 Workshop preparation (2026-10-27)

[Staging, launcher and verification](WORKSHOP_UPLOAD_C492.md): 614 tagged package files staged and hash-verified for the owner's first in-game Unlisted upload. Installed-game Workshop validation passes, including the owner-supplied still exported to 512x512. Fifteen isolated tooling checks and existing installer regressions pass without Steam calls. Gameplay/tag/install and connected-player acceptance remain unchanged. The owner subsequently confirmed native upload success for item 3828638252, establishing the first per-item content baseline; the project records that exact ID. No cumulative changelog notes were cleared.

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
