local C = {}
C.passiveKinds = {Plate = true}
C.types = {
    Controller = "Base.OMHTTTrapController",
    Plate = "Base.OMHTTTrapPressurePlate",
    Button = "Base.OMHTTTrapButton",
}

---@param object IsoThumpable Passive sensor
---@param kind string Device family
---@return nil
function C.passive(object, kind)
    if not C.passiveKinds[kind] then return end
    object:setCanPassThrough(true)
    object:setBlockAllTheSquare(false)
    object:setIsThumpable(false)
end

---@param source table? Input state
---@param target table? Receiver state
---@return boolean linked
---@nodiscard
function C.linked(source, target)
    if not source or not target then return false end
    for i = 1, #source.links do
        if source.links[i] == target.id then return true end
    end
    return false
end

---@param params table Native construction context
---@return boolean valid
function C.valid(params)
    local square = params.square
    return square ~= nil and square:TreatAsSolidFloor()
end

---@param item InventoryItem? Candidate defense supply
---@return boolean allowed
function C.storable(item)
    if not item then return false end
    local fullType = item:getFullType()
    if string.find(fullType, "^Base%.OMHTTTrap") or string.find(fullType, "^Base%.OMHTTTurret")
        or string.find(fullType, "^Base%.OMHTTModule") or string.find(fullType, "^Base%.OMHTTAmmo") then return true end
    if fullType == "Base.Battery" or fullType == "Base.CarBattery1" or fullType == "Base.CarBattery2"
        or fullType == "Base.CarBattery3" then return true end
    if item:getDisplayCategory() == "Ammo" then return true end
    local turret = rawget(_G, "OMHTT_Turret")
    return turret ~= nil and turret.kind(item) ~= nil
end

---@param container ItemContainer Controlled stockpile
---@param item InventoryItem Proposed native insertion
---@return boolean allowed
function C.accept(container, item)
    if isServer() or not C.storable(item) then return false end
    return container:getCapacityWeight() + item:getUnequippedWeight() <= 500
end

---@param params table Native placement preview
---@return boolean valid
function C.wall(params)
    local square = params.square
    if not square or not square:TreatAsSolidFloor() then return false end
    return square:getProperties():has(IsoFlagType.WallN) or square:getProperties():has(IsoFlagType.WallW)
end

---@param params table Native construction transaction
---@return table? result
function C.created(params)
    if isClient() then return end
    return require("OMHTT/ControlWorld").create(params)
end

---@param params table Craft menu context
---@return boolean enabled
function OMHTT_ControlMenu(params)
    return true
end

OMHTTControlAccept = C.accept
OMHTT_Controls = C
return C
