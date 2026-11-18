# 0.2.71.2 verification

## C532 connected retest: failed

Owner reports delayed M16 Splitter visuals after ammo is exhausted, without new damage; construction-hook startup error; incorrect stabilizer wall placement; excessive click range; vegetation rejection; movement, Tether attacks/audio and Poke damage during multiplayer pause. Client/server version0.2.71.2 confirmed. [Diagnosis, proof limits and next scope](MULTIPLAYER_FEEDBACK_C532.md). Automated C531 evidence below remains historical and does not establish connected acceptance. No new patch or test request.

44,249 assertions, three frozen released-code negative controls, 266 compiled Lua files, native write/read and Traps/Turrets/both startup checks pass. Native stacked child shots apply exact health loss at contact. [Detailed evidence and limits](CONTACT_TIMING_C531.md) | [Verification receipt](evidence/c531-verification.json).

Zero connected clients participated. Real two-client smoothness remains pending. Installed and staged from immutable `test/v0.2.71.2` / `9f83c8e`. All 464 source and 640 tag/package/install/archive/stage files match; previous backups and page metadata/preview verify. [Delivery](evidence/c531-delivery.json). No Workshop upload, live-server or sibling change.

Test after uploading 0.2.71.2 and restarting server and clients. No new world required.

- M16 with five or six Splitters
- Potato Splitter and Fragment contact pops
- Rotary contact timing on both clients
- Construction over Poke stabilizers
- Disconnect without trap-render errors
