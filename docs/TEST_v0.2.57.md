# Test 0.2.57

## Automated evidence

- Full installed-game Kahlua/API/content validator: **23,802 assertions**, 249 Lua/translation inputs and 1,089 native translation keys. [Log](../diagnostics/v0.2.57/validation.log).
- Focused checks cover assigned shared-bank access, insufficient/exhausted/withdrawn batteries, overlapping debit requests, local/grid/bank priority, automatic spare rollover, phase-timed Poke contact, one wear per successful cycle, no wear on misses, safe retraction, Horde Night opt-out and no unpowered player injury.
- Native dedicated probes craft both Poke recipes using actual ingredients and retained tools; check the thirty-second conversion, placement/non-thumpability, private authorization, blocked input links, exact battery transfer and fractional debit, pickup/redeployment, condition and Grid Mythic registration. Fresh-process persistence checks retain private packed state and a real Poke item with condition 123 and exact battery charge 0.876544.
- Existing native turret signal/reload/fire, inventory, serialization and save/restart probes remain passing. These are native objects in a zero-connected-client fixture, not multiplayer acceptance.
- Traps-only, Turrets-only and combined package startup checks are recorded under diagnostics/v0.2.57.
- Desktop/mobile browser regression passes with zero page errors, including Grid weight 1 and unchanged saved tuning.
- LootLab model/weight/tier checks and five backend catalog tests pass. The prepared live Worker upgrade is compared against the canonical upgrade; no database writes. Hosted Worker bytes and thirteen protected paths/two public endpoint statuses are verified after deployment. [Hosted release](../diagnostics/v0.2.57/lootlab-release.json).
- Shipped Lua banned-call gate passes. Initial checks caught and corrected distinct native sprite-orientation requirements, obsolete catalog-count assertions, a battery-empty UI read, a native crafting-time conversion and a test fixture that had relied on mains power without a car battery. No connected play or rendered trap animation is claimed.

## Short owner test — after installation

1. Restart and confirm **0.2.57**. Craft standard and improvised Poke Floors; confirm the same item/performance and the expected ingredients/tools.
2. Place a Poke Floor, disable it, install a Car Battery and enable it. Lead zombies onto it: repeated visible strikes while occupied, one wear per successful cycle. Disable during a cycle and confirm safe retraction.
3. Check player traversal on a disposable test character, then remove all power and repeat: no invisible unpowered wound. Repair and pick up while disabled; redeploy and check condition/battery preservation.
4. Put two Car Batteries in a Controller and assign a turret/Poke Floor. Remove or exhaust the local battery and confirm shared fallback and automatic spare selection. Move/unassign the device and confirm it cannot use that bank.
5. A turret without Grid should require battery power even in a powered building. Install Grid: check mains/generator use, then battery fallback when electricity is removed. Siphon must not refill Controller batteries.
6. Open LootLab: Grid should be present at default Mythic weight 1, with your existing weights and tiers unchanged. Send console.txt and screenshots for any mismatch; repeat connected-player behavior when available.

Fresh test worlds remain the supported policy. Owner testing is deferred until available; this is not a failure or acceptance. Rendered/connected results remain pending. Retain the immutable 0.2.56.1 rollback snapshot.

## Local installation

Installed 2026-10-19 from immutable `test/v0.2.57` / `f9934476ec52ebd8ae5d52b077f03981ea541659`. All 308 source and 402 tagged/package/installed/archive files match; both 0.2.56.1 backups verify. [Release record](../diagnostics/v0.2.57/local-release.json). Connected and rendered owner acceptance remain pending.
