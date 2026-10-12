if isClient() or isServer() then return end
local E
local Clock = require("OMHTT/TurretClock")
local Budget = require("OMHTT/TurretScheduler")
local markers, due, cursor = {}, 0, 1

---@return nil
local function update()
    local now = Clock.now()
    if now < due then return end
    due = now + 100
    local count, created, deadline = 0, 0, Budget.limit(1)
    local player = getSpecificPlayer(0)
    for id, marker in pairs(markers) do
        local field = E.fields[id]
        if not player or not field or now < field.starts or now >= field.expires or field.z ~= math.floor(player:getZ())
            or (field.x - player:getX()) ^ 2 + (field.y - player:getY()) ^ 2 >= 900 then
            marker:remove()
            markers[id] = nil
        else
            count = count + 1
        end
    end
    if player and count < 32 then
        for _ = 1, math.min(32, #E.fieldOrder) do
            if created >= 4 or count >= 32 or getTimestampMs() >= deadline then break end
            if cursor > #E.fieldOrder then cursor = 1 end
            local field = E.fieldOrder[cursor]
            cursor = cursor + 1
            local dx, dy = field.x - player:getX(), field.y - player:getY()
            if not markers[field.id] and now >= field.starts and now < field.expires and field.z == math.floor(player:getZ()) and dx * dx + dy * dy < 900 then
                local square = getCell():getGridSquare(math.floor(field.x), math.floor(field.y), field.z)
                if square and square:isCanSee(0) then
                    local marker = getWorldMarkers():addGridSquareMarker(square, .65, .65, .65, false, field.radius * 2)
                    marker:setScaleCircleTexture(true)
                    markers[field.id] = marker
                    count, created = count + 1, created + 1
                end
            end
        end
    end
end

Events.OnGameStart.Add(function()
    E = require("OMHTT/TurretProc")
    Budget.register("TurretTackMarkers.update", update)
end)
