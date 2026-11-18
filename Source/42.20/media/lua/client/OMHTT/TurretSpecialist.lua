if isServer() then return end

---@return nil
local function applyIcon()
    local trait = CharacterTraitDefinition.getCharacterTraitDefinition(OMHTTTurretSpecialist)
    if not trait then return end
    local texture = getTexture("Item_MagazineElectronics01")
    if texture then
        local x = math.floor(texture:getXStart() * texture:getWidthHW() + .5)
        local y = math.floor(texture:getYStart() * texture:getHeightHW() + .5)
        local icon = texture:split("OMHTTTurretSpecialist", x, y, texture:getWidth(), texture:getHeight())
        local scale = 16 / math.max(texture:getWidth(), texture:getHeight())
        icon:setWidth(math.max(1, math.floor(texture:getWidth() * scale)))
        icon:setHeight(math.max(1, math.floor(texture:getHeight() * scale)))
        trait:setTexture(icon)
    end
end

Events.OnGameBoot.Add(applyIcon)
