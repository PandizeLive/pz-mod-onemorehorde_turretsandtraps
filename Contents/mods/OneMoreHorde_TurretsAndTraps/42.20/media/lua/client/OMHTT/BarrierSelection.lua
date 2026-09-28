if isClient() or isServer() then return end
local F = require("OMHTT/Foundation")
local Selection = {}

---@param record table Barrier identity
---@param x number Cursor world X
---@param y number Cursor world Y
---@return number distance Squared distance to its occupied footprint
local function distanceToFootprint(record, x, y)
    local nx, ny = F.barrierDirection(record.facing)
    local secondX, secondY = record.x - ny, record.y + nx
    local left, top = math.min(record.x, secondX), math.min(record.y, secondY)
    local right, bottom = math.max(record.x, secondX) + 1, math.max(record.y, secondY) + 1
    local dx = math.max(0, math.max(left - x, x - right))
    local dy = math.max(0, math.max(top - y, y - bottom))
    return dx * dx + dy * dy
end

---@param player IsoPlayer Local player
---@param worldobjects table Native picker objects
---@param x number Cursor world X
---@param y number Cursor world Y
---@return table entries Complete barriers, direct picks before nearby footprints
function Selection.collect(player, worldobjects, x, y)
    local Footprint = require("OMHTT/BarrierFootprint")
    local entries, seen = {}, {}
    local z = math.floor(player:getZ())
    local function add(object, source)
        local record = Footprint.exact(object)
        if not record or seen[record.id] or record.z ~= z or record.placementSource ~= "construction" then return end
        local distance = distanceToFootprint(record, x, y)
        if source == "footprint" and distance > 0.04 then return end
        local parts = Footprint.parts(record)
        if not parts then return end
        seen[record.id] = true
        entries[#entries + 1] = {record = record, object = parts[1], parts = parts, source = source, distance = distance}
    end
    for i = 1, #worldobjects do
        add(worldobjects[i], "native")
    end
    for sx = math.floor(x) - 1, math.floor(x) + 1 do
        for sy = math.floor(y) - 1, math.floor(y) + 1 do
            local square = getCell():getGridSquare(sx, sy, z)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    add(objects:get(i), "footprint")
                end
            end
        end
    end
    table.sort(entries, function(a, b)
        if a.source ~= b.source then return a.source == "native" end
        if a.distance ~= b.distance then return a.distance < b.distance end
        return a.record.id < b.record.id
    end)
    return entries
end

---@param option table Native context option
---@param menu ISContextMenu Owning menu
---@param active boolean Hover state
---@param parts table Exact visible parts
---@return nil
function Selection.highlight(option, menu, active, parts)
    local color = getCore():getWorldItemHighlightColor()
    for i = 1, #parts do
        local object = parts[i]
        if object:getObjectIndex() >= 0 then
            object:setHighlighted(menu.player, active, false)
            object:setHighlightColor(menu.player, color)
            object:setOutlineHighlight(menu.player, active)
            object:setOutlineHighlightCol(menu.player, color)
        end
    end
end

---@param option table Native context option
---@param parts table Exact visible parts
---@return nil
function Selection.bindHighlight(option, parts)
    option.onHighlight = Selection.highlight
    option.onHighlightParams = {parts}
end

return Selection
