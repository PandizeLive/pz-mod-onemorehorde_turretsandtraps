# Checkpoint record template

Copy only when a checkpoint begins. Replace every placeholder before handing it off as a completed record.

## Identity and authorization

- Checkpoint ID / title: TBD
- State: proposed / authorized / implementing / awaiting player evidence / accepted
- Source snapshot / package version / installed game build: TBD
- Authorized scope and date: TBD
- Effort recommendation / estimated duration: TBD
- Applicable decisions and unresolved dependencies: TBD

## Problem and expected behavior

Describe the player-visible outcome and the exact limitation or defect being addressed. State which runtime modes are affected.

## Scope and ownership

List the concrete files/components, sibling-project dependencies if any, persistence changes, and features deliberately deferred by the roadmap. Separate confirmed requirements from experimental tuning.

## Implementation evidence

Record current-build vanilla/API evidence, significant choices, changed-file summary, migration/rollback behavior and any limitations. Link to the actual source and logs, not merely a remembered method name.

## Verification

| Check | Environment / command | Expected | Actual | Evidence |
| --- | --- | --- | --- | --- |
| Smallest meaningful check | TBD | TBD | Not run | TBD |

Distinguish static validation, in-game observations and publication. Explain skipped checks only when material to readiness. Add broader testing only for changed behavior, failures or unresolved risks.

## Owner test

Write one complete sequence of 4-8 short numbered steps. Put exact build and prerequisites in the first step, expected behavior with each action, and log/report instructions in the last. Do not describe a future test as ready.

## Result and release

- Acceptance criteria met: TBD
- Known risks / remaining decisions: TBD
- Logs reviewed: TBD
- Workshop draft changes and confirmed upload baseline: TBD
- Published item/version evidence, if applicable: TBD
- Next checkpoint: TBD
- Handoff: Test now / Wait for a patch / Decision needed
