# 0.2.61 targeting and reduced player injuries - C389

Owner approved the complete C386 targeting patch and confirmed C388's 1C balance with "Yea". C108 authorizes local installation and the existing development mirror. No further gameplay decision remains for this slice.

## Scope

- Controller target defaults
- Defense target overrides
- Other Factions targeting
- Reduced turret player injuries
- Player damage and wound Sandbox settings

Controllers default to Zombies Only. Assigned turrets and Tether Dart Traps inherit the Controller setting unless explicitly overridden; unassigned defenses default to Zombies Only. Target controls are in the Controller's Selected Device section, the turret Manage footer and the Tether context menu. The tooltip reports the effective mode. Configuration survives save/restart and existing pickup/redeployment state handling.

Other Factions includes zombies and players outside the defense owner's current faction, including factionless outsiders. Owner/current faction exclusion affects deliberate acquisition; management access is separate. Server PvP, both-participants safety and non-PvP zones gate player acquisition and turret injuries. An offline owner is treated as safety-enabled, so a safety-enabled victim is protected. Acquisition, aiming and primary impact recheck eligibility. Physical incidental contact does not gain blanket faction immunity.

Tether autonomous sensing uses the target policy. An external trigger still overrides sensing; player injury severity remains its existing scratch rule, with server protection checks. Laser detects physical crossings; passive traps and Poke do not gain recognition or modules. Existing Detection, Firing, power and finish-current-action rules remain.

| Head | Body-part damage before clothing | Wound chance |
| --- | --- | --- |
| Potato | 2 | 0% |
| Firearm | 4; shotgun up to 8 per shell | 6% |
| Ballista | 10 | 15% |
| Scrapshot | Up to 8 per volley, one per landed pellet | 9% |
| Rotary Bat | 2 per eligible contact | 0% |
| Rotary Blades | 4 per eligible contact | 15% cut |
| Lobber | Up to 10, distance falloff | 15%, distance falloff |

Other wounds are scratches. There are no player critical/Execute bonuses, forced knockdowns, head/neck bonuses or guaranteed bullets/deep wounds/fractures. Armor reduces fixed damage; fully blocked hits do not consume a wound opportunity. One nonzero wound roll is allowed per victim per real second across turrets, plus one per shot/volley lineage. Damage from distinct attacks still stacks. Both rotary heads retain their shared two-second recovery interval. Existing Martyrdom collateral remains a modest two-damage bruise, bounded by the same attack budget and one-second contact recovery. Fragment rays remain zombie-only; Lobber fragments retain their existing reduced blast collateral within the root cap.

Splitter/piercing rays and saved secondary jobs share the originating attack's player budget. Serializable event IDs reunite separately restored copies; weak references release finished budgets without a world scan. Player injuries are selected on the authority and sent only to the affected client using the existing injury protocol; receivers reject invalid limbs, excessive values and replayed events. Zombie damage formulas/Horde permissions and passive/Poke injury rules are unchanged.

New Sandbox multipliers independently scale player damage and wound chance from 0 to 5 (default 1), under turret operation settings. They do not change zombie/trap damage. The values are a starting balance, not measured PvP time-to-kill.

See [verification and focused owner test](TEST_v0.2.61.md). Automated/native probes do not establish rendered or connected-client acceptance.
