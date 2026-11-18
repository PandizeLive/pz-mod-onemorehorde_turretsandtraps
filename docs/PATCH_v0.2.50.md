# 0.2.50 — turret heads, ammunition and utility modules

Implements the complete approved C235 content bundle on C246 multiplayer authority. Owner authorization: “You are approved to start the patch. Keep in mind multiplayer functionality.” No new gameplay choice was substituted for an approved selection.

- Grenade Lobber and Makeshift Bomb
- Scrapshot
- Lure Module
- Void Module
- Built-in head magazines and payload priorities
- Travelling Ballista spears and broader spear compatibility
- Extended rotary reach and contact modules
- Potato piercing contacts
- Module Pack completion flow
- Lure/Void LootLab catalog

Lobber uses homogeneous three-round magazines, explicit preferred/second/third payload order, fallback off by default, safe switching, two-second landing fuses and bounded terminal Fragment minis. Actor-only blasts retain the approved native-bomb strength and linear falloff. Scrapshot has eight primary pellets, one side projectile per Splitter, conditional-hit snapshots and once-per-victim effects. Pellets wait for an outstanding same-shot damage receipt before calculating the next hit; neither damage nor item mutations are client-controlled.

Void converts exact selected ammunition in twenty-item server-completed actions; it never materializes rounds or bypasses finite magazines. Quality descriptors and Conservation debt belong to the exact module in the server-private store. Routine replication contains compact counts; inspection reads twenty type totals per authenticated, distance-checked page, with separate split-screen requests. Physical ammunition remains preferred at reload. Removal clears virtual ready rounds without refund or a new Impact entitlement. Count and descriptor lookups are cached. Native carried/world weight limits still apply to physical items; approved count limits are 40 spears, 20 mixed bombs and 250 ordinary firearm rounds before firearm expansion kits.

Lure uses the standalone bundled attraction sound, linked 5–20-tile range/volume, manual or five-second repeat, range-scaled battery use and Horde consent checks. Power-off, removal and pickup stop repeats; elapsed lag permits one due pulse without backlog. Ballista is 24 tiles/45 degrees with travelling primary and secondary spears; rotaries reach two tiles through 90-degree front/rear sectors, with Tack/Martyrdom contact support. Potato Piercing retains attenuated splash and guarded knockdown at each direct contact.

Five new native recipe transactions and four sound registrations pass. The full validator passes 20,401 assertions, 167 Lua/translation compilations, 849 translation entries, native packet/table serialization and existing audio/model checks. Native B42.21 stock-first write/read and three independent package selections pass with zero clients. These establish implementation/runtime evidence, not rendered or connected-multiplayer acceptance. See [the test record](TEST_v0.2.50.md).

Remaining acceptance: connected dedicated/listen ownership/latency/disconnect cases, rendered spear/grenade/pellet feedback, audible timing and real horde performance. As in C246, ambiguous receipt loss expires without replay. Saving while network damage is unresolved does not manufacture a replacement hit; an unresolved delayed Impact may be omitted after restart. No Workshop upload or main merge is authorized or performed. Final artwork remains owner-sourced; technical placeholders are retained.

Hosted LootLab was deployed as `cc779434-0e9d-4b92-9eb1-ac7d3417bb66`; production bundle equals the isolated tested build, SHA-256 `7480ef7f2358ca923206425d9ef48fa36a1993fd4771cf6f8aa8eb76c14a28fa`. Thirteen anonymous admin paths remain protected and both checked public APIs remain HTTP 200. Existing account rows were not rewritten. [Evidence](../diagnostics/v0.2.50/lootlab-release.json).
