# Native barrier controls, connected corners and safe servicing

The 0.2.4 player test exposed misleading collision footprints, an endlessly walking pickup approach, right-click-only vaulting and a scratch applied after the animation. Version 0.2.5 adds native Interact/run/sprint input routing to the low-fence action, collision-line previews, independently owned perpendicular corner joins, contact-time spike scratches, and collision-checked servicing approaches with stall cancellation.

Sandbox options are grouped into General, Spike Barrier and Debug. Vault Scratch Chance is 0-50 (default 5); Show Collision defaults off. Repair stays tool-free and takes ten seconds, with the redundant menu wording removed. Recipes, bundle weights and XP remain unchanged. The owner's existing mod-list icon is preserved.

Validation and limitations: [checkpoint](PHASE_2_CHECKPOINT_2_VAULT_REPAIR.md). Native and Kahlua results are recorded under `diagnostics/v0.2.5`; rendered SP acceptance remains pending. No remote push or Workshop upload.
