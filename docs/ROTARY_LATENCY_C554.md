# C554 connected rotary timing retest

The November 2 retest ran 0.2.71.11. Both ends logged `turretDetails=true`. All 38 server rotary hit entries had a positive damage completion and a corresponding client damage display. There were no recorded expired rotary movement intervals. The observations establish delivery for the hits that entered the damage system. They cannot count physical blade passes absent from that system.

From the zombie movement sample to the visible damage number, the median was 170 ms, the mean 180 ms and the maximum 373 ms. The maximum published sample-to-owner health application was 372 ms. The client emitted 38 individual displays but flushed aggregate owner-application counters for 37 samples. The table below uses the individual display measurements.

| Hit, by receipt suffix | Sample to server hit | Server hit to send | Send to display, estimated | Total to display |
| --- | ---: | ---: | ---: | ---: |
| 67 | 107 ms | 194 ms | 72 ms | 373 ms |
| 62 | 96 ms | 185 ms | 64 ms | 345 ms |
| 46 | 105 ms | 70 ms | 52 ms | 227 ms |

Every other display took 201 ms or less. The server queue summary independently recorded a maximum of 194 ms. This identifies the cause of the two outliers in this capture. The previous 319 ms hit did not have an individual trace, so its cause remains unassigned.

For both slowest hits, the same turret had already sent Martyrdom damage to the same zombie. Hit 67 waited 157 ms for that transaction to finish, followed by another 37 ms before dispatch. Hit 62 waited 121 ms for its predecessor, followed by 64 ms before dispatch. The 0.2.71.11 queue releases the victim when the prior receipt settles. Waiting hits are serviced by the tick worker. Pairing already-waiting hits cannot append damage to an operation that has left the server.

The server hit entry is joined to its result by source, victim and FIFO order; the client display joins by receipt and victim. The server's diagnostic `ms` field records the event time before deferred printing. Estimated send time is the result timestamp minus transaction elapsed time plus dispatch time. Sample age and display elapsed time use the game's synchronized clock. The remaining send-to-display time includes network transit and client scheduling.

**Decision needed.** **1A, recommended.** Prototype dispatching the next already-waiting hit as soon as that victim's prior acknowledgement finishes, subject to the existing work limits. On the recorded timings, dispatch at that moment could have saved up to 37 and 64 ms respectively, with all other stages held constant. Check fairness across zombies, exactly-once resolution, death callbacks and the 100-zombie mixed-base replay before packaging. **1B** keeps 0.2.71.11 for now. The detailed owner test is complete.
