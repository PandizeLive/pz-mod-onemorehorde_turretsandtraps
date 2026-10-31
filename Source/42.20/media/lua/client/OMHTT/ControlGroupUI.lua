if isServer() then return end
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local G = {}

---@param panel ISPanel Controller
---@param command string Operation
---@param group string? Group identity
---@param before string? Insertion point
---@param name string? New label
---@param target IsoObject? Moved device
---@return nil
function G.request(panel, command, group, before, name, target)
    local state = A.state(panel.object)
    if not state or not A.write(panel.player, state) or panel.groupPending then return end
    local revision = state.organization and state.organization.revision or 0
    local value = tostring(revision) .. "|" .. (group or "") .. "|" .. (before or "") .. "|" .. (name or "")
    if string.find(name or "", "[|%c<>]") then return end
    local targetState = target and A.state(target)
    local expected = require("OMHTT/ControlGroups").propose({object = panel.object, character = panel.player,
        command = command, value = value, target = target, targetId = targetState and targetState.id})
    if not expected then return end
    U.command(panel.player, panel.object, command, value, target)
    panel.graph.notice = "UI_OMHTT_ChangePending"
    panel.groupPending = {revision = revision, expires = getTimestampMs() + 5000, expected = expected,
        target = targetState and targetState.id, group = group, before = before}
    getSoundManager():playUISound("UIActivateButton")
end

---@param pending table Submitted edit
---@param data table Replicated organization
---@return boolean applied
function G.applied(pending, data)
    if data.revision ~= pending.expected.revision then return false end
    if pending.target then
        if (data.members[pending.target] or "") ~= (pending.group or "") then return false end
        local position
        for i = 1, #data.order do
            if data.order[i] == pending.target then
                position = i
            end
        end
        if not position then return false end
        return pending.before and data.order[position + 1] == pending.before or not pending.before and position == #data.order
    end
    if #data.groups ~= #pending.expected.groups then return false end
    for i = 1, #data.groups do
        local actual, expected = data.groups[i], pending.expected.groups[i]
        if actual.id ~= expected.id or actual.name ~= expected.name then return false end
    end
    return true
end

---@param panel ISPanel Controller
---@param button ISButton Modal result
---@param group table? Renamed group
---@return nil
function G.named(panel, button, group)
    if button.internal ~= "OK" then return end
    local name = button.parent.entry:getText()
    G.request(panel, group and "GroupName" or "GroupAdd", group and group.id, nil, name)
end

---@param panel ISPanel Controller
---@param group table? Existing group
---@return nil
function G.rename(panel, group)
    require("ISUI/ISTextBox")
    local modal = ISTextBox:new(0, 0, 300, 180, getText("UI_OMHTT_GroupName"), group and group.name or "",
        panel, G.named, panel.player:getPlayerNum(), group)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

---@param panel ISPanel Controller
---@param group table Existing group
---@return nil
function G.remove(panel, group)
    G.request(panel, "GroupDelete", group.id)
end

---@param graph ISPanel Connection graph
---@return nil
function G.layout(graph)
    local state = A.state(graph.owner.object)
    local data = state and state.organization or {groups = {}, members = {}, order = {}}
    local rank, known = {}, {}
    for i = 1, #data.groups do
        known[data.groups[i].id] = true
    end
    for i = 1, #data.order do
        rank[data.order[i]] = i
    end
    local function ordered(a, b)
        local first, second = rank[a.state.id] or 1000, rank[b.state.id] or 1000
        if first == second then return a.state.id < b.state.id end
        return first < second
    end
    table.sort(graph.triggers, ordered)
    table.sort(graph.defenses, ordered)
    graph.groups, graph.positions = {}, {}
    local y, header = graph.headerHeight, graph.owner.lineHeight + 14
    for i = 1, #data.groups + 1 do
        local entry = data.groups[i] or {id = "", name = getText("UI_OMHTT_Ungrouped")}
        local group = {id = entry.id, name = entry.name, y = y, header = header}
        graph.groups[#graph.groups + 1] = group
        local count = 0
        for side = 1, 2 do
            local rows = side == 1 and graph.triggers or graph.defenses
            local n = 0
            for j = 1, #rows do
                local row = rows[j]
                local membership = data.members[row.state.id]
                if (known[membership] and membership or "") == group.id then
                    row.group = group.id
                    row.collapsed = graph.collapsed[group.id] == true
                    row.y = row.collapsed and y or y + header + n * graph.rowHeight
                    n = n + 1
                    graph.positions[row.state.id] = j
                end
            end
            count = math.max(count, n)
        end
        group.height = header + (graph.collapsed[group.id] and 0 or math.max(1, count) * graph.rowHeight)
        y = y + group.height + 6
    end
    graph.contentHeight = y
end

---@param graph ISPanel Connection graph
---@param y number Local pointer Y
---@return table? group
function G.at(graph, y, headerOnly)
    if y < graph.headerHeight or y >= graph.height then return end
    local content = y - graph:getYScroll()
    for i = 1, #graph.groups do
        local group = graph.groups[i]
        if content >= group.y and content < group.y + (headerOnly and group.header - 2 or group.height) then return group end
    end
end

return G
