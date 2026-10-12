# Current development and planning handoff

**C182 / 0.2.47.3:** approved rotation ticks (1B), pickup selection cue (2B), custom rarity audio pending owner files (3C), and a pulse-only four-second fade (4B). Pack audio uses native UI events with one shared bounded tick stream, no catch-up burst and cleanup on Collect. LootLab now shows calculated rarity in the normal list, refreshes draft feedback, and automatically groups equal weights when reopening. Confirmed tier weights persist for the page session; full reload derives centers from loaded weights. [Patch](PATCH_v0.2.47.3.md) | [Test](TEST_v0.2.47.3.md) | [Contract and pitch limitation](PACK_POLISH.md).

Native pitch variation requested, but additional randomized pitch is **not implemented**: the installed event path ignores clip pitch and the emitter setter writes every queued/active sound. Native rotation is played unchanged; no unrelated audio is modified. Custom rarity sounds remain pending, with the approved pickup cue providing selection feedback. No particles. No loot/default/rarity-formula changes.

0.2.47.3 is installed from its immutable test tag; all 256 installed files and both backups verify. LootLab is deployed and verified. Installation/deployment evidence is in RELEASE.md. Owner acceptance remains pending. The current console still identifies 0.2.47.1; it cannot validate 0.2.47.2/3. The owner's 0.2.47.2 LootLab report is recorded in its test findings.

C181 fixed the native carried-capacity warnings: six-weight base permits 44 contents weight, while ammo-count limits remain separate. Defaults fill all seven rarity bands; saved all-one multipliers leave Common empty. Saved tuning is preserved.

GitHub: `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1), targeting dev. Began at 7296be8243fc9877197d0b0330e381d99007a82f after fetching origin; no incoming planning PRs or dev changes. C108/C119 require mirror of code, plans and findings; no Workshop publication.

R1C3 performance and R3C7 acceptance remain open; preserve the owner's earlier accepted lag improvement. SP/fresh-world independent Turrets/Traps packages remain. Packed-turret weight compression is abandoned (C170); Viewpoint is a separate unapproved prototype. [Roadmap](ROADMAP.md#current-checkpoint-status-and-next-work) remains the next-work index.
