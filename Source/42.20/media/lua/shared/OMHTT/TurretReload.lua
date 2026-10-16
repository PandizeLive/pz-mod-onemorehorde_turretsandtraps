local G = require("OMHTT/Firearms")
local State = require("OMHTT/TurretItemState")
local Feed = require("OMHTT/TurretFeed")
local Extension = require("OMHTT/FirearmFeed")
local Order = require("OMHTT/TurretLoadOrder")
local Void = require("OMHTT/TurretVoid")
local T = require("OMHTT/Turret")
local R = {}

---@param contents table Inventory snapshot
---@param stats table Effective settings
---@return boolean allowed
function R.allowed(contents, stats)
    local head = contents.head
    if not head or stats.rotary or head:getCondition() <= 0 then return false end
    local cycle = State.get(head, "cycle")
    if G.profile(head) and not (cycle and cycle.virtual) then
        local gun = State.get(head, "gun")
        return not G.servicing[head] and not head:isJammed()
            and (not head:getMagazineType() or head:isContainsClip())
            and not (gun and (gun.reloadReady or gun.rackReady))
            and contents.reserve > 0 and head:getCurrentAmmoCount() + Extension.count(head) < stats.magazine
    end
    if contents.ammo <= 0 or (cycle and (cycle.reloadReady or cycle.rackReady)) then return false end
    local selected = Order.select(contents, T.state(head:getContainer():getParent()))
    if not selected then return false end
    if not cycle or (cycle.loaded or 0) == 0 or cycle.payload ~= selected then return true end
    local available = Feed.physical(contents, selected)
    if available == 0 or G.profile(head) then
        local count, group = Void.count(contents.void, head, selected)
        available = group and group.count or count
    end
    return cycle.loaded < math.min(stats.magazine, available)
end

---@param contents table Authoritative inventory
---@param stats table Effective tuning
---@param now number Active time
---@return boolean started
function R.start(contents, stats, now)
    if isClient() or not R.allowed(contents, stats) then return false end
    local head = contents.head
    local cycle = State.get(head, "cycle")
    if G.profile(head) and not (cycle and cycle.virtual) then
        local state = G.state(head)
        state.manualReload = true
        G.update(contents, stats, now, true)
    else
        local impactReady = cycle and cycle.impactReady == true
        Feed.cancel(head)
        if cycle then
            cycle.manualImpactReady = impactReady
        end
        Feed.update(contents, stats, now, true)
    end
    State.publish(head)
    return true
end

return R
