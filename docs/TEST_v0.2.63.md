# 0.2.63 - C397 verification

Status: automated verification passed; tagged installation pending. Owner/rendered and connected multiplayer acceptance pending.

## Owner checklist

- Lever alignment on all four wall faces
- Turret sleep angle, wake sound and firing delay
- Tether cable joins and zombie depth
- Controller loading, selection and checking indicators
- Controller expansion, range and stockpile limits
- Module icons and compact repair tooltips
- Poke Floor contact and retracted servicing
- Sandbox grouping and readable loot values
- Laser visibility and device feedback volume

## Automated evidence

- Full validation: 26,794 Kahlua assertions; 316 runtime/translation files compile, 1,304 native translation keys resolve.
- Native JOML: 240 heading/pitch combinations match the downward barrel direction without mount translation. Existing three firearm attachment checks remain valid.
- Controller kit fixture: each grade, replacement, removal, failed insertion rollback, overfull protection, independent Traps settings and client mutation rejection.
- UI fixture: shorter numeric display preserves untouched raw values; intentional edits replace them. Progressive discovery preserves selection and bounds per-update scanning.
- Standby fixture: initial power-on wakes, alerts, delays .25 seconds and cancels if the target becomes invalid during that delay.
- Native write: passed on installed game 42.21, including kit installation/removal, 10/50 radius, 100/500 virtual capacity and exact kit pickup/redeployment. Heavy Controller has 251 preserved items.
- Fresh-process read passed (63.9s). Independent startup passed: Traps 64.6s, Turrets 60.4s, both 56.9s. Shared definitions register once; Traps-only adds 26 kit loot entries, with no turret modules or packs.
- Local LootLab metadata/default checks passed. No hosted update or browser acceptance claimed.

Initial failures exposed the native container capacity clamp and fixtures expecting retired Poke disarming/500 base capacity. Production retains native capacity <=100; stockpile allowance remains enforced through existing Controller transfers. Failed checks were corrected and rerun, not counted as passing.

## Remaining visual investigation

Lever/Laser marker projection and mount positions use a .015-tile face inset, reduced from .08. Native placement continues to exercise all orientations and built/prebuilt walls. This is not proof that the owner's visible facing problem is fully resolved.

Native fade inspection identifies container occlusion as a plausible cause of transparent bases. No explicit turret alpha mutation was found. Rendered reproduction and acceptance remain pending; no global fade override was added.

All server probes use isolated caches and zero connected players. They establish native loading, action and persistence behavior, not live multiplayer acceptance. No player saves are modified.
