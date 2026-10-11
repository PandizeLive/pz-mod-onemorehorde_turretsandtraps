# 0.2.38 focused test

Status: automated/native verification and tagged installation passed. Owner test not performed. This replaces the prior active checklist and carries its unaccepted collapse/audio/continuous-placement checks into one run. Older results remain historical.

## Owner test (fresh world, single player)

1. Restart the game, create a fresh world, enable the entries you use and confirm **0.2.38** in the loaded marker. Check Crafting/Building: root Turret Base, Heads/Modules, Makeshift names, no complete Potato Turret crafts; inspect Traps/Modules Sandbox headings.
2. Craft Bed Spikes: receive **two** items. Place the pair, then reinforce/repair/pick up one tile; the other must remain unchanged. Place that one recovered tile alone. Building should keep its placement preview between placements.
3. Craft/place **Concertina Wire** with pliers, one Barbed Wire and two Wire uses. Check five-second place/pickup and ten-second free repair. Wire is freestanding; panels still need backing.
4. Lead zombies across wire and a panel edge: half-speed only during contact, normal movement after exit, timed damage without stronger overlap slowing. Check independent wear/repair, door-following and window-frame barbs; save/reload once.
5. With god/noclip **off**, walk safely, then run/sprint through a short adjoining hazard line. Watch brush-through, entry scratches/trips and a cut only on a new landing. Injuries are chance-based. Noclip should bypass; god mode should prevent injury/trips.
6. Let zombies fall on Bed Spikes: collapse/recover, hear the impact, and confirm only the hit tile wears/breaks. Briefly repeat your loaded-turret crowd test; report visible pauses and finish with **Test complete** so console.txt can be captured/reviewed.

Do not repeat unrelated old tests. Native probes do not establish rendered collapse, audio balance or elimination of 300-700ms pauses. Report what you observed; unmentioned checks are not automatically formal passes.

## Automated evidence

All final native write/read and isolated-package runs pass. 3,946 Kahlua assertions; 94 compiled runtime/translation files; 574 native translation keys; 23 packet serializations. Native write/read pass in 95.7/90.6 seconds. Traps-only/Turrets-only/both startup pass in 81.3/83.3/88.3 seconds. The manifest covers 188 source and 228 package files; 111 Sandbox options and 31 identical shared helpers pass independent checks. Native tests cover 32 independent bed objects across pair/single/tier/facing routes, eight panel/support pairs and one worn coil. Current native logs include stock asset/world-generation diagnostics; no mod probe failure remains in passing runs. Unit coverage includes continuous movement during cooldown, changed input speed, non-stacking overlaps, exit/disable/removal, player entry/landing/god/noclip rules, independent tile wear/retirement, pickup conservation, exact pair/single placement inputs and Sandbox ordering. Native probes cover registered recipes/retained tools, independent item/world state and texture registry aliases.

During development, native checks caught duplicate sprite registrations and an incorrect native recipe-time conversion; both were corrected before installation. The extended atlas verifier also needed new wire/single-tile mappings. No failed attempt is an acceptance result.
