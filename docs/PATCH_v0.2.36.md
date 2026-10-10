# 0.2.36: tier groups, continuous Building and zombie collapse

Approved under C110 on 2026-10-09 after the C109 / 0.2.35 findings. This is a local corrective patch with the required C108 GitHub development mirror. No new content or recipe balance changes.

- Restore OMH: Traps and OMH: Turrets categories. Within native recipe list view, expandable groups are Normal, Reinforced and Packed. Building uses Normal and Reinforced; bundles remain crafting-only. Search/favorites operate on the filtered recipes, deliberate collapse survives refresh, and vanilla groups remain intact. Native icon view remains flat.
- Zombies use the installed `Zombie_HitDeath_HeadTop` forward-collapse clip for Bed Spikes, with clip displacement disabled and the existing bumped-to-getup completion markers. Players retain their sprint-trip clip. Damage still requires a fresh fall actually on the bed; no damage is granted for landing elsewhere. Recovery protection, damage and wear are unchanged.
- Building retains the placement cursor and orientation after a completed placement. Each action binds the next exact carried item. Once those run out, a preview remains; the next valid world click crafts through the original recipe and places its actual output. No speculative stockpile crafting. Cancellation suppresses automatic placement, retains any completed crafted item, and never reuses a consumed trap. Raw-material availability is refreshed on inventory changes rather than scanned every render frame.
- Zombie collapse plays native `ZombieTrip` and `BodyHitGround` animation events. Actual damaging Bed Spike falls play `SpearCraftedHit` once; prone updates remain silent. No copied audio assets or added zombie-attraction radius.

## Evidence and limits

Installed 42.21 sources: `ISRecipeScrollingListBox.addGroup` and native group toggles; `ISBuildingObject.tryBuild`, `ISBuildIsoEntity.tryBuild`, `ISBuildAction.perform`; `ISHandcraftAction.FromLogic`; zombie `knockeddown-headTop/HeadTopFall.xml`, `climbfence/start.xml` and `falldown/frombehind.xml`; generated zombie-foley and melee-spear sound registrations. Validation manifests record native source hashes.

Focused Kahlua checks cover native list collapse/selection/filtering, exact carried/output identity, repeat/cancel/close behavior, blocked duplicate clicks, orientation, click-only recipe fallback, unchanged-inventory cache behavior, one sound per damage event, and player/zombie animation separation. Native write/read checks cover original recipe consumption, tools, zero deployment XP, registered sounds and controlled get-up transitions. See [release evidence](RELEASE.md) for completed run/install results.

Headless checks do not prove visible collapse displacement, audible timing, continuous mouse interaction or absence of the previously reported client pauses. Only the [four-step owner test](TEST_v0.2.36.md) is requested; historical failures and tentative passes remain intact.
