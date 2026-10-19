local G = {}
local A = require("OMHTT/ControlAccess")

---@param state table Controller state
---@return table organization Detached snapshot
function G.copy(state)
    local data = state.organization or {revision = 0, serial = 0, groups = {}, members = {}, order = {}}
    local copy = {revision = data.revision, serial = data.serial, groups = {}, members = {}, order = {}}
    for i = 1, #data.groups do
        copy.groups[i] = {id = data.groups[i].id, name = data.groups[i].name}
    end
    for id, group in pairs(data.members) do
        copy.members[id] = group
    end
    for i = 1, #data.order do
        copy.order[i] = data.order[i]
    end
    return copy
end

---@param action table Validated control action
---@return table? data New layout
function G.propose(action)
    local state = A.state(action.object)
    if not state or state.kind ~= "Controller" or not A.near(action.character, action.object)
        or not A.write(action.character, state) or type(action.value) ~= "string" or #action.value > 240 then return nil end
    local revision, group, before, name = string.match(action.value, "^(%d+)|([^|]*)|([^|]*)|([^|]*)$")
    if not revision then return nil end
    local data = G.copy(state)
    if tonumber(revision) ~= data.revision then return nil end
    local index
    for i = 1, #data.groups do
        if data.groups[i].id == group then
            index = i
        end
    end
    local command = action.command
    if command == "GroupAdd" or command == "GroupName" then
        if #name == 0 or #name > 48 or string.find(name, "[%c<>]") then return nil end
        if command == "GroupAdd" then
            if #data.groups >= 32 then return nil end
            data.serial = data.serial + 1
            data.groups[#data.groups + 1] = {id = tostring(data.serial), name = name}
        else
            if not index then return nil end
            data.groups[index].name = name
        end
    elseif command == "GroupDelete" then
        if not index then return nil end
        table.remove(data.groups, index)
        for id, assigned in pairs(data.members) do
            if assigned == group then
                data.members[id] = nil
            end
        end
    elseif command == "GroupMove" then
        if not index or group == before then return nil end
        local moved = table.remove(data.groups, index)
        local destination = #data.groups + 1
        if before ~= "" then
            destination = nil
            for i = 1, #data.groups do
                if data.groups[i].id == before then
                    destination = i
                end
            end
        end
        if not destination then return nil end
        table.insert(data.groups, destination, moved)
    elseif command == "DeviceMove" then
        local target = A.state(action.target)
        if not target or target.id ~= action.targetId or target.controller ~= state.id
            or (group ~= "" and not index) or not A.write(action.character, target)
            or not A.range(action.object, action.target) then return nil end
        local world = not isClient() and require("OMHTT/ControlWorld")
        local order = {}
        for i = 1, #data.order do
            local id = data.order[i]
            local record = world and world.records().records[id]
            if id ~= target.id and (not world or (record and record.placed and record.controller == state.id)) then
                order[#order + 1] = id
            else
                data.members[id] = nil
            end
        end
        if world then
            local remaining, present = {}, {}
            for i = 1, #order do
                present[order[i]] = true
            end
            for id, record in pairs(world.records().records) do
                if record.placed and record.controller == state.id and id ~= target.id and not present[id] then
                    remaining[#remaining + 1] = id
                    if #remaining + #order >= 64 then return nil end
                end
            end
            table.sort(remaining)
            for i = 1, #remaining do
                order[#order + 1] = remaining[i]
            end
        end
        if #order >= 64 then return nil end
        local position = #order + 1
        for i = 1, #order do
            if order[i] == before then
                position = i
            end
        end
        table.insert(order, position, target.id)
        data.order = order
        data.members[target.id] = group ~= "" and group or nil
    else
        return nil
    end
    data.revision = data.revision + 1
    return data
end

return G
