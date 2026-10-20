local H = require("OMHTT/TurretHeads")
local Stats = require("OMHTT/TurretStats")
local D = {}
local ratings = {
    {key = "UI_OMHTT_HeadBatteryLow", r = .35, g = .85, b = .4},
    {key = "UI_OMHTT_HeadBatteryMedium", r = 1, g = .75, b = .25},
    {key = "UI_OMHTT_HeadBatteryHigh", r = 1, g = .35, b = .35},
}

---@param item InventoryItem Head without installed turret modules
---@return table rating Shared label and color
---@return number drain Percentage points per real unpaused hour
---@return table stats Module-free baseline
function D.rating(item)
    local stats = Stats.resolve({head = item, active = {}, powerLoad = 0})
    local drain = stats.motorPower
    if not stats.rotary then
        local magazine = math.max(1, stats.magazine)
        local gap = math.max(stats.cooldown, stats.reload)
        if stats.firearm then
            local reload = stats.reload
            if not item:getMagazineType() then
                reload = reload * magazine
            end
            local rack = item:haveChamber() and stats.rack or 0
            gap = stats.cooldown + reload + rack
        end
        local duration = (magazine - 1) * stats.cooldown + gap
        drain = stats.batteryPercent * magazine * 3600000 / math.max(1, duration)
    end
    local band = 1
    if drain >= 15 then
        band = 3
    elseif drain >= 5 then
        band = 2
    end
    return ratings[band], drain, stats
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
    local rating, _, baseline = D.rating(item)
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
