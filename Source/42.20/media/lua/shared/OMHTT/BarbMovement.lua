local M = {}

---@param actor IsoGameCharacter Moving actor
---@return boolean traversing Native climbing/falling movement must remain intact
function M.traversing(actor)
    return actor:isClimbing() or actor:isBumpFall() or actor:isKnockedDown() or actor:isRagdoll()
        or actor:isOnFloor() and not (instanceof(actor, "IsoZombie") and actor:isCrawling())
end

---@param actor IsoGameCharacter Actor after native deferred movement, before collision resolution
---@param divisor number Contact movement divisor
---@return nil
function M.apply(actor, divisor)
    if divisor <= 1 or M.traversing(actor) then return end
    -- Scale this update's pending displacement, never the actor's persistent speed.
    local x, y = actor:getX(), actor:getY()
    actor:setNextX(x + (actor:getNextX() - x) / divisor)
    actor:setNextY(y + (actor:getNextY() - y) / divisor)
end

return M
