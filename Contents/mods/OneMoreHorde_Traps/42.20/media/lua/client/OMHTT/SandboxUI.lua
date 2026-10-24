if isServer() then return end
require("OptionScreens/SandboxOptions")
require("ISUI/AdminPanel/ISServerSandboxOptionsUI")
require("OptionScreens/ServerSettingsScreen")
require("ISUI/ISLabel")
local UI = {}
-- Filter only the duplicate *presentation*, before native controls are created.
-- Distinct native option IDs preserve both packages' saved values independently.
function UI.triggerSettings(page)
    local settings = page.settings
    if not settings then return page end
    local primary = {}
    for i=1,#settings do primary[settings[i].name]=true end
    for i=#settings,1,-1 do
        local name=settings[i].name
        local common=name and name:gsub("^OMHTurretsTraps%.Traps", "OMHTurretsTraps.")
        local key = name and name:gsub("^OMHTurretsTraps%.", ""):gsub("^Traps", "")
        if (common ~= name and primary[common]) or key == "AutomationEnabled" or key == "ForwardCone"
            or key == "PotatoPlaybackVolume" or key == "DeviceSoundVolume" or key == "ShowTurretRange" then
            table.remove(settings, i)
        end
    end
    return page
end
local groups = {
    {"Sandbox_Title_OMHTurretsTraps_Operation", {"PotatoHealth", "PotatoRequirePower", "PotatoGeneratorFuelPerShot", "IdleSweepSpeed", "DetectionInterval", "TurretPlayerDamageMultiplier", "TurretPlayerWoundMultiplier", "FriendlyPlayerDamageMultiplier", "FriendlyPlayerWoundMultiplier", "HostilePlayerDamageMultiplier", "HostilePlayerWoundMultiplier"}},
    {"Sandbox_Title_OMHTurretsTraps_Standby", {"TurretStandbyEnabled", "TurretIdleSeconds", "TurretWakeSeconds", "TurretAlertDelay", "TurretStateIndicator"}},
    {"Sandbox_Title_OMHTurretsTraps_Storage", {"PotatoAmmoCapacity", "PotatoModuleCapacity", "PotatoMagazineCapacity"}},
    {"Sandbox_Title_OMHTurretsTraps_RotaryBat", {"RotaryBatDamage", "RotaryBatShove", "RotaryBatteryHours", "RotaryBatForwardCone", "RotaryBatHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_RotaryBlades", {"RotaryBladesDamage", "RotaryBladesShove", "RotaryBladesBatteryMultiplier", "RotaryBladesForwardCone", "RotaryBladesHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Potato", {"PotatoTurret", "PotatoDamage", "PotatoCriticalChance", "PotatoCriticalDamage", "PotatoCooldown", "PotatoReloadTime", "PotatoRange", "PotatoTurnSpeed", "PotatoProjectileSpeed", "PotatoKnockdownChance", "PotatoSplashPercent", "PotatoSplashRadius", "PotatoBatteryPercentPerShot", "PotatoForwardCone", "PotatoHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Scrapshot", {"ScrapshotDamage", "ScrapshotRange", "ScrapshotCooldown", "ScrapshotReload", "ScrapshotBatteryPercent", "ScrapshotForwardCone", "ScrapshotHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Ballista", {"BallistaDamage", "BallistaRange", "BallistaCooldown", "BallistaReload", "BallistaBatteryPercent", "BallistaForwardCone", "BallistaHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Arc", {"ArcDamage", "ArcRange", "ArcCooldown", "ArcTargets", "ArcJumpRange", "ArcBatteryPercent", "ArcForwardCone", "ArcHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Lobber", {"LobberDamage", "LobberRange", "LobberCooldown", "LobberReload", "LobberBatteryMultiplier", "LobberForwardCone", "LobberHearingRadius"}},
    {"Sandbox_Title_OMHTurretsTraps_Firearms", {"FirearmTurrets", "FirearmAmmoCapacity", "FirearmAimingLevel", "FirearmAccuracyMultiplier", "FirearmRangeAccuracy", "PrecisionRangeAccuracy", "FirearmDamageMultiplier", "FirearmRangeMultiplier", "FirearmReloadMultiplier", "FirearmRateMultiplier", "FirearmCycleMultiplier", "FirearmTurnSpeed", "FirearmBatteryMultiplier", "FirearmForwardCone"}},
}

local moduleGroups = {
    {"Sandbox_Title_OMHTurretsTraps_Regulator", {"RegulatorFirst", "RegulatorBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Siphon", {"SiphonFirst", "SiphonBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Conservation", {"ConservationFirst", "ConservationBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Power", {"ModulePowerBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Martyrdom", {"MartyrdomRadius", "MartyrdomBonus", "MartyrdomDamage"}},
    {"Sandbox_Title_OMHTurretsTraps_Tack", {"TackRadius", "TackBonus", "TackDamage", "TackLifetime"}},
    {"Sandbox_Title_OMHTurretsTraps_Firing", {"ImprovisedFiringFailure", "EnhancedFireMultiplier"}},
    {"Sandbox_Title_OMHTurretsTraps_Detection", {"EnhancedTurnMultiplier", "EnhancedDetectionInterval"}},
    {"Sandbox_Title_OMHTurretsTraps_Critical", {"CriticalFirst", "CriticalBonus", "CriticalDamageMultiplier"}},
    {"Sandbox_Title_OMHTurretsTraps_Accuracy", {"AccuracyFirst", "AccuracyBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Suppression", {"SuppressionFirstReduction", "SuppressionDiminishing", "SuppressionVolumeFloor"}},
    {"Sandbox_Title_OMHTurretsTraps_RapidFire", {"RapidFireFirst", "RapidFireBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Reload", {"ReloadFirst", "ReloadBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Magazine", {"MagazineFirst", "MagazineBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Velocity", {"VelocityFirst", "VelocityBonus", "VelocityKnockdownFirst", "VelocityKnockdownBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Range", {"RangeFirst", "RangeBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Splitter", {"SplitterDamage"}},
    {"Sandbox_Title_OMHTurretsTraps_Fragment", {"FragmentDamage", "FragmentBonus", "FragmentRange"}},
    {"Sandbox_Title_OMHTurretsTraps_Piercing", {"PiercingRetention"}},
    {"Sandbox_Title_OMHTurretsTraps_InitialBlow", {"InitialBlowFirst", "InitialBlowBonus", "InitialBlowThreshold"}},
    {"Sandbox_Title_OMHTurretsTraps_Execute", {"ExecuteFirst", "ExecuteBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Impact", {"ImpactFirst", "ImpactBonus"}},
    {"Sandbox_Title_OMHTurretsTraps_Capacity", {"ControllerKitRange", "ControllerKitCapacity", "TrapsControllerKitRange", "TrapsControllerKitCapacity", "CapacityImprovisedModuleBonus", "CapacityImprovisedAmmoBonus", "CapacitySmallAmmoBonus", "CapacitySmallModuleBonus", "CapacityAmmoBonus", "CapacityModuleBonus", "CapacityLargeAmmoBonus", "CapacityLargeModuleBonus"}},
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
        panel:insertNewLineOfButtons(control.omhttRarity or control)
    end
    panel.joypadIndex, panel.joypadIndexY = 1, 1
    panel.joypadButtons = panel.joypadButtonsY[1]
    panel:setScrollHeight(y)
end

---@param control ISTextEntryBox Numeric entry
---@return nil
function UI.precision(control)
    if control.omhttPrecision or control.Type ~= "ISTextEntryBox" then return end
    control.omhttPrecision = true
    local setText, getTextValue = control.setText, control.getText
    control.setText = function(self, value)
        local number = tonumber(value)
        self.omhttRaw, self.omhttDisplay = nil, nil
        if number and number == number and math.abs(number) < math.huge then
            local digits = 2
            if math.abs(number) > 0 and math.abs(number) < .01 then
                digits = 10
            end
            local display = string.format("%." .. digits .. "f", number)
            if digits == 10 then
                display = string.gsub(display, "0+$", "")
            end
            self.omhttRaw, self.omhttDisplay = tostring(value), display
            setText(self, display)
        else
            setText(self, value)
        end
    end
    control.getText = function(self)
        local value = getTextValue(self)
        if value == self.omhttDisplay then return self.omhttRaw end
        return value
    end
    control:setText(getTextValue(control))
end

---@param panel ISPanel Sandbox panel
---@return ISPanel panel
function UI.attach(panel)
    if not panel or not panel.controls or panel.omhttTitles then return panel end
    for name, control in pairs(panel.controls) do
        if string.find(name, "^OMHTurretsTraps%.") then
            UI.precision(control)
        end
    end
    local sections = groups
    if panel.controls["OMHTurretsTraps.RapidFireBonus"] or panel.controls["OMHTurretsTraps.TrapsControllerKitRange"] then
        sections = moduleGroups
    elseif panel.controls["OMHTurretsTraps.ModuleLootRate"] or panel.controls["OMHTurretsTraps.TrapsModuleLootRate"] then
        sections = {
            {"Sandbox_Title_OMHTurretsTraps_LootGeneral", {"ModuleLootRate", "PackLootWeight", "PackZombieChance"}},
            {"Sandbox_Title_OMHTurretsTraps_Rarity", {"RarityWeightAbundant", "RarityWeightCommon", "RarityWeightUncommon", "RarityWeightRare", "RarityWeightEpic", "RarityWeightLegendary", "RarityWeightMythic"}},

        }
        local loot = require("OMHTT/ControlLootUI").sections(panel)
        for i = 1, #loot do
            sections[#sections + 1] = loot[i]
        end
    elseif panel.controls["OMHTurretsTraps.SpikeBarrier"] then
        sections = {
            {"Sandbox_Title_OMHTurretsTraps_SharedContact", {"BarbDamage", "BarbInterval", "BarbMovementDivisor", "BedScratchChance", "BedSprintTripChance"}},
            {"Sandbox_Title_OMHTurretsTraps_Barrier", {"SpikeBarrier", "SpikeBarrierDamage", "ReinforcedBarrierDamage", "SpikeBarrierHealth", "ReinforcedBarrierHealthMultiplier", "SpikeBarrierScratchChance"}},
            {"Sandbox_Title_OMHTurretsTraps_Poke", {"PokeDamage", "PokeCycleSeconds", "PokeHealth", "PokeWear", "PokeScratchChance"}},
            {"Sandbox_Title_OMHTurretsTraps_Tether", {"TetherRange", "TetherLaunchSpeed", "TetherReturnSpeed", "TetherHoldSeconds", "TetherResetSeconds", "TetherHitDamage", "TetherPullDamage"}},
            {"Sandbox_Title_OMHTurretsTraps_Beds", {"BedSpikes", "BedDamage", "BedReinforcedDamage", "BedHealth", "BedReinforcedHealth", "BedWear", "BedTripChance", "BedRecoverySeconds"}},
            {"Sandbox_Title_OMHTurretsTraps_BarbedPanel", {"BarbSections"}},
            {"Sandbox_Title_OMHTurretsTraps_ConcertinaWire", {"BarbWire"}},
        }
    elseif panel.controls["OMHTurretsTraps.ControllerRange"] or panel.controls["OMHTurretsTraps.TrapsControllerRange"] then
        local prefix = panel.controls["OMHTurretsTraps.ControllerRange"] and "" or "Traps"
        sections = {
            {"Sandbox_Title_OMHTurretsTraps_Controller", {prefix .. "ControllerRange", prefix .. "ControllerCapacity"}},
            {"Sandbox_Title_OMHTurretsTraps_Laser", {prefix .. "LaserRange", prefix .. "TriggerLaserConsumption"}},
            {"Sandbox_Title_OMHTurretsTraps_Button", {prefix .. "TriggerButtonConsumption"}},
            {"Sandbox_Title_OMHTurretsTraps_Lever", {prefix .. "TriggerLeverConsumption"}},
            {"Sandbox_Title_OMHTurretsTraps_Plate", {prefix .. "TriggerPlateConsumption"}},
            {"Sandbox_Title_OMHTurretsTraps_TriggerAudio", {prefix .. "DeviceSoundVolume"}},
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
            if not panel.controls[name] and panel.controls["OMHTurretsTraps.Traps" .. group[2][j]] then
                name = "OMHTurretsTraps.Traps" .. group[2][j]
            end
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
    return UI.attach(originalPanel(self, UI.triggerSettings(page)))
end
local originalAdmin = ISServerSandboxOptionsUI.createPanel
---@param self ISServerSandboxOptionsUI Screen
---@param page table Page
---@return ISPanel panel
function ISServerSandboxOptionsUI:createPanel(page)
    return UI.attach(originalAdmin(self, UI.triggerSettings(page)))
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
        return UI.attach(original(page, UI.triggerSettings(category), settings))
    end
end
return UI
