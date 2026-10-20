local C = require("OMHTTTether/Core")
local W = require("OMHTTTether/World")
local A = require("OMHTTTether/Authority")

local function run()
    local count = 0
    local function check(value, description)
        count = count + 1
        assert(value, description)
    end
    local hits = 0
    local function hit() hits = hits + 1 end
    local function miss() return nil end
    local state = C.new(0, 0, 0, 1, 0)
    check(not C.start(state, false, false), "Unlinked device must detect a target")
    check(C.start(state, true, false), "Unlinked detection should fire")
    check(not C.start(state, true, true), "No extra launch while busy")
    C.cancel(state)
    state.links = 1
    check(not C.start(state, true, false), "Linked detection must be disabled")
    check(C.start(state, false, true), "Linked input must fire without a target")
    local function first(s, from, destination)
        if destination >= 1.5 then return (1.5 - from) / (destination - from), "first", "zombie" end
    end
    for i = 1, 20 do C.step(state, .05, first, hit) end
    check(hits == 1, "No piercing or return damage")
    check(state.phase == "idle", "Hit returns and resets")
    check(state.sequence == 2, "Busy requests are not queued")
    state.held = true
    check(C.start(state, false, false), "Held input starts a ready device")
    state.held = false
    C.step(state, .1, miss, hit)
    check(state.phase == "out", "Input release cannot abandon current cycle")
    for i = 1, 50 do C.step(state, .05, miss, hit) end
    check(state.phase == "idle" and state.distance == 0, "Miss must return")
    check(not C.start(state, true, false), "Released input prevents new cycle")
    state.links = 0
    check(C.start(state, true, false), "Last unlink restores detection")
    C.step(state, 10, first, hit)
    check(state.phase == "idle" and hits == 1, "Large stall cancels without delayed damage")
    C.start(state, true, false)
    C.step(state, .6, miss, hit)
    check(state.distance <= 4.801 and state.debt > 0, "Per-tick work bounded with retained debt")
    for i = 1, 60 do C.step(state, .05, miss, hit) end
    check(state.phase == "idle", "Bounded catch-up completes")
    check(math.abs(C.intersection(0, 0, 10, 0, 3, 0, .3) - .27) < .00001, "Swept collision prevents tunneling")
    check(C.intersection(0, 0, 10, 0, 3, 2, .3) == nil, "Off-ray targets miss")
    check(C.intersection(3, 0, 4, 0, 3, 0, .3) == 0, "Starting overlap is a hit")
    local movingX = 8
    C.cancel(state)
    C.start(state, true, false)
    local function moving(s, from, destination)
        return C.intersection(from, 0, destination, 0, movingX, 0, .3), "moving", "zombie"
    end
    C.step(state, .1, moving, hit)
    movingX = 1.6
    C.step(state, .1, moving, hit)
    check(hits == 2 and state.phase == "back", "Collision reads the moving target during flight")
    local message = C.snapshot(state, 1, 10)
    check(C.accept(nil, message), "Valid first state")
    check(not C.accept(message, message), "Duplicate network state rejected")
    local stale = C.snapshot(state, 1, 9)
    check(not C.accept(message, stale), "Out-of-order state rejected")
    local restarted = C.snapshot(state, 1, 1, "2")
    check(C.accept(message, restarted), "Fresh authority session can restart serial numbers")
    check(not C.accept(restarted, message), "Delayed message from an old authority session is rejected")
    stale.serial, stale.distance = 11, 0 / 0
    check(not C.accept(message, stale), "Nonfinite payload rejected")
    local x1 = C.position(message, 0, 2)
    local x2 = C.position(message, .1, 2)
    check(x2 < x1 and x2 >= state.x, "Retraction visual shortens toward origin")
    message.phase = "out"
    check(C.position(message, 1) == C.position(message, 0), "Client cannot invent an outbound impact")
    check(C.position(message, .05, 0) > state.x and C.position(message, .05, 0) < C.position(message, .1, 0),
        "Outbound visual interpolates within confirmed segment")
    check(C.position(message, 10, 0) == C.position(message, .1, 0), "No speculative extrapolation after packet loss")

    local native = getCell()
    local square = IsoGridSquare.new(native, nil, 100, 100, 0)
    local zombie = IsoZombie.new(native)
    zombie:setX(100.65)
    zombie:setY(100.5)
    zombie:setZ(0)
    square:getMovingObjects():add(zombie)
    local fixture = {getGridSquare = function(_, x, y, z)
        if x == 100 and y == 100 and z == 0 then return square end
    end}
    local nativeState = C.new(100.1, 100.5, 0, 1, 0)
    local fraction, victim, reason = W.cast(nativeState, 0, .7, fixture)
    check(fraction and victim == zombie and reason == "zombie", "Native zombie and square collision adapter")
    local farther = IsoZombie.new(native)
    farther:setX(100.95)
    farther:setY(100.5)
    farther:setZ(0)
    square:getMovingObjects():clear()
    square:getMovingObjects():add(farther)
    square:getMovingObjects():add(zombie)
    check(select(2, W.cast(nativeState, 0, .7, fixture)) == zombie, "Nearest actor wins regardless of list ordering")
    zombie:setHealth(0)
    check(select(2, W.cast(nativeState, 0, .7, fixture)) == farther, "Dead actors do not steal the hit")
    square:getMovingObjects():clear()
    local boundary, _, stop = W.cast(nativeState, 0, 2, fixture)
    check(boundary and stop == "unloaded", "Unloaded path fails closed")

    local empty = {size = function() return 0 end}
    local firstSquare = {
        getX = function() return 0 end, getY = function() return 0 end,
        testVisionAdjacent = function() return "Blocked" end,
        isWindowTo = function() return false end,
        getMovingObjects = function() return empty end
    }
    local otherSquare = {
        getX = function() return 1 end, getY = function() return 0 end,
        isSolid = function() return false end, isSolidTrans = function() return false end,
        getMovingObjects = function() return empty end
    }
    local walls = {getGridSquare = function(_, x, y, z)
        if y ~= 0 or z ~= 0 then return nil end
        if x == 0 then return firstSquare end
        if x == 1 then return otherSquare end
    end}
    local wallState = C.new(.5, .5, 0, 1, 0)
    local wallFraction, _, wallReason = W.cast(wallState, 0, 1, walls)
    check(wallFraction and wallFraction < .51 and wallReason == "wall", "Solid boundary stops outbound travel")
    firstSquare.testVisionAdjacent = function() return "Clear" end
    firstSquare.isWindowTo = function() return true end
    check(select(3, W.cast(wallState, 0, 1, walls)) == "wall", "Windows stop nails")

    local fakePlayer = {
        isDead = function() return false end, getAccessLevel = function() return "None" end,
        getUsername = function() return "probe" end,
        getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end
    }
    local controlled = C.new(0, 0, 0, 1, 0)
    controlled.owner, controlled.id = "probe", 1
    A.devices[1] = controlled
    A.command("OMHTTTether", "Input", fakePlayer, {id = 1})
    check(controlled.phase == "idle", "Non-admin cannot request prototype actions")
    fakePlayer.getAccessLevel = function() return "admin" end
    A.command("OMHTTTether", "Input", fakePlayer, {id = 1})
    check(controlled.phase == "out", "Admin input handled by authoritative endpoint")
    check(C.accept(nil, C.snapshot(controlled, 1, 999, A.session)), "Native authority session produces a valid snapshot")
    A.command("OMHTTTether", "Input", fakePlayer, {id = 1})
    check(controlled.sequence == 1, "Duplicate input cannot queue another shot")
    local stranger = {
        isDead = function() return false end, getAccessLevel = function() return "Admin" end,
        getUsername = function() return "stranger" end,
        getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end
    }
    A.command("OMHTTTether", "Clear", stranger, {id = 1})
    check(A.devices[1] ~= nil, "Another admin cannot mutate an owner's fixture")
    A.devices = {}
    print("[OMHTT-TetherCycle] assertions=" .. count .. " nativeActor=true nativeSquare=true connectedClients=0 rendered=false")
    print("[OMHTT-TetherCycle] completed=true")
end

Events.OnServerStarted.Add(run)
