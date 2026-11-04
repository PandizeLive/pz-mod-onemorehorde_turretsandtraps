local C = {}

---@param state table Exact head's persisted cycle
---@param uses number Existing loaded-ammo charge, including Splitter fallback
---@param divisor number Firing uses per round
---@return number cost Whole rounds consumed now
function C.consume(state, uses, divisor)
    local debt = (state.conservationDebt or 0) + uses / math.max(1, divisor)
    local cost = math.floor(debt + 0.0000001)
    state.conservationDebt = math.max(0, debt - cost)
    return cost
end

return C
