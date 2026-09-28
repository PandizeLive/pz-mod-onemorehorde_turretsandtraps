# Validation environment

Observed 2026-09-28: installed stock game is 42.21.0 / 4a0e9546ec. The previous validated game was 42.20.4 / b0bbce05d5 with PZOptimizer loose overrides.

Normal loose-first isolated startup failed before mod Lua with `NoSuchMethodError: void se.krka.kahlua.luaj.compiler.LuaCompiler.register(se.krka.kahlua.vm.KahluaTable)`. The initial failed transcript was overwritten by subsequent smoke runs; this note records the observation, not a retained crash log.

Final validation and server-write/server-read logs use `OMHTT_STOCK_CLASSES=1`, loading stock game classes before loose overrides. No game or optimizer file was changed. Passing isolated probes do not demonstrate that the owner's ordinary game launcher starts with the incompatible overrides still installed. Resolve that external mismatch before the combined player test.
