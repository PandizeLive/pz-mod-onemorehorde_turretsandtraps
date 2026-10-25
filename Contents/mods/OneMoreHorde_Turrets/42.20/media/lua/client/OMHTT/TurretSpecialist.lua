if isServer() then return end

---@return nil
local function applyIcon()
    local trait = CharacterTraitDefinition.getCharacterTraitDefinition(OMHTTTurretSpecialist)
    if not trait then return end
    local texture = getTexture("Item_MagazineElectronics01")
    if texture then
        trait:setTexture(texture)
    end
end

Events.OnGameBoot.Add(applyIcon)
