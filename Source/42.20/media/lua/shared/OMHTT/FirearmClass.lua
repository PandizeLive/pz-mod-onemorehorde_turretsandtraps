local C = {overrides = {}}

---@param gun HandWeapon Mounted weapon
---@return boolean precision
---@nodiscard
function C.precision(gun)
    local override = C.overrides[gun:getFullType()]
    if override ~= nil then return override end
    if not gun:isTwoHandWeapon() or gun:getProjectileCount() > 1 then return false end
    local modes = gun:getFireModePossibilities()
    if modes then
        for i = 0, modes:size() - 1 do
            if tostring(modes:get(i)) ~= "Single" then return false end
        end
    end
    if gun:getFireMode() ~= "Single" then return false end
    local mechanism = tostring(gun:getWeaponReloadType())
    local rifle = mechanism == "boltaction" or mechanism == "boltactionnomag" or mechanism == "leveraction"
    if not rifle then return false end
    local script = gun:getScriptItem()
    return script:getMaxRange() >= 30 or gun:isRackAfterShoot()
end

return C
