# 0.2.64.4 - C427 approved feedback correction

Owner approval: C426 selects C425 option 1A and corrects the Controller layout; the subsequent "Approved" authorizes this implementation and local installation.

- Arc volume, blue glow and fade
- Lever wall artwork
- Tether launch height
- Controller equipment layout
- Automation rarity icons
- Module battery costs and totals
- Repair requirement labels

Arc now uses a dedicated four-triangle crossed-plane visual with a pale core and blue alpha falloff. An 80 ms flash precedes a 250 ms quadratic fade. Native per-item world alpha provides the fade; world depth, visibility checks and the existing 192-draw budget remain. Firing gain rises from .65 to 1.3; impact gain stays .12, with master volume, Suppression and impact-start limits retained. Native import/alpha-path checks pass; rendered glow and listening balance require the owner test.

The Tether nail/cable and Arc no longer apply the legacy camera-height compensation in the newer chunk renderer. Installed 42.21 bytecode confirms the chunk camera lacks the old -.48 model translation. Actual Tether mount, sag and floor heights remain unchanged. Lever retains its four dedicated wall-face developer sprites; the load hook that replaced them with differently anchored native switches is removed. Geometry checks are not rendered alignment acceptance.

Battery and expansion divide the former left-side battery area equally. Online/range and stockpile access return to the original adjacent right-side area. The extra equipment row is removed and the battery count clips inside its narrower slot.

Eight owner Automation PNGs are copied unchanged, including their 28x29 dimensions. Native aspect-preserving icon drawing and existing effective-rarity hooks cover all eight Automation definitions without scanning inventories or changing loot weights. Hash provenance: art/MODULE_ART_C427.json.

Abundant through Mythic add .15/.25/.50/.75/1/1.5/2 times base cost. These are additions: one Mythic gives 3x total. Existing Sandbox scaling and active-module exclusions remain. The shared firing-load formula also continues to affect generator fuel; Regulator reduces battery use only and adds no surcharge. Battery hover shows installed module total and, when present, the effective total after Regulator. Siphon is not treated as a guaranteed discount. Repair menus label Required material and Required tool with existing availability colors, skills and time; costs are unchanged.

No Workshop upload, hosted LootLab update, new loot weights or connected-multiplayer acceptance. [Verification and owner checklist](TEST_v0.2.64.4.md).
