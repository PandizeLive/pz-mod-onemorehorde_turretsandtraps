# v0.2.0.1: approved Spike Barrier recipe

Replaces the temporary hammer/four-plank/eight-nail recipe with the owner-approved four interchangeable planks/basic crafted wooden spears, four binding units (ripped sheets, dirty ripped sheets or twine uses) and a retained sharp knife/cleaver. Native construction requires Carpentry 1, grants one 10 base Carpentry XP award, and uses the native wood-carving action with normal light tool wear. Time stays at 200 native units; basic durability/damage stay at 100/20.

Existing objects and paired persistence are unchanged. Reinforced upgrades, portable items and bundles remain scheduled; this candidate does not implement them. Construction/combat remain SP-only.

Validation: 232 existing lifecycle assertions, 12 Kahlua modules and 61 native translation keys pass. Native B42.20.4 startup verifies skill/XP declarations and all 75 combinations of five wood mixes and fifteen binding mixes, using both knife and cleaver fixtures. Three wood units, three binding units, missing/dull/broken tools are rejected; ingredient previews consume nothing. The isolated server saves and shuts down cleanly (44.8 seconds). Ingredient checks run at OnServerStarted, after native input caches are populated; the runner waits for the probe rather than only the server-ready message.

These are real native input-eligibility checks, not player inventory/XP transactions. Existing lifecycle tests use controlled world/recipe doubles and verify one recipe execution for both parts. Player UI, animation, inventory consumption and displayed XP acceptance remain pending. See [release state](RELEASE.md) for the source tag and hash-verified local installation. No push or Workshop upload; cumulative first-release notes are preserved.
