# 0.2.51 verification and short owner test

## Automated evidence

- Full validator: 20,441 assertions; 264 source files, 322 packaged files and 257 literal translation keys. Includes ammo-family transfer, active-clock transfer, invalid reload-deadline recovery, Void summaries, removable Expansion, module/head text, small-screen Lure/Landing layout, exact-pack Open Next and targetless firing.
- Landing control rejects wrong heads, fractional/out-of-range values, strings, NaN and infinity. Projectile launch/impact identity and rejected-resource reservation cleanup are covered.
- Stock 42.21 dedicated-server production probe: targetless firearm shot consumes one round and rejects an immediate second cycle; zero clients connected.
- Native multi-magazine Void spear reload and exact item accounting pass. Native placed-container capacity checks: Scrapshot 85, Ballista 40, Lobber 20 with the documented full equipment fixture.
- Traps-only, Turrets-only and combined startup checks pass. Fresh-process native write/read evidence is retained with the release diagnostics.

These checks include native objects and Lua test doubles. They do not establish rendered acceptance, arbitrary mod compatibility, connected dedicated/listen-server behavior or measured multiplayer performance. No owner acceptance is inferred from patch approval.

## Test now — six checks

1. Restart and confirm **0.2.51**. Open Manage: hover Head, Ammo, Void, battery and modules; confirm distinct text, stack benefits, readable layout and removable Expansion styling.
2. Ballista: load a modded spear, store several magazines in Void, pause briefly, add ammo, then fire through two reloads. Swap heads and check compatible counts/types; hover the Void item too.
3. Lobber: load Makeshift/Pipe Bombs. With Firing but no Detection, set Landing Distance and Fire into an empty lane; confirm one forward shot and normal reload. Try a forward Scrapshot burst against zombies.
4. Add Lure: change range, Play and Loop; confirm range feedback and roughly ten-second pulses. Check rotary front/rear and Ballista coverage previews.
5. Fill physical ammo toward its displayed limit; confirm loading stops cleanly. Void should remain usable without freezing or losing ammunition.
6. Open two packs: hover settled rewards, use Open Next, then Collect. Confirm rewards once per pack and Open Next disabled when none remain.

After the test, capture console.txt through OMH.cmd and record exact loaded version, new errors and any remaining failures. Connected MP remains a separate retained acceptance check, not part of this short SP test.
