if isClient() then return end
local Combat = require("OMHTT/ControlCombat")
local Injury = require("OMHTT/DefenseInjury")
local H = {}
local wounds = setmetatable({}, {__mode = "k"})
local contacts = setmetatable({}, {__mode = "k"})
-- Live jobs retain budgets. Weak values release finished attacks without a scan.
local events = setmetatable({}, {__mode = "v"})
local profiles = {
    Arc = {damage = 2, chance = 0},
    Potato = {damage = 2, chance = 0},
    Firearm = {damage = 4, chance = .06, bullet = true},
    Shotgun = {damage = 8, chance = .06, bullet = true},
    Ballista = {damage = 10, chance = .15},
    Scrapshot = {damage = 8, chance = .09, bullet = true},
    RotaryBat = {damage = 2, chance = 0, interval = 2000},
    RotaryBlades = {damage = 4, chance = .15, cut = true, interval = 2000},
    Lobber = {damage = 10, chance = .15},
    Burst = {damage = 2, chance = 0, interval = 1000},
}

---@param options table Shot owner
---@return string kind
function H.kind(options)
    if options.playerKind then return options.playerKind end
    local stats = options.stats or {}
    if stats.firearm then
        if options.weapon and options.weapon:getProjectileCount() > 1 then return "Shotgun" end
        return "Firearm"
    end
    return stats.headKind or "Potato"
end

---@param player IsoPlayer Victim
---@param options table Shared root, including persisted scalar-keyed player budget
---@param kind string? Profile
---@param fraction number? Portion of root injury
---@return boolean contacted
function H.hit(player, options, kind, fraction)
    while options.root do
        options = options.root
    end
    if not Combat.protected(options.playerSource, player) then return false end
    local profile = profiles[kind or H.kind(options)]
    if not profile then return false end
    local now = require("OMHTT/ControlClock").now()
    local contact = contacts[player]
    if profile.interval and contact and now < (contact[kind] or 0) then return false end
    local settings = SandboxVars.OMHTurretsTraps or {}
    local damageScale = math.max(0, math.min(5, settings.TurretPlayerDamageMultiplier or 1))
    local woundScale = math.max(0, math.min(5, settings.TurretPlayerWoundMultiplier or 1))
    local hostile = require("OMHTT/ControlTargeting").outsider(options.playerSource, player)
    local relationshipDamage = settings[hostile and "HostilePlayerDamageMultiplier" or "FriendlyPlayerDamageMultiplier"]
    local relationshipWound = settings[hostile and "HostilePlayerWoundMultiplier" or "FriendlyPlayerWoundMultiplier"]
    damageScale = damageScale * math.max(0, math.min(10, relationshipDamage or (hostile and 4 or 2)))
    woundScale = woundScale * math.max(0, math.min(10, relationshipWound or (hostile and 4 or 1)))
    local cap = profile.damage * damageScale
    options.playerBudget = options.playerBudget or {}
    if options.playerEvent then
        local shared = events[options.playerEvent]
        if shared and shared ~= options.playerBudget then
            for name, saved in pairs(options.playerBudget) do
                local current = shared[name]
                if not current then
                    shared[name] = saved
                else
                    current.used = math.max(current.used, saved.used)
                    current.rolled = current.rolled or saved.rolled
                end
            end
            options.playerBudget = shared
        else
            events[options.playerEvent] = options.playerBudget
        end
    end
    local key = player:getUsername()
    if not key or key == "" then
        key = "local:" .. tostring(player:getPlayerNum())
    end
    local budget = options.playerBudget[key]
    if not budget then
        budget = {used = 0}
        options.playerBudget[key] = budget
    end
    local amount = math.min(cap - budget.used, cap * math.max(0, math.min(1, fraction or 1)))
    if amount <= 0 then return false end
    local parts = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R}
    local part = BodyPartType.ToIndex(parts[ZombRand(4) + 1])
    local protection = math.max(0, math.min(100, player:getBodyPartClothingDefense(part, false, profile.bullet == true)))
    budget.used = budget.used + amount
    if profile.interval then
        if not contact then
            contact = {}
            contacts[player] = contact
        end
        -- Both rotary heads share the same contact recovery interval.
        if kind == "RotaryBat" or kind == "RotaryBlades" then
            contact.RotaryBat, contact.RotaryBlades = now + profile.interval, now + profile.interval
        end
        contact[kind] = now + profile.interval
    end
    amount = amount * (1 - protection / 100)
    if amount <= 0 then return true end
    local chance = math.min(1, profile.chance * woundScale * (kind == "Lobber" and (fraction or 1) or 1))
    local wound = false
    if chance > 0 and not budget.rolled and now >= (wounds[player] or 0) then
        budget.rolled, wounds[player] = true, now + 1000
        wound = ZombRand(10000) < chance * 10000
    end
    Injury.turret(player, part, amount, wound and (profile.cut and "cut" or "scratch") or "none")
    return true
end

return H
