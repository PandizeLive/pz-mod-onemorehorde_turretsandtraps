if isServer() then return end
require("OptionScreens/SandboxOptions")
require("ISUI/AdminPanel/ISServerSandboxOptionsUI")
require("OptionScreens/ServerSettingsScreen")
require("ISUI/ISLabel")
local UI = {}
local groups = {
    {"Sandbox_Title_OMHTurretsTraps_Operation", {"PotatoTurret", "PotatoHealth", "IdleSweepSpeed"}},
    {"Sandbox_Title_OMHTurretsTraps_Storage", {"PotatoAmmoCapacity", "PotatoModuleCapacity", "PotatoMagazineCapacity"}},
    {"Sandbox_Title_OMHTurretsTraps_Combat", {"PotatoDamage", "PotatoCriticalChance", "PotatoCriticalDamage", "PotatoCooldown", "PotatoReloadTime", "PotatoRange", "PotatoTurnSpeed", "PotatoProjectileSpeed", "PotatoKnockdownChance", "PotatoSplashPercent", "PotatoSplashRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Audio", {"PotatoHearingRadius", "PotatoPlaybackVolume"}},
    {"Sandbox_Title_OMHTurretsTraps_Power", {"PotatoRequirePower", "PotatoBatteryPercentPerShot", "PotatoGeneratorFuelPerShot", "ModulePowerBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Firearms", {"FirearmTurrets", "FirearmAmmoCapacity", "FirearmAimingLevel", "FirearmAccuracyMultiplier", "FirearmRangeAccuracy", "PrecisionRangeAccuracy", "FirearmDamageMultiplier", "FirearmRangeMultiplier", "FirearmReloadMultiplier", "FirearmRateMultiplier", "FirearmCycleMultiplier", "FirearmTurnSpeed"}},
}

local moduleGroups = {
    {"Sandbox_Title_OMHTurretsTraps_Firing", {"ImprovisedFiringFailure", "EnhancedFireMultiplier"}},
    {"Sandbox_Title_OMHTurretsTraps_Detection", {"EnhancedTurnMultiplier", "EnhancedDetectionInterval"}},
    {"Sandbox_Title_OMHTurretsTraps_Critical", {"CriticalBonus", "CriticalDamageMultiplier"}},
    {"Sandbox_Title_OMHTurretsTraps_Accuracy", {"AccuracyBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Suppression", {"SuppressionFirstReduction", "SuppressionDiminishing", "SuppressionVolumeFloor"}},
    {"Sandbox_Title_OMHTurretsTraps_RapidFire", {"RapidFireBonus", "RapidFireBonusCap", "RapidFireMinimum"}},
    {"Sandbox_Title_OMHTurretsTraps_Reload", {"ReloadBonus", "ReloadBonusCap", "ReloadMinimum"}},
    {"Sandbox_Title_OMHTurretsTraps_Magazine", {"MagazineBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Velocity", {"VelocityBonus", "VelocityBonusCap", "VelocityKnockdownBonus", "VelocityKnockdownCap"}},
    {"Sandbox_Title_OMHTurretsTraps_Range", {"RangeBonus", "RangeBonusCap"}},
    {"Sandbox_Title_OMHTurretsTraps_Splitter", {"SplitterDamage"}},
    {"Sandbox_Title_OMHTurretsTraps_Fragment", {"FragmentDamage", "FragmentBonus", "FragmentDamageCap", "FragmentRange"}},
    {"Sandbox_Title_OMHTurretsTraps_Piercing", {"PiercingRetention"}},
    {"Sandbox_Title_OMHTurretsTraps_InitialBlow", {"InitialBlowBonus", "InitialBlowThreshold"}},
    {"Sandbox_Title_OMHTurretsTraps_Execute", {"ExecuteFirst", "ExecuteBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Impact", {"ImpactFirst", "ImpactBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Capacity", {"CapacityImprovisedModuleBonus", "CapacityImprovisedAmmoBonus", "CapacitySmallAmmoBonus", "CapacitySmallModuleBonus", "CapacityAmmoBonus", "CapacityModuleBonus", "CapacityLargeAmmoBonus", "CapacityLargeModuleBonus"}},
}

---@param panel ISPanel Sandbox panel
---@return nil
function UI.layout(panel)
    if panel.omhttWidth == panel:getWidth() then return end
    panel.omhttWidth = panel:getWidth()
    local y = 11
    panel.joypadButtonsY = {}
    for i = 1, #panel.settingNames do
        local name = panel.settingNames[i]
        local title = panel.omhttTitles[name]
        if title then
            title:setX((panel:getWidth() - title:getWidth()) / 2)
            title:setY(y + 20)
            y = y + title:getHeight() + 42
        end
        local label, control = panel.labels[name], panel.controls[name]
        label:setY(y)
        control:setY(y)
        y = y + math.max(label:getHeight(), control:getHeight()) + 10
        panel:insertNewLineOfButtons(control)
    end
    panel.joypadIndex, panel.joypadIndexY = 1, 1
    panel.joypadButtons = panel.joypadButtonsY[1]
    panel:setScrollHeight(y)
end

---@param panel ISPanel Sandbox panel
---@return ISPanel panel
function UI.attach(panel)
    if not panel or not panel.controls or panel.omhttTitles then return panel end
    local sections = groups
    if panel.controls["OMHTurretsTraps.RapidFireBonus"] then
        sections = moduleGroups
    elseif panel.controls["OMHTurretsTraps.SpikeBarrier"] then
        sections = {
            {"Sandbox_Title_OMHTurretsTraps_Barrier", {"SpikeBarrier", "SpikeBarrierDamage", "ReinforcedBarrierDamage", "SpikeBarrierHealth", "ReinforcedBarrierHealthMultiplier", "SpikeBarrierScratchChance"}},
            {"Sandbox_Title_OMHTurretsTraps_Beds", {"BedSpikes", "BedDamage", "BedReinforcedDamage", "BedHealth", "BedReinforcedHealth", "BedWear", "BedTripChance", "BedRecoverySeconds"}},
            {"Sandbox_Title_OMHTurretsTraps_Barbs", {"BarbSections", "BarbWire", "BarbDamage", "BarbInterval", "BarbMovementDivisor"}},
            {"Sandbox_Title_OMHTurretsTraps_PlayerContact", {"BedScratchChance", "BedSprintTripChance"}},
        }
    elseif not panel.controls["OMHTurretsTraps.PotatoTurret"] then
        return panel
    end
    panel.omhttTitles = {}
    panel.titles = panel.titles or {}
    local ordered, used = {}, {}
    for i = 1, #sections do
        local group, first = sections[i], true
        for j = 1, #group[2] do
            local name = "OMHTurretsTraps." .. group[2][j]
            if panel.controls[name] then
                ordered[#ordered + 1], used[name] = name, true
                if first then
                    local title = ISLabel:new(0, 0, getTextManager():getFontHeight(UIFont.Large) + 6,
                        getText(group[1]), 1, 1, 1, 1, UIFont.Large)
                    panel:addChild(title)
                    panel.omhttTitles[name] = title
                    panel.titles[#panel.titles + 1] = title
                    first = false
                end
            end
        end
    end
    for i = 1, #panel.settingNames do
        local name = panel.settingNames[i]
        if not used[name] then ordered[#ordered + 1] = name end
    end
    panel.settingNames = ordered
    local original = panel.prerender
    ---@param self ISPanel Panel
    ---@return nil
    panel.prerender = function(self)
        UI.layout(self)
        original(self)
    end
    return panel
end

local originalPanel = SandboxOptionsScreen.createPanel
---@param self SandboxOptionsScreen Screen
---@param page table Page
---@return ISPanel panel
function SandboxOptionsScreen:createPanel(page)
    return UI.attach(originalPanel(self, page))
end
local originalAdmin = ISServerSandboxOptionsUI.createPanel
---@param self ISServerSandboxOptionsUI Screen
---@param page table Page
---@return ISPanel panel
function ISServerSandboxOptionsUI:createPanel(page)
    return UI.attach(originalAdmin(self, page))
end
local originalCreate = ServerSettingsScreen.create
---@param self ServerSettingsScreen Screen
---@return nil
function ServerSettingsScreen:create()
    originalCreate(self)
    local original = self.pageEdit.createPanel
    ---@param page table Page editor
    ---@param category table Category
    ---@param settings table Settings
    ---@return ISPanel panel
    self.pageEdit.createPanel = function(page, category, settings)
        return UI.attach(original(page, category, settings))
    end
end
return UI
