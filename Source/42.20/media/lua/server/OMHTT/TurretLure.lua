if isClient() then return end
local T = require("OMHTT/Turret")
local Clock = require("OMHTT/TurretClock")
local Horde = require("OMHTT/DefenseHorde")
local Effects = require("OMHTT/DefenseEffects")
local L = {}

---@param object IsoObject Authoritative turret
---@param contents table Current components
---@param now number Active milliseconds
---@return boolean emitted
function L.pulse(object, contents, now)
    local state = T.state(object)
    if not state or not T.isOn(state) or not contents.active.Lure then return false end
    state.lureCycle = state.lureCycle or {}
    Clock.restore(state.lureCycle, now)
    if state.lureCycle.nextShot and now < state.lureCycle.nextShot then return false end
    local range = math.max(5, math.min(20, state.lureRange or 10))
    local stats = T.cycleConfig(contents)
    local fraction = range * range / 400
    local cost = .02 * fraction * stats.modulePower / stats.regulator
    local world = require("OMHTT/TurretWorld")
    local power = world.power(object, contents, {batteryPercent = cost,
        generatorFuel = .0001 * fraction * stats.modulePower / stats.regulator})
    if not power then return false end
    local square = object:getSquare()
    if not Horde.sound(object, square:getX(), square:getY(), square:getZ(), range, range) then return false end
    if power.kind == "battery" then
        require("OMHTT/TurretBattery").spend(power.battery, power.cost)
    elseif power.kind == "generator" then
        power.generator:setFuel(math.max(0, power.generator:getFuel() - power.cost))
        require("OMHTT/TurretPowerSync").changed(power.generator)
    end
    state.lureCycle.nextShot = now + 10000
    Effects.emit("Click", {sound = "OMHTTLure", x = square:getX() + .5,
        y = square:getY() + .5, z = square:getZ(), gain = range / 20, lureRange = range})
    return true
end

---@param object IsoObject Turret visited by the bounded feed scheduler
---@param contents table Component snapshot
---@param now number Active milliseconds
---@return nil
function L.update(object, contents, now)
    local state = T.state(object)
    if not state then return end
    state.lureCycle = state.lureCycle or {}
    Clock.restore(state.lureCycle, now)
    if not contents.active.Lure or not T.isOn(state) then
        state.lureRepeat = false
        return
    end
    if state.lureRepeat and (not state.lureCycle.nextShot or now >= state.lureCycle.nextShot) then
        if not L.pulse(object, contents, now) then
            state.lureCycle.nextShot = now + 10000
        end
    end
end

return L
