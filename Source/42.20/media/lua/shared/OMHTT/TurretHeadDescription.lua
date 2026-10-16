local H = require("OMHTT/TurretHeads")
local D = {}

---@param item InventoryItem Head
---@param rich boolean? Rich tooltip
---@param resolved table? Installed effective stats
---@return string description
function D.get(item, rich, resolved)
    local definition = H.get(item)
    local stats = resolved or require("OMHTT/TurretStats").resolve({head = item, active = {}, powerLoad = 0})
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
    }
    return table.concat(lines, rich and " <LINE> " or "\n")
end

return D
