local S = {}
-- Existing option identities remain the additional-copy controls, preserving saved tuning.
S.definitions = {
    RapidFire = {40, 20}, Reload = {50, 25}, Velocity = {30, 15}, Range = {3, 1},
    Magazine = {50, 25}, Accuracy = {10, 4}, Critical = {15, 5}, InitialBlow = {50, 20},
    VelocityKnockdown = {5, 3}, Fragment = {25, 4, "FragmentDamage"},
    Execute = {18, 2}, Impact = {60, 2}, Conservation = {1, .5}, Siphon = {2, .5},
    Regulator = {.25, .25}, Martyrdom = {1.5, .15, "MartyrdomRadius"},
    Tack = {1.25, .15, "TackRadius"},
}

---@param name string Effect family
---@return number first First-copy contribution
---@return number extra Additional-copy contribution
function S.values(name)
    local def = S.definitions[name]
    local settings = SandboxVars.OMHTurretsTraps or {}
    local first, extra = settings[def[3] or name .. "First"], settings[name .. "Bonus"]
    if type(first) ~= "number" or first ~= first or first == math.huge then first = def[1] end
    if type(extra) ~= "number" or extra ~= extra or extra == math.huge then extra = def[2] end
    return math.max(0, math.min(200, first)), math.max(0, math.min(200, extra))
end

---@param active table Active effect counts
---@param name string Effect family
---@return number contribution Additive total; zero when absent
function S.bonus(active, name)
    local count = active[name] or 0
    if name == "VelocityKnockdown" then count = active.Velocity or 0 end
    if count <= 0 then return 0 end
    local first, extra = S.values(name)
    return first + (count - 1) * extra
end

return S
