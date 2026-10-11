local S = {}
S.NATIVE = {
    ["DesertEagleShoot"] = "OMHTTSuppressedDesertEagleShoot",
    ["DoubleBarrelShotgunShoot"] = "OMHTTSuppressedDoubleBarrelShotgunShoot",
    ["JS14Shoot"] = "OMHTTSuppressedJS14Shoot",
    ["JS2000ShotgunShoot"] = "OMHTTSuppressedJS2000ShotgunShoot",
    ["L92Shoot"] = "OMHTTSuppressedL92Shoot",
    ["L94Shoot"] = "OMHTTSuppressedL94Shoot",
    ["M14Shoot"] = "OMHTTSuppressedM14Shoot",
    ["M16Shoot"] = "OMHTTSuppressedM16Shoot",
    ["M1911Shoot"] = "OMHTTSuppressedM1911Shoot",
    ["M36Shoot"] = "OMHTTSuppressedM36Shoot",
    ["M625Shoot"] = "OMHTTSuppressedM625Shoot",
    ["M9Shoot"] = "OMHTTSuppressedM9Shoot",
    ["MSR700Shoot"] = "OMHTTSuppressedMSR700Shoot",
    ["MSR788Shoot"] = "OMHTTSuppressedMSR788Shoot",
    ["MagnumShoot"] = "OMHTTSuppressedMagnumShoot",
    ["SawnOffDoubleBarrelShotgunShoot"] = "OMHTTSuppressedSawnOffDoubleBarrelShotgunShoot",
    ["SawnOffJS2000ShotgunShoot"] = "OMHTTSuppressedSawnOffJS2000ShotgunShoot",
    ["TrapperCarbineShoot"] = "OMHTTSuppressedTrapperCarbineShoot",
}

---@param head InventoryItem Installed head
---@return string? sound Prepared replacement
---@nodiscard
function S.suppressed(head)
    if head:getFullType() == "Base.OMHTTTurretPotato" then return "OMHTTPotatoSuppressed" end
    return S.NATIVE[head:getSwingSound()]
end

return S
