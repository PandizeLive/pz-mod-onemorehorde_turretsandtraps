local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
testMode = "sp"
SandboxVars.OMHTurretsTraps.Enabled = true
SandboxVars.OMHTurretsTraps.PotatoTurret = true
local config = T.cycleConfig()
check(config.magazine == 1 and config.reload == 2000 and config.cooldown == 2000, "Default potato cycle is magazine one with overlapping two-second timers")
local nextId = 1000
local function item(kind, weight)
    nextId = nextId + 1
    local result = {kind = kind, weight = weight or 1, charge = 0.37, condition = 100, id = nextId}
    function result:setWorldScale(value) self.scale = value end
    function result:getFullType() return self.kind end
    function result:getDisplayName() return self.kind end
    function result:getActualWeight() return self.weight end
    function result:getID() return self.id end
    function result:getCondition() return self.condition end
    function result:getCurrentUsesFloat() return self.charge end
    function result:setCurrentUsesFloat(value) self.charge = value end
    function result:getContainer() return self.container end
    result.data = {}
    function result:getModData() return self.data end
    return result
end
local function container()
    local result = {items = {}, kind = T.CONTAINER}
    function result:getItems()
        local items = self.items
        return {size = function() return #items end, get = function(self, index) return items[index + 1] end}
    end
    function result:getType() return self.kind end
    function result:getContainingItem() return nil end
    function result:contains(candidate)
        for i = 1, #self.items do if self.items[i] == candidate then return true end end
        return false
    end
    function result:AddItem(candidate)
        self.items[#self.items + 1] = candidate
        candidate.container = self
    end
    function result:Remove(candidate)
        for i = #self.items, 1, -1 do
            if self.items[i] == candidate then table.remove(self.items, i) end
        end
        candidate.container = nil
    end
    return result
end
local storage = container()
local head, battery, potato = item(T.HEAD, 4), item("Base.CarBattery1", 5), item("Base.Potato", 0.2)
check(not T.accept(storage, potato), "Ammo requires a head")
check(T.accept(storage, head), "First head allowed")
storage:AddItem(head)
check(not T.accept(storage, item(T.HEAD)), "Second head blocked")
check(T.accept(storage, potato), "Potatoes allowed with head")
storage:AddItem(potato)
check(T.canRemove(storage, head), "Head removal leaves reserve stored")
check(T.canRemove(storage, potato), "Ammo can be unloaded")
storage:AddItem(battery)
check(not T.accept(storage, item("Base.CarBattery2")), "Second battery blocked")
check(not T.accept(storage, item("Base.Plank")), "Unrelated material rejected")
for i = 1, 4 do
    local module = item("Base.OMHTTModuleRange", 0.3)
    check(T.accept(storage, module), "Repeated range module allowed while space remains")
    storage:AddItem(module)
end
check(not T.accept(storage, item("Base.OMHTTModuleVelocity")), "Module count bound enforced")
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = 1
check(not T.accept(storage, item("Base.Potato")), "Ammo count bound enforced")
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = nil
local contents = T.contents(storage)
check(contents.ammo == 1 and contents.modules == 4 and math.abs(contents.weight - 10.4) < 0.001, "Actual contents weight summed once")
local other = container()
T.moveContents(storage, other)
check(#storage.items == 0 and #other.items == 7 and other:contains(battery) and battery.charge == 0.37, "Transfers preserve exact items and charge")
testMode = "client"
check(not T.accept(other, item("Base.Potato")), "MP storage fails closed")
testMode = "sp"
local square = makeSquare(500, 500, 0)
function square:hasGridPower() return self.grid == true end
function square:getRoom() return self.room end
function square:haveElectricity() return self.generatorPower == true end
local object = {square = square}
function object:getSquare() return self.square end
contents = T.contents(other)
local power = W.power(object, contents)
check(power.kind == "battery" and math.abs(power.cost - 0.0000063) < 0.000001, "Four Range modules give 0.00063 percent with automatic rarity battery cost")
square.grid, square.room = true, {}
check(W.power(object, contents).kind == "grid", "External grid preferred over battery")
square.room = nil
check(W.power(object, contents).kind == "battery", "Outdoor tile does not invent mains power")
battery.charge = 0
check(W.power(object, contents) == nil, "Empty battery provides no power")
battery.charge = 0.000005
check(W.power(object, contents) == nil, "Partial shot charge cannot power full shot")
SandboxVars.OMHTurretsTraps.PotatoRequirePower = false
check(W.power(object, contents).kind == "disabled", "Power toggle bypasses consumption")
SandboxVars.OMHTurretsTraps.PotatoRequirePower = true
battery.charge = 0.37
local Combat = require("OMHTT/PrototypeCombat")
for x = 494, 506 do for y = 494, 506 do makeSquare(x, y, 0) end end
square = testSquares["500:500:0"]
object.square = square
function object:setSprite(value) self.sprite = value end
function object:invalidateRenderChunkLevel() end
local record = {schema = 1, id = "turret-unit", kind = "potato", ammo = 1, shots = 0, nextShot = 0, facing = 0}
local commits = 0
local options = {range = 6, interval = 1000, damage = 0.5, splash = 0.001, knockdown = 100, radius = 1.1, managed = true}
options.commit = function() commits = commits + 1 return true end
check(Combat.fire(record, object, testPlayer, options) == "NoTarget" and commits == 0, "No target spends no resources")
local zombie = makeZombie(testSquares["502:500:0"], 2)
check(Combat.fire(record, object, testPlayer, options) == "Fired" and commits == 1 and zombie.health == 1.5, "Managed hit commits once and applies configured damage")
record.ammo = 1
options.managed = false
check(Combat.fire(record, object, testPlayer, options) == "Cooling" and commits == 1, "Cooldown blocks resource commit")
options.managed = true
options.commit = function() return false end
check(Combat.fire(record, object, testPlayer, options) == "Unavailable" and zombie.health == 1.5, "Failed resource transaction applies no damage")
check(object.sprite == nil, "Managed aiming does not invalidate or replace the base sprite")
object.sprite = "omhtt_turret_01_0"
function object:hasModData() return true end
object.data = {OMHTTTurret = record}
function object:getModData() return self.data end
function object:getObjectIndex() return 0 end
function object:getHealth() return 100 end
function object:getContainer() return other end
function object:getSpriteName() return self.sprite end
function object:getSpriteConfig()
    return {isValid = function() return true end, getTileInfo = function() return {getSpriteName = function() return self.sprite end} end}
end
function square:hasGridPower() return false end
function square:haveElectricity() return self.generatorPower == true end
function square:getRoom() return nil end
local oldX, oldY, oldZ = testPlayer.x, testPlayer.y, testPlayer.z
testPlayer.x, testPlayer.y, testPlayer.z = 500.5, 500.5, 0
local oldSquare = testPlayer.getSquare
function testPlayer:getSquare() return square end
record.nextShot = 0
check(W.fire(testPlayer, object, zombie) == "Reloading", "First load starts two-second reload")
testMillis = testMillis + 1999
check(W.fire(testPlayer, object, zombie) == "Reloading" and other:contains(potato), "No early shot before two-second reload")
testMillis = testMillis + 1
local originalHybrid, originalContents, originalRefresh = T.hybrid, T.contents, W.refresh
local contentReads, refreshes = 0, 0
T.hybrid = function() return true end
T.contents = function(container) contentReads = contentReads + 1; return originalContents(container) end
W.refresh = function(device) refreshes = refreshes + 1; return originalRefresh(device) end
local ownedResult = W.fire(testPlayer, object, zombie)
T.hybrid, T.contents, W.refresh = originalHybrid, originalContents, originalRefresh
check(contentReads == 1 and refreshes == 0, "Hybrid shot scans inventory once without rebuilding unchanged turret configuration")
check(ownedResult == "Fired", "Inventory-backed shot succeeds: " .. ownedResult)
check(zombie.health == 1.5, "No direct damage before projectile arrival")
testMillis = testMillis + 100
require("OMHTT/PrototypeCombat").tickFlights()
check(math.abs(zombie.health - 1.15) < 0.000001, "Default shot deals exactly 35 points or 0.35 native HP")
check(not other:contains(potato) and math.abs(battery.charge - 0.3699937) < 0.000001, "Shot spends one exact potato and battery charge once")
check(W.fire(testPlayer, object, zombie) == "Empty" and math.abs(battery.charge - 0.3699937) < 0.000001, "Empty turret spends no additional charge")
local generator = {kind = "IsoGenerator", fuel = 1, active = true, connected = true, index = 0}
function generator:hasModData() return false end
function generator:getSquare() return square end
function generator:getObjectIndex() return self.index end
function generator:isActivated() return self.active end
function generator:isConnected() return self.connected end
function generator:getFuel() return self.fuel end
function generator:setFuel(value) self.fuel = value end
IsoGenerator = {isPoweringSquare = function() return true end}
W.loaded(generator)
square.generatorPower = true
check(W.power(object, T.contents(other)).kind == "generator", "Connected generator preferred over battery")
generator.active = false
check(W.power(object, T.contents(other)).kind == "battery", "Stopped generator falls back to battery")
generator.active = true
generator.fuel = 0.0001
check(W.power(object, T.contents(other)).kind == "battery", "Insufficient generator fuel falls back")
generator.fuel = 1
other:AddItem(item("Base.Potato", 0.2))
record.nextShot = 0
check(W.fire(testPlayer, object, zombie) == "Reloading", "Replenishing empty turret reloads")
testMillis = testMillis + 2000
check(W.fire(testPlayer, object, zombie) == "Fired" and math.abs(generator.fuel - 0.99986) < 0.000001, "Generator shot charges fuel exactly once")
check(math.abs(battery.charge - 0.3699937) < 0.000001, "Generator operation preserves battery charge")
testMillis = testMillis + 100
require("OMHTT/PrototypeCombat").tickFlights()
testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.getSquare = oldX, oldY, oldZ, oldSquare
local playerStorage = container()
playerStorage.room = false
function playerStorage:hasRoomFor(player, candidate) return self.room end
local pickupPlayer = {}
function pickupPlayer:isDead() return false end
function pickupPlayer:getSquare() return square end
function pickupPlayer:getX() return 500.5 end
function pickupPlayer:getY() return 500.5 end
function pickupPlayer:getZ() return 0 end
function pickupPlayer:getInventory() return playerStorage end
function pickupPlayer:setHaloNote() end
local oldInstanceItem = instanceItem
function instanceItem(kind)
    if kind ~= T.BASE then return oldInstanceItem(kind) end
    local base = item(kind, 6)
    base.data, base.inventory = {}, container()
    function base:getInventory() return self.inventory end
    function base:getModData() return self.data end
    function base:getConditionMax() return 100 end
    function base:setCondition(value) self.condition = value end
    function base:setActualWeight(value) self.weight = value end
    function base:setCapacity(value) self.inventory.capacity = value end
    function base.inventory:setType(value) self.kind = value end
    function base.inventory:setCapacity(value) self.capacity = value end
    function base.inventory:setAcceptItemFunction(value) self.accept = value end
    function base.inventory:setExplored() end
    return base
end
record.revision = 1
object.testHealth = 37
function object:getHealth() return self.testHealth end
function object:getMaxHealth() return 100 end
function object:setHealth(value) self.testHealth = value end
local savedHeadCondition, savedCharge = head.condition, battery.charge
check(not W.repair(pickupPlayer, object, "stale"), "Repair rejects wrong identity")
check(W.repair(pickupPlayer, object, record.id), "Damaged base can be repaired")
check(object:getHealth() == 100 and head.condition == savedHeadCondition and battery.charge == savedCharge, "Repair changes only base condition")
check(not W.repair(pickupPlayer, object, record.id), "Full condition repair rejected")
object.testHealth = 37
function square:transmitRemoveItemFromSquare(candidate) self.removedTurret = candidate end
record.maxHealth = 100
local beforeCount = #other.items
check(not W.pickup(pickupPlayer, object, record.id) and #other.items == beforeCount, "Full inventory pickup retains world contents")
playerStorage.room = true
check(not W.pickup(pickupPlayer, object, "stale-id") and #other.items == beforeCount, "Stale pickup rejected before mutation")
check(W.pickup(pickupPlayer, object, record.id) and #other.items == 0 and #playerStorage.items == 1, "Pickup transfers once and removes world object")
local carried = playerStorage.items[1]
check(carried.inventory:contains(battery) and math.abs(battery.charge - 0.3699937) < 0.000001, "Pickup preserves battery identity and charge")
check(carried.data.OMHTTTurret.condition == 37 and carried.data.OMHTTTurret.nextShot == record.nextShot, "Pickup preserves durability and cooldown")
check(not W.pickup(pickupPlayer, object, record.id) and #playerStorage.items == 1, "Repeated pickup cannot duplicate item")
local Action = require("OMHTT/TurretPickupAction")
local incomplete = {elapsed = 4.9, seconds = 5, done = false}
check(not Action.complete(incomplete), "Pickup cannot complete before five seconds")
instanceItem = oldInstanceItem

local dropped = {}
function square:AddWorldInventoryItem(candidate)
    dropped[#dropped + 1] = candidate
end
W.removed(object)
check(#dropped == 0, "Pickup retirement must not produce salvage or duplicate contents")
object.data.OMHTTTurret = {schema = 1, id = "destroy-unit"}
T.moveContents(carried.inventory, other)
local beforeDrop = #other.items
W.removed(object)
check(#other.items == 0 and #dropped == beforeDrop + 2 and T.state(object) == nil,
    "Removal fallback empties exact inventory and retires turret with two scrap")
local foundBattery = false
for i = 1, #dropped do
    if dropped[i] == battery then foundBattery = true end
end
check(foundBattery and math.abs(battery.charge - 0.3699937) < 0.000001, "Fallback preserves exact battery charge")
W.removed(object)
check(#dropped == beforeDrop + 2, "Repeated removal cannot duplicate salvage")
object.data.OMHTTTurret = {schema = 1, id = "empty-destroy-unit"}
W.removed(object)
check(#dropped == beforeDrop + 4, "Native already-dumped container still yields base salvage once")
object.materials = {[T.BASE] = 1, ["Base.Plank"] = 2}
function object:getBuildMaterials() return self.materials end
W.clearBuildRefund(object)
local materialCount = 0
for _ in pairs(object.materials) do materialCount = materialCount + 1 end
check(materialCount == 0, "Construction refunds cannot return a working base")
