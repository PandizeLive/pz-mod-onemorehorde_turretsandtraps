local Ammo = require("OMHTT/TurretAmmo")
local Void = require("OMHTT/TurretVoid")
local State = require("OMHTT/TurretItemState")
local Cycle = require("OMHTT/TurretCycle")
local G = require("OMHTT/Firearms")
local F = {}
local groupCache = setmetatable({}, {__mode = "k"})
F.BOMBS = {"Base.OMHTTAmmoMakeshiftBomb", "Base.Aerosolbomb", "Base.PipeBomb"}

---@param contents table Inventory summary
---@param fullType string Exact ammunition identity
---@return number count Physical items of this type
---@nodiscard
function F.physical(contents, fullType)
    local count = 0
    for i = 1, #contents.rounds do
        if contents.rounds[i]:getFullType() == fullType then
            count = count + 1
        end
    end
    return count
end

---@param contents table Inventory summary
---@param container ItemContainer Owning storage
---@return string? fullType Homogeneous ready payload or next requested type
---@nodiscard
function F.select(contents, container)
    local head = contents.head
    if not head then return nil end
    if G.profile(head) then return G.ammoType(head) end
    local cycle = State.get(head, "cycle")
    if cycle and cycle.loaded and cycle.loaded > 0 and cycle.payload then return cycle.payload end
    local state = require("OMHTT/Turret").state(container:getParent())
    local selected = require("OMHTT/TurretLoadOrder").select(contents, state)
    if selected then return selected end
    local definition = require("OMHTT/TurretHeads").get(head)
    return definition and definition.ammo or "Base.Potato"
end

---@param head InventoryItem Exact head
---@return nil
function F.cancel(head)
    if isClient() or not head then return end
    local cycle = State.get(head, "cycle")
    if not cycle then return end
    cycle.loaded, cycle.pending, cycle.reloadReady, cycle.rackReady = 0, nil, nil, nil
    cycle.virtual, cycle.moduleId, cycle.descriptor, cycle.payload = nil, nil, nil, nil
    cycle.suppressImpactReload, cycle.virtualRack = true, nil
    cycle.manualImpactReady = nil
    -- Service cannot manufacture a new first-shot entitlement.
    require("OMHTT/TurretImpactCycle").consume(cycle)
end

---@param contents table Inventory summary
---@param cycle table Bound ready state
---@return table? group Exact stored quality descriptor
---@nodiscard
function F.group(contents, cycle)
    if not contents.void or contents.void:getID() ~= cycle.moduleId then return nil end
    local data = Void.data(contents.void)
    if not data or not cycle.descriptor then return nil end
    local cached = groupCache[cycle]
    if cached and cached.data == data and cached.group.count > 0 and Void.same(cached.group, cycle.descriptor) then
        return cached.group
    end
    for i = 1, #data.groups do
        local group = data.groups[i]
        if group.count > 0 and Void.same(group, cycle.descriptor) then
            groupCache[cycle] = {data = data, group = group}
            return group
        end
    end
end

---@param contents table Inventory summary
---@param stats table Current effective settings
---@param now number Active milliseconds
---@param operate boolean Powered feeder may reload
---@return table cycle Exact-head ready state; virtual rounds never enter native magazine fields
---@return string status
function F.update(contents, stats, now, operate)
    if isClient() then return nil, "Unavailable" end
    local head = contents.head
    local cycle = State.get(head, "cycle", {schema = 1, loaded = 0, nextShot = 0})
    local firearm = G.profile(head)
    if firearm and (not contents.void or G.loaded(head) > 0 or (not cycle.virtual and contents.reserve > 0)) then
        if cycle.virtual then
            F.cancel(head)
        end
        return G.update(contents, stats, now, operate)
    end
    local owner = require("OMHTT/Turret").state(head:getContainer():getParent())
    if owner and not require("OMHTT/Turret").isOn(owner) then return cycle, "Off" end
    if firearm then
        if G.servicing[head] then return cycle, "Servicing" end
        if not G.enabled() then return cycle, "Disabled" end
        if head:isJammed() then return cycle, "Jammed" end
        if head:getMagazineType() and not head:isContainsClip() then return cycle, "NoMagazine" end
        local native = G.state(head)
        cycle.nextShot = math.max(cycle.nextShot or 0, native.nextShot or 0)
    end
    if cycle.virtual and not F.group(contents, cycle) then
        F.cancel(head)
    end
    if not cycle.payload and (cycle.loaded or 0) > 0 then
        cycle.payload = F.select(contents, head:getContainer())
    end
    if (cycle.loaded or 0) == 0 and not cycle.reloadReady then
        cycle.virtual, cycle.moduleId, cycle.descriptor = nil, nil, nil
        cycle.payload = nil
        local fullType = F.select(contents, head:getContainer())
        cycle.payload = fullType
        local physical = fullType and F.physical(contents, fullType) or 0
        if physical == 0 or firearm then
            local _, group = Void.count(contents.void, head, fullType)
            if group then
                cycle.virtual, cycle.moduleId = true, contents.void:getID()
                cycle.descriptor = {}
                for key, value in pairs(group) do
                    if key ~= "count" then
                        cycle.descriptor[key] = value
                    end
                end
            end
        end
    end
    contents.payloadType = cycle.payload
    local group = cycle.virtual and F.group(contents, cycle)
    local amount = group and group.count or (cycle.payload and F.physical(contents, cycle.payload) or 0)
    if cycle.virtual and not group then
        amount = 0
    end
    local config = stats
    if firearm then
        config = {}
        for key, value in pairs(stats) do config[key] = value end
        if not head:getMagazineType() then
            config.reload = config.reload * math.min(config.magazine, amount)
        end
    end
    if not operate and (cycle.loaded or 0) == 0 then return cycle, amount > 0 and "Reloading" or "Empty" end
    local status = Cycle.update(cycle, amount, config, now)
    if firearm and status == "Ready" and head:haveChamber() and cycle.virtualRack ~= true then
        if not cycle.rackReady then
            cycle.rackReady = now + stats.rack
        end
        if now < cycle.rackReady then return cycle, "Racking" end
        cycle.rackReady, cycle.virtualRack = nil, true
    end
    if cycle.suppressImpactReload and cycle.loaded > 0 then
        cycle.impactReady = cycle.manualImpactReady == true
        cycle.suppressImpactReload, cycle.manualImpactReady = nil, nil
    end
    cycle.status = status
    return cycle, status
end

---@param contents table Current inventory summary
---@param cycle table Ready state
---@return table? descriptor Selected quality and payload snapshot
---@nodiscard
function F.descriptor(contents, cycle)
    if cycle.virtual then return F.group(contents, cycle) end
    for i = 1, #contents.rounds do
        local item = contents.rounds[i]
        if item:getFullType() == cycle.payload then return Ammo.describe(item) end
    end
end

---@param contents table Current inventory summary
---@param stats table Effective settings
---@param cycle table Ready state returned by update
---@param now number Active milliseconds
---@return boolean committed
---@return number cost Whole rounds charged
function F.consume(contents, stats, cycle, now)
    if isClient() or not cycle or (cycle.loaded or 0) < 1 then return false, 0 end
    if G.profile(contents.head) and not cycle.virtual then return G.consume(contents, stats, now) end
    local uses = math.min(cycle.loaded, 1 + stats.splitter)
    local cost
    if cycle.virtual then
        local group = F.group(contents, cycle)
        if not group then return false, 0 end
        local success
        success, cost = Void.consume(contents.void, group, uses, stats.conservation)
        if not success then return false, 0 end
        State.publish(contents.void)
    else
        if F.physical(contents, cycle.payload) < uses then return false, 0 end
        cycle.debts = cycle.debts or {}
        cycle.conservationDebt = cycle.debts[cycle.payload] or 0
        cost = require("OMHTT/TurretConservation").consume(cycle, uses, stats.conservation)
        cycle.debts[cycle.payload] = cycle.conservationDebt
        local spent, kept = 0, 0
        local storage = contents.head:getContainer()
        for i = 1, #contents.rounds do
            local item = contents.rounds[i]
            if spent < cost and item:getFullType() == cycle.payload and storage:contains(item) then
                storage:Remove(item)
                if isServer() then
                    sendRemoveItemFromContainer(storage, item)
                end
                spent = spent + 1
            else
                kept = kept + 1
                contents.rounds[kept] = item
            end
        end
        for i = #contents.rounds, kept + 1, -1 do contents.rounds[i] = nil end
        contents.reserve = contents.reserve - spent
    end
    require("OMHTT/TurretImpactCycle").consume(cycle)
    cycle.loaded = math.max(0, cycle.loaded - cost)
    cycle.nextShot, cycle.cooldownDuration = now + stats.cooldown, stats.cooldown
    if cycle.loaded == 0 then
        cycle.pending, cycle.reloadReady, cycle.virtualRack = nil, nil, nil
        F.update(contents, stats, now, true)
    elseif G.profile(contents.head) and contents.head:isRackAfterShoot() and cost > 0 then
        cycle.virtualRack = nil
        cycle.rackReady = now + stats.rack
    end
    if G.profile(contents.head) then
        G.state(contents.head).nextShot = cycle.nextShot
    end
    return true, cost
end

return F
