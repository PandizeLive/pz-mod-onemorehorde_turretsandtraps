local T = require("OMHTT/Turret")
local S = require("OMHTT/TurretStats")
local Feed = require("OMHTT/TurretFeed")
local Void = require("OMHTT/TurretVoid")
local State = require("OMHTT/TurretItemState")
local Clock = require("OMHTT/TurretClock")
local O = require("OMHTT/TurretOrdnance")
local V = require("OMHTT/TurretVolley")
local oldMode, oldSettings, oldClock = testMode, SandboxVars.OMHTurretsTraps, Clock.now
testMode = "sp"
SandboxVars.OMHTurretsTraps = {PotatoRequirePower = false}
local now, sequence = 10000, 40000
Clock.now = function() return now end
local function item(kind)
    sequence = sequence + 1
    local i = {kind = kind, data = {}, id = sequence}
    function i:getFullType() return self.kind end
    function i:getID() return self.id end
    function i:getModData() return self.data end
    function i:getCondition() return 100 end
    function i:getAge() return 100 end
    function i:isCooked() return false end
    function i:isBurnt() return false end
    function i:isFavorite() return false end
    function i:getActualWeight() return .2 end
    function i:getDisplayName() return self.kind end
    function i:getContainer() return self.container end
    return i
end
local function container()
    local c = {items = {}}
    function c:getItems() return {size = function() return #self.items end, get = function(_, n) return self.items[n + 1] end} end
    function c:getParent() return self.parent end
    function c:contains(i) for n = 1, #self.items do if self.items[n] == i then return true end end return false end
    function c:AddItem(i) self.items[#self.items + 1], i.container = i, self; return i end
    function c:Remove(i) for n = #self.items, 1, -1 do if self.items[n] == i then table.remove(self.items, n) end end i.container = nil end
    return c
end
local storage, source = container(), container()
local head, module = item(T.HEAD), item(Void.TYPE)
storage:AddItem(head); storage:AddItem(module)
for i = 1, 12 do
    local potato = item("Base.Potato")
    source:AddItem(potato)
    check(Void.deposit(module, potato, source), "Virtual feed setup converts exact food")
end
local contents = T.contents(storage)
local stats = S.resolve(contents)
local cycle, status = Feed.update(contents, stats, now, true)
check(status == "Reloading" and cycle.virtual and cycle.loaded == 0 and Void.count(module) == 12,
    "Virtual ammo begins a real three-round reload without pre-debit")
now = now + stats.reload
cycle, status = Feed.update(T.contents(storage), stats, now, true)
check(status == "Ready" and cycle.loaded == 3, "Virtual Potato magazine retains finite capacity")
local consumed, cost = Feed.consume(T.contents(storage), stats, cycle, now)
check(consumed and cost == 1 and Void.count(module) == 11 and cycle.loaded == 2, "One shot charges exact module once")
local saved = nativeRoundTrip(module.data)
module.data = saved
Feed.cancel(head)
check(cycle.loaded == 0 and not cycle.virtual and Void.count(module) == 11, "Removal cancels ready state without refund or duplicate credit")
storage:Remove(module)
cycle, status = Feed.update(T.contents(storage), stats, now + 10000, true)
check(status == "Empty" and cycle.loaded == 0, "Removed module cannot leave fireable virtual rounds")
storage:AddItem(module)
local physical = item("Base.Potato"); storage:AddItem(physical)
cycle, status = Feed.update(T.contents(storage), stats, now + 10000, true)
check(not cycle.virtual and cycle.payload == "Base.Potato", "Physical reserve is preferred at the next reload")
storage:Remove(head)
head = item("Base.OMHTTTurretLobber"); storage:AddItem(head)
storage:Remove(physical)
local record = {schema = 1, id = "c247", powered = true, ammoPreferred = "Base.PipeBomb"}
local square = makeSquare(1700, 1700, 0)
local object = {hasModData = function() return true end, getModData = function() return {OMHTTTurret = record} end,
    getSquare = function() return square end}
storage.parent = object
storage:AddItem(item("Base.OMHTTAmmoMakeshiftBomb"))
contents = T.contents(storage)
check(contents.payloadType == "Base.OMHTTAmmoMakeshiftBomb", "C267 load order skips unavailable legacy preference")
record.ammoFallback = true
contents = T.contents(storage)
check(contents.payloadType == "Base.OMHTTAmmoMakeshiftBomb", "Fallback selects available supported payload")
stats = S.resolve(contents)
check(stats.ammo == 20 and stats.magazine == 3 and stats.minimumRange == 6 and stats.range == 18,
    "Lobber has shared twenty-bomb cap, three-round feed and six-to-eighteen range")
contents.active.CapacityLarge = 1
check(S.resolve(contents).ammo == 20 and S.resolve(contents).modules == 16, "Expansion adds module slots without expanding bomb allowance")
local savedJobs, savedReserve, savedSerial = O.jobs, O.reserved, O.serial
O.jobs, O.reserved = {}, 0
for x = 1699, 1712 do for y = 1698, 1702 do makeSquare(x, y, 0) end end
local target = makeZombie(testSquares["1708:1700:0"], 10)
stats.fragment, stats.splitter, stats.synergy = 1, 2, true
local options = {stats = stats, damage = 1.5, critical = false, impactReady = false, managed = true,
    ammoDescriptor = {type = "Base.OMHTTAmmoMakeshiftBomb"}}
record.shots = 1
check(O.capacity(stats) == 18 and O.available(stats), "Three parents reserve fifteen terminal minis before commit")
V.reserve(options)
O.launch(record, square, target, nil, options)
V.done(options)
check(#O.jobs == 3 and O.reserved == 15, "Each accepted side grenade owns its future mini capacity")
local job = O.jobs[1]
check(job.damage == 1.5 and O.jobs[2].damage == .75 and job.radius == 4, "Side grenades halve damage while retaining payload radius")
local start = now
for i = 1, 200 do
    now = start + i * 25
    O.step(job)
    if job.landed then break end
end
check(job.landed and job.due == now + 1250, "Grenade lands before starting the 1.25-second fuse")
now = job.due - 1
check(O.step(job) == nil and #O.jobs == 3, "No damage or minis before landing fuse completes")
now = now + 1
O.step(job)
check(#O.jobs == 8 and O.reserved == 10 and job.children == 0, "Parent blast releases exactly five reserved terminal minis")
local mini = O.jobs[4]
check(mini.due == now + 250 and mini.fuse == 500 and mini.range == 2 and mini.children == 0,
    "Minis have delayed launch, short travel and landing fuse without recursion")
O.jobs, O.reserved, O.serial = savedJobs, savedReserve, savedSerial
local lure = require("OMHTT/TurretLure")
local oldSound, sounds = require("OMHTT/DefenseHorde").sound, 0
require("OMHTT/DefenseHorde").sound = function(_, _, _, _, radius)
    check(radius >= 5 and radius <= 20, "Lure attraction stays within owner-selected range")
    sounds = sounds + 1
    return true
end
contents.active.Lure = 1
record.lureRepeat, record.lureRange = true, 20
lure.update(object, contents, now)
lure.update(object, contents, now + 9999)
check(sounds == 1, "Lure loop waits the complete ten seconds")
lure.update(object, contents, now + 20000)
check(sounds == 2, "Lag counts elapsed time but allows only one repeat pulse per update")
record.powered = false
lure.update(object, contents, now + 40000)
check(not record.lureRepeat and sounds == 2, "Turning off stops repeating attraction")
require("OMHTT/DefenseHorde").sound = oldSound
-- Pellet damage snapshots and secondary-proc admission are independent of visuals.
local Scrap = require("OMHTT/TurretScrapshot")
local Hit = require("OMHTT/Damage")
local Proc = require("OMHTT/TurretProc")
local Conditional = require("OMHTT/TurretConditionalHit")
local originalHit, originalProc, originalImpact = Hit.resolve, Proc.hit, Conditional.impact
local hits, procs = {}, 0
Hit.resolve = function(victim, amount, _, _, callback)
    hits[#hits + 1] = amount
    victim:setHealth(math.max(0, victim:getHealth() - amount))
    callback(amount)
    return true
end
Proc.hit = function() procs = procs + 1 end
Conditional.impact = function() end
local victim = makeZombie(square, 1)
victim:getModData().OMHTTInitialHealth = 1
local shot = {scrapId = "c247:pellet", scrapEligibility = {}, scrapEffects = {}, scrapInjury = {}}
local pelletStats = {initialBlow = .25, initialThreshold = .9, execute = 0, synergy = false}
local ray = {id = "c247", shot = 2, damage = .15, z = 0, group = {options = shot, primary = true, stats = pelletStats}}
Scrap.hit(ray, victim)
Scrap.hit(ray, victim)
check(math.abs(hits[1] - .1875) < .00001 and hits[2] == hits[1] and procs == 1,
    "Primary pellets share pre-shot Initial Blow and trigger effects once per victim")
ray.group.penetrated = true
Scrap.hit(ray, victim)
check(hits[3] == .15 and procs == 1, "Pierced pellet cannot propagate conditional modules without Synergy")
ray.group.penetrated, pelletStats.execute = false, .1
victim:setHealth(.2)
Scrap.hit(ray, victim)
check(hits[4] == .2 and victim:getHealth() == 0, "Scrapshot Execute evaluates health after allocated pellet damage")
Hit.resolve, Proc.hit, Conditional.impact = originalHit, originalProc, originalImpact
-- MP keeps descriptor/debt data private and pages type counts with exact IDs.
local View = require("OMHTT/TurretVoidView")
local previousSend = sendClientCommand
local messages, delivered = {}, 0
sendClientCommand = function(_, namespace, command, message) messages[#messages + 1] = message end
local localOne = {getPlayerNum = function() return 0 end}
local localTwo = {getPlayerNum = function() return 1 end}
testMode = "client"
View.read(localOne, object, module, 0, function() delivered = delivered + 1 end)
View.read(localTwo, object, module, 20, function() delivered = delivered + 1 end)
for i = 1, 2 do
    View.receive("OMHTT_VoidView", "Page", {serial = messages[i].serial, item = module:getID(), rows = {}, total = 0, offset = 0})
end
check(delivered == 2, "Split-screen Void inspections do not overwrite another player's pending page")
View.receive("OMHTT_VoidView", "Page", {serial = messages[1].serial, item = module:getID(), rows = {}})
check(delivered == 2, "Void pages cannot replay a completed callback")
testMode, sendClientCommand = "sp", previousSend
local summary = Void.summary(module, Void.data(module))
check(summary.summary and #summary.groups == 0 and not summary.debt["Base.Potato"] and summary.total == 11,
    "Replicated Void summary contains counts, never quality groups or Conservation accounting")
local Order = require("OMHTT/TurretLoadOrder")
local Reload = require("OMHTT/TurretReload")
local Ammo = require("OMHTT/TurretAmmo")
local ammoStorage = container()
record.powered = true
ammoStorage.parent = object
local scrapHead = ammoStorage:AddItem(item("Base.OMHTTTurretScrapshot"))
local scrapVoid = ammoStorage:AddItem(item(Void.TYPE))
local gold = source:AddItem(item("Base.GoldScrap"))
check(Void.deposit(scrapVoid, gold, source), "Rare native scrap enters exact Void storage")
for i = 1, 12 do ammoStorage:AddItem(item("Base.ScrapMetal")) end
record.ammoOrders = {[scrapHead:getFullType()] = "Base.ScrapMetal|Base.GoldScrap"}
local selected = T.contents(ammoStorage)
local config = S.resolve(selected)
local oldSource = #ammoStorage.items
local loaded = Feed.update(selected, config, now, true)
now = now + config.reload
Feed.update(T.contents(ammoStorage), config, now, true)
check(loaded.payload == "Base.ScrapMetal" and loaded.loaded == 10, "Ordered custom magazine loads one physical type")
check(not Reload.allowed(T.contents(ammoStorage), config), "Full unchanged magazine has no redundant Reload")
loaded.debts = {["Base.ScrapMetal"] = .5}
loaded.impactReady, loaded.nextShot = false, now + config.cooldown
local retainedDeadline = loaded.nextShot
record.ammoOrders[scrapHead:getFullType()] = "Base.GoldScrap|Base.ScrapMetal"
check(T.contents(ammoStorage).payloadType == "Base.ScrapMetal", "Changing order cannot rewrite an already loaded magazine")
check(Reload.start(T.contents(ammoStorage), config, now), "Manual reload accepts changed next type")
check(#ammoStorage.items == oldSource and Void.count(scrapVoid) == 1 and loaded.loaded == 0,
    "Reload creates no physical refund and spends no virtual ammunition")
now = now + config.reload
Feed.update(T.contents(ammoStorage), config, now, true)
check(loaded.loaded == 1 and loaded.virtual and loaded.payload == "Base.GoldScrap"
    and loaded.debts["Base.ScrapMetal"] == .5 and loaded.nextShot == retainedDeadline and not loaded.impactReady,
    "Reload preserves Conservation debt, cooldown and consumed Impact entitlement")
check(Feed.descriptor(T.contents(ammoStorage), loaded).multiplier == 1.15, "Void gold retains the physical material bonus")
local request = {head = scrapHead:getID(), previous = Order.saved(record, scrapHead), order = "Base.SteelScrap|Base.ScrapMetal"}
check(Order.valid(request, T.contents(ammoStorage), record), "Exact-head current load-order edit accepted")
request.previous = "stale"
check(not Order.valid(request, T.contents(ammoStorage), record), "Concurrent stale load-order edit rejected")
request.previous, request.order = Order.saved(record, scrapHead), "Base.ScrapMetal|Base.ScrapMetal"
check(not Order.valid(request, T.contents(ammoStorage), record), "Duplicate load-order types rejected")
request.order = "Base.PipeBomb"
check(not Order.valid(request, T.contents(ammoStorage), record), "Incompatible load-order type rejected")
local copied = require("OMHTT/TurretAuthority").copy(record)
check(copied.ammoOrders ~= record.ammoOrders and Order.saved(nativeRoundTrip(copied), scrapHead) == Order.saved(record, scrapHead),
    "Replicated and persisted orders are independent exact copies")
for kind, bonus in pairs(Ammo.scraps) do
    check(Ammo.accepts(scrapHead, kind) and Ammo.describe(item(kind)).multiplier == 1 + bonus, "Each native scrap has its approved damage bonus")
end
for _, pair in pairs({{"", 20}, {"CapacityImprovised", 30}, {"CapacitySmall", 40}, {"Capacity", 60}, {"CapacityLarge", 80}}) do
    local active = {}
    if pair[1] ~= "" then active[pair[1]] = 1 end
    check(S.resolve({head = scrapHead, active = active}).ammo == pair[2], "Scrap reserve follows the safe expansion progression")
end
for i = 1, 25 do
    local kind = "Test.C267Scrap" .. string.format("%02d", i)
    Ammo.overrides[kind] = "scrap"
    local candidate = source:AddItem(item(kind))
    check(Void.deposit(scrapVoid, candidate, source), "Large type-list fixture converts exact ammo")
end
record.ammoOrders[scrapHead:getFullType()] = "Test.C267Scrap25|Base.GoldScrap|Base.ScrapMetal"
local compactRows = Order.rows(T.contents(ammoStorage), record, nil, true)
check(#compactRows <= 23 and compactRows[1].type == "Test.C267Scrap25" and compactRows[1].virtual == 1,
    "Routine Manage summary stays bounded while retaining a preferred type beyond its twenty-row preview")
check(Order.select(T.contents(ammoStorage), record) == "Test.C267Scrap25", "Feeder selects cached exact priority beyond preview")
local originalVoid = State.get(scrapVoid, "void")
for i = 1, 2 do Void.deposit(scrapVoid, source:AddItem(item("Base.GoldScrap")), source) end
record.ammoOrders[scrapHead:getFullType()] = "Base.GoldScrap|Base.ScrapMetal"
State.set(scrapVoid, "void", Void.summary(scrapVoid, originalVoid))
testMode = "client"
check(Reload.allowed(T.contents(ammoStorage), config), "Client enables a useful virtual top-up from replicated counts without private descriptors")
check(not Reload.start(T.contents(ammoStorage), config, now), "Client cannot mutate reload accounting")
testMode = "sp"
State.set(scrapVoid, "void", originalVoid)
for i = 1, 25 do Ammo.overrides["Test.C267Scrap" .. string.format("%02d", i)] = nil end
testMode, SandboxVars.OMHTurretsTraps, Clock.now = oldMode, oldSettings, oldClock
testC247 = "finiteVirtualMagazine=pass exactModuleDebt=pass mixedPayload=pass boundedGrenadeLineage=pass lureNoCatchup=pass"
