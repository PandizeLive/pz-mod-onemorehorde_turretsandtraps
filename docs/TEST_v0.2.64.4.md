# 0.2.64.4 verification

## Owner checklist

Restart before testing the installed build.

- Arc volume, glow and fade
- Lever wall alignment
- Tether nail and cable height
- Controller battery, expansion and status layout
- Automation rarity icons
- Battery totals and Regulator reduction
- Repair requirement labels

## Automated evidence

27,534 assertions pass; 317 runtime/translation files compile. The package manifest contains 408 source files and 554 packaged files (214 Traps, 340 Turrets). Tests cover the selected tier schedule, tooltip totals/cache invalidation, all Automation rarities, equipment geometry, repair labels, Arc opacity timing/expiry/visibility/draw budget and Tether launch/floor heights. Native static-model import verifies the new eight-vertex/four-triangle Arc mesh. Current installed bytecode verifies the chunk camera transform, item alpha and native model renderer path.

Traps-only, Turrets-only and combined native startups pass (66.3, 53.9 and 61.5 seconds). Initial persistence attempts exposed two stale test expectations from the previous rarity schedule: the M9 loaded-power fixture and the Synergy/Martyrdom/Tack fixture. Their old failure transcripts are preserved; expected values were recalculated against the approved schedule. They were not gameplay exceptions hidden by the patch.

Native write/save and fresh-process restore pass (read 58.2 seconds), with zero connected clients. The successful write transcript was revalidated against every post-process assertion after updating the Python runner's stale M9 summary marker; the Lua checks had already completed and the server shut down cleanly. Installed from immutable test/v0.2.64.4 / 208e353dceef5a14a09c26038943d694bcd40ee8. Release verification matches all 408 source files and 554 tagged/package/install/archive files, plus both complete 0.2.64.3 backups. [Local verification record](../diagnostics/v0.2.64.4/local-release.json). C108 development mirror accompanies this handoff. No GPU rendering, in-game listening, stress FPS or connected-client acceptance is claimed by these automated probes. Owner acceptance remains pending.
