# 0.2.70.7 - C505 multiplayer corrections

Owner approves C504 **1A** and asks for thorough reproduction, server authority and a remote Module Pack check. [Approval](MULTIPLAYER_FEEDBACK_C504.md#c505-approval-and-implementation-2026-10-29). No rebalance, new loot, sibling changes or publication.

## Physical position and damage

- Replace predicted-square discovery with one actual-position index using loaded native actors. A fair refresh handles at most 1024 actors and a cooperative 2ms deadline per slice; complete passes wait 50ms. Individual engine/callback duration is not preemptible.
- Searches choose the smaller of nearby eight-tile buckets and occupied bucket traversal. Range no longer forces a full empty-tile scan. Priority, LOS and per-turret work budgets remain; dense searches can require multiple slices.
- Bed, Poke, barbs/wire, Tacks, barriers, triggers, Arc, rotary, rays, splash and Martyrdom use physical occupancy. Clear crossings between samples are considered only on one floor within two tiles/250ms. Long gaps do not invent hits.
- Ready Poke contact strikes immediately, with a 150ms rising window and one hit per victim per configured cycle. Careful walking and repeat cooldowns remain. Bed wear follows confirmed damage; rejected still-landed hits can retry. Startup no longer resets Bed contact history on its first tick. Contact freshness uses observation time; gameplay cooldowns retain their game-time clocks.
- Normalize only native outfit bit 15, which changes when a zombie loses its hat. Preserve signed identity, every other bit, ownership, receipts and duplicate protection.
- Fixed rejection reasons reach shared targeting. A failed victim receives a one-second revalidation delay, cleared on ownership/identity change. This bounds repeated attempts without permanently blacklisting a live zombie; it does not establish that every stale server actor is eliminated.

## Client presentation and diagnostics

- Projectile packets carry target identity. Clients follow the matching native actor within the same two-tile impact tolerance. Obsolete flights expire sooner; bounded phase history prevents delayed launches resurrecting completed impacts. Existing 100-400ms aim interpolation remains. Clients do not select damage or spend resources.
- Remote pack icons use existing 24px art, eight-tile radius, same floor and visibility checks. Invisible players stay hidden. Native action completion/cancellation, replacement, death, disconnect, range exit and expiry clear the marker. Serial history survives expiry; no reward details are sent to observers.
- Existing logging gains fixed reject/result counters, source/victim/phase/elapsed/loss details, search duration/range/priority, actual versus membership coordinates for landings, and effective logging switches. Existing line/queue limits remain; no per-frame logs or extra diagnostic request loop.

## Delivery

[Verification and owner checklist](TEST_v0.2.70.7.md). The confirmed 0.2.70.6 upload to item 3828638252 is the new changelog baseline. The current pre-patch notes matched its published snapshot line for line; different byte hashes were only line endings. No unpublished notes were discarded.

No new world is required. Update and restart the server and clients on the same build. Simulated and isolated native evidence does not establish connected acceptance.
