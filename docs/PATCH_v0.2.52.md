# 0.2.52 / C267 — Manage and ammunition corrections

Owner explicitly approved the C263–C266 recap and accepted the corrected layout. This implements that correction bundle; R4C1 physical inputs/controller remain the next content checkpoint. No additional gameplay decision was required.

## Player changes

- Revised Equipment and Ammunition layout
- Shared per-head Load Order
- Next-load, next-shot and ammo-type summaries
- Manual Magazine Reload
- Scrap ammunition compatibility and material bonuses
- Safer Scrapshot reserve limits
- Quieter Makeshift Bombs and revised Lobber timing
- New-head reload audio
- White, unwrapped descriptions and simplified rotary RPM

Equipment contains Head, Expansion and Battery/Power. Equal-width Ammo/Void share a Load Order button; Magazine and Reload occupy the row below. The 4/6/6 module arrangement is retained. Native scrolling keeps the taller window bounded by the player's viewport, including Lure and Landing Distance.

Load Order stores a separate preference for each head type. It lists compatible physical and Void ammunition, displays counts and material benefits, supports Up/Down, skips unavailable types and appends newly encountered types deterministically. Apply changes the next reload; it never transforms an already loaded magazine. One ammunition type is loaded at a time. Native firearms still use their supported fixed ammunition type.

Manual Reload uses the normal duration. Custom/virtual loaded counts are reservations, so restarting them never creates refund items or spends ammo. Native firearms top up actual rounds and their Magazine-module extension without losing existing rounds or the chamber. Conservation debt, cooldown and Impact eligibility are preserved. A partly loaded native firearm uses physical reserve for top-up; it changes to a separate Void-fed magazine after its physical loaded rounds are spent. Void never materializes withdrawable native ammunition.

Scrap reserve progression is 20/30/40/60/80 for None/Makeshift/Small/Medium/Large. Native weight checks remain authoritative, so unusually heavy modded ammunition can still reduce the physical allowance. Void remains weightless. Scrap Metal/aluminum have no damage bonus; copper/brass +5%; iron/steel +10%; gold/silver +15%. Both physical and Void paths apply the same descriptor to the existing eight 40-damage pellets. Unknown modded scrap requires an explicit family override, not a name guess.

Makeshift Bomb uses native FireCrackerSingleExplode at .35 playback gain; native Pipe/Aerosol bombs retain their own sounds. Fragment minis use .15 gain and suppress tightly overlapping cues within the same volley. Playback gain now reaches impact audio. Zombie attraction is unchanged. Lobber's landing fuse is 1.25 seconds and base firing interval 5.5 seconds. Normal speed upgrades remain: overlapping upgraded shots are possible, with no detonation callback gate or new timing cap.

Ballista uses native rope/wood handling; Lobber and Scrapshot use native loading cues. Rotary heads retain no-ammo mechanics and display plain RPM. Module descriptions and stack/drain values are white; rarity remains colored. Inventory and Manage tooltips retain explicit lines without automatic wrapping, with cached measurement in the inventory footer.

## Multiplayer and performance

Load Order and Reload use the existing authoritative timed-action path, checking exact head identity, current order, compatible types, reach, powered state and inventory. Duplicate, malformed and stale order requests fail. The replicated/packed-state copier now preserves the bounded per-head order map without aliasing private tables. Old Lobber-only preference/fallback/switch commands are removed from the UI and action endpoint; legacy saved preference is read as an initial priority.

Priority parsing is cached per head. Feeding avoids constructing/sorting the complete UI list; it uses exact preferred counts and the existing cached Void preview. Manage retains its 200ms refresh. The editor checks equipment every 250ms and reads multiplayer Void lists in bounded twenty-type pages. Row descriptions are cached and offscreen rows are not rendered. Unchanged tooltip lines are measured once. No new per-tick event, pcall or xpcall is introduced.

An order request is limited to 256 unique types and 16 KiB of text. This bounds untrusted multiplayer input; it does not cap Void storage. Connected-client rendering/latency and audible balance remain owner acceptance work, not established by a zero-client server probe. [Verification and short test](TEST_v0.2.52.md).
