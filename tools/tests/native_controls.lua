local C = require("OMHTT/ControlWorld")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local Transfer = require("OMHTT/ControlTransferAction")
local T = require("OMHTT/Turret")

return function(player)
    require("OMHTT/NativeTriggers")(player)
    -- Legacy ownership/receiver fixture uses synthetic, non-loaded squares. Shared
    -- supply is exercised with actual batteries and native objects in NativeTriggers.
    local triggerPower = require("OMHTT/ControlPower").trigger
    require("OMHTT/ControlPower").trigger = function() return true end
    assert(isServer() and not isClient(), "Controls probe requires actual server mode")
    if EXPECT_READ then
        local targetingFixture = ModData.getOrCreate("OMHTTNativeTargeting")
        local targetingHost = C.records().records[targetingFixture.controller]
        assert(targetingHost and targetingHost.targeting == "OtherFactions", "Fresh process lost Controller target default")
        local targeting = require("OMHTT/ControlTargeting")
        assert(not targetingHost.placed and targeting.resolve({kind = "Turret", controller = targetingHost.id}, targetingHost) == "Zombies",
            "Packed Controller must not supply inherited targeting after restart")
        print("[OMHTT-C386] targeting fresh-process=preserved packed-host=excluded")
        local pokeFixture = ModData.getOrCreate("OMHTTNativePoke")
        local pokeRecord = C.records().packed[pokeFixture.item]
        assert(pokeRecord and pokeRecord.id == pokeFixture.id and pokeRecord.enabled == false and pokeRecord.carriedHealth == 123,
            "Fresh process lost private packed Poke ownership/disabled state")
        print("[OMHTT-C339] private-poke fresh-process=preserved")
        local groupFixture = ModData.getOrCreate("OMHTTNativeGroups")
        local groupHost = C.records().records[groupFixture.controller]
        assert(groupHost and groupHost.organization.revision == 8
            and groupHost.organization.groups[1].name == "Inside Defenses", "Fresh process lost Controller groups")
        print("[OMHTT-C327] native groups fresh-process=preserved")
        local fixture = ModData.getOrCreate("OMHTTNativeControls")
        local saved = fixture.plate and C.records().records[fixture.plate]
        assert(saved and saved.name == fixture.label and saved.owner == "control-owner"
            and saved.trigger == "Zombies", "Fresh process lost exact private device/access configuration")
        assert(#saved.links == 1 and saved.links[1] == fixture.receiver, "Saved private link was lost")
        local retired = C.records().records[fixture.retired]
        assert(retired and not retired.placed and #retired.links == 0
            and not C.incoming[fixture.receiver][fixture.retired], "Restart retained a legacy retired input")
        print("[OMHTT-C344] fresh-process live-link=preserved retired-link=removed")
        assert(saved.displayName == fixture.displayName and saved.displayNumber == fixture.displayNumber,
            "Fresh process lost the device's display identity")
        local names = ModData.getOrCreate("OMHTTDefenseNamesV1")
        local entry = names.entries[saved.displayIdentity]
        assert(entry and entry.label == saved.displayName and entry.number == saved.displayNumber,
            "Fresh process lost the private naming reservation")
        print("[OMHTT-C323] native-names fresh-process=preserved private-reservation=preserved")
    end
    player:setUsername("control-owner")
    local recipes = {
        {"Controller", {SmallSheetMetal = 2, ElectronicsScrap = 4, ElectricWire = 2, Screws = 4}},
        {"Plate", {Plank = 1, ElectronicsScrap = 2, ElectricWire = 1, Nails = 4}},
        {"Button", {ElectronicsScrap = 1, ElectricWire = 1, Screws = 2}},
        {"Lever", {ElectronicsScrap = 1, ElectricWire = 1, Screws = 2}},
        {"Laser", {ElectronicsScrap = 2, ElectricWire = 1, SmallSheetMetal = 1, Screws = 2}},
        {"Poke", {TirePump = 1, MetalBar = 4, SmallSheetMetal = 2, ElectronicsScrap = 4, ElectricWire = 2, Screws = 8}},
        {"Poke", {MetalPipe = 2, MetalBar = 4, SmallSheetMetal = 2, ElectronicsScrap = 4, ElectricWire = 2, Screws = 8}, "PokeImprovised"},
    }
    require("OMHTT/NativeTether")()
    require("OMHTT/NativePlacement")(player)
    require("OMHTT/NativeTetherService")(player)
    assert(GameSounds.getSound("LightSwitch"), "Native Button cue must exist")
    for n = 1, #recipes do
        local case = recipes[n]
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraft" .. (case[3] or case[1]))
        assert(recipe, "Control craft missing")
        if case[1] == "Poke" then
            assert(math.abs(recipe:getTime() * 5 - 30 * getGameTime():getMultiplierFromTimeDelta(1)) < .001,
                "Poke recipe must take thirty real seconds at normal speed")
        end
        local inputs, resources, kept = ArrayList.new(), ArrayList.new(), {}
        for _, name in pairs({"Screwdriver", "Pliers", "Hammer", "Wrench"}) do
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
        for i = 1, #kept do assert(player:getInventory():contains(kept[i]), "Control craft consumed tool"); player:getInventory():Remove(kept[i]) end
        player:getInventory():Remove(data:getFirstCreatedItem())
    end
    local square = IsoGridSquare.new(getCell(), nil, 28, 28, 0)
    player:setCurrent(square)
    player:setX(28.5)
    player:setY(28.5)
    player:setZ(0)
    local function create(kind, sprite, location)
        location = location or square
        local item = player:getInventory():AddItem(require("OMHTT/ControlDefinitions").types[kind])
        assert(item, "Missing control item " .. kind)
        local consumed = ArrayList.new()
        consumed:add(item)
        local object = IsoThumpable.new(getCell(), location, sprite, false)
        location:getObjects():add(object)
        location:getSpecialObjects():add(object)
        local info = SpriteConfigManager.GetObjectInfo("OMHTTDeploy" .. kind)
        assert(info and info:getScript(), "Missing control entity " .. kind)
        GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
        C.create({thumpable = object, character = player, craftRecipeData = {getAllConsumedItems = function() return consumed end}})
        assert(C.state(object).owner == "control-owner" and not player:getInventory():contains(item), "Exact placement ownership failed")
        return object
    end
    local controller = create("Controller", "omhtt_turret_01_21")
    local expansion = require("OMHTT/ControlExpansion")
    local expansionAction = require("OMHTT/ControlExpansionAction")
    local kit = player:getInventory():AddItem("Base.OMHTTModuleExpansionLarge")
    assert(expansionAction:new(player, controller, kit):complete(), "Native Controller kit installation failed")
    assert(expansion.item(controller) == kit and expansion.capacity(controller) == 500 and controller:getContainer():getCapacity() == 100 and A.radius(controller) == 50,
        "Native Controller kit effects missing: item=" .. tostring(expansion.item(controller) == kit) .. " capacity=" .. controller:getContainer():getCapacity() .. " radius=" .. A.radius(controller))
    assert(expansionAction:new(player, controller, nil):complete() and kit:getContainer() == player:getInventory(), "Native exact-kit removal failed")
    assert(controller:getContainer():getCapacity() == 100 and A.radius(controller) == 10, "Native base Controller limits did not restore")
    assert(expansionAction:new(player, controller, kit):complete(), "Native kit reinstall failed")
    print("[OMHTT-C397] native Controller kit=exact install/remove=pass radius=10/50 capacity=100/500")
    local layoutHost = C.state(controller)
    local targeting = require("OMHTT/ControlTargeting")
    local targetingAction = Action:new(player, controller, "Targeting", "OtherFactions", nil, layoutHost.id)
    assert(targetingAction:complete() and not targetingAction:complete(), "Native targeting action/replay failed")
    assert(controller:getModData().OMHTTControl.targetingEffective == "OtherFactions", "Native targeting snapshot failed")
    ModData.getOrCreate("OMHTTNativeTargeting").controller = layoutHost.id
    assert(not targeting.outsider(layoutHost, player), "Native owner exclusion failed")
    assert(Faction.getPlayerFaction(player:getUsername()) == Faction.getPlayerFaction(player), "Native faction string lookup differs")
    print("[OMHTT-C386] targeting command=passed snapshot=passed owner-exclusion=passed faction-string=passed")
    require("OMHTT/NativeTargeting")(player, controller)
    local add = Action:new(player, controller, "GroupAdd", "0|||Base Front", nil, layoutHost.id)
    assert(add:complete() and layoutHost.organization.groups[1].name == "Base Front", "Native group creation failed")
    assert(not add:complete(), "Group action replay succeeded")
    assert(not Action:new(player, controller, "GroupAdd", "0|||Stale", nil, layoutHost.id):complete(), "Stale group revision accepted")
    local view = C.copy(layoutHost)
    view.organization.groups[1].name = "Client mutation"
    assert(layoutHost.organization.groups[1].name == "Base Front", "Published groups alias authoritative state")
    assert(Action:new(player, controller, "GroupAdd", "1|||Base Rear", nil, layoutHost.id):complete(), "Second group failed")
    assert(Action:new(player, controller, "GroupMove", "2|2|1|", nil, layoutHost.id):complete(), "Group reordering failed")
    assert(layoutHost.organization.groups[1].id == "2", "Group order not persisted")
    assert(Action:new(player, controller, "GroupName", "3|2||Inside Defenses", nil, layoutHost.id):complete(), "Group rename failed")
    local groupFixture = ModData.getOrCreate("OMHTTNativeGroups")
    groupFixture.controller = layoutHost.id
    print("[OMHTT-C327] native groups=create/reorder/rename stale=rejected snapshot=detached")
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
    OMHTT_NativePlate = plate
    assert(plate:getSpriteName() == "omhtt_turret_01_25", "Existing plate did not adopt inset sprite")
    assert(plate:getSpriteConfig():getTileInfo():getSpriteName() == "omhtt_turret_01_25", "Existing plate placement component was not migrated")
    local plateState = C.state(plate)
    plateState.recoverAt = require("OMHTT/ControlClock").now() - 1
    local moving = square:getMovingObjects()
    local alreadyPresent = moving:contains(player)
    if not alreadyPresent then moving:add(player) end
    C.updatePlate(plate, getTimestampMs())
    assert(plateState.active and plate:getSpriteName() == "omhtt_turret_01_29", "Native occupied plate failed to press")
    moving:remove(player)
    C.updatePlate(plate, getTimestampMs())
    assert(not plateState.active and plate:getSpriteName() == "omhtt_turret_01_25", "Native released plate failed to rise")
    if alreadyPresent then moving:add(player) end
    print("[OMHTT-C309] native-plate migration=passed pressed=29 released=25 state=authoritative")
    assert(not plate:isThumpable() and plate:isCanPassThrough() and not plate:isBlockAllTheSquare(), "Native plate must be pass-through and non-thumpable")
    assert(plate:getThumpableFor(player) == nil, "Native thump target must reject a passive plate")
    local standing = IsoZombie.new(getCell())
    assert(plate:getThumpableFor(standing) == nil, "Standing zombie may not target plate for thumping")
    standing:setCrawler(true)
    assert(plate:getThumpableFor(standing) == nil, "Crawler may not target plate for thumping")
    print("[OMHTT-C308] native-plate standing=nonthumpable crawler=nonthumpable")
    local nameRegistry = ModData.getOrCreate("OMHTTDefenseNamesV1")
    local nextButton = ((nameRegistry.counters and nameRegistry.counters.Button) or 0) + 1
    local button = create("Button", "appliances_radio_01_0")
    assert(button:getSpriteName() == "lighting_indoor_01_0" and instanceof(button, "IsoThumpable")
        and not instanceof(button, "IsoLightSwitch"), "Button must retain momentary device type with native switch art")
    assert(button:getSpriteConfig():isValid() and button:getSpriteConfig():getTileInfo():getSpriteName() == "lighting_indoor_01_0",
        "Existing Button sprite component migration failed")
    if not EXPECT_READ then
        assert(C.state(button).displayName == "Button #" .. nextButton, "Button numbering must advance from one without reuse")
    end
    print("[OMHTT-C323] native-button sprite=lightswitch device=momentary identity=numbered")
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
        "Base.Battery", "Base.Bullets9mm", "Base.9mmClip", "Base.SpearCrafted", "Base.Potato", "Base.SweetPotato",
        "Base.AluminumScrap", "Base.OMHTTAmmoMakeshiftBomb", "Base.PipeBomb", "Base.Pistol"}) do
        local item = instanceItem(fullType)
        assert(item and supplies.storable(item), "Allowed defense supply rejected: " .. fullType)
    end
    for _, fullType in pairs({"Base.Plank", "Base.Shirt_FormalWhite", "Base.Apple", "Base.Bag_Schoolbag", "Base.IDcard"}) do
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
    local battery = player:getInventory():AddItem("Base.CarBattery1")
    assert(Transfer:new(player, controller, battery, true, host.id):complete(), "Native controller battery transfer failed")
    local B = require("OMHTT/TurretBattery")
    local before = B.charge(battery)
    assert(C.power(controller, .01) and math.abs(B.charge(battery) - before + .01 / 48) < .000001, "Backup fractional charge incorrect")
    assert(C.power(controller, 24) and math.abs(B.charge(battery) - before + 24.01 / 48) < .00001, "Backup 48-hour baseline incorrect")
    local spare = player:getInventory():AddItem("Base.CarBattery1")
    assert(Transfer:new(player, controller, spare, true, host.id):complete(), "Second backup battery deposit failed")
    local select = Transfer:new(player, controller, spare, true, host.id, nil, true)
    local count = controller:getContainer():getItems():size()
    assert(select:complete() and not select:complete() and C.batteries[controller] == spare
        and controller:getContainer():getItems():size() == count, "Selecting backup must preserve exact stockpile item/count")
    assert(Transfer:new(player, controller, battery, true, host.id, nil, true):complete(), "Selecting original spare failed")
    B.spend(battery, 1)
    assert(C.power(controller, 0) and C.batteries[controller] == spare
        and controller:getContainer():getItems():size() == count, "Depleted backup must select exact charged spare without consuming stored items")
    battery:setCurrentUsesFloat(1)
    assert(Transfer:new(player, controller, battery, true, host.id, nil, true):complete(), "Restoring original backup selection failed")
    print("[OMHTT-C302] multiple-batteries=exact depleted-spare=selected count=preserved")
    for i = 1, 2000 do
        assert(C.power(controller, .0001 + (i % 11) * .0000003), "Native fractional Controller debit flickered offline")
    end
    print("[OMHTT-C340] native Controller fractional-debits=2000 stable=passed switch-sound=present")
    for _, route in pairs({"Poke", "PokeImprovised"}) do
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraft" .. route)
        assert(recipe and recipe:getInputs():size() == 6, "Mechanical Poke recipe input count")
        assert(recipe:getXPAwardCount() == 1 and recipe:getXPAward(0):getPerk() == Perks.Mechanics,
            "Mechanical Poke awards only Mechanics XP")
        local inputs, resources = ArrayList.new(), ArrayList.new()
        local costs = {Screwdriver = 1, Wrench = 1, MetalBar = 4, SmallSheetMetal = 2, Screws = 8}
        costs[route == "Poke" and "TirePump" or "MetalPipe"] = route == "Poke" and 1 or 2
        for name, count in pairs(costs) do
            for i = 1, count do inputs:add(instanceItem("Base." .. name)) end
        end
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        assert(data:canConsumeInputs(resources, inputs, true, true), "Mechanical inputs rejected: " .. route)
        for i = 0, inputs:size() - 1 do
            local material = inputs:get(i)
            player:getInventory():AddItem(material)
            for j = 0, recipe:getInputs():size() - 1 do data:offerInputItem(recipe:getInputs():get(j), material) end
        end
        assert(data:consumeInputs(resources) and data:createOutputs(resources, player), "Mechanical Poke craft transaction")
        data:luaCallOnCreate(player)
        data:processDestroyAndUsedItems(player)
        local output = data:getFirstCreatedItem()
        assert(output and output:getFullType() == "Base.OMHTTTrapPokeFloor" and data:getAllCreatedItems():size() == 1,
            "Mechanical Poke output identity/count")
        for i = 0, inputs:size() - 1 do
            local material = inputs:get(i)
            local tool = material:getFullType() == "Base.Screwdriver" or material:getFullType() == "Base.Wrench"
            assert((material:getContainer() == player:getInventory()) == tool, "Poke tool retention/material consumption")
            if tool then player:getInventory():Remove(material) end
        end
        player:getInventory():Remove(output)
    end
    assert(getText("IGUI_CraftingCategories_OMHControls") == "OMH: Triggers"
        and getText("IGUI_ContainerTitle_OMHTTPoke") == "Poke Floor", "Native trigger/Poke translations")
    print("[OMHTT-C355] mechanical-recipes=2 inputs=consumed tools=retained output=exact translations=passed")
    local poke = create("Poke", "omhtt_barrier_01_85")
    local pokeState = C.state(poke)
    local PokeAction = require("OMHTT/ControlPokeAction")
    assert(poke:getMaxHealth() == 200 and poke:getHealth() == 200, "Poke Floor condition")
    assert(not poke:isThumpable(), "Poke Floor must be non-thumpable")
    assert(not C.link(plate, poke, true) and not C.link(poke, plate, true), "Poke Floor accepts no external signals")
    assert(not Action:new(player, poke, "Repair", nil, nil, pokeState.id):complete(), "Generic free repair must not bypass Poke Floor cost")
    assert(not PokeAction:new(player, poke, "Power", false, nil, pokeState.id):complete(), "Mechanical Poke rejects retired disable action")
    pokeState.enabled = false -- Legacy saved flag must survive without controlling mechanical activation.
    local pokeBattery = player:getInventory():AddItem("Base.CarBattery2")
    B.spend(pokeBattery, .123456)
    local exact = B.charge(pokeBattery)
    assert(not PokeAction:new(player, poke, "Battery", true, pokeBattery, pokeState.id):complete(), "Mechanical Poke rejects battery installation")
    -- Seed a pre-patch battery to exercise safe withdrawal and packed-item persistence.
    player:getInventory():Remove(pokeBattery)
    poke:getContainer():AddItem(pokeBattery)
    assert(PokeAction:new(player, poke, "Battery", false, pokeBattery, pokeState.id):complete(), "Legacy battery withdrawal")
    assert(pokeBattery:getContainer() == player:getInventory() and math.abs(B.charge(pokeBattery) - exact) < .000001,
        "Legacy withdrawal changes neither identity nor fractional charge")
    player:getInventory():Remove(pokeBattery)
    poke:getContainer():AddItem(pokeBattery)
    assert(poke:getContainer():contains(pokeBattery), "Poke Floor exact battery identity")
    assert(C.assign(controller, poke, player, true), "Poke Floor Controller assignment")
    assert(not require("OMHTT/ControlPower").fallback(poke, .001), "Mechanical Poke cannot consume Controller charge")
    local Power = require("OMHTT/ControlPower")
    local source = {kind = "controller", controller = controller, battery = Power.battery(controller, .001), cost = .001}
    assert(source.battery, "Native Controller bank selection")
    local sourceCharge = B.charge(source.battery)
    assert(math.abs(Power.spend(source) - .001) < .000001 and math.abs(B.charge(source.battery) - sourceCharge + .001) < .000001, "Native shared debit exact")
    poke:setHealth(123)
    assert(C.pickup(player, poke), "Native Poke Floor pickup")
    local packedPoke = pokeBattery:getContainer():getContainingItem()
    assert(packedPoke and packedPoke:getFullType() == "Base.OMHTTTrapPokeFloor" and packedPoke:getCondition() == 123, "Poke pickup retains wear")
    assert(math.abs(B.charge(pokeBattery) - exact) < .000001, "Poke pickup preserves exact battery charge")
    local pokeItems = ArrayList.new()
    pokeItems:add(packedPoke)
    local installedPoke = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_85", false)
    square:getObjects():add(installedPoke)
    square:getSpecialObjects():add(installedPoke)
    GameEntityFactory.CreateIsoObjectEntity(installedPoke, SpriteConfigManager.GetObjectInfo("OMHTTDeployPoke"):getScript():getParent(), true)
    C.create({thumpable = installedPoke, character = player, craftRecipeData = {getAllConsumedItems = function() return pokeItems end}})
    assert(installedPoke:getHealth() == 123 and installedPoke:getContainer():contains(pokeBattery), "Poke redeploy retains condition and exact battery")
    assert(C.state(installedPoke).id == pokeState.id and C.state(installedPoke).enabled == false, "Poke redeploy preserves identity and disabled state")
    assert(C.pickup(player, installedPoke), "Poke persistence fixture pickup")
    OMHTT_NativePackedPoke = pokeBattery:getContainer():getContainingItem()
    local pokeFixture = ModData.getOrCreate("OMHTTNativePoke")
    pokeFixture.id = pokeState.id
    pokeFixture.item = tostring(OMHTT_NativePackedPoke:getID())
    assert(require("OMHTT/Turret").TYPES.Grid == "Base.OMHTTModuleGrid", "Grid Module registered")
    assert(require("OMHTT/TurretRarity").get("Grid").band == 7, "Grid Module must be Mythic")
    print("[OMHTT-C339] native poke=placed pickup=exact redeploy=exact bank=atomic grid=mythic")

    assert(Transfer:new(player, controller, spare, false, host.id):complete() and spare:getContainer() == player:getInventory(), "Battery removal failed")
    assert(not Transfer:new(player, controller, spare, true, host.id, nil, true):complete(), "Selecting a non-stockpile battery accepted")
    player:getInventory():Remove(spare)
    print("[OMHTT-C300] backup-select=exact replay=blocked remote-item=blocked")
    host.powered = true
    local assign = Action:new(player, controller, "Assign", true, plate, host.id, input.id)
    assert(assign:complete() and not assign:complete() and input.controller == host.id, "Assignment/replay check failed")
    assert(Action:new(player, plate, "Name", "Gate plate", nil, input.id):complete() and string.find(input.name, "Gate plate", 1, true), "Name save failed")
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
    -- Recover an isolated fixture tile left by a prior failed probe, as normal chunk load does.
    require("OMHTT/TurretAuthority").reconcile(square)
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
    require("OMHTT/NativeC314")(player, controller, localTurret)
    require("OMHTT/NativeC444")(player, localTurret)
    local Cycle = require("OMHTT/ControlCycle")
    local World = require("OMHTT/TurretWorld")
    local Clock = require("OMHTT/TurretClock")
    local storage = localTurret:getContainer()
    local pulseHead = storage:AddItem("Base.OMHTTTurretPotato")
    storage:AddItem("Base.OMHTTModuleFiring")
    local battery = storage:AddItem("Base.CarBattery1")
    battery:setCurrentUsesFloat(1)
    for i = 1, 5 do storage:AddItem("Base.Potato") end
    World.refresh(localTurret)
    C.state(button).recoverAt, C.state(localTurret).recoverAt = 0, 0
    assert(C.link(button,localTurret,true), "Native cycle input link failed")
    C.state(button).pulseUntil = nil -- The earlier physical press has completed before this isolated cycle.
    local clockNow = Clock.now
    local activeNow = clockNow()
    Clock.now = function() return activeNow end
    T.state(localTurret).facingPending = true
    C.pulse(localTurret)
    local request = Cycle.pending[localTurret]
    assert(request and T.isOn(T.state(localTurret)), "Native button did not retain pending turn")
    for i=1,20 do C.pulse(localTurret) end
    assert(Cycle.pending[localTurret] == request, "Native repeated press replaced current cycle")
    T.state(localTurret).facingPending = nil
    C.receiver(localTurret,getTimestampMs())
    assert(Cycle.pending[localTurret] and T.isOn(T.state(localTurret)), "Native pending turn did not continue through reload")
    activeNow = activeNow + T.cycleConfig(T.contents(storage)).reload + 100
    C.receiver(localTurret,getTimestampMs())
    assert(not Cycle.pending[localTurret] and not T.isOn(T.state(localTurret)), "Native completed shot did not release temporary power")
    assert(T.contents(storage).ammo == 4, "Native pulse did not consume exactly one real potato")
    Clock.now = clockNow
    C.clearInputs(localTurret)
    while storage:getItems():size() > 0 do storage:Remove(storage:getItems():get(0)) end
    World.refresh(localTurret)
    print("[OMHTT-C330] native-cycle turn/reload/shot=pass rapid-press=no-backlog real-ammo=one power=off")

    assert(require("OMHTT/TurretPickupAction"):new(player,localTurret,"Pickup",turretId):complete(), "Empty native test turret cleanup failed")
    host.powered = true
    print("[OMHTT-C300] native-stockpile-head=bidirectional exact-item=yes offline-nearby=yes theft=blocked net-action=constructed")
    local far = IsoGridSquare.new(getCell(), nil, 40, 28, 0)
    local receiver = IsoThumpable.new(getCell(), far, "omhtt_turret_01_16", false)
    far:getObjects():add(receiver)
    receiver:setHealth(100)
    local output = C.register(receiver, player, "Turret")
    C.number(receiver, instanceItem("Base.OMHTTTurretBallista"))
    assert(output.headType == "Base.OMHTTTurretBallista" and output.number and output.displayName, "Unassigned turret must retain numbered head metadata")
    output.controller = host.id
    require("OMHTT/ControlRemote").command("OMHTT_ControlRemote", "Renew", player, {controller = host.id, target = output.id, serial = 1, player = 0})
    assert(A.authorized(player, receiver) and A.stockpile(player, receiver) == controller, "Remote write/storage scope missing")
    host.powered = false
    assert(not A.authorized(player, receiver), "Power loss allowed remote writes")
    host.powered = true
    output.controller = nil
    assert(not A.authorized(player, receiver), "Unassignment allowed stale remote writes")
    output.controller = host.id
    local clock = require("OMHTT/ControlClock").now()
    local inputSquare = IsoGridSquare.new(getCell(), nil, 38, 28, 0)
    local remotePlate = create("Plate", "floors_interior_tilesandwood_01_40", inputSquare)
    local remoteState = C.state(remotePlate)
    assert(remoteState.controller == host.id and not A.near(player,remotePlate), "Native placement failed automatic Controller assignment")
    require("OMHTT/ControlRemote").command("OMHTT_ControlRemote","Renew",player,
        {controller=host.id,target=remoteState.id,serial=2,player=0})
    local remoteLink = Action:new(player,remotePlate,"Link",true,receiver,remoteState.id,output.id)
    local remoteNetwork = NetTimedAction.new()
    remoteNetwork:set(player,remoteLink)
    assert(remoteLink:complete() and #remoteState.links == 1, "Native remote link still requires input proximity")
    host.powered = false
    assert(not Action:new(player,remotePlate,"Link",false,receiver,remoteState.id,output.id):complete(), "Native remote link ignored power loss")
    host.powered = true
    C.deleted(remotePlate)
    inputSquare:getObjects():remove(remotePlate)
    inputSquare:getSpecialObjects():remove(remotePlate)
    print("[OMHTT-C315] placement=auto-assigned remote-link=serialized power-loss=blocked input-distance=10")
    input.recoverAt, input.active = clock - 1, true
    assert(C.link(plate, receiver, true), "Native direct link failed")
    assert(C.link(button, receiver, true), "Native second input link failed")
    local moveGroup = Action:new(player, controller, "DeviceMove", "4|1||", plate, host.id, input.id)
    local groupNetwork = NetTimedAction.new()
    groupNetwork:set(player, moveGroup)
    assert(moveGroup:complete() and not moveGroup:complete(), "Native group move/replay failed")
    assert(host.organization.members[input.id] == "1", "Group membership missing")
    assert(Action:new(player, controller, "DeviceMove", "5|2|" .. input.id .. "|", receiver, host.id, output.id):complete(), "Remote defense group move failed")
    local beforeIndex, afterIndex
    for i = 1, #host.organization.order do
        if host.organization.order[i] == output.id then beforeIndex = i end
        if host.organization.order[i] == input.id then afterIndex = i end
    end
    assert(beforeIndex and afterIndex == beforeIndex + 1, "Device ordering failed")
    assert(not Action:new(stranger, controller, "GroupName", "6|2||Stolen", nil, host.id):complete(), "Private Controller organization writable by stranger")
    assert(not Action:new(player, controller, "GroupName", "6|2||<bad>", nil, host.id):complete(), "Group markup accepted")
    assert(not Action:new(player, controller, "GroupDelete", "5|1||", nil, host.id):complete(), "Stale group deletion accepted")
    assert(Action:new(player, controller, "GroupDelete", "6|1||", nil, host.id):complete(), "Group deletion failed")
    assert(not host.organization.members[input.id] and #input.links == 1 and input.links[1] == output.id, "Ungrouping disconnected device")
    assert(Action:new(player, controller, "DeviceMove", "7|2|" .. output.id .. "|", plate, host.id, input.id):complete(), "Device reordering failed")
    for i = 1, #host.organization.order do
        if host.organization.order[i] == input.id then beforeIndex = i end
        if host.organization.order[i] == output.id then afterIndex = i end
    end
    assert(afterIndex == beforeIndex + 1 and #input.links == 1, "Reordering lost links")
    print("[OMHTT-C327] native groups device-move=serialized delete=ungroup-only cross-group-links=preserved permissions=checked replay=blocked")

    C.publish(receiver)
    assert(#receiver:getModData().OMHTTControl.inputs == 2, "Receiver did not publish both incoming sources")
    assert(C.link(button, receiver, false), "Individual disconnect failed")
    assert(#receiver:getModData().OMHTTControl.inputs == 1, "Disconnect left stale incoming source")
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
    plate:setIsThumpable(true)
    C.bind(plate)
    assert(not plate:isThumpable(), "Reload must repair existing thumpable plates")
    assert(C.state(plate) == input and not input.active, "Reload failed private identity/recovery")
    C.clearInputs(receiver)
    assert(not C.input(receiver, getTimestampMs()) and #input.links == 0, "Native clear-input recovery left stale links")
    assert(C.link(button, receiver, true), "Native retired-input fixture link failed")
    C.removed(button)
    C.publish(receiver)
    assert(C.input(receiver, getTimestampMs()) and #receiver:getModData().OMHTTControl.inputs == 1,
        "Native unload must retain a named inactive connection")
    C.bind(button)
    C.retire(button)
    C.removed(button)
    assert(not C.input(receiver, getTimestampMs()) and #receiver:getModData().OMHTTControl.inputs == 0,
        "Native retirement left an invisible power-controlling connection")
    print("[OMHTT-C344] native input-unload=retained retired-input=disconnected public-authority=matched")
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
    controller:setHealth(37)
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
    assert(C.state(rebuilt).targeting == "OtherFactions", "Redeployment lost private targeting default")
    assert(targeting.resolve({kind = "Turret", controller = host.id}, C.state(rebuilt)) == "OtherFactions",
        "Redeployed Controller did not restore inherited targeting")
    assert(rebuilt:getHealth() == 37, "Controller condition trusted forged presentation or healed on redeploy")
    assert(rebuilt:getContainer():contains(first) and rebuilt:getContainer():getItems():size() == 251, "Redeployment changed exact stockpile")
    assert(expansion.item(rebuilt) == kit and expansion.capacity(rebuilt) == 500, "Controller pickup/redeploy lost exact installed kit")
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
    local fixture = ModData.getOrCreate("OMHTTNativeControls")
    fixture.label = input.name
    fixture.displayName, fixture.displayNumber = input.displayName, input.displayNumber
    fixture.plate, fixture.receiver = input.id, output.id
    fixture.retired = C.records().records[button:getModData().OMHTTControl.id].id
    C.records().records[fixture.retired].links = {output.id}
    print("[OMHTT-Controls] native devices=3 ownership=private read=public replay=blocked remote=power-scoped plate=recovery-safe backup=48h heavy=exact capacities=30")
    require("OMHTT/ControlPower").trigger = triggerPower
end
