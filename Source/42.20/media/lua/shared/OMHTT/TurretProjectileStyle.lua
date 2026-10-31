local P = {}

---@param stats table Shot snapshot
---@param options table? Original ammunition and launch settings
---@return string? family Physical projectile family; nil for rays/electricity
---@return number? speed Tiles per active second
---@return string? ammoType Original inventory icon identity
function P.describe(stats, options)
    options = options or {}
    local ammo = options.ammoDescriptor and options.ammoDescriptor.type
    if stats.firearm or stats.headKind == "Scrapshot" or stats.headKind == "Arc" then return nil end
    if stats.headKind == "Ballista" then return "spear", options.projectileSpeed or 24, ammo or "Base.SpearCrafted" end
    if stats.headKind == "Lobber" then return "grenade", 8, ammo or "Base.OMHTTAmmoMakeshiftBomb" end
    if not stats.headKind or stats.headKind == "Potato" then
        return "potato", options.projectileSpeed or require("OMHTT/Turret").option("ProjectileSpeed", 20, 5, 100), ammo or "Base.Potato"
    end
    return nil
end

return P
