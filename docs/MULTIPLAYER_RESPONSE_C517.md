# C517 - Consistent multiplayer response audit

Owner approval, 2026-10-30: "We need to ensure all traps aren't delayed like they are. 1A." This approves C516's combined aim/tether correction and a consistent audit across the complete trap sequence. Earlier approval permits corrective packaging for owner testing. No live server, Workshop upload, sibling project or gameplay balance changes are authorized by this checkpoint.

The earlier audit checked shared damage but missed separate detection and presentation waits. This checkpoint follows **discovery -> detection -> visible response -> damage -> recovery -> cleanup** for each family. A passing damage handler is not a passing rendered multiplayer test.

## Findings replaced

- Validated owner reports reached the contact router, but pressure/laser/tether occupancy still consulted older server coordinates. The existing actor spatial index now temporarily uses the validated report, with native-owner/connection/outfit checks and a 250 ms freshness limit. Native actor coordinates are never changed. Ownership change, expiry, recycling and unload discard that information. Pressure/laser/tether checks also reject stale native coordinates for client-owned actors after report expiry, instead of reactivating hazards from the old position.
- Pressure plates, lasers and tether lanes did not independently request owner contact reports. Their local discovery index now registers approach corridors; it does not scan the world each frame.
- Passive trap objects could stream before their mod data and miss indexing. Bed/Barb providers now participate in the existing bounded discovery retry instead of relying exclusively on the original load event. Pending work uses at most 64 objects/1 ms every 50 ms, then becomes idle. Wire/panel and Tack approach margins obtain the existing server permission before contact where possible.
- Changed trigger inputs waited for the 100 ms routine device scan. Dirty receivers now drain on the next tick within a 32-entry/1 ms slice; routine work keeps its fairness and existing budget.
- Tether idle detection polled every 200 ms and active flight advanced through the routine device scan. Fresh contact wakes an idle tether; concurrent contacts coalesce to at most one detection per 50 ms per trap. Active flight/hold/return/reset uses a fair 64-entry/1 ms per-tick schedule. Existing recovery and damage rules remain intact.
- Tether presentation only interpolated received distances and then stopped. It now advances from synchronized snapshots, at most 250 ms, capped by range and the server's known first obstruction. Confirmed target identity follows the locally rendered victim during embedding; retraction starts at that endpoint. SP uses its local victim reference. Clients never decide hits.
- Non-rotary aiming interpolated already-old server angles. The server now supplies the selected target identity and turn rate; each client turns toward that target's local position. It cannot select another target, fire or alter authoritative aim. Stale identity falls back to replicated angles. Rotary presentation uses confirmed motor speed/stroke bounds with bounded prediction.
- Projectile launch visuals restarted their entire flight on arrival. Launch snapshots now carry a synchronized timestamp and account for up to 250 ms transit. Impact ordering and duplicate protection remain intact.

## Complete path matrix

| Family | Detection and visible response | Damage and intentional timing | Exit/recovery/lifecycle check |
| --- | --- | --- | --- |
| Basic and reinforced Bed Spikes | Indexed approach; native-owner trip/landing reports; native directional trip animation | Damage on a valid fall, not every standing step; existing trip chance and recovery retained | Landing once, corpse proxy excluded, failed application retry; per-tile wear/retirement and save/load |
| Concertina Wire | Exact paired-tile contact; approach permission enables same-update local slowdown | First valid contact then configured interval; server-authorized owner damage | Local slowdown ends at actual exit; stale native position cannot repeat an owner hit; both halves retire/save together |
| Barbed Panel | Exact backed-edge/side geometry; same local slowdown/consent path as wire | Same contact cadence; native backing can still be thumped | Independent opposite faces, support loss, closed garage section, exit and shared overlap timer |
| Basic and reinforced Spike Barrier | Native thump target and independent animation condition; strike markers survive native packet updates | Front/side retaliation on native strike markers; safe rear retained | Duplicate marker blocked; release on leaving, thump-target change, removal and death; C515 native animation evidence rerun |
| Poke Floor | Indexed owner contact plus local spike preview | First eligible contact strikes immediately; 150 ms is the same stroke's admission window, not a mandatory first-hit wait | One hit per actor per stroke, configured cycle, corpse exclusion, preview reconciliation and wear |
| Tether Dart | Fresh lane report; authoritative swept collision; continuous client flight and confirmed victim attachment | Separate impact and pull; existing 0.75 s hold and 3 s reset defaults retained | Correct return endpoint, wall/unloaded/density stop reasons, cancellation, object/support loss and fair active scheduling |
| Tacks | Nearby field snapshot/index; approach permission; exact local field/wall contact | Same validated contact exchange and overlap timer as barbs | Field expiry follows game time; exact local exit, server removal, duplicate/late snapshot guards |
| Martyrdom | Authoritative death/root and existing bounded proc scheduler | Existing root/child rules and shared damage exchange | Once-only death, Synergy lineage and cleanup; no dependency on skipped dedicated-server OnZombieUpdate |
| Pressure Plate | Fresh actor-index membership, including first owner entry | No damage itself; changed output dispatches without waiting for routine scan | Exit updates previous plate; trigger policy, battery and corpse checks retained |
| Laser Sensor | Fresh owner coordinates and first-on-beam sample; bounded crossing check | No damage itself; existing short crossing hold preserves brief signals | Dead/corpse excluded; beam clipping, obstruction and link policy retained |
| Button and Lever | Native authorized timed action; output uses changed-input queue | Native action time is intentional; no extra routine-scan wait after output changes | Existing recovery, link/power/access, removal and release behaviour |
| Controller | Existing authoritative assignments and receiver routing | No independent combat or damage prediction | Privacy, range, power fallback, stockpile and removal suites retained |

Turret coverage is explicit too: Potato, Ballista, Scrapshot, Arc, Lobber, Rotary Bat, Rotary Blades, and representative pistol/shotgun/rifle firearm paths. Non-rotary heads share selected-target presentation; both rotary heads share motor prediction. Projectile families retain server collision, rays/pellets, Arc's deliberate chain spacing, Lobber flight/fuse and module effects. The existing 360 head/catalog cells and 339 serialized hit cases are rerun, including representative combined Splitter/Piercing/Fragment/Synergy and delayed callbacks. This does not assert every possible module permutation or third-party firearm is tested.

## Proof and limits

`tools/tests/response_c517.lua` runs actual production functions with divergent owner/server positions and controlled clocks, captures tether renderer draw coordinates, and exercises first-contact inputs, late metadata, expiry/handoff, active scheduling, transit accounting and the actual aim-renderer branch. `tools/check_response_regressions.py` substitutes frozen pre-fix modules from `f0b8702`; each must fail its named behaviour assertion. The corrected complete suite must then pass. These are failure-and-repair replays, not a network emulator or rendered acceptance.

The corrected complete suite passes 40,498 assertions. All eight frozen old-code paths fail at their intended assertions. Native stock-game save/read, independent Traps/Turrets/both starts and dedicated combat/service checks pass. Native probes connect zero clients. [Recorded checks](evidence/c517-checks.json). Results and exact package hashes belong in [the versioned test record](TEST_v0.2.70.11.md).

No honest implementation can promise zero network latency. A newly streamed/spawned actor already inside a hazard may still await its first server consent. Packet gaps beyond the bounded prediction window freeze/fall back instead of inventing hits. The server rejects reports over 500 ms old or over two tiles from its native replica. Actual wall/unloaded/density-limit tether stops remain intentional safety outcomes, now distinguished in logs; C516's old logs cannot establish which caused every observed stop. These limits require connected observation, not another blanket "all fixed" assertion.

Detailed diagnostics add `owner-contact-permission-ready`, `owner-contact-position-rejected` and `tether-phase` with cycle/phase/reason, alongside C515 contact-to-owner-apply/settled/display and existing Barrier markers. Timing logs measure function calls, not GPU frames.

The artist handoff already contains both `OMHTT_TetherNail.x` and `OMHTT_TetherCable.x`, byte-identical to current meshes when checked in C516. No new mesh is introduced; the full kit still carries its older C445 baseline.

Connected multiplayer acceptance remains open until the owner tests this exact build. No new world is required for these corrections.
