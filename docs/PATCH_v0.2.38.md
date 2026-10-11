# 0.2.38: Concertina Wire and independent spike tiles

C120 implements the C114-C119 bundle after the owner's explicit "Approved for patch". Detailed values and provenance remain in [the checkpoint contract](checkpoints/R2C4_CONCERTINA.md).

- Concertina Wire
- Barbed-contact slowdown and player injuries
- Independent Bed Spikes durability and recovery
- Sandbox header organization
- Improvised head and Makeshift component naming
- Complete-turret crafting cleanup

Wire is one freestanding tile, 50 HP, one wear per damaging activation, and shares panel damage/cadence (10 every two seconds by default). Its recipe consumes one Barbed Wire and two uses of Wire, retains usable pliers, takes ten base seconds and grants no XP or skill requirement. Placement/pickup take five seconds; repair is free, tool-free and ten seconds. One coil weighs 2. World and inventory art remain explicit white WIRE technical markers.

A single bounded contact handler selects a touching panel/coil. It halves the actor's native pending displacement before collision handling; it never stores/restores base speed or compounds separate panel/wire multipliers. The handler checks contact even while damage is cooling down. Native climbing, bump falls, knockdowns, ragdolls and non-crawling prone movement bypass the modifier. Native movement API and event order were inspected in installed 42.21; tests use real player/zombie objects as well as runtime doubles. This proves the exposed delta path, not rendered animation/pathfinding acceptance or compatibility with every external movement hook. Horde Night itself is unchanged; current movement from other sources is scaled rather than replaced.

Wire and panels reuse the existing Bed Spikes player rules: safe walking, 20-percent running/sprinting scratch, an additional 20-percent sprint-trip entry roll, and one environmental cut on a fresh landing. Adjacent pieces share entry state. God mode prevents injuries/trips; noclip/ghost bypass custom contact effects. Panel geometry and backing health remain unchanged.

Bed Spikes craft two one-tile units. Two carried units place a pair; one remaining unit places singly from inventory or Building. Each tile owns its 50/100 health, six wear per damaging fall, repair, reinforcement, pickup and destruction. Weights are 1.5/2 per tile. Reinforcement consumes one plank/four nails, retains a hammer, requires Carpentry 3 and grants 15 XP. Spike Barriers are unchanged. No save migration is supplied: use a fresh world. Native entity routes require distinct sprite IDs, but all spike routes still reuse one texture.

Turret Base remains at root, with Heads and Modules groups. Removed both assembled-turret craft shortcuts; base/head crafting and manual assembly remain. The alternate head method says Improvised, while starter components say Makeshift. Internal IDs and output identity are unchanged. Sandbox now groups firing reliability, expansion tiers, trap damage/durability, shared player-contact settings and audio coherently; existing saved option IDs/values are retained.

Automated verification passed: 3,946 Kahlua assertions; 94 compiled runtime/translation files; 574 native translation keys; 23 packet serializations. Native write/read pass in 95.7/90.6 seconds. Traps-only/Turrets-only/both startup pass in 81.3/83.3/88.3 seconds. The manifest covers 188 source and 228 package files; 111 Sandbox options and 31 identical shared helpers pass independent checks.

Verification and the single active owner checklist: [TEST_v0.2.38](TEST_v0.2.38.md). Existing collapse/audio and dense-client pause acceptance remain open. No multiplayer enablement, Workshop upload or automatic PR merge.
