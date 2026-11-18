---@return nil
local function run()
    local cell = getCell()
    OMHTT_BarbFixtures = ArrayList.new()
    OMHTT_BarbPairs = ArrayList.new()
    local zombie = IsoZombie.new(cell)
    local width = zombie:getWidth()
    assert(type(width) == 'number' and width > 0, 'Zombie contact width unavailable')
    local types = {'logwall', 'logfence', 'mapfence', 'mapwall'}
    for t = 1, #types do
        for axis = 1, 2 do
            local north = axis == 1
            local x, y = 900 + t * 4, 900 + axis * 4
            local square = IsoGridSquare.new(cell, nil, x, y, 0)
            local other = IsoGridSquare.new(cell, nil, x - (north and 0 or 1), y - (north and 1 or 0), 0)
            square:setAdjacentSquare(north and IsoDirections.N or IsoDirections.W, other)
            other:setAdjacentSquare(north and IsoDirections.S or IsoDirections.E, square)
            local sprite
            if t == 1 then
                sprite = north and 'carpentry_02_81' or 'carpentry_02_80'
            elseif t == 2 then
                sprite = north and 'crafted_04_115' or 'crafted_04_116'
            elseif t == 3 then
                sprite = north and 'fencing_01_1' or 'fencing_01_2'
            else
                sprite = north and 'walls_exterior_house_01_1' or 'walls_exterior_house_01_0'
            end
            local host
            if t <= 2 then
                host = IsoThumpable.new(cell, square, sprite, north)
                host:setIsThumpable(true)
                host:setIsHoppable(t == 2)
                host:setBlockAllTheSquare(false)
                host:setCanPassThrough(false)
                host:setMaxHealth(t == 1 and 500 or 200)
                host:setHealth(t == 1 and 437 or 137)
            else
                host = IsoObject.new(cell, square, sprite)
            end
            square:getObjects():add(host)
            if t <= 2 then
                square:getSpecialObjects():add(host)
            end
            square:RecalcProperties()
            other:RecalcProperties()
            assert(host:getObjectIndex() >= 0, 'Host missing from square')
            host:getModData().OMHTTBarbProbe = {id = types[t] .. axis, side = north and 'N' or 'W'}
            if t <= 2 then
                local health = host:getHealth()
                assert(health == (t == 1 and 437 or 137), 'Attachment changed health')
                host:Damage(10)
                assert(host:getHealth() < health, 'Native constructed-host damage did not reduce health')
                assert(square:getThumpableWallOrHoppable(north) == host, 'Constructed edge lookup lost identity')
            else
                local broken = BrokenFences.getInstance():isBreakableObject(host)
                assert(broken == (t == 3), 'Unexpected map host breakable classification')
                assert(host.getHealth == nil and host.getMaxHealth == nil, 'Map host unexpectedly has constructed health')
                if t == 3 then
                    local remaining = host:getDamage()
                    host:Damage(100)
                    assert(host:getDamage() == remaining - 10, 'Map fence damage pool inaccessible')
                    print('[BarbProbe] map-fence damageBefore=' .. remaining .. ' damageAfter=' .. host:getDamage())
                end
            end
            if t == 2 or t == 3 then
                assert(square:getHoppableTo(other) == host and other:getHoppableTo(square) == host, 'Fence edge lookup failed')
                OMHTT_BarbPairs:add(square)
                OMHTT_BarbPairs:add(other)
            end
            OMHTT_BarbFixtures:add(host)
        end
    end
    for axis = 1, 2 do
        for side = -1, 1, 2 do
            ---@param along number Position along edge
            ---@param across number Signed distance from edge
            ---@return boolean touching
            local function contact(along, across)
                zombie:setX(axis == 1 and 900 + along or 900 + across)
                zombie:setY(axis == 1 and 900 + across or 900 + along)
                local u = axis == 1 and zombie:getX() - 900 or zombie:getY() - 900
                local v = axis == 1 and zombie:getY() - 900 or zombie:getX() - 900
                return u >= 0 and u <= 1 and v * side >= 0 and v * side <= width
            end
            assert(contact(.5, side * width * .5), 'Front contact missed')
            assert(contact(.5, side * width * .5), 'Stationary contact missed')
            assert(not contact(.5, side * (width + .1)), 'Near miss counted')
            assert(not contact(.5, -side * width * .5), 'Protected side counted')
            assert(not contact(1.2, side * width * .5), 'Past endpoint counted')
        end
    end
    local damage = require('OMHTT/Damage')
    local nativeServer = isServer
    ---@return boolean server
    isServer = function() return false end
    zombie:setHealth(1)
    local nextHit, hits = nil, 0
    ---@param now number Controlled active milliseconds
    ---@param touching boolean Contact sample
    ---@return nil
    local function tick(now, touching)
        if touching and (not nextHit or now >= nextHit) then
            damage.apply(zombie, .1, 'barb-native-probe', 'barb-prototype', nil, nil)
            nextHit, hits = now + 2000, hits + 1
        end
    end
    tick(0, true)
    tick(0, true)
    tick(1000, false)
    tick(1500, true)
    tick(1999, true)
    tick(2000, true)
    tick(4000, true)
    tick(6000, false)
    isServer = nativeServer
    assert(hits == 3 and math.abs(zombie:getHealth() - .7) < .00001, 'Timed native damage mismatch')
    print('[BarbProbe] TIMER PASS hits=3 health=0.7 immediate=1 cadenceMs=2000 exit=stops sharedGuard=prototype')
    print('[BarbProbe] LUA PASS fixtures=8 fencePairs=4 contactSamples=20 width=' .. width .. ' nativeLuaAPIs=exposed')
    OMHTT_BarbContentProbe()
end
Events.OnServerStarted.Add(run)
