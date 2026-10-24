local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local A = require("OMHTT/TurretAuthority")
local Action = require("OMHTT/TurretPickupAction")

return function(player)
    player:getKnownRecipes():add("OMHTTMountFirearm")
    assert(isServer() and not isClient(), "Authority probe must run in actual dedicated-server mode")
    local source = player:getInventory():AddItem(T.BASE)
    T.configure(source:getInventory())
    local potato = source:getInventory():AddItem("Base.Potato")
    local battery = source:getInventory():AddItem("Base.CarBattery1")
    battery:setCurrentUsesFloat(.37)
    source:getModData().OMHTTTurret = {schema = 1, shots = 999999, maxHealth = 999999}
    local consumed = ArrayList.new()
    consumed:add(source)
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    local square = IsoGridSquare.new(getCell(), nil, 8, 8, 0)
    W.squareLoaded(square)
    local object = IsoThumpable.new(getCell(), square, "omhtt_turret_01_16", false)
    square:getObjects():add(object)
    square:getSpecialObjects():add(object)
    GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
    W.onCreate({thumpable = object, character = player, facing = "e",
        craftRecipeData = {getAllConsumedItems = function() return consumed end}})
    assert(not player:getInventory():contains(source) and source:getInventory():getItems():isEmpty(), "Server deployment did not consume exact base")
    assert(object:getContainer():contains(potato) and object:getContainer():contains(battery), "Server deployment lost exact native contents")
    assert(T.state(object).shots == 0 and T.state(object).maxHealth ~= 999999, "Public packed state became authority")
    local id = T.state(object).id
    object:getModData().OMHTTTurret = {schema = 1, id = "forged", shots = 999999}
    assert(T.state(object).id == id and T.state(object).shots == 0, "Public object state became authority")
    player:setX(8.5)
    player:setY(8.5)
    player:setZ(0)
    player:setCurrent(square)
    object:setHealth(37)
    player:getInventory():AddItem("Base.ScrapMetal")
    player:getInventory():AddItem("Base.Wrench")
    local repair = Action:new(player, object, "Repair", id)
    assert(repair:getDuration() == 500 and repair:complete(), "Native server repair failed")
    assert(object:getHealth() == object:getMaxHealth() and not repair:complete(), "Native repair replay was accepted")
    local previousAngle, previousPower = T.state(object).aimDegrees, T.state(object).powered
    T.state(object).powered = false
    assert(W.setFacing(object, 123.45), "Native facing operation rejected")
    assert(T.state(object).facingDegrees == 123.45 and T.state(object).aimDegrees == previousAngle,
        "Native OFF turret changed physical heading")
    assert(object:getModData().OMHTTTurret.facingDegrees == 123.45, "Authoritative facing did not reach published snapshot")
    assert(require("OMHTT/TurretModules").profile(T.state(object), T.contents(object:getContainer())).heading == 123.45,
        "Native firing sector ignored Controller heading")
    print("[OMHTT-C308] native-facing angle=123.45 powerOff=stationary publication=authoritative")
    T.state(object).powered = previousPower
    W.refresh(object)
    local pickup = Action:new(player, object, "Pickup", id)
    local firstModule=object:getContainer():AddItem(T.TYPES.RapidFire)
    local secondModule=object:getContainer():AddItem(T.TYPES.Reload)
    local inactiveModule=object:getContainer():AddItem(T.TYPES.Siphon)
    T.rememberModules(object:getContainer(),{secondModule,firstModule,inactiveModule})
    T.state(object).ammoOrders = {[T.HEAD] = "Base.SweetPotato|Base.Potato", ["@potato"] = "Base.Potato|Base.SweetPotato"}
    A.publish(object)
    assert(object:getModData().OMHTTTurret.ammoOrders[T.HEAD] == "Base.SweetPotato|Base.Potato", "Native publication dropped saved load order")
    assert(pickup:getDuration() == 250 and pickup:complete(), "Native server pickup failed")
    assert(T.state(object) == nil and not pickup:complete(), "Native pickup replay was accepted")
    local packed = potato:getContainer():getContainingItem()
    assert(packed and packed:getFullType() == T.BASE and player:getInventory():contains(packed), "Recovered native container missing")
    assert(packed:getInventory():contains(battery) and math.abs(battery:getCurrentUsesFloat() - .37) < .000001, "Native battery identity or charge changed")
    assert(A.packed(packed) and A.packed(packed).shots == 0, "Trusted recovered state missing")
    assert(T.moduleOrder(packed:getInventory())[1]==secondModule and not T.contents(packed:getInventory()).active.Siphon,
        "Native packing changed activation priority or enabled an inactive module")
    assert(square:getWorldObjects():size() == 0, "Pickup also produced destruction salvage")
    packed:getModData().OMHTTTurret = {schema = 1, shots = 777777, maxHealth = 777777}
    local nextConsumed = ArrayList.new()
    nextConsumed:add(packed)
    local rebuilt = IsoThumpable.new(getCell(), square, "omhtt_turret_01_16", false)
    square:getObjects():add(rebuilt)
    square:getSpecialObjects():add(rebuilt)
    GameEntityFactory.CreateIsoObjectEntity(rebuilt, info:getScript():getParent(), true)
    W.onCreate({thumpable = rebuilt, character = player, facing = "n",
        craftRecipeData = {getAllConsumedItems = function() return nextConsumed end}})
    assert(T.state(rebuilt).shots == 0 and T.state(rebuilt).maxHealth == 100 and T.state(rebuilt).facing == 4, "Redeployment imported forged packed controls")
    assert(T.state(rebuilt).facingDegrees == nil and not T.state(rebuilt).facingPending,
        "New placement must follow its selected direction rather than old Controller facing")
    assert(rebuilt:getContainer():contains(battery) and A.packed(packed) == nil, "Redeployment failed to consume trusted packed state")
    assert(T.state(rebuilt).ammoOrders[T.HEAD] == "Base.SweetPotato|Base.Potato", "Native pickup/redeploy dropped saved load order")
    assert(T.state(rebuilt).ammoOrders["@potato"] == "Base.Potato|Base.SweetPotato", "Native pickup/redeploy dropped platform order")
    assert(T.moduleOrder(rebuilt:getContainer())[1]==secondModule and not T.contents(rebuilt:getContainer()).active.Siphon,
        "Native redeploy lost exact stored priority or capacity filtering")
    rebuilt:getContainer():Remove(firstModule);rebuilt:getContainer():Remove(secondModule);rebuilt:getContainer():Remove(inactiveModule)
    T.rememberModules(rebuilt:getContainer())
    print("[OMHTT-C444] native activation-priority pickup=preserved packed=inactive redeploy=preserved")
    local Transfer = require("OMHTT/TurretTransferAction")
    local Magazine = require("OMHTT/TurretMagazineAction")
    local Control = require("OMHTT/TurretControlAction")
    local currentId = T.state(rebuilt).id
    assert(Transfer:new(player, rebuilt, potato, false, currentId):complete(), "Native exact head removal failed")
    local gun = player:getInventory():AddItem("Base.Pistol")
    gun:setContainsClip(false)
    gun:setCurrentAmmoCount(0)
    player:setPrimaryHandItem(gun)
    assert(Transfer:new(player, rebuilt, gun, true, currentId):complete(), "Native exact firearm installation failed")
    assert(player:getPrimaryHandItem() == nil, "Installed firearm stayed equipped on the player")
    local magazine = player:getInventory():AddItem(gun:getMagazineType())
    magazine:setCurrentAmmoCount(7)
    assert(Magazine:new(player, rebuilt, magazine, gun, currentId):complete(), "Server magazine insertion failed")
    assert(gun:isContainsClip() and gun:getCurrentAmmoCount() == 7 and not player:getInventory():contains(magazine), "Magazine rounds were not conserved")
    local eject = Magazine:new(player, rebuilt, nil, gun, currentId)
    assert(eject:complete() and not eject:complete() and not gun:isContainsClip() and gun:getCurrentAmmoCount() == 0, "Server ejection replay or round accounting failed")
    local ammoType = gun:getAmmoType():getItemKey()
    local orderValue = {head = gun:getID(), previous = "", order = ammoType}
    local orderAction = Control:new(player, rebuilt, currentId, "AmmoOrder", orderValue)
    assert(orderAction:complete() and not orderAction:complete(), "Native Load Order action did not commit once")
    assert(T.state(rebuilt).ammoOrders[gun:getFullType()] == ammoType, "Native Load Order did not persist per head")
    assert(not Control:new(player, rebuilt, currentId, "AmmoOrder", orderValue):isValid(), "Native stale Load Order request accepted")
    local platformValue = {platform="bomb", previous="", order="Base.PipeBomb|Base.OMHTTAmmoMakeshiftBomb"}
    local platformAction = Control:new(player,rebuilt,currentId,"AmmoPlatformOrder",platformValue)
    local network = NetTimedAction.new()
    network:set(player,platformAction)
    assert(platformAction:complete() and not platformAction:complete(),"Native platform order must commit once")
    assert(rebuilt:getModData().OMHTTTurret.ammoOrders["@bomb"]==platformValue.order,"Native platform order not published")
    assert(not Control:new(player,rebuilt,currentId,"AmmoPlatformOrder",platformValue):isValid(),"Stale native platform request accepted")
    local invalid={platform="bomb",previous=platformValue.order,order=ammoType}
    assert(not Control:new(player,rebuilt,currentId,"AmmoPlatformOrder",invalid):isValid(),"Cross-platform native request accepted")
    print("[OMHTT-Controls] native-platform-order other-head=valid stale=rejected cross-family=rejected publication=retained pickup=retained")
    local rounds, ids = {}, {}
    for i = 1, 20 do
        rounds[i] = player:getInventory():AddItem(ammoType)
        ids[i] = rounds[i]:getID()
    end
    local batch = Transfer:new(player, rebuilt, rounds[1], true, currentId, ids)
    assert(batch:complete() and not batch:complete(), "Native bounded batch failed or replayed")
    assert(T.contents(rebuilt:getContainer()).reserve == 20, "Native batch did not preserve all twenty rounds")
    assert(Transfer:new(player, rebuilt, rounds[1], false, currentId, ids):complete(), "Native bounded batch removal failed")
    assert(T.contents(rebuilt:getContainer()).reserve == 0, "Native outgoing batch left rounds behind")
    assert(Control:new(player, rebuilt, currentId, "Range", 3):complete() and T.state(rebuilt).engagementRange == 3, "Native server control action failed")
    local G = require("OMHTT/Firearms")
    local Feed = require("OMHTT/FirearmFeed")
    local ItemState = require("OMHTT/TurretItemState")
    gun:getModData().OMHTTFeedRounds = 99999
    gun:getModData().OMHTTGunCycle = {schema = 1, nextShot = -999, loaded = 99999}
    assert(Feed.count(gun) == 0 and G.state(gun).loaded ~= 99999, "Public head metadata became server feed authority")
    local empty = player:getInventory():AddItem(gun:getMagazineType())
    empty:setCurrentAmmoCount(0)
    assert(Magazine:new(player, rebuilt, empty, gun, currentId):complete(), "Native empty magazine insertion failed")
    for i = 1, 3 do
        local round = player:getInventory():AddItem(ammoType)
        assert(Transfer:new(player, rebuilt, round, true, currentId):complete(), "Native feed ammunition insertion failed")
    end
    local contents = T.contents(rebuilt:getContainer())
    local stats = T.cycleConfig(contents)
    local clock = require("OMHTT/TurretClock").now()
    local cycle, status = G.update(contents, stats, clock, true)
    assert(status == "Reloading" and G.loaded(gun) == 0, "Reload consumed ammunition before its deadline: " .. tostring(status) .. "/" .. tostring(G.loaded(gun)))
    cycle, status = G.update(contents, stats, clock + stats.reload + 1, true)
    cycle, status = G.update(contents, stats, clock + stats.reload + stats.rack + 2, true)
    assert(status == "Ready" and G.loaded(gun) == 3 and contents.reserve == 0, "Authoritative native reload lost or duplicated rounds")
    ItemState.publish(gun, player)
    assert(gun:getModData().OMHTTGunCycle ~= G.state(gun), "Published cycle aliases private authority")
    assert(Control:new(player, rebuilt, currentId, "Power", false):complete() and not T.isOn(T.state(rebuilt)), "Native power-off action failed")
    assert(Control:new(player, rebuilt, currentId, "Power", true):complete() and T.isOn(T.state(rebuilt)), "Native power-on action failed")
    print("[OMHTT-Smoke] native-server-feed reload=3-conserved publicMetadata=ignored power=server fields=recipient-native clients=0")
    local target = IsoZombie.new(getCell())
    target:setCurrent(square)
    target:setX(8.5)
    target:setY(8.25)
    target:setZ(0)
    target:setHealth(100)
    local Clock = require("OMHTT/TurretClock")
    local oldNow, oldRandom = Clock.now, ZombRand
    Clock.now = function() return clock + stats.reload + stats.rack + stats.cooldown + 1000 end
    ZombRand = function() return 0 end
    T.state(rebuilt).aimDegrees = require("OMHTT/TurretAim").angle(rebuilt, target)
    local Battery = require("OMHTT/TurretBattery")
    local charge = Battery.charge(battery)
    local supply = W.power(rebuilt, T.contents(rebuilt:getContainer()), stats)
    -- The native fixture square is not in the mapped world; provide only its lookup.
    local oldCell, nativeCell = getCell, getCell()
    getCell = function() return {getGridSquare = function(_, x, y, z)
        if x == 8 and y == 8 and z == 0 then return square end
        return nativeCell:getGridSquare(x, y, z)
    end} end
    local fired = W.fire(player, rebuilt, target)
    getCell = oldCell
    assert(fired == "Fired", "Production dedicated-server firearm dispatch failed: " .. tostring(fired))
    assert(target:getHealth() < 100 and G.loaded(gun) == 2
        and (supply.kind ~= "battery" or math.abs(Battery.charge(battery) - charge + supply.cost) < .00000001),
        "Production fire state health=" .. tostring(target:getHealth()) .. " loaded=" .. tostring(G.loaded(gun))
            .. " charge=" .. tostring(battery:getCurrentUsesFloat()) .. " before=" .. tostring(charge)
            .. " power=" .. tostring(supply.kind) .. " cost=" .. tostring(supply.cost))
    W.publishRuntime(rebuilt, T.state(rebuilt), T.contents(rebuilt:getContainer()), Clock.now())
    local remainder = ItemState.get(battery, "battery").debt
    battery:getModData().OMHTTBatteryDrain.debt = -999
    assert(math.abs(ItemState.get(battery, "battery").debt - remainder) < .00000001,
        "Forged battery view changed private fractional accounting")
    ItemState.publish(battery, player)
    local firing = player:getInventory():AddItem(T.TYPES.Firing)
    assert(Transfer:new(player, rebuilt, firing, true, currentId):complete(), "Native Firing module install failed")
    Clock.now = function() return clock + stats.reload + stats.rack + stats.cooldown * 3 + 2000 end
    local beforeForward = G.loaded(gun)
    assert(W.fire(player, rebuilt) == "Fired" and G.loaded(gun) == beforeForward - 1,
        "Native Firing-only manual dispatch must shoot without a target")
    assert(W.fire(player, rebuilt) == "Cooling", "Repeated command must respect native firing cooldown")
    assert(Transfer:new(player, rebuilt, firing, false, currentId):complete(), "Native Firing module removal failed")
    print("[OMHTT-C262] native-forward-fire target=none ammo=one cooldown=guarded clients=0")
    Clock.now, ZombRand = oldNow, oldRandom
    target:setHealth(0)
    print("[OMHTT-Smoke] native-server-production-fire damage=confirmed ammo=one power=" .. supply.kind .. " presentation=published clients=0")
    assert(Transfer:new(player, rebuilt, gun, false, currentId):complete(), "Native firearm removal failed")
    local head = player:getInventory():AddItem(T.HEAD)
    assert(Transfer:new(player, rebuilt, head, true, currentId):complete(), "Native potato head install failed")
    assert(Transfer:new(player, rebuilt, potato, true, currentId):complete(), "Native potato ammunition reinstall failed")
    print("[OMHTT-Smoke] native-server-manage transfers=exact batch=20 magazines=conserved controls=validated clients=0")
    rebuilt:destroy()
    assert(T.state(rebuilt) == nil and rebuilt:getContainer():getItems():isEmpty(), "Destruction did not retire native server state")
    assert(square:getWorldObjects():size() == 5, "Destruction must salvage exact contents and two scrap only")
    W.removed(rebuilt)
    assert(square:getWorldObjects():size() == 5, "Repeated destruction duplicated salvage")
    if getActivatedMods():contains("OneMoreHorde_Traps") then
        require("OMHTT/NativeTrapServices")(player)
    end
    print("[OMHTT-Smoke] native-server-turret deploy=exact publicState=ignored repair=server pickup=exact redeploy=trusted salvage=once replay=blocked clients=none")
end
