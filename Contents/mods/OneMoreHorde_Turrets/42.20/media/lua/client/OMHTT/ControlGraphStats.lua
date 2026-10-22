if isServer() then return end
local S = {}

---@param graph ISPanel Connection list
---@return nil
function S.step(graph)
    if #graph.defenses == 0 or getTimestampMs() < graph.statsDue then return end
    local job = graph.statsJob
    if not job then
        if graph.statsIndex > #graph.defenses then
            graph.statsIndex, graph.statsDue = 1, getTimestampMs() + 1000
            return
        end
        local object = graph.defenses[graph.statsIndex].object
        local container = object:getObjectIndex() >= 0 and object:getContainer()
        graph.statsIndex = graph.statsIndex + 1
        local state = require("OMHTT/ControlAccess").state(object)
        if state and state.kind == "Tether" then
            graph.stats[object] = {label = getText("UI_OMHTT_TetherAmmo")}
            return
        end
        if not container then return end
        if state and state.kind == "Poke" then
            graph.stats[object] = {label = getText("UI_OMHTT_PokeContact")}
            return
        end
        job = {object = object, container = container, index = 0, count = container:getItems():size(), rounds = {}, kinds = {}}
        graph.statsJob = job
    end
    if job.object:getObjectIndex() < 0 or job.object:getContainer() ~= job.container
        or job.count ~= job.container:getItems():size() then
        graph.statsJob = nil
        graph.statsIndex = math.max(1, graph.statsIndex - 1)
        return
    end
    local T = require("OMHTT/Turret")
    local items, deadline = job.container:getItems(), getTimestampMs() + 1
    for i = 1, 128 do
        if job.index >= job.count then break end
        local item = items:get(job.index)
        job.index = job.index + 1
        local fullType = item:getFullType()
        local kind = job.kinds[fullType]
        if kind == nil then
            kind = T.kind(item) or false
            job.kinds[fullType] = kind
        end
        if kind == "head" then
            job.head = item
        elseif kind == "ammo" then
            job.rounds[fullType] = (job.rounds[fullType] or 0) + 1
        elseif fullType == "Base.OMHTTModuleVoid" and item:getCondition() > 0 then
            job.void = item
        end
        if getTimestampMs() >= deadline then return end
    end
    if job.index < job.count then return end
    local Ammo = require("OMHTT/TurretAmmo")
    local total = 0
    for fullType, count in pairs(job.rounds) do
        if Ammo.accepts(job.head, fullType) then
            total = total + count
        end
    end
    local G = require("OMHTT/Firearms")
    if G.profile(job.head) then
        total = math.max(0, total - require("OMHTT/FirearmFeed").count(job.head)) + G.loaded(job.head)
    end
    total = total + require("OMHTT/TurretVoid").count(job.void, job.head)
    local definition = require("OMHTT/TurretHeads").get(job.head)
    local label = getText("UI_OMHTT_GraphAmmo", total)
    if not job.head or (definition and definition.rotary) then
        label = getText("UI_OMHTT_GraphAmmoNone")
    end
    graph.stats[job.object] = {label = label, ammo = total}
    graph.statsJob = nil
end

return S
