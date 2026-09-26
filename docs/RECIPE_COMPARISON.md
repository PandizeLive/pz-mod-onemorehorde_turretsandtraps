# Spike Barrier recipe review

Reviewed 2026-09-26 at the owner's request. Source: installed Cheval de frise Workshop item 2927800433, `mods/ChevalDeFrise/42.0/media/scripts/module_barriere.txt`, compared with OMH v0.2.0. This comparison uses the B42 definitions; the separate legacy recipe is not the comparison baseline.

Reference file SHA-256: `a2c96d86d53dbeb71d1de10be7dff966177a127a72f17e1b7262b61f808824e7`.

| Requirement | Cheval de frise: wooden | OMH v0.2.0 Spike Barrier |
| --- | --- | --- |
| Planks consumed | 2 | 4 |
| Other materials consumed | 4 binding units from ripped sheets, dirty ripped sheets or twine | 8 nails |
| Tool retained | Hammer | Hammer |
| Skill requirement | Carpentry 3 (`Woodwork:3`) | None configured |
| Base crafting XP | 5 Carpentry XP | No award configured |
| Scripted recipe time | 200 | 200 |
| Construction footprint | 2 tiles | 2 tiles |

Twine is a drainable item in the installed game; its input quantity is uses, not four entire rolls. Scripted time is not a promise of 200 real-world seconds. Crafting XP is separate from the later faction defense-kill XP integration.

The reference also defines a metal barrier: MetalWelding 3, 2 scrap metal, 4 small metal sheets and 2 blowtorch uses, with 5 MetalWelding XP and scripted time 200. OMH has no metal recipe in this candidate.

Ours currently consumes twice as many planks and depends on nails, while allowing construction without Carpentry progression and awarding no crafting XP. These are different resource/progression tradeoffs, not a balanced equivalent. The current recipe was assistant-selected for testing without asking the owner and remains unapproved.

The owner should select ingredients, required tools/skills and crafting XP before a recipe patch. Using the reference wooden recipe as a discussion baseline is a recommendation only. No reference code/art was copied, no runtime recipe changed, and no version/install/upload followed this review. Phase 2 implementation authorization otherwise remains in effect; the five-barrier bundle and 67% encumbrance reduction remain confirmed.

## Owner direction after comparison

Confirmed 2026-09-26: the basic barrier consumes four total planks and/or basic crafted wooden spears in any mix, plus four binding units (ripped sheets, dirty ripped sheets or twine uses). Four spears is valid; no frame plank is mandatory. Basic Carpentry is level 1 and reinforcement is level 3, giving 10 and 30 base crafting XP under the corresponding-XP progression discussed with the owner. These replace the prior level 2/5 and one-fixed-plank proposals.

The owner subsequently approved a retained sharp knife/cleaver and the checkpoint. The approved reinforcement uses two extra planks, eight nails and a retained hammer, doubles maximum durability, preserves existing damage and raises retaliation to 25 damage per thump. At current tuning, a basic barrier at 83/100 would become 183/200: the existing 17 damage remains. Reinforcement is scheduled at P2C2a; packing/unpacking/redeployment award no crafting XP.

Installed B42.20.4 recipe evidence: `generated/recipes/recipes_carving.txt` defines CarveStick as one plank (or another listed source) to one short `Base.WoodenStick2`, with Carving 1 required. `recipes_spears.txt` defines CarveSpear as one long stick, sapling or listed household shaft to one `Base.SpearCrafted`; the short wooden stick and plank are not accepted. There is no default plank-to-multiple-spears conversion. Native alternatives are explicitly declared recipe inputs, not universal item equivalence. Current BuildLogic/CraftRecipeData bytecode and `ISBuildPanel:createBuildIsoEntity` require actual recipe inputs; building does not recursively craft missing spears.

The 0.2.0.1 candidate implements the basic recipe using native alternative inputs, Carpentry 1, one 10 base XP award, and the native wood-carving action. The cutting tool is retained with vanilla light wear and rejects dull/broken tools; wood/spear inputs use vanilla condition eligibility. Time remains 200 native action units and basic durability/damage remain 100/20. Reinforcement is not included in this candidate. See [current checkpoint](PHASE_2_CHECKPOINT_1.md) for evidence and the owner test; the older comparison above documents the 0.2.0 baseline.
