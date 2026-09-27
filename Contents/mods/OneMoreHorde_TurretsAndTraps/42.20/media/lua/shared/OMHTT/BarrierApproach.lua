local F = require("OMHTT/Foundation")
local Approach = {}

---@param record table Barrier record
---@return table targets Accessible side coordinates
---@nodiscard
function Approach.targets(record)
    local targets = {}
    local nx, ny = F.barrierDirection(record.facing)
    for part = 0, 1 do
        local x, y = record.x - ny * part, record.y + nx * part
        if record.collisionModel == "outline-v1" then
            targets[#targets + 1] = {x = x, y = y}
            targets[#targets + 1] = {x = x + nx, y = y + ny}
            targets[#targets + 1] = {x = x - nx, y = y - ny}
        elseif record.collisionModel == "edge-v1" then
            targets[#targets + 1] = {x = x, y = y}
            if nx == 0 then
                targets[#targets + 1] = {x = x, y = y - 1}
            else
                targets[#targets + 1] = {x = x - 1, y = y}
            end
        else
            targets[#targets + 1] = {x = x + nx, y = y + ny}
            targets[#targets + 1] = {x = x - nx, y = y - ny}
        end
    end
    if record.collisionModel ~= "edge-v1" then
        targets[#targets + 1] = {x = record.x + ny, y = record.y - nx}
        targets[#targets + 1] = {x = record.x - ny * 2, y = record.y + nx * 2}
    end
    return targets
end

---@param player IsoPlayer Acting player
---@param record table Barrier record
---@return boolean ready On a service side
---@nodiscard
function Approach.ready(player, record)
    if math.floor(player:getZ()) ~= record.z then return false end
    local x, y = math.floor(player:getX()), math.floor(player:getY())
    local targets = Approach.targets(record)
    for i = 1, #targets do
        if targets[i].x == x and targets[i].y == y then return true end
    end
    return false
end

---@param player IsoPlayer Acting player
---@param record table Barrier record
---@return table? route Cardinal, collision-checked walking waypoints
---@nodiscard
function Approach.route(player, record)
    local from = player:getCurrentSquare()
    if not from or from:getZ() ~= record.z then return nil end
    if Approach.ready(player, record) then return {} end
    local targets = Approach.targets(record)
    local queue = {{square = from}}
    local seen = {[F.key(from:getX(), from:getY(), record.z)] = true}
    local cursor = 1
    local steps = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
    while cursor <= #queue and cursor <= 169 do
        local node = queue[cursor]
        for i = 1, #targets do
            if node.square:getX() == targets[i].x and node.square:getY() == targets[i].y then
                local route = {}
                while node.previous do
                    table.insert(route, 1, node.square)
                    node = queue[node.previous]
                end
                return route
            end
        end
        for i = 1, #steps do
            local dx, dy = steps[i][1], steps[i][2]
            local x, y = node.square:getX() + dx, node.square:getY() + dy
            local key = F.key(x, y, record.z)
            if not seen[key] and math.abs(x - from:getX()) <= 6 and math.abs(y - from:getY()) <= 6 then
                seen[key] = true
                local square = getCell():getGridSquare(x, y, record.z)
                if square and square:getFloor() and square:isFree(false) and not square:HasStairs()
                    and not square:HasStairsBelow() and not square:has(IsoFlagType.water)
                    and not square:isVehicleIntersecting()
                    and not node.square:testCollideAdjacent(player, dx, dy, 0) then
                    queue[#queue + 1] = {square = square, previous = cursor}
                end
            end
        end
        cursor = cursor + 1
    end
    return nil
end

return Approach
