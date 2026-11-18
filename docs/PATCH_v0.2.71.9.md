# 0.2.71.9 rotary contact repair

A rotary arm now evaluates the path it swept while a nearby standing target moved. The server uses the existing motor history, observation stream and damage transaction for both stock heads and registered two-arm heads. It applies each arm's damage once per victim per pass. Early reports wait for recorded travel. Short pauses, changed ownership or posture, stale observations and powering off break continuity. With insufficient movement evidence the turret resumes from the next usable pair of observations.

The independent sweep calculation splits cone reversals, follows changes in relative bearing near the pivot and checks reach and obstruction at contact. A completed stop holds its endpoint in motor history. Stationary targets use the existing angle calculation.

The last confirmed unlisted Workshop upload was 0.2.71.8 for item 3828638252. Its frozen changelog matches the prior draft. The 0.2.71.9 draft covers the rotary changes since that upload. [Verification and upload evidence](evidence/c546-verification.json).
