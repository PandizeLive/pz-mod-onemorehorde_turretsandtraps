local C = {}
C.types = {
    Controller = "Base.OMHTTTrapController",
    Plate = "Base.OMHTTTrapPressurePlate",
    Button = "Base.OMHTTTrapButton",
}

---@param params table Native construction context
---@return boolean valid
function C.valid(params)
    local square = params.square
    return square ~= nil and square:TreatAsSolidFloor()
end

---@param container ItemContainer Controlled stockpile
---@param item InventoryItem Proposed native insertion
---@return boolean allowed
function C.accept(container, item)
    if isServer() or not item then return false end
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
