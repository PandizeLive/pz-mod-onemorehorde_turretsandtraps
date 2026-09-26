# P1C1: current-build evidence and persistent device shell

Status: approved and implemented as `0.1.0-p1c1`; awaiting player acceptance. Read the [implementation record and executable owner test](P1C1_RECORD.md). The requirements below remain the checkpoint's acceptance contract.

## Goal

Prove that one uniquely identified device can be created, found, saved, restored and removed correctly in the current game. Establish the package identity and authoritative lifecycle before adding weapons, recipes or rewards.

## Inputs to resolve

- Record exact installed Project Zomboid build and game/vanilla source paths. Reinspect current methods instead of assuming the B42.20.2 historical references match.
- Confirm the proposed package ID `OneMoreHorde_TurretsAndTraps` and the version-folder convention used by the actual target build.
- Review whether a native global-object system or a small server-owned registry best fits a few test objects. Choose based on a working vanilla call site and persistence lifecycle.
- Use a temporary test-only ownership identity. Full faction assignment/transfers remain a later decision; do not accidentally establish a permanent public ownership format here. No geographic base-claim system is required.

## Deliverables

1. A minimal package with version identification and explicit SP/client/server roles.
2. One temporary test device with stable identity, marker, coordinates and a small mutable test condition value.
3. A validated creation/removal path with no gameplay damage or live-world mass cleanup.
4. Reconciliation across save/reload and area unload without duplicate objects or reset condition.
5. Evidence notes naming the current methods/call sites and limitations, plus the exact test source snapshot.

Expected change scope: this project's initial package and local validation tooling. No Horde Night, Trait Shop, Cure Defense, website or public Workshop change is included unless separately authorized for the concrete test workflow.

## Exclusions

Turret combat, sprites beyond the minimum original test asset, final recipes, full faction ownership UI, shared/offline XP, scoring, signals and Cure simulation are outside this checkpoint. Do not use a prototype test control as the final player interface.

## Acceptance

SP and a minimal dedicated check must agree on one object, stable identity and saved test condition. Creation/removal is authoritative; repeated requests do not duplicate it. Reload and area return restore the same object without affecting unrelated objects sharing a tile/type. Capture the loaded version and review logs.

## Owner test to prepare after implementation

The following is the original acceptance outline. The [record](P1C1_RECORD.md#owner-test-single-player-first) supplies the exact installed package and complete current owner test; connected-player dedicated testing follows the first SP result.

1. Load the prepared test world and confirm the exact version in the supplied diagnostic; no startup errors appear.
2. Place the test device and change its test condition using the supplied control; one object and the expected value are shown.
3. Save, exit and reload; the same identity and condition return with no duplicate.
4. Leave and return far enough to exercise the agreed area lifecycle; identity and condition remain unchanged.
5. Remove it and reload again; only that device stays removed, with nearby objects unaffected.
6. Complete the prepared one-player dedicated variant, then provide the requested logs and observations together; both modes must show the same result.

The published/distributed test build requirements must be satisfied before asking the owner to perform multiplayer testing. The implementer should automate setup and verifiable checks where possible instead of requiring the owner to execute developer commands.

## Next checkpoint

P1C2 proves damaging obstruction/thump behavior. It must not assume that this persistence checkpoint established a combat callback.
