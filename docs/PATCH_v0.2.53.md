# 0.2.53 — connected controls and larger ammunition reserves

C285 implements the owner's explicit approval of C283/C284, including multiplayer authority and GitHub development delivery. [Approved contract](checkpoints/R4C1_CONNECTED_CONTROLS.md). Rendered/connected multiplayer acceptance remains separate.

- Controller and remote turret management
- Pressure plates and wall buttons
- Device ownership and access settings
- Turret naming and automatic numbering
- Controller stockpile and inventory transfers
- Larger ammunition reserves
- Native two-handed heavy pickup
- Controller range and connection overlays

## Behavior

Controllers cover 20 tiles on the same floor, with 32 assigned inputs and 32 turrets. Assign devices explicitly, choose an input, then link its receiver. Plates offer Players/Zombies/Both. A held plate switches the existing turret power ON and supplies fire; release switches it OFF, including aiming. Multiple inputs combine with OR. Clear input links removes stale/destroyed inputs from an authorized receiver and leaves it OFF for deliberate manual reactivation. Buttons request one ordinary firing cycle; busy shots are not queued. Firing actuates; Detection supplies powered aiming/automatic targeting. Firing-only linked turrets shoot forward. Passive barriers, wire and beds are not signal receivers; Poke Floor remains R4C2.

Controller power uses grid/generator electricity first, then a small battery with 48 in-game hours of backup. Outages disable remote management without stopping independent direct links. Private/Faction/Public write access is server-checked; ordinary reading remains public. Only the owner/admin changes sharing policy. Current faction membership is checked, and ownership survives pickup/controller destruction.

The controller opens the existing modular Manage menu and a 500-real-weight stockpile. Drag exact items from player inventory or stockpile; select the destination for removals. No automatic resupply. New turret name entry supports custom names or Auto, using stable per-head numbering within its controller. Existing Equipment, equal-width Ammo/Void, Magazine/Reload, Load Order, modules and Lure layout is retained.

Large Expansion defaults: 1,000 potatoes; 350 spears; 350 launchable bombs; 900 scrap; 5,000 firearm rounds; 1,000 shotgun rounds. Lower expansion tiers follow C283. Existing explicit Sandbox scaling values are preserved. Turret-specific transfers admit real ammunition beyond normal container weight admission while enforcing type/count limits. Loaded pickup retains exact items and full weight; native two-handed heavy carrying is used when ordinary inventory admission fails. Void remains optional and unchanged.

## Performance and verification

Input occupancy responds to local actor-square changes, with bounded fallback work. Signal work has a two-millisecond budget, a 64-device batch ceiling and no catch-up firing. The saved backup battery is restored by exact native identity instead of slowly rescanning large stockpiles. Controller discovery scans incrementally; stockpile views page 200 items. Repeated ammo types are classified once per inventory summary; native exact items still incur count-dependent inventory/save costs. This is not a guarantee of frame-time performance with arbitrarily large inventories.

[Verification and five-step test](TEST_v0.2.53.md). Native save/reload checks include 5,000 real rounds and a loaded controller over 100 weight. Current shipped Lua passes the banned-call gate: no pcall/xpcall. Temporary native device sprites remain subject to rendered placement/appearance review. Fresh worlds are preferred; existing unowned 0.2.52 turrets need pickup/redeployment to register control ownership. Connected dedicated/listen-server acceptance and rendered/audio checks are pending, not prerequisites for this approved development delivery.
