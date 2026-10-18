# 0.2.55.1 verification — C324

## Owner-reported failure

0.2.55 is **not accepted**. Owner reports game freeze/exit, errors and a scrollbar in the screen interior; later suspects one overloaded CPU core. The captured console identifies loaded version 0.2.55 and contains **454** `attempted index: refreshDue of non-table: null` exceptions, all from `ControlGraph.lua:65` through native `UIElement.update`. Its ending records world/GlobalModData saving and `GameThread exited`. No new `hs_err_pid` report was found in the game/user-root locations checked. No CPU profile or core-utilization recording is available.

The local raw console is preserved under `diagnostics/v0.2.55.1/owner-console-0.2.55.txt`; only a sanitized summary/hash is mirrored. This supersedes the earlier automated-pass handoff without rewriting its historical results.

## Corrective evidence

Owner follow-up (2026-10-18): Controller links/gestures, resizing, Stockpile scrollbar and presentation remain unsatisfactory. [C325 findings and corrective test](TEST_v0.2.55.2.md) supersede the pending visual handoff; this version is not fully accepted. The inspected later SP console still identifies 0.2.55.1 and does not repeat the old `refreshDue` exception.

- Installed Build 42.21 stock-JAR-first validation: **21,849 assertions**, 231 compiled Lua/translation files, 298 source / 383 packaged files. Shipped Lua retains the banned-call gate: no `pcall`, `xpcall`, `ipairs` or bare `next`.
- The new regression drives 600 recursive child-widget updates with native dispatch semantics, rather than only invoking Controller refresh helpers. This catches the original method-name collision. No update errors or gameplay/remote-session commands occur.
- Native `UIElement.update` bytecode confirms it retrieves `update` through the widget table and passes that same widget as `self`, including hidden child elements. The corrected `Graph.refreshForPanel` does not occupy that callback name.
- Native `UIElement` construction/update probe reproduces deferred scrollbar anchor drift after explicit geometry changes. Disabling those anchors preserves exact right-edge placement and panel height at widths 400, 270, 540 and 310. UI geometry checks cover all three affected scrollbars, including their containing stencil policy.
- Native UIWorldMap v3 construction/signature checks pass. Adapter tests verify automatic map selection, visited-area settings, single data initialization over 100 draws, and safe map-disabled behavior. The renderer itself is not executed by this probe.
- Existing resize, persistence, exact-stockpile, drag-link permission and 32-by-32 connection tests remain passing. Geometry traces are development render adapters, not live gameplay screenshots.

Native write/read pass in 146.7 / 126.1 seconds with no connected client. Traps-only, Turrets-only and both startup checks pass in 127.1 / 115.5 / 110.4 seconds. Installed from immutable `test/v0.2.55.1` / `397d8e1449e8940cfcf65ceb77d99e31d1464d40`. All 298 source and 383 tagged/packaged/installed/archive files match; both 0.2.55 backups verify. [Release evidence](../diagnostics/v0.2.55.1/local-release.json). Rendered owner acceptance, connected multiplayer acceptance and actual gameplay CPU/frame measurements remain pending.

## Main-menu slowdown investigation (2026-10-18)

Owner reports progressively worse whole-PC responsiveness while Zomboid is focused, including at the main menu before loading a world. This is separate from the proven 0.2.55 Controller exception above. The inspected current console confirms 0.2.55.1 and does not contain the previous repeating `refreshDue` exception; this is not full rendered acceptance.

Read-only local measurements:

- Zomboid's process affinity is `0xFFFF0000`, limiting it to logical CPUs 16–31. Native `GetSystemCpuSetInformation` identifies these as the i9-13980HX's 16 efficiency cores (EfficiencyClass 0); logical CPUs 0–15 are the eight SMT performance cores (EfficiencyClass 1). Wardogs retains all processors. Earlier advice to divide processor sets omitted this important topology distinction. Recommend restoring Zomboid to **All processors**, not assigning an arbitrary half.
- An NVIDIA snapshot reports 99% GPU utilization, about 12.4 GiB of 16 GiB VRAM used and 58°C. A separate Windows GPU-engine sample reports Wardogs at about 71–73% 3D and Zomboid at about 3.6–3.8%, with Wardogs foreground. These are different samples/metrics; they do not establish Zomboid's foreground GPU demand or prove the progressive slowdown's cause.
- About 71 GiB system RAM remains available, committed memory is about 52.3%, and paging input is near zero. Current evidence does not show system RAM exhaustion.
- Across a 15-second sample with Zomboid in the background, its private memory stays near 12.163 GiB, working set near 6.816 GiB, and handles near 48,432–48,434. CPU usage averages roughly 2.05–2.43 cores worth. No growth was demonstrated in this short background interval; a foreground-only leak remains untested.
- Saved settings already specify `frameRate=60` and `uncappedFPS=false`; `vsync=false`, `uiRenderFPS=120`, and `uiRenderOffscreen=false`. Do not characterize this as a confirmed uncapped-FPS problem. The launcher also contains a native agent; no causal attribution to that agent is established.

Next isolation: restore All processors, exit Wardogs normally, then check Zomboid's main menu briefly. Stop/minimize immediately if desktop responsiveness degrades; do not deliberately reproduce a full freeze. If the symptom persists with Zomboid alone, investigate the foreground render/driver/startup-mod path separately before proposing another Controller patch. A main-menu symptom does not implicate the unopened Controller, but also does not exclude startup-loaded mods.

Owner follow-up asks whether allocated RAM could cause this. Rechecked launcher: `-Xmx16384m` sets a 16 GiB maximum Java heap, not a guarantee that 16 GiB is currently occupied or the total process limit. The inspected console has no matches for `OutOfMemoryError`, `Java heap space`, `GC overhead limit` or native-memory-allocation failure. System RAM availability and process memory are not direct heap/garbage-collection measurements; GC pressure is not ruled out. Recommend leaving the heap limit unchanged for the CPU/GPU isolation test. If the symptom remains, measure heap usage and GC activity rather than blindly raising/lowering the limit. [Java heap and memory troubleshooting](https://docs.oracle.com/en/java/javase/25/troubleshoot/troubleshooting-memory-leaks.html).

No process affinity, priority, game options, driver settings, applications, gameplay files or installed build were changed during this investigation. Root cause and owner acceptance remain unresolved. Documentation only; no new test tag or package version.

References: [Microsoft CPU-set efficiency classes](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-system_cpu_set_information), [Microsoft thread affinity guidance](https://learn.microsoft.com/en-us/windows/win32/procthread/multiple-processors#thread-affinity), [NVIDIA background application frame-rate setting](https://www.nvidia.com/content/Control-Panel-Help/vLatest/en-us/mergedProjects/nv3d/Manage_3D_Settings_%28reference%29.htm).

## Short owner test — after system responsiveness is stable

1. Restart and confirm **0.2.55.1**. Open the Controller; the in-game map should appear directly.
2. Leave it open for 30 seconds, then select several devices. Check for freezes or a growing error counter.
3. Resize wider/narrower and scroll Connections and Selected Device. Scrollbars should remain inside their sections.
4. Drag a trigger to a turret, open Manage and return to Stockpile. Close/reopen the Controller once.

After this test, inspect the new console for the previous callback exception and any new errors. Connected clients are a separate acceptance check; no connected multiplayer pass is claimed here.
