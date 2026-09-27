# v0.2.0.3 owner test: partial SP pass

The owner reported Test Completed on 2026-09-27. Reviewed console.txt captured at 00:16:05 EDT with `OMH.cmd -Action Capture`. Local capture: `diagnostics/captures/20260927-001605-5599/`; SHA-256 `A2B13D791955D6226CC6AF1C03ACAF5772ABBABF549216A6F680F86A971A9F22`. [Machine-readable review](../diagnostics/v0.2.0.3/owner-test-review.json).

## Confirmed by the log

- Authority and client loaded 0.2.0.3 in SP. The 17-key translation audit has zero missing keys.
- Building reports 13 categories and the translated Turrets & Traps label. Spike Barrier is registered once, categorized as Carpentry, and its native visibility callback returns true. The custom category was selected with Build Cheat both on and off.
- Four barriers completed with two parts each: three with Build Cheat, one without. All eight creation callbacks report valid native SpriteConfig, distinct A/B sprite identities and 100 condition. The normal build has one native `consume success` at console line 1407.
- All eight objects report full-square blocking, no pass-through and no hopping. These are configured flags, not direct evidence of attempted player traversal.
- Five preview results are Occupied, including a neighboring anchor whose second tile overlaps an existing barrier. Two previews are Blocked. No additional construction occurs at those rejected coordinates in the captured run.
- All four headings appear in preview; actual completed builds in this run face north. No Lua exception stack or the former missing-sprite-name creation exception appears.

## Remaining failure and limits

Six later `Invalid SpriteConfig object! scripted object = OMHTTSpikeBarrier` warnings occur at lines 1348-1353, frames 5634/5637. They follow three complete barriers (six parts), hot-save activity and a later player initialization. This is consistent with the outstanding sprite/component restoration problem, but the log alone does not establish the exact save/load boundary or prove which object emitted each warning. The fourth normal build later creates valid parts again. This is not a clean persistence pass.

No item-by-item inventory deltas, tool-condition delta or XP delta were logged. One normal material transaction completed, but exact ingredient quantities, retained tool and displayed XP are not separately certified by this capture. Visual layout, list/grid switching, cancellation and traversal also lack direct event evidence; Test Completed by itself does not assert that every expected result passed.

The errors mentioning vanilla Piano UiConfig, map vegetation, mannequin zones and map rooms are separate from the six OMHTT warnings. Do not report a globally error-free console.

## Next checkpoint

Keep P2C1a partially accepted. The next repair/proof must exercise real object save/load and cell unload/reload, retaining both part sprites, native component identity, collision, facing, shared condition and ledger ownership. Add load-state diagnostics sufficient to identify an invalid part and its serialized identity. Stable native tile definitions may be required; do not assume naming a file-backed sprite supplies a persistent tile ID. Do not accept persistence merely because the server smoke saves an empty fixture world or the Lua ledger round-trips.

Resolve this before P2C1b portable items and P2C1c five-item bundles. Their planned crafting/bundling workflow and 67% bundle-weight reduction remain unchanged. No runtime/package change, new test tag, install or Workshop upload was made during this review.
