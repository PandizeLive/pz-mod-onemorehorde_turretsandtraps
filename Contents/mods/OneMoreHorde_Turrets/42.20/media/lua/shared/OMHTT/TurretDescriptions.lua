local R = require("OMHTT/TurretRarity")
local S = require("OMHTT/TurretStats")
local D = {cache = {}}

local Stacking = require("OMHTT/TurretStacking")
local units = {RapidFire = "Rate", Reload = "Reload", Velocity = "Damage", Range = "Range", Magazine = "Magazine",
    Accuracy = "Chance", Critical = "Chance", InitialBlow = "Damage", Fragment = "Fragment", Execute = "Threshold",
    Impact = "Chance", Conservation = "Uses", Siphon = "Siphon", Regulator = "Divisor", Martyrdom = "Radius", Tack = "Radius"}

---@param value number Loaded coefficient
---@return string text
local function number(value)
    return (string.gsub(string.format("%.2f", value), "%.?0+$", ""))
end

---@param name string Module identity
---@return string benefit First and additional active-copy contributions
function D.stack(name)
    if Stacking.definitions[name] then
        local first, extra = Stacking.values(name)
        if name == "Conservation" then first = first + 1 end
        return getText("UI_OMHTT_FirstExtra" .. units[name], number(first), number(extra))
    end
    if name == "Splitter" then return getText("UI_OMHTT_StackShots", 1) end
    if name == "Piercing" then return getText("UI_OMHTT_StackPiercing", 1) end
    if name == "Suppression" then
        return getText("UI_OMHTT_FirstExtraSuppression", S.option("SuppressionFirstReduction", 60, 0, 99), S.option("SuppressionDiminishing", .6, 0, 10))
    end
    return getText("UI_OMHTT_ModuleNo")
end

---@param name string Module identity
---@param rich boolean Rich tooltip markup
---@return string description Four concise fields
function D.get(name, rich)
    if string.sub(name, 1, 8) == "Capacity" then
        local E = require("OMHTT/ControlExpansion")
        local tier = ({CapacityImprovised = 1, CapacitySmall = 2, Capacity = 3, CapacityLarge = 4})[name]
        local sep = rich and " <LINE> " or "\n"
        local text = getText("UI_OMHTT_ControllerKitBonus", tier * E.option("ControllerKitRange", 10, 25), tier * E.option("ControllerKitCapacity", 100, 1000))
            .. sep .. getText("UI_OMHTT_TurretKitBonus", S.resolve({active = {[name] = 1}}).modules - S.resolve().modules)
        local rarity = R.get(name)
        return (rich and "<RGB:0.8,0.8,0.8> " .. text .. " <RGB:1,1,1>" or text) .. sep
            .. (rich and string.format("<RGB:%.3f,%.3f,%.3f> ", rarity.tr, rarity.tg, rarity.tb) or "")
            .. getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. rarity.band)) .. (rich and " <RGB:1,1,1>" or "")
    end
    local rarity = R.get(name)
    local surcharge = string.format("%.2f", (string.sub(name, 1, 8) == "Capacity" or name == "Regulator") and 0 or rarity.surcharge * S.option("ModulePowerBonus", 5, 0, 200) / 5)
    surcharge = string.gsub(surcharge, "%.?0+$", "")
    local stack = D.stack(name)
    local feature = "Tooltip_OMHTT_Module" .. name
    if name == "MotionDetectionEnhanced" then feature = "Tooltip_OMHTT_ModuleDetectionEnhanced" end
    if name == "FiringImprovised" or name == "MotionDetectionImprovised" then feature = "Tooltip_OMHTT_" .. name end
    local effect = getText(feature)
    if name == "InitialBlow" then effect = getText("UI_OMHTT_InitialFeature", S.option("InitialBlowThreshold", 90, 0, 100)) end
    if name == "Velocity" then
        local first, extra = Stacking.values("VelocityKnockdown")
        effect = getText("UI_OMHTT_VelocityFeature", number(first), number(extra))
    end
    local key = name .. tostring(rich) .. tostring(rarity.band) .. surcharge .. stack .. effect
    if D.cache[key] then return D.cache[key] end
    local color = rich and string.format(" <RGB:%.3f,%.3f,%.3f> ", rarity.tr, rarity.tg, rarity.tb) or ""
    local sep = rich and " <LINE> " or "\n"
    local text = (rich and "<RGB:0.8,0.8,0.8> " or "") .. getText("UI_OMHTT_ModuleFeature", effect)
        .. (rich and " <RGB:1,1,1>" or "") .. sep
        .. getText("UI_OMHTT_ModuleStackable", stack) .. sep
        .. getText("UI_OMHTT_ModuleDrain", surcharge) .. sep
        .. color .. getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. rarity.band)) .. (rich and " <RGB:1,1,1> " or "")
    D.cache[key] = text
    return text
end

return D
