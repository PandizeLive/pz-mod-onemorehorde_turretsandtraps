local R = require("OMHTT/TurretRarity")
local S = require("OMHTT/TurretStats")
local D = {cache = {}}

local stacks = {
    Magazine = {"Magazine", 35, "MagazineBonus", 200}, RapidFire = {"Rate", 25, "RapidFireBonus", 200},
    Reload = {"Reload", 25, "ReloadBonus", 200}, Range = {"Range", 2, "RangeBonus", 200},
    Velocity = {"Velocity", 20, "VelocityBonus", 200}, Critical = {"Chance", 5, "CriticalBonus", 100},
    Accuracy = {"Chance", 5, "AccuracyBonus", 100}, InitialBlow = {"Damage", 25, "InitialBlowBonus", 200},
    Execute = {"Threshold", 2, "ExecuteBonus", 100}, Impact = {"Chance", 2, "ImpactBonus", 100},
    Fragment = {"Damage", 5, "FragmentBonus", 100}, Martyrdom = {"Radius", .25}, Tack = {"Radius", .25},
    Siphon = {"Siphon", 1}, Regulator = {"Battery", 25}, Conservation = {"Uses", 1}, Splitter = {"Shots", 1}, Piercing = {"Piercing", 1},
    Suppression = {"Suppression", .6, "SuppressionDiminishing", 10},
}

---@param name string Module identity
---@return string benefit Per-copy or subsequent-copy benefit
function D.stack(name)
    local row = stacks[name]
    if not row then return getText("UI_OMHTT_ModuleNo") end
    local value = row[3] and S.option(row[3], row[2], 0, row[4]) or row[2]
    local extra = name == "Velocity" and S.option("VelocityKnockdownBonus", 5, 0, 100) or ""
    return getText("UI_OMHTT_Stack" .. row[1], value, extra)
end

---@param name string Module identity
---@param rich boolean Rich tooltip markup
---@return string description Four concise fields
function D.get(name, rich)
    local rarity = R.get(name)
    local surcharge = string.format("%.2f", (string.sub(name, 1, 8) == "Capacity" or name == "Regulator") and 0 or rarity.surcharge * S.option("ModulePowerBonus", 5, 0, 200) / 5)
    surcharge = string.gsub(surcharge, "%.?0+$", "")
    local stack = D.stack(name)
    local key = name .. tostring(rich) .. tostring(rarity.band) .. surcharge .. stack
    if D.cache[key] then return D.cache[key] end
    local feature = "Tooltip_OMHTT_Module" .. name
    if name == "MotionDetectionEnhanced" then feature = "Tooltip_OMHTT_ModuleDetectionEnhanced" end
    if string.sub(name, 1, 8) == "Capacity" then feature = "Tooltip_OMHTT_ModuleCapacity" end
    if name == "FiringImprovised" or name == "MotionDetectionImprovised" or name == "CapacityImprovised" then feature = "Tooltip_OMHTT_" .. name end
    local color = rich and string.format(" <RGB:%.3f,%.3f,%.3f> ", rarity.tr, rarity.tg, rarity.tb) or ""
    local sep = rich and " <LINE> " or "\n"
    local text = getText("UI_OMHTT_ModuleFeature", getText(feature)) .. sep
        .. getText("UI_OMHTT_ModuleStackable", stack) .. sep
        .. getText("UI_OMHTT_ModuleDrain", surcharge) .. sep
        .. color .. getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. rarity.band)) .. (rich and " <RGB:1,1,1> " or "")
    D.cache[key] = text
    return text
end

return D
