return function(player)
    local Action = require("OMHTT/PlacementAction")
    local Rules = require("OMHTT/PlacementRules")
    local savedCell, savedServer, savedPlayer, savedThumpable = getCell, isServer, getSpecificPlayer, IsoThumpable
    local cell, lookup = getCell(), {}
    local sequence, completed = 0, 0
    local fixtureX = 12000
    local generation = ModData.getOrCreate("OMHTTPlacementProbeV1")
    generation.index = (generation.index or 0) + 1
    local fixtureY = 10000 + generation.index * 10
    local oldX, oldY, oldZ, oldSquare = player:getX(), player:getY(), player:getZ(), player:getSquare()
    local oldCheat = player:isBuildCheat()
    -- Real native squares, objects, inventory and setInfo; synthetic lookup only.
    -- Both Lua execution branches run in this isolated server process, not a live SP client.
    getCell = function() return {getGridSquare = function(_, x, y, z) return lookup[x .. ":" .. y .. ":" .. z] end} end
    IsoThumpable = {new = function(_, ...) return savedThumpable.new(cell, ...) end}
    getSpecificPlayer = function(index)
        assert(index == player:getPlayerNum(), "Native SP construction lost its player binding")
        return player
    end
    for _, server in pairs({false, true}) do
        isServer = function() return server end
        for _, cheat in pairs({false, true}) do
            player:setBuildCheat(cheat)
            for route, profile in pairs(Rules.routes) do
              for variant = 1, ((route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") and 8 or 1) do
                local rotation = (route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") and ((variant - 1) % 4 + 1) or 2
                sequence = sequence + 1
                local x, y = fixtureX + sequence * 10, fixtureY
                local chunk = IsoChunk.new(cell)
                chunk:assignLoadID()
                for dx = -2, 3 do
                    for dy = -2, 3 do
                        local square = IsoGridSquare.new(cell, nil, x + dx, y + dy, 0)
                        chunk:setSquare(dx + 2, dy + 2, 0, square)
                        square:getObjects():add(IsoObject.new(square, "floors_interior_tilesandwood_01_0", "floor"))
                        square:RecalcProperties()
                        lookup[(x + dx) .. ":" .. (y + dy) .. ":0"] = square
                    end
                end
                local square = lookup[x .. ":" .. y .. ":0"]
                player:setX(x + .5); player:setY(y + .5); player:setZ(0); player:setCurrent(square)
                if (route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") or route == "OMHTTBarbs" or route == "OMHTTDeploySwitchButton" then
                    local wx, wy, north = x, y + 1, true
                    if route == "OMHTTDeploySwitchButton" then wy = y end
                    if (route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") then
                        wx, wy = x + (rotation == 1 and 1 or 0), y + (rotation == 2 and 1 or 0)
                        north = rotation == 2 or rotation == 4
                    end
                    local backing = lookup[wx .. ":" .. wy .. ":0"]
                    local info = SpriteConfigManager.GetObjectInfo("WoodenWallLvl1")
                    local sprite = info:getFace(north and "n" or "w"):getTileInfo(0, 0, 0):getSpriteName()
                    local wall
                    if (route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") and variant > 4 then
                        wall = IsoObject.new(backing, sprite, "wall")
                    else
                        wall = savedThumpable.new(cell, backing, sprite, north)
                    end
                    GameEntityFactory.CreateIsoObjectEntity(wall, info:getScript():getParent(), true)
                    if instanceof(wall, "IsoThumpable") then wall:setMaxHealth(450); wall:setHealth(450); wall:setIsThumpable(true) end
                    backing:getObjects():add(wall); backing:getSpecialObjects():add(wall)
                    backing:RecalcProperties()
                end
                local item = player:getInventory():AddItem(profile[1])
                local decoy = player:getInventory():AddItem(profile[1])
                local companion = profile[3] and player:getInventory():AddItem(profile[1]) or nil
                item:setCondition(37)
                if companion then companion:setCondition(63) end
                local action = Action:new(player, item, companion, route, rotation, x, y, 0)
                action.elapsed = profile[2]
                assert(action:isValid(), "Full placement invalid: " .. route .. " server=" .. tostring(server) .. " cheat=" .. tostring(cheat) .. " variant=" .. variant)
                assert(action:complete(), "Full construction failed: " .. route)
                assert(not player:getInventory():contains(item) and player:getInventory():contains(decoy), "Exact portable input/decoy mismatch: " .. route)
                if companion then assert(not player:getInventory():contains(companion), "Companion not removed") end
                assert(not action:complete(), "Completed placement replay accepted")
                if route ~= "OMHTTBarbs" then
                    assert(square:getSpecialObjects():size() > 0, "No native object survived completion: " .. route)
                end
                if (route == "OMHTTDeployTether" or route == "OMHTTDeployLever" or route == "OMHTTDeployLaser") then
                    local found = false
                    for n=0,square:getSpecialObjects():size()-1 do
                        local object = square:getSpecialObjects():get(n)
                        local state = require("OMHTT/ControlWorld").state(object)
                        if state and (state.kind == "Tether" or state.kind == "Lever" or state.kind == "Laser") then
                            assert(object:getHealth() == 37, "Tether condition lost")
                            assert(require(state.kind == "Tether" and "OMHTT/TetherMount" or "OMHTT/ControlMount").resolve(x, y, 0, state.facing), "Placed Tether lost backing wall")
                            found = true
                        end
                    end
                    assert(found, "Tether identity lost")
                end
                player:getInventory():Remove(decoy)
                completed = completed + 1
              end
            end
        end
    end
    getCell, isServer, getSpecificPlayer, IsoThumpable = savedCell, savedServer, savedPlayer, savedThumpable
    player:setBuildCheat(oldCheat)
    player:setX(oldX); player:setY(oldY); player:setZ(oldZ); player:setCurrent(oldSquare)
    assert(completed == 148, "Missing placement execution cases")
    print("[OMHTT-C373] native-placement-complete cases=148 branches=sp/server cheat=on/off exact-items=retained condition=37 replay=blocked")
end
