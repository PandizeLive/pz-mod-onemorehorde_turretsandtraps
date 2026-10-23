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

Native persistence and installation evidence will be recorded below after completion. No GPU rendering, in-game listening, stress FPS or connected-client acceptance is claimed by these automated probes. Owner acceptance remains pending.
