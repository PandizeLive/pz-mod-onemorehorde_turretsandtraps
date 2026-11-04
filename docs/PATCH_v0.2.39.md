# 0.2.39: paired Concertina Wire

C133 approves implementing C132 on 2026-10-11. R2C4 gains one linked 1x2 Concertina trap. One inventory item places two passable tiles sharing 50 HP, repair, pickup and breakage. Either tile selects the whole trap; pickup returns one item. Cost, weight 2, contact damage/slowdown/injury rules and service times remain unchanged. Bed Spikes retain independent durability.

Both rotated floor tiles must be clear and connected. A central saved wire record gives both native objects one identity and bounded nearby index; crossing the seam does not reset damage or player-entry timers. Removing or depleting one half retires both, with late-loaded orphan cleanup. Distinct sprite aliases reuse the existing WIRE pixels and texture page. No new art, animation, sound, crafting group or Sandbox setting is required.

The larger contact area at unchanged cost/weight/HP is approved; multiple actors can consume the shared durability faster. Fresh test worlds remain the policy. Module tuning/native capacity proof remains R3C4 work; no unfinished module behavior is included.

Validation and owner acceptance are tracked in [TEST_v0.2.39.md](TEST_v0.2.39.md). Cumulative unpublished Workshop notes are preserved. GitHub development mirroring applies; no merge or Workshop publication.
