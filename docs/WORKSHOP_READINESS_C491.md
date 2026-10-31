# C491 - Connected testing and Workshop presentation

2026-10-27. Owner asks whether multiplayer testing should begin and requests review of earlier Workshop chats, recalling "OMH: Presentation". This is research/planning, not publication or new artwork approval. Installed gameplay stays 0.2.70.2; connected acceptance remains pending.

## Retrieved discussions

- **OMH: Presentation**, archived chat `01a0340d-a523-7d43-89ba-98f485388a6b`: Workshop page structure, owner-edited casual copy, feature overview near the top, website visibility, support/credits/disclosure, GIF/PNG preparation, Media Library links, discussion templates and an optional Horde Night trailer proposal. The 37-second trailer was for Horde Night, not an approved T&T requirement.
- **Prep Trait Shop Steam page**, archived chat `01a0bc34-0402-7ac2-a0b3-c68f2f33d9d0`: owner explicitly prefers the Horde Night Workshop page over the website as the main style reference, shorter copy, no em/en dashes, actual gameplay footage, preserved color, and 1,000-pixel-wide exports with proportions/readability retained. Owner provides the voice and media; implementation claims must match evidence.
- **Update Horde Night addon display**, chat `01a0e41c-c20f-7061-91fb-1c3f7d0c4151`: T&T cover/icons, compact addon artwork and Bugs/Feature Suggestions discussions. Later publication evidence in `../pz-mod-onemorehorde_protectthecure/docs/WORKSHOP_ADDONS_PUBLICATION_2026-09-27.md` confirms the final 180x180 addon row artwork, not the earlier overflowing 400px table version.

These are historical decisions/evidence. Older paths, game versions, Steam limits and public URLs require verification before publication; previous per-project permissions are not new T&T upload authority. The current Trait Shop description is more structured than its earliest chat draft, so reuse principles rather than copying stale wording.

## Existing assets verified locally

Paths below are relative to the workspace `C:/Users/bandi/Zomboid_Modding`:

| Asset | File | Verified |
| --- | --- | --- |
| Animated T&T cover | `OMH/Images/Traps & Turrets/final-template-PUNJABI.gif` | 400x400, 75 frames |
| Addon thumbnail | `OMH/Images/Workshop Addon Thumbnails/traps-180.gif` | 180x180, 75 frames; prior full verification retained |
| T&T icons/still | `OMH/Images/Traps & Turrets/icon_traps.png`, `icon_3.png`, `punjabistill.png` | Files present |
| Shared OMH templates | `OMH/Images/Templates/final-template-top-left.gif`, `final-template-top-right.gif`, `icon_3.png` | Files present |

The T&T image-folder scan found only the branded cover GIF, no MP4/WebM/MOV or gameplay GIF collection. This does not prove no recording exists elsewhere. No T&T Workshop description draft or approved gameplay capture pack was found in the inspected project records. Final owner/artist game assets remain a separate release task; current developer head/device art is not final promotional art.

## Recommended connected test

Use the same 0.2.70.2 packages on server and both clients. Start with two genuinely separate clients; a zero-client startup or split-screen fixture is not equivalent. Run hosted first if easiest, then repeat on dedicated before claiming both supported. Use server-synchronized supplies and keep both client logs plus the server log. Optional Horde Night/Trait Shop integration testing requires matching intended sibling versions; C488 hosted score deployment is still separately pending.

- Controller privacy and shared access.
- Simultaneous inventory and expansion swaps.
- Arc/Tack combat and ownership handoff.
- Fast-forward, Tack discovery and expiry.
- Faction XP, offline return and character death.
- Reconnect, server restart and retained inventories.
- Multiplayer notifications and translated status text.

Prove correctness at modest load before adding a horde stress case. Current automated/native checks justify starting acceptance testing, not declaring multiplayer complete. Existing saves do not need replacement for the Tack patch; an isolated test save is recommended to control test conditions.

## Proposed T&T media package

No new design is approved by this inventory. Recommend reusing existing branding and preparing these real-game captures:

| Piece | Capture purpose |
| --- | --- |
| Opening defense GIF | A readable turret-and-trap defense in action; show the core appeal quickly. |
| Modular turret GIF | Install/change a head or module, then demonstrate the resulting behavior. |
| Automation GIF | Trigger/device connection and the defense responding, with a short readable Controller view. |
| Manage/Controller stills | Equipment, expansion and grouping at normal readable UI sizes. |
| Sandbox still | A small representative selection showing customization; avoid a long scrolling clip. |

Keep original full-resolution recordings. Follow the established 1,000px-wide description-media convention where suitable, preserving useful aspect ratios rather than forcing every UI into 1000x375. Short single-purpose clips, colors/timing retained, no debug overlays in final exports. Keep 180px addon thumbnails separate from full-size feature media. Capture reference footage during testing, then record final promotional shots once chosen game art and behavior are stable. No AI art generation, automatic cropping, upload or publication is requested here.

Recommended page order: existing cover and short hook; concise feature overview and OMH website link; defenses/modules/automation demonstrations; customization; setup and independent Turrets/Traps entries; verified optional integrations and multiplayer support; Steam discussion links, credits and reviewed support/disclosure. Reuse the established Bugs and Feature Suggestions structure. Do not advertise undocumented T&T extension APIs, use a private repository as a public help link, or promise official scoring before the separate readiness/deployment work is complete.

Draft page copy and a capture checklist can proceed alongside testing. Finish game art before final promo capture; verify rendered Steam BBCode/media and every link before separately authorized publication. No Workshop listing, gameplay file or hosted asset was changed. **Test now when available: connected multiplayer.**
