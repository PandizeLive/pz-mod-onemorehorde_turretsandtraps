if isServer() then return end
local C = {pending = {}, cursor = 1, due = 0}

---@param action OMHTTControlTransferAction Completed action
---@return boolean finished
function C.finish(action)
    if action.cancelled or action.callbackDone or not action.onCompleteFunc or not action.item then return true end
    local destination = action:destination()
    if not destination then return true end
    local original = action.item
    local item = original:getContainer() == destination and original or destination:getItemWithID(original:getID())
    if not item then return false end
    local args = action.onCompleteArgs
    for i = 1, 8 do
        if args[i] == original then
            args[i] = item
        end
    end
    action.item, action.callbackDone = item, true
    action.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    return true
end

---@return nil
function C.update()
    local now = getTimestampMs()
    if now < C.due then return end
    C.due = now + 100
    for step = 1, math.min(4, #C.pending) do
        if C.cursor > #C.pending then
            C.cursor = 1
        end
        local entry = C.pending[C.cursor]
        if now >= entry.expires or C.finish(entry.action) then
            table.remove(C.pending, C.cursor)
        else
            C.cursor = C.cursor + 1
        end
    end
    if #C.pending == 0 and C.active then
        Events.OnTick.Remove(C.update)
        C.active = false
    end
end

---@param action OMHTTControlTransferAction Completed action
---@return nil
function C.complete(action)
    if C.finish(action) or not isClient() then return end
    C.update()
    for i = 1, #C.pending do
        if C.pending[i].action == action then return end
    end
    if #C.pending >= 32 then
        table.remove(C.pending, 1)
    end
    C.pending[#C.pending + 1] = {action = action, expires = getTimestampMs() + 5000}
    if not C.active then
        C.active = true
        Events.OnTick.Add(C.update)
    end
end

return C
