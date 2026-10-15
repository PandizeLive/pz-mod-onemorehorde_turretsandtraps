-- Native ZombiePacket quantizes health to thousandths. The lethal reservation must stay nonzero on that wire.
local P = {MODULE = "OMHTT_CombatV1", TIMEOUT = 5000, MAX_PENDING = 128, EPSILON = 0.001}

---@param value any Candidate
---@param minimum number Inclusive lower bound
---@param maximum number Inclusive upper bound
---@return boolean valid
function P.number(value, minimum, maximum)
    return type(value) == "number" and value == value and value >= minimum and value <= maximum
end

---@param value any Candidate
---@return boolean valid
function P.identity(value)
    return P.number(value, -2147483648, 2147483647) and value == math.floor(value)
end

---@param value any Candidate transaction/receipt token
---@return boolean valid
function P.token(value)
    return type(value) == "string" and #value > 0 and #value <= 96
end

---@param message any Wire payload
---@return boolean valid
function P.envelope(message)
    return type(message) == "table" and P.token(message.token) and P.identity(message.id) and message.id ~= -1
        and P.identity(message.outfit) and P.identity(message.owner)
        and P.number(message.sequence, 1, 1000000000) and message.sequence == math.floor(message.sequence)
end

---@param before number Current owner health
---@param amount number Authorized native damage
---@return number after Nonzero until server commits a lethal result
---@return number lost Applied loss, excluding lethal sentinel
---@return boolean lethal
function P.result(before, amount)
    local lethal = before - amount < 0.000001
    if lethal then return P.EPSILON, before, true end
    local after = math.max(P.EPSILON, before - amount)
    return after, before - after, false
end

return P
