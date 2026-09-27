# v0.2.2: readable menus, barrier servicing and five-item packs

Portable barriers were missing the Crafting mod category, and selected-recipe descriptions clipped the tool warning. Add Turrets & Traps alongside Carpentry, wrap only OMHTT descriptions to the available width, and show purpose plus damage/durability/size for craft, build and deploy.

Add shared condition display on either placed half and ten-second pickup/free repair actions. Pickup returns one full-condition item and removes the pair once; free repair restores 100 durability. Validate cancellation, identity, proximity and capacity at completion. Add five-item packs at 9.9 encumbrance (67% less than five loose items), using native crafting transactions with no transport/service XP. Preserve the existing construction recipe and XP.

Validation: 299 Kahlua assertions, installed menu/layout methods with doubles, 79 native translations, native five-to-one/one-to-five transactions and existing construction/persistence smoke. Player UI/action acceptance is pending; [complete test](PHASE_2_CHECKPOINT_1C.md#owner-test). Requested directional-risk vaulting remains a collision/animation prototype, and this candidate keeps the existing blocking behavior.
