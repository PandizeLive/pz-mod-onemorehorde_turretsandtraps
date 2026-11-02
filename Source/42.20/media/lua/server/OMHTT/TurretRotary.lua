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
local Contacts = require("OMHTT/TurretRotaryContacts")
local Active = require("OMHTT/ActiveTime")
local Sweep = require("OMHTT/TurretRotarySweep")
local Diagnostics = require("OMHTT/Diagnostics")
local Protocol = require("OMHTT/DefenseCombatProtocol")
local R = {}

---@param entry table Motor owner
---@param before number Previous travel
---@param after number Current travel
---@param elapsed number Active milliseconds advanced
---@return nil
---@param movingFraction number? Portion of this interval before reaching a stop
function R.record(entry, before, after, elapsed, movingFraction)
    local now = GameTime.getServerTimeMills()
    entry.timeline = entry.timeline or {}
    local history = entry.timeline
    local last = history[#history]
    if last and now <= last.at then return end
    -- Travel uses active game time; owner reports use synchronized wall time.
    local from = last and last.at or now - math.max(0, elapsed)
    local endpoint = now
    if movingFraction and movingFraction < 1 then
        endpoint = from + (now-from)*movingFraction
    end
    history[#history+1] = {at=endpoint, from=from, before=before, after=after, energy=entry.siphonEnergy}
    if endpoint < now then
        history[#history+1] = {at=now, from=endpoint, before=after, after=after}
    end
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

---@param actor IsoGameCharacter Candidate
---@param position table? Validated observation with stance
---@return boolean standing Alive and able to meet the rotating arms
function R.standing(actor, position)
    if actor:isDead() then return false end
    if instanceof(actor, "IsoZombie") then
        if not position and isServer() and actor:getOwner() then
            local node = Actors.nodes[actor]
            local report = node and node.report
            if report and Actors.confirmed(actor) then position = report.frame end
        end
        if position and position.ownerReport and type(position.down) == "boolean" then
            return not position.down and not position.prone
        end
        local _, down = require("OMHTT/DefenseActorState").stance(actor)
        return not down
    end
    return instanceof(actor, "IsoPlayer") and not actor:isOnFloor()
        and not actor:isKnockedDown() and not actor:isRagdoll()
end

---@param entry table Motor and outstanding intervals
---@param actor IsoGameCharacter Observed actor
local function forget(entry, actor)
    if entry.contactFrames then entry.contactFrames[actor] = nil end
    if entry.pendingContacts then entry.pendingContacts[actor] = nil end
end

---@param entry table Motor with synchronized history
---@param actor IsoGameCharacter Observed actor
---@param job table Contact profile and module stats
---@param old table Previous standing observation
---@param frame table Current standing observation
local function consume(entry, actor, job, old, frame)
    local origin = entry.object:getSquare()
    local startX, startY = old.x or frame.x, old.y or frame.y
    local dx, dy = frame.x-startX, frame.y-startY
    local duration = frame.at-old.at
    local history = entry.timeline
    local i = #history
    while i > 1 and history[i-1].at > old.at do i = i-1 end
    for n = i, #history do
        local motor = history[n]
        if motor.from >= frame.at then break end
        local a, b = math.max(old.at,motor.from), math.min(frame.at,motor.at)
        if b > a and motor.after > motor.before then
            local speed = (motor.after-motor.before)/(motor.at-motor.from)
            local first = motor.before+(a-motor.from)*speed
            local last = motor.before+(b-motor.from)*speed
            local t, span = (a-old.at)/duration, (b-a)/duration
            local x = startX+dx*t-origin:getX()-.5
            local y = origin:getY()+.5-startY-dy*t
            Sweep.crossings(job.profile, first, last, x, y, dx*span, -dy*span, function(arm, pass, travel, at)
                if pass <= (entry.hits[arm][actor] or -math.huge) then return end
                local east, north = x+dx*span*at, y-dy*span*at
                if east*east+north*north > job.profile.range^2 then return end
                local hitX, hitY = origin:getX()+.5+east, origin:getY()+.5-north
                local square = getCell():getGridSquare(math.floor(hitX), math.floor(hitY), frame.z)
                if not square or not require("OMHTT/PrototypeCombat").clearLane(origin,square,job.profile.range) then return end
                if instanceof(actor,"IsoZombie") then
                    R.hit(entry,actor,job,arm,pass,travel,hitX,hitY,square,frame.at,first,last,frame,old)
                else
                    entry.hits[arm][actor] = pass
                    R.injure(actor,job.stats.headKind=="RotaryBlades",Clock.now(),entry.object)
                end
            end)
        end
    end
end

---@param entry table Motor with newly recorded travel
---@param now number Current synchronized time
local function flush(entry, now)
    if not entry.pendingContacts then return end
    local waiting = false
    local covered = entry.timeline[#entry.timeline].at
    for actor, queue in pairs(entry.pendingContacts) do
        local keep = 0
        for i = 1, #queue do
            local item = queue[i]
            local frame = item.frame
            local zombie = instanceof(actor,"IsoZombie")
            if actor:isDead() or frame.epoch ~= Active.epoch or now-frame.at > 250
                or math.floor(actor:getZ()) ~= frame.z or (zombie and (frame.owner ~= actor:getOwner()
                or (frame.owner and (frame.player ~= actor:getOwnerPlayer() or frame.id ~= actor:getOnlineID()))
                or frame.outfit ~= Protocol.outfit(actor:getPersistentOutfitID()) or not Horde.allowed(actor))) then
                Diagnostics.count("rotary-interval-expired",1,"turrets")
            elseif frame.at <= covered then
                consume(entry,actor,item.job,item.old,frame)
            else
                waiting = true
                keep = keep+1
                queue[keep] = item
            end
        end
        for i = #queue, keep+1, -1 do queue[i] = nil end
        if keep == 0 then entry.pendingContacts[actor] = nil end
    end
    if not waiting then entry.pendingContacts = nil end
end

---@param entry table Motor owner
---@param actor IsoGameCharacter Observed candidate
---@param job table Resolved sweep and timestamp
function R.contact(entry, actor, job)
    if Active.paused() or not entry.timeline then return end
    if not R.standing(actor,job.position) then forget(entry,actor); return end
    local zombie = instanceof(actor,"IsoZombie")
    if zombie and not Horde.allowed(actor) then forget(entry,actor); return end
    local x,y,z,current,at = Actors.position(actor)
    if not current or z ~= entry.object:getSquare():getZ() or not T.isOn(T.state(entry.object)) then
        forget(entry,actor)
        return
    end
    at = job.observedAt or at or GameTime.getServerTimeMills()
    local owner = zombie and actor:getOwner() or nil
    local player = owner and actor:getOwnerPlayer() or nil
    local id = owner and actor:getOnlineID() or nil
    local outfit = zombie and Protocol.outfit(actor:getPersistentOutfitID()) or nil
    entry.contactFrames = entry.contactFrames or setmetatable({}, {__mode="k"})
    local old = entry.contactFrames[actor]
    local continuous = old and old.owner == owner and old.player == player and old.id == id and old.outfit == outfit
    if continuous and at <= old.at then return end
    local frame = {at=at,x=x,y=y,z=z,owner=owner,player=player,id=id,outfit=outfit,epoch=Active.epoch}
    if not continuous or old.epoch ~= frame.epoch
        or (old.z and old.z ~= z) or at-old.at > 250 or (old.x and (x-old.x)^2+(y-old.y)^2 > 4) then
        forget(entry,actor)
        entry.contactFrames[actor] = frame
        return
    end
    entry.contactFrames[actor] = frame
    local latest = entry.timeline[#entry.timeline]
    if not latest then return end
    if at <= latest.at then
        consume(entry,actor,job,old,frame)
        return
    end
    entry.pendingContacts = entry.pendingContacts or {}
    local queue = entry.pendingContacts[actor] or {}
    entry.pendingContacts[actor] = queue
    if #queue >= 32 then
        table.remove(queue,1)
        Diagnostics.count("rotary-interval-expired",1,"turrets")
    end
    queue[#queue+1] = {old=old,frame=frame,job=job}
    Diagnostics.count("rotary-interval-deferred",1,"turrets")
end

---@param entry table Motor owner
---@param actor IsoZombie Confirmed contact victim
---@param job table Resolved head and module snapshot
---@param arm number Contact arm
---@param pass number Unique motor pass
---@param crossing number Angular travel at contact
---@param hitX number Contact X
---@param hitY number Contact Y
---@param square IsoGridSquare Contact square
---@param observedAt number Observation timestamp
---@param before number Previous travel
---@param after number Current travel
---@param frame table? Reserved observation
---@param oldFrame table? Previous observation
---@return nil
function R.hit(entry, actor, job, arm, pass, crossing, hitX, hitY, square, observedAt, before, after, frame, oldFrame)
    local origin = entry.object:getSquare()
    if pass <= (entry.hits[arm][actor] or -math.huge) then return end
    local Proc = require("OMHTT/TurretProc")
    if not Proc.available(job.stats) then return end
    local energy
    for i = #entry.timeline, 1, -1 do
        local sample = entry.timeline[i]
        if crossing > sample.before and crossing <= sample.after then
            energy = sample.energy and sample.energy[pass]
            break
        end
    end
    local proc = {playerSource = require("OMHTT/ControlCombat").source(entry.object), stats = job.stats, siphon = energy}
    Proc.reserve(proc)
    local hits = entry.hits
    local previousPass = hits[arm][actor]
    entry.hits[arm][actor] = pass
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
            require("OMHTT/Diagnostics").count("rotary-applied", 1, "turrets")
            Proc.hit(actor, true, hitX, hitY, square:getZ(), {id = source}, nil, proc)
            Conditional.impact(actor, origin, {source = source, impactReady = true, stats = {impact = job.stats.knockdown}})
            if getTimestampMs() >= (entry.soundAt or 0) then
                entry.soundAt = getTimestampMs() + 150
                local radius = require("OMHTT/TurretStats").hearingRadius(entry.rotaryHead, job.stats)
                if radius > 0 then
                    Horde.sound(entry.object, origin:getX(), origin:getY(), origin:getZ(), radius, 10)
                end
                local sound = job.stats.fireSound or "BaseballBatHit"
                require("OMHTT/DefenseEffects").emit("Click", {sound = sound, x = origin:getX() + .5, y = origin:getY() + .5, z = origin:getZ(), gain = job.stats.hearingMultiplier})
            end
        else
            require("OMHTT/Diagnostics").count("rotary-rejected", 1, "turrets")
            if hits[arm][actor] == pass then
                hits[arm][actor] = previousPass
            end
            if frame and entry.contactFrames and entry.hits == hits and entry.contactFrames[actor] == frame then
                entry.contactFrames[actor] = oldFrame
            end
        end
        Proc.release(proc)
    end, observation)

end

---@param entry table Scheduler entry
---@return boolean retained
function R.step(entry)
    if Active.paused() then return true end
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
        Contacts.remove(object)
        return false
    end
    Contacts.watch(entry, stats.range)
    if entry.rotaryHead ~= head then
        Siphon.stop(entry)
        entry.rotaryHead, entry.rotaryAt = head, now
        entry.gameAt = getGameTime():getWorldAgeHours()
        entry.travel, entry.hits = 0, {setmetatable({}, {__mode = "k"}), setmetatable({}, {__mode = "k"})}
        entry.timeline,entry.contactFrames,entry.pendingContacts = {},nil,nil
        state.rotaryMoving = false
    end
    local elapsed = math.max(0, now - entry.rotaryAt)
    entry.rotaryAt = now
    local gameNow = getGameTime():getWorldAgeHours()
    local gameHours = math.max(0, gameNow - entry.gameAt)
    entry.gameAt = gameNow
    local powered = W.valid(object) and T.isOn(state) and head:getCondition() > 0
    if not powered then
        Siphon.stop(entry)
        state.rotaryMoving, state.rotaryManual = false, nil
        require("OMHTT/TurretStandby").step(object, contents, nil)
        entry.hasTarget, entry.detectedTarget = false, nil
        entry.timeline,entry.contactFrames,entry.pendingContacts = {},nil,nil
        return true
    end
    local profile = M.profile(state, contents, true, stats)
    local automatic = M.detects(state, contents) and contents.active.Firing and not require("OMHTT/ControlCycle").managed(object)
    local manual = state.rotaryManual and now < state.rotaryManual
    local standby = require("OMHTT/TurretStandby")
    if entry.detectedTarget and (not R.standing(entry.detectedTarget) or not Actors.confirmed(entry.detectedTarget)
        or not standby.valid(object, entry.detectedTarget, contents)) then
        entry.detectedTarget = nil
    end
    entry.hasTarget = entry.detectedTarget ~= nil
    local ready = standby.step(object, contents, entry.detectedTarget, state.rotaryMoving == true)
    local wants = manual or (automatic and entry.hasTarget and ready)
    local wasMoving = state.rotaryMoving == true
    local moving = wasMoving
    local movingFraction
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
    if moving and elapsed > 0 then
        local travel = elapsed / 1000 * stats.motorSpeed
        if entry.stopAt then
            local requested = travel
            travel = math.min(travel, math.max(0, entry.stopAt - before))
            if requested > 0 then movingFraction = travel/requested end
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
    if not moving then
        Siphon.stop(entry)
    end
    state.rotaryMoving = moving
    if elapsed > 0 or not moving or not entry.timeline or not entry.timeline[1] or not wasMoving then
        R.record(entry,before,entry.travel,elapsed,movingFraction)
    end
    if entry.timeline and #entry.timeline > 0 then flush(entry,GameTime.getServerTimeMills()) end
    state.rotaryTravel = entry.travel
    state.aimAt = entry.timeline[#entry.timeline].at
    state.rotarySpeed, state.rotaryStopAt = stats.motorSpeed, entry.stopAt
    local angle = Heads.motion(entry.travel, profile.omni, profile.cone)
    state.aimDegrees = (profile.heading + angle + 360) % 360
    W.publishRuntime(object, state, contents, now)
    return true
end

---@param entry table Indexed rotary motor owner
---@param actor IsoGameCharacter Observed target
---@param position table Validated owner or native observation
---@param previous table? Previous position from this observation source
---@param ownerReport boolean? Server-validated owner frame
---@return nil
function R.observe(entry, actor, position, previous, ownerReport)
    if Active.paused() then return end
    local object = entry.object
    local state = T.state(object)
    if not state or not T.isOn(state) or state.facingPending then return end
    local W = require("OMHTT/TurretWorld")
    local contents = W.contents(object)
    local stats = entry.rotaryContents == contents and entry.rotaryStats or T.cycleConfig(contents)
    if not stats.rotary then
        Contacts.remove(object)
        return
    end
    local origin = object:getSquare()
    local dx, dy = position.x - origin:getX() - .5, position.y - origin:getY() - .5
    if dx * dx + dy * dy > (stats.range + 1) ^ 2 then
        forget(entry,actor)
        return
    end
    if (previous and (previous.z ~= position.z or previous.down or previous.prone)) or not R.standing(actor,position) then
        forget(entry,actor)
    end
    local detection = M.profile(state, contents, true, stats)
    local target = entry.detectedTarget
    if R.standing(actor,position) and require("OMHTT/ControlCombat").eligible(object, actor)
        and M.inside(origin, actor, detection, position.x, position.y)
        and require("OMHTT/PrototypeCombat").clearLane(origin, Actors.square(actor), stats.range) then
        entry.detectedTarget = actor
        if not target then
            require("OMHTT/Diagnostics").defer("rotary-target-observed", {id=state.id, victim=actor:getOnlineID(),
                observedAt=position.at, receivedAt=GameTime.getServerTimeMills()}, "turrets")
        end
    elseif target == actor then
        entry.detectedTarget = nil
    end
    if entry.rotaryAt ~= Clock.now() or (not target and entry.detectedTarget) or (target and not entry.detectedTarget) then
        R.step(entry)
    end
    if not entry.timeline then return end
    R.contact(entry, actor, {at = Clock.now(), profile = M.profile(state, contents, false, stats),
        stats = stats,
        position = ownerReport and position or nil, observedAt = ownerReport and position.at or GameTime.getServerTimeMills()})
end

return R
