# 0.2.63.2 - C401 performance corrections

- Fair routine and queued device updates
- Complete incremental Controller cache traversal
- Cached Connections labels and layout

Owner approved fixing the C400 findings and will test personally when available. No debug stress presets, balance changes or additional content are included. [Verification](TEST_v0.2.63.2.md).

Routine work and queued receiver work alternate first use of the existing shared soft time budget. Dirty receivers use FIFO order with at most 32 dispatches per pass; routine work retains its 64-device cap. When one dispatch consumes the full budget, both classes still progress across successive updates. This is fairness, not a hard latency guarantee: individual Lua/native operations are not preemptible, and heavy loads can still delay work. Existing action completion and input/power rules are retained.

Controller scans now traverse an indexed, weak-reference cache in batches of at most 64 slots, then perform the bounded spatial scan. Removal swaps out indexed entries; collected slots are pruned during traversal. This reaches assigned out-of-range devices beyond the former fixed 64-entry prefix without scanning the full cache in the opening frame. Concurrent membership changes may require the next scan to observe a swapped entry.

Connections checks structural inputs every 500ms but retains unchanged rows, markers and edges. Replicated live state updates existing row references. Names, links, head/kind/number, range status, organization revision, explicit group/collapse refreshes, font size and dimensions invalidate relevant layout. Fitted labels survive rebuilds when text/width/font are unchanged; retained label entries are limited to the current structure. Group labels are fitted during layout instead of each rendered frame.

The tests measure operation counts and simulated scheduling, not real FPS. Rendered and connected-player acceptance remain deferred.
