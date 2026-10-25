# 0.2.68 - Shared defense XP

Owner approval: C464, implementing C460-C463. Coordinated versions: T&T 0.2.68, Trait Shop 0.9.1, Horde Night/Cure Defense 0.6.16.6.

- Half-value faction kill XP
- Equal personal PvP assists
- Delayed defense kill credit
- Character-bound offline rewards
- Independent Sandbox controls
- Horde eligibility integration

For a normal reward of 100, the eligible owner faction shares 50. On defense-credited PvP kills only, eligible personal assistants share the remaining 50 equally; no assistants leaves it unawarded. Repeated hits do not increase a share. The owner's personal assist can combine with their faction share. Source modes, enemy/faction rules and account-victim cooldowns still apply. Ordinary kills never also receive a defense payout.

Authoritative records use server GlobalModData, not mutable player modData. Device owner identity is retained for delayed effects and portable defenses. Pending shares bind to existing living characters; reconnect/restart cannot duplicate them and replacements inherit none. Recovery clears the encounter, while later confirmed attackers replace finishing credit. No proportional wound simulation or arbitrary gameplay encounter timeout.

Changed systems: defense owner registration, confirmed injury adapter, lethal hooks and optional XP Sandbox settings; Trait Shop injury evidence, attribution, offline settlement, recovery command and deferred native death processing; Horde offline permission lookup and defense settings audit. No crafting, combat damage, loot, module or art tuning.

Performance: participant sets store unique character lives, not hit history. Recipient lookups use indexed owner/faction names rather than every saved account. Body snapshots run on player hit events; full-recovery checks run at most once per second only for active encounters. No extra per-zombie scan. The native and behavioral checks do not establish a live server FPS claim.

See [verification and limitations](TEST_v0.2.68.md). Workshop drafts retain all unrelated unuploaded changes. Local install does not publish any package.
