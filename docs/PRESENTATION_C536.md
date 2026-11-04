# C536 - coherent multiplayer shot presentation and client actor lifecycle

Owner selected C535 option 1A on 2026-10-31: repair Splitter presentation and validated target coordinates; investigate missing client zombies and unstable pause before packaging. This is a corrective test build, not acceptance of multiplayer rendering.

## Implemented behavior

- Firearm Splitter rays are prepared when the shot is committed. For targeted firearms, the primary shot and its complete Splitter fan share one presentation packet. Authoritative collision and damage retain their bounded server queue. Damage settlement never emits a second firearm tracer.
- First delivery is not discarded merely because the server timestamp is 250 ms old. Packet and per-projectile phase deduplication prevent repeats; tracers retain their short local rendered lifetime. Immediate rays stop at loaded visible geometry. Physical Potato/Spear flight and contact presentation remain physical projectiles, not instant tracers.
- Eligibility, head aim, primary shot snapshot and Splitter direction use the same validated owner position. Firearm, Ballista, Arc and Scrapshot contact presentation uses the corresponding position source. Forward shots retain their explicit fixed aim. Expired or mismatched ownership reports cannot keep an old aim alive. This does not move native actors or change damage, range, ammunition, power, ownership or reward rules.
- Native zombie creation precedes assignment of the client OnlineID. The client now revisits those exact newly created instances after initialization, with at most 128 pending entries processed per call and a two-second retirement window for unresolved initialization. Ordinary native updates remain the observation path. No global zombie scan or new network request was added. First observation no longer overwrites the actual creation timestamp. Recycled IDs, dead/corpse proxies and ownership guards remain enforced. Disconnect clears the pending/indexed lifecycle state.
- Detailed logs identify successful client indexing, initialization delay and native actor count on a missing-target rejection. This separates a delayed T&T lookup from an entirely empty client native actor list; a nonzero list does not establish presence of the particular missing ID.

## Investigation boundaries

C535 confirmed all six native Horde Manager requests: 51 constructed zombies and six client replies. Neither the native spawn handler nor Horde Night spawning was changed by this patch. The captured logs do not prove why those zombies were not visible. The corrected creation/indexing race is a real defect, but is not proof that the native client received every reported missing zombie. Connected spawn visibility remains an acceptance item.

The installed 42.21 IsoPlayer bytecode contains a nearby-zombie spotting path that writes the game multiplier back to 1 outside client mode, including on dedicated servers. MultiplayerFastForwarding reapplies its selected rate on a 250 ms cadence. These competing writers match C535's server 0/1 oscillation while the client remains at 0. This is a concrete compatibility conflict, not proof that T&T caused every instance of paused zombie sliding. No pause mod, engine, live server or sibling project was edited. A proper correction needs cooperation with that mod's authoritative pause state; T&T should not invent another timer or override global speed.

A direct GameClient Java registry lookup was investigated and rejected by an actual native Lua probe: the Java object does not expose getZombie to Lua. That approach is not shipped. The final native probe exercises the supported lifecycle path using a real IsoZombie whose ID is assigned after the creation callback.

## Proof and release boundary

[Verification](TEST_v0.2.71.4.md) records frozen-code failures, current behavior checks, native runtime and delivery. Zero clients participated in automated dedicated probes. Those checks establish executable behavior and API compatibility, not connected visual acceptance.

The exact Workshop item successfully published 0.2.71.3; its saved notes match the preceding draft after newline/trailing-blank normalization. [Receipt evidence](evidence/c536-upload-baseline.json). The 0.2.71.4 draft contains only subsequent changes. Owner edits in AGENTS.md, README.md, docs/AMMO_UI_C446.md and docs/RELEASE.md remain untouched and unstaged.
