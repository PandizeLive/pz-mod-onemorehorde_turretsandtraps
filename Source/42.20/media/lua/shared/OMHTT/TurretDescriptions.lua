local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRarity")
local S = require("OMHTT/TurretStats")
local D = {cache = {}}

---@param name string Module identity
---@param rich boolean Rich tooltip markup
---@return string description Four concise fields
function D.get(name, rich)
    local rarity = R.get(name)
    local surcharge = string.format("%.2f", (string.sub(name, 1, 8) == "Capacity" or name == "Regulator") and 0 or rarity.surcharge * S.option("ModulePowerBonus", 5, 0, 200) / 5)
    surcharge = string.gsub(surcharge, "%.?0+$", "")
    local key = name .. tostring(rich) .. tostring(rarity.band) .. surcharge
    if D.cache[key] then return D.cache[key] end
    local feature = "Tooltip_OMHTT_Module" .. name
    if name == "MotionDetectionEnhanced" then feature = "Tooltip_OMHTT_ModuleDetectionEnhanced" end
    if string.sub(name, 1, 8) == "Capacity" then feature = "Tooltip_OMHTT_ModuleCapacity" end
    if name == "FiringImprovised" or name == "MotionDetectionImprovised" or name == "CapacityImprovised" then feature = "Tooltip_OMHTT_" .. name end
    local single = T.SINGLE[name] or string.sub(name, 1, 8) == "Capacity"
        or name == "FiringImprovised" or name == "MotionDetectionImprovised" or name == "FiringEnhanced" or name == "MotionDetectionEnhanced"
    local color = rich and string.format(" <RGB:%.3f,%.3f,%.3f> ", rarity.tr, rarity.tg, rarity.tb) or ""
    local sep = rich and " <LINE> " or "\n"
    local text = getText("UI_OMHTT_ModuleFeature", getText(feature)) .. sep
        .. getText("UI_OMHTT_ModuleStackable", getText(single and "UI_OMHTT_ModuleNo" or "UI_OMHTT_ModuleYes")) .. sep
        .. getText("UI_OMHTT_ModuleDrain", surcharge) .. sep
        .. color .. getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. rarity.band))
    D.cache[key] = text
    return text
end

return D
