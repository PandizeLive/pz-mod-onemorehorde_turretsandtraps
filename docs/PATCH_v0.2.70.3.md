# 0.2.70.3 - C494 connected-test corrections

## Authorization

2026-10-28: owner selects C493 **1A** and requests all eight replacements from `OMH/Images/Traps & Turrets/Modules/Automation 2`. The owner's annotation explicitly retains Private read-only inspection and requests visibly grey, inaccessible mutation controls. This supersedes C493's proposed inspection block. No Workshop upload, sibling changes or website deployment is authorized by this patch.

## Final behavior

- Combat owner receipts no longer invoke the unexposed `NetworkZombieAI.extraUpdate` method. Health uses the native owner transport and the existing acknowledgement/reconciliation protocol; authoritative terminal death and reward ownership remain unchanged.
- Running client turret/Controller transfers retain reach and write-access checks while native inventory replication arrives ahead of Done. Queued/pre-start actions and every server completion still validate the exact source, destination, item, capacity and permissions. This replaces the incorrect active-client item-source test; no extra transfer protocol or polling loop is added.
- Private turrets remain inspectable. Mutation buttons, item sockets, name entry and all three sliders are dimmed/locked. Details, contents, tooltips, scrolling and closing remain available. Lost permissions clear pending slider edits, and existing load-order editors lose their mutation controls. Server write enforcement and Controller discovery privacy are unchanged.
- Eight Automation 2 images replace the existing automation base/rarity textures byte for byte. Mapping and dimensions remain unchanged; no duplicate runtime art or unrelated replacements. Provenance is in `art/MODULE_ART_C494.json`.

## Observer effects

No independent delivery failure is established by the available owner logs. Production-path regression checks cover nearby shooter/observer recipients, native serialized launch data, client-local timing, duplicate suppression and retained line of sight. Bounded existing diagnostic infrastructure now records presentation-send recipient counts/packet IDs, and client receipt logs include that packet ID. This joins server send, client receipt and first render evidence without new network traffic. The owner report remains pending a connected two-client retest; it is not declared fixed by fixtures.

## Release boundary

0.2.70.2 was successfully uploaded to Workshop item 3828638252 (C492). Therefore the new cumulative changelog contains only the net changes above since that confirmed upload. Local packaging/install does not upload to Steam or update the hosted test server. Existing saves/settings are retained; no new world is required.

See [verification and owner checklist](TEST_v0.2.70.3.md).
