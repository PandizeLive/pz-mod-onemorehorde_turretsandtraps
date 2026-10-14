local G = require("OMHTT/Firearms")
local A = {cache = {}, overrides = {}, potatoes = {["Base.Potato"] = true, ["Base.SweetPotato"] = true}}
A.bombs = {
    ["Base.OMHTTAmmoMakeshiftBomb"] = {damage = 150, radius = 4, power = .02},
    ["Base.Aerosolbomb"] = {minimum = 350, maximum = 700, radius = 6, power = .03},
    ["Base.PipeBomb"] = {minimum = 450, maximum = 900, radius = 7, power = .04},
}

---@param fullType string Registered script identity
---@return string? family
---@nodiscard
function A.family(fullType)
    if type(fullType) ~= "string" then return nil end
    if A.overrides[fullType] ~= nil then return A.overrides[fullType] or nil end
    if A.potatoes[fullType] then return "potato" end
    if A.bombs[fullType] then return "bomb" end
    if fullType == "Base.ScrapMetal" then return "scrap" end
    if G.AMMO[fullType] then return "round" end
    if A.cache[fullType] ~= nil then return A.cache[fullType] or nil end
    local script = getScriptManager():getItem(fullType)
    if script and script:containsWeaponCategory(WeaponCategory.SPEAR) then
        A.cache[fullType] = "spear"
        return "spear"
    end
    A.cache[fullType] = false
    return nil
end

---@param head InventoryItem? Installed head
---@param fullType string Ammunition identity
---@return boolean accepted
---@nodiscard
function A.accepts(head, fullType)
    if not head then return false end
    if G.profile(head) then return fullType == G.ammoType(head) end
    local kind = head:getFullType()
    local family = A.family(fullType)
    if kind == "Base.OMHTTTurretBallista" then return family == "spear" end
    if kind == "Base.OMHTTTurretLobber" then return family == "bomb" end
    if kind == "Base.OMHTTTurretScrapshot" then return family == "scrap" end
    return kind == "Base.OMHTTTurretPotato" and family == "potato"
end

---@param item InventoryItem Exact ammunition
---@return table? descriptor Persistable relevant item state
function A.describe(item)
    local fullType = item:getFullType()
    local family = A.family(fullType)
    if not family then return nil end
    if family == "spear" and item:getCondition() <= 0 then return nil end
    local descriptor = {type = fullType, condition = item:getCondition(), multiplier = 1}
    if family == "spear" then
        local reference = getScriptManager():getItem("Base.SpearCrafted")
        if not reference then return nil end
        local baseline = reference:getMinDamage() + reference:getMaxDamage()
        local value = item:getMinDamage() + item:getMaxDamage()
        if baseline <= 0 or baseline ~= baseline or baseline == math.huge
            or value < 0 or value ~= value or value == math.huge then return nil end
        descriptor.multiplier = 1 + .25 * (value / baseline - 1)
    elseif family == "potato" then
        descriptor.age = item:getAge()
        descriptor.cooked = item:isCooked()
        descriptor.burnt = item:isBurnt()
    end
    return descriptor
end

return A
