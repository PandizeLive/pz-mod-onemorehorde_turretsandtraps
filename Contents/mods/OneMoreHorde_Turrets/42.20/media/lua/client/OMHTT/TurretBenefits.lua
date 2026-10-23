local T = require("OMHTT/Turret")
local S = require("OMHTT/TurretStats")
local M = require("OMHTT/TurretModules")
local B = {}
local Rarity = require("OMHTT/TurretRarity")
local Estimate = require("OMHTT/TurretBatteryEstimate")

---@param value number Value displayed, never used for consumption
---@return string text
---@nodiscard
function B.number(value)
    if value == 0 then return "0" end
    if math.abs(value) < .01 then return string.format("%.4f", value) end
    if math.abs(value) < 1 then return string.format("%.2f", value) end
    if value ~= math.floor(value) then return (string.gsub(string.format("%.2f", value), "%.?0+$", "")) end
    return string.format("%.0f", value)
end

---@param contents table Current inventory summary
---@param stats table Effective stats
---@return string description Battery-local tooltip
---@nodiscard
function B.battery(contents, stats)
    local multiplier = getText("UI_OMHTT_BatteryModuleTotal", B.number(stats.modulePower))
    if stats.regulator > 1 then
        multiplier = multiplier .. " <LINE> " .. getText("UI_OMHTT_BatteryRegulatedTotal",
            B.number(stats.modulePower / stats.regulator), B.number((1 - 1 / stats.regulator) * 100))
    end
    multiplier = multiplier .. " <LINE> "
    if not contents.head or contents.head:getCondition() <= 0 or not contents.battery or contents.battery:getCondition() <= 0 then
        return multiplier .. getText("UI_OMHTT_BatteryUnavailable")
    end
    if stats.rotary then
        if stats.motorPower == 0 then return multiplier .. getText("UI_OMHTT_BatteryFree") end
        local hours = require("OMHTT/TurretBattery").charge(contents.battery) * 100 / stats.motorPower
        return multiplier .. getText("UI_OMHTT_MotorBattery", B.number(stats.motorPower), string.format("%.1f", hours))
    end
    local cost = stats.batteryPercent
    if cost == 0 then return multiplier .. getText("UI_OMHTT_BatteryFree") end
    local costText = B.number(cost)
    if cost < .0001 then costText = "<0.0001" end
    local volleys = math.floor(require("OMHTT/TurretBattery").charge(contents.battery) * 100 / cost + .0000001)
    local gun = stats.firearm and contents.head or nil
    local data = contents.head:getModData()
    local state = gun and data.OMHTTGunCycle or data.OMHTTCycle
    local loaded = gun and require("OMHTT/Firearms").loaded(gun) or state and state.loaded
    local seconds = Estimate.duration(stats, gun, volleys, loaded, state and state.conservationDebt) / 1000
    local minutes = seconds / 60 * 1440 / getGameTime():getMinutesPerDay()
    local unit = getText("UI_OMHTT_BatteryMinutes")
    if minutes >= 60 then
        minutes = minutes / 60
        unit = getText("UI_OMHTT_BatteryHours")
    end
    local time = string.format("%.1f", minutes)
    return multiplier .. getText("UI_OMHTT_BatteryCost", costText) .. " <LINE> "
        .. getText("UI_OMHTT_BatteryVolleys", volleys) .. " <LINE> "
        .. getText("UI_OMHTT_BatteryTime", time, unit)
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
        if name == "Regulator" then label, value = "Battery", (1 - 1 / stats.regulator) * 100
        elseif name == "Siphon" then label, value = "Siphon", stats.siphon
        elseif name == "Synergy" then label = "Synergy"
        elseif name == "Martyrdom" then label, value = "Radius", stats.martyrdom
        elseif name == "Tack" then label, value = "Radius", stats.tack
        elseif name == "Conservation" then label, value = "Ammo", stats.conservation
        elseif name == "Splitter" then
            label, value = "Shots", stats.splitter
        elseif name == "InitialBlow" then
            label, value = "Damage", stats.initialBlow * 100
        elseif name == "Execute" then
            label, value = "HP", stats.execute * 100
        elseif name == "Impact" then
            label, value = "Stagger", stats.impact
        elseif name == "Piercing" then
            label, value = "Piercing", stats.piercing
            if stats.piercing == 0 then label = "Inactive" end
        elseif name == "Void" then label, value = "Void", nil
        elseif name == "Grid" then label, value = "Grid", nil
        elseif name == "Lure" then label, value = "Lure", nil
        elseif name == "Fragment" then
            label, value = "Damage", stats.fragmentDamage * 100
        elseif name == "Magazine" then label, value = "Magazine", stats.magazine - base.magazine
        elseif name == "Range" then label, value = "Range", stats.range - base.range
        elseif name == "Velocity" then label, value = "Damage", S.bonus(contents.active, "Velocity", 20, 100)
        elseif name == "Critical" then label, value = "Chance", stats.critChance - base.critChance
        elseif name == "Accuracy" then label, value = "Chance", math.max(stats.accuracy - base.accuracy, stats.farAccuracy - base.farAccuracy)
        elseif name == "Suppression" then label, value = "Noise", (1 - stats.hearingMultiplier) * 100
        elseif name == "Reload" then
            label, value = "Reload", base.reload > 0 and (1 - stats.reload / base.reload) * 100 or 0
            if stats.autoloader then label = "Inactive" end
        elseif name == "Autoloader" then label, value = "Reload", 100
        elseif name == "RapidFire" then
            local without = {}
            for key, amount in pairs(contents.active) do without[key] = amount end
            without.RapidFire = nil
            local prior = S.resolve({head = contents.head, active = without, powerLoad = contents.powerLoad})
            label, value = "Rate", (prior.cooldown / stats.cooldown - 1) * 100
        elseif name == "Detection360" then label, value = "Degrees", 360
        elseif name == "FiringEnhanced" then label, value = "Rate", (stats.firearm or stats.headKind) and (S.option("EnhancedFireMultiplier", 4 / 3, 1, 5) - 1) * 100 or 0
        elseif name == "MotionDetectionEnhanced" or name == "MotionDetection" or name == "MotionDetectionImprovised" then
            label, value = "Detection", name == "MotionDetectionImprovised" and stats.range * .75 or stats.range
        end
        if value == 0 and label ~= "Inactive" then label = "Capped" end
        if count == 0 then label = "Broken" end
        if not require("OMHTT/TurretHeads").supports(contents.head, name) then label, value = "Inactive", nil end
        local effect = getText("UI_OMHTT_Effect" .. label, value and B.number(value) or "")
        local title = getText("UI_OMHTT_Module" .. name) .. (entry.count > 1 and " x" .. entry.count or "")
        rows[#rows + 1] = {name = name, title = title, effect = effect, color = Rarity.get(name), inactive = count == 0 or label == "Inactive",
            details = require("OMHTT/TurretDescriptions").get(name, true)}
    end
    table.sort(rows, function(a, b) return a.title < b.title end)
    return rows
end

return B
