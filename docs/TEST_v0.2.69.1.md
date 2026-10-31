# 0.2.69.1 verification

C481, 2026-10-26. Owner approves C479/C480. Prior0.2.69 contact feedback remains positive; garage/reload/connected-player acceptance and earlier deferred checks are not promoted to passes.

## Automated and native evidence

- Full installed-Kahlua regression:34,428 assertions,350 Lua/translation compilation checks,444 source files and610 packaged files;401 package translation keys. Native parser validates all four reaction definitions; native actor tests verify suppression and restoration of the previous deferred-movement setting.
- Direction matrix:24 initial facings by8 bearings,10 updates per pull; no initial snap, maximum9 degrees per50ms and45 degrees total, inward pending movement and cleanup. Includes zero-distance, obstacle, competing reaction, climbing, fast-forward and observer/duplicate/identity guards. World/UI/network objects in this suite are test doubles.
- Native actor probe:960 real IsoZombie direction/pending-movement steps. No native stagger, no direct teleport; real angle setter stays within the turn bounds. Production impact applies no shove. This headless test does not render animation clips.
- Current 42.21 AnimationPlayer/AnimationTrack bytecode in diagnostics/c479 proves node movement flags are not copied into playback. An attempted track-access implementation failed the native Lua probe because AnimationPlayer is not exposed; it was removed. The final implementation uses the exposed actor movement gate, with automated/native restoration checks. Live visual blend/first-frame acceptance remains pending.
- Controller regressions cover title/background/release/scroll hit regions, retained map range calculations without a circle, responsive map/settings geometry and existing scrolling.
- Source review: no new full-world scan, global movement switch, event, polling timer or persistent per-target record. Existing weak active map and owner-routing are reused; inactive actors return immediately. The actor gate is saved/restored without inspecting animation tracks.

Final native write/read passed in 79.3/87.7 seconds; all three independent package startups passed. Evidence files: diagnostics/v0.2.69.1/validation.log, manifest.json, server-write.log, server-read.log and packages-*.json. These establish bounded native/runtime behavior, not rendered or connected-player acceptance.

## Owner checklist

- Tether pulling and slight turns from different directions.
- Controller map space and settings scrolling.
- Group title clicks and background clicks.

Restart before testing. No new world is needed. Connected multiplayer remains deferred; no live playtest was performed by the agent.

## Publication

Private mirror remains blocked by the earlier automatic approval-review rejection of that upload; no push retry. No Workshop upload or sibling changes. Unrelated owner edit docs/AMMO_UI_C446.md is preserved and excluded from this patch.


## Final installed evidence

- Immutable tag: `test/v0.2.69.1`; source commit `c31de5cedfacd885283172d6193763371d2a1a3f`.
- Final package-only starts: Traps/Turrets/both 71.9/75.6/67.8 seconds. Native write/read:79.3/87.7 seconds, with no connected player. Earlier intermediate track-access failure was corrected before tagging and all final checks passed.
- Local install: `C:\Users\bandi\Zomboid\mods`. All 444 source and 610 package/tag/install/archive files verified; both 0.2.69 package backups verified.
- Backup: `C:\Users\bandi\Zomboid_Modding\OMH\Turrets & Traps\diagnostics\p1c1\install-backups\20261026-192807-1839`.
- Archive: `C:\Users\bandi\Zomboid_Modding\OMH\Turrets & Traps\artifacts\OMHTT-0.2.69.1.zip`; SHA-256 `3bc1051c9492d3d0d36341be52e5b80c632ce6ed1d4792416904e64e2e9df865`.
- Machine-readable evidence: `diagnostics/v0.2.69.1/local-release.json`. Its historical generic `fresh worlds` field is not a new migration requirement: this correction needs a restart only.
- Private mirror remains blocked by the prior automatic approval review requiring explicit destination/payload authorization. No retry, public upload, sibling modification or owner-save change.

**Test now after restart when available.** Rendered and connected-player acceptance remains pending.


## C482 - Owner repeat-interruption report (2026-10-26)

Owner reports tether stun/pull repeats as a loop and requests a longer refire delay; settings need compact reordering. Captured console confirms both packages0.2.69.1 / game42.21, reset0.5, hold0.75, return speed4 and pull distance0.75. Capture: diagnostics/captures/20261026-202614-9485, console SHA-25613ae4650921b4f7c0dab048b0f188c0431e11322dad3148d4b472306aa320824. No OMHTT exception stack found; the log does not measure per-target recovery. This is a reported gameplay-balance failure, not full acceptance or a failure of the previously recorded source/native checks. See [proposed correction and mockups](CONTROLLER_SETTINGS_C482.md). No new build, installed tuning change or owner retest request in this discussion. Connected-player acceptance remains pending.
