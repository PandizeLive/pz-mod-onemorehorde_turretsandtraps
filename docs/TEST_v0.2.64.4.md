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

## C428 owner findings, 2026-10-22

Owner reports Fragment's inappropriate pistol cue, insufficient Arc firing/impact audibility, dark Arc core/unfeathered halo/no world light, and a laser overlay visible through the player. Sandbox grouping, capitalization, decimal notation and duplicate Mod Options remain unacceptable. Timing and progression were requested as audits, not reported as passed. Unmentioned prior checklist items are not implicitly accepted.

Captured SP console confirms 0.2.64.4 at diagnostics/captures/20261022-224045-0945; console SHA256 99A7AECD8F860E567ACD681221FFB34068D9D70E029C618D374BF48E99F5237D. No OMHTT exception stack found. Native map, unrelated translation and clothing model warnings remain. The saved global module-loot multiplier is 1.011111111111111; this audit does not round or replace it.

[C428 audit](AUDIT_C428.md) confirms source causes and proposed fixes; [progression analysis](PROGRESSION_C428.md) records current tuning. No new automated gameplay pass, native rendering acceptance or connected-client acceptance is claimed. Source, installed package and immutable test tag remain unchanged. Further patch scope is awaiting discussion/selection; this is not another test request.
