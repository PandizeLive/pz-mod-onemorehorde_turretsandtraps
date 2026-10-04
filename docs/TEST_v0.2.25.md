# 0.2.25 owner test review

Owner reported Test Complete, then questioned M16's two shots/second, repeated console output, loot tuning and similar rifle damage. Console reviewed: 0.2.25 loaded; 1,492 T&T records, including 584 transfer records (570 bullets) and 316 repeated inactive states. Native Action traces contribute separate output. Measured shot stages were mostly 0–2 ms; these are not full-frame measurements.

M16 used RecoilDelay 15 / 30 = 0.5 seconds. Acquired-target firing also ran through the 0.25-second detection interval. Each ammo transfer reset automation through a full configuration refresh. C77 addresses these causes.

MSR788 and MSR7T both have native 1.2–2 damage and range 40; their critical/recoil values differ. M16 has 1–1.6 damage and range 30. Owner elected to keep native damage and criticals, reduce derived firearm rate to 0.75, and add engagement range/distance accuracy without Precision Fire or recoil simulation. No blanket claim of complete visual/audio/performance acceptance.
