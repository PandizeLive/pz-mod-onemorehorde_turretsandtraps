local C = require("OMHTT/ControlWorld")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local Transfer = require("OMHTT/ControlTransferAction")
local T = require("OMHTT/Turret")

return function(player)
    assert(isServer() and not isClient(), "Controls probe requires actual server mode")
    if EXPECT_READ then
        local found = false
        for _, saved in pairs(C.records().records) do
            if saved.name == "Gate plate" and saved.owner == "control-owner" and saved.trigger == "Zombies" then
                assert(#saved.links == 1, "Saved private link was lost")
                found = true
            end
        end
        assert(found, "Fresh process lost private device/access configuration")
    end
    player:setUsername("control-owner")
    local recipes = {
        {"Controller", {SmallSheetMetal = 2, ElectronicsScrap = 4, ElectricWire = 2, Screws = 4}},
        {"Plate", {Plank = 1, ElectronicsScrap = 2, ElectricWire = 1, Nails = 4}},
        {"Button", {ElectronicsScrap = 1, ElectricWire = 1, Screws = 2}},
    }
    for n = 1, #recipes do
        local case = recipes[n]
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraft" .. case[1])
        assert(recipe, "Control craft missing")
        local inputs, resources, kept = ArrayList.new(), ArrayList.new(), {}
        for _, name in pairs({"Screwdriver", "Pliers", "Hammer"}) do
            local item = instanceItem("Base." .. name)
            inputs:add(item)
            kept[#kept + 1] = item
        end
        for name, count in pairs(case[2]) do
            for i = 1, count do inputs:add(instanceItem("Base." .. name)) end
        end
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        assert(data:canConsumeInputs(resources, inputs, true, true), "Control craft ingredients rejected")
        for i = 0, inputs:size() - 1 do
            local item = inputs:get(i)
            player:getInventory():AddItem(item)
            for j = 0, recipe:getInputs():size() - 1 do data:offerInputItem(recipe:getInputs():get(j), item) end
        end
        assert(data:consumeInputs(resources) and data:createOutputs(resources, player), "Control craft transaction failed")
        data:processDestroyAndUsedItems(player)
        assert(data:getFirstCreatedItem():getFullType() == require("OMHTT/ControlDefinitions").types[case[1]], "Control craft output mismatch")
        for i = 1, #kept do assert(player:getInventory():contains(kept[i]), "Control craft consumed tool") end
    end
    local square = IsoGridSquare.new(getCell(), nil, 28, 28, 0)
    player:setCurrent(square)
    player:setX(28.5)
    player:setY(28.5)
    player:setZ(0)
    local function create(kind, sprite)
        local item = player:getInventory():AddItem(require("OMHTT/ControlDefinitions").types[kind])
        assert(item, "Missing control item " .. kind)
        local consumed = ArrayList.new()
        consumed:add(item)
        local object = IsoThumpable.new(getCell(), square, sprite, false)
        square:getObjects():add(object)
        square:getSpecialObjects():add(object)
        local info = SpriteConfigManager.GetObjectInfo("OMHTTDeploy" .. kind)
        assert(info and info:getScript(), "Missing control entity " .. kind)
        GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
        C.create({thumpable = object, character = player, craftRecipeData = {getAllConsumedItems = function() return consumed end}})
        assert(C.state(object).owner == "control-owner" and not player:getInventory():contains(item), "Exact placement ownership failed")
        return object
    end
    local controller = create("Controller", "omhtt_turret_01_21")
    for _, offset in pairs({{0,-1},{1,0},{0,1},{-1,0},{1,1},{-1,-1}}) do
        local adjacent = IsoGridSquare.new(getCell(), nil, 28 + offset[1], 28 + offset[2], 0)
        player:setCurrent(adjacent)
        player:setX(28.5 + offset[1])
        player:setY(28.5 + offset[2])
        assert(A.near(player, controller), "Controller rejects adjacent native access: " .. offset[1] .. "," .. offset[2])
        assert(Action:new(player, controller, "Access", "Public", nil, C.state(controller).id):isValid(), "Adjacent controller access action invalid")
    end
    local corner = IsoGridSquare.new(getCell(), nil, 29, 29, 0)
    player:setCurrent(corner)
    player:setX(29.99)
    player:setY(29.99)
    assert(A.near(player, controller), "Native-adjacent diagonal edge rejected")
    player:setX(30.2)
    assert(not A.near(player, controller), "Out-of-reach player accepted")
    player:setCurrent(square)
    player:setX(28.5)
    player:setY(28.5)
    print("[OMHTT-Controls] adjacent-native-access directions=6 policy=valid")
    local plate = create("Plate", "floors_interior_tilesandwood_01_40")
    local button = create("Button", "appliances_radio_01_0")
    local host, input = C.state(controller), C.state(plate)
    assert(controller:getContainer():getType() == "OMHTTController", "Controller real stockpile absent")
    assert(controller:getSpriteName() == "omhtt_turret_01_21", "Controller cube not applied to existing radio placeholder")
    local junk = player:getInventory():AddItem("Base.Plank")
    assert(not Transfer:new(player, controller, junk, true, host.id):complete() and player:getInventory():contains(junk), "Unrelated stockpile insertion accepted")
    assert(controller:getSpriteConfig():isValid(), "New Controller sprite configuration invalid")
    controller:setSpriteFromName("appliances_radio_01_17")
    local location = host.location
    host.sprite, host.location = "appliances_radio_01_17", "28:28:0:appliances_radio_01_17"
    C.locations[location][host.id] = nil
    C.locations[host.location] = {[host.id] = true}
    C.controllerSprite(controller,host)
    assert(controller:getSpriteName()=="omhtt_turret_01_22" and controller:getSpriteConfig():isValid()
        and controller:getSpriteConfig():getTileInfo():getSpriteName()=="omhtt_turret_01_22",
        "Legacy radio conversion must rebuild native facing metadata")
    local supplies = require("OMHTT/ControlDefinitions")
    for _, fullType in pairs({"Base.OMHTTModuleRange", "Base.OMHTTTrapPressurePlate", "Base.OMHTTTurretPotato",
        "Base.CarBattery1", "Base.Bullets9mm", "Base.9mmClip", "Base.SpearCrafted", "Base.Potato", "Base.SweetPotato",
        "Base.AluminumScrap", "Base.OMHTTAmmoMakeshiftBomb", "Base.PipeBomb", "Base.Pistol"}) do
        local item = instanceItem(fullType)
        assert(item and supplies.storable(item), "Allowed defense supply rejected: " .. fullType)
    end
    for _, fullType in pairs({"Base.Plank", "Base.Shirt_FormalWhite", "Base.Apple", "Base.Bag_Schoolbag"}) do
        local item = instanceItem(fullType)
        assert(item and not supplies.storable(item), "Unrelated supply allowed: " .. fullType)
    end
    player:getInventory():Remove(junk)
    controller:getContainer():AddItem(junk)
    assert(Transfer:new(player, controller, junk, false, host.id):complete(), "Previously stored unrelated item cannot be withdrawn")
    local bag = player:getInventory():AddItem("Base.Bag_Schoolbag")
    local module = controller:getContainer():AddItem("Base.OMHTTModuleRange")
    local move = Transfer:new(player, controller, module, false, host.id, bag)
    assert(move:complete() and module:getContainer() == bag:getInventory(), "Native stockpile withdrawal ignored selected bag")
    assert(not move:complete(), "Native stockpile withdrawal repeated")
    bag:getInventory():Remove(module)
    controller:getContainer():AddItem(module)
    OMHTT_NativeStockTransfer = Transfer:new(player, controller, module, false, host.id, bag)
    OMHTT_NativeStockSquare = square
    OMHTT_NativeStockNetwork = NetTimedAction.new()
    OMHTT_NativeStockNetwork:set(player, OMHTT_NativeStockTransfer)
    player:getInventory():Remove(bag)
    assert(not OMHTT_NativeStockTransfer:complete() and module:getContainer() == controller:getContainer(), "Removed bag accepted")
    player:getInventory():AddItem(bag)
    assert(OMHTT_NativeStockTransfer:complete() and module:getContainer() == bag:getInventory(), "Restored bag transfer failed")
    local battery = player:getInventory():AddItem("Base.Battery")
    assert(Transfer:new(player, controller, battery, true, host.id):complete(), "Native controller battery transfer failed")
    local B = require("OMHTT/TurretBattery")
    local before = B.charge(battery)
    assert(C.power(controller, .01) and math.abs(B.charge(battery) - before + .01 / 48) < .000001, "Backup fractional charge incorrect")
    assert(C.power(controller, 24) and math.abs(B.charge(battery) - before + 24.01 / 48) < .00001, "Backup 48-hour baseline incorrect")
    local spare = controller:getContainer():AddItem("Base.Battery")
    local select = Transfer:new(player, controller, spare, true, host.id, nil, true)
    local count = controller:getContainer():getItems():size()
    assert(select:complete() and not select:complete() and C.batteries[controller] == spare
        and controller:getContainer():getItems():size() == count, "Selecting backup must preserve exact stockpile item/count")
    assert(Transfer:new(player, controller, battery, true, host.id, nil, true):complete(), "Selecting original spare failed")
    assert(Transfer:new(player, controller, spare, false, host.id):complete() and spare:getContainer() == player:getInventory(), "Battery removal failed")
    assert(not Transfer:new(player, controller, spare, true, host.id, nil, true):complete(), "Selecting a non-stockpile battery accepted")
    player:getInventory():Remove(spare)
    print("[OMHTT-C300] backup-select=exact replay=blocked remote-item=blocked")
    host.powered = true
    local assign = Action:new(player, controller, "Assign", true, plate, host.id, input.id)
    assert(assign:complete() and not assign:complete() and input.controller == host.id, "Assignment/replay check failed")
    assert(Action:new(player, plate, "Name", "Gate plate", nil, input.id):complete() and input.name == "Gate plate", "Name save failed")
    assert(not Action:new(player, plate, "Name", "<bad>", nil, input.id):complete(), "Markup name accepted")
    assert(Action:new(player, plate, "Trigger", "Zombies", nil, input.id):complete(), "Plate filter failed")
    local stranger = IsoPlayer.new(getCell())
    stranger:setUsername("stranger")
    stranger:setCurrent(square)
    stranger:setX(28.5)
    stranger:setY(28.5)
    stranger:setZ(0)
    assert(A.authorized(stranger, plate, true) and not A.authorized(stranger, plate), "Private device read/write separation failed")
    assert(not Action:new(stranger, plate, "Name", "stolen", nil, input.id):complete(), "Unauthorized write accepted")
    assert(Action:new(stranger, button, "Pulse", nil, nil, C.state(button).id):complete(), "Anyone must be able to physically press button")
    assert(Action:new(player, plate, "Access", "Public", nil, input.id):complete() and A.authorized(stranger, plate), "Public access failed")
    assert(not Action:new(stranger, plate, "Access", "Private", nil, input.id):complete(), "Public writer stole ownership policy")
    local previous = input.access
    assert(not Action:new(player, plate, "Access", "Faction", nil, input.id):complete() and input.access == previous, "Missing faction changed access")
    plate:getModData().OMHTTControl = {id = input.id, owner = "stranger", access = "Public"}
    assert(C.state(plate).owner == "control-owner", "Public metadata replaced authoritative owner")
    C.publish(plate)
    local base = player:getInventory():AddItem(T.BASE)
    T.configure(base:getInventory())
    local consumedBase = ArrayList.new()
    consumedBase:add(base)
    local localTurret = IsoThumpable.new(getCell(), square, "omhtt_turret_01_16", false)
    square:getObjects():add(localTurret)
    square:getSpecialObjects():add(localTurret)
    local turretInfo = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    GameEntityFactory.CreateIsoObjectEntity(localTurret, turretInfo:getScript():getParent(), true)
    require("OMHTT/TurretWorld").onCreate({thumpable=localTurret,character=player,facing="e",
        craftRecipeData={getAllConsumedItems=function() return consumedBase end}})
    local head = controller:getContainer():AddItem("Base.OMHTTTurretBallista")
    local turretId = T.state(localTurret).id
    local TurretTransfer = require("OMHTT/TurretTransferAction")
    host.powered = false
    local installHead = TurretTransfer:new(player, localTurret, head, true, turretId, nil, nil, false, controller)
    local installNetwork = NetTimedAction.new()
    installNetwork:set(player, installHead)
    assert(installHead.controller == controller and installHead:complete() and not installHead:complete(), "Native nearby stockpile head install/replay failed")
    assert(head:getContainer() == localTurret:getContainer(), "Head was copied instead of moved")
    local returnHead = TurretTransfer:new(player, localTurret, head, false, turretId, nil, nil, true, controller)
    assert(Transfer.canStore(player,controller,head) and returnHead:complete()
        and head:getContainer() == controller:getContainer(), "Native installed-head drop to exact stockpile failed")
    assert(not TurretTransfer:new(stranger,localTurret,head,true,turretId,nil,nil,false,controller):complete(), "Private stockpile theft accepted")
    assert(Transfer:new(player,controller,head,false,host.id):complete(), "Head cleanup withdrawal failed")
    assert(require("OMHTT/TurretPickupAction"):new(player,localTurret,"Pickup",turretId):complete(), "Empty native test turret cleanup failed")
    host.powered = true
    print("[OMHTT-C300] native-stockpile-head=bidirectional exact-item=yes offline-nearby=yes theft=blocked net-action=constructed")
    local far = IsoGridSquare.new(getCell(), nil, 40, 28, 0)
    local receiver = IsoThumpable.new(getCell(), far, "omhtt_turret_01_16", false)
    far:getObjects():add(receiver)
    receiver:setHealth(100)
    local output = C.register(receiver, player, "Turret")
    C.number(receiver, instanceItem("Base.OMHTTTurretBallista"))
    assert(output.headType == "Base.OMHTTTurretBallista" and not output.number, "Unassigned head metadata did not refresh")
    output.controller = host.id
    require("OMHTT/ControlRemote").command("OMHTT_ControlRemote", "Renew", player, {controller = host.id, target = output.id, serial = 1, player = 0})
    assert(A.authorized(player, receiver) and A.stockpile(player, receiver) == controller, "Remote write/storage scope missing")
    host.powered = false
    assert(not A.authorized(player, receiver), "Power loss allowed remote writes")
    host.powered = true
    output.controller = nil
    assert(not A.authorized(player, receiver), "Unassignment allowed stale remote writes")
    output.controller = host.id
    local clock = getTimestampMs()
    input.recoverAt, input.active = clock - 1, true
    assert(C.link(plate, receiver, true), "Native direct link failed")
    local linked, on = C.input(receiver, clock)
    assert(linked and on, "Occupied plate did not power receiver")
    input.active = false
    linked, on = C.input(receiver, clock)
    assert(linked and not on, "Released plate did not clear signal")
    input.active, input.recoverAt = true, clock + 1000
    linked, on = C.input(receiver, clock)
    assert(linked and not on, "Recovery delay replayed occupancy early")
    input.recoverAt = clock - 1
    C.removed(plate)
    linked, on = C.input(receiver, clock)
    assert(linked and not on, "Removed input retained power")
    C.bind(plate)
    assert(C.state(plate) == input and not input.active, "Reload failed private identity/recovery")
    C.clearInputs(receiver)
    assert(not C.input(receiver, getTimestampMs()) and #input.links == 0, "Native clear-input recovery left stale links")
    assert(C.link(plate, receiver, true), "Native relink after recovery failed")
    local storage = controller:getContainer()
    for i = 1, 249 do storage:AddItem("Base.OMHTTTrapBarbedPanel") end
    assert(storage:getCapacityWeight() > 100, "Heavy fixture failed to exceed ordinary native limit")
    local savedBattery = C.batteries[controller]
    storage:Remove(savedBattery)
    storage:AddItem(savedBattery)
    C.batteries[controller], C.batteryScan[controller] = nil, 0
    assert(C.power(controller, 0) and C.batteries[controller] == savedBattery, "Saved battery identity must restore immediately behind 249 stockpile items")
    local extra = player:getInventory():AddItem("Base.OMHTTTrapBarbedPanel")
    assert(not Transfer:new(player, controller, extra, true, host.id):complete(), "Stockpile exceeded 500 real weight")
    local first = storage:getFirstType("Base.OMHTTTrapBarbedPanel")
    local firstId, weight = first:getID(), storage:getCapacityWeight()
    assert(C.pickup(player, controller), "Loaded heavy controller pickup failed")
    local packed = first:getContainer():getContainingItem()
    assert(packed and packed:getFullType() == "Base.OMHTTTrapController" and packed:getInventory():contains(first), "Exact stockpile lost on pickup")
    assert(player:getPrimaryHandItem() == packed and player:getSecondaryHandItem() == packed, "Heavy controller must occupy both hands")
    assert(first:getID() == firstId and math.abs(packed:getInventory():getCapacityWeight() - weight) < .001, "Packed contents weight/identity changed")
    assert(C.records().packed[tostring(packed:getID())].id == host.id, "Private packed ownership lost")
    packed:getModData().OMHTTControl = {owner = "stranger", access = "Public"}
    local consumed = ArrayList.new()
    consumed:add(packed)
    local rebuilt = IsoThumpable.new(getCell(), square, "omhtt_turret_01_21", false)
    square:getObjects():add(rebuilt)
    square:getSpecialObjects():add(rebuilt)
    GameEntityFactory.CreateIsoObjectEntity(rebuilt, SpriteConfigManager.GetObjectInfo("OMHTTDeployController"):getScript():getParent(), true)
    C.create({thumpable = rebuilt, character = player, craftRecipeData = {getAllConsumedItems = function() return consumed end}})
    assert(C.state(rebuilt).id == host.id and C.state(rebuilt).owner == "control-owner", "Redeployment trusted forged ownership")
    assert(rebuilt:getContainer():contains(first) and rebuilt:getContainer():getItems():size() == 250, "Redeployment changed exact stockpile")
    assert(C.pickup(player, rebuilt), "Second heavy pickup failed")
    OMHTT_NativeHeavyController = first:getContainer():getContainingItem()
    local allowance = require("OMHTT/TurretAmmoCapacity")
    local saved = SandboxVars.OMHTurretsTraps
    SandboxVars.OMHTurretsTraps = {}
    for kind, row in pairs(allowance.rows) do
        assert(allowance.resolve(kind, {}, row[1]) == row[1], "Base allowance mismatch")
        for i = 1, 4 do
            assert(allowance.resolve(kind, {[allowance.kits[i]] = 1}, row[1]) == row[i + 1], "Expansion allowance mismatch " .. kind)
        end
    end
    SandboxVars.OMHTurretsTraps = saved
    print("[OMHTT-Controls] native devices=3 ownership=private read=public replay=blocked remote=power-scoped plate=recovery-safe backup=48h heavy=exact capacities=30")
end
