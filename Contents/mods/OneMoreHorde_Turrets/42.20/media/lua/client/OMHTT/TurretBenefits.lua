local T = require("OMHTT/Turret")
local S = require("OMHTT/TurretStats")
local M = require("OMHTT/TurretModules")
local B = {}

---@param value number Value displayed, never used for consumption
---@return string text
---@nodiscard
function B.number(value)
    if value == 0 then return "0" end
    if math.abs(value) < .01 then return string.format("%.4f", value) end
    if math.abs(value) < 1 then return string.format("%.2f", value) end
    return string.format("%.0f", value)
end

---@param contents table Current inventory summary
---@param stats table Effective stats
---@return string description Battery-local tooltip
---@nodiscard
function B.battery(contents, stats)
    if not contents.head or contents.head:getCondition() <= 0 or not contents.battery or contents.battery:getCondition() <= 0 then
        return getText("UI_OMHTT_BatteryUnavailable")
    end
    local cost = stats.batteryPercent
    if cost == 0 then return getText("UI_OMHTT_BatteryFree") .. " <LINE> " .. getText("UI_OMHTT_BatteryAssumptions") end
    local costText = B.number(cost)
    if cost < .0001 then costText = "<0.0001" end
    local volleys = math.floor(contents.battery:getCurrentUsesFloat() * 100 / cost + .0000001)
    return getText("UI_OMHTT_BatteryCost", costText) .. " <LINE> "
        .. getText("UI_OMHTT_BatteryVolleys", volleys) .. " <LINE> "
        .. getText("UI_OMHTT_BatteryTime", string.format("%.1f", volleys * stats.cooldown / 60000)) .. " <LINE> "
        .. getText("UI_OMHTT_BatteryAssumptions")
end

---@param contents table Current inventory summary
---@param stats table Effective stats
---@return table rows Stable grouped effects
function B.rows(contents, stats)
    local base = S.resolve({head = contents.head, active = {}, powerLoad = 0})
    local rows = {}
    for name, entry in pairs(contents.moduleDetails) do
        local count = contents.active[name] or 0
        local label, value = "Active", nil
        local tooltipKey = "Tooltip_OMHTT_Module" .. name
        if name == "MotionDetectionEnhanced" then tooltipKey = "Tooltip_OMHTT_ModuleDetectionEnhanced" end
        if name == "FiringImprovised" or name == "MotionDetectionImprovised" then tooltipKey = "Tooltip_OMHTT_" .. name end
        local details = getText(tooltipKey)
        if name == "Conservation" then label, value = "Ammo", stats.conservation
        elseif name == "Splitter" then
            label, value = "Shots", stats.splitter
            details = getText("UI_OMHTT_EffectSecondary", B.number(stats.splitterDamage * 100))
        elseif name == "InitialBlow" then
            label, value = "Damage", stats.initialBlow * 100
            details = getText("UI_OMHTT_EffectThreshold", B.number(stats.initialThreshold * 100))
        elseif name == "Execute" then
            label, value = "HP", stats.execute * 100
            details = getText("UI_OMHTT_EffectExecute", B.number(value))
        elseif name == "Impact" then
            label, value = "Stagger", stats.impact
            details = getText("UI_OMHTT_EffectImpact")
        elseif name == "Piercing" then
            label, value = "Piercing", stats.piercing
            details = getText("UI_OMHTT_EffectRetention", B.number(stats.pierceRetention * 100))
            if stats.piercing == 0 then label, details = "Inactive", getText("UI_OMHTT_PiercingInactive") end
        elseif name == "Fragment" then
            label, value = "Damage", stats.fragmentDamage * 100
            details = getText("UI_OMHTT_EffectFragment", B.number(stats.fragmentDamage * 100), B.number(stats.fragmentRange))
        elseif name == "Magazine" then label, value = "Magazine", stats.magazine - base.magazine
        elseif name == "Range" then label, value = "Range", stats.range - base.range
        elseif name == "Velocity" then label, value = "Damage", S.bonus(contents.active, "Velocity", 20, 100)
        elseif name == "Critical" then label, value = "Chance", stats.critChance - base.critChance
        elseif name == "Accuracy" then label, value = "Chance", math.max(stats.accuracy - base.accuracy, stats.farAccuracy - base.farAccuracy)
        elseif name == "Suppression" then label, value = "Noise", (1 - stats.hearingMultiplier) * 100
        elseif name == "Reload" then
            label, value = "Reload", base.reload > 0 and (1 - stats.reload / base.reload) * 100 or 0
            if stats.autoloader then label = "Inactive"; details = getText("Tooltip_OMHTT_ModuleAutoloader") end
        elseif name == "Autoloader" then label, value = "Reload", 100
        elseif name == "RapidFire" then
            local without = {}
            for key, amount in pairs(contents.active) do without[key] = amount end
            without.RapidFire = nil
            local prior = S.resolve({head = contents.head, active = without, powerLoad = contents.powerLoad})
            label, value = "Rate", (prior.cooldown / stats.cooldown - 1) * 100
        elseif name == "Detection360" then label, value = "Degrees", 360
        elseif name == "FiringEnhanced" then label, value = "Rate", stats.firearm and (S.option("EnhancedFireMultiplier", 4 / 3, 1, 5) - 1) * 100 or 0
        elseif name == "MotionDetectionEnhanced" or name == "MotionDetection" or name == "MotionDetectionImprovised" then
            label, value = "Detection", name == "MotionDetectionImprovised" and stats.range * .75 or stats.range
            details = details .. " <LINE> " .. getText("UI_OMHTT_DetectionDetails", B.number(T.turnSpeed(contents.head, contents.active)),
                string.format("%.2f", M.option(name == "MotionDetectionEnhanced" and "EnhancedDetectionInterval" or "DetectionInterval", name == "MotionDetectionEnhanced" and .1 or .25, .05, 10)))
        end
        if value == 0 and label ~= "Inactive" then label = "Capped" end
        if count == 0 then label = "Broken" end
        local effect = getText("UI_OMHTT_Effect" .. label, value and B.number(value) or "")
        local title = getText("UI_OMHTT_Module" .. name) .. (entry.count > 1 and " x" .. entry.count or "")
        rows[#rows + 1] = {name = name, title = title, effect = effect, inactive = count == 0 or label == "Inactive",
            details = getText("UI_OMHTT_EffectWorking", count, entry.count) .. " <LINE> " .. effect .. " <LINE> " .. details}
    end
    table.sort(rows, function(a, b) return a.title < b.title end)
    return rows
end

return B
