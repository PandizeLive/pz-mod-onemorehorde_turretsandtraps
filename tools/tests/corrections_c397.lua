local E = require("OMHTT/ControlExpansion")
local A = require("OMHTT/ControlAccess")
local W = require("OMHTT/ControlWorld")
local Action = require("OMHTT/ControlExpansionAction")
local nativeTransfer = ISTransferAction
ISTransferAction = ISTransferAction or {}
local old = {settings = SandboxVars.OMHTurretsTraps, state = A.state, near = A.near,
    write = A.write, world = W.state, publish = W.publish, mode = testMode,
    remove = ISTransferAction.removeItemOnCharacter}
testMode = "sp"
SandboxVars.OMHTurretsTraps = {}
local function container()
    local result = {items = {}, payload = 0}
    function result:getCapacityWeight()
        local weight = self.payload
        for _, item in pairs(self.items) do weight = weight + item:getUnequippedWeight() end
        return weight
    end
    function result:getItemWithID(id) return self.items[id] end
    function result:setCapacity(value) self.capacity = value end
    function result:hasRoomFor() return true end
    function result:contains(item) return self.items[item:getID()] == item end
    function result:isRemoveItemAllowed() return true end
    function result:isInCharacterInventory() return self.carried == true end
    function result:AddItem(item)
        if self.fail or self.failItem == item then return nil end
        self.items[item:getID()], item.container = item, self
        return item
    end
    function result:Remove(item) self.items[item:getID()], item.container = nil, nil end
    return result
end
local storage, inventory = container(), container()
inventory.carried = true
local state = {kind = "Controller", id = "c397-host"}
local object = {getContainer = function() return storage end}
local player = {getInventory = function() return inventory end}
A.state, W.state = function(value) return value == object and state end, function() return state end
A.near, A.write = function() return true end, function() return true end
W.publish, ISTransferAction.removeItemOnCharacter = function() end, function() end
local kits = {}
local names = {"Improvised", "Small", "Medium", "Large"}
for tier = 1, 4 do
    local kit = {id = tier, name = "Base.OMHTTModuleExpansion" .. names[tier]}
    function kit:getFullType() return self.name end
    function kit:getID() return self.id end
    function kit:getContainer() return self.container end
    function kit:isFavorite() return self.favorite == true end
    function kit:getUnequippedWeight() return .5 end
    kits[tier] = kit
    inventory:AddItem(kit)
    check(Action:new(player, object, kit):complete(), "Controller installs exact kit grade " .. tier)
    check(E.item(object) == kit and E.capacity(object) == 100 + tier * 100,
        "Controller capacity follows installed grade " .. tier)
    check(A.radius(object) == 10 + tier * 10 and storage.capacity == 100,
        "Native capacity stays bounded while management range follows grade " .. tier)
end
check(inventory:contains(kits[3]), "Replacing kit returns previous exact instance")
storage.payload = 150
check(not Action:new(player, object, nil):complete() and E.item(object) == kits[4], "Overfull kit removal blocked without discarding contents")
check(not E.canRemove(object, kits[4]), "Stockpile withdrawal also protects installed overfull kit")
SandboxVars.OMHTurretsTraps.ControllerCapacity = 20
E.refresh(object)
check(storage.payload == 150 and storage.capacity == 100, "Sandbox resizing retains stored contents")
SandboxVars.OMHTurretsTraps.ControllerKitCapacity = 0
E.refresh(object)
check(storage.payload == 150 and storage.capacity == 20, "Over-capacity inventory remains intact")
SandboxVars.OMHTurretsTraps = {}
storage.payload = 0
inventory.fail = true
check(not Action:new(player, object, kits[1]):complete() and E.item(object) == kits[4], "Failed old-kit return rolls back exact installed item")
inventory.fail = false
check(Action:new(player, object, nil):complete() and E.item(object) == nil and storage.capacity == 100,
    "Empty stockpile permits kit removal and restores base capacity")
check(Action:new(player, object, kits[4]):complete(), "Kit can be reinstalled")
storage.failItem = kits[1]
check(not Action:new(player, object, kits[1]):complete(), "Failed replacement insertion is rejected")
storage.failItem = nil
check(E.item(object) == kits[4], "Rejected replacement restores original installed kit")
check(inventory:contains(kits[1]), "Failed insertion returns replacement to inventory")
SandboxVars.OMHTurretsTraps = {TrapsControllerCapacity = 125, TrapsControllerKitCapacity = 50, TrapsControllerRange = 12, TrapsControllerKitRange = 5}
check(E.capacity(object) == 325 and A.radius(object) == 32, "Traps-only normalized options control expansion")
SandboxVars.OMHTurretsTraps.ControllerKitCapacity = 0 / 0
check(E.capacity(object) == 525, "Malformed expansion setting uses finite default")
testMode = "client"
check(not Action:new(player, object, nil):complete(), "Client cannot complete authoritative kit mutation")
A.state, A.near, A.write = old.state, old.near, old.write
W.state, W.publish = old.world, old.publish
ISTransferAction.removeItemOnCharacter = old.remove
ISTransferAction = nativeTransfer
SandboxVars.OMHTurretsTraps, testMode = old.settings, old.mode

local UI = require("OMHTT/SandboxUI")
local field = {text = "1.011111111111111", Type = "ISTextEntryBox"}
function field:setText(value) self.text = value end
function field:getText() return self.text end
UI.precision(field)
check(field.text == "1.01" and field:getText() == "1.011111111111111", "Readable multiplier preserves untouched raw tuning")
field.text = "1.25"
check(field:getText() == "1.25", "Deliberate multiplier edit replaces raw tuning")
field:setText("0.000125")
check(field.text == "0.000125" and field:getText() == "0.000125", "Small probabilities retain useful precision")
local O = require("OMHTT/ControlOptions")
check(O.get("LaserVisible") == false and O.get("LaserOpacity") == 25, "Laser presentation defaults off and faint")
