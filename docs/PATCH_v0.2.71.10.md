# 0.2.71.10 multiplayer damage scheduling

Several defenses hitting one crowd could fill the damage queue while the server repeatedly inspected hits waiting on the same zombie. The server now serves waiting victims in rotation, keeps each victim's hit order, and drops expired work without replaying rotary contacts or blocking fresh damage on that zombie. Rotary heads reuse detection work within each motor update.

The previous confirmed unlisted content upload was 0.2.71.8 for item 3828638252. The cumulative Workshop draft retains both pending 0.2.71.9 notes and adds the crowd correction. [Verification](TEST_v0.2.71.10.md).
