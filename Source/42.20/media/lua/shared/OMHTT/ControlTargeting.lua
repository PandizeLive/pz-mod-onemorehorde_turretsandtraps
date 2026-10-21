local T = {}

---@param kind string Device family
---@return boolean supported
function T.supported(kind)
    return kind == "Controller" or kind == "Turret" or kind == "Tether"
end

---@param mode any Requested mode
---@return boolean valid
function T.mode(mode)
    return mode == "Zombies" or mode == "OtherFactions"
end

---@param state table? Private device record
---@param value any Requested policy
---@return boolean valid
function T.valid(state, value)
    if not state or not T.supported(state.kind) then return false end
    return T.mode(value) or (state.kind ~= "Controller" and value == "Inherit")
end

---@param state table? Device record
---@param host table? Assigned Controller record
---@return string mode
function T.resolve(state, host)
    if not state or not T.supported(state.kind) then return "Zombies" end
    if T.mode(state.targeting) then return state.targeting end
    if state.kind ~= "Controller" and host and host.kind == "Controller" and host.placed
        and state.controller == host.id and T.mode(host.targeting) then
        return host.targeting
    end
    return "Zombies"
end

---@param state table? Defense ownership, independent of management access
---@param player IsoPlayer Candidate, before combat protection checks
---@return boolean outsider Faction classification only, not permission to damage
function T.outsider(state, player)
    if not state or type(state.owner) ~= "string" or state.owner == "" or not player then return false end
    local username = player:getUsername()
    if not username or username == "" or username == state.owner then return false end
    local ownerFaction = Faction.getPlayerFaction(state.owner)
    return not ownerFaction or Faction.getPlayerFaction(username) ~= ownerFaction
end

return T
