# 0.2.44 - Manage feedback and secondary-hit modules

C160 implements the owner-approved [C155-C159 contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md). Single-player development build; owner gameplay acceptance pending.

- Manage section borders and backgrounds
- Loot-weight rarity colors
- Battery, reserve and magazine bars
- Reload-aware per-shot battery estimates
- Once Each targeting
- Synergy Module
- Martyrdom Module
- Tack Module
- Bounded secondary-effect processing
- Updated LootLab catalog and scenario imports

## Behavior

Manage retains its 4/6/6 grid and separate utility slots. Installed Modules has its own bounded background, names left and compact effects right, with individual hover explanations. Rarity uses the seven Horde Night color stops, including the pale-blue/purple extremes, calculated from effective loaded catalog weights; disabled/crafted entries are neutral. Battery hover reports cost per firing event (primary plus side shots), shots remaining and approximate continuous firing time including reload/chamber delays and Conservation. Display rounding does not alter power use; no idle drain is added. Cached estimates update with relevant state and on hover, not every tick.

Filter's Once Each starts with the closest eligible target, then chooses the smallest legal turn (distance breaks ties). The cohort is collected through the existing incremental scan. A committed shot counts even if it misses; a failed attempt does not. New arrivals join the next round, and every selection still checks live range/cone/sight eligibility.

Synergy is loot-only, weight 1.0, one installed copy. It enables applicable passive effects on Splitter, Piercing and Fragment hits with 100-percent eligibility, while preserving each passive's own condition. Splitter/Piercing can generate Fragment; Fragment cannot generate Fragment. Martyrdom and Tack damage are terminal and cannot restart the effect chain.

Martyrdom is loot-only, weight 1.5: eligible projectile kills burst for 20 zombie damage in a 1.5-tile radius, adding .25 radius per extra copy. The separate attracting noise radius is 20. One exposed player limb takes 2 health damage and 5 pain, with one active-second protection; no invented Bruise status or forced bleeding. Solid walls and different floors block effects.

Tack is loot-only, weight 1.5: an eligible hit leaves a stationary ten-active-second field, radius 1 plus .25 per extra copy. It deals 10 damage per two seconds and halves contact movement. The same zombie can trigger again after expiry; hits do not refresh an existing field. Overlapping fields/barbs do not multiply contact ticks or slowing. Walking is safe; running/sprinting/falling use existing barb player rules, with noclip/ghost bypass. Native circular technical markers visualize fields; final art remains owner-sourced.

All three modules weigh .3, use ordinary slots and the existing module power multiplier. No new recipes. Both selectable packages remain independent.

## Performance and persistence

Reserve worst-case secondary-ray/effect capacity before consuming ammo or power. Full queues delay new firing instead of dropping paid effects. Terminal AoE jobs run incrementally within the existing shared 3-ms scheduler; sparse spatial buckets limit Tack contact candidates. Capacities are 256 rays, 512 queued bursts and 512 fields; each effect worker is bounded by steps and elapsed time. Presentation is separately bounded (32 nearby markers, paced creation, shared audio limit).

Tack fields, pending bursts and player injury protection retain remaining active time in save data. Offline time is excluded. Per-victim burst identifiers prevent duplicate resumed burst hits. Native serializable data is separate from transient object references.

## Evidence and limits

15,931 Kahlua assertions; 111 compiled runtime/translation files; 743 native translation keys; 23 serialized packets (largest 390 bytes). Native write/read, Traps-only/Turrets-only/both startup and Firearms B42 (51 guns, 153 firing transactions) pass. The synthetic 160-burst/486-zombie run drained through 481 callbacks; the final run's maximum was 1.37 ms. This is test-double work, not an in-game frame-time guarantee. The prior 676-ms client gap remains unassigned.

Native probes cover the three real module definitions, injury calls/protection and field ModData serialization. Native server probes use isolated copies of SP-only effect bodies for API checks; production remains SP-only. Rendered markers, audio, dense crowds and a live save/reload remain in the [six-step test](TEST_v0.2.44.md). LootLab has 28 modules, 193 pool entries and 76 passing API/page checks; browser model/import tests also pass. [Release evidence](RELEASE.md).
