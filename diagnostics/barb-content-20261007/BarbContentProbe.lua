---@return nil
function OMHTT_BarbContentProbe()
    local S = require("OMHTT/BarbSupport")
    local C = require("OMHTT/BarbContact")
    local Damage = require("OMHTT/Damage")
    local nativeServer = isServer
    ---@return boolean server
    isServer = function() return false end
    local cell = getCell()
    local policy = {fixedWindowFrame = false}
    local fixtures = OMHTT_BarbFixtures
    assert(fixtures and fixtures:size() == 8, "Initial fixtures have not run")
    for i = 0, fixtures:size() - 1 do
        local host = fixtures:get(i)
        local north = i % 2 == 0
        assert(S.kind(host, north), "Host classification missing: " .. host:getSpriteName())
        local health = i < 4 and host:getHealth() or host:getDamage()
        assert(S.bind(host, north, 1, "host-" .. i, policy), "Attachment failed")
        assert(not S.bind(host, north, 1, "duplicate", policy), "Duplicate attachment accepted")
        assert(S.bind(host, north, -1, "back-" .. i, policy), "Opposite face denied")
        local record = host:getModData().OMHTTBarbs[S.faceKey(north, 1)]
        assert(record.shared == (i < 4), "Wrong shared health model")
        S.wear(record, .1)
        if not record.shared then assert(record.health == 49, "Separate durability did not wear") end
        assert((i < 4 and host:getHealth() or host:getDamage()) == health, "Attachment/wear changed native health")
        local square = host:getSquare()
        assert(S.find(square, north) == host, "Backing lookup lost exact host")
        assert(S.resolve(square, north, 1, record.id, policy) == host, "Exact attachment failed to resolve")
        local unloaded, status = S.resolve(nil, north, 1, record.id, policy)
        assert(not unloaded and status == "unloaded", "Unload treated as destruction")
        square:getObjects():remove(host)
        local replacement = IsoObject.new(cell, square, host:getSpriteName())
        square:getObjects():add(replacement)
        local missing, reason = S.resolve(square, north, 1, record.id, policy)
        assert(not missing and reason == "missing", "Replacement inherited attachment")
        square:getObjects():remove(replacement)
        square:getObjects():add(host)
        assert(S.resolve(square, north, 1, record.id, policy) == host, "Reload failed to resume")
        assert(not S.unbind(host, north, 1, "stale"), "Stale removal accepted")
    end
    for axis = 1, 2 do
        local north = axis == 1
        local square = IsoGridSquare.new(cell, nil, 1000 + axis * 4, 1000, 0)
        local door = IsoDoor.new(cell, square, getSprite(north and "fixtures_doors_01_1" or "fixtures_doors_01_0"), north)
        square:getObjects():add(door)
        square:getSpecialObjects():add(door)
        square:RecalcProperties()
        door:getModData().OMHTTBarbProbe = {id = "door-" .. axis}
        assert(S.bind(door, north, 1, "door-" .. axis, policy), "Door attachment failed")
        local edge = {}
        assert(S.edge(door, north, 1, edge) and edge.north == north, "Closed door edge wrong")
        local health = door:getHealth()
        door:setOpen(true)
        assert(S.active(door, north, policy), "Open door lost barbs")
        assert(S.edge(door, north, 1, edge) and edge.north ~= north and edge.side == -1, "Barbs failed to follow door swing")
        local x, y = edge.x - .15, edge.y + .5
        if edge.north then x, y = edge.x + .5, edge.y - .15 end
        assert(C.touching(edge, x, y, 0, .3), "Open door contact not on new edge")
        door:setOpen(false)
        assert(S.edge(door, north, 1, edge) and edge.north == north and edge.side == 1, "Closing failed to restore edge")
        assert(not C.touching(edge, x, y, 0, .3), "Previous open position still damages after closing")
        assert(door:getHealth() == health, "Opening/closing altered shared health")
        fixtures:add(door)
        local windowSquare = IsoGridSquare.new(cell, nil, 1020 + axis * 4, 1000, 0)
        local window = IsoWindow.new(cell, windowSquare, getSprite(north and "fixtures_windows_01_1" or "fixtures_windows_01_0"), north)
        windowSquare:getObjects():add(window)
        windowSquare:getSpecialObjects():add(window)
        windowSquare:RecalcProperties()
        window:getModData().OMHTTBarbProbe = {id = "window-" .. axis}
        assert(S.bind(window, north, 1, "window-" .. axis, policy), "Window attachment failed")
        fixtures:add(window)
    end
    local zombie = IsoZombie.new(cell)
    zombie:setHealth(1)
    local own = {id = "wear-timer", shared = false, health = 50}
    local state, hits = {}, 0
    for now = 0, 4000, 100 do
        if C.step(state, now, "native", true, 2000) then
            S.wear(own, Damage.apply(zombie, .1, own.id, "barbs", nil, nil))
            hits = hits + 1
        end
    end
    assert(hits == 3 and own.health == 47 and math.abs(zombie:getHealth() - .7) < .00001, "Damage and wear cadence mismatch")
    assert(S.repair(own) and own.health == 50, "Separate repair failed")
    isServer = nativeServer
    print("[BarbProbe] CONTENT PASS hosts=12 doorsFollow=2 windowFixtures=2 lifecycle=exactIdentity damageHits=3 ownWear=3 repair=50")
end

---@param window IsoWindow Window with controlled native open flag
---@return boolean passed
function OMHTT_BarbWindowCheck(window)
    local S = require("OMHTT/BarbSupport")
    local north, edge = window:getNorth(), {}
    assert(window:IsOpen(), "Native open flag not reflected in Lua")
    assert(S.edge(window, north, 1, edge) and edge.north == north and edge.side == 1, "Window barbs moved with opening")
    assert(S.active(window, north, {}), "Open intact window lost contact")
    window:setSmashed(true)
    assert(not S.active(window, north, {}), "Intact-only policy ignored smashed state")
    assert(S.active(window, north, {fixedWindowFrame = true}), "Fixed-frame policy lost existing frame")
    assert(not S.sharedHealth(window, north, {fixedWindowFrame = true}), "A persistent frame cannot share broken-glass health")
    window:setSmashed(false)
    return true
end
