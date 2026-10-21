# 0.2.59 approved build — C370

Owner approval: “Approved” following confirmation that the next build's decisions were settled (2026-10-20). This authorizes implementation, native verification, local installation and the standing C108 GitHub mirror. It does not authorize a Workshop upload or merge.

## Scope

- Tether Dart Trap integration
- Uniform repair requirements and timing
- Condition-preserving recovery and deployment
- Portable multiplayer placement timing
- Poke Floor damage adjustment
- Head tooltip cleanup

Tether uses the approved four-direction wall panel, one reusable nail, six-tile range, 30 impact damage and 15 pull damage after a 0.75-second hold. It has 100 condition, loses one condition per completed cycle, weighs four, consumes no ammunition/power and accepts no modules. Unlinked traps sense zombies; any trigger link overrides sensing. Buttons request one cycle; held inputs repeat only after full return/reset; release finishes the current cycle. Player first-hit collateral uses one normal trap scratch. No piercing, knockdown or physical character pulling.

Crafting retains the selected Mechanics 2 / 20 XP / 30-second recipe: two Small Sheet Metal, one Metal Bar, one Rope, four Screws, two Wire uses; retain Screwdriver, Pliers and Wrench/Pipe Wrench. Repair consumes one Scrap Metal with retained Pliers. Disable the trap before servicing it.

Service rules follow [C368/C369](SERVICE_RULES_C368.md): traps 2s place/pickup and 4s repair; triggers 1s place/pickup and 2s repair; turrets/Controllers 5s place/pickup and 10s repair. One material and one retained tool per family; triggers use only their tool. Private exact condition survives moving. Deployment accepts worn barriers, while five-item packing still requires full-condition inputs to prevent free healing.

The existing native BuildAction does not honor recipe timing. Portable placement now uses an allowlisted shared timed action with server-derived duration and exact input references, then delegates construction/consumption to native BuildLogic and ISBuildIsoEntity. Ordinary construction remains native.

The Lever remains separate: its behavior is selected but its recipe/placement details were never settled. No recipe was invented. The former debug tether mod stays retired.

## Verification status

Kahlua regression suite: 26,119 assertions, including accelerated SP placement and worn-barrier eligibility. Native write/fresh-process read pass, including exact-input consumption, server duration/argument serialization, crafting and Tether combat/service behavior. Traps-only, Turrets-only and combined startup pass. Tagged installation is next. Rendered and connected-client acceptance remain distinct from zero-client native probes. See TEST_v0.2.59.md for final evidence and owner steps.
