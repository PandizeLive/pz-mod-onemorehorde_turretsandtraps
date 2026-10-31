local N = require("OMHTT/DefenseNames")
local mode = testMode
testMode = "server"
local first, second = {id = "name-one"}, {id = "name-two"}
N.ensure(first, "NamingFixture", "Fixture Button")
N.ensure(second, "NamingFixture", "Fixture Button")
check(first.displayName == "Fixture Button #1" and second.displayName == "Fixture Button #2", "Fresh numbering family starts at one and avoids duplicate automatic labels")
first.name, second.name = "Front Gate", "  front   gate  "
N.ensure(first, "NamingFixture", "Fixture Button")
N.ensure(second, "NamingFixture", "Fixture Button")
check(first.displayName == "Front Gate" and string.find(second.displayName, "#2", 1, true),
    "Case and whitespace equivalent custom names receive a suffix without renaming original")
second.name = "  front   gate  "
N.ensure(second, "NamingFixture", "Fixture Button")
check(second.name == second.displayName, "Repeated conflicting rename retains the resolved display name")
local number, identity = second.displayNumber, second.displayIdentity
second.name = ""
N.ensure(second, "NamingFixture", "Ballista")
check(second.displayNumber == number and second.displayIdentity == identity and second.displayName == "Ballista #2",
    "Changing automatic base label preserves reserved number and internal identity")
local item = {getID = function() return 78541236 end, getModData = function(self) self.data = self.data or {}; return self.data end}
function item:getFullType() return "Base.OMHTTTrapSpikeBarrier" end
function item:getConditionMax() return 10 end
function item:setCondition(value) self.condition = value end
second.condition, second.maxHealth = 37, 100
N.pack(second, item)
check(item.condition == 3, "Native item display may round but private recovery keeps exact health")
local restored = {id = "new-placement"}
N.restore(restored, {size = function() return 1 end, get = function() return item end})
check(N.health(restored, 100) == 37, "Exact health survives pickup and restore without rounding loss")
N.ensure(restored, "NamingFixture", "Ballista")
check(restored.displayIdentity == identity and restored.displayNumber == number, "Exact recovered item restores label reservation on placement")
check(restored.displayName == second.displayName, "Packed trap name is restored before the world bind publication")
local replay = {id = "second-placement"}
N.restore(replay, {size = function() return 1 end, get = function() return item end})
check(replay.displayIdentity == nil, "Packed identity claim is consumed exactly once")
check(replay.recoveredHealth == nil, "A consumed condition claim cannot be reused")
second.name = "Packed custom fixture"
N.ensure(second, "NamingFixture", "Ballista")
N.pack(second, item)
local customRestored = {id = "custom-placement"}
N.restore(customRestored, {size = function() return 1 end, get = function() return item end})
N.ensure(customRestored, "NamingFixture", "Ballista")
check(customRestored.name == second.name and customRestored.displayName == second.displayName,
    "Exact recovered custom name survives placement")
local healthCopy = nativeRoundTrip(customRestored)
check(N.health(healthCopy, 100) == 37, "Exact restored health survives native serialization")
for i = 1, 20 do
    second.condition = 37
    N.pack(second, item)
    local moved = {id = "repeat-" .. i}
    N.restore(moved, {size = function() return 1 end, get = function() return item end})
    check(N.health(moved, 100) == 37, "Repeated packing neither repairs nor rounds condition")
end
local copy = nativeRoundTrip(restored)
N.ensure(copy, "NamingFixture", "Ballista")
check(copy.displayName == restored.displayName and copy.displayIdentity == identity, "Native serialized record preserves display identity")
testMode = "client"
local forbidden = {id = "client-owned-label"}
N.ensure(forbidden, "NamingFixture", "Fixture Button")
check(not forbidden.displayName, "Clients cannot allocate authoritative names")
testMode = mode
