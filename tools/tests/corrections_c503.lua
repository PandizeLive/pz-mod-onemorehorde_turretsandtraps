-- Corrective regressions for the dedicated-server event gap and observer presentation.
local savedMode, savedMillis = testMode, testMillis
local C = require("OMHTT/DefenseContacts")
local E = require("OMHTT/TurretProc")
local D = require("OMHTT/Damage")
local Clock = require("OMHTT/TurretClock")
local savedClock, savedSettings = Clock.now, SandboxVars.OMHTurretsTraps
testMode, testMillis = "server", 1000000
SandboxVars.OMHTurretsTraps = {}
Clock.now = function() return testMillis end

do
    local registered = false
    for i = 1, #Events.OnTick.handlers do
        if Events.OnTick.handlers[i] == require("OMHTT/DefenseActors").refresh then registered = true end
    end
    check(registered and C.handlers.bed and C.handlers.barb and C.handlers.tack and C.handlers.control,
        "C503 all installed hazard channels share a registered tick driver")
    -- C505 replaces square-list slicing with one shared physical-position index.
    local Actors = require("OMHTT/DefenseActors")
    local oldHandlers = C.handlers
    C.handlers, C.tiles, C.sources, C.count = {}, {}, {}, 0
    local hits = 0
    C.handlers.tack = function() hits = hits + 1 end
    local square = makeSquare(5100,5100,0)
    local actors = {}
    for i = 1, 300 do actors[i] = makeZombie(square,1) end
    C.watch("a","tack",5100,5100,5100,5100,0)
    C.watch("b","tack",5100,5100,5100,5100,0)
    testMillis = testMillis + 50
    for i = 1, #actors do Actors.observe(actors[i]) end
    check(hits == 300, "C505 shared actor sample visits every dense contact once")
    for i = 1, #actors do Actors.observe(actors[i]) end
    check(hits == 300, "C505 overlapping watches and same-time samples do not duplicate contact")
    C.remove("a")
    check(C.tiles["5100:5100:0"] ~= nil, "C505 removing one overlapping source retains tile")
    C.remove("b")
    check(C.tiles["5100:5100:0"] == nil, "C505 last source reclaims watch")
    C.handlers = oldHandlers
end

do
    local Barrier, Footprint = require("OMHTT/BarrierRetaliation"), require("OMHTT/BarrierFootprint")
    local oldExact, oldFace, oldResolve = Footprint.exact, Barrier.face, D.resolve
    local square = makeSquare(5350,5350,0)
    local actor = makeZombie(square,1)
    actor.onlineId, actor.outfitId, actor.state = 93, 94, "thump"
    local sender = {}
    actor.owner = {havePlayer=function(_,p) return p == sender end}
    local target = {getHealth=function() return 100 end,getModData=function() return {} end}
    square.objects = {target}
    Footprint.exact = function(value) return value == target and {id="c503-barrier",tier="normal"} end
    Barrier.face = function() return "front" end
    local hits = 0
    D.resolve = function() hits = hits + 1 end
    local message = {id=93,outfit=94,barrier="c503-barrier",x=5350,y=5350,z=0,index=0,token="left"}
    Barrier.command("OMHTT_BarrierContact","Strike",sender,message)
    check(hits == 1, "C503 barrier resolves actor without any zombie-update indexing")
    Barrier.command("OMHTT_BarrierContact","Strike",sender,message)
    check(hits == 1, "C503 barrier duplicate strike remains suppressed")
    testMillis = testMillis + 250
    message.token = "right"
    Barrier.command("OMHTT_BarrierContact","Strike",{},message)
    check(hits == 1, "C503 barrier rejects a report from another connection")
    message.outfit = 95
    Barrier.command("OMHTT_BarrierContact","Strike",sender,message)
    check(hits == 1, "C503 barrier rejects recycled identity mismatch")
    Footprint.exact, Barrier.face, D.resolve = oldExact, oldFace, oldResolve
end

do
    local H = require("OMHTT/TargetHealth")
    local Conditional = require("OMHTT/TurretConditionalHit")
    local actor = makeZombie(makeSquare(5300,5300,0),1)
    H.created(actor)
    actor.health = 4
    H.tick()
    actor.health = .4
    local result = Conditional.snapshot(actor,{initialBlow=.3,initialThreshold=.9,execute=.18})
    check(H.maximum(actor) == 4 and result.execute and result.bonus == 1,
        "C503 deferred spawn customization is captured before later ordinary injury")
    H.created(actor)
    actor.health = 2
    H.tick()
    check(H.maximum(actor) == 2, "C503 recycled actor discards its previous maximum")
    local A = require("OMHTT/DefenseActorState")
    actor.owner, actor.floor = {}, false
    actor.state = "getup"
    local prone, down = A.stance(actor)
    check(prone and down, "C503 replicated getup supplies landing even when native server floor flag is false")
    actor.state = "falldown"
    prone, down = A.stance(actor)
    check(not prone and down, "C503 falling is not a completed landing")
    actor.state = "bumped"
    prone, down = A.stance(actor)
    check(not prone and not down, "C503 ordinary shove is not treated as a floor landing")
end

do
    local P = require("OMHTT/ControlPoke")
    local W = require("OMHTT/ControlWorld")
    local Audio = require("OMHTT/ControlAudio")
    local oldVisual, oldPublish, oldResolve, oldEmit = P.visual, W.publish, D.resolve, Audio.emit
    local square = makeSquare(5400,5400,0)
    makeZombie(square,1)
    local object = {getSquare=function() return square end,getHealth=function() return 200 end}
    local state, hits = {id="c503-poke"}, 0
    P.visual = function(_,s,active) s.active = active end
    W.publish, Audio.emit = function() end, function() end
    D.resolve = function() hits = hits + 1 end
    P.time = 0
    P.step(object,state)
    check(state.active and hits == 1, "C505 first occupied observation starts and strikes immediately")
    P.time = 1600
    P.step(object,state)
    check(hits == 2 and state.active, "C505 ready occupied Poke repeats once after its cooldown")
    P.step(object,state)
    check(hits == 2 and state.active, "C505 same-time observations do not create catch-up damage")
    square.moving = {}
    P.time = 1750
    P.step(object,state)
    check(hits == 2, "C505 cooldown prevents damage after crossing")
    P.entries[object] = nil
    P.visual, W.publish, D.resolve, Audio.emit = oldVisual, oldPublish, oldResolve, oldEmit
end

do
    local U, A = require("OMHTT/ControlClient"), require("OMHTT/ControlAccess")
    local oldState, oldText = A.state, getText
    local record = {kind="Poke",number=3,displayName="UI_OMHTT_ControlPoke #3"}
    A.state = function() return record end
    for _, locale in pairs({"Floor spikes","Piques de sol"}) do
        getText = function() return locale end
        check(U.name({}) == locale .. " #3", "C503 automatic legacy label renders in viewer locale")
        record.name = "UI_OMHTT_My custom name"
        check(U.name({}) == record.name, "C503 explicit custom text is preserved even when resembling a key")
        record.name = nil
    end
    A.state, getText = oldState, oldText
end

do
    local V = require("OMHTT/TurretAimView")
    local sample = {}
    check(V.sample(sample,359,0,false) == 359, "C503 first heading initializes without a spin")
    V.sample(sample,1,250,false)
    check(math.abs(V.sample(sample,1,375,false)) < .00001, "C503 shortest-angle interpolation crosses zero smoothly")
    check(V.sample(sample,1,5000,false) == 1, "C503 missing packets stop at confirmed heading")
    V.sample(sample,181,5000,false)
    check(V.sample(sample,181,5001,false) ~= 181, "C503 late packet does not snap to its endpoint")
    sample = {}
    V.sample(sample,350,0,true)
    V.sample(sample,750,250,true)
    check(V.sample(sample,750,375,true) == 550, "C503 rotary travel preserves complete turns and motor direction")
    check(V.sample(sample,0,400,true) == 0, "C503 restarted motor resets travel without spinning backwards")
end

do
    local oldIndicator, oldSpecific, oldCount = PixelStrikeIndicator, getSpecificPlayer, getNumActivePlayers
    local square = makeSquare(5500,5500,0)
    local visible, shown = true, 0
    square.isCanSee = function() return visible end
    local actor = makeZombie(square,1)
    PixelStrikeIndicator = {Config={showDamageDealt=true,showOrdinaryHits=true,scale=100},
        spawnAt=function(x,y,z,value,kind,index)
            check(value == 20 and kind == "hit", "C503 display uses actual server loss")
            shown = shown + 1
        end}
    getSpecificPlayer = function() return actor end
    getNumActivePlayers = function() return 2 end
    testMode = "client"
    local facts = {x=5500.5,y=5500.5,z=0,lost=.2,packet=950001}
    triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
    triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
    check(shown == 2, "C503 duplicate split-screen delivery displays once per viewport")
    visible, facts.packet = false, 950002
    triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
    check(shown == 2, "C503 unseen hit does not reveal a target")
    visible, facts.packet = true, 950003
    PixelStrikeIndicator.Config.showDamageDealt = false
    triggerEvent("OnServerCommand","OMHTT_DamageView","Hit",facts)
    check(shown == 2, "C503 Pixel Strike disabled preference is respected")
    PixelStrikeIndicator, getSpecificPlayer, getNumActivePlayers = oldIndicator, oldSpecific, oldCount
    testMode = "server"
    local facts = require("OMHTT/DamageNotice").capture(actor,.2,"c503","tack")
    actor.square = nil
    check(facts.x == 5500.5 and facts.lost == .2, "C503 lethal notice retains position after actor removal")
end

do
    local S, V = require("OMHTT/TurretPackObservers"), require("OMHTT/TurretPackObserverView")
    local oldOnline, oldSend = getOnlinePlayers, sendServerCommand
    local square = makeSquare(5600,5600,0)
    square.isCanSee = function() return true end
    local opener, viewer = makeZombie(square,1), makeZombie(square,1)
    opener.onlineId, viewer.onlineId = 50, 51
    local distance, valid, packets = 8, true, {}
    viewer.getX = function() return opener:getX() + distance end
    getOnlinePlayers = function() return {size=function() return 2 end,get=function(_,i) return i == 0 and opener or viewer end,
        contains=function(_,v) return v == opener or v == viewer end} end
    sendServerCommand = function(who,module,command,facts)
        check(who == viewer and facts.player == 50, "C503 pack icon excludes opener and identifies only its actor")
        packets[#packets+1] = facts
    end
    local action = {character=opener,isValid=function() return valid end}
    S.start(action)
    check(#packets == 1 and packets[1].active and V.visible(opener,viewer,0), "C503 observer at exactly eight tiles sees opening")
    distance = 8.01
    testMillis = testMillis + 250
    S.tick()
    check(#packets == 2 and not packets[2].active and not V.visible(opener,viewer,0), "C503 crossing eight-tile limit clears icon")
    distance = 1
    testMillis = testMillis + 250
    S.tick()
    valid = false
    testMillis = testMillis + 250
    S.tick()
    check(#packets == 4 and not packets[4].active and S.count == 0, "C503 cancellation ends observation and idle work")
    testMode = "client"
    V.receive("OMHTT_PackView","Opening",packets[4])
    V.receive("OMHTT_PackView","Opening",packets[3])
    check(not V.entries[50].active, "C503 delayed start cannot override newer stop")
    testMode = "server"
    getOnlinePlayers, sendServerCommand = oldOnline, oldSend
end

-- The production worker, admission and damage callback produce the delayed Synergy child.
do
    local stats = require("OMHTT/TurretStats").resolve({active={Martyrdom=1,Synergy=1}})
    local oldJobs, oldReserved = E.jobs, E.reservedJobs
    E.jobs, E.reservedJobs = {}, 0
    for x = 5698, 5706 do for y = 5698, 5702 do makeSquare(x,y,0) end end
    local root = makeZombie(testSquares["5700:5700:0"],0)
    local first = makeZombie(testSquares["5701:5700:0"],.1)
    local second = makeZombie(testSquares["5702:5700:0"],.05)
    first.data.OMHTTPackRolled, second.data.OMHTTPackRolled = true, true
    first.die, second.die = function() end, function() end
    local shot = {stats=stats}
    E.reserve(shot)
    E.hit(root,true,root:getX(),root:getY(),0,{id="c503-martyr"},nil,shot)
    E.release(shot)
    check(#E.jobs == 1, "C503 confirmed lethal callback queues Martyrdom on server")
    testMillis = testMillis + 749
    E.tick()
    check(first.health == .1, "C503 Martyrdom honors delayed detonation")
    testMillis = testMillis + 1
    for i = 1, 20 do E.tick() end
    check(first:isDead() and #E.jobs == 1 and E.jobs[1].generation == 1,
        "C503 scheduled server burst kills and queues one Synergy follow-up")
    testMillis = testMillis + 750
    for i = 1, 20 do E.tick() end
    check(second:isDead() and #E.jobs == 0, "C503 follow-up damages through production authority without another generation")
    E.jobs, E.reservedJobs = oldJobs, oldReserved
end

testMode, testMillis = savedMode, savedMillis
Clock.now, SandboxVars.OMHTurretsTraps = savedClock, savedSettings
testC503 = "contact-budget=pass health=pass poke=pass names=pass aim=pass observer=pass popup=pass martyrdom=scheduled-server-path"

do
    local XP = require("OMHTT/DefenseXP")
    local oldMods, oldBarrier = getActivatedMods, __modules["OMHTT/BarrierFootprint"]
    getActivatedMods = function() return {contains=function(_,id) return id == "OneMoreHorde_Turrets" end} end
    __modules["OMHTT/BarrierFootprint"] = nil
    XP.register("test-c503-disabled-traps","owner",5500,5500,0)
    local actor = {isDead=function() return false end,isGodMod=function() return false end,
        isNoClip=function() return false end,isGhostMode=function() return false end,getSquare=function() return nil end}
    check(not XP.contact(actor,"test-c503-disabled-traps"), "C503 old barrier identity cannot load absent Traps code")
    getActivatedMods, __modules["OMHTT/BarrierFootprint"] = oldMods, oldBarrier
end
