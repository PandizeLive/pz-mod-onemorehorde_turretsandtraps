# Fix conditional damage initialization and Controller regressions

Native spawners can replace zombie health after OnZombieCreate, making healthy targets miss Initial Blow and giving Execute the wrong health percentage. Settle the baseline before damage or the first update; preserve known wounded baselines and unknown-target handling. Apply the approved18%/+2%Execute defaults without resetting saved tuning.

Also enforce host-owner Controller discovery and requests, queue own-device autoassignment, reject native placement blockers, support identical kit-stack swaps, correct icon/storage labels and add configurable collision-aware tether push/pull. Preserve legacy Poke item identity while hiding its debug duplicate. Horde's coordinated local patch updates reviewed settings and removes the combined-score example.

Verification and limitations are recorded in docs/TEST_v0.2.68.2.md. Native actor conditional damage is measured; rendered client behavior and connected multiplayer remain owner acceptance work. No Workshop publication.
