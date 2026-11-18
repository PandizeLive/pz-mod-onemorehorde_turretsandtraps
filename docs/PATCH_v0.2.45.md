# 0.2.45 - Delayed effects and module feedback

C165 implements the approved C161-C163 correction bundle except packed-weight compression, which remains technically blocked. [Contract](checkpoints/R3_EFFECT_POLISH.md) | [test](TEST_v0.2.45.md).

- Tack startup correction
- Delayed Tack landing and sound
- Delayed Martyrdom pop and leading sound
- Delayed terminal-stop Fragment and sound
- Shotgun accuracy and Piercing
- Rarity-based additive power
- Four-field module descriptions
- In-game battery endurance estimates
- Engagement slider and status polish

Tack's client contact and marker bindings wait for OnGameStart, after server-side SP files are available. Tack lands after .5 active seconds, plays MetalworkingPunchDrop, then lasts ten active seconds. Martyrdom plays AttackStomp at .55 seconds and applies its pop/damage/20-radius AI noise at .75 seconds. These are scheduling targets; workload can delay execution, and audible alignment still needs owner verification. Each of the three effect cues has a 100-ms limit to avoid crowded audio bursts without Tack suppressing Martyrdom.

Fragment now follows terminal projectile stop, including misses and obstructions, then waits .25 seconds and uses OMHTTSuppressedM9Shoot. Piercing leaves the final burst at the end of its one-shot chain. Fragment cannot recurse; all admitted rays retain bounded shared work and capacity accounting. Pending rays, delays and hit suppression survive saves. Shotguns roll aim once for the shot and may create one Piercing chain; the 60/80 far-accuracy defaults remain.

Power uses `weapon factor * (1 + sum(working-copy rarity surcharge))`. Seven surcharges are .1/.2/.4/.7/1/1.5/2; expansion adds none. Crafted modules use .1; loot-disabled entries use canonical rarity. The saved ModulePowerBonus control is retained as a scale: 5 normal, 10 double, 0 off. The old 5-percent-per-copy formula is replaced. Display-only rounding does not change consumption.

Module descriptions use Feature, Stackable, Battery Drain and Rarity, sharing the loaded rarity resolver and colors. Battery hover uses `% / shot`, shots remaining and approximate in-game minutes; native day length and reload/chamber timing remain in the cached calculation. Engagement text and slider share an inset row; applicability information wraps separately from operating status.

## Unfinished approved work

**Packed turret contents compression is not shipped.** Native bag reduction only affects equipped weight. The owner confirmed automatic packing on Pick Up, the usual contents summary, and unpacking through existing placement. An isolated 42.21 test can create an opaque native item snapshot but cannot navigate/restore its byte buffer from ordinary Lua; reflection is debug-only. Do not reconstruct arbitrary guns from a partial property list, change global weapon scripts, store Java references in ModData, or claim the equipped-only flag fixes this. Existing exact-item pickup/placement and weight remain unchanged pending a reliable preservation design.

LootLab's colors, five family shapes and sticky visibility controls already shipped under C164; they are not a new gameplay change. Catalog/loot weights are unchanged here. No Workshop upload or multiplayer combat acceptance.
