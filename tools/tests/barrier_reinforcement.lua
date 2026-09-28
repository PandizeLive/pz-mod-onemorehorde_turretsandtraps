local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local Service = require("OMHTT/BarrierService")
local C = require("OMHTT/Construction")
testMode, testData, testSquares = "sp", nil, {}
testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.dead = 900.5, 900.5, 0, false
testBuildCheat, testPlayer.woodwork = false, 3
SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
S.initialize()
for x = 898, 904 do for y = 898, 904 do makeSquare(x, y, 0) end end
local function build(x, entity, offset)
    local record
    for part = 0, 1 do
        local square = getCell():getGridSquare(x, 900 + part, 0)
        local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. (offset + part), false)
        square:AddSpecialObject(object)
        record = P.adoptBuild(object, testPlayer, x, 900, 0, entity)
    end
    return record
end
local record = build(900, "OMHTTSpikeBarrier", 0)
local slot = P.slot(getCell():getGridSquare(900, 900, 0), record.id)
local object = P.parts(record)[1]
P.colliders(record)[1]:setHealth(70)
P.sync(slot)
testInventory.items, testInventory.room = {}, true
function testInventory:getSomeTypeRecurse(kind, maximum)
    local items = {}
    for i = 1, #self.items do if self.items[i].kind == kind and #items < maximum then items[#items + 1] = self.items[i] end end
    return {size = function() return #items end, get = function(self, i) return items[i + 1] end}
end
function testInventory:getFirstTagEvalRecurse(tag, predicate)
    for i = 1, #self.items do
        if self.items[i].kind == "Base.Hammer" and predicate(self.items[i]) then return self.items[i] end
    end
end
function testInventory:Remove(item)
    for i = #self.items, 1, -1 do if self.items[i] == item then table.remove(self.items, i) end end
end
function testPlayer:removeFromHands(item) end
function addXp(player, perk, amount) testUpgradeXP = testUpgradeXP + amount end
function addSound() end
function getItemStaticModel(kind) return kind end
ISTimedActionQueue.getTimedActionQueue = function() return {resetQueue = function() end} end
testUpgradeXP = 0
local function material(kind)
    local item = {kind = kind, condition = 100}
    function item:getCondition() return self.condition end
    function item:getContainer() return testInventory end
    function item:getStaticModel() return "Hammer" end
    testInventory:AddItem(item)
    return item
end
check(not Service.apply(testPlayer, object, record.id, "Reinforce"), "missing materials cannot upgrade")
local hammer = material("Base.Hammer")
for i = 1, 2 do material("Base.Plank") end
for i = 1, 8 do material("Base.Nails") end
testPlayer.woodwork = 2
check(not Service.reinforcementMaterials(testPlayer, record), "Carpentry 2 rejected without consuming")
testPlayer.woodwork, hammer.condition = 3, 0
check(not Service.reinforcementMaterials(testPlayer, record), "broken hammer rejected")
hammer.condition = 100
local cancelled = testServiceAction(testPlayer, object, record.id, "Reinforce")
cancelled:start(); cancelled:update(); cancelled:stop()
check(not cancelled:complete() and #testInventory.items == 11 and not record.tier and testUpgradeXP == 0,
    "cancelled reinforcement consumes nothing and gives no XP")
local action = testServiceAction(testPlayer, object, record.id, "Reinforce")
action:start()
check(not action:complete(), "reinforcement cannot finish early")
for i = 1, 101 do action:update() end
check(action:complete() and record.tier == "reinforced" and record.maxHealth == 200 and record.condition == 200,
    "upgrade repairs all missing health while doubling maximum")
check(#testInventory.items == 1 and testInventory.items[1] == hammer and testUpgradeXP == 30,
    "upgrade consumes exactly two planks and eight nails, retains hammer, grants 30 base XP")
check(not action:complete() and not Service.apply(testPlayer, object, record.id, "Reinforce") and testUpgradeXP == 30,
    "repeat/stale completion cannot duplicate upgrade XP")
check(F.barrierDamage(record) == 25 and F.barrierDamage() == 10, "reinforced damage is independent of basic damage")
for _, part in pairs(P.healthObjects(record)) do check(part:getHealth() == 200 and part:getMaxHealth() == 200, "all visual/edge parts share reinforced condition") end
P.colliders(record)[1]:setHealth(170)
P.sync(slot)
local owner, id, anchor = record.testOwner, record.id, record.slotKey
testData = nativeRoundTrip(testData); S.initialize()
record = testData.tiles[anchor].device
check(record.tier == "reinforced" and record.condition == 170 and record.testOwner == owner and record.id == id,
    "ledger serialization preserves upgrade tier, owner, identity and damage")
local options = SandboxVars.OMHTurretsTraps
options.ReinforcedBarrierHealthMultiplier, options.ReinforcedBarrierDamage = 3, 40
P.sync(testData.tiles[anchor])
check(record.maxHealth == 300 and record.condition == 255 and F.barrierDamage(record) == 40,
    "reinforced Sandbox changes preserve health percentage and retune damage")
options.ReinforcedBarrierHealthMultiplier, options.ReinforcedBarrierDamage = nil, nil
P.sync(testData.tiles[anchor])
check(Service.apply(testPlayer, object, id, "Repair") and record.condition == 200, "reinforced repair is free and preserves tier")
object:setHealth(150); P.sync(testData.tiles[anchor])
check(Service.apply(testPlayer, object, id, "Pickup"), "reinforced pickup succeeds")
local recovered = testInventory.items[#testInventory.items]
check(recovered.kind == "Base.OMHTTReinforcedBarrierItem" and recovered.condition == 100,
    "pickup returns one full-condition reinforced item")
local deployed = build(902, "OMHTTDeployReinforcedBarrier", 20)
check(deployed.tier == "reinforced" and deployed.condition == 200 and deployed.maxHealth == 200, "native reinforced deployment restores correct tier and health")
for i = 0, 7 do check(C.edgeNorth("omhtt_barrier_01_" .. (20 + i), false) == (math.floor(i / 2) % 2 == 1), "reinforced sprite orientations match all four native faces") end
testPlayer.x = 902.5
testPlayer.woodwork, testBuildCheat = 0, true
check(not Service.reinforcementMaterials(testPlayer, deployed), "build cheat cannot repeat reinforced upgrade")
testBuildCheat = false
