local D = {}
local kinds = {
    OMHTTTrapSpikeBarrier = "Barrier", OMHTTTrapSpikeBarrierReinforced = "Barrier",
    OMHTTTrapBedSpikes = "Bed", OMHTTTrapBedSpikesReinforced = "Bed",
    OMHTTTrapBarbedPanel = "Barb", OMHTTTrapConcertinaWire = "Wire",
    OMHTTTrapPokeFloor = "Poke", OMHTTTrapTetherDart = "Tether",
    OMHTTTrapController = "Controller", OMHTTTrapButton = "Button",
    OMHTTTrapLever = "Lever", OMHTTTrapPressurePlate = "Plate", OMHTTTrapLaser = "Laser",
}

---@param item InventoryItem? Owned item
---@return string? description Compact live device description
function D.get(item)
    if not item then return nil end
    local expansion = require("OMHTT/ControlExpansion")
    local tier = expansion.tier(item)
    if tier > 0 then
        return getText("UI_OMHTT_ControllerKitBonus", tier * expansion.option("ControllerKitRange", 10, 25), tier * expansion.option("ControllerKitCapacity", 100, 1000))
    end
    local name = item:getFullType()
    if string.sub(name, 1, 5) ~= "Base." then return nil end
    local kind = kinds[string.sub(name, 6)]
    if not kind then return nil end
    local settings = SandboxVars.OMHTurretsTraps or {}
    local text = getText("UI_OMHTT_DevicePurpose" .. kind)
    if kind == "Poke" then
        text = text .. "\n" .. getText("UI_OMHTT_DeviceDamage", settings.PokeDamage or 45)
    elseif kind == "Tether" then
        text = text .. "\n" .. getText("UI_OMHTT_TetherDamage", settings.TetherHitDamage or 30, settings.TetherPullDamage or 15)
            .. "\n" .. getText("UI_OMHTT_DeviceRange", settings.TetherRange or 6)
    elseif kind == "Bed" then
        local reinforced = string.find(name, "Reinforced", 1, true) ~= nil
        local damage = reinforced and (settings.BedReinforcedDamage or 50) or (settings.BedDamage or 20)
        text = text .. "\n" .. getText("UI_OMHTT_DeviceDamage", damage)
    elseif kind == "Controller" then
        text = text .. "\n" .. getText("UI_OMHTT_ControllerRange", require("OMHTT/ControlAccess").radius())
    elseif kind == "Laser" then
        text = text .. "\n" .. getText("UI_OMHTT_DeviceRange", require("OMHTT/ControlAccess").laserRange())
    end
    if require("OMHTT/ControlDefinitions").inputs[kind] then
        text = text .. "\n" .. require("OMHTT/ControlConsumption").description(kind, false)
    end
    local reinforced = string.find(name, "Reinforced", 1, true) ~= nil
    local health = 100
    if kind == "Barrier" then
        local damage = reinforced and (settings.ReinforcedBarrierDamage or 25) or (settings.SpikeBarrierDamage or 10)
        text = text .. "\n" .. getText("UI_OMHTT_DeviceDamage", damage)
        health = (settings.SpikeBarrierHealth or 100) * (reinforced and (settings.ReinforcedBarrierHealthMultiplier or 2) or 1)
    elseif kind == "Bed" then
        health = reinforced and (settings.BedReinforcedHealth or 100) or (settings.BedHealth or 50)
    elseif kind == "Poke" then
        health = settings.PokeHealth or 200
    elseif kind == "Wire" or kind == "Barb" then
        health = 50
        text = text .. "\n" .. getText("UI_OMHTT_DeviceDamage", settings.BarbDamage or 10)
    end
    text = text .. "\n" .. getText("UI_OMHTT_DeviceHealth", health)
    return text
end

return D
