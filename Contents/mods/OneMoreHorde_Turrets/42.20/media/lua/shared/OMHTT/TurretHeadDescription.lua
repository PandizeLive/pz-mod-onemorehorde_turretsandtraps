local H = require("OMHTT/TurretHeads")
local Stats = require("OMHTT/TurretStats")
local D = {}
local Consumption = require("OMHTT/ControlConsumption")

---@param item InventoryItem Head without installed turret modules
---@return table rating Shared label and color
---@return number drain Percentage points per real unpaused hour
---@return table stats Module-free baseline
function D.rating(item, resolved)
    local stats = resolved or Stats.resolve({head = item, active = {}, powerLoad = 0})
    local drain = stats.motorPower
    if not stats.rotary then
        local count = stats.ammoFree and 1 or require("OMHTT/TurretBatteryEstimate").magazineUses(math.max(1, stats.magazine), 1 + (stats.splitter or 0), stats.conservation or 1, 0)
        local duration = require("OMHTT/TurretBatteryEstimate").duration(stats, item, count + 1)
        drain = stats.batteryPercent * count * 3600000 / math.max(1, duration)
    end
    return Consumption.band(drain), drain, stats
end

---@param item InventoryItem Head
---@param rich boolean? Rich tooltip
---@param rating table? Already calculated baseline rating
---@return string label Rating with only its value colored
function D.battery(item, rich, rating)
    rating = rating or D.rating(item)
    local value = getText(rating.key)
    if rich then
        value = string.format("<RGB:%.2f,%.2f,%.2f> ", rating.r, rating.g, rating.b) .. value .. " <RGB:1,1,1>"
    end
    return getText("UI_OMHTT_HeadBattery", value)
end

---@param item InventoryItem Head
---@param rich boolean? Rich tooltip
---@param resolved table? Installed effective stats
---@return string description
---@return table rating Shared native tooltip color
function D.get(item, rich, resolved)
    local definition = H.get(item)
    local rating, _, baseline = D.rating(item, resolved)
    local stats = resolved or baseline
    local kind = definition and definition.key or "Potato"
    local ammo = getText("UI_OMHTT_HeadAmmo" .. kind)
    if stats.firearm then
        kind = "Firearm"
        local fullType = require("OMHTT/Firearms").ammoType(item)
        local script = getScriptManager():getItem(fullType)
        ammo = script and script:getDisplayName() or fullType
    end
    local damage = string.format("%.1f", stats.damage)
    if kind == "Scrapshot" then damage = getText("UI_OMHTT_HeadPellets", string.format("%.1f", stats.damage / 8), damage) end
    local rate = getText("UI_OMHTT_HeadRate", string.format("%.2f", 1000 / stats.cooldown))
    if stats.rotary then rate = getText("UI_OMHTT_MotorSpeed", string.format("%.1f", stats.motorSpeed / 6)) end
    local lines = {
        getText("UI_OMHTT_ModuleFeature", getText("UI_OMHTT_HeadFeature" .. kind)),
        getText("UI_OMHTT_HeadAmmo", ammo), getText("UI_OMHTT_HeadDamage", damage),
        getText("UI_OMHTT_HeadRange", string.format("%.1f", stats.range)), getText("UI_OMHTT_HeadFirerate", rate),
        D.battery(item, rich, rating),
    }
    return table.concat(lines, rich and " <LINE> " or "\n"), rating
end

return D
