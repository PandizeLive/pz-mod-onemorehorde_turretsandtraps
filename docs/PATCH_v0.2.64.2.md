# 0.2.64.2 - Owner module icons

C423: Owner requests the updated Performance artwork and new Utility icons, applied like the previous rarity-aware set.

- Updated Performance icons
- Rarity-aware Utility icons

The newer Performance `*2.png` set replaces the seven existing rarity textures and the base fallback. Utility supplies seven rarity textures plus its base fallback for Grid, Siphon, Lure and Void. All sixteen 32x32 RGBA images are copied byte-for-byte from the owner's module folders. Source paths, packaged paths and hashes are recorded in art/MODULE_ART_C423.json. Original artwork is unchanged.

Utility joins the existing lazy item-icon/tooltip/Manage-slot hook, which reads effective rarity and caches textures. Existing items refresh when drawn; changed rarity selects the matching image. No extra world/container scan. Unsupported categories and Expansion Kits retain their existing artwork. The four Utility item scripts also use the supplied neutral fallback instead of the technical cube.

This changes presentation only. LootLab settings, rarity assignments, weights, module behavior and balance are unchanged. No hosted LootLab deployment or Workshop upload.
