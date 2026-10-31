if isClient() then return end
local Actors = require("OMHTT/DefenseActors")
local Horde = require("OMHTT/DefenseHorde")
local T = require("OMHTT/Turret")
local Heads = require("OMHTT/TurretHeads")
local M = require("OMHTT/TurretModules")
local Clock = require("OMHTT/TurretClock")
local Conditional = require("OMHTT/TurretConditionalHit")
local Damage = require("OMHTT/Damage")
local Siphon = require("OMHTT/TurretSiphon")
local R = {}
local weapon
local parts

---@param entry table Motor owner
---@param before number Previous travel
---@param after number Current travel
---@param elapsed number Active milliseconds advanced
---@return nil
function R.record(entry, before, after, elapsed)
    local now = GameTime.getServerTimeMills()
    entry.timeline = entry.timeline or {}
    local history = entry.timeline
    history[#history+1] = {at=now, from=now-math.max(0,elapsed), before=before, after=after}
    while #history > 128 or (#history > 1 and history[1].at < now - 750) do
        table.remove(history, 1)
    end
end

---@param entry table Motor owner
---@param at number Synchronized observation time
---@return number? travel Confirmed motor position at that time
function R.travelAt(entry, at)
    local history = entry.timeline
    for i=#history,1,-1 do
        local sample=history[i]
        if at>=sample.from and at<=sample.at then
            local fraction=sample.at>sample.from and (at-sample.from)/(sample.at-sample.from) or 1
            return sample.before+(sample.after-sample.before)*fraction
        end
    end
end

---@param player IsoPlayer Operator
---@param object IsoObject Base
---@return string status
function R.start(player, object, signal)
    local W = require("OMHTT/TurretWorld")
    if (player and not W.near(player, object)) or (not player and not signal) then return "Unavailable" end
    local contents = W.contents(object)
    local stats = T.cycleConfig(contents)
    if not W.power(object, contents, stats) then return "NoPower" end
    local state = T.state(object)
    local auto = require("OMHTT/TurretAutomation").entries[object]
    if not player and contents.active.MotionDetection and not require("OMHTT/TurretStandby").step(object, contents, auto and auto.detectedTarget) then return "Waking" end
    local profile = M.profile(state, contents, false, stats)
    state.rotaryManual = Clock.now() + (profile.omni and 90 or profile.cone) * 1000 / stats.motorSpeed
    return "Fired"
end

---@param player IsoPlayer Contact victim
---@param blades boolean Cutting head
---@param now number Active milliseconds
---@return nil
function R.injure(player, blades, now, object)
    require("OMHTT/TurretPlayerHit").hit(player,
        {playerSource = require("OMHTT/ControlCombat").source(object)}, blades and "RotaryBlades" or "RotaryBat")
end

---@param entry table Active turret job
---@param actor IsoMovingObject Candidate
---@param job table Observed sweep
---@return nil
function R.contact(entry, actor, job)
    local zombie = instanceof(actor, "IsoZombie")
    local player = instanceof(actor, "IsoPlayer")
    if not zombie and not player then return end
    if zombie then
        local _, down = require("OMHTT/DefenseActorState").stance(actor)
        if down then return end
    elseif actor:isOnFloor() or actor:isKnockedDown() or actor:isRagdoll() then
        return
    end
    if zombie and not Horde.allowed(actor) then return end
    local origin = entry.object:getSquare()
    local hitX, hitY, z, current, observedAt = Actors.position(actor)
    if not current then return end
    local square = actor:getSquare()
    if isServer() then
        square = getCell():getGridSquare(math.floor(hitX), math.floor(hitY), z)
    end
    if not square or actor:isDead() or square:getZ() ~= origin:getZ() then return end
    local dx, dy = hitX - origin:getX() - .5, hitY - origin:getY() - .5
    if dx * dx + dy * dy > job.profile.range * job.profile.range then return end
    local bearing = math.deg(math.atan2(-dy, dx)) - job.profile.heading
    local relative = (bearing + 540) % 360 - 180
    if not job.profile.omni and math.abs(relative) > 45 and math.abs(relative) < 135 then return end
    if not require("OMHTT/PrototypeCombat").clearLane(origin, square, 2) then return end
    if require("OMHTT/ControlCombat").eligible(entry.object, actor) and M.inside(origin, actor, job.detection, hitX, hitY) then
        job.target = true
        job.targetActor = actor
    end
    if not T.isOn(T.state(entry.object)) then return end
    if Clock.now() - job.at > 150 then return end
    local before, after = job.before, job.after
    if observedAt and entry.timeline then
        entry.contactFrames = entry.contactFrames or setmetatable({}, {__mode="k"})
        local old = entry.contactFrames[actor]
        local owner = actor:getOwner()
        local outfit = require("OMHTT/DefenseCombatProtocol").outfit(actor:getPersistentOutfitID())
        local from = observedAt-100
        if old and old.owner==owner and old.outfit==outfit then
            if observedAt<=old.at then return end
            from=math.max(observedAt-250,old.at)
        end
        before,after=R.travelAt(entry,from),R.travelAt(entry,observedAt)
        if not before or not after then return end
        entry.contactFrames[actor]={at=observedAt,owner=owner,outfit=outfit}
    elseif not job.moving then
        return
    end
    local arm, pass = Heads.crossing(bearing, before, after, job.profile.omni, job.profile.cone)
    if not arm then return end
    if player then
        R.injure(actor, job.stats.headKind == "RotaryBlades", Clock.now(), entry.object)
        return
    end
    if entry.hits[arm][actor] == pass then return end
    local Proc = require("OMHTT/TurretProc")
    if not Proc.available(job.stats) then return end
    local proc = {playerSource = require("OMHTT/ControlCombat").source(entry.object), stats = job.stats, siphon = job.energy and job.energy[pass]}
    Proc.reserve(proc)
    entry.hits[arm][actor] = pass
    if not weapon then
        weapon = instanceItem("Base.Hammer")
    end
    local amount = job.stats.damage / 100
    if ZombRand(10000) < job.stats.critChance * 100 then
        amount = amount * job.stats.critMultiplier
    end
    amount = Conditional.damage(actor, amount, Conditional.snapshot(actor, job.stats))
    local source = T.state(entry.object).id
    local observation = {at = observedAt or GameTime.getServerTimeMills()}
    require("OMHTT/Diagnostics").defer("rotary-hit", {id=source, victim=actor:getOnlineID(), observedAt=observation.at,
        observationAgeMs=GameTime.getServerTimeMills()-observation.at, sweepAgeMs=Clock.now()-job.at,
        before=before, after=after, arm=arm, pass=pass, x=hitX, y=hitY}, "turrets")
    Damage.resolve(actor, amount, source, "rotary", function(lost)
        if lost > 0 then
            Proc.hit(actor, true, hitX, hitY, square:getZ(), {id = source}, nil, proc)
            Conditional.impact(actor, origin, {source = source, impactReady = true, stats = {impact = job.stats.knockdown}})
        end
        Proc.release(proc)
    end, observation)
    if getTimestampMs() >= (entry.soundAt or 0) then
        entry.soundAt = getTimestampMs() + 150
        local radius = require("OMHTT/TurretStats").hearingRadius(entry.rotaryHead, job.stats)
        if radius > 0 then
            Horde.sound(entry.object, origin:getX(), origin:getY(), origin:getZ(), radius, 10)
        end
        local sound = job.stats.headKind == "RotaryBlades" and "AxeSawBladeHit" or "BaseballBatHit"
        require("OMHTT/DefenseEffects").emit("Click", {sound = sound, x = origin:getX() + .5, y = origin:getY() + .5, z = origin:getZ(), gain = job.stats.hearingMultiplier})
    end
end

---@param entry table Scheduler entry
---@param deadline number Wall-clock budget
---@return boolean retained
function R.step(entry, deadline)
    local W = require("OMHTT/TurretWorld")
    local object, now = entry.object, Clock.now()
    local state, contents = T.state(object), W.contents(object)
    if entry.rotaryContents ~= contents then
        entry.rotaryContents, entry.rotaryStats = contents, T.cycleConfig(contents)
    end
    local stats = entry.rotaryStats
    local head = contents.head
    if not state or not stats.rotary then
        Siphon.stop(entry)
        return false
    end
    if entry.rotaryHead ~= head then
        Siphon.stop(entry)
        entry.rotaryHead, entry.rotaryAt, entry.rotaryJob = head, now, nil
        entry.gameAt = getGameTime():getWorldAgeHours()
        entry.travel, entry.checkedTravel, entry.hits = 0, 0, {setmetatable({}, {__mode = "k"}), setmetatable({}, {__mode = "k"})}
        entry.timeline,entry.contactFrames = {},nil
        state.rotaryMoving = false
    end
    local elapsed = math.max(0, now - entry.rotaryAt)
    entry.rotaryAt = now
    local gameNow = getGameTime():getWorldAgeHours()
    local gameHours = math.max(0, gameNow - entry.gameAt)
    entry.gameAt = gameNow
    local powered = W.valid(object) and T.isOn(state) and head:getCondition() > 0
    if entry.rotaryJob and now - entry.rotaryJob.at > 150 then
        entry.rotaryJob.moving = false
    end
    if not powered then
        Siphon.stop(entry)
        state.rotaryMoving, state.rotaryManual = false, nil
        require("OMHTT/TurretStandby").step(object, contents, nil)
        entry.rotaryJob, entry.hasTarget = nil, false
        entry.timeline,entry.contactFrames = {},nil
        return true
    end
    local profile = M.profile(state, contents, true, stats)
    local automatic = M.detects(state, contents) and contents.active.Firing and not require("OMHTT/ControlCycle").managed(object)
    local manual = state.rotaryManual and now < state.rotaryManual
    local standby = require("OMHTT/TurretStandby")
    local ready = standby.step(object, contents, entry.detectedTarget, state.rotaryMoving == true)
    local wants = manual or (automatic and entry.hasTarget and ready)
    local moving = state.rotaryMoving == true
    if moving and not wants and entry.stopAt == nil then
        local span = profile.omni and 180 or profile.cone
        entry.stopAt = (math.floor(entry.travel / span) + 1) * span
    elseif wants then
        entry.stopAt = nil
    end
    if wants and not moving and not manual and contents.active.FiringImprovised then
        if now < (entry.retryAt or 0) then
            wants = false
        elseif ZombRand(10000) < M.option("ImprovisedFiringFailure", 15, 0, 100) * 100 then
            wants = false
            entry.retryAt = now + stats.cooldown
            local square = object:getSquare()
            require("OMHTT/DefenseEffects").emit("Click", {sound = "OMHTTTriggerClick", x = square:getX() + .5, y = square:getY() + .5, z = square:getZ()})
        end
    end
    if wants and not moving then
        moving = true
        require("OMHTT/ControlAudio").emit(object, "rotary")
        elapsed, gameHours = 0, 0
    end
    local before = entry.travel
    if moving then
        local travel = elapsed / 1000 * stats.motorSpeed
        if entry.stopAt then
            travel = math.min(travel, math.max(0, entry.stopAt - before))
        end
        local seconds = travel / stats.motorSpeed
        local hours = gameHours
        if elapsed > 0 then
            hours = hours * math.min(1, seconds * 1000 / elapsed)
        end
        local cost = stats.motorPower * hours
        local transaction = {batteryPercent = cost, generatorFuel = stats.generatorFuel * seconds}
        local power = W.power(object, contents, transaction)
        if not power then
            Siphon.stop(entry)
            if contents.battery and require("OMHTT/TurretBattery").charge(contents.battery) > 0 then
                require("OMHTT/TurretBattery").spend(contents.battery, 1)
            end
            state.rotaryManual = nil
            moving = false
            entry.rotaryJob = nil
            entry.checkedTravel = entry.travel
        else
            local spent = 0
            if power.kind == "battery" then
                spent = require("OMHTT/TurretBattery").spend(power.battery, power.cost)
            elseif power.kind == "controller" then
                require("OMHTT/ControlPower").spend(power)
            elseif power.kind == "generator" then
                power.generator:setFuel(math.max(0, power.generator:getFuel() - power.cost))
                require("OMHTT/TurretPowerSync").changed(power.generator)
            end
            entry.travel = before + travel
            entry.siphonEnergy = Siphon.motor(entry, power, stats, spent, before, entry.travel, profile.omni, profile.cone)
        end
        if entry.stopAt and entry.travel >= entry.stopAt then
            moving = false
        end
    end
    state.rotaryMoving = moving
    R.record(entry,before,entry.travel,elapsed)
    state.rotaryTravel = entry.travel
    state.rotarySpeed, state.rotaryStopAt = stats.motorSpeed, entry.stopAt
    local angle = Heads.motion(entry.travel, profile.omni, profile.cone)
    state.aimDegrees = (profile.heading + angle + 360) % 360
    if not entry.rotaryJob then
        if not moving and not manual and (not automatic or now < (entry.rotaryScanAt or 0)) then return true end
        entry.rotaryJob = {at = now, x = -2, y = -2, index = 0, profile = M.profile(state, contents, false, stats), detection = profile, stats = stats,
            moving = entry.travel > entry.checkedTravel, before = math.max(entry.checkedTravel, entry.travel - stats.motorSpeed * .1), after = entry.travel,
            energy = entry.siphonEnergy}
        entry.checkedTravel = entry.travel
    end
    local job = entry.rotaryJob
    for i = 1, 48 do
        if getTimestampMs() >= deadline then return true end
        if job.y > 2 then
            if not moving then
                Siphon.stop(entry)
            end
            entry.hasTarget = job.target == true
            entry.detectedTarget = job.targetActor
            local interval = M.option("DetectionInterval", .25, .1, 5)
            if contents.active.MotionDetectionEnhanced then
                interval = math.min(interval, M.option("EnhancedDetectionInterval", .1, .05, 5))
            end
            entry.rotaryScanAt = now + interval * 1000
            entry.rotaryJob = nil
            return true
        end
        local origin = object:getSquare()
        local square = getCell():getGridSquare(origin:getX() + job.x, origin:getY() + job.y, origin:getZ())
        local objects = square and Actors.occupants(square, job)
        if objects and job.index < objects:size() then
            local actor = objects:get(job.index)
            job.index = job.index + 1
            R.contact(entry, actor, job)
        else
            job.index = 0
            job.x = job.x + 1
            if job.x > 2 then
                job.x, job.y = -2, job.y + 1
            end
        end
    end
    return true
end

return R
