# C528 - Approved rotary correction

Owner selected C527 **1A** on 2026-10-31. This authorizes the complete rotary correction, verification and local test delivery. It does not authorize Workshop publication or live-server changes.

## Final behavior

- Rotary rendering always uses one motor timeline. The stale generic interpolation fallback is removed. Start, running, stop, long idle and restart retain the same display state. Missing snapshots predict for at most750ms, then settle; corrections are bounded to1.5 times the motor speed per frame. No new idle snapshot traffic is required. Both cone reversal and360 rotation use this path.
- Rotary distance, bearing, detection and hit origin use the same accepted owner position. Reports must retain matching owner/connection/outfit and be at most250ms old. Missing/stale owner reports cannot substitute older native coordinates. Prone exclusions, wall/reach and per-arm/pass deduplication remain.
- Rotary applications expire500ms from the validated observation, including time spent queued. They cannot use the longer projectile lifetime or renew their contact timestamp at dispatch. An expired hit is dropped, not replayed late. High-latency loss is possible and preferable to old-contact damage; no zero-latency guarantee is made.
- Shared Impact reactions use native posture and authoritative remote state rather than lowercasing an optional animation name. The asynchronous rotary callback completes its module reservation cleanup when the animation name is nil. Five-second reaction protection remains.
- Bounded diagnostics correlate rotary snapshot/display, sweep/contact, owner application and visible damage. Server damage/death/XP/Horde authority remains unchanged.

## Evidence

Three frozen0.2.71 paths fail the new named assertions; the corrected full suite passes43794.0 assertions. [Regression receipt](evidence/c528-regressions.json). Tests invoke the actual renderer and rotary contact code, not only the interpolation helper. The reproduced idle-stop burst falls from18 degrees per10ms to0 in the stopped replay. Cone/360 transitions, restart, packet gaps and delayed stops stay within the correction limit.

Current native42.21 objects have a nil animation name in the reaction probe. Both SP-mode and server-mode branches accept one reaction and block its repeat without throwing. Native world write/fresh-process read and Traps-only/Turrets-only/combined starts pass with actual0.2.71.1 runtime markers. Existing whole-catalog module/head checks remain included. Motion transport and GPU presentation are not reproduced by the zero-client native probe.

Expiry tests cover a late arriving rotary application and a rotary hit queued behind another shot; both reject after the original observation expires. Fresh valid application remains covered by the multiplayer matrix. Owner handoff, stale positions, outside-range reports, grounded actors, missing animation name and reservation release are explicit cases.

During verification the first candidate had an unchanged Foundation version despite a bumped mod.info. Native validation caught it; both now match0.2.71.1. The traps-only start was repeated after correction. Package smoke now requires the loaded packages-ready version marker as well as its success marker. Fixtures were corrected to supply native getZ/getOnlineID, native getup state, and an accepted owner report; no runtime guard was relaxed to pass them.

## Release baseline and limits

Confirmed upload of0.2.71 to item3828638252 establishes the new changelog baseline; [publisher receipt](evidence/c528-upload-baseline.json). The0.2.71.1 draft contains only subsequent net fixes. Owner edits in AGENTS.md, README.md, docs/AMMO_UI_C446.md and docs/RELEASE.md are preserved outside this commit.

No connected client participated in automated verification. Smoothness under the owner's connection remains pending; server scheduling and transit still exist. No assets, balance values, save schema or sibling project changed. No new world is required. Prior automatic approval-review rejection of the GitHub mirror remains; no alternate push route is attempted.
