# R4C1 — buttons, pressure plates and links

## C250: selections and compatibility research, 2026-10-15

This section supersedes the conflicting C249 proposals below. Owner selects and amends the design, then requests investigation of other mods providing redstone-like power/triggers. No gameplay implementation, dependency installation or integration claim is implied.

- **1A selected:** inputs require no battery; receiver operating power remains its own contract.
- **2A amended:** players and zombies can trigger plates; owner also requires manually editable targeting and controller-based targeting. Owner separately states any player can activate a plate regardless of controller access. Therefore editable filters are confirmed as a requirement, but their scope (plate trigger eligibility versus receiver victim eligibility) remains unresolved. Do not quietly apply faction configuration locks to physical plate activation. Passive damage hazards retain their existing physical behavior; this does not retroactively grant target recognition to wire or spikes.
- **3 amended:** 20-tile connection range, themed as electrical reach, with 32 inputs and 32 outputs per device. Retain bounded processing despite the larger base use case. The numerical limit is not a claim that electricity physically stops after twenty tiles or that unlimited fan-out is free. Straight-line distance versus actual cable routing remains to be settled if routing is introduced; same-floor abstract links remain the prior recommendation, not newly confirmed routing mechanics.
- **4B amended:** no universal repeated-action behavior. Expose activation/change and held signal state, then agree each trap/head's response: one action, repeated normal cycles, remaining active or inhibiting operation. Exact mapping and multi-input rearm behavior must be settled with each receiver; the bare 4B selection does not override the owner's explicit per-device qualification. No backlog bursts or resource/cooldown bypass.
- **5 replaced:** devices can be manipulated by anyone before a controller is placed; assigning traps/turrets to a faction-base controller protects their manipulation. Physical pressure plates remain usable by any player. Define the base boundary, eligible assignments, overlapping controllers, solo ownership, controller removal/destruction and faction disbanding before implementation. Do not infer that an enemy can claim another established network by placing a controller, or that loss of power releases access protection. This is a requested extension to existing device access, not code already implemented.
- **6A selected:** restore actual occupancy and resume after a one-second safety delay, without replaying historical pulses. One-shot receiver rearming on reload needs an explicit rule to avoid generating a new attack merely by unloading/reloading an occupied plate.

### External-mod research — primary author sources

Checked 2026-10-15; descriptions are author claims, not OMHTT compatibility or multiplayer certification. No ready-made current-build general-purpose circuit API was verified.

| Candidate | Evidence and relevance | Limit |
| --- | --- | --- |
| [Better Electronics](https://steamcommunity.com/workshop/filedetails/?id=2999183635) | Remotes, motion sensors, noise devices and door motors | Author [comments](https://steamcommunity.com/sharedfiles/filedetails/comments/2999183635) discuss B42.20 work and MP fixes; no validated B42.21 OMHTT integration/API established |
| [Electrical Overhaul](https://demarest.dev/projects/electrical-overhaul/) | B42 wired networks, hubs, security sensors, relays and automation | Author explicitly labels the project private until release; unavailable as a verified public dependency |
| [Deadwire](https://github.com/robotsmeller/deadwire) | Public B42+ project with trip-line detection, alarms and server-authority claims | README Current State lists electric fencing and pull-alarms as not yet implemented, despite broader feature overview. License is TBD; no code reuse authorized |
| [SmartLights](https://steamcommunity.com/sharedfiles/filedetails/?id=3785996415) | Presence/zone sensors and binding lights to switches; useful connection-UI comparison | Advertised B42.20; author explicitly says MP untested. No current-build integration verified |
| [Automatic Gate](https://steamcommunity.com/sharedfiles/filedetails/?id=3784740460) | Advertises B42.20+ remote gate motors with grid/generator/battery power | Specialized output, not evidence of a universal signal network; no API or compatibility verification |

Recommendation, not a new selected dependency: retain independent OMHTT controls and define a small optional adapter boundary for Pulse, held ON/OFF and separate power availability. Third-party sources must pass the same server validation, access, Horde consent, resource and bounded-work rules. Electricity availability must not automatically become an activation pulse. Repeated notification delivery must not cause duplicate activation; unload/removal must clear stale held state. Inspect exact mod source/version and author integration hooks before writing an adapter; do not take ownership of another mod's generator ledger or replace its devices. No dependency downloaded, source copied, author contacted or gameplay modified.

### Outstanding discussion

First settle the relationship between filters and anyone-triggerable plates, plus the faction-base boundary and controller lifecycle. Recommended direction: everyone can physically trigger a plate; compatible receivers apply target filters, while controller access affects configuration only. Recommend explicit device assignments inside a clearly shown base area and persistent ownership when the controller loses power. Area selection and ownership-loss policy remain choices, not approvals. Recipes/service details and per-receiver signal responses follow. The requested controller protection may require bringing a limited controller function forward from R4C3; do not silently expand this into the complete controller/sensor feature set.

## C249: discussion prepared, 2026-10-15

Owner requests preparation and discussion of R4C1. This authorizes planning, not gameplay implementation or the recommendations below. 0.2.50 remains the installed build; owner and connected MP acceptance remain deferred. Preserve the existing [design](../DESIGN.md) and [roadmap](../ROADMAP.md) distinctions.

Confirmed earlier direction: a button produces a pulse; a pressure plate is ON while occupied and OFF when clear. Beam sensors belong to R4C3. Optional toggle switches are not confirmed. Passive barriers, beds and wire are not signal receivers. A control unit later manages authorized compatible smart defenses, not all world defenses.

## Historical C249 choices — superseded where C250 selects or amends them

1. **Input power.** Recommend A: mechanical button/plate, no battery in either input; the receiving device supplies its own required operating power. B: electronic button/plate, each requiring power. A reduces servicing; it does not make the receiving hazard free to operate. Exact receiver power belongs to its content contract.

2. **Pressure-plate detection.** Recommend A: living players and zombies, including crawlers; no corpses, dropped loot, animals or vehicles in this first slice. B: zombies only. The latter is a selective gameplay rule, not a claim that a mechanical plate identifies species. Player eligibility to press a plate is separate from permission to configure it and from receiver injury rules.

3. **Connection size.** Recommend A: 20-tile same-floor links, up to eight receivers per input and four inputs per receiver. B: 40 tiles, sixteen receivers and eight inputs. Both are provisional design limits, not measured engine limits. Select a source then compatible targets; lines appear during setup/inspection. Model an abstract wired connection through walls, without cable segments, cable collision or routing simulation; wire recipe/link costs still need approval. No relay chains or loops in the first slice.

4. **Multiple inputs and repeated cycles.** Recommend A: any occupied linked plate permits repeated normal-speed cycles; the last clear plate disables new cycles. B: one activation when the combined plate state first becomes occupied, then wait until all linked plates clear to rearm. Button pulses request one legal activation under either choice. Busy pulses are discarded with visible feedback, never accumulated; a pulse does not add an extra attack while a held input already enables cycling. OFF does not interrupt safe mechanical retraction.

5. **Multiplayer access.** Recommend A: placer/current owner faction configures, links and removes; anyone nearby can press a button. B: owner/faction only for configuration and button use. Admin override remains. Physical plate triggers follow choice 2 regardless of access. Validate authority over both link endpoints. Explicit ownership assignment/transfer and recipe/service details require follow-up; reuse attribution identity without silently changing access to existing turrets/traps. Recheck current faction membership, not a permanent saved member list.

6. **Recovery.** Recommend A: restore working inputs from actual occupancy and resume after a one-second safety delay when loaded/powered/valid again. B: require manual rearming after power loss, restart or unload. No historical pulse replay under either option. Broken/removed endpoints disable their contribution; picking up/replacing a device cannot inherit a stale link solely by occupying its old square. Unloaded regions do not simulate combat.

## Recommended implementation constraints, not new player choices

- SP and MP share signal rules. Server-owned device IDs, links, permissions, occupancy and admission; clients provide requests and display server state. The server validates sender, both endpoints, reach, range/floor, input mode, ownership and bounded counts. Persistent changes use the established server transaction paths; client world/player modData is not authoritative.
- Signals request operation, never bypass receiver cooldown, ammo, power, target eligibility or Horde receiving-run consent. Keep neutral collision and the existing attraction policy. R4C4 turret integration is separate and optional; Traps must function without Turrets installed.
- Change-driven link propagation and indexed local occupancy checks with bounded work. Do not broadcast unchanged ON states each tick or scan the full world per plate. Prove fast crossing, crawlers, adjacent plates and high-density behavior before selecting the final polling/edge-detection implementation. Timing options are goals, not current native API proof.
- Persist identity and link configuration, rebuild occupancy on activation, expire missing/stale sources and discard pulses. Test concurrent linking/removal/presses, duplicate commands, power loss, late join, area unload and fresh-process reload. Exercise actual dedicated/listen clients before acceptance; fixture checks alone are insufficient.
- Show Connected, Occupied, Unpowered, Disabled and Broken link states. A harmless setup test should highlight endpoints, never secretly fire an armed receiver. No general logic gates, arbitrary scripts, recursive signals or automatic Lure feedback loops.

## Scope and next discussion

R4C1 delivers the inputs, link model, feedback and bounded signal foundation. It does not by itself add a new damaging trap. Recommend Poke Floor as the first usable receiver under R4C2, then the dart emitter; do not implement either without its approved content contract. Recipes, skill/XP, dimensions/mounting, wire costs, durability, service and ownership transfer remain open after these six choices. No unapproved numerical costs are assigned here.

Evidence consulted: installed B42.21 `media/lua/server/ClientCommands.lua` dispatches commands using the server-supplied player; current `TurretControlAction.lua` validates requests and executes mutations in server completion; existing DESIGN.md specifies identity-based links, occupancy reconstruction and no pulse replay. These establish a compatible architectural direction, not proof of a native ready-made circuit system. No gameplay code or live-test result changed during this discussion.
