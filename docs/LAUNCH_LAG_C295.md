# C295: whole-PC slowdown investigation

2026-10-17. Owner reports slowdown when launching/playing and clarifies: starts at the main menu, stops on exit or minimize. No completed corrective acceptance or authorization to change display settings, Java agents or third-party mods is inferred. Installed 0.2.53.4 remains unchanged.

## Evidence

- Current console confirms SP 42.21 and both T&T packages at 0.2.53.4. Roughly 235 KB at capture, no OutOfMemory/GL_OUT_OF_MEMORY, Object-tried-to-call or ExceptionLogger matches. This is not evidence of zero possible faults. Existing startup warnings include Firearms formatting, missing font textures, and a missing backpack-model bone. No recurring T&T exception flood was found.
- Windows host reads show one ProjectZomboid64 process, no leftover Java/native test servers, normal priority, approximately 6.1 GiB resident / 11.3 GiB private memory, approximately 94.6 GiB physical memory free, zero page reads/input and no disk queue pressure in the sample.
- A four-second CPU delta places the game at 7.91% of all 32 logical processors. Earlier instantaneous CPU metrics fluctuated; no sustained full-machine CPU saturation was established.
- NVIDIA sample: RTX 4090 Laptop, driver 616.92, 37 C, 38% GPU utilization, 6654/16376 MiB total VRAM used; the game committed approximately 4.6 GiB dedicated memory. No GPU heat/VRAM exhaustion was established. Short driver-event query returned no matching display/storage/hardware error; this is not a comprehensive driver trace.
- Display settings: windowed 2560x1369, frameRate=144, uiRenderFPS=120, VSync enabled, pause on focus loss enabled. Native MainOptions.lua confirms supported game/UI frame-rate controls and VSync application. Both NVIDIA and Intel display adapters report active 2560x1440 modes; this alone does not prove the game's presentation route or a hybrid-display fault.
- Foreground/minimized state was not observed during sampling. Therefore these measurements cannot exclude a spike confined to the reported visible-window condition. No temperature/CPU/GPU trace was captured through the actual transition.
- ZombieBuddy reports Loader.loadMods() took 1,125,093 ms (18.75 minutes), followed by normal mod loading of 4,270 ms. Viewpoint, ViewpointSurface and ViewpointRollingHills Java add-ons were denied; Rolling Hills subsequently reports its Java component unavailable. Approval-dialog wait can be included in elapsed loader time. This is a separate startup anomaly, not proven CPU usage or the explanation for continuing desktop lag.
- Startup disk report shows about 35 GB free on a 3.8 TB volume. Low free space is recorded separately; current counters do not show disk saturation or paging, so it is not assigned as the cause.

[Selected console evidence](../diagnostics/v0.2.53.4/launch-lag-review.json). Raw console was not published.

## T&T review

C294 Controller discovery only runs for an open Controller window. Native callback retries attach only for pending multiplayer transfers. Remote renewal is request-driven. No T&T OnFETick handler exists. Existing range/connection rendering depends on world selections/open panels. These facts make the reported pre-world main-menu symptom a poor match for the five C294 corrections, but are not a controlled exclusion of all T&T interactions.

The observed in-world T&T summaries generally show 12-32 ms maximum active update gaps after startup, and around 2-4 ms maximum range-draw duration. These counters cover limited sections, exclude pauses, and do not measure desktop responsiveness or the entire renderer. No GPU acceptance or complete performance pass is claimed.

## Next diagnostic step

Leading area to isolate: visible-window rendering/presentation, including frame pacing, VSync/driver interaction or a Java/overlay hook. Do not identify a specific driver/mod as the cause yet, raise Java heap, reinstall drivers, disable integrations or patch unrelated turret code on this evidence.

Recommended short comparison, using native Options and no world changes:

1. At the main menu, set game frame cap to 60; leave VSync and other settings unchanged.
2. Keep the game visible and compare desktop responsiveness against minimized. If fixed, report that before further changes.
3. If unchanged, turn VSync off at the same 60 cap and repeat the visible/minimized comparison. Restore VSync if this does not help.
4. Report which state helps. If neither does, next isolate the Java-agent/overlay route with a separate launch before modifying gameplay; no save needs loading for this symptom.

This test is proposed, not performed. Owner's usual 144 cap can be restored after comparison. Reducing UI render rate is a subsequent isolated option, not bundled into the first comparison.

## Owner follow-up (C296, 2026-10-17)

Owner reports **Solved**. No specific setting or cause was identified in that reply. Close this diagnostic as owner-reported resolved without attributing it to the mod or a particular display setting.
