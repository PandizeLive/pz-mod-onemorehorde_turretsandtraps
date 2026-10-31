if isServer() then return end
local Flight = {}
local Line = require("OMHTT/DefenseLine")
local Protocol = require("OMHTT/DefenseCombatProtocol")

---@param effect table Server-announced cosmetic child flight
---@param now number Active milliseconds
---@return boolean contact Local presentation only; never health or rewards
function Flight.contact(effect, now)
    if not effect.contactFlight or effect.phase ~= "Launch" then return false end
    local dx, dy = effect.x - effect.fromX, effect.y - effect.fromY
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 or effect.flight <= 0 then return true end
    dx, dy = dx / length, dy / length
    local destination = length * math.max(0, math.min(1, (now - effect.start) / effect.flight))
    local distance = effect.contactDistance or 0
    local cell = getCell()
    local checked = 0
    local previous = cell:getGridSquare(math.floor(effect.fromX+dx*distance), math.floor(effect.fromY+dy*distance), effect.z)
    -- At most16 short segments per visible flight/frame. A late packet catches up
    -- over bounded frames; this never scans the global zombie list.
    for step = 1, 16 do
        if distance >= destination then break end
        local after = math.min(destination, distance + .5)
        local x, y = effect.fromX+dx*after, effect.fromY+dy*after
        local square = cell:getGridSquare(math.floor(x), math.floor(y), effect.z)
        if not square or not previous then return false end
        local contact
        if square ~= previous and not Line.clear(previous, square, 2) then
            contact = after
            if square:getX() ~= previous:getX() then
                local edge = previous:getX() + (dx > 0 and 1 or 0)
                contact = math.min(contact, (edge - effect.fromX) / dx)
            end
            if square:getY() ~= previous:getY() then
                local edge = previous:getY() + (dy > 0 and 1 or 0)
                contact = math.min(contact, (edge - effect.fromY) / dy)
            end
        end
        local ax, ay = effect.fromX+dx*distance, effect.fromY+dy*distance
        for sx = math.floor(math.min(ax,x)-.35), math.floor(math.max(ax,x)+.35) do
            for sy = math.floor(math.min(ay,y)-.35), math.floor(math.max(ay,y)+.35) do
                local tile = cell:getGridSquare(sx,sy,effect.z)
                local objects = tile and tile:getMovingObjects()
                for i = 0, math.min(objects and objects:size() or 0, 64)-1 do
                    checked = checked + 1
                    if checked > 128 then
                        -- Crowded paths defer to the server instead of stalling a
                        -- frame or inventing a collision after a partial scan.
                        effect.contactFlight = false
                        return false
                    end
                    local actor = objects:get(i)
                    if instanceof(actor,"IsoZombie") and not actor:isDead()
                        and not (actor:getOnlineID()==effect.excludeId
                            and Protocol.outfit(actor:getPersistentOutfitID())==effect.excludeOutfit) then
                        local rx, ry = actor:getX()-effect.fromX, actor:getY()-effect.fromY
                        local along = rx*dx+ry*dy
                        local across = math.abs(rx*dy-ry*dx)
                        if along >= distance and along <= after and across <= math.max(.2,actor:getWidth())
                            and Line.clear(previous,tile,2) and (not contact or along<contact) then contact=along end
                    end
                end
            end
        end
        if contact then
            effect.x, effect.y = effect.fromX+dx*contact, effect.fromY+dy*contact
            return true
        end
        distance, previous = after, square
    end
    effect.contactDistance = distance
    return distance >= length
end

return Flight
