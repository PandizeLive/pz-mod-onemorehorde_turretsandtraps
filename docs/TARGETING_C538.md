# C538: confirmed multiplayer targets and physical-projectile presentation

Owner approved C537 option 1A on 2026-10-31. Corrective build: **0.2.71.5**. No saved tuning reset, new world, sibling edit or live-server change is required.

## Resulting behavior

- Deliberate turret acquisition and commitment require a current validated position report for client-owned zombies. Server-owned actors and SP retain their native authority path. The existing 250 ms observation contract is retained. Missing/stale observations postpone firing instead of spending ammunition on an unconfirmed replica; explicit fixed-direction shots remain supported.
- Missing, wrong-identity, dead, wrong-owner and position rejections remain unavailable until a newer owner observation or an identity/owner transition. The previous unconditional one-second retry is removed for these failures. Other transient failures retain their existing retry behavior.
- Client zombie indexing still handles native creation-before-ID assignment immediately. A bounded native-list reconciliation additionally visits at most 128 actors every 100 ms, independent of shots; identity checks prevent recycled/unloaded actors from resolving. No full-list scan occurs in target lookup or every shot.
- Replicated no-target scanning state drives the client idle sweep. The visual heading does not modify the server's detection cone or aim. Sleep, wake, disabled state and actual target tracking take precedence.
- Lobber acquisition tests exercise the real search at 6, 8, 12 and 18 tiles, rejecting five and 19 at the normal 18-tile range/six-tile minimum. Acquisition logs retain selected target identity, observed position, range, minimum range, cone and distance with ordinary turret diagnostics enabled. This does not establish the exact cause of the owner's apparent eight-tile limit.
- Shared area-effect radius checks, Lobber falloff/secondary origins and Martyrdom child origins use the same validated owner coordinates. Physical child rays also require a current actor observation at selection and contact, preserving Fragment collateral rules. Eligibility no longer mixes an owner-position square with a stale native-position radius test.
- Ballista primary and physical child spear effects use the actual native ammunition model, falling back to Crafted Spear for an invalid family. Rendering runs in the opaque world pass with world lighting and visibility; it stops at contact. Models are cached locally and never inserted into inventory/world state. Rendered orientation remains an owner acceptance item.
- Scrap loading uses 25 native action units (approximately 0.5 seconds per item); spear loading uses 12.5 (approximately 0.25 seconds). Native 42.21 NetTimedAction bytecode multiplies duration by 20 ms, before applicable adjustments. MP batches retain a per-item cost and at most 20 exact items. SP uses faster native individual transfers. Dexterous, All Thumbs and glove modifiers remain; actual inventory weight is unchanged. Existing light-ammo/Makeshift batch tuning is unchanged. Rates depend on baseline weapon families, not removable module DPS.

## Evidence and honest limits

Eight frozen 0.2.71.4 production paths fail the new regression assertions; the corrected suite passes. The shared multiplayer matrix now supplies separate server/client actor lists and current owner observations rather than allowing one side's native-list fixture to overwrite the other's actors. This models the required synchronization contract; it does not pretend that a connected client participated.

The four prior native container exceptions remain unattributed. Current installed `LuaManager.GlobalObject.syncItemModData` bytecode sends relative to the supplied player's position, and `SyncItemModDataPacket.parse` dereferences its resolved container. Missing native containers can therefore throw before Lua can handle the packet. The captured exception contains no item ID or sender. No engine patch, delayed-send workaround or silent exception suppression is included.

The earlier MPFF/native pause conflict remains unresolved and unchanged. Do not describe this build as proof of flawless multiplayer, or as a fix for missing native Horde Manager spawn visibility. Owner acceptance is still required for live timing, aim, native spear orientation and the reported Lobber limit.

No new Sandbox defaults were introduced, so there is no matching Horde Night baseline edit. No gameplay changelog history is discarded: confirmed 0.2.71.4 publication is recorded in [baseline evidence](evidence/c538-upload-baseline.json), and only the next upload's net changes appear in the 0.2.71.5 draft.

[Verification](TEST_v0.2.71.5.md).

## C539 - minimum-range presentation discussion (2026-11-01)

Owner requests showing the Lobber minimum visually or removing it. Current `TurretHeads` defines six tiles, `TurretModules.inside` enforces it, and manual landing controls enforce the same lower bound. The existing selected-turret `TurretRange` preview draws outer coverage without the inner exclusion. This is a confirmed presentation omission; it does not prove the reported live eight-tile engagement cause.

Recommend **1A: retain the six-tile minimum and show its boundary in the existing selected-turret range preview**, with a clearly labeled inner no-fire area and usable coverage between minimum and effective maximum. Respect the current cone, 360 module and preview visibility; derive both limits from effective stats. Reuse cached geometry. This is separate from the removed Controller in-world gradient. **1B: remove the minimum** permits point-blank targeting and is a gameplay buff, requiring matching targeting/manual controls and projectile-contact verification. Neither option is approved or implemented yet. No package, saved setting or gameplay change. **Decision needed.**
