local P = {}
P.routes = {
    OMHTTDeploySpikeBarrier = {"Base.OMHTTTrapSpikeBarrier", 2},
    OMHTTDeployReinforcedBarrier = {"Base.OMHTTTrapSpikeBarrierReinforced", 2},
    OMHTTDeployBedSpikes = {"Base.OMHTTTrapBedSpikes", 2, true},
    OMHTTDeployBedSpikesSingle = {"Base.OMHTTTrapBedSpikes", 2},
    OMHTTDeployReinforcedBedSpikes = {"Base.OMHTTTrapBedSpikesReinforced", 2, true},
    OMHTTDeployReinforcedBedSpikesSingle = {"Base.OMHTTTrapBedSpikesReinforced", 2},
    OMHTTDeployConcertinaWire = {"Base.OMHTTTrapConcertinaWire", 2},
    OMHTTBarbs = {"Base.OMHTTTrapBarbedPanel", 2, false, true},
    OMHTTDeployTurret = {"Base.OMHTTTurretBase", 5},
    OMHTTDeployController = {"Base.OMHTTTrapController", 5},
    OMHTTDeployInsetPlate = {"Base.OMHTTTrapPressurePlate", 1},
    OMHTTDeploySwitchButton = {"Base.OMHTTTrapButton", 1},
    OMHTTDeployLever = {"Base.OMHTTTrapLever", 1},
    OMHTTDeployLaser = {"Base.OMHTTTrapLaser", 1},
    OMHTTDeployPoke = {"Base.OMHTTTrapPokeFloorMechanical", 2},
}

---@param item InventoryItem? Exact input
---@param player IsoPlayer Builder
---@param fullType string Required family
---@return boolean valid
---@nodiscard
function P.carried(item, player, fullType)
    local container = item and item:getContainer()
    if not container or not container:isInCharacterInventory(player) or not container:contains(item) then return false end
    local matches = item and (item:getFullType() == fullType
        or fullType == "Base.OMHTTTrapPokeFloorMechanical" and item:getFullType() == "Base.OMHTTTrapPokeFloor")
    return matches and item:getCondition() > 0
end

---@param item InventoryItem Tool
---@return boolean usable
---@nodiscard
function P.usable(item)
    return item:getCondition() > 0
end

return P
