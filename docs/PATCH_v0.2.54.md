# 0.2.54 — Controller corrections and Siphon

Approved by C314 after C310–C313 selections.

- Siphon Module
- Rotary Synergy
- Limited Martyrdom chaining
- Grouped Controller menu
- Incoming connections and individual Disconnect
- Set Aim
- Pressure-plate draw order and pickup animation
- Exact module swaps and slot feedback
- Manage alignment and action tooltips
- LootLab Siphon catalog

Siphon restores 2× the shot’s actual paid battery cost per eligible kill, plus 1× per additional module. Module-generated secondary kills need Synergy. Original-battery identity, charge cap, server death authority and Horde Night consent/scoring remain in force. Rotaries settle the accumulated paid swing/pass cost, including interrupted motion. Both arms share that record. No health repair is added.

Synergy allows one additional Martyrdom generation at 50% damage per initial-burst victim. Reduced bursts cannot chain again. Existing bounded queues, delay/audio and player injury rules remain. Saturated follow-up work is omitted without delaying confirmed damage.

The native cursor class is loaded when Set Aim starts. Pressure-plate sprites use the native Floor render layer. The Controller alone opens its menu, which separates Manage/Set Aim, Connections, and Access & Assignment. Exact swaps retain slot order and return the displaced item to the incoming item's authorized source.

LootLab is updated locally with Siphon, account-scenario migration and matching server catalog changes. Hosted publication awaits Cloudflare login; no production change is claimed. [Verification and short test](TEST_v0.2.54.md).
