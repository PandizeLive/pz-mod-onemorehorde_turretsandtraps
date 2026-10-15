local A = require("OMHTT/TurretAuthority")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local Action = require("OMHTT/TurretPickupAction")
local oldMode, oldStore, oldFactory, oldRefresh = testMode, ModData.getOrCreate, instanceItem, W.refresh
local oldAdd, oldRemove = sendAddItemToContainer, sendRemoveItemFromContainer
local persisted, sent = {}, {}
local itemStore = {}
ModData.getOrCreate = function(key)
    if key == "OMHTTItemAuthorityV1" then return itemStore end
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
check(W.fire(player, object) == "Off", "Server firing obeys private power state despite forged public metadata")
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

local Transfer = require("OMHTT/TurretTransferAction")
local Control = require("OMHTT/TurretControlAction")
local transferObject = device("turret-transfer-fixture")
function transferObject:transmitUpdatedSpriteToClients() self.spriteSent = true end
function player:hasTrait() return false end
function player:isWearingAwkwardGloves() return false end
function player:removeFromHands() end
local oldTraits = CharacterTrait
local oldNativeTransfer = ISTransferAction
ISTransferAction = {removeItemOnCharacter = function(_, operator, candidate)
    operator:removeFromHands(candidate)
    candidate.detached = true
end}
CharacterTrait = {DEXTROUS = "dex", ALL_THUMBS = "thumbs"}
local transferId = T.state(transferObject).id
local inv, target = player.inventory, transferObject.inventory
inv.kind = "inventory"
for _, container in pairs({inv, target}) do
    function container:getParent() return self == target and transferObject or nil end
    function container:isInCharacterInventory(p) return self == p.inventory end
    function container:isRemoveItemAllowed() return true end
    function container:isItemAllowed() return true end
    function container:getItemById(id)
        for i = 1, #self.items do if self.items[i]:getID() == id then return self.items[i] end end
    end
end
local function component(kind)
    local value = item(kind)
    function value:getDisplayName() return kind end
    function value:getUnequippedWeight() return self.weight end
    function value:isFavorite() return self.favorite == true end
    return value
end
local head = component(T.HEAD)
inv:AddItem(head)
local adds, removes = 0, 0
sendRemoveItemFromContainer = function(source, candidate)
    check(not source:contains(candidate), "Transfer removal sync follows the committed move")
    removes = removes + 1
end
sendAddItemToContainer = function(destination, candidate)
    check(destination:contains(candidate), "Transfer addition sync follows the committed move")
    adds = adds + 1
end
local transfer = Transfer:new(player, transferObject, head, true, transferId)
testMode = "client"
check(not transfer:complete() and inv:contains(head), "Client transfer completion cannot move items")
testMode = "server"
check(not Transfer:new(player, transferObject, head, true, "stale"):complete(), "Wrong turret identity rejects transfer")
check(not Transfer:new(player, transferObject, head, true):complete(), "Missing serialized identity rejects transfer")
target.room = false
check(not transfer:complete() and inv:contains(head), "No-room transfer preserves item")
target.room, target.failAdd = true, true
check(not transfer:complete() and inv:contains(head) and removes == 0, "Failed native insertion rolls back before synchronization")
target.failAdd = false
transfer = Transfer:new(player, transferObject, head, true, transferId)
check(transfer:complete() and target:contains(head) and adds == 1 and removes == 1, "Server moves exact head and synchronizes both endpoints once")
check(head.detached, "Deposited equipment uses native attachment/hand/worn-item cleanup")
check(not transfer:complete(), "Repeated completion cannot duplicate a transfer")
local secondHead = component(T.HEAD)
inv:AddItem(secondHead)
check(not Transfer:new(player, transferObject, secondHead, true, transferId):complete(), "Server rejects a second head")
local potato = component("Base.Potato")
inv:AddItem(potato)
potato.favorite = true
check(not Transfer:new(player, transferObject, potato, true, transferId):complete(), "Favorite item cannot be deposited")
potato.favorite = false
check(not Transfer:new(player, transferObject, potato, true, transferId, {potato.id, potato.id}):complete(), "Repeated batch identities are rejected")
check(not Transfer:new(player, transferObject, potato, true, transferId, {potato.id}):complete(), "Heavy ammunition cannot use light-item batching")
check(Transfer:new(player, transferObject, potato, true, transferId):complete(), "Exact ammo can enter the mounted matching head")
check(not Transfer:new(player, transferObject, potato, true, transferId):complete(), "Concurrent stale incoming transfer is rejected")
check(not Transfer:new(player, transferObject, potato, false, transferId, nil, false):complete(), "Unsupported destination is rejected instead of silently changed")
check(Transfer:new(player, transferObject, potato, false, transferId):complete() and inv:contains(potato), "Outgoing transfer restores the exact item")
local state = T.state(transferObject)
check(not Control:new(player, transferObject, transferId, "Power", "true"):complete(), "Power control rejects a non-boolean")
check(not Control:new(player, transferObject, transferId, "Range", 0/0):complete(), "Nonfinite ranges are rejected")
check(not Control:new(player, transferObject, transferId, "Range", -1):complete(), "Negative ranges are rejected")
check(not Control:new(player, transferObject, transferId, "Range", 9999):complete(), "Out-of-range values are rejected")
local range = Control:new(player, transferObject, transferId, "Range", 2)
check(range:complete() and state.engagementRange == 2 and not range:complete(), "Range is set by the server exactly once")
check(Control:new(player, transferObject, transferId, "Range", 0):complete() and state.engagementRange == nil, "Max range clears the custom limit")
check(not Control:new(player, transferObject, transferId, "Priority", "Weakest"):complete(), "Priority requires a working Filter module")
target:AddItem(component(T.TYPES.Filter))
check(Control:new(player, transferObject, transferId, "Priority", "Weakest"):complete() and state.priority == "Weakest", "Server validates and stores a known priority")
check(not Control:new(player, transferObject, transferId, "Priority", "Unknown"):complete(), "Unknown priorities are rejected")
local oldCapacity = SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = 500
target:AddItem(component(T.TYPES.CapacityLarge))
local rounds, started, maxBatch = {}, realMillis(), 0
for i = 1, 600 do
    local round = component("Base.Potato")
    round.weight = .05
    inv:AddItem(round)
    rounds[i] = round
end
local oversized = {}
for i = 1, 21 do oversized[i] = rounds[i]:getID() end
check(not Transfer:new(player, transferObject, rounds[1], true, transferId, oversized):complete(), "More than twenty batch entries are rejected")
for offset = 1, 600, 20 do
    local ids = {}
    for i = offset, offset + 19 do ids[#ids + 1] = rounds[i]:getID() end
    local begin = realMillis()
    check(Transfer:new(player, transferObject, rounds[offset], true, transferId, ids):complete(), "Bounded server batch completes")
    maxBatch = math.max(maxBatch, realMillis() - begin)
end
check(T.contents(target).reserve == 600, "All six hundred exact rounds arrive through thirty server actions")
testMPTransfer = "items=600 batches=30 maxBatchMs=" .. maxBatch .. " elapsedMs=" .. (realMillis() - started)
local oldBonus = SandboxVars.OMHTurretsTraps.CapacityLargeAmmoBonus
SandboxVars.OMHTurretsTraps.CapacityLargeAmmoBonus = 105
local limited, limitedIds = {}, {}
for i = 1, 20 do
    local round = component("Base.Potato")
    round.weight = .05
    inv:AddItem(round)
    limited[i], limitedIds[i] = round, round:getID()
end
check(Transfer:new(player, transferObject, limited[1], true, transferId, limitedIds):complete(), "Batch moves the portion that fits")
check(T.contents(target).reserve == 605 and inv:contains(limited[6]) and inv:contains(limited[20]), "Incremental batch accounting stops exactly at the remaining capacity")
SandboxVars.OMHTurretsTraps.CapacityLargeAmmoBonus = oldBonus
SandboxVars.OMHTurretsTraps.PotatoAmmoCapacity = oldCapacity
local oldQueue, oldBegin = ISTimedActionQueue, ISBaseTimedAction.begin
local queue = {queue = {}}
function queue:indexOf(action)
    for i = 1, #self.queue do if self.queue[i] == action then return i end end
    return -1
end
ISTimedActionQueue = {
    getTimedActionQueue = function() return queue end,
    add = function(action) queue.queue[#queue.queue + 1] = action end,
}
ISBaseTimedAction.begin = function(action) action.begun = true end
testMode = "client"
local selected = {}
for i = 1, 41 do
    selected[i] = component("Base.Potato")
    selected[i].weight = .05
    inv:AddItem(selected[i])
end
local Network = require("OMHTT/TurretNetworkTransfers")
check(Network.queue(player, transferObject, selected, true, "ammo") == 41, "Manage queues exact multiplayer ammo candidates")
local batches = 0
while #queue.queue > 0 do
    local action = queue.queue[1]
    action:begin()
    check(action.begun and #action.ids <= 20, "Client batch merges before native action serialization and stays bounded")
    batches = batches + 1
    table.remove(queue.queue, 1)
end
check(batches == 3 and inv:contains(selected[41]), "Forty-one queued rounds form three actions without client inventory mutation")
local nativeDrag = ISInventoryTransferAction:new(player, selected[1], inv, target)
check(nativeDrag.Type == Transfer.Type and nativeDrag.id == transferId, "Ordinary native inventory drag routes to the same validated action")
local declined = ISInventoryTransferAction:new(player, limited[1], target, {getType = function() return "floor" end, getContainingItem = function() return nil end})
check(declined.destinationBag == false and not declined:isValid(), "Unsupported native drag cannot silently route to the player's main inventory")
ISTimedActionQueue, ISBaseTimedAction.begin = oldQueue, oldBegin
testMode = "server"
local ItemState = require("OMHTT/TurretItemState")
local oldPlayers, oldMeta, oldWeapon = getOnlinePlayers, syncItemModData, syncHandWeaponFields
local mounted = item("Base.Pistol")
mounted.kind = "HandWeapon"
mounted.container = target
local first = {getX = function() return 200 end, getY = function() return 200 end}
local second = {getX = function() return 201 end, getY = function() return 200 end}
local distant = {getX = function() return 999 end, getY = function() return 999 end}
local observers, fields, metadata = {first, second, distant}, {}, 0
getOnlinePlayers = function()
    return {size = function() return #observers end, get = function(_, i) return observers[i + 1] end}
end
syncHandWeaponFields = function(recipient, actual)
    check(actual == mounted and recipient ~= distant, "Native mounted-gun fields go only to nearby actual observers")
    fields[recipient] = (fields[recipient] or 0) + 1
end
syncItemModData = function(recipient, actual)
    check(recipient ~= nil and actual == mounted, "Native metadata sync always has a real recipient")
    metadata = metadata + 1
end
mounted.data.OMHTTGunCycle = {schema = 1, loaded = 99999, nextShot = -99999}
local private = ItemState.get(mounted, "gun", {schema = 1, nextShot = 1234, loaded = 3})
check(private.loaded == 3 and private.nextShot == 1234, "Forged public cycle is never adopted by server authority")
ItemState.set(mounted, "feed", 2)
ItemState.publish(mounted, first)
check(fields[first] == 1 and fields[second] == 1 and metadata == 1, "One transition updates two observers without duplicate metadata broadcast")
check(mounted.data.OMHTTGunCycle ~= private and mounted.data.OMHTTFeedRounds == 2, "Presentation is a detached copy of private state")
mounted.data.OMHTTGunCycle.loaded, mounted.data.OMHTTFeedRounds = 99999, 99999
check(ItemState.get(mounted, "gun").loaded == 3 and ItemState.get(mounted, "feed") == 2, "Later public replacement cannot create loaded ammo")
testMode = "client"
check(not ItemState.set(mounted, "feed", 500), "Client feed writes are denied")
local gunView = ItemState.get(mounted, "gun")
check(gunView == mounted.data.OMHTTGunCycle, "Client reads only the replicated presentation")
testMode = "server"
observers = {}
ItemState.publish(mounted)
check(metadata == 1, "No connected observers means no invalid nil-player packet")
getOnlinePlayers, syncItemModData, syncHandWeaponFields = oldPlayers, oldMeta, oldWeapon
local V = require("OMHTT/TurretVoid")
local VoidAction = require("OMHTT/TurretVoidAction")
local void = component(V.TYPE)
void.data.OMHTTVoid = {schema = 1, revision = 1, groups = {{type = "Base.Bullets9mm", count = 999999}}, debt = {}}
target:AddItem(void)
local virtualRounds, virtualIds = {}, {}
for i = 1, 20 do
    local round = component("Base.Bullets9mm")
    target:AddItem(round)
    virtualRounds[i], virtualIds[i] = round, round:getID()
end
check(V.count(void) == 0, "Forged public Void counts are never accepted as server inventory")
getOnlinePlayers = function() return {size = function() return 0 end} end
syncItemModData = function(recipient, actual) check(recipient == player and actual == void, "Committed Void snapshot is synchronized to operator") end
local conversion = VoidAction:new(player, transferObject, transferId, void, virtualIds)
check(not VoidAction:new(player, transferObject, "wrong", void, virtualIds):complete(), "Wrong turret cannot convert ammunition")
check(not VoidAction:new(player, transferObject, transferId, void, {virtualIds[1], virtualIds[1]}):complete(), "Duplicate conversion IDs are rejected before removal")
virtualRounds[1].favorite = true
check(not conversion:complete() and target:contains(virtualRounds[1]), "Favorite ammunition remains physical")
virtualRounds[1].favorite = false
local potatoHead = component(require("OMHTT/Turret").HEAD)
target:AddItem(potatoHead)
ItemState.set(potatoHead, "cycle", {schema = 1, loaded = 1})
local potatoEnabled = SandboxVars.OMHTurretsTraps.PotatoTurret
SandboxVars.OMHTurretsTraps.PotatoTurret = false
local disabledCycle, disabledStatus = T.cycle({head = potatoHead, ammo = 100}, 1000, {})
check(disabledCycle.loaded == 1 and disabledStatus == "Disabled", "Disabled head retains an inert state for server publication")
SandboxVars.OMHTurretsTraps.PotatoTurret = potatoEnabled
check(conversion:complete() and V.count(void) == 20 and ItemState.get(potatoHead, "cycle").loaded == 0,
    "Explicit conversion cancels physical ready reservations before crediting virtual ammo")
target:Remove(potatoHead)
check(not conversion:complete() and V.count(void) == 20, "Twenty exact rounds cannot be converted twice")
local count, group = V.count(void, nil, "Base.Bullets9mm")
check(count == 20 and not target:contains(virtualRounds[1]), "Physical removal and private virtual credit agree")
void.data.OMHTTVoid.total = 999999
check(void.data.OMHTTVoid.summary and #void.data.OMHTTVoid.groups == 0, "Native item metadata excludes the private quality ledger")
check(V.count(void) == 20, "Replicated Void snapshot does not alias private ammunition")
local used, cost = V.consume(void, group, 1, 2)
check(used and cost == 0 and V.count(void) == 20, "Server Conservation retains the first fractional use")
used, cost = V.consume(void, group, 1, 2)
check(used and cost == 1 and V.count(void) == 19, "Server Conservation charges the second use exactly once")
local saved = nativeRoundTrip(itemStore)
check(saved.items[tostring(void:getID())].void.groups[1].count == 19, "Private Void count survives native table serialization")
getOnlinePlayers, syncItemModData = oldPlayers, oldMeta
A.retire(transferObject)
CharacterTrait = oldTraits
ISTransferAction = oldNativeTransfer

testMode, ModData.getOrCreate, instanceItem, W.refresh = oldMode, oldStore, oldFactory, oldRefresh
sendAddItemToContainer, sendRemoveItemFromContainer = oldAdd, oldRemove
