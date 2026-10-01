# 0.2.21 — owner test and discussion, 2026-10-01

Owner reports Test Complete with two findings: the gun disappears while turning, and turret reloading has no sound. Owner requests discussion before gameplay changes, native firearm reload equivalents, potato reload HTML candidates, and a stackable Suppression Module proposal. No next gameplay patch is authorized by this test report.

Capture: diagnostics/captures/20261001-190017-1604. Original console SHA-256 0619EC56ECF24116C908CB82A1D388250C892A15150754A88AFFD197546B8FD1. Runtime version 0.2.21; 38 firearm shots, two magazine transactions, 32 first-render records and three Manage openings. No mod runtime exception frames or former Texture/Double errors found. This does not prove GPU visibility or all unreported steps.

## Rendering diagnosis to verify

Current 42.21 JAR: LuaManager.GlobalObject.Render3DItem forwards forcedRotation to WorldItemModelDrawer.renderMain. The negative value used for upright item XYZ pose permits renderAtlasTexture; WorldItemAtlas.ItemParams.isStillValid invalidates that cached picture when any world rotation changes. Continuous turning can therefore churn static-item atlas entries. This is a strong candidate for the disappearing gun, not GPU-confirmed root cause.

Propose a scoped live-model rendering path that keeps upright pose, muzzle alignment, attachments and correct depth, then verify a full turn. Do not permanently disable the global item cache or use a fake placement state without checking its additional native behavior. Add transition-level diagnostics; avoid per-frame logging/cache rebuilding. Previous eight-heading matrix tests checked geometry, not atlas behavior.

## Reload audio proposal

Use the actual firearm's InsertAmmoStartSound, InsertAmmoSound, InsertAmmoStopSound, EjectAmmo equivalents and RackSound, matching real cycle transitions. Current native groups: M9, JS2000Shotgun and MSR788. Read these from the weapon, not a new duplicated gun sound table. Play at the turret and stop/cancel appropriately; do not replay on Manage refresh or emit an entire burst of per-round events after lag. Zero-time Autoloader should avoid a multi-second reload sound; pump/bolt feedback remains.

The potato head needs an owner-selected short feed/seat/pressure sound, once per actual reload. Updated art/POTATO_AUDIO.html contains 16 existing native loose-file candidates and the supplied fire/impact clips. Current bank-only weapon events need not match the legacy loose samples used for auditioning. No new native audio is copied into the gameplay package.

## Suppression proposal — not approved or implemented

One regular, loot-only, stackable module. Proposed baseline: hearing radius multiplied by 0.75 per effective module, maximum four, yielding 75%, 56.25%, 42.19%, 31.64% of the original radius. Expose per-stack reduction and maximum stacks with Modules/Loot settings. This changes newly emitted firing noise; it does not erase existing zombie targets or silence footsteps/impacts.

Audio and AI hearing are separate. The user-defined 250 Hz wet envelope is linear through (0,0%), (.04,100%), (.09,100%), (.18,25%), (.69,0%). Equal .04/.09 values imply a plateau. HTML previews this on the supplied potato shots using an explicitly provisional 48 dB/octave filter and complementary dry gain, with original pitch. It is not game DSP implementation or final audio design.

Current emitter APIs expose volume/pitch and existing FMOD parameters, not generic creation of a per-shot DSP chain. Low-level FMOD JNI contains DSP calls; that does not establish supported Lua access or safe handle/lifetime management. Do not promise an arbitrary native-gun filter or invent a parameter name. A custom authored FMOD event/bank needs a separate compatibility proof; prebaked owner-supplied potato variants are the simpler option. Baked envelope timing shifts with random playback pitch, whereas exact real-time timestamps need an audio-engine timeline. Avoid 40ms Lua frame-based filter automation.

Recommended scope after discussion approval: turning repair, native/selected reload feedback, module hearing-radius effects and settings. Exact universal live filtering remains a separate feasibility decision. High effort is appropriate for the renderer/audio lifecycle work.
