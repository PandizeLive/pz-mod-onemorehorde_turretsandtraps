local A = require("OMHTT/ControlAccess")
local C = require("OMHTT/ControlDefinitions")
local G = require("OMHTT/ControlGroups")
local B = {pending = setmetatable({}, {__mode = "k"}), serial = 0}

---@param action table Control action
---@return boolean valid
function B.valid(action)
    local host, value = A.state(action.object), action.value
    if not host or host.kind ~= "Controller" or not A.near(action.character, action.object)
        or not A.write(action.character, host) or type(value) ~= "table"
        or (value.mode ~= "Move" and value.mode ~= "Assign" and value.mode ~= "Unassign")
        or type(value.revision) ~= "number" or value.revision < 0 or value.revision ~= math.floor(value.revision)
        or type(value.serial) ~= "number" or value.serial < 1 or value.serial > 2147483647 or value.serial ~= math.floor(value.serial)
        or type(value.player) ~= "number" or value.player < 0 or value.player > 3 or value.player ~= math.floor(value.player)
        or type(value.group) ~= "string" or #value.group > 48
        or type(value.before) ~= "string" or #value.before > 80
        or type(value.ids) ~= "table" or #value.ids < 1 or #value.ids > 64 then return false end
    local seen = {}
    for key, id in pairs(value.ids) do
        if type(key) ~= "number" or key < 1 or key > #value.ids or key ~= math.floor(key)
            or type(id) ~= "string" or #id > 80 or #id == 0 or seen[id] then return false end
        seen[id] = true
    end
    return true
end

---@param module string Namespace
---@param command string Response
---@param args table Server receipt
---@return nil
function B.response(module, command, args)
    if module ~= "OMHTT_ControlBatch" or command ~= "Result" or type(args) ~= "table" then return end
    local player = getSpecificPlayer(args.player)
    local pending = player and B.pending[player]
    if pending and pending.serial == args.serial and pending.controller == args.controller then
        pending.result = args
    end
end

---@param action table Validated authoritative action
---@return boolean completed
function B.complete(action)
    if isClient() or not B.valid(action) then return false end
    local W = require("OMHTT/ControlWorld")
    local host, value = W.state(action.object), action.value
    local data = G.copy(host)
    local result = {serial = value.serial, controller = host.id, player = value.player, applied = 0, skipped = 0, reasons = {}}
    local groupValid = value.group == ""
    for i = 1, #data.groups do
        if data.groups[i].id == value.group then
            groupValid = true
        end
    end
    local stale = data.revision ~= value.revision or (value.mode == "Move" and not groupValid)
    local records, counts = W.records().records, {inputs = 0, defenses = 0}
    for _, state in pairs(records) do
        if state.placed and state.controller == host.id then
            local key = C.defense(state.kind) and "defenses" or "inputs"
            counts[key] = counts[key] + 1
        end
    end
    local moved = {}
    for i = 1, #value.ids do
        local id = value.ids[i]
        local object = W.objects[id]
        local state = object and W.state(object)
        local reason
        if stale then
            reason = "Stale"
        elseif not state or state.id ~= id or not state.placed or object:getObjectIndex() < 0
            or not (C.inputs[state.kind] or C.defense(state.kind)) then
            reason = "Missing"
        elseif not A.visible(action.object, object) or not A.write(action.character, state) then
            reason = "Access"
        elseif state.controller and state.controller ~= host.id then
            reason = "OtherController"
        elseif value.mode == "Unassign" then
            if state.controller ~= host.id then
                reason = "Unassigned"
            elseif not W.assign(action.object, object, action.character, false, counts) then
                reason = "Missing"
            end
        elseif not A.range(action.object, object) then
            reason = "Range"
        elseif object:getHealth() <= 0 then
            reason = "Broken"
        elseif state.controller ~= host.id then
            local key = C.defense(state.kind) and "defenses" or "inputs"
            if host.powered ~= true then
                reason = "Power"
            elseif counts[key] >= 32 then
                reason = "Capacity"
            elseif not W.assign(action.object, object, action.character, true, counts) then
                reason = "Missing"
            end
        end
        if reason then
            result.skipped = result.skipped + 1
            result.reasons[reason] = (result.reasons[reason] or 0) + 1
        else
            result.applied = result.applied + 1
            if value.mode == "Move" then
                moved[#moved + 1] = id
            end
        end
    end
    if #moved > 0 then
        G.move(data, moved, value.group, value.before, records, host.id)
        host.organization = data
        W.publish(action.object)
    elseif value.mode == "Unassign" and result.applied > 0 then
        W.publish(action.object)
    end
    if isServer() then
        sendServerCommand(action.character, "OMHTT_ControlBatch", "Result", result)
    else
        local pending = B.pending[action.character]
        if pending and pending.serial == result.serial then
            pending.result = result
        end
    end
    return true
end

if isClient() then
    Events.OnServerCommand.Add(B.response)
end
return B
