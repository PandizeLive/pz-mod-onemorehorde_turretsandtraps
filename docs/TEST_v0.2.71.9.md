# 0.2.71.9 verification

The released 0.2.71.8 motor fails the new crossing check on a Rotary Bat. The corrected motor matched all 262 reference paths for each of the Bat, Blades and a registered custom head with three-tile reach. Each head produced six hits at both receipt phases. The tested paths include zero-lag lateral movement, a stationary actor with 65 ms transit, and disagreement between owner and native posture. Additional cases check the shared pivot, exact grazing, cone reversals, stacked speed, stale or duplicate reports, two skipped evaluations, stopping, owner changes and actual health loss.

The final suite passed 51,902 assertions. A replay of 40 moving crowds of 32 actors measured 2.454 ms at the 95th percentile per packet on this machine. The benchmark uses simulated actors, network delivery and a damage sink. Native stock-engine write/read checks and the three package starts used zero connected players. Connected visual timing remains open. [Measurements](evidence/c546-verification.json).

An interim mocked frame lacked the new pause-generation field, and the lightweight single-player test exposed an unnecessary call for a network owner. The final code queries network identity only for an owned actor. Earlier package checks encountered mixed generated files during editing. Final native runs used the rebuilt candidate in separate caches.

- Sideways crossings and stationary targets
- Rotary Bat and Rotary Blades
- Knockdown, recovery and stopping

Installed and staged from test/v0.2.71.9 at 6b170ff1. All 642 packaged files match the tag, installation, archive and Workshop stage. [Delivery](evidence/c546-delivery.json). **Test now** after uploading and restarting the server and clients. The current test world is compatible.

## C547 crowded base replay

**C547 / Crowded rotary base benchmark, 0.2.71.9.** Owner selected 1B. Three runs with 32 moving zombies matched all geometric crossings at 1, 2, 4, 6 and 8 turrets. The real damage transaction delivered every hit through four turrets, 35 of 2,543 at six and zero of 3,424 at eight during the measured window. Giving the queue more service in a diagnostic control restored all 3,424. [Results and proposed repair](ROTARY_CROWD_C547.md). Connected testing is still deferred. **Decision needed.**
