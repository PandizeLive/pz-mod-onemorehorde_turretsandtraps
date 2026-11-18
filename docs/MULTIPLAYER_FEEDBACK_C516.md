# C516 - Improved damage; aiming and tether presentation remain unsatisfactory

2026-10-30 owner report: turret aim appears desynchronized; damage appears better; Concertina was delayed on the first crossing and then felt good. Tether Dart is delayed, sometimes appears to stop immediately, and should follow the struck target. Owner asks whether its assets are in the artist kit. This is partial improvement, not acceptance of all multiplayer behavior. No new gameplay patch or art refresh is made in this review.

## Captured evidence

Read-only local/SFTP capture in ignored `diagnostics/c516` confirms client and server 0.2.70.10. Retained detailed server results show 58 applied Barrier hits, 18 Poke hits, 22 barbed hits, four Bed landing hits, nine tether impacts and eight tether pulls. Four Bed trip/landing/fall event sets also appear. These are retained detail rows, not total session hit counts; console and debug logs duplicate the same events and must not be added together.

The client records 68 contact-to-indicator calls at 113-181ms, median 131ms. These begin at the owner's contact report and end at the indicator call, not physical collision or GPU rendering. They establish actual connected measurements for this path but not turret aim or tether flight latency. No T&T attack stack trace was found in this capture; the broad nearby-error scan matched an unrelated startup Fuel Pump naming error adjacent to asset warnings.

## Confirmed presentation defects and remaining unknowns

- Turret runtime angles publish no more often than every 250ms. `TurretRenderer.animate` then calls `TurretAimView.sample`, blending toward those received angles over another 100-400ms. It does not track the current client position of the server-selected target. A production-function Kahlua replay shows a newly received 90-degree heading still displaying 0 degrees on arrival, 45 after 125ms and 90 after 250ms. This is additional presentation lag; it does not establish the owner's exact per-shot timing.
- Tether `C.position` interpolates toward a received distance only. It never advances flight using the supplied speed. Outbound interpolation lasts 25ms, with active snapshots requested every 100ms of simulation time. The replay reproduces a stationary launch until an update, a short movement, then a stationary gap. A close-range flight can finish within a server step. Native server actor positions may also differ from client positions; retained tether result rows show discrepancies, but receipt coordinates are sampled later and cannot alone prove the original collision was wrong.
- `C.snapshot` contains no victim identity or attachment endpoint. `TetherView` stays on the original lane/impact distance during hold and returns along that lane. The requested following behavior is absent, not merely hidden by connection quality. The server does retain a victim for pull/damage, which can be reused for an explicit visual attachment contract.
- An immediate stop can also be a real blocked/unloaded/density-limited lane or actor collision. Current logs omit the individual cast reason and flight phase timeline, so this capture cannot assign every reported stop to a particular cause. Add bounded shot/phase/collision-reason tracing alongside the correction.
- Concertina's first crossing is consistent with the first server consent lease not yet having arrived. Grants are acquired on approach; first-touch permission timing is not logged, so this remains a hypothesis. Inspect initial discovery/ownership/permission readiness before changing the lease or bypassing Horde consent.

The nine-assertion replay uses current production `TetherCycle` and `TurretAimView` under the game's Kahlua, with controlled clocks. It reproduces current defects; it is not a corrected candidate or connected rendering proof. [Sanitized evidence](evidence/c516-review.json).

## Artist package

`artifacts/OMHTT-Artist-Handoff-C445.zip` includes `current/42.20/media/models_X/OMHTT_TetherNail.x` and `OMHTT_TetherCable.x`, plus shared textures and item/model script references. Both mesh payloads are byte-identical to current Source. The overall kit remains the older 0.2.66/C445 snapshot; do not imply all references and artwork are refreshed to 0.2.70.10. No duplicate art export is needed to answer this question.

## Recommended next patch

**1A (recommended):** correct aim presentation against the server-selected target; animate tether travel continuously between timestamped authoritative phases; attach the hit nail/cable endpoint to the identified victim, then detach/retract coherently on death, loss or release; investigate cold-start wire permission and trace premature stops. Preserve server collision/damage/pull/Horde/XP authority, ordering, expiry and ownership checks. Keep rotary motion and deliberate standby/aim turn rates intact. Prove delayed/reordered snapshots, fast crossings, moving hit targets, target loss and observer behavior before claiming smoothness.

**1B:** prioritize the tether flight/attachment correction and defer aim/first-contact investigation. This leaves known presentation lag visible elsewhere.

Decision/patch approval remains pending for this focused follow-up. Installed/staged 0.2.70.10 remains unchanged. Previous GitHub automatic approval review still blocks mirroring over destination authorization; no alternate push was attempted.
