local C = require("OMHTT/TetherCycle")
local W = require("OMHTT/TetherLane")
local M = require("OMHTT/TetherMount")

local function run()
    local count = 0
    local function check(value, description)
        count = count + 1
        assert(value, description)
    end
    local tuning = {range = 6, speed = 12, returnSpeed = 4, resetTime = .4}
    check(C.new(100, 100, 0, 1, 0) == nil, "No fixture balance silently becomes a gameplay default")
    check(C.new(100, 100, 0, .6, .4, tuning) == nil, "Direction must be cardinal")
    check(C.new(100, 100, 0, 1, 0, {range = 0}) == nil, "Invalid tuning rejected")
    local state = C.new(100.05, 100.5, 0, 1, 0, tuning)
    check(state and not C.start(state, false, false), "Unlinked trap waits for detection")
    state.links = 1
    check(not C.start(state, true, false), "Link disables autonomous sensing")
    check(C.start(state, false, true), "Input can fire into an empty lane")
    local impacts = 0
    local function collision(s, from, to)
        if to >= .5 then return (.5 - from) / (to - from), "victim", "player" end
    end
    local function hit()
        impacts = impacts + 1
    end
    state.held = false
    for i = 1, 30 do
        C.step(state, .05, collision, hit)
    end
    check(impacts == 1 and state.phase == "idle", "Player impact happens once, return completes after release")
    check(not C.start(state, true, false), "Released input starts no new shot")
    state.links = 0
    check(C.start(state, true, false), "Unlink restores sensing")
    C.step(state, 20, collision, hit)
    check(impacts == 1 and state.phase == "idle", "Stall causes no late damage")
    local message = C.snapshot(state, "control-304", 2, "100")
    check(C.accept(nil, message), "Persistent Controller identity supported")
    check(not C.accept(message, message), "Duplicate snapshot rejected")
    check(not C.accept(message, C.snapshot(state, "control-305", 3, "100")), "Cross-device state rejected")
    check(C.accept(message, C.snapshot(state, "control-304", 1, "101")), "New authority session accepted")
    check(not C.accept(message, C.snapshot(state, "control-304", 5, "99")), "Old authority session rejected")
    local restored = nativeRoundTrip and nativeRoundTrip(message) or nil
    if restored then
        check(C.accept(nil, restored), "Snapshot native serialization")
    end

    local native = getCell()
    local square = IsoGridSquare.new(native, nil, 100, 100, 0)
    local zombie, player = IsoZombie.new(native), IsoPlayer.new(native)
    zombie:setX(100.85)
    zombie:setY(100.5)
    zombie:setZ(0)
    player:setX(100.4)
    player:setY(100.5)
    player:setZ(0)
    player:setGodMod(false)
    player:setNoClip(false)
    player:setGhostMode(false)
    square:getMovingObjects():add(zombie)
    square:getMovingObjects():add(player)
    local fixture = {getGridSquare = function(_, x, y, z)
        if x == 100 and y == 100 and z == 0 then return square end
    end}
    local fraction, victim, reason = W.cast(state, 0, .9, fixture)
    check(fraction and victim == player and reason == "player", "Player blocks a zombie behind them")
    check(W.detect(state, fixture) == nil, "Player cannot activate autonomous firing")
    player:setY(101.5)
    check(W.detect(state, fixture) == zombie, "Clear lane detects zombie")
    player:setY(100.5)
    player:setGodMod(true, true)
    check(select(2, W.cast(state, 0, .9, fixture)) == zombie, "Protected player ignored")
    player:setGodMod(false, true)
    zombie:setHealth(0)
    check(select(2, W.cast(state, 0, .9, fixture)) == player, "Player still blocks a triggered shot without a zombie")
    square:getMovingObjects():clear()

    local lookup = {}
    for x = 99, 102 do
        for y = 99, 102 do
            local tile = IsoGridSquare.new(native, nil, x, y, 0)
            tile:getObjects():add(IsoObject.new(tile, "floors_interior_tilesandwood_01_0", "floor"))
            tile:RecalcProperties()
            lookup[x .. ":" .. y] = tile
        end
    end
    local world = {getGridSquare = function(_, x, y, z)
        if z == 0 then return lookup[x .. ":" .. y] end
    end}
    local east = lookup["100:100"]
    local north = lookup["100:101"]
    local west = lookup["101:100"]
    local eastWall = IsoObject.new(east, "walls_exterior_wooden_01_0", "wall")
    eastWall:getProperties():set(IsoFlagType.collideW)
    eastWall:getProperties():set(IsoFlagType.WallW)
    east:getObjects():add(eastWall)
    local northWall = IsoObject.new(north, "walls_exterior_wooden_01_1", "wall")
    northWall:getProperties():set(IsoFlagType.collideN)
    northWall:getProperties():set(IsoFlagType.WallN)
    north:getObjects():add(northWall)
    local westWall = IsoThumpable.new(native, west, "walls_exterior_wooden_01_0", false, nil)
    westWall:getProperties():set(IsoFlagType.collideW)
    westWall:getProperties():set(IsoFlagType.WallW)
    westWall:setHealth(100)
    west:getObjects():add(westWall)
    local southWall = IsoThumpable.new(native, east, "walls_exterior_wooden_01_1", true, nil)
    southWall:getProperties():set(IsoFlagType.collideN)
    southWall:getProperties():set(IsoFlagType.WallN)
    southWall:setHealth(100)
    east:getObjects():add(southWall)
    local faces = {"e", "n", "w", "s"}
    local vectors = {{1, 0}, {0, -1}, {-1, 0}, {0, 1}}
    for i = 1, #faces do
        local mount, backing = M.resolve(100, 100, 0, faces[i], world)
        check(mount and backing and mount.dx == vectors[i][1] and mount.dy == vectors[i][2],
            "Native and constructed wall face " .. faces[i] .. " fires outward")
        check(math.floor(mount.x) == 100 and math.floor(mount.y) == 100, "Muzzle starts on selected side")
    end
    westWall:setHealth(0)
    check(M.resolve(100, 100, 0, "w", world) == nil, "Destroyed player-built wall rejected")
    check(M.resolve(100, 100, 0, "invalid", world) == nil, "Invalid facing rejected")
    check(M.resolve(99, 99, 0, "e", world) == nil, "Floor alone cannot support wall panel")
    check(M.resolve(100, 100, 1, "e", world) == nil, "Unloaded floor rejected")
    local embedded = C.new(0, 0, 0, 1, 0, {range=6, speed=12, returnSpeed=4, resetTime=.4, holdTime=.75})
    embedded.links = 1
    C.start(embedded, false, true)
    local impacts, pulls = 0, 0
    local function immediate() return 0, "victim", "zombie" end
    local function impact() impacts = impacts + 1 end
    local function pull() pulls = pulls + 1 end
    C.step(embedded, .05, immediate, impact, pull)
    check(embedded.phase == "hold" and impacts == 1 and pulls == 0, "Impact embeds exactly once")
    for i=1,14 do C.step(embedded,.05,immediate,impact,pull) end
    check(embedded.phase == "hold" and pulls == 0, "Pull cannot precede 0.75 second hold")
    C.step(embedded,.05,immediate,impact,pull)
    check(embedded.phase == "back" and pulls == 1, "Hold completes with one pull")
    for i=1,40 do C.step(embedded,.05,immediate,impact,pull) end
    check(impacts == 1 and pulls == 1 and embedded.phase == "idle", "No return damage or queued shots")
    print("[OMHTT-TetherTrap] assertions=" .. count .. " nativePlayer=true nativeWalls=true connectedClients=0 rendered=false")
    print("[OMHTT-TetherTrap] completed=true")
end

Events.OnServerStarted.Add(run)
