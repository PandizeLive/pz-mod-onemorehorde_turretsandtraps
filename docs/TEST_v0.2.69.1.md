# 0.2.69.1 verification

C481, 2026-10-26. Owner approves C479/C480. Prior0.2.69 contact feedback remains positive; garage/reload/connected-player acceptance and earlier deferred checks are not promoted to passes.

## Automated and native evidence

- Full installed-Kahlua regression:34,428 assertions,350 Lua/translation compilation checks,444 source files and610 packaged files;401 package translation keys. Native parser validates all four reaction definitions; native actor tests verify suppression and restoration of the previous deferred-movement setting.
- Direction matrix:24 initial facings by8 bearings,10 updates per pull; no initial snap, maximum9 degrees per50ms and45 degrees total, inward pending movement and cleanup. Includes zero-distance, obstacle, competing reaction, climbing, fast-forward and observer/duplicate/identity guards. World/UI/network objects in this suite are test doubles.
- Native actor probe:960 real IsoZombie direction/pending-movement steps. No native stagger, no direct teleport; real angle setter stays within the turn bounds. Production impact applies no shove. This headless test does not render animation clips.
- Current 42.21 AnimationPlayer/AnimationTrack bytecode in diagnostics/c479 proves node movement flags are not copied into playback. An attempted track-access implementation failed the native Lua probe because AnimationPlayer is not exposed; it was removed. The final implementation uses the exposed actor movement gate, with automated/native restoration checks. Live visual blend/first-frame acceptance remains pending.
- Controller regressions cover title/background/release/scroll hit regions, retained map range calculations without a circle, responsive map/settings geometry and existing scrolling.
- Source review: no new full-world scan, global movement switch, event, polling timer or persistent per-target record. Existing weak active map and owner-routing are reused; inactive actors return immediately. The actor gate is saved/restored without inspecting animation tracks.

Final native write/read, independent package startup and installation evidence will be appended after completion. Evidence files: diagnostics/v0.2.69.1/validation.log, manifest.json, server-write.log, server-read.log and packages-*.json. These establish bounded native/runtime behavior, not rendered or connected-player acceptance.

## Owner checklist

- Tether pulling and slight turns from different directions.
- Controller map space and settings scrolling.
- Group title clicks and background clicks.

Restart before testing. No new world is needed. Connected multiplayer remains deferred; no live playtest was performed by the agent.

## Publication

Private mirror remains blocked by the earlier automatic approval-review rejection of that upload; no push retry. No Workshop upload or sibling changes. Unrelated owner edit docs/AMMO_UI_C446.md is preserved and excluded from this patch.
