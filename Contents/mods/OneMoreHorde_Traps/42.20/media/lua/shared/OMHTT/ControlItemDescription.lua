local Repair = require("OMHTT/ControlRepair")
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
    local profile = Repair.profiles[kind]
    local material = profile.material and ("1 " .. getItemNameFromFullType(profile.material)) or getText("UI_OMHTT_ToolOnly")
    text = text .. "\n" .. getText("UI_OMHTT_DeviceRepair", material, getText(profile.tools), profile.seconds)
        .. "\n" .. getText("UI_OMHTT_DevicePlacement", profile.pickup)
    return text
end

return D
