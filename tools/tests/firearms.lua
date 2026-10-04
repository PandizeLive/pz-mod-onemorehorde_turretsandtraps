local G = require("OMHTT/Firearms")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local oldSettings = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {Enabled = true, PotatoTurret = true, PotatoRequirePower = false, FirearmAccuracyMultiplier = 3}
local definitions = {{"Base.Pistol", "Base.Bullets9mm", 15, false},
    {"Base.Shotgun", "Base.ShotgunShells", 6, true}, {"Base.HuntingRifle", "Base.308Bullets", 4, true}}
local function item(fullType)
    local value = {fullType = fullType, condition = 10, data = {}, ammo = 0, chamber = false, spent = false, clip = true}
    function value:getID() return 9001 end
    function value:getFullType() return self.fullType end
    function value:getDisplayName() return self.fullType end
    function value:getCondition() return self.condition end
    function value:setCondition(n) self.condition = n end
    function value:getActualWeight() return 1 end
    function value:getModData() return self.data end
    function value:getContainer() return self.container end
    function value:getCurrentAmmoCount() return self.ammo end
    function value:setCurrentAmmoCount(n) self.ammo = n end
    function value:isRoundChambered() return self.chamber end
    function value:setRoundChambered(n) self.chamber = n end
    function value:setSpentRoundChambered(n) self.spent = n end
    function value:haveChamber() return true end
    function value:isContainsClip() return self.clip end
    function value:isJammed() return self.jammed == true end
    function value:getMinDamage() return 0.6 end
    function value:getMaxDamage() return 1 end
    function value:getMaxRange() return 15 end
    function value:getRecoilDelay() return 12 end
    function value:getFireMode() return "Single" end
    function value:getCyclicRateMultiplier() return 0 end
    function value:getMinSightRange() return 2 end
    function value:getMaxSightRange() return 10 end
    function value:getCriticalChance() return 20 end
    function value:getCriticalDamageMultiplier() return 4 end
    function value:getHitChance() return 50 end
    function value:getAimingPerkHitChanceModifier() return 4 end
    function value:getConditionLowerChance() return 0 end
    function value:getSoundRadius() return 100 end
    function value:getSoundVolume() return 30 end
    function value:getSwingSound() return "M9Shoot" end
    function value:getProjectileCount() return 1 end
    function value:isTwoHandWeapon() return false end
    function value:getFireModePossibilities() return nil end
    return value
end
local function container()
    local value = {items = {}}
    function value:getType() return T.CONTAINER end
    function value:getContainingItem() return nil end
    function value:getItems()
        return {size = function() return #value.items end, get = function(self, index) return value.items[index + 1] end}
    end
    function value:contains(candidate)
        for i = 1, #self.items do if self.items[i] == candidate then return true end end
        return false
    end
    function value:AddItem(candidate) self.items[#self.items + 1] = candidate; candidate.container = self end
    function value:Remove(candidate)
        for i = #self.items, 1, -1 do if self.items[i] == candidate then table.remove(self.items, i) end end
        candidate.container = nil
    end
    return value
end
local generic = item("ModExample.ServicePistol")
generic.kind = "HandWeapon"
function generic:isRanged() return true end
function generic:getAmmoType() return {getItemKey = function() return "ModExample.Round" end} end
function generic:getAmmoPerShoot() return 1 end
function generic:getMaxAmmo() return 8 end
function generic:getWeaponReloadType() return "handgun" end
function generic:getStaticModel() return nil end
check(G.profile(generic) and G.AMMO["ModExample.Round"], "Unlisted conventional modded firearm derives profile and ammunition")
local multi = item("ModExample.MultiAmmoLauncher")
multi.kind = "HandWeapon"
multi.isRanged, multi.getAmmoType, multi.getMaxAmmo = generic.isRanged, generic.getAmmoType, generic.getMaxAmmo
function multi:getAmmoPerShoot() return 2 end
check(not G.profile(multi), "Unsupported multiple-round mechanism is rejected instead of losing ammo")
local Stats = require("OMHTT/TurretStats")
function generic:getFireMode() return "Auto" end
function generic:getCyclicRateMultiplier() return 1 end
function generic:isRackAfterShoot() return false end
local auto = Stats.resolve({head = generic, active = {}})
check(math.abs(auto.cooldown - 1000 / 3 / 1.5 / .75) < .001, "Automatic cadence uses clip/speed rather than recoil delay")
SandboxVars.OMHTurretsTraps.FirearmRateMultiplier = 1
local full = Stats.resolve({head = generic, active = {}})
check(math.abs(auto.cooldown * .75 - full.cooldown) < .001, "Global rate scales proportionally")
function generic:getCyclicRateMultiplier() return 2 end
check(math.abs(Stats.resolve({head = generic, active = {}}).cooldown * 2 - full.cooldown) < .001, "Modded cyclic multiplier preserves weapon differentiation")
function generic:getCyclicRateMultiplier() return 0 end
check(math.abs(Stats.resolve({head = generic, active = {}}).cooldown - full.cooldown) < .001, "Unset cyclic multiplier has native fallback")
SandboxVars.OMHTurretsTraps.FirearmRateMultiplier = nil
local Accuracy = require("OMHTT/FirearmAccuracy")
check(Accuracy.chance(generic, {accuracy = 0}, .5, false) == 0, "Disabled accuracy stays disabled at point blank")
check(Accuracy.chance(generic, {accuracy = 50, farAccuracy = 40, range = 30}, 6, false) > Accuracy.chance(generic, {accuracy = 50, farAccuracy = 40, range = 30}, 30, false), "Native sight band beats long-distance penalty")
G.PROFILES[generic.fullType] = nil
local specimens = {}
for n = 1, #definitions do
    local definition = definitions[n]
    local gun, storage = item(definition[1]), container()
    function gun:getAmmoType() return {getItemKey = function() return definition[2] end} end
    function gun:getMaxAmmo() return definition[3] end
    function gun:getMaxRange() return ({15, 12, 40})[n] end
    function gun:getCriticalChance() return ({20, 70, 30})[n] end
    function gun:getCriticalDamageMultiplier() return ({4, 12, 4})[n] end
    function gun:getMagazineType() if definition[1] == "Base.Pistol" then return "Base.9mmClip" end end
    function gun:isRackAfterShoot() return definition[4] end
    function gun:getRecoilDelay()
        local recoil = {12, 30, 23}
        return recoil[n]
    end
    SandboxVars.OMHTurretsTraps.FirearmAmmoCapacity = 1
    gun.ammo = 2
    check(not T.accept(storage, gun), "Loaded gun cannot exceed configured ammo capacity")
    gun.ammo = 0
    SandboxVars.OMHTurretsTraps.FirearmAmmoCapacity = nil
    check(T.accept(storage, gun), "Supported empty gun mounts")
    storage:AddItem(gun)
    check(not T.accept(storage, item("Base.Potato")), "Mounted gun rejects potatoes")
    check(not T.accept(storage, item(T.HEAD)), "Gun occupies the existing head slot")
    for i = 1, 40 do storage:AddItem(item(definition[2])) end
    local summary, now = T.contents(storage), testMillis
    local config = T.cycleConfig(summary)
    check(config.range == ({15, 12, 40})[n], "Each supported firearm uses its own native range")
    check(config.critChance == ({20, 70, 30})[n] and config.critMultiplier == ({4, 12, 4})[n], "Native critical chance and multiplier retained")
    local modded = require("OMHTT/TurretStats").resolve({head = gun, active = {Critical = 2, Accuracy = 2}})
    check(modded.critChance == config.critChance + 10 and modded.critMultiplier == config.critMultiplier, "Critical stacks add percentage points without multiplying critical damage")
    check(modded.accuracy <= 100 and modded.accuracy >= config.accuracy, "Accuracy stacks respect 100 percent")
    local expectedCooldown = {400 / .75, 1000 / .75, 1200 / .75}
    check(math.abs(config.cooldown - expectedCooldown[n]) < .001, "Native recoil and manual cycling determine per-weapon cadence")
    if n == 1 then
        check(math.abs(config.rack - 1600) < .001 and math.abs(config.cooldown - 400 / .75) < .001, "Pistol retains initial racking without charging it per shot")
    end
    check(summary.ammo == 40 and summary.reserve == 40 and config.magazine == definition[3], "Profile counts exact ammunition")
    local _, status = G.update(summary, config, now, false)
    check(status == "Reloading" and gun.ammo == 0, "Read-only Manage does not load ammo")
    G.update(summary, config, now, true)
    G.cancelLoading(gun)
    check(gun.ammo == 0 and T.contents(storage).ammo == 40, "Cancelled loading spends nothing")
    G.update(T.contents(storage), config, now + 10000, true)
    local cycle
    cycle, status = G.update(T.contents(storage), config, now + 30000, true)
    check(status == "Racking" and T.contents(storage).ammo == 40, "Magazine loading conserves rounds; chamber waits for cycle")
    cycle, status = G.update(T.contents(storage), config, now + 35000, true)
    check(status == "Ready" and gun.chamber and gun.ammo == definition[3] - 1, "Racking moves exactly one magazine round into chamber")
    check(G.consume(T.contents(storage), config, now + 35000), "Ready gun fires")
    check(T.contents(storage).ammo == 39, "Firing loses exactly one round")
    check(not G.consume(T.contents(storage), config, now + 35000), "Same tick cannot fire again")
    storage:AddItem(item(T.TYPES.Autoloader))
    local boosted = T.cycleConfig(T.contents(storage))
    check(boosted.reload == 0 and boosted.cooldown > 0 and boosted.rack > 0, "Autoloader preserves shot and pump/bolt cadence")
    local rapid = item(T.TYPES.RapidFire)
    local reloadA, reloadB = item(T.TYPES.Reload), item(T.TYPES.Reload)
    storage:AddItem(rapid); storage:AddItem(reloadA); storage:AddItem(reloadB)
    check(T.cycleConfig(T.contents(storage)).cooldown < config.cooldown, "Rapid-Fire affects firearm cadence")
    for i = #storage.items, 1, -1 do
        local candidate = storage.items[i]
        if candidate:getFullType() == T.TYPES.Autoloader then storage:Remove(candidate) end
    end
    check(T.cycleConfig(T.contents(storage)).reload < config.reload, "Reload stacks on firearm loading")
    check(T.canRemove(storage, gun), "Head swap leaves reserve stored")
    local shots = 1
    for step = 1, 100 do
        now = now + 40000
        local current = T.contents(storage)
        local effective = T.cycleConfig(current)
        local _, ready = G.update(current, effective, now, true)
        if ready == "Ready" and G.consume(T.contents(storage), effective, now) then shots = shots + 1 end
        check(T.contents(storage).ammo + shots == 40, "Reload/fire loop conserves ammo without duplicate chamber rounds")
    end
    check(shots == 40 and G.loaded(gun) == 0, "Finite reserve produces exactly forty shots")
    gun.ammo, gun.chamber = 2, true
    check(T.canRemove(storage, gun), "Loaded gun can be recovered after unloading reserve")
    gun.jammed = true
    local _, jammed = T.cycle(T.contents(storage), now)
    check(jammed == "Jammed" and G.loaded(gun) == 3, "Existing jam blocks firing without deleting ammunition")
    gun.jammed = false
    if gun:getMagazineType() then
        gun.clip = false
        local _, missing = T.cycle(T.contents(storage), now)
        check(missing == "NoMagazine", "Pistol cannot manufacture a magazine")
        gun.clip = true
    end
    gun.data.OMHTTGunCycle = nil
    storage:AddItem(item(T.TYPES.Firing)); storage:AddItem(item(T.TYPES.MotionDetection))
    specimens[#specimens + 1] = {gun = gun, storage = storage}
end
local pair = specimens[1]
local origin = makeSquare(700, 700, 0)
local destination = makeSquare(702, 700, 0)
makeSquare(701, 700, 0)
local object = {data = {OMHTTTurret = {schema = 1, kind = "potato", id = "gun-integration", facing = 0,
    baseFacing = 0, aimDegrees = 0, nextShot = 0, shots = 0}}}
function object:hasModData() return true end
function object:getModData() return self.data end
function object:getSquare() return origin end
function object:getObjectIndex() return 0 end
function object:getHealth() return 100 end
function object:getContainer() return pair.storage end
local victim = makeZombie(destination, 5)
local oldHybrid, oldSound = T.hybrid, addSound
T.hybrid = function() return true end
local noise = 0
addSound = function() noise = noise + 1 end
check(W.fire(nil, object, victim) == "Fired", "Gun integrates with automated W.fire")
check(victim.health < 5 and G.loaded(pair.gun) == 2 and noise == 1, "Gun spends one round, deals damage and makes world noise")
check(#require("OMHTT/PrototypeCombat").pending == 0, "Firearm does not launch potato projectiles")
local prior = G.loaded(pair.gun)
check(W.fire(nil, object, victim) == "Cooling" and G.loaded(pair.gun) == prior, "Gun integration enforces cooldown before spending")
SandboxVars.OMHTurretsTraps.FirearmAccuracyMultiplier = 0
check(T.cycleConfig(T.contents(pair.storage)).accuracy == 0, "Zero accuracy multiplier allows no hits")
SandboxVars.OMHTurretsTraps.FirearmTurrets = false
local _, disabled = G.update(T.contents(pair.storage), T.cycleConfig(T.contents(pair.storage)), testMillis + 100000, true)
check(disabled == "Disabled" and G.loaded(pair.gun) == prior, "Disabled gun cannot feed or fire")
-- The timed action owns reach/lifecycle; the shared firearm service owns rounds.
SandboxVars.OMHTurretsTraps.FirearmTurrets = true
local Action = require("OMHTT/TurretMagazineAction")
local gun = pair.gun
function gun:setContainsClip(value) self.clip = value end
local carried = container()
function carried:isInCharacterInventory() return true end
local operator = {getInventory = function() return carried end, removeFromHands = function() end}
local oldNear, oldRefresh, oldStop = W.near, W.refresh, ISBaseTimedAction.stop
local near = true
W.near = function() return near end
W.refresh = function() end
ISBaseTimedAction.stop = function() end
local magazine = item("Base.9mmClip")
function magazine:isFavorite() return false end
magazine.ammo = 7
carried:AddItem(magazine)
gun.clip, gun.ammo, gun.chamber = false, 0, true
local action = Action:new(operator, object, magazine)
check(action.maxTime == 75 and action.stopOnWalk and action.stopOnRun, "Magazine service uses native action duration and movement interruption")
check(not action:complete() and carried:contains(magazine), "Unstarted action cannot mutate inventory")
action = Action:new(operator, object, magazine)
action.action = {setActionAnim = function() end, setAnimVariable = function() end, setOverrideHandModels = function() end}
-- Native animation host is absent from headless UI fixtures.
action.setActionAnim = function() end
action.setAnimVariable = function() end
action.setOverrideHandModels = function() end
action:start()
check(not T.canRemove(pair.storage, gun), "Started action locks only its gun")
near = false
check(not action:complete() and carried:contains(magazine) and G.servicing[gun] == nil, "Leaving reach rejects commit and releases gun")
near = true
action = Action:new(operator, object, magazine)
action.started, G.servicing[gun] = true, action
action:stop()
check(not action:complete() and carried:contains(magazine) and G.servicing[gun] == nil, "Interrupted magazine action spends nothing")
action = Action:new(operator, object, magazine)
action.started, G.servicing[gun] = true, action
check(action:complete() and G.loaded(gun) == 8 and not carried:contains(magazine), "Completed insertion conserves rounds and chamber")
check(not action:complete() and G.loaded(gun) == 8, "Duplicate complete cannot insert twice")
W.near, W.refresh, ISBaseTimedAction.stop = oldNear, oldRefresh, oldStop
T.hybrid, addSound = oldHybrid, oldSound
SandboxVars.OMHTurretsTraps = oldSettings
