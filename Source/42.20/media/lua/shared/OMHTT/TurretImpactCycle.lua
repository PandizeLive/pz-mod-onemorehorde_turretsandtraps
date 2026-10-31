local I = {}

---@param state table Persistent head cycle
---@param loaded number All ready rounds including chamber and extension
---@return nil
function I.observe(state, loaded)
    if state.impactReady == nil then state.impactReady = loaded > 0 end
    if loaded == 0 then
        state.impactEmpty = true
    elseif state.impactEmpty then
        state.impactReady, state.impactEmpty = true, false
    end
end

---@param state table Persistent head cycle
---@return nil
function I.consume(state)
    state.impactReady = false
end

return I
