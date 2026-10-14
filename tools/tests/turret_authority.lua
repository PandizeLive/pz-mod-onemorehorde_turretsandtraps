local A = require("OMHTT/TurretAuthority")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local Action = require("OMHTT/TurretPickupAction")
local oldMode, oldStore, oldFactory, oldRefresh = testMode, ModData.getOrCreate, instanceItem, W.refresh
local oldAdd, oldRemove = sendAddItemToContainer, sendRemoveItemFromContainer
local persisted, sent = {}, {}
ModData.getOrCreate = function(key)
    check(key == "OMHTTProductionTurretsV1", "Production state uses a separate global store")
    return persisted
end
testMode = "server"

local function storage()
    local c = {items = {}, room = true, kind = "OMHTTTurret"}
    function c:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
    function c:getType() return self.kind end
    function c:setType(value) self.kind = value end
    function c:setCapacity(value) self.capacity = value end
    function c:setAcceptItemFunction(value) self.accept = value end
    function c:setExplored() end
    function c:getContainingItem() return self.owner end
    function c:hasRoomFor() return self.room end
    function c:contains(item)
        for i = 1, #self.items do if self.items[i] == item then return true end end
        return false
    end
    function c:AddItem(item)
        if self.failAdd then return nil end
        self.items[#self.items + 1], item.container = item, self
        return item
    end
    function c:Remove(item)
        for i = #self.items, 1, -1 do if self.items[i] == item then table.remove(self.items, i) end end
        item.container = nil
    end
    return c
end
local sequence = 9000
local function item(kind)
    sequence = sequence + 1
    local i = {id = sequence, data = {}, weight = .2, condition = 100}
    function i:getID() return self.id end
    function i:getFullType() return kind end
    function i:getModData() return self.data end
    function i:getActualWeight() return self.weight end
    function i:setActualWeight(value) self.weight = value end
    function i:getCondition() return self.condition end
    function i:getConditionMax() return 100 end
    function i:setCondition(value) self.condition = value end
    function i:getContainer() return self.container end
    function i:getInventory() return self.inventory end
    function i:setCapacity(value) self.inventory.capacity = value end
    if kind == T.BASE then
        i.weight, i.inventory = 6, storage()
        i.inventory.owner = i
    end
    return i
end
instanceItem = item
local square = {getX = function() return 200 end, getY = function() return 200 end, getZ = function() return 0 end}
function square:transmitRemoveItemFromSquare(object)
    W.removed(object)
    object.removed = true
end
local function device(id)
    local o = {data = {}, health = 50, inventory = storage(), square = square}
    function o:hasModData() return true end
    function o:getModData() return self.data end
    function o:getSquare() return self.square end
    function o:getContainer() return self.inventory end
    function o:getObjectIndex() return self.removed and -1 or 0 end
    function o:getHealth() return self.health end
    function o:getMaxHealth() return 100 end
    function o:setHealth(value) self.health = value end
    function o:sync() self.healthSynced = true end
    function o:transmitModData() self.transmitted = A.copy(self.data.OMHTTTurret) end
    function o:invalidateRenderChunkLevel() end
    local state = {id = id, schema = 1, condition = 50, maxHealth = 100, revision = 1,
        shots = 7, nextShot = 12000, depthPolicy = "cube-depth-v2", powered = false}
    check(A.register(o, state), "Server registers exact new turret")
    state.shots = 999
    return o
end
local object = device("turret-authority-fixture")
check(T.state(object).shots == 7, "Initial authority state is independently copied")
object.data = {OMHTTTurret = {schema = 1, id = "forged", shots = 999, powered = true}}
check(T.state(object).shots == 7 and not T.isOn(T.state(object)), "Replacing object modData cannot replace server controls")
A.publish(object)
check(object.transmitted.shots == 7 and object.data.OMHTTTurret ~= T.state(object), "Published state is a detached snapshot")
object.data.OMHTTTurret.shots = 333
check(T.state(object).shots == 7, "Editing public snapshot cannot mutate authority")
local impostor = {hasModData = object.hasModData, getModData = object.getModData, getSquare = object.getSquare,
    getContainer = object.getContainer, data = {OMHTTTurret = {id = T.state(object).id}}, square = square, inventory = storage()}
check(not A.bind(impostor) and T.state(impostor) == nil, "Second live object cannot adopt an existing turret identity")
local fakePacked = item(T.BASE)
fakePacked.data.OMHTTTurret = {schema = 1, shots = 99999, powered = true}
check(A.packed(fakePacked) == nil, "Packed item metadata is not an authority source")
check(A.available(fakePacked), "Fresh server inventory item can be deployed")
A.deployed(fakePacked)
check(not A.available(fakePacked), "Repeated consumed-item callback is rejected")

local player = {inventory = storage(), dead = false, x = 200.5, y = 200.5}
function player:isDead() return self.dead end
function player:getInventory() return self.inventory end
function player:getSquare() return square end
function player:getX() return self.x end
function player:getY() return self.y end
function player:getZ() return 0 end
function player:setHaloNote() end
W.refresh = function(o) T.state(o).condition = o:getHealth() end
sendAddItemToContainer = function(container, added)
    check(container:contains(added), "Only a committed native inventory item is synchronized")
    sent[#sent + 1] = added
end
sendRemoveItemFromContainer = function() error("Pickup must not separately synchronize nested contents") end
local id = T.state(object).id
check(W.fire(player, object) == "Unavailable" and not W.setPower(player, object, true), "Service support does not accidentally enable unfinished multiplayer combat")
local repair = Action:new(player, object, "Repair", id)
check(repair.maxTime == 500 and repair.elapsed == 0, "Server reconstructs ten-second repair without client elapsed state")
check(repair:complete() and object.health == 100 and object.healthSynced, "Server completion repairs and synchronizes native health")
check(not repair:complete(), "Repair action completes at most once")
check(not Action:new(player, object, "Repair", id):complete(), "Concurrent stale repair cannot repeat a completed repair")
object.health = 50
check(not Action:new(player, object, "Repair"):complete(), "Missing serialized identity cannot be reconstructed into authorization")
check(not Action:new(player, object, "Delete", id):complete(), "Unknown service operation is rejected")
check(not Action:new(player, object, "Pickup", "old-id"):complete(), "Stale service identity is rejected")
local a, b = item("Base.Potato"), item("Base.Potato")
object.inventory:AddItem(a)
object.inventory:AddItem(b)
player.inventory.room = false
check(not W.pickup(player, object, id) and object.inventory:contains(a), "No-room pickup preserves exact world contents")
player.inventory.room, player.inventory.failAdd = true, true
check(not W.pickup(player, object, id) and T.state(object) ~= nil and object.inventory:contains(b), "Failed inventory insertion cannot retire or empty a turret")
player.inventory.failAdd = false
local pickup = Action:new(player, object, "Pickup", id)
check(pickup.maxTime == 250, "Native multiplayer pickup duration is five seconds")
testMode = "client"
check(not pickup:complete() and #player.inventory.items == 0, "Client completion cannot grant a packed turret")
testMode = "server"
check(pickup:complete() and object.removed and #sent == 1, "Server pickup retires world state and grants once")
local packed = sent[1]
check(packed.inventory:contains(a) and packed.inventory:contains(b) and #object.inventory.items == 0, "Pickup preserves exact contents without independent nested-item grants")
check(T.state(object) == nil and not W.pickup(player, object, id), "Concurrent pickup cannot duplicate contents")
check(A.packed(packed).shots == 7 and A.packed(packed).condition == 50, "Trusted packed record retains controls and base condition")
packed.data.OMHTTTurret.shots = 12345
check(A.packed(packed).shots == 7, "Client-replaced packed metadata cannot overwrite persisted state")
local saved = nativeRoundTrip(persisted)
check(saved.packed[tostring(packed.id)].shots == 7 and saved.world[id] == nil, "Native table persistence preserves packed state and retirement")
check(not A.bind(impostor), "Retired identity cannot be revived through public modData")
local unloaded = device("turret-reload-fixture")
local reloaded = {hasModData = unloaded.hasModData, getModData = unloaded.getModData,
    getSquare = unloaded.getSquare, getContainer = unloaded.getContainer, getObjectIndex = unloaded.getObjectIndex,
    data = {}, square = square, inventory = unloaded.inventory}
unloaded.removed = true
check(A.bind(reloaded) and T.state(reloaded).shots == 7, "Reloaded object recovers trusted persisted state even when its public marker was erased")
check(T.state(unloaded) == nil, "Rebinding releases the old native-object identity")
A.retire(reloaded)
local missing = device("turret-missing-native-fixture")
function square:getObjects() return {size = function() return 0 end} end
A.reconcile(square)
check(T.state(missing) == nil and persisted.world["turret-missing-native-fixture"] == nil, "Fully loaded empty tiles retire orphaned records without granting replacement items")
local replacement = device("turret-after-missing-fixture")
A.retire(replacement)

testMode, ModData.getOrCreate, instanceItem, W.refresh = oldMode, oldStore, oldFactory, oldRefresh
sendAddItemToContainer, sendRemoveItemFromContainer = oldAdd, oldRemove
