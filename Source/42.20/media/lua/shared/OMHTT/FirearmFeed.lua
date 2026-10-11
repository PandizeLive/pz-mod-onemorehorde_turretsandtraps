-- Extra loaded rounds remain real items in the turret. Only their ready count is persisted.
local Feed = {}

---@param gun HandWeapon Mounted firearm
---@return number rounds Turret-owned loaded extension
---@nodiscard
function Feed.count(gun)
    return gun:getModData().OMHTTFeedRounds or 0
end

---@param gun HandWeapon Mounted firearm
---@param count number Nonnegative loaded extension
---@return nil
function Feed.set(gun, count)
    gun:getModData().OMHTTFeedRounds = count > 0 and count or nil
end

---@param gun HandWeapon Mounted firearm
---@param amount number Available magazine/feed rounds to spend
---@return nil
function Feed.spend(gun, amount)
    local native = math.min(amount, gun:getCurrentAmmoCount())
    gun:setCurrentAmmoCount(gun:getCurrentAmmoCount() - native)
    local remaining = amount - native
    if remaining == 0 then return end
    local storage = gun:getContainer()
    local items = storage:getItems()
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        if item:getFullType() == gun:getAmmoType():getItemKey() then
            storage:Remove(item)
            remaining = remaining - 1
            Feed.set(gun, Feed.count(gun) - 1)
            if remaining == 0 then break end
        end
    end
end

---@param gun HandWeapon Mounted firearm
---@param capacity number Effective magazine capacity, excluding chamber
---@param player IsoPlayer? Acting player
---@param detached boolean? Remove the entire extension
---@return boolean restored All required surplus was returned
function Feed.restore(gun, capacity, player, detached)
    local extra = Feed.count(gun)
    local count = detached and extra or math.min(extra, math.max(0, gun:getCurrentAmmoCount() + extra - capacity))
    if count == 0 then return true end
    -- These exact rounds already occupy the reserve container, with their weight/capacity paid.
    -- Unmarking them cannot overflow storage, so the inventory/floor fallback is unnecessary here.
    Feed.set(gun, extra - count)
    return true
end

---@param gun HandWeapon Salvaged firearm
---@param square IsoGridSquare Loaded destruction tile
---@return nil
function Feed.drop(gun, square)
    -- The destruction path drops the real loose rounds along with the other contents.
    Feed.set(gun, 0)
end

return Feed
