if isServer() then return end
local A = require("OMHTT/ControlAccess")
local B = require("OMHTT/ControlBatch")
local S = {}

---@param graph ISPanel Connections
---@return table ids Visible selected identities in graph order
function S.ids(graph)
    local rows = {}
    for _, row in pairs(graph.rowsByObject or {}) do
        if graph.selection and graph.selection[row.state.id] and not row.collapsed
            and A.visible(graph.owner.object, row.object) then
            rows[#rows + 1] = row
        end
    end
    table.sort(rows, function(a, b)
        if a.y ~= b.y then return a.y < b.y end
        return a.state.id < b.state.id
    end)
    local ids = {}
    for i = 1, #rows do
        ids[i] = rows[i].state.id
    end
    return ids
end

---@param graph ISPanel Connections
---@return nil
function S.reconcile(graph)
    local selected = {}
    local ids = S.ids(graph)
    for i = 1, #ids do
        selected[ids[i]] = true
    end
    if graph.owner.scanIndex ~= nil then
        local discovery = require("OMHTT/ControlDiscovery")
        for id in pairs(graph.selection or {}) do
            local object = discovery.byId[id]
            if object and not graph.rowsByObject[object] and object:getObjectIndex() >= 0
                and A.visible(graph.owner.object, object) then
                selected[id] = true
            end
        end
    end
    graph.selection, graph.selectionCount = selected, #ids
end

---@param panel ISPanel Controller
---@param mode string Assign or Unassign
---@param group table Group under context menu
---@return nil
function S.assignGroup(panel, mode, group)
    local ids = {}
    for _, row in pairs(panel.graph.rowsByObject) do
        if row.group == group.id and A.visible(panel.object, row.object) then
            ids[#ids + 1] = row.state.id
        end
    end
    table.sort(ids)
    S.submit(panel, mode, nil, nil, ids)
end

---@param graph ISPanel Connections
---@param row table Device card
---@param toggle boolean Ctrl modifier
---@return nil
function S.select(graph, row, toggle)
    graph.selection = graph.selection or {}
    if toggle then
        graph.selection[row.state.id] = not graph.selection[row.state.id] or nil
    elseif not graph.selection[row.state.id] then
        graph.selection = {[row.state.id] = true}
    end
    S.reconcile(graph)
end

---@param graph ISPanel Connections
---@param x number Viewport X
---@param y number Viewport Y
---@return nil
function S.box(graph, x, y)
    local box = graph.selectionBox
    if not box then return end
    local scroll, half = graph:getYScroll(), (graph.width - 88) / 2
    local left, right = math.min(box.x, x), math.max(box.x, x)
    local top, bottom = math.min(box.y, y - scroll), math.max(box.y, y - scroll)
    local selected = {}
    for id in pairs(box.initial) do
        selected[id] = true
    end
    for side = 1, 2 do
        local rows = side == 1 and graph.triggers or graph.defenses
        local cardX = side == 1 and 4 or half + 74
        for i = 1, #rows do
            local row = rows[i]
            if not row.collapsed and row.y + scroll < graph.height and row.y + graph.rowHeight + scroll > graph.headerHeight
                and cardX < right and cardX + half - 4 > left
                and row.y < bottom and row.y + graph.rowHeight > top then
                selected[row.state.id] = true
            end
        end
    end
    graph.selection = selected
    S.reconcile(graph)
end

---@param panel ISPanel Controller
---@param mode string Move, Assign or Unassign
---@param group string? Destination group
---@param before string? Destination card
---@param ids table? Explicit single-card or group selection
---@return nil
function S.submit(panel, mode, group, before, ids)
    local graph, host = panel.graph, A.state(panel.object)
    if not host or panel.groupPending or B.pending[panel.player] then return end
    ids = ids or S.ids(graph)
    if #ids == 0 then return end
    if #ids > 64 then
        graph.notice, graph.batchNotice = "UI_OMHTT_BatchLimit", nil
        return
    end
    B.serial = B.serial % 2147483647 + 1
    local value = {mode = mode, group = group or "", before = before or "", ids = ids,
        revision = host.organization and host.organization.revision or 0, serial = B.serial, player = panel.player:getPlayerNum()}
    local action = require("OMHTT/ControlAction"):new(panel.player, panel.object, "Batch", value)
    if not action:isValid() then return end
    B.pending[panel.player] = {serial = value.serial, controller = host.id, expires = getTimestampMs() + 10000, panel = panel}
    graph.notice, graph.batchNotice = "UI_OMHTT_ChangePending", nil
    ISTimedActionQueue.add(action)
    getSoundManager():playUISound("UIActivateButton")
end

---@param panel ISPanel Controller
---@return nil
function S.refresh(panel)
    local pending = B.pending[panel.player]
    if not pending or pending.panel ~= panel then return end
    local result = pending.result
    if result then
        local reasons = {}
        local keys = {"Stale", "Missing", "Access", "OtherController", "Unassigned", "Range", "Broken", "Power", "Capacity"}
        for i = 1, #keys do
            local key = keys[i]
            if result.reasons[key] then
                reasons[#reasons + 1] = getText("UI_OMHTT_Batch" .. key) .. ": " .. result.reasons[key]
            end
        end
        panel.graph.batchNotice = getText("UI_OMHTT_BatchResult", result.applied, result.skipped)
        if #reasons > 0 then
            panel.graph.batchNotice = panel.graph.batchNotice .. " - " .. table.concat(reasons, ", ")
        end
        panel.graph.notice = nil
        panel.graph.refreshDue = 0
        B.pending[panel.player] = nil
    elseif getTimestampMs() >= pending.expires then
        panel.graph.notice = "UI_OMHTT_ChangeRejected"
        B.pending[panel.player] = nil
    end
end

---@param panel ISPanel Controller
---@param group table Group under context menu
---@return nil
function S.group(panel, group)
    panel.graph.selection = {}
    for _, row in pairs(panel.graph.rowsByObject) do
        if row.group == group.id then
            panel.graph.selection[row.state.id] = true
        end
    end
    panel.graph.collapsed[group.id] = nil
    panel.graph.refreshDue = 0
end

return S
